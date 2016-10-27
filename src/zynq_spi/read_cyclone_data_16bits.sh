#!/bin/sh

# Tell cyclone to send all 16 bits

./zynq_cyclone_comm_tool -W "\x08" -V "\x02"

# Get current time with millisecond resolution

filename=$(./millitime)

# Send SPI request to read data from all channels (all 16 bits)

./spi_receive_data_16bits -D /dev/spidev32766.0 -s 10000000 # capture 32768 samples

# Name new data with timestamp

cat file.txt > raw_data/test_run/test_subrun/$filename
