--------------------------------------------------------------------------------
--
-- fifoXilinx
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:21:19 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--  Xilinx fifo wrapper so that any FIFO (integrated or implemented with standard
--  cells) may be used. The read and write parts use the same clock (only one
--- clock domain)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.VCOMPONENTS.all;


entity fifoXilinx is
	generic(
		UDP_PAYLOAD_LENGTH : natural := 64
	);
	port(
		clk   : in  std_logic;                       -- clock
		din   : in  std_logic_vector(7 downto 0);    -- input data
		dout  : out std_logic_vector(7 downto 0);    -- output data
		wr    : in  std_logic;                       -- asserted to write din in fifo
		rd    : in  std_logic;                       -- asserted to read dout from fifo
		full  : out std_logic;                       -- asserted when fifo is full
		lvl   : out std_logic;                       -- asserted when fifo reach lvl
		empty : out std_logic                        -- asserted when fifo is empty
	);
end fifoXilinx;


architecture rtl of fifoXilinx is

	signal do     : std_logic_vector(31 downto 0);
	signal di     : std_logic_vector(31 downto 0);
	signal rstReg : std_logic_vector(5 downto 0) := "100000";
	signal rst    : std_logic;
	signal wren   : std_logic;
	signal rden   : std_logic;

	constant ALMOST_FULL_OFFSET : bit_vector(15 downto 0) := to_bitvector(std_logic_vector(to_unsigned(2048 - UDP_PAYLOAD_LENGTH, 16)));

begin

	dout <= do(7 downto 0);
	di <= x"00_00_00" & din;

	wren <= '0' when rst = '1' else wr;
	rden <= '0' when rst = '1' else rd;
	rst <= not rstReg(5);

	p_reset : process(clk)
	begin
		if rising_edge(clk) then
			rstReg <= rstReg(4 downto 0) & '1';
		end if;
	end process;

	i_fifo18e1 : fifo18e1
		generic map(
			ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
			DATA_WIDTH              => 9,
			DO_REG                  => 0,
			EN_SYN                  => true,
			FIRST_WORD_FALL_THROUGH => false,
			SIM_DEVICE              => "7SERIES"
		)
		port map(
			ALMOSTEMPTY     => open,
			ALMOSTFULL      => lvl,
			DO              => do,
			DOP             => open,
			EMPTY           => empty,
			FULL            => full,
			RDCOUNT         => open,
			RDERR           => open,
			WRCOUNT         => open,
			WRERR           => open,
			DI              => di,
			DIP             => "0000",
			RDCLK           => clk,
			RDEN            => rden,
			REGCE           => '1',
			RST             => rst,
			RSTREG          => '0',
			WRCLK           => clk,
			WREN            => wren
		);

end rtl;
