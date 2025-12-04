import sys
import os
import csv
import matplotlib.pyplot as plt
from collections import defaultdict

def main():
    # Check command-line arguments
    if len(sys.argv) < 2:
        print("Usage: python classify_and_plot.py <input_csv>")
        sys.exit(1)

    # 1. Receive CSV file name from the command line
    input_csv = sys.argv[1]

    # 2. Derive output file names from the input file name
    base_name, _ = os.path.splitext(input_csv)
    output_csv = f"{base_name}_time_distribution.csv"
    output_png = f"{base_name}_time_distribution.png"

    time_counts = defaultdict(int)
    total_samples = 0

    # 3. Read the CSV and compute time in ns (for 2.2 GHz => ~0.4545 ns per cycle)
    with open(input_csv, 'r', newline='') as file:
        reader = csv.reader(file)

        # If there's a header, uncomment the following line to skip it:
        # next(reader)

        for row in reader:
            try:
                time_in_cycles = float(row[2])
            except (ValueError, IndexError):
                # Skip any row that doesn't have a valid float in the third column
                continue

            time_in_ns = time_in_cycles / 2.2
            ns_bucket = int(round(time_in_ns))  # bucket into 1 ns intervals

            time_counts[ns_bucket] += 1
            total_samples += 1

    # 4. Sort the buckets
    sorted_ns = sorted(time_counts.keys())


    # 5. Write out the distribution to a CSV file
    with open(output_csv, 'w', newline='') as out_file:
        writer = csv.writer(out_file)
        writer.writerow(["Time(ns)", "Count", "Proportion"])

        for ns_bin in sorted_ns:
            count = time_counts[ns_bin]
            proportion = count / total_samples
            writer.writerow([ns_bin, count, proportion])

    # 6. Plot the distribution as a bar chart
    x_vals = sorted_ns
    y_vals = [time_counts[ns_bin] for ns_bin in x_vals]

    plt.figure(figsize=(10, 6))
    plt.bar(x_vals, y_vals, color='steelblue')
    plt.xlabel('Time (ns)')
    plt.ylabel('Count')
    plt.title('Time Distribution (1 ns buckets)')
    plt.tight_layout()

    # 7. Save the plot
    plt.savefig(output_png)
    plt.close()

if __name__ == "__main__":
    main()

