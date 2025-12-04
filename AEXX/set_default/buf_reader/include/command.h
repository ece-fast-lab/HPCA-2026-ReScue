#ifndef _COMMAND_H
#define _COMMAND_H

#include <stdint.h>

#define NUM_COUNTERS            (512 / 16 * 65536)
#define TRACER_REGION_SIZE      (2UL * NUM_COUNTERS)    // 4 MB <=> record 8GB of memory

int init_csr(int *fd_out, uint64_t **ptr_out);
int set_writeback_addr(uint64_t* pci_vaddr, uint64_t wb_addr);
int start_writeback(uint64_t* pci_vaddr);
int start_zeroout(uint64_t* pci_vaddr);
int clean_csr(int pci_fd, uint64_t *pci_vaddr);
uint64_t hash1(uint64_t addr);
uint64_t hash2(uint64_t addr);
uint64_t hash3(uint64_t addr);
int process_addresses(const char *filename,uint64_t* pci_vaddr);
#endif