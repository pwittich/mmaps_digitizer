# -*-tcl-*-
transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl/spi_slave.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl/spi_master.v}

vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl/spi_defines.v}

vlog -sv -work work +incdir+/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl/spi_demo_sm.sv}

vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v3/mmaps_digitizer/src/hdl/spi_sm.v}


vsim -L altera_mf_ver -L altera_mf rtl_work.spi_demo_sm

radix -hexadecimal

add wave -noupdate /spi_demo_sm/sysclk
add wave -noupdate /spi_demo_sm/rst
add wave -noupdate /spi_demo_sm/MISO
add wave -noupdate /spi_demo_sm/MOSI
add wave -noupdate -radix hexadecimal /spi_demo_sm/registers
add wave -noupdate -radix hexadecimal /spi_demo_sm/master_data_i
add wave -noupdate -radix hexadecimal /spi_demo_sm/master_data_o
add wave -noupdate -radix hexadecimal /spi_demo_sm/s
add wave -noupdate -radix hexadecimal /spi_demo_sm/s_m
add wave -noupdate /spi_demo_sm/SCLK
add wave -noupdate /spi_demo_sm/busy
add wave -noupdate /spi_demo_sm/start
add wave -noupdate /spi_demo_sm/new_data
add wave -noupdate /spi_demo_sm/sel
add wave -noupdate /spi_demo_sm/SPI_done
add wave -noupdate /spi_demo_sm/rd_select
add wave -noupdate /spi_demo_sm/wr_select
add wave -noupdate /spi_demo_sm/fifo_select
add wave -noupdate /spi_demo_sm/latch_cmd
add wave -noupdate -radix hexadecimal /spi_demo_sm/SPI_tx_reg
add wave -noupdate -radix hexadecimal /spi_demo_sm/SPI_rx_reg
add wave -noupdate -radix hexadecimal /spi_demo_sm/addr
add wave -noupdate -radix hexadecimal /spi_demo_sm/cmd

## SM
add wave -noupdate -divider -height 24 "State Machine"
add wave 	       sim:/spi_demo_sm/sm/fifo_select
add wave 	       sim:/spi_demo_sm/sm/rd_select
add wave 	       sim:/spi_demo_sm/sm/wr_select
add wave 	       sim:/spi_demo_sm/sm/latch_cmd
add wave -radix hexadecimal sim:/spi_demo_sm/sm/CMD
add wave 	       sim:/spi_demo_sm/sm/DONE
add wave 	       sim:/spi_demo_sm/sm/FIFO_PK_SZ
#add wave 	       sim:/spi_demo_sm/sm/clk
#add wave 	       sim:/spi_demo_sm/sm/rst
add wave 	       sim:/spi_demo_sm/sm/state
add wave 	       sim:/spi_demo_sm/sm/nextstate
add wave 	       sim:/spi_demo_sm/sm/FIFO_CNT
add wave 	       sim:/spi_demo_sm/sm/next_FIFO_CNT
add wave -radix ascii sim:/spi_demo_sm/sm/statename


# master
add wave -noupdate -divider -height 24 "Master"
add wave -position end  sim:/spi_demo_sm/my_spi_master/miso
add wave -position end  sim:/spi_demo_sm/my_spi_master/mosi
add wave -position end  sim:/spi_demo_sm/my_spi_master/sck
add wave -position end  sim:/spi_demo_sm/my_spi_master/start
add wave -position end  sim:/spi_demo_sm/my_spi_master/data_in
add wave -position end  sim:/spi_demo_sm/my_spi_master/data_out
add wave -position end  sim:/spi_demo_sm/my_spi_master/busy
add wave -position end  sim:/spi_demo_sm/my_spi_master/new_data
add wave -position end  sim:/spi_demo_sm/my_spi_master/state_d
add wave -position end  sim:/spi_demo_sm/my_spi_master/state_q
add wave -position end  sim:/spi_demo_sm/my_spi_master/data_d
add wave -position end  sim:/spi_demo_sm/my_spi_master/data_q
add wave -position end  sim:/spi_demo_sm/my_spi_master/sck_d
add wave -position end  sim:/spi_demo_sm/my_spi_master/sck_q
add wave -position end  sim:/spi_demo_sm/my_spi_master/mosi_d
add wave -position end  sim:/spi_demo_sm/my_spi_master/mosi_q
add wave -position end  sim:/spi_demo_sm/my_spi_master/ctr_d
add wave -position end  sim:/spi_demo_sm/my_spi_master/ctr_q
add wave -position end  sim:/spi_demo_sm/my_spi_master/new_data_d
add wave -position end  sim:/spi_demo_sm/my_spi_master/new_data_q
add wave -position end  sim:/spi_demo_sm/my_spi_master/data_out_d
add wave -position end  sim:/spi_demo_sm/my_spi_master/data_out_q

## Slave
add wave -noupdate -divider -height 24 "Slave"
add wave 	       sim:/spi_demo_sm/slave/ss
add wave 	       sim:/spi_demo_sm/slave/mosi
add wave 	       sim:/spi_demo_sm/slave/miso
add wave 	       sim:/spi_demo_sm/slave/sck
add wave 	       sim:/spi_demo_sm/slave/done
add wave 	       sim:/spi_demo_sm/slave/din
add wave 	       sim:/spi_demo_sm/slave/dout
add wave 	       sim:/spi_demo_sm/slave/mosi_d
add wave 	       sim:/spi_demo_sm/slave/mosi_q
add wave 	       sim:/spi_demo_sm/slave/ss_d
add wave 	       sim:/spi_demo_sm/slave/ss_q
add wave 	       sim:/spi_demo_sm/slave/sck_d
add wave 	       sim:/spi_demo_sm/slave/sck_q
add wave 	       sim:/spi_demo_sm/slave/sck_old_d
add wave 	       sim:/spi_demo_sm/slave/sck_old_q
add wave 	       sim:/spi_demo_sm/slave/data_d
add wave 	       sim:/spi_demo_sm/slave/data_q
add wave 	       sim:/spi_demo_sm/slave/done_d
add wave 	       sim:/spi_demo_sm/slave/done_q
add wave 	       sim:/spi_demo_sm/slave/bit_ct_d
add wave 	       sim:/spi_demo_sm/slave/bit_ct_q
add wave 	       sim:/spi_demo_sm/slave/dout_d
add wave 	       sim:/spi_demo_sm/slave/dout_q
add wave 	       sim:/spi_demo_sm/slave/miso_d
add wave 	       sim:/spi_demo_sm/slave/miso_q

configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left

update
WaveRestoreZoom {0 ns} {4000 ns}



run 4000