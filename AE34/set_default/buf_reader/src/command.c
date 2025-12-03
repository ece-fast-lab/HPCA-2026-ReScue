#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdarg.h>
#include "command.h"
#include "util.h"
#include <xmmintrin.h>  // Header for _mm_mfence

/**
 * init_csr
 *   @brief Open the PCIe file and map to virtual memory
 *   @param pci_fd the pointer to the variable that will take the return value of fd
 *   @param pci_vaddr the pointer to the variable that will take the return value of mapped virtual address
 *   @return 0 means succedded, -1 means failed
 */
int init_csr(int *pci_fd, uint64_t **pci_vaddr) {

    uint64_t *ptr;
    int fd;

    fd = open("/sys/devices/pci0000:6a/0000:6a:00.1/resource2", O_RDWR | O_SYNC);
    if(fd == -1){
        LOG_ERROR(" Open BAR2 failed.\n");
        return -1;
    }
    LOG_INFO(" PCIe File opened.\n");

    ptr = mmap(0, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if(ptr == (void *) -1){
        LOG_ERROR(" PCIe Device mmap not successful. Found -1.\n");
        close(fd);
        return -1;
    }
    if(ptr == (void *) 0){
        LOG_ERROR(" PCIe Device mmap not successful. Found 0.\n");
        close(fd);
        return -1;
    }

    LOG_INFO(" PCIe Device mmap succeeded.\n");
    LOG_INFO(" PCIe Memory mapped to address 0x%016lx.\n", (unsigned long) ptr);

    *pci_fd = fd;
    *pci_vaddr = ptr;

    return 0;
}

/**
 * clean_csr
 *   @brief Close the PCIe file and unmap the virtual memory
 *   @param pci_fd  the opened PCIe file
 *   @param pci_vaddr the mapped virtual address
 *   @return 0 means succedded, -1 means failed
 */
int clean_csr(int pci_fd, uint64_t *pci_vaddr) {

    int ret;
    
    ret = munmap(pci_vaddr, 4096); 
    if (ret < 0) {
        LOG_ERROR(" mummap not successful.\n");
        return -1;
    }
    close(pci_fd);
    
    return 0;
}

/**
 * start_writeback
 *   @brief Start the write back process. Currently you need to 
 *          wait for 1 sec to make sure this process completes
 *   @param pci_vaddr the mapped virtual address
 *   @return 0 means succedded, -1 means failed
 */
int start_writeback(uint64_t* pci_vaddr) {

    smart_log("writing back cnt ...\n");

    if (pci_vaddr == NULL) return -1;
    for(int i=0;i<64;i++){
    	*(pci_vaddr + i) = 1;
    	printf("value in addr %d is %ld\n",i,*(pci_vaddr+i));
    }
    
    return 0;
}

/**
 * start_zeroout
 *   @brief Start to zero out the contents inside counter buffer. Currently you 
 *          need to wait for 1 sec to make sure this process completes.
 *   @param pci_vaddr the mapped virtual address
 *   @return 0 means succedded, -1 means failed
 */
int start_zeroout(uint64_t* pci_vaddr) {

    smart_log("zero out sram ...\n");

    if (pci_vaddr == NULL) return -1;

    *(pci_vaddr + 16) = 1;

    return 0;
}

int count_lines(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Failed to open file");
        return -1;
    }

    int lines = 0;
    char ch;
    while (!feof(file)) {
        ch = fgetc(file);
        if (ch == '\n') {
            lines++;
        }
    }
    printf("Number of lines : %d lines \n", lines);

    fclose(file);
    return lines;
}

uint64_t binary_to_uint64(const char *binary_str) {
    uint64_t result = 0;
    while (*binary_str) {
        result = (result << 1) + (*binary_str++ - '0');
    }
    return result;
    
}

int process_addresses(const char *filename,uint64_t* pci_vaddr) {
    smart_log("processing addresses ...\n");
    if (pci_vaddr == NULL) return -1;

    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Failed to open file");
        return -1;
    }

    int total_lines = count_lines(filename);
    if (total_lines == -1) {
        return -1;
    }
    
    char binary_str[65];  // 64 characters for the binary number + 1 for the null terminator
    uint64_t addr;
    int idx = 0;
    int writes =0;
    rewind(file); // Reset file pointer to the beginning

    // Reset Bloomfilter
    // for (int i=0 ; i < 64 ; i++) {
        
    //     addr = 0xffffffffffffffff;

    //     printf("RESET : Writing value %lx to register %d\n", addr, i);
    //     *(pci_vaddr + i) = addr;
    //     printf("RESET : Value in reg %d is %lx\n", i, *(pci_vaddr + i));
       
    // }

    sleep(1);   

    while (fscanf(file, "%64s", binary_str) == 1) {
        
        addr = binary_to_uint64(binary_str);
        //printf("Binary string: %s\n", binary_str);
        //printf("Converted value: %lx\n", addr); // Print as hex


        printf("Writing value %lx to register %d\n", addr, idx);
        *(pci_vaddr + idx) = addr;
        //printf("Value in reg %d is %lx\n", idx, *(pci_vaddr + idx));
        asm volatile("mfence" ::: "memory");
        writes++;
        //printf("Value in reg %d is %lx\n", idx, *(pci_vaddr + idx));
        idx = (idx + 1) % 64;
        if (writes % 64 == 0) {
            printf("write %d lines \n", writes);
            //sleep(1);
            for (int i=0 ; i < 64 ; i++){
                printf("Value in reg %d is %lx\n", i, *(pci_vaddr + i));
            }
        }
    }
    fclose(file);
    return 0;
}
