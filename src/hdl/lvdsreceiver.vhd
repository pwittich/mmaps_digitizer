
-- Copyright (C) 1991-2009 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II"
-- VERSION		"Version 9.1 Build 222 10/21/2009 SJ Full Version"
-- CREATED		"Mon Dec 03 14:45:52 2012"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

library altera;
use altera.altera_primitives_components.all;

LIBRARY lpm;
USE lpm.lpm_components.all;

LIBRARY work;

ENTITY lvdsreceiver IS 
  PORT
    (
      FASTCLK :  IN  STD_LOGIC;
      FRAME :  IN  STD_LOGIC;
      DATA :  IN  STD_LOGIC_VECTOR(0 downto 0);
      RESET_n : IN STD_LOGIC;
      sysclk : in std_logic;
      CBDATA : OUT STD_LOGIC_VECTOR(11 downto 0);
--      CBADDRESS : out std_logic_vector(7 downto 0);
      WENABLE : out std_logic
      );
END lvdsreceiver;

ARCHITECTURE bdf_type OF lvdsreceiver IS 

  signal doh : std_logic_vector (0 downto 0); 
  signal dol : std_logic_vector (0 downto 0);
  signal lvds_sr : std_logic_vector (11 downto 0);
  signal LATCHFRAME : std_logic;
  signal LATCHFRAME1 : std_logic;
  signal lvds_rx : std_logic_vector (11 downto 0);
  signal address : std_logic_vector (7 downto 0);
  type sm_type is (Initialize, Wait4SyncHigh,Latchdata, Wait4Data);
  signal sm: sm_type;

BEGIN 


  altddio_in_component : altddio_in
    GENERIC MAP (
      intended_device_family => "Cyclone III",
      invert_input_clocks => "OFF",
      lpm_type => "altddio_in",
      power_up_high => "OFF",
      width => 1
      )
    PORT MAP (
      datain => DATA,
      inclock => FASTCLK,
      dataout_h => doh,
      dataout_l => dol
      );

  PROCESS (fastclk, RESET_n)

  BEGIN
    IF RESET_n = '0' THEN
      lvds_rx <= (others => '0');
      address <= (others => '0');
      sm <= Initialize;
      wenable <= '0';
    else
      IF falling_edge(fastclk) THEN
        
        lvds_sr <= lvds_sr(9 downto 0) & dol & doh;

        case sm is
          when Initialize =>
            wenable <= '0';
            lvds_rx<=(others=>'0');

            if (FRAME = '1' ) then
              sm <= Initialize;
            else
              sm <= Wait4SyncHigh;
            end if;

          when Wait4SyncHigh =>

            if (FRAME='0') then
              sm<=Wait4SyncHigh;

            else
              sm <= Wait4Data;
            end if;

          when Wait4Data =>
            address <= std_logic_vector(unsigned(address)+1);
            cbdata <= lvds_sr;
            sm<=LatchData;
          when LatchData =>
            wenable <= '1';
            sm <= Initialize;
          when others =>
            sm<=Initialize;
        end case;
      end if;     
      
    END IF;
    

    
    
  END PROCESS;


--  cbaddress<=address;




END bdf_type;

