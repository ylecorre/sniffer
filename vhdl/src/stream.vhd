--------------------------------------------------------------------------------
--
-- stream
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 10:40:49 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Generate a byte stream of value (simple up-counter). Will reset when
--   not enabled so that it always starts from 0.
--   The freq parameter is used as a clock divider parameter: byteRdy is asserted
--   every (freq) clock cycles of clk. Value 0 for freq is not valid (no error
--   detection!)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity stream is
	port(
		clk     : in  std_logic;                        -- clock, rising-edge active
		enable  : in  std_logic;                        -- asserted to enable stream generator. Stream is reset is de-asserted
		freq    : in  std_logic_vector(6 downto 0);     -- stream frequency parameter
		byte    : out std_logic_vector(7 downto 0);     -- data output
		byteRdy : out std_logic                         -- asserted when byte is valid
	);
end stream;


architecture rtl of stream is

	signal freqCounterReg : unsigned(6 downto 0) := to_unsigned(0, 7);
	signal counterReg     : unsigned(7 downto 0) := to_unsigned(0, 8);
	signal byteRdyReg     : std_logic := '0';

begin

	byte <= std_logic_vector(counterReg);
	byteRdy <= byteRdyReg;

	p_counter : process(clk)
	begin
		if rising_edge(clk) then
			if enable = '0' then
				freqCounterReg <= to_unsigned(0, freqCounterReg'length);
				counterReg <= to_unsigned(0, counterReg'length);
			else
				freqCounterReg <= freqCounterReg + 1;
				if freqCounterReg = unsigned(freq) then
					counterReg <= counterReg + 1;
					freqCounterReg <= to_unsigned(0, freqCounterReg'length);
					byteRdyReg <= '1';
				else
					byteRdyReg <= '0';
				end if;
			end if;
		end if;
	end process;	

end rtl;
