transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/SM_chro.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/SM2.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/single_channel.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/ringbuffer.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/enc.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/digi_many.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/demux.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/bc_counter.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/addr_cntrl.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/maaps_daq_toplevel.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/prj/altera {/home/wittich/maaps_daq/v2/mmaps_digitizer/prj/altera/fifo.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/lvds_transmitter.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/prj/altera {/home/wittich/maaps_daq/v2/mmaps_digitizer/prj/altera/lvds_tx.v}
vlog -vlog01compat -work work +incdir+/home/wittich/maaps_daq/v2/mmaps_digitizer/prj/altera/db {/home/wittich/maaps_daq/v2/mmaps_digitizer/prj/altera/db/lvds_tx_lvds_tx.v}
vcom -2008 -work work {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/spi_3_wire_master.vhd}
vcom -2008 -work work {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/lvdsreceiver.vhd}
vcom -2008 -work work {/home/wittich/maaps_daq/v2/mmaps_digitizer/src/hdl/adc_spimaster.vhd}

# need to have altera_mf_ver before altera_mf 
vsim -L altera_mf_ver -L altera_mf rtl_work.maaps_daq_toplevel
# vsim -L altera_mf_ver -L altera_mf -do maaps_digi_run_msim_rtl_verilog.do -l msim_transcript -i rtl_work.maaps_daq_toplevel
run 2000