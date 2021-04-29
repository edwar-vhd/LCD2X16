----------------------------------------------------------------------------------------
-- University: Universidad Pedagógica y Tecnológica de Colombia
-- Author: Edwar Javier Patiño Núñez
--
-- Create Date: 13/05/2020
-- Project Name: LCD2X16
-- Description: 
-- 	This description emulates the behavior of an LCD display
----------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package pkg is
  type scrn is array (natural range <>, natural range <>) of std_logic_vector(7 downto 0);
end package;

package body pkg is
end package body;
----------------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg.all;

entity LCD2X16 is
	port(
		RW			:in std_logic;
		RS			:in std_logic;
		E			:in std_logic;
		DATA		:in std_logic_vector(7 downto 0);
		screen	:out scrn(0 to 1, 0 to 15)
	);
end entity;

architecture bevah of LCD2X16 is
	signal pos_x 		:natural := 0;
	signal pos_y 		:natural := 0;
	signal DDRAM		:scrn(0 to 1, 0 to 39):=(others=>(others=>(others=>'0')));
	
	-- Signals for FSM
	type state_type is (	idle, ins, dta, no_init, ins_init_0, ins_init_1,
								ins_init_2, inst_ctr, inactive,
								-- Instructions
								clr_disp,
								rtn_home,
								ent_mode_set,
								disp_on_off,
								shift,
								func_set,
								CGRAM_addr,
								DDRAM_addr,
								-- Evaluate instructions
								ent_mode_set_eval,
								disp_on_off_eval,
								shift_eval,
								func_set_eval,
								-- Delays
								dl_dta);
	signal curr_state, nxt_state	:state_type;
	signal strt							:std_logic:='0';
	signal clk							:std_logic:='0';
	signal ctr							:natural:=0;
	signal pwr_on						:std_logic:='0';
	signal rst							:std_logic:='1';
	signal init							:std_logic_vector(1 downto 0):=(others=>'0');
	signal IR							:std_logic_vector(7 downto 0);	-- Instruction register
	signal DR							:std_logic_vector(7 downto 0);	-- Data register
	-- Internal for instructions
	signal ID							:std_logic:='0';
	signal S								:std_logic:='0';	
	signal SC							:std_logic:='0';
	signal RL							:std_logic:='0';
	signal DL							:std_logic:='0';
	signal N								:std_logic:='0';
	signal F								:std_logic:='0';
	signal D								:std_logic:='0';
	signal C								:std_logic:='0';
	signal B								:std_logic:='0';
