#!/usr/bin/env python3
# bank_pair_scatter.py
import pandas as pd, numpy as np, matplotlib.pyplot as plt, sys, os
from collections import defaultdict

# ───────────────────────────────────────── Bank-bit decode
def decode_bank_bits(addr):
    ch   = (addr >> 6)  & 0x1
    bg   = (addr >> 7)  & 0x3
    ba   = (addr >> 16) & 0x3
    rank = (addr >> 18) & 0x1
    return ch, rank, bg, ba
# def decode_bank_bits(addr: int):
#     ch   = (addr >> 6)  & 0x1
#     bg   = (addr >> 7)  & 0x3
#     # New BA extraction using XOR with bit 15
#     ba_hi = (addr >> 17) & 0x1
#     ba_lo = (addr >> 16) & 0x1
#     ba_x  = (addr >> 15) & 0x1
#     ba    = ((ba_hi << 1) | ba_lo) ^ ba_x
#     rank = (addr >> 18) & 0x1
#     return ch, rank, bg, ba

def bank_id(addr):
    ch, rk, bg, ba = decode_bank_bits(addr)
    return (ch << 5) | (rk << 4) | (bg << 2) | ba   # 0‥63

def classify_pair(addr_b, addr_p):
    cb, rb, gbb, bab = decode_bank_bits(addr_b)
    cp, rp, gbp, bap = decode_bank_bits(addr_p)
    if   (cb, rb, gbb, bab) == (cp, rp, gbp, bap): return "BANK"
    elif (cb, rb, gbb)      == (cp, rp, gbp)     : return "BG"
    elif (cb, rb)           == (cp, rp)          : return "RANK"
    elif  cb                ==  cp               : return "CH"
    else                                           : return "INTERLEAVE"

# ───────────────────────────────────────── Main
def main(csv_path):
    df = pd.read_csv(csv_path)
    assert {'base','probe','time'}.issubset(df.columns), "CSV must have base, probe, time"

    # Pre-process
    df['base_int']   = df['base'].apply(lambda x: int(x,16))
    df['probe_int']  = df['probe'].apply(lambda x: int(x,16))
    df['latency_ns'] = df['time'] / 2.2                 # 2 GHz → 0.5 ns/clk
    df['base_id']    = df['base_int'].apply(bank_id)
    df['probe_id']   = df['probe_int'].apply(bank_id)
    df['class']      = df.apply(lambda r: classify_pair(r.base_int, r.probe_int), axis=1)

    # 
    pair_stats = (df
        .groupby(['base_id','probe_id','class'])
        .agg(avg_ns=('latency_ns','mean'),
             std_ns=('latency_ns','std'),
             count =('latency_ns','size'))
        .reset_index())

    # 
    stem  = os.path.splitext(os.path.basename(csv_path))[0]
    out_csv = f"{stem}_pair_stats.csv"
    out_png = f"{stem}_pair_scatter.png"
    pair_stats.to_csv(out_csv, index=False)
    print(f"[✓] Per-pair stats saved ➜ {out_csv}")

    #
    color_map = {
        "BANK":"#d62728",       # red
        "BG":"#ff7f0e",         # orange
        "RANK":"#2ca02c",       # green
        "CH":"#1f77b4",         # blue
        "INTERLEAVE":"#7f7f7f"  # gray
    }
    plt.figure(figsize=(9,7))
    for cls, grp in pair_stats.groupby('class'):
        plt.scatter(grp['avg_ns'], grp['std_ns'],
                    s=40, alpha=0.75,
                    c=color_map.get(cls,'black'),
                    label=f"{cls} ({len(grp)})")

    plt.xlabel("Average latency (ns)")
    plt.ylabel("Std-dev latency (ns)")
    plt.title("Latency scatter for every 64×64 bank pair")
    plt.xlim(340, 460)       # x: 0 ~ 30
    plt.ylim(0, 30)    # y: 340 ~ 460

    plt.grid(True, linestyle=":")
    plt.legend(title="Conflict class", fontsize=8)
    plt.tight_layout()
    plt.savefig(out_png, dpi=300)
    #plt.show()
    print(f"[✓] Scatter saved     ➜ {out_png}")

if __name__ == "__main__":
    if len(sys.argv)!=2:
        print("Usage: python3 bank_pair_scatter.py <raw_csv>")
        sys.exit(1)
    main(sys.argv[1])
