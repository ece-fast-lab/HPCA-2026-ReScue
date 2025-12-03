#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <pthread.h>
#include <time.h>
#include <string.h>

#define ARRAY_SIZE ((size_t)512 * 1024 * 1024 / sizeof(int64_t))  // 512 MiB per thread

typedef struct {
    int64_t *array;
    size_t total_accesses;
    int read_per_loop;
    int write_per_loop;
} thread_args_t;

void *memory_benchmark_thread(void *arg) {
    thread_args_t *args = (thread_args_t *)arg;
    int64_t *array = args->array;
    size_t total_accesses = args->total_accesses;
    int read_per_loop = args->read_per_loop;
    int write_per_loop = args->write_per_loop;
    int loop_stride = read_per_loop + write_per_loop;

    size_t idx = 0;
    int64_t sum0 = 0, sum1 = 0;

    while (idx + loop_stride <= total_accesses) {
        // Unrolled reads
        for (int i = 0; i < read_per_loop; i += 2) {
            sum0 += array[(idx + i) % total_accesses];
            sum1 += array[(idx + i + 1) % total_accesses];
        }

        // Unrolled writes
        for (int i = 0; i < write_per_loop; i += 2) {
            array[(idx + read_per_loop + i) % total_accesses] = sum0;
            array[(idx + read_per_loop + i + 1) % total_accesses] = sum1;
        }

        idx += loop_stride;
    }

    return NULL;
}

void memory_benchmark(double read_write_ratio, int num_threads) {
    pthread_t threads[num_threads];
    thread_args_t args[num_threads];
    size_t chunk_size = ARRAY_SIZE;

    int read_per_loop = (int)(read_write_ratio * 64);
    int write_per_loop = 64 - read_per_loop;

    if (read_per_loop % 2 != 0) read_per_loop++;  // for unrolling
    if (write_per_loop % 2 != 0) write_per_loop++;

    int64_t **arrays = malloc(num_threads * sizeof(int64_t *));
    for (int i = 0; i < num_threads; i++) {
        if (posix_memalign((void **)&arrays[i], 64, chunk_size * sizeof(int64_t)) != 0) {
            printf("Aligned memory allocation failed for thread %d\n", i);
            exit(1);
        }

        // Optional: memset to prevent page faults later
        memset(arrays[i], 0, chunk_size * sizeof(int64_t));
    }

    clock_t start = clock();

    for (int i = 0; i < num_threads; i++) {
        args[i].array = arrays[i];
        args[i].total_accesses = chunk_size;
        args[i].read_per_loop = read_per_loop;
        args[i].write_per_loop = write_per_loop;
        pthread_create(&threads[i], NULL, memory_benchmark_thread, &args[i]);
    }

    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
    }

    clock_t end = clock();
    double elapsed = (double)(end - start) / CLOCKS_PER_SEC;

    double total_data_gb = (read_per_loop + write_per_loop) * sizeof(int64_t)
                         * ((chunk_size / (read_per_loop + write_per_loop)) * num_threads)
                         / (1024.0 * 1024.0 * 1024.0);
    double bandwidth = total_data_gb / elapsed;

    printf("\rTotal bandwidth: %.2f GB/s\n\r", bandwidth);

    for (int i = 0; i < num_threads; i++) {
        free(arrays[i]);
    }
    free(arrays);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <read_write_ratio> <num_threads>\n", argv[0]);
        return -1;
    }

    double read_write_ratio = atof(argv[1]);
    int num_threads = atoi(argv[2]);

    if (read_write_ratio < 0.0 || read_write_ratio > 1.0) {
        printf("Read/Write ratio must be between 0.0 and 1.0\n");
        return -1;
    }

    if (num_threads <= 0) {
        printf("Number of threads must be > 0\n");
        return -1;
    }

    printf("\rRunning streaming benchmark: R/W = %.2f, threads = %d\n", read_write_ratio, num_threads);
    memory_benchmark(read_write_ratio, num_threads);
    return 0;
}


