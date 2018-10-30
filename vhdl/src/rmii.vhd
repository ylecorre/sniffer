--------------------------------------------------------------------------------
--
-- rmii
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:40:53 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--  Top-level for RMII interface
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rmii is
	port(
		clk           : in  std_logic;                          -- 100 MHz clock
		rn            : out std_logic;                          -- rmii reset (active low)
		txd           : out std_logic_vector(1 downto 0);       -- data to be sent (2 bits @ 50 MHz)
		txen          : out std_logic;                          -- asserted when txd is ready
		rxdIn         : in  std_logic_vector(1 downto 0);       -- received data from pad (2 bits @ 50 MHz)
		rxdEn         : out std_logic;                          -- rxd pads enable
		crsIn         : in  std_logic;                          -- data valid signal
		refClk        : out std_logic;                          -- front-end clock @ 50 MHz
		rxData        : out std_logic_vector(7 downto 0);       -- byte received from front-end
		rxDataValid   : out std_logic;                          -- asserted when rxData is valid
		frameStart    : out std_logic;                          -- asserted when frame starts
		frameEnd      : out std_logic;                          -- asserted when frame ends
		txStart       : in  std_logic;                          -- asserted to start transmitting a new frame
		txByte        : in  std_logic_vector(7 downto 0);       -- byte to be transmitted
    txByteReq     : out std_logic;                          -- asserted to request a new byte to transmit
		txByteRdy     : in  std_logic;                          -- asserted when new byte to transmit is available
    txDone        : in  std_logic                           -- asserted when frame has been transfered to RMII
	);
end rmii;


architecture rtl of rmii is

	signal refClk_wire : std_logic;

begin

	refClk <= refClk_wire;

	i_rmiiClk : entity work.rmiiClk
		port map(
			clk    => clk,
			refClk => refClk_wire
		);

	i_rmiiRx : entity work.rmiiRx
		port map(
			clk         => clk,
			rn          => rn,
			rxdIn       => rxdIn,
			rxdEn       => rxdEn,
			crsIn       => crsIn,
			refClk      => refClk_wire,
			rxData      => rxData,
			rxDataValid => rxDataValid,
			frameStart  => frameStart,
			frameEnd    => frameEnd
		);

	i_rmiiTx : entity work.rmiiTx
		port map(
			clk           => clk,
			refClk        => refClk_wire,
			txd           => txd,
			txen          => txen,
			txStart       => txStart,
			txByte        => txByte,
			txByteReq     => txByteReq,
			txByteRdy     => txByteRdy,
			txDone        => txDone
		);

end rtl;
