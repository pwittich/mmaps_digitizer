
## Copyright (C) 1991-2012 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.



##
## DEVICE  "EP3C25F324C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {sysclk} -period 20.000 [get_ports {CK50}]
create_clock -name {adcclk1} -period 20.000 [get_ports {adcclk1_p}]
create_clock -name {adcclk2} -period 20.000 [get_ports {adcclk2_p}]
create_clock -name {adcfastclk} -period 3.333  [get_ports {adcfastclk_p}]
create_clock -name {adcframe} -period 20.000 [get_ports {adcframe_p}]
create_clock -name {spi_clk} -period 187.5  [get_ports {spi_sclk}]
create_clock -name {adc_sclk} -period 20.000 [get_ports {adc_sclk1}]


set_false_path -to [get_ports {adc_sclk1}]
set_false_path -to [get_ports {adcclk1_p}]
set_false_path -to [get_ports {adcclk2_p}]
set_false_path -to [get_ports {adcclk1_p(n)}]
set_false_path -to [get_ports {adcclk2_p(n)}]
set_false_path -to [get_ports {L0}]
set_false_path -to [get_ports {L1}]



#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

create_clock -name {adcfastclk_ext} -period 3.333 -waveform { 0.833 2.5 }
create_clock -name {spi_clk_ext} -period 187.5

set_clock_groups -asynchronous -group {sysclk } \
	-group { spi_clk spi_clk_ext } \
	-group { adcfastclk adcfastclk_ext adcframe } \
	-group { adcclk1 adcclk2 } \
	-group { adc_sclk }

#set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk1}]  0.040  
#set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk1}]  0.040  
#set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk1}]  0.040  
#set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk1}]  0.040  
#set_clock_uncertainty -rise_from [get_clocks {clk1}] -rise_to [get_clocks {clk1}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clk1}] -fall_to [get_clocks {clk1}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clk1}] -rise_to [get_clocks {clk1}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clk1}] -fall_to [get_clocks {clk1}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clk2}] -rise_to [get_clocks {clk1}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clk2}] -fall_to [get_clocks {clk1}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clk2}] -rise_to [get_clocks {clk1}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clk2}] -fall_to [get_clocks {clk1}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************


set_input_delay -clock adcfastclk_ext -max 0.0 [get_ports {adcdata_p[*]}]
set_input_delay -clock adcfastclk_ext -min 0.0 [get_ports {adcdata_p[*]}]
set_input_delay -clock adcfastclk_ext -max 0.0 -clock_fall [get_ports {adcdata_p[*]}] -add_delay
set_input_delay -clock adcfastclk_ext -min 0.0 -clock_fall [get_ports {adcdata_p[*]}] -add_delay

set_input_delay -clock spi_clk_ext -max 0.0 [get_ports {spi_data_in}]
set_input_delay -clock spi_clk_ext -min 0.0 [get_ports {spi_data_in}]
set_input_delay -clock spi_clk_ext -max 0.0 [get_ports {spi_cs}]
set_input_delay -clock spi_clk_ext -min 0.0 [get_ports {spi_cs}]
set_output_delay -clock spi_clk_ext -max 0.0 [get_ports {spi_data_out}]
set_output_delay -clock spi_clk_ext -min 0.0 [get_ports {spi_data_out}]

set_output_delay -clock adc_sclk -max 0.0 [get_ports {adc_sdio1}]
set_output_delay -clock adc_sclk -min 0.0 [get_ports {adc_sdio1}]
set_output_delay -clock adc_sclk -max 0.0 [get_ports {adc_ncs1}]
set_output_delay -clock adc_sclk -min 0.0 [get_ports {adc_ncs1}]



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

