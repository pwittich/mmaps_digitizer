#include <getopt.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <linux/types.h>
#include "zynq_spi_library.h"

uint8_t command;
static char * reg;
static char * value;
static char * howmany;

static const char * spiDevice = "/dev/spidev32766.0";

static void printUsage(const char *progName) {
	printf("Usage: %s [-RWV]\n", progName);
	puts("-R --read   read register from Cyclone\n"
	     "-W --write  write to register in Cyclone\n"
	     "-V --value  value to write in register\n"
	     "-D --data   read XX amount of data from Cyclone\n");
	exit(1);
}

static void parseOptions(int argc, char * argv[]) {
	while(1) {
		static const struct option optList[] = {
			{"read",   1, 0, 'R'},
			{"write",  1, 0, 'W'},
			{"value",  1, 0, 'V'},
			{"data",   1, 0, 'D'},
			{NULL,     0, 0,  0}
		};

		int c;
		c = getopt_long(argc, argv, "R:W:V:D:", optList, NULL);

		if (c == -1) 
			break;
		
		switch(c) {
		case 'R':
			command = SPI_READ_REG;
			reg = optarg;
			break;
		case 'W':
			command = SPI_WRITE_REG;
			reg = optarg;
			break;
		case 'V':
			value = optarg;
			break;
		case 'D':
			command = SPI_READ_FIFO;
			howmany = optarg;
			break;
		default:
			printUsage(argv[0]);
			break;
		}
	}
}

static int unescapeHex(char * _dst, char * _src) {
	int returnCode = 0;
	char * src = _src;
	char * dst = _dst;
	unsigned int ch;

	while (*src) {
		if (*src == '\\' && *(src+1) == 'x') {
			sscanf(src + 2, "%2X", &ch);
			src += 4;
			*dst++ = (unsigned char) ch;
		}
		else {
			*dst++ = *src++;
		}
		returnCode++;
	}
	return returnCode;
}

void processRequest(int fd) {
	int size;
	uint8_t *unReg;
	uint8_t *unValue;
	uint8_t *unHowmany;

	switch (command) {

	case SPI_READ_REG:

		size = strlen(reg+1);
		unReg = malloc(size);
		size = unescapeHex((char *)unReg, reg);
	
		spiReadRegister(fd, *unReg);

		free(unReg);

		break;

	case SPI_WRITE_REG:

		size = strlen(reg+1);
		unReg = malloc(size);
		size = unescapeHex((char *)unReg, reg);

		size = strlen(value+1);
		unValue = malloc(size);
		size = unescapeHex((char *)unValue, value);

		spiWriteRegister(fd, *unReg, *unValue);

		free(unReg);
		free(unValue);

		break;

	case SPI_READ_FIFO:

		size = strlen(howmany+1);
		unHowmany = malloc(size);
		size = unescapeHex((char *)unHowmany, howmany);

		spiReadFifo(fd, *unHowmany);

		free(unHowmany);

		break;

	default:
		break;
	}
}
	
int main(int argc, char * argv[]) {

	int fd;
	uint8_t *unReg;
	uint8_t *unValue;

	fd = open(spiDevice, O_RDWR);

	spiInit(fd);

	parseOptions(argc, argv);
/*
	int size = strlen(reg+1);
	unReg = malloc(size);
	size = unescapeHex((char *)unReg, reg);

	if (command == SPI_WRITE) {
		size = strlen(value+1);
		unValue = malloc(size);
		size = unescapeHex((char *)unValue, value);
	}

	if (command == SPI_READ_REG)
		spiReadRegister(fd, *unReg);
	else if (command == SPI_WRITE)
		spiWriteRegister(fd, *unReg, *unValue);
	else if (command == SPI_READ_FIFO)
		spiReadFifo(fd, *howmany);

	free(unReg);
	if (command == SPI_WRITE)
		free(unValue);
*/
	processRequest(fd);

	close(fd);

	return 0;
}
