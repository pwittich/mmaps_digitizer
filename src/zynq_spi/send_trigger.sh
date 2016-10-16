#!/bin/sh

./zynq_cyclone_comm_tool2 -W "\x0a" -V "\x01" # Send 1 to register 10, trigger
./zynq_cyclone_comm_tool2 -W "\x0a" -V "\x00" # Untrigger
./zynq_cyclone_comm_tool2 -W "\x0b" -V "\x01" # Send 1 to register 11, readout
./zynq_cyclone_comm_tool2 -W "\x0b" -V "\x00" # Unreadout
