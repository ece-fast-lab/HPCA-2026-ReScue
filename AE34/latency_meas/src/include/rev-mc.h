#include "utils.h"
#include "unistd.h"


typedef struct {
	char* 		v_addr; 
	uint64_t 	p_addr;
} addr_tuple;

//----------------------------------------------------------
// 			Functions


void rev_mc(size_t rep_cnt, size_t iter_cnt, size_t rounds, size_t m_size, char* o_file, uint64_t flags);
