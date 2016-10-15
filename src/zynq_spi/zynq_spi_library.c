#include "zynq_spi_library.h"

uint32_t spiMode = 0x000;
uint32_t spiSpeed = 10000000;
uint8_t spiBitsPerWord = 8;

void spiInit(int fd) {
	int returnCode;
	returnCode = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &spiBitsPerWord);
	returnCode = ioctl(fd, SPI_IOC_WR_MODE32, &spiMode);
	returnCode = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &spiSpeed);
}

void spiTransfer(int fd, uint8_t const *tx, uint8_t *rx, size_t len) {
	int returnCode;

	struct spi_ioc_transfer transfer = {
		.tx_buf = (unsigned long) tx,
		.rx_buf = (unsigned long) rx,
		.len = len,
		.speed_hz = spiSpeed,
		.bits_per_word = spiBitsPerWord
	};

	returnCode = ioctl(fd, SPI_IOC_MESSAGE(1), &transfer);
}

void spiReadRegister(int fd, uint8_t address) {

	printf("Reading register %1X\n", address);

	uint8_t tx = ((address & 0x0f) << 4) | ((SPI_READ_REG & 0xf0) >> 4);
	uint8_t rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	tx = 0x00;
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	printf("Value of register %1X: %02X\n", address, rx);
}

void spiWriteRegister(int fd, uint8_t address, uint8_t value) {

	printf("Writing to register %1X with word %2X\n", address, value);

	uint8_t tx = ((address & 0x0f) << 4) | ((SPI_WRITE_REG & 0xf0) >> 4);
	uint8_t rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	tx = value;
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	printf("Successfully wrote to register %1X!\n", address);
}

void spiReadFifo(int fd, uint8_t howmany) {

	printf("Reading %d ADC samples from the Cyclone...\n", howmany);
	
	uint8_t address = 0x00;
	uint8_t value = howmany;

	uint8_t tx = ((address & 0x0f) << 4) | ((SPI_WRITE_REG & 0xf0) >> 4);
	uint8_t rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	tx = value;
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	address = 0x0a; // Address for triggering
	value = 0x01; // Send 1 to trigger, then 0 to untrigger

	tx = ((address & 0x0f) << 4) | ((SPI_WRITE_REG & 0xf0) >> 4);
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	tx = value;
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	tx = ((address & 0x0f) << 4) | ((SPI_WRITE_REG & 0xf0) >> 4);
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	tx = 0x00;
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	address = 0x0b;
	tx = ((address & 0x0f) << 4) | ((SPI_WRITE_REG & 0xf0) >> 4);
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	tx = 0x01;
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	uint8_t * dataTX;
	uint8_t * dataRX;

	size_t size = (size_t) howmany;

	dataTX = malloc(size);
	dataRX = malloc(size);

	int i;
	for (i = 0; i < size; i++) 
		dataTX[i] = 0x99;

	spiTransfer(fd, dataTX, dataRX, size);

	tx = 0x99;
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	tx = ((address & 0x0f) << 4) | ((SPI_WRITE_REG & 0xf0) >> 4);
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	tx = 0x00;
	rx = 0x00;

	spiTransfer(fd, &tx, &rx, sizeof(tx));

	hexDump(dataRX, size);
	
}

void hexDump(const void * src, size_t length) {
	const unsigned char * address = src;

	printf("Data received:\n");
	
	while (length-- > 0) {
		printf("%02X ", *address++);
	}
	
	printf("\n");
}


