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
```

Quartus II project is in prj/altera/maaps_digi.qpf.

## Register Map

| Address  	| RW  	| Name  	| Bit |
|---	|---	|---	|--- |
| 0x0  	|   RW	| Test  	| 16 | 
| 0x1    | RW     | Status Register | 16 |
| 0x10  	|   RW	| How Many   	| 16 | 
| 0x11  	|   RW	| Look Back  	| 16 | 
| 0x20    |   RW   | Trigger Mask | 16 | 
| 0x21    | R      | Triggered | 16 |
| 0x30+n | R      | Trigger Counter, n=0..15 | 16 |
