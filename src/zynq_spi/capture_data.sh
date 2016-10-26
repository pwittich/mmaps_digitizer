#!/bin/sh

# ./send_trigger.sh # Send trigger and readout request

filename=$(./millitime)

./spidev_test -D /dev/spidev32766.0 -s 10000000 # capture 4096 samples

#mv file.txt raw_data/data_chns_0123.dat

cat file.txt > raw_data/test_run/test_subrun/$filename

./spidev_test -D /dev/spidev32766.0 -s 10000000 # capture 4096 samples

#mv file.txt raw_data/data_chns_4567.dat

cat file.txt >> raw_data/test_run/test_subrun/$filename

./spidev_test -D /dev/spidev32766.0 -s 10000000 # capture 4096 samples

#mv file.txt raw_data/data_chns_89ab.dat
cat file.txt >> raw_data/test_run/test_subrun/$filename

./spidev_test -D /dev/spidev32766.0 -s 10000000 # capture 4096 samples

#mv file.txt raw_data/data_chns_cdef.dat
cat file.txt >> raw_data/test_run/test_subrun/$filename

