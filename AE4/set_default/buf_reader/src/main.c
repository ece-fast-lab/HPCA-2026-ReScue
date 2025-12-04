#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "command.h"
#include "util.h"

#define IF_FAIL_THEN_EXIT       if (ret != 0) goto FAILED;

int init( uint64_t** pci_vaddr) {
    int         pci_fd;
    int         init_ok;

    /* Initialize CSR access */
    init_ok = init_csr(&pci_fd, &(*pci_vaddr));
    if (init_ok) goto FAILED;
    return 0;

FAILED:
    return -1;
}

void test_hw(uint64_t* pci_vaddr) {
    /* Zero out the counters on the hardware */
    LOG_INFO("  Sending zero out command to the hardware...\n");
    if (start_zeroout(pci_vaddr)) goto FAILED;


    /* Wait for some time to increment the counter */
    LOG_INFO("  Wait for 10 sec\n");
    sleep(10);


    /* Send the writeback command to the hardware */
    LOG_INFO("  Sending write back command to the hardware...\n");
    if (start_writeback(pci_vaddr)) goto FAILED;


    /* Wait for some time */
    LOG_INFO("  Wait for 1 sec\n");
    sleep(1);
    
    return;
FAILED:
    LOG_INFO(" Failed in test_hw\n");
}

int main(int argc, char *argv[]){
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }
    int ret;
    uint64_t* pci_vaddr;
    ret = init(&pci_vaddr);
    IF_FAIL_THEN_EXIT
    process_addresses(argv[1],pci_vaddr);
    return 0;
FAILED:
    LOG_ERROR(" Failure detected.\n");
    return -1;
}




