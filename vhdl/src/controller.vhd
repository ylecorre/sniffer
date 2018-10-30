--------------------------------------------------------------------------------
--
-- controller
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:06:26 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--
--  The controller block parses incoming bytes and generate stream control signals
--  accordingly. It supports only one command currently. This command is only 1
--  byte which is directly mapped as follow:
--   byte[7]: enable ('1')/disable ('0') the stream generation
--   byte[6:0] : used as a parameter by the stream block to control stream throughput
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity controller is
	port(
		clk          : in  std_logic;                        -- input clock, rising-edge active
		fifoData     : in  std_logic_vector(7 downto 0);     -- input from parser
		fifoEmpty    : in  std_logic;                        -- asserted when no more data input is available
		fifoRd       : out std_logic;                        -- asserted to request for next data input
		streamEnable : out std_logic;                        -- asserted to enable stream generator
		streamFreq   : out std_logic_vector(6 downto 0)      -- stream generator frequency parameter
	);
end controller;


architecture rtl of controller is

	type stateType is (S_IDLE, S_GET_DATA_DELAY, S_GET_DATA);

	signal stateReg        : stateType := S_IDLE;
	signal fifoRdReg       : std_logic := '0';
	signal streamEnableReg : std_logic := '0';
	signal streamFreqReg   : std_logic_vector(6 downto 0) := "0000000";

begin

	fifoRd <= fifoRdReg;
	streamEnable <= streamEnableReg;
	streamFreq <= streamFreqReg;

	p_main : process(clk)
	begin
		if rising_edge(clk) then

			-- default
			fifoRdReg <= '0';

			-- state decoding
			case stateReg is

				when S_IDLE =>
					if fifoEmpty = '0' then
						fifoRdReg <= '1';
						stateReg <= S_GET_DATA_DELAY;
					end if;

				when S_GET_DATA_DELAY =>
					stateReg <= S_GET_DATA;
	
				when S_GET_DATA =>
					streamEnableReg <= fifoData(7);
					streamFreqReg <= fifoData(6 downto 0);
					stateReg <= S_IDLE;

			end case;
		end if;
	end process;

end rtl;
