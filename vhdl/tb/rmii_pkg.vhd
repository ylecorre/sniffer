--------------------------------------------------------------------------------
--
-- rmii_pkg
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 12:09:49 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 16:28:25 +0200 (Wed, 28 May 2014) $
-- $Revision: 166 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   RMII operation packages. Emulate receive and transmit from/to RMII interface
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library netitf_lib;
use netitf_lib.packet_pkg.all;


package rmii_pkg is

	procedure rmiiReceive(
		signal   clk         : in    std_logic;
		signal   rxd         : out   std_logic_vector(1 downto 0);
		signal   crs         : out   std_logic;
		variable etherPacket : inout etherPacketType
	);

	procedure rmiiTransmit(
		signal   clk         : in  std_logic;
		signal   txen        : in  std_logic;
		signal   txd         : in  std_logic_vector(1 downto 0);
		variable etherPacket : inout etherPacketType
	);

end rmii_pkg;


package body rmii_pkg is

  ------------------------------------------------------------------------------
  -- receiver side
  ------------------------------------------------------------------------------
	procedure rmiiReceiveByte(
		signal   clk          : in    std_logic;
		signal   rxd          : out   std_logic_vector(1 downto 0);
		signal   crs          : out   std_logic;
		constant byte         : in    std_logic_vector(7 downto 0);
		constant lastByteFlag : in    boolean := false
	) is
	begin
		crs <= '1';
		rxd <= byte(1 downto 0);
		wait until falling_edge(clk);
		rxd <= byte(3 downto 2);
		wait until falling_edge(clk);
		rxd <= byte(5 downto 4);
		wait until falling_edge(clk);
		rxd <= byte(7 downto 6);
		if lastByteFlag = true then
			crs <= '0';
		end if;
		wait until falling_edge(clk);
	end rmiiReceiveByte;

	procedure rmiiReceive(
		signal   clk         : in    std_logic;
		signal   rxd         : out   std_logic_vector(1 downto 0);
		signal   crs         : out   std_logic;
		variable etherPacket : inout etherPacketType
	) is
		constant length : natural := etherPacket.getLength;
		variable byte   : std_logic_vector(7 downto 0);
	begin
		wait until falling_edge(clk);
		for i in 0 to 6 loop
			rmiiReceiveByte(clk, rxd, crs, x"55", false);
		end loop;
		rmiiReceiveByte(clk, rxd, crs, x"d5", false);
		for i in 0 to length - 1 loop
			byte :=  etherPacket.getByte(i);
			if i = length - 1 then
				rmiiReceiveByte(clk, rxd, crs, byte, true);
			else
				rmiiReceiveByte(clk, rxd, crs, byte, false);
			end if;
		end loop;
	end rmiiReceive;

  ------------------------------------------------------------------------------
  -- transmitter side
  ------------------------------------------------------------------------------
	procedure rmiiTransmitByte(
		signal   clk      : in  std_logic;
		signal   txen     : in  std_logic;
		signal   txd      : in  std_logic_vector(1 downto 0);
		variable byte     : out std_logic_vector(7 downto 0);
		variable stopFlag : out boolean
	) is
	begin
		wait until falling_edge(clk);
		if txen = '0' then
			stopFlag := true;
		else
			stopFlag := false;
			byte(1 downto 0) := txd;
			wait until falling_edge(clk);
			byte(3 downto 2) := txd;
			wait until falling_edge(clk);
			byte(5 downto 4) := txd;
			wait until falling_edge(clk);
			byte(7 downto 6) := txd;
		end if;
	end rmiiTransmitByte;

	procedure rmiiTransmit(
		signal   clk         : in    std_logic;
		signal   txen        : in    std_logic;
		signal   txd         : in    std_logic_vector(1 downto 0);
		variable etherPacket : inout etherPacketType
	) is
		variable stop  : boolean;
		variable bytes : byteVectorPtr;
		variable byte  : std_logic_vector(7 downto 0);
		variable tmp   : byteVectorPtr;
	begin
		wait until txen = '1';
		for i in 0 to 6 loop
			rmiiTransmitByte(clk, txen, txd, byte, stop);
			assert byte = x"55"
				report "RMII::TX: preamble error"
				severity ERROR;
		end loop;
		rmiiTransmitByte(clk, txen, txd, byte, stop);
		assert byte = x"d5"
			report "RMII::TX: SFD error"
			severity ERROR;
		while true loop
			rmiiTransmitByte(clk, txen, txd, byte, stop);
			if stop = true then
				exit;
			end if;
			if bytes = NULL then
				bytes := new byteVector(0 to 0);
				bytes(0) := byte;
			else
				tmp := new byteVector(0 to bytes'length);
				tmp(bytes'range) := bytes.all;
				tmp(tmp'high) := byte;
				deallocate(bytes);
				bytes := tmp;
			end if;
		end loop;
		etherPacket.create(bytes.all);
	end rmiiTransmit;

end package body;
