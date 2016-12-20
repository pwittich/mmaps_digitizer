#ifndef _zynq_spi_library_h
#define _zynq_spi_library_h

#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>

#define SPI_READ_REG 0x00
#define SPI_WRITE_REG 0x10
#define SPI_READ_FIFO 0x20

extern uint32_t spiSpeed;// = 10000000;
extern uint32_t spiMode;// = 0x0000;
extern uint8_t spiBitsPerWord;// = 8;

void spiInit(int fd);

void spiTransfer(int fd, uint8_t const *tx, uint8_t *rx, size_t len);

void spiReadRegister(int fd, uint8_t address);

void spiWriteRegister(int fd, uint8_t address, uint8_t value);

void spiReadFifo(int fd, uint8_t howmany);

void hexDump(const void * src, size_t length);

#endif // _zynq_spi_library_h
