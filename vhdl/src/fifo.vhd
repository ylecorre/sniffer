--------------------------------------------------------------------------------
--
-- fifo
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:19:12 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--  Fully synchronous fifo with separated write and read ports. The read and
--  write parts use the same clock (and are in the same clock domain).
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types_pkg.all;


entity fifo is
	generic(
		ADDR_WIDTH : natural := 4
	);
	port(
		clk   : in  std_logic;                       -- clock
		din   : in  std_logic_vector(7 downto 0);    -- input data
		dout  : out std_logic_vector(7 downto 0);    -- output data
		wr    : in  std_logic;                       -- asserted to write din in fifo
		rd    : in  std_logic;                       -- asserted to read dout from fifo
		full  : out std_logic;                       -- asserted when fifo is full
		empty : out std_logic                        -- asserted when fifo is empty
	);
end fifo;


architecture rtl of fifo is

	signal rdAddrReg    : unsigned(ADDR_WIDTH downto 0) := to_unsigned(0, ADDR_WIDTH + 1);
	signal wrAddrReg    : unsigned(ADDR_WIDTH downto 0) := to_unsigned(0, ADDR_WIDTH + 1);
	signal doutReg      : std_logic_vector(7 downto 0) := x"00";
	signal fullReg      : std_logic := '0';
	signal emptyReg     : std_logic := '1';

	signal rdAddrNext   : unsigned(ADDR_WIDTH downto 0);
	signal wrAddrNext   : unsigned(ADDR_WIDTH downto 0);

begin

	full <= fullReg;
	empty <= emptyReg;
	dout <= doutReg;

	wrAddrNext <= wrAddrReg + 1;
	rdAddrNext <= rdAddrReg + 1;

	p_fifo : process(clk)
		variable fifoMem : byteVector(2**ADDR_WIDTH - 1 downto 0);
	begin
		if rising_edge(clk) then
			-- write logic
			if wr =  '1' and fullReg = '0' then
				fifoMem(to_integer(wrAddrReg)) := din;
				wrAddrReg <= wrAddrNext;
				emptyReg <= '0';
				if wrAddrNext(ADDR_WIDTH - 1 downto 0) = rdAddrReg(ADDR_WIDTH - 1 downto 0) and wrAddrNext(ADDR_WIDTH) /= rdAddrReg(ADDR_WIDTH) then
					fullReg <= '1';
				end if;
			end if;
			-- read logic
			if rd = '1' and emptyReg = '0' then
				doutReg <= fifoMem(to_integer(rdAddrReg));
				rdAddrReg <= rdAddrNext;
				fullReg <= '0';
				if wrAddrReg(ADDR_WIDTH - 1 downto 0) = rdAddrNext(ADDR_WIDTH - 1 downto 0) and wrAddrReg(ADDR_WIDTH) = rdAddrNext(ADDR_WIDTH) then
					emptyReg <= '1';
				end if;
			end if;
		end if;
	end process;

end rtl;
