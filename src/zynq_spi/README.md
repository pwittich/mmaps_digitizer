Compilation and usage instructions:

1) Source settings.sh in the petalinux install folder
(this will give you the arm gcc compilers)

2) Run:
	$ arm-linux-gnueabihf-gcc -o zync_cyclone_comm_tool zynq_cyclone_comm_tool.c zynq_spi_library.c

3) Copy executable to zynq via scp

4) SSH to zynq and run $ chmod +x zynq_cyclone_comm_tool

5) Use as follows:
	$ ./zynq_cyclone_comm_tool -W "\x01" -V "\xff" // Writes ff to register 0x1
	$ ./zynq_cyclone_comm_tool -R "\x01" // Reads value of register 0x01
	$ ./zynq_cyclone_comm_tool -D "\xff" // Reads 255 values from the fifo (not entirely operational yet)
