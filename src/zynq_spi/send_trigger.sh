#!/bin/sh

./zynq_cyclone_comm_tool -W "\x0a" -V "\x01" # Send 1 to register 10, trigger
./zynq_cyclone_comm_tool -W "\x0a" -V "\x00" # Untrigger
