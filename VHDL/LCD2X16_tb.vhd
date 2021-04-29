----------------------------------------------------------------------------------------
-- University: Universidad Pedagógica y Tecnológica de Colombia
-- Author: Edwar Javier Patiño Núñez
--
-- Create Date: 16/05/2020
-- Project Name: LCD2X16_tb
----------------------------------------------------------------------------------------
library ieee;
library work;
use work.pkg.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LCD2X16_tb is
end entity;

architecture bevah of LCD2X16_tb is
	signal RW		:std_logic:='0';
	signal RS		:std_logic:='0';
	signal E			:std_logic:='0';
	signal DATA		:std_logic_vector(7 downto 0):=(others=>'0');
	signal screen	:scrn(0 to 1, 0 to 15):=(others=>(others=>(others=>'0')));
	
	type mode is (Initializing, Writing, Instruction);
	signal s_mode :mode := Initializing;
	
	type msg is array (natural range <>) of std_logic_vector(7 downto 0);
	signal message_1 :msg(0 to 13):=(	x"4C",
													x"43",
													x"44",
													x"20",
													x"53",
													x"49",
													x"4D",
													x"55",
													x"4C",
													x"41",
													x"54",
													x"49",
													x"4F",
													x"4E");
	
	signal message_2 :msg(0 to 13):=(	x"47",
													x"4F",
													x"4F",
													x"44",
													x"20",
													x"20",
													x"4C",
													x"55",
													x"43",
													x"4B",
													x"20",
													x"20",
													x"20",
													x"20");
begin
	---------------------------------------------------------
	-- Instantiate and map the design under test 
	---------------------------------------------------------	
	DUT: entity work.LCD2X16
		port map(
			RW			=> RW,
			RS			=> RS,
			E			=> E,
		   DATA		=> DATA,
			
			screen	=> screen
		);
		
	process
	begin
		---------------------------------------------------------
		-- Initializing
		---------------------------------------------------------
		wait for 20 ms;
		
		DATA <= "0011XXXX";
		E <= '1';
		wait for 1 us;
		E <= '0';
		wait for 5 ms;
		
		E <= '1';
		wait for 1 us;
		E <= '0';
		wait for 120 us;
		
		E <= '1';
		wait for 1 us;
		E <= '0';
		wait for 50 us;
		
		DATA <= "00111XXX";		-- Function set
		E <= '1';
		wait for 1 us;
		E <= '0';
		wait for 50 us;
		
		DATA <= "00001100";		-- Display on
		E <= '1';
		wait for 1 us;
		E <= '0';
		wait for 50 us;
		
		DATA <= "00000001";		-- Display clear
		E <= '1';
		wait for 1 us;
		E <= '0';
		wait for 2 ms;
		
		DATA <= "00000110";		-- Entry mode set
		E <= '1';
		wait for 1 us;
		E <= '0';
		wait for 50 us;
		
		---------------------------------------------------------
		-- Writing data
		---------------------------------------------------------
		s_mode <= Instruction;
		
		DATA <= "10000001";		-- Change cursor position
		E <= '1';
		wait for 1 us;
		E <= '0';
		wait for 50 us;
		
		RS <= '1';
		s_mode <= Writing;
		
		for i in 0 to 13 loop
			DATA <= message_1(i);
			E <= '1';
			wait for 1 us;
			E <= '0';
			wait for 50 us;
		end loop;
		
		RS <= '0';
		s_mode <= Instruction;
		
		DATA <= "11000011";		-- Change cursor position
		E <= '1';
		wait for 1 us;
		E <= '0';
		wait for 50 us;
		
		RS <= '1';
		s_mode <= Writing;
		
		for i in 0 to 9 loop
			DATA <= message_2(i);
			E <= '1';
			wait for 1 us;
			E <= '0';
			wait for 50 us;
		end loop;
	end process;
end architecture;