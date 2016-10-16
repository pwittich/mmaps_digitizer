#!/bin/sh

./send_trigger.sh # Send trigger and readout request

./spidev_test -D /dev/spidev32766.0 -s 10000000 # capture 1024 samples
