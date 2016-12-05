#!/bin/sh

# Tell cyclone to send all 16 bits

./zynq_cyclone_comm_tool -W "\x08" -V "\x02"

for n in $(seq 1 100)
do
	./spi_receive_data_16bits -D /dev/spidev32766.0 -s 10000000 # Capture 32768 samples
done

