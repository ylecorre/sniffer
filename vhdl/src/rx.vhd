--------------------------------------------------------------------------------
--
-- rx
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 10:33:26 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 16:28:25 +0200 (Wed, 28 May 2014) $
-- $Revision: 166 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Top-level of the receive part of the interface. Connects together the
--   receive FIFO, the rx controller and the RMII receive interface.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library netitf_lib;
use netitf_lib.types_pkg.all;


entity rx is
	port(
		clk           : in  std_logic;                          -- 100 MHz clock, rising-edge active
		rmiiRn        : out std_logic;                          -- \
		rmiiRxdIn     : in  std_logic_vector(1 downto 0);       -- |
		rmiiRxdEn     : out std_logic;                          -- > RMII PHY signals
		rmiiCrsIn     : in  std_logic;                          -- |
		rmiiRefClk    : in  std_logic;                          -- /
    mac           : in  byteVector(0 to 5);                 -- our own MAC address. first byte at pos. 0
    ip            : in  byteVector(0 to 3);                 -- our own IP address. first byte at pos. 0
		udpPort       : in  byteVector(0 to 1);                 -- UDP port number. LSB at pos. 0
    senderMac     : out byteVector(0 to 5);                 -- MAC address of last receive ARP request. first byte at pos. 0
    senderIp      : out byteVector(0 to 3);                 -- IP address of last receive ARP request. first byte at pos. 0
		arpReq        : out std_logic;                          -- asserted when an ARP request is received
		fifoRd        : in  std_logic;                          -- asserted to read byte from receive fifo
		fifoRdData    : out std_logic_vector(7 downto 0);       -- received data (stored in received fifo)
		fifoEmpty     : out std_logic;                          -- asserted when receive fifo is empty
		fifoFull      : out std_logic                           -- asserted when receive fifo is full
	);
end rx;


architecture rtl of rx is

	signal rmiiRxData      : std_logic_vector(7 downto 0);
	signal rmiiRxDataValid : std_logic;
	signal rmiiFrameStart  : std_logic;
	signal rmiiFrameEnd    : std_logic;
	signal fifoWrData      : std_logic_vector(7 downto 0);
	signal fifoWr          : std_logic;

begin

	i_rmiiRx : entity netitf_lib.rmiiRx
		port map(
			clk         => clk,
			rn          => rmiiRn,
			rxdIn       => rmiiRxdIn,
			rxdEn       => rmiiRxdEn,
			crsIn       => rmiiCrsIn,
			refClk      => rmiiRefClk,
			rxData      => rmiiRxData,
			rxDataValid => rmiiRxDataValid,
			frameStart  => rmiiFrameStart,
			frameEnd    => rmiiFrameEnd
		);

	i_rxCtl : entity netitf_lib.rxCtl
		port map(
			clk             => clk,
			rmiiRxData      => rmiiRxData,
			rmiiRxDataValid => rmiiRxDataValid,
			rmiiFrameStart  => rmiiFrameStart,
			rmiiFrameEnd    => rmiiFrameEnd,
			mac             => mac,
			ip              => ip,
			udpPort         => udpPort,
			senderMac       => senderMac,
			senderIp        => senderIp,
			arpReq          => arpReq,
			fifoData        => fifoWrData,
			fifoWr          => fifoWr
		);

	i_fifo : entity netitf_lib.fifoXilinx
		port map(
			clk   => clk,
			din   => fifoWrData,
			wr    => fifoWr,
			dout  => fifoRdData,
			rd    => fifoRd,
			empty => fifoEmpty,
			full  => fifoFull
		);

end rtl;
