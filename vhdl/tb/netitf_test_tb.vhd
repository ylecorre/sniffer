--------------------------------------------------------------------------------
--
-- netitf_test_tb
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 12:02:07 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 16:28:25 +0200 (Wed, 28 May 2014) $
-- $Revision: 166 $
--
--------------------------------------------------------------------------------
-- Documentation:
--  Testbench of netitf_test entity. Simple design that transmit a stream of byte
--  of configurable frequency from the DUT to an PC. Used to test link throughput
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library netitf_lib;
use netitf_lib.packet_pkg.all;


entity netitf_test_tb is
end netitf_test_tb;


architecture bench of netitf_test_tb is

	signal clk          : std_logic;
	signal rmiiMdio     : std_logic;
	signal rmiiMdc      : std_logic;
	signal rmiiRn       : std_logic;
	signal rmiiRxd      : std_logic_vector(1 downto 0);
	signal rmiiCrs      : std_logic;
	signal rmiiRefClk   : std_logic;
	signal rmiiTxd      : std_logic_vector(1 downto 0);
	signal rmiiTxen     : std_logic;
	signal rn           : std_logic;
	signal sendFrame    : std_logic;
	signal loopback     : std_logic;
	signal arpNudp      : std_logic;
	signal packetSignal : packetSignalType;

  constant UDP_PORT  : natural               := 56789;

  constant BCST_MAC : byteVector(0 to 5)    := (x"ff", x"ff", x"ff", x"ff", x"ff", x"ff");
  constant PEER_MAC : byteVector(0 to 5)    := (x"e8", x"9d", x"87", x"09", x"2b", x"24");
  constant PEER_IP  : naturalVector(0 to 3) := (192, 168, 0, 4);
  constant DUT_MAC  : byteVector(0 to 5)    := (x"00", x"10", x"a4", x"7b", x"ea", x"80");
	constant DUT_IP   : naturalVector(0 to 3) := (192, 168, 0, 44);

begin

	i_netitf_test : entity netitf_lib.netitf_test
		port map(
			clk        => clk,
			rmiiMdio   => rmiiMdio,
			rmiiMdc    => rmiiMdc,
			rmiiRn     => rmiiRn,
			rmiiRxd    => rmiiRxd,
			rmiiCrs    => rmiiCrs,
			rmiiRefClk => rmiiRefClk,
			rmiiTxd    => rmiiTxd,
			rmiiTxen   => rmiiTxen
		);

  i_lan8720 : entity netitf_lib.lan8720
		generic map(
			DUMP_FILE_NAME => "dump.pcap"
		)
    port map(
      rn         => rmiiRn,
      mdio       => rmiiMdio,
      mdc        => rmiiMdc,
      txd        => rmiiTxd,
      txen       => rmiiTxen,
      rxd        => rmiiRxd,
      crs        => rmiiCrs,
      clkin      => rmiiRefClk,
			packet     => packetSignal,
      frameStart => sendFrame,
      loopback   => loopback,
      straps     => open
    );

  p_clock : process(rn, clk)
  begin
    if rn = '0' then
      clk <= '0';
    elsif rising_edge(rn) then
      clk <= '1' after 10 ns;
    elsif clk'event then
      clk <= not clk after 5 ns;
    end if;
  end process;

	p_stim : process

		procedure sendByte(
			byte : in  std_logic_vector
		) is
			variable arpPacket   : arpPacketType;
			variable rawPacket   : rawPacketType;
			variable udpPacket   : udpPacketType;
			variable ipPacket    : ip4PacketType;
			variable etherPacket : etherPacketType;
		begin
			rawPacket.create;
			rawPacket.append(byte);
			udpPacket.create(srcPort => UDP_PORT, dstPort => UDP_PORT);
			udpPacket.encapsulate(rawPacket);
			ipPacket.create(srcIp => PEER_IP, dstIp => DUT_IP);
			rawPacket.deallocate;
			ipPacket.encapsulate(udpPacket);
			udpPacket.deallocate;
			etherPacket.create(dstMac => DUT_MAC, srcMac => PEER_MAC);
			etherPacket.encapsulate(ipPacket);
			ipPacket.deallocate;
			packet2signal(packetSignal, etherPacket);
			etherPacket.deallocate;
			sendFrame <= '1';
			wait until rising_edge(rmiiRefClk);
			sendFrame <= '0';
			wait until rising_edge(rmiiRefClk);
		end sendByte;

		procedure arpConf is
			variable arpPacket   : arpPacketType;
			variable etherPacket : etherPacketType;
		begin
			wait until rising_edge(rmiiRefClk);
			arpPacket.create(
				operation   => ARP_REQUEST,
				senderHAddr => PEER_MAC,
				senderPAddr => PEER_IP,
				targetHAddr => BCST_MAC,
				targetPADdr => DUT_IP
			);
			etherPacket.create(dstMac => BCST_MAC, srcMac => PEER_MAC);
			etherPacket.encapsulate(arpPacket);
			arpPacket.deallocate;
			packet2signal(packetSignal, etherPacket);
			etherPacket.deallocate;
			sendFrame <= '1';
			wait until rising_edge(rmiiRefClk);
			sendFrame <= '0';
			wait until rising_edge(rmiiRefClk);
			etherPacket.deallocate;
			wait for 100 us;
		end arpConf;

	begin
		rn <= '0';
		sendFrame <= '0';
		loopback  <= '0';
		arpNudp   <= '0';
		wait for 10 ns;
		rn <= '1';
		wait until rising_edge(clk) and rmiiRn = '1';

		-- configure DUT through ARP
		arpConf;

		-- set stream frequency
		sendByte(x"99");
		wait for 100 us;
		sendByte(x"19");
		wait for 100 us;

		rn <= '0';
		wait for 10 ns;
		wait;
	end process;

end bench;
