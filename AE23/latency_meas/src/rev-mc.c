#include <stdbool.h>
#include <time.h>
#include <stdlib.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <assert.h>
#include <inttypes.h>
#include <string.h>


#include <vector>
#include <functional>
#include <algorithm>
#include <bitset>  

#include "rev-mc.h"

// #define BOOL_XOR(a,b) ((a) != (b))
#define O_HEADER "base,probe,time\n"
#define ALIGN_TO(X, Y) ((X) & (~((1LL<<(Y))-1LL))) // Mask out the lower Y bits
// #define LS_BITMASK(X)  ((1LL<<(X))-1LL) // Mask only the lower X bits

// #define SET_SIZE 40 // elements per set 
// // #define VALID_THRESH    0.75f
// // #define SET_THRESH      0.95f
// #define BITSET_SIZE 256  // bitset used to exploit bitwise operations 
// #define ROW_SET_CNT 5

// from https://stackoverflow.com/questions/1644868/define-macro-for-debug-printing-in-c
// #define verbose_printerr(fmt, ...) \
// 	do { if (flags & F_VERBOSE) { fprintf(stderr, fmt, ##__VA_ARGS__); } } while(0)



typedef std::vector<addr_tuple> set_t; 

//-------------------------------------------
//-------------------------------------------
uint64_t time_tuple(volatile char* a1, volatile char* a2, size_t rounds) {

    uint64_t* time_vals = (uint64_t*) calloc(rounds, sizeof(uint64_t));
    uint64_t t0;
    sched_yield();
    for (size_t i = 0; i < rounds; i++) {
        mfence();
        t0 = rdtscp();
        *a1;
        *a2;
        time_vals[i] = rdtscp() - t0; 
        lfence();
        clflush(a1);
        clflush(a2);

    }

    uint64_t mdn = median(time_vals, rounds);
    free(time_vals);
    return mdn;
}



//----------------------------------------------------------
char* get_rnd_addr(char* base, size_t m_size, size_t align) {
        return (char*) ALIGN_TO((uint64_t) base, (uint64_t) align) + ALIGN_TO(rand() % m_size, (uint64_t) align);
}



//----------------------------------------------------------
uint64_t get_pfn(uint64_t entry) {
    return ((entry) & 0x3fffffffffffff);
}

//----------------------------------------------------------
uint64_t get_phys_addr(uint64_t v_addr) 
{
    uint64_t entry; 
    uint64_t offset = (v_addr/4096) * sizeof(entry);
    uint64_t pfn; 
    int fd = open("/proc/self/pagemap", O_RDONLY);
    assert(fd >= 0);
    int bytes_read = pread(fd, &entry, sizeof(entry), offset);
    close(fd);
    assert(bytes_read == 8);
    assert(entry & (1ULL << 63));
    pfn = get_pfn(entry);
    assert(pfn != 0);
    return (pfn*4096) | (v_addr & 4095); 
}


//----------------------------------------------------------
addr_tuple gen_addr_tuple(char* v_addr) {
    return (addr_tuple) { v_addr, get_phys_addr((uint64_t) v_addr)};
}




//----------------------------------------------------------
// https://www.cs.umd.edu/~gasarch/TOPICS/factoring/fastgauss.pdf
// gaussian elimination in GF2 

//----------------------------------------------------------
// from https://graphics.stanford.edu/~seander/bithacks.html#NextBitPermutation

//----------------------------------------------------------

//----------------------------------------------------------

//----------------------------------------------------------
/* 
It currently finds some of the interesting bits for the row addressing. 
@TODO 	still need to figure out which bits are used for the row addressing and which 
	are from the bank selection. This is currently done manually 
*/

//----------------------------------------------------------
void rev_mc(size_t rep_cnt, size_t iter_cnt, size_t rounds, size_t m_size, char* o_file, uint64_t flags) {

    time_t t;

    int o_fd = 0;
    int huge_fd = 0;
    
    size_t iter = 0;

    //std::vector<set_t> sets;
    //std::vector<char*> used_addr;
    //std::vector<uint64_t> fn_masks;

    srand((unsigned) time(&t));

    if (flags & F_EXPORT) {
        if (o_file == NULL) {
            fprintf(stderr, "[ERROR] - Missing export file name\n");
            exit(1);
        }
        if((o_fd = open(o_file, O_CREAT|O_RDWR)) == -1) {
            perror("[ERROR] - Unable to create export file");
            exit(1);
        }
    dprintf(o_fd, O_HEADER);
    }

    mem_buff_t mem = {
        .buffer = NULL,
        .size   = m_size,
        .flags  = flags ,
    };

    alloc_buffer(&mem);


    while (iter < iter_cnt) {
        char* rnd_addr_tar = get_rnd_addr(mem.buffer, mem.size, CL_SHIFT);
        char* rnd_addr_org = get_rnd_addr(mem.buffer, mem.size, CL_SHIFT);
 
        addr_tuple tp_tar = gen_addr_tuple(rnd_addr_tar);
        addr_tuple tp_org = gen_addr_tuple(rnd_addr_org);

        bool found_set = false;
        for (size_t idx = 0; idx < rep_cnt; idx++) {
            uint64_t time = 0;
            time = time_tuple((volatile char*) tp_org.v_addr, (volatile char*) tp_tar.v_addr, rounds);
            dprintf(o_fd, "%lx,%lx,%ld\n",(uint64_t) tp_org.v_addr, (uint64_t) tp_tar.v_addr,time);
        }
        iter = iter+1;
        fprintf(stderr, "[ LOG ] - Iteration : %ld\n", iter);
    }

    free_buffer(&mem);
}



// Fin.

//----------------------------------------------------------
//          Helpers

//----------------------------------------------------------
