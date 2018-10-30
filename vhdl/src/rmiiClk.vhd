--------------------------------------------------------------------------------
--
-- rmiiClk
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:34:35 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--  This block generates the RMII reference clock.
--  The reference clock frequency is 50 MHz.
--  See LAN8720A datasheet
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rmiiClk is
	port(
		clk    : in  std_logic;  -- 100 MHz system clock, rising-edge active
		refClk : out std_logic   --  50 MHz RMII clock
	);
end rmiiClk;


architecture rtl of rmiiClk is

	signal refClkReg : std_logic := '0';

begin

	refClk <= refClkReg;

	-- refClk generation (simply divide clk by 2)
	p_refClk : process(clk)
	begin
		if rising_edge(clk) then
		  refClkReg <= not refClkReg;
		end if;
	end process;

end rtl;
