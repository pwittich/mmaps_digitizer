#!/bin/sh

# Tell cyclone to send only top 8 bits

./zynq_cyclone_comm_tool -W "\x08" -V "\x00"

for n in $(seq 1 100)
do
	./spi_receive_data_8bits -D /dev/spidev32766.0 -s 10000000 # Capture 16384 samples
done

