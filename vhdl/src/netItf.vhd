--------------------------------------------------------------------------------
--
-- netItf
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:25:37 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 16:28:25 +0200 (Wed, 28 May 2014) $
-- $Revision: 166 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Top-level of the interface. mac, ip, udpPort should be connected to constant
--   signals.
--   The PHY side is a classical RMII 100M interface
--   The application side presents a FIFO-like interface.
--   The interface automatically answers the ARP requests.
--   All signals are part of "clk" clock domain (i.e. no synchronization is done
--   internally)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library netitf_lib;
use netitf_lib.types_pkg.all;


entity netItf is
	generic(
		UDP_PAYLOAD_LENGTH : natural := 64
	);
	port(
		clk              : in  std_logic;                      -- clock, rising-edge active, 100 MHz
		mac              : in  byteVector(0 to 5);             -- MAC address. 1st byte is at pos 0
		ip               : in  byteVector(0 to 3);             -- IP address. 1st byte is at pos 0
		udpPort          : in  byteVector(0 to 1);             -- UDP port. LSB is at pos 0
		rmiiRn           : out std_logic;                      -- \
		rmiiRxdIn        : in  std_logic_vector(1 downto 0);   -- |
		rmiiRxdEn        : out std_logic;                      -- |
		rmiiCrsIn        : in  std_logic;                      -- > RMII interface signals. See LAN820A datasheet
		rmiiRefClk       : out std_logic;                      -- |
		rmiiTxd          : out std_logic_vector(1 downto 0);   -- |
		rmiiTxen         : out std_logic;                      -- /
		txFifoWr         : in  std_logic;                      -- asserted to write data in the transmit FIFO
		txFifoData       : in  std_logic_vector(7 downto 0);   -- data to transmit
		txFifoFull       : out std_logic;                      -- asserted when transmit FIFO is full
		rxFifoRd         : in  std_logic;                      -- asserted to read data from the receive FIFO
		rxFifoData       : out std_logic_vector(7 downto 0);   -- received data
		rxFifoEmpty      : out std_logic;                      -- asserted when receive FIFO is empty
		rxFifoFull       : out std_logic                       -- asserted when receive FIFO is full
	);
end netItf;


architecture rtl of netItf is

	signal rmiiRefClkWire  : std_logic;
	signal peerIp          : byteVector(3 downto 0);
	signal peerMac         : byteVector(5 downto 0);
	signal send            : std_logic;
	signal arpReq          : std_logic;

begin

	-- outputs
	rmiiRefClk <= rmiiRefClkWire;

	-- RMII reference clock
	i_rmiiClk : entity netitf_lib.rmiiClk
		port map(
			clk    => clk,
			refClk => rmiiRefClkWire
		);

	-- receiver
	i_rx : entity netitf_lib.rx
		port map(
			clk           => clk,
			rmiiRn        => rmiiRn,
			rmiiRxdIn     => rmiiRxdIn,
			rmiiRxdEn     => rmiiRxdEn,
			rmiiCrsIn     => rmiiCrsIn,
			rmiiRefClk    => rmiiRefClkWire,
			mac           => mac,
			ip            => ip,
			udpPort       => udpPort,
			senderMac     => peerMac,
			senderIp      => peerIp,
			arpReq        => arpReq,
			fifoRd        => rxFifoRd,
			fifoRdData    => rxFifoData,
			fifoEmpty     => rxFifoEmpty,
			fifoFull      => rxFifoFull
		);

	-- transmitter
	i_tx : entity work.tx
		port map(
			clk              => clk,
			mac              => mac,
			ip               => ip,
			targetMac        => peerMac,
			targetIp         => peerIp,
			arpReq           => arpReq,
			fifoWr           => txFifoWr,
			fifoWrData       => txFifoData,
			fifoFull         => txFifoFull,
			rmiiRefClk       => rmiiRefClkWire,
			rmiiTxd          => rmiiTxd,
			rmiiTxen         => rmiiTxen
		);

end rtl;
