# mmaps_digitizer
Firmware for the digitizer for MMAPS

```
Directory structure:
   .
   |-prj
   |---altera
   |---xilinx
   |-src
   |---hdl
   |---other
   |---sim
   |---zynq_spi
   |---event_display
```

Quartus II project is in prj/altera/maaps_digi.qpf.

Vivado Zynq project is in prj/xilinx/vivado/zynq_spi_emio_diff/.

Petalinux Zynq project is in prj/xilinx/petalinux/darkphoton_zynq/.

## Register Map

| Address  	| RW  	| Name  	| Bit |
|---	|---	|---	|--- |
| 0x0  	|   RW	| Bottom 8 bits of ADC_sample_num  	| 8 | 
| 0x1    | RW     | Top 8 bits of ADC_sample_num | 8 |
| 0x2  	|   RW	| Bottom 8 bits of Zynq_word_num   	| 8 | 
| 0x3  	|   RW	| Top 8 bits of Zynq_word_num  	| 8 | 
| 0x4    |   RW   | Bottom 8 bits of trigger delay offset | 8 | 
| 0x5    | RW      | Top 8 bits of trigger delay offset | 8 |
| 0x6 | RW      | ADC mode | 8 |
| 0x7 | RW | Sub-module test | 8 |
| 0x8 | RW | Send ADC {16/top 8/bottom 8} bits | 8 |
| 0x9 | RW | Unused | 8 |
| 0xa | RW | Fake trigger | 8 |
| 0xb | RW | Read request (for single_channel test) | 8 |
| 0xc | RW | Zynq-mandated reset | 8 |
