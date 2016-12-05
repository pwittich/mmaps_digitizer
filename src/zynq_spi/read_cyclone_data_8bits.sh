#!/bin/sh

# Tell cyclone to send top 8 bits only

./zynq_cyclone_comm_tool -W "\x08" -V "\x00"

# Get current time with millisecond resolution

filename=$(./millitime)

# Send SPI request to read data from all channels (only top 8 bits)

./spi_receive_data_8bits -D /dev/spidev32766.0 -s 10000000 # capture 16384 samples

# Name new data with timestamp

cat file.txt > raw_data/test_run/test_subrun/$filename
