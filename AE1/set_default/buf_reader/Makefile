CFLAGS+=-Wall -g -Iinclude
CC=gcc

SRC=$(wildcard src/*.c)
HEADERS = $(wildcard include/*.h)
OBJ = $(patsubst %.c, %.o, $(SRC))

all: buf_reader

buf_reader: $(OBJ)
	$(CC) $^ -o $@

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f *.o */*.o
	rm -f buf_reader

