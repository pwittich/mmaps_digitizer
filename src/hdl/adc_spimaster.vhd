library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.numeric_std.all;
library work;

entity adc_spimaster is

	port (
		sys_clk : in std_logic;
		reset_n : in std_logic;
		
		adc_sclk : out std_logic;
		adc_sdio : inout std_logic;
		adc_cs : out std_logic_vector(0 downto 0);
		
		adc_flag : in std_logic;
		adc_mode : in std_logic_vector(7 downto 0);
		adc_ready : out std_logic
	);
end adc_spimaster;

architecture a of adc_spimaster is

	type write_states_T is (IDLE, RUNNING, STOPPING);
	signal state : write_states_T;
	
	type setup_states_T is (READY, SET1, SET2);
	signal setup_state : setup_states_T;

	signal rw : std_logic;
	signal busy : std_logic;
	signal adc_tx_addr : std_logic_vector(7 downto 0);
	signal adc_tx_data : std_logic_vector(7 downto 0);
	signal adc_rx_data : std_logic_vector(7 downto 0);
	
	signal adc_spienable : std_logic;
	signal spi_delay : INTEGER range 0 to 10000;

begin

	rw <= not(adc_tx_addr(7));

	spi_3_wire_master_1: entity work.spi_3_wire_master
	generic map (
		slaves    => 1,
		cmd_width => 8,
		d_width   => 8,
		clk_div   => 25)
	port map (
		clock   => sys_clk,
		reset_n => reset_n,
		enable  => adc_spienable,
		cpol    => '0',
		cpha    => '0',
		rw      => rw,
		tx_cmd  => adc_tx_addr,
		tx_data => adc_tx_data,
		sclk    => adc_sclk,
		ss_n    => adc_cs,
		sdio    => adc_sdio,
		busy    => busy,
		rx_data => adc_rx_data);
		
	init_adc: process (sys_clk, reset_n)
	begin
		if reset_n = '0' then
			state <= IDLE;
			setup_state <= READY;
			adc_ready <= '1';
			
			adc_tx_addr <= X"00";
			adc_tx_data <= X"00";
			spi_delay <= 0;
			
			adc_spienable <= '0';
		elsif rising_edge (sys_clk) then
			case state is
				when IDLE =>
					case setup_state is
						when READY =>
							adc_ready <= '1';
							if adc_flag = '1' then
								adc_ready <= '0';
								state <= RUNNING;
								adc_tx_addr <= X"00";
								adc_tx_data <= X"00";
								setup_state <= SET1;
							end if;
							
						when SET1 =>
							state <= RUNNING;
							adc_tx_addr <= X"01";
							if adc_mode = X"00" then
								adc_tx_data <= X"09";
							elsif adc_mode = X"01" then
								adc_tx_data <= X"79";
							else
								adc_tx_data <= adc_mode;
							end if;
							setup_state <= SET2;
						
						when SET2 =>
							setup_state <= READY;
							
					end case;
				
				when RUNNING =>
					state <= STOPPING;
					spi_delay <= 0;
					adc_spienable <= '1';
				
				when STOPPING =>
					adc_spienable <= '0';
					-- we need to delay the next write a bit
					if spi_delay > 9998 then
						state <= IDLE;
					else
						spi_delay <= spi_delay + 1;
					end if;
			end case;
		end if;
	end process;	
		
end a;

