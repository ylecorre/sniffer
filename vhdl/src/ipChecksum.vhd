--------------------------------------------------------------------------------
--
-- ipChecksum
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:23:02 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Implements IPv4 checksum calculation.
--   Mode of operation:
--    1) assert clr and enable right before the first input byte is available
--    2) assert enable when an input byte is available
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ipChecksum is
	port(
		clk      : in  std_logic;                       -- clock, rising-edge active
		clr      : in  std_logic;                       -- asserted to clear the checksum state
		enable   : in  std_logic;                       -- asserted when a new data input is to be used
		din      : in  std_logic_vector(7 downto 0);    -- data input
		checksum : out std_logic_vector(15 downto 0)    -- checksum
	);
end ipChecksum;


architecture rtl of ipChecksum is

	signal checksumReg : unsigned(15 downto 0) := to_unsigned(0, 16);
	signal msbSelReg   : std_logic := '0';

begin

	checksum <= not std_logic_vector(checksumReg);

	p_main : process(clk)
		variable ipChecksumV : unsigned(16 downto 0);
		variable operand     : unsigned(16 downto 0);
	begin
		if rising_edge(clk) then
			if enable = '1' then
				if clr = '1' then
					checksumReg <= to_unsigned(0, checksumReg'length);
					msbSelReg <= '1';
				else
					if msbSelReg = '1' then
						operand := shift_left(resize(unsigned(din), 17), 8);
					else
						operand := resize(unsigned(din), 17);
					end if;
					ipChecksumV := resize(checkSumReg, 17) + operand;
					ipChecksumV := resize(ipChecksumV(15 downto 0), 17) + resize('0' & ipChecksumV(16), 17);
					checksumReg <= ipChecksumV(15 downto 0);
					msbSelReg <= not msbSelReg;
				end if;
			end if;
		end if;
	end process;

end rtl;
