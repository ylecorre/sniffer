--------------------------------------------------------------------------------
--
-- tx
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 10:56:41 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 16:28:25 +0200 (Wed, 28 May 2014) $
-- $Revision: 166 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Implements top-level of TX part. Connects together the transmit fifo,
--   the TX controller, and the RMII TX interface
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library netitf_lib;
use netitf_lib.types_pkg.all;


entity tx is
	generic(
		UDP_PAYLOAD_LENGTH : natural := 64
	);
	port(
		clk              : in  std_logic;                      -- clock, rising-edge active
    mac              : in  byteVector(0 to 5);             -- our own MAC address, 1st byte at pos. 
    ip               : in  byteVector(0 to 3);             -- our own IP address, 1st byte at pos. 0
    targetMac        : in  byteVector(0 to 5);             -- target MAC address. 1st byte at pos. 0
    targetIp         : in  byteVector(0 to 3);             -- target IP address. 1st byte at pos.0
		arpReq           : in  std_logic;                      -- asserted when requesting an ARP response
		fifoWr           : in  std_logic;                      -- asserted to write data into the transmit fifo
		fifoWrData       : in  std_logic_vector(7 downto 0);   -- data to be written in the transmit fifo
		fifoFull         : out std_logic;                      -- asserted when the transmit fifo is full
		rmiiRefClk       : in  std_logic;                      -- \
		rmiiTxd          : out std_logic_vector(1 downto 0);   -- | RMII interface to PHY
		rmiiTxen         : out std_logic                        --/
	);
end tx;


architecture rtl of tx is

	signal fifoRdData    : std_logic_vector(7 downto 0);
	signal fifoRd        : std_logic;
	signal fifoEmpty     : std_logic;
	signal rmiiTxStart   : std_logic;
	signal rmiiTxByteReq : std_logic;
	signal rmiiTxbyteRdy : std_logic;
	signal rmiiTxByte    : std_logic_vector(7 downto 0);
	signal rmiiTxDone    : std_logic;
	signal arpNudp       : std_logic;
	signal send          : std_logic;
	signal doneArp       : std_logic;
	signal doneUdp       : std_logic;
	signal fifoLvl       : std_logic;

begin

	i_rmiiTx : entity netitf_lib.rmiiTx
		port map(
			clk       => clk,
			refClk    => rmiiRefClk,
			txd       => rmiiTxd,
			txen      => rmiiTxen,
			txStart   => rmiiTxStart,
			txByte    => rmiiTxByte,
			txByteReq => rmiiTxByteReq,
			txByteRdy => rmiiTxByteRdy,
			txDone    => rmiiTxDone
		);

	i_txCtl : entity netitf_lib.txCtl
		generic map(
			UDP_PAYLOAD_LENGTH => UDP_PAYLOAD_LENGTH
		)
		port map(
			clk              => clk,
			mac              => mac,
			ip               => ip,
			targetMac        => targetMac,
			targetIp         => targetIp,
			arpNudp          => arpNudp,
			send             => send,
			doneArp          => doneArp,
			doneUdp          => doneUdp,
			fifoRd           => fifoRd,
			fifoData         => fifoRdData,
			fifoEmpty        => fifoEmpty,
			rmiiTxStart      => rmiiTxStart,
			rmiiTxByteReq    => rmiiTxByteReq,
			rmiiTxByteRdy    => rmiiTxByteRdy,
			rmiiTxByte       => rmiiTxByte,
			rmiiTxDone       => rmiiTxDone
		);

	i_fifo : entity netitf_lib.fifoXilinx
		generic map(
			UDP_PAYLOAD_LENGTH => UDP_PAYLOAD_LENGTH
		)
		port map(
			clk              => clk,
			din              => fifoWrData,
			dout             => fifoRdData,
			wr               => fifoWr,
			rd               => fifoRd,
			full             => fifoFull,
			lvl              => fifoLvl,
			empty            => fifoEmpty
		);

	i_txArbitrator : entity netitf_lib.txArbitrator
		port map(
			clk     => clk,
			fifoLvl => fifoLvl,
			arpReq  => arpReq,
			arpNudp => arpNudp,
			send    => send,
			doneArp => doneArp,
			doneUdp => doneUdp
		);

end rtl;
