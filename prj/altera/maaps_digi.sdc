
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
create_clock -name {adcclk1} -period 20.000 [get_ports {ADCCLK1_p}]
create_clock -name {adcclk2} -period 20.000 [get_ports {ADCCLK2_p}]
create_clock -name {adcfastclk} -period 300MHz  [get_ports {adcfastclk_p}]
create_clock -name {adcframe} -period 20.000 [get_ports {adcframe_p}]
create_clock -name {spi_clk} -period 10MHz  [get_ports {SPI_SCLK}]
create_clock -name {adc_sclk1} -period 20.000 [get_ports {ADC_SCLK1}]
create_clock -name {adc_sclk2} -period 20.000 [get_ports {ADC_SCLK2}]


set_false_path -to [get_ports {ADC_SCLK1}]
set_false_path -to [get_ports {ADC_SCLK2}]
set_false_path -to [get_ports {ADCCLK1_p}]
set_false_path -to [get_ports {ADCCLK2_p}]
#set_false_path -to [get_ports {ADCCLK1_p(n)}]
#set_false_path -to [get_ports {ADCCLK2_p(n)}]
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
#create_clock -name {spi_clk_ext} -period 187.5
create_clock -name {spi_clk_ext} -period 100.0

set_clock_groups -asynchronous -group {sysclk } \
	-group { spi_clk spi_clk_ext } \
	-group { adcfastclk adcfastclk_ext adcframe } \
	-group { adcclk1 adcclk2 } \
	-group { adc_sclk1 adc_sclk2 }

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

set_input_delay -clock spi_clk_ext -max 0.0 [get_ports {SPI_MOSI}]
set_input_delay -clock spi_clk_ext -min 0.0 [get_ports {SPI_MOSI}]
set_input_delay -clock spi_clk_ext -max 0.0 [get_ports {SPI_SS}]
set_input_delay -clock spi_clk_ext -min 0.0 [get_ports {SPI_SS}]
set_output_delay -clock spi_clk_ext -max 0.0 [get_ports {SPI_MISO}]
set_output_delay -clock spi_clk_ext -min 0.0 [get_ports {SPI_MISO}]

set_output_delay -clock adc_sclk1 -max 0.0 [get_ports {ADC_SDIO1}]
set_output_delay -clock adc_sclk1 -min 0.0 [get_ports {ADC_SDIO1}]
set_output_delay -clock adc_sclk2 -max 0.0 [get_ports {ADC_SDIO2}]
set_output_delay -clock adc_sclk2 -min 0.0 [get_ports {ADC_SDIO2}]
set_output_delay -clock adc_sclk1 -max 0.0 [get_ports {ADC_nCS1}]
set_output_delay -clock adc_sclk1 -min 0.0 [get_ports {ADC_nCS1}]
set_output_delay -clock adc_sclk2 -max 0.0 [get_ports {ADC_nCS2}]
set_output_delay -clock adc_sclk2 -min 0.0 [get_ports {ADC_nCS2}]




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

