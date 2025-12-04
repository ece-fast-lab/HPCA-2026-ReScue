#ifndef UTIL_H
#define UTIL_H

#include <stdint.h>
#include <stdbool.h>

#define DEBUG 1
#define debug_print(fmt, ...) \
        do { if (DEBUG) fprintf(stderr, "%s:%d:%s(): " fmt, __FILE__, \
                                __LINE__, __func__, __VA_ARGS__); } while (0)



/* text color */
#define RED   "\x1B[31m"
#define GRN   "\x1B[32m"
#define YEL   "\x1B[33m"
#define BLU   "\x1B[34m"
#define MAG   "\x1B[35m"
#define CYN   "\x1B[36m"
#define WHT   "\x1B[37m"
#define RESET "\x1B[0m"

#define LOG_INFO(...) ( printf(GRN "[INFO] " RESET), printf(__VA_ARGS__) )
#define LOG_WARN(...) ( printf(YEL "[WARN] " RESET), printf(__VA_ARGS__) )
#define LOG_DEBUG(...) ( printf(MAG "[DEBUG] " RESET), printf(__VA_ARGS__) )
#define LOG_ERROR(...) ( printf(RED "[ERROR] " RESET), printf(__VA_ARGS__) )

#define smart_log(...) ( printf(CYN "[%s]: " RESET, __func__ ) , printf(__VA_ARGS__) )

#define MAX_OP_CNT    1024
#define MAX_PATH_LEN  256

#endif