begin
	-- Internal reset
	rst <= '0' after 1 ns;
	-- Delay after "power on"
	process
	begin
		wait for 15 ms;
		pwr_on <= '1';
		wait;
	end process;
	---------------------------------------------------------
	-- FSM
	---------------------------------------------------------
	-- Clock
	process
	begin	
		wait for 2 us;		-- 250KHz
		clk <= not clk;
	end process;
	-- State transition logic
	process (clk, rst, pwr_on, E)
	begin
		if ((E and pwr_on) or rst) = '1' then
			curr_state <= idle;
		elsif (rising_edge(clk)) then
			curr_state <= nxt_state;
		end if;
	end process;
	-- Next state logic
	process(curr_state, ctr)
	begin
		case curr_state is
			when idle =>
				if init = "11" then
					if RS = '0' then
						nxt_state <= ins;
					else
						nxt_state <= dl_dta;
					end if;
				else
					if pwr_on = '1' then
						if (RS & RW & DATA(7 downto 4)) = "000011" then
							if init = "00" then
								nxt_state <= ins_init_0;
							elsif init = "01" then
								nxt_state <= ins_init_1;
							else
								nxt_state <= ins_init_2;
							end if;
						else
							nxt_state <= inactive;
						end if;
					else
						nxt_state <= no_init;
					end if;
				end if;
				
			when ins =>
				if  DATA = "00000001" then						-- Display clear
					if ctr >= 378 then 
						nxt_state <= clr_disp;
					else
						nxt_state <= ins;
					end if;
				elsif DATA(7 downto 1) = "0000001" then	-- Return home
					if ctr >= 378 then 
						nxt_state <= rtn_home;
					else
						nxt_state <= ins;
					end if;
				elsif DATA(7 downto 2) = "000001" then		-- Entry mode set	
					if ctr >= 7 then 
						nxt_state <= ent_mode_set;
					else
						nxt_state <= ins;
					end if;
				elsif DATA(7 downto 3) = "00001" then		-- Display on/off
					if ctr >= 7 then 
						nxt_state <= disp_on_off;
					else
						nxt_state <= ins;
					end if;
				elsif DATA(7 downto 4) = "0001" then		-- Cursor or display shift
					if ctr >= 7 then 
						nxt_state <= shift;
					else
						nxt_state <= ins;
					end if;
				elsif DATA(7 downto 5) = "001" then			-- Function set
					if ctr >= 6 then 
						nxt_state <= func_set;
					else
						nxt_state <= ins;
					end if;
				elsif DATA(7 downto 6) = "01" then			-- Set CGRAM address
					if ctr >= 7 then 
						nxt_state <= CGRAM_addr;
					else
						nxt_state <= ins;
					end if;
				elsif DATA(7) = '1' then						-- Set DDRAM address
					if ctr >= 7 then 
						nxt_state <= DDRAM_addr;
					else
						nxt_state <= ins;
					end if;
				else
					nxt_state <= inactive;
				end if;
			----------------------------------------------------------------------
			-- Instructions
			----------------------------------------------------------------------
			when clr_disp =>
				nxt_state <= inactive;
			when rtn_home =>
			when ent_mode_set =>
				nxt_state <= ent_mode_set_eval;
			when ent_mode_set_eval =>
				nxt_state <= inactive;
			when disp_on_off =>
				nxt_state <= disp_on_off_eval;
			when disp_on_off_eval =>
				nxt_state <= inactive;
			when shift =>
				nxt_state  <= shift_eval;
			when shift_eval =>
				nxt_state <= inactive;
			when func_set =>
				nxt_state <= func_set_eval;
			when func_set_eval => 
				nxt_state <= inactive;
			when CGRAM_addr =>
				nxt_state <= inactive;
			when DDRAM_addr =>
				nxt_state <= inactive;
			----------------------------------------------------------------------
			when no_init =>
			when dl_dta =>
				if ctr >= 7 then
					nxt_state <= dta;
				else
					nxt_state <= dl_dta;
				end if;
			when dta =>
				nxt_state <= inactive;
			when ins_init_0 =>
				if ctr >= 1024 then
					nxt_state <= inst_ctr;
				else
					nxt_state <= ins_init_0;
				end if;
			when ins_init_1 =>
				if ctr > 24 then
					nxt_state <= inst_ctr;
				else
					nxt_state <= ins_init_1;
				end if;
			when ins_init_2 =>
				nxt_state <= inst_ctr;
			when inst_ctr =>
				nxt_state <= inactive;
			when inactive =>
		end case;
	end process;
	-- Timer
	process(clk, strt)
	begin
		if strt = '1' then
			ctr <= 0;
		elsif (rising_edge(clk)) then
			if curr_state /= nxt_state then
				ctr <= 0;
			else
				ctr <= ctr + 1;
			end if;
		end if;
	end process;
	-- Output depends solely on the current state
	process (curr_state)
	begin
		case curr_state is
			when idle 			=>
			when ins 			=>
			when no_init		=>
			when dl_dta			=>
			when dta => 
				DDRAM(pos_y,pos_x) <= DATA;
				if ID = '1' then
					if pos_x < 39 then pos_x <= pos_x + 1; else pos_x <= 0; end if;
				else
					if pos_x > 0 then pos_x <= pos_x - 1; else pos_x <= 39; end if;
				end if;
			when ins_init_0	=> 
			when ins_init_1	=> 
			when ins_init_2	=> 
			----------------------------------------------------------------------
			-- Instructions
			----------------------------------------------------------------------								
			when clr_disp =>
				DDRAM <= (others=>(others=>(X"20")));
				pos_x <= 0;
				pos_y <= 0;
				ID <= '1';
			when rtn_home =>
				pos_x <= 0;
				pos_y <= 0;
			when ent_mode_set	=>
				S <= DATA(0);
				ID <= DATA(1);
			when ent_mode_set_eval =>
				assert S = '0' report "Function not implemented: Accompanies display shift" severity failure;
			when disp_on_off =>
				D <= DATA(2);
				C <= DATA(1);
				B <= DATA(0);
			when disp_on_off_eval =>
				assert C = '0' report "Function not implemented: Cursor on" severity warning;
				assert B = '0' report "Function not implemented: Blink of cursor position character" severity warning;
			when shift =>
				SC <= DATA(3);
				RL <= DATA(2);
				
				if SC <= '0' then
					if RL <= '1' then
						if pos_x < 39 then 
							pos_x <= pos_x + 1; 
						else
							pos_x <= 0;
							if pos_y <= 0 then pos_y <= 1; else pos_y <= 0; end if;
						end if;
					else
						if pos_x > 0 then
							pos_x <= pos_x - 1;
						else
							pos_x <= 39;
							if pos_y <= 0 then pos_y <= 1; else pos_y <= 0; end if;
						end if;
					end if;
				end if;
			when shift_eval =>
				assert SC = '0' report "Function not implemented: Display shift" severity failure;
			when func_set =>
				DL <= DATA(4);
				N <= DATA(3);
				F <= DATA(2);
			when func_set_eval =>	
				assert DL = '1' report "Function not implemented: Interface data 4bits" severity failure;
				assert N = '1' report "Function not implemented: Number of display lines 1" severity failure;
			when CGRAM_addr =>
				report "Function not implemented: Set CGRAM address" severity warning;
			when DDRAM_addr =>
				if DATA(6) <= '0' then
					pos_y <= 0;
				else
					pos_y <= 1;
				end if;
				
				pos_x <= to_integer(unsigned(DATA(5 downto 0)));
			----------------------------------------------------------------------
			when inst_ctr =>
				init <= std_logic_vector(unsigned(init) + 1);
			when inactive	=>
		end case;
	end process;
	
	-- DDRAM to screen
	process(DDRAM, D)
	begin
		for i in 0 to 1 loop
			for j in 0 to 15 loop
				if D = '1' then
					screen(i,j) <= DDRAM(i,j);
				else
					screen(i,j) <= x"2D";
				end if;
			end loop;
		end loop;
	end process;
end architecture;