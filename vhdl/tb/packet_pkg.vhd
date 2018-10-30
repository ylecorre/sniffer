--------------------------------------------------------------------------------
--
-- packet_pkg
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 12:03:44 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 12:10:04 +0200 (Wed, 28 May 2014) $
-- $Revision: 163 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Ethernet/ARP/IPv4/UDP packet manipulation package. Supports encapsulation.
--   Note that packets must be deallocated (using membere function "deallocate")
--   if they have to re-encapsulate other packets
--   Must be compiled with VHDL-2002
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;


package packet_pkg is

	type naturalVector is array(natural range <>) of natural;
	type byteVector is array(natural range <>) of std_logic_vector(7 downto 0);
	type byteVectorPtr is access byteVector;

  ------------------------------------------------------------------------------
	-- raw packet
  ------------------------------------------------------------------------------
	type rawPacketType is protected
		procedure create(data : in  byteVector);
		procedure create;
		procedure append(data : in  std_logic_vector(7 downto 0));
		procedure append(data : in  natural);
		procedure deallocate;
		impure function getLength return natural;
		impure function getByte(constant idx : in  natural) return std_logic_vector;
	end protected rawPacketType;
	procedure write(variable l : inout line; variable rawPacket : inout rawPacketType);

  ------------------------------------------------------------------------------
	-- UDP packet
  ------------------------------------------------------------------------------
	type udpPacketType is protected
		procedure create(srcPort : in  natural; dstPort : in  natural);
		procedure encapsulate(rawPacket : inout rawPacketType);
		procedure deallocate;
		impure function getSrcPort return natural;
		impure function getDstPort return natural;
		impure function getPayloadLength return natural;
		impure function getLength return natural;
		impure function getByte(constant idx : in  natural) return std_logic_vector;
	end protected udpPacketType;
	procedure write(variable l : inout line; variable udpPacket : inout udpPacketType);

  ------------------------------------------------------------------------------
	-- IPv4 packet (subset only: no fragmentation, fixed TTL and options)
  ------------------------------------------------------------------------------
	type ip4PacketType is protected
		procedure create(srcIp : in  naturalVector; dstIp : in  naturalVector);
		procedure encapsulate(udpPacket : inout udpPacketType);
		procedure deallocate;
		impure function getSrcIp return naturalVector;
		impure function getDstIp return naturalVector;
		impure function getPayloadLength return natural;
		impure function getLength return natural;
		impure function getByte(constant idx : in  natural) return std_logic_vector;
	end protected ip4PacketType;
	procedure write(variable l : inout line; variable ipPacket : inout ip4PacketType);

  ------------------------------------------------------------------------------
	-- ARP packet
  ------------------------------------------------------------------------------
	constant ARP_REQUEST : natural := 1;
	constant ARP_REPLY   : natural := 2;

	type arpPacketType is protected
		procedure create(
			operation   : in  natural;
			senderHAddr : in  byteVector;
			senderPAddr : in  naturalVector;
			targetHAddr : in  byteVector;
			targetPAddr : in  naturalVector
		);
		procedure deallocate;
		impure function getSenderHAddr return byteVector;
		impure function getSenderPAddr return naturalVector;
		impure function getTargetHAddr return byteVector;
		impure function getTargetPAddr return naturalVector;
		impure function getLength return natural;
		impure function getByte(constant idx : in  natural) return std_logic_vector;
	end protected arpPacketType;
	procedure write(variable l : inout line; variable arpPacket : inout arpPacketType);

  ------------------------------------------------------------------------------
	-- ethernet frame (without preamble and SFD)
  ------------------------------------------------------------------------------
	type etherPacketType is protected
		procedure create(dstMac : in  byteVector; srcMac : in  byteVector);
		procedure create(bytes : in byteVector; length : in natural);
		procedure create(bytes : in byteVector);
		procedure encapsulate(ipPacket : inout ip4PacketType);
		procedure encapsulate(arpPacket : inout arpPacketType);
		procedure deallocate;
		impure function checkCrc return boolean;
		impure function getSrcMac return byteVector;
		impure function getDstMac return byteVector;
		impure function getPayloadLength return natural;
		impure function getLength return natural;
		impure function getByte(constant idx : in  natural) return std_logic_vector;
	end protected etherPacketType;
	procedure write(variable l : inout line; variable etherPacket : inout etherPacketType);

  ------------------------------------------------------------------------------
	-- Conversion to/from signals (for easy interfacing with entities)
  ------------------------------------------------------------------------------
	type packetSignalType is record
		bytes  : byteVector(0 to 2047);
		length : natural;
  end record;
  procedure packet2signal(signal packetSignal : out packetSignalType; variable etherPacket : inout etherPacketType);
  procedure signal2packet(variable etherPacket : inout etherPacketType; signal  packetSignal : in packetSignalType);

end packet_pkg;


package body packet_pkg is

  ------------------------------------------------------------------------------
	-- utilities
  ------------------------------------------------------------------------------
	procedure setField(pkt : inout byteVectorPtr; idx : in  natural; val : in  natural) is
		variable tmp : std_logic_vector(15 downto 0);
	begin
		tmp := std_logic_vector(to_unsigned(val, 16));
		pkt(idx) := tmp(15 downto 8);
		pkt(idx + 1) := tmp(7 downto 0);
	end setField;

  ------------------------------------------------------------------------------
	-- raw packet
  ------------------------------------------------------------------------------
	type rawPacketType is protected body

		variable pkt : byteVectorPtr;

		procedure create(
			data : in  byteVector
		) is
			constant length : natural := data'length;
		begin
			pkt := new byteVector(0 to length - 1);
			for i in 0 to length - 1 loop
				pkt(i) := data(i);
			end loop;
		end create;

		procedure create is
		begin
			pkt := NULL;
		end create;

		procedure append(data : in  std_logic_vector(7 downto 0)) is
			variable tmp    : byteVectorPtr;
			variable length : natural;
		begin
			if pkt = NULL then
				pkt := new byteVector(0 to 0);
				pkt(0) := data;
			else
				length := pkt'length + 1;
				tmp := new byteVector(0 to length - 1);
				tmp(0 to length - 2) := pkt.all;
				tmp(length - 1) := data;
				deallocate(pkt);
				pkt := tmp;
			end if;
		end append;

		procedure append(data : in natural) is
		begin
			assert data < 256
				report "rawPacketType::append can only append data < 256"
				severity FAILURE;
			append(std_logic_vector(to_unsigned(data, 8)));
		end append;

		procedure deallocate is
		begin
			deallocate(pkt);
		end deallocate;

		impure function getLength return natural is
		begin
			if pkt = NULL then
				return 0;
			else
				return pkt'length;
			end if;
		end getLength;

		impure function getByte(
			constant idx : in  natural
		) return std_logic_vector is
		begin
			assert idx < pkt'length
				report "rawPacketType::getByte: index overflow"
				severity FAILURE;
			return pkt(idx);
		end getByte;

	end protected body rawPacketType;

	procedure write(
		variable l         : inout line;
		variable rawPacket : inout rawPacketType
	) is
		constant length : natural := rawPacket.getLength;
	begin
		assert length > 0
			report "rawPacketType::write: 0-length packet"
			severity FAILURE;
		for i in 0 to length - 1 loop
			write(l, string'(" 0x"));
			hwrite(l, rawPacket.getByte(i));
		end loop;
	end write;

  ------------------------------------------------------------------------------
	-- UDP packet
  ------------------------------------------------------------------------------
	type udpPacketType is protected body

		variable sPort : natural;
		variable dPort : natural;
		variable len   : natural;
		variable cksum : natural;
		variable pkt   : byteVectorPtr;

		procedure create(
			srcPort : in  natural;
			dstPort : in  natural
		) is
		begin
			sPort := srcPort;
			dPort := dstPort;
			cksum := 0;
			len := 8;
			pkt := new byteVector(0 to 7);
			setField(pkt, 0, srcPort);
			setField(pkt, 2, dstPort);
			setfield(pkt, 4, len);
			setfield(pkt, 6, 0);
		end create;

		procedure encapsulate(
			rawPacket : inout rawPacketType
		) is
			variable payloadLength : natural;
			variable tmpPkt        : byteVectorPtr;
		begin
			assert pkt /= NULL
				report "udpPacketType::encapsulate: packet is not empty"
				severity FAILURE;
			payloadLength := rawPacket.getLength;
			len := len + payloadLength;
			tmpPkt := new byteVector(0 to len - 1);
			tmpPkt(0 to 7) := pkt(0 to 7);
			for i in 0 to payloadLength - 1 loop
				tmpPkt(i + 8) := rawPacket.getByte(i);
			end loop;
			deallocate(pkt);
			pkt := tmpPkt;
			setField(pkt, 4, len);
		end encapsulate;

		procedure deallocate is
		begin
			deallocate(pkt);
		end deallocate;

		impure function getSrcPort return natural is
		begin
			return sPort;
		end getSrcPort;

		impure function getDstPort return natural is
		begin
			return dPort;
		end getDstPort;

		impure function getPayloadLength return natural is
		begin
			return len - 8;
		end getPayloadLength;

		impure function getLength return natural is
		begin
			if pkt = NULL then
				return 0;
			else
				return pkt'length;
			end if;
		end getLength;

		impure function getByte(
			constant idx : in  natural
		) return std_logic_vector is
		begin
			assert idx < pkt'length
				report "udpPacketType::getByte: index overflow"
				severity FAILURE;
			return pkt(idx);
		end getByte;

	end protected body udpPacketType;

	procedure write(
		variable l         : inout line;
		variable udpPacket : inout udpPacketType
	) is
		constant length : natural := udpPacket.getLength;
	begin
		assert length > 0
			report "udpPacketType::write: 0-length packet"
			severity FAILURE;
		for i in 0 to length - 1 loop
			write(l, string'(" 0x"));
			hwrite(l, udpPacket.getByte(i));
		end loop;
	end write;

  ------------------------------------------------------------------------------
	-- IPv4 packet
  ------------------------------------------------------------------------------
	type ip4PacketType is protected body

		variable sIp : naturalVector(0 to 3);
		variable dIp : naturalVector(0 to 3);
		variable len   : natural;
		variable cksum : natural;
		variable pkt   : byteVectorPtr;

		procedure insertChecksum is
			variable cksumV   : unsigned(16 downto 0) := to_unsigned(0, 17);
			variable operandV : unsigned(16 downto 0);
		begin
			cksumV := to_unsigned(0, 17);
			for i in 0 to 19 loop
				if i mod 2 = 0 then
					operandV := shift_left(resize(unsigned(pkt(i)), 17), 8);
				else
					operandV := resize(unsigned(pkt(i)), 17);
				end if;
				cksumV := resize(cksumV, 17) + operandV;
				cksumV := resize(cksumV(15 downto 0), 17) + resize('0' & cksumV(16), 17);
				cksumV(16) := '0';
			end loop;
			cksumV(15 downto 0) := not cksumV(15 downto 0);
			setField(pkt, 10, to_integer(cksumV));
		end insertChecksum;

		procedure create(
			srcIp : in  naturalVector;
			dstIp : in  naturalVector
		) is
		begin
			sIp := srcIp;
			dIp := dstIp;
			cksum := 0;
			len := 20;
			pkt := new byteVector(0 to 19);
			pkt(0 to 1) := (x"45", x"00");
			setField(pkt, 2, len);
      pkt(4 to 9) := (x"00", x"00", x"00", x"00", x"80", x"11");
			setField(pkt, 10, cksum); -- to be calculated later
			pkt(12) := std_logic_vector(to_unsigned(sIp(0), 8));
			pkt(13) := std_logic_vector(to_unsigned(sIp(1), 8));
			pkt(14) := std_logic_vector(to_unsigned(sIp(2), 8));
			pkt(15) := std_logic_vector(to_unsigned(sIp(3), 8));
			pkt(16) := std_logic_vector(to_unsigned(dIp(0), 8));
			pkt(17) := std_logic_vector(to_unsigned(dIp(1), 8));
			pkt(18) := std_logic_vector(to_unsigned(dIp(2), 8));
			pkt(19) := std_logic_vector(to_unsigned(dIp(3), 8));
			insertChecksum;
		end create;

		procedure encapsulate(
			udpPacket : inout udpPacketType
		) is
			variable payloadLength : natural;
			variable tmpPkt        : byteVectorPtr;
		begin
			assert pkt /= NULL
				report "ip4PacketType::encapsulate: packet is not empty"
				severity FAILURE;
			payloadLength := udpPacket.getLength;
			len := len + payloadLength;
			tmpPkt := new byteVector(0 to len - 1);
			tmpPkt(0 to 19) := pkt(0 to 19);
			for i in 0 to payloadLength - 1 loop
				tmpPkt(i + 20) := udpPacket.getByte(i);
			end loop;
			deallocate(pkt);
			pkt := tmpPkt;
			setField(pkt, 2, len);
			setField(pkt, 10, cksum); -- to be calculated later
			insertChecksum;
		end encapsulate;

		procedure deallocate is
		begin
			deallocate(pkt);
		end deallocate;

		impure function getSrcIp return naturalVector is
		begin
			return sIp;
		end getSrcIp;

		impure function getDstIp return naturalVector is
		begin
			return dIp;
		end getDstIp;

		impure function getPayloadLength return natural is
		begin
			return len - 20;
		end getPayloadLength;

		impure function getLength return natural is
		begin
			if pkt = NULL then
				return 0;
			else
				return pkt'length;
			end if;
		end getLength;

		impure function getByte(
			constant idx : in  natural
		) return std_logic_vector is
		begin
			assert idx < pkt'length
				report "ip4PacketType::getByte: index overflow"
				severity FAILURE;
			return pkt(idx);
		end getByte;

	end protected body ip4PacketType;

	procedure write(
		variable l        : inout line;
		variable ipPacket : inout ip4PacketType
	) is
		constant length : natural := ipPacket.getLength;
	begin
		assert length > 0
			report "ip4PacketType::write: 0-length packet"
			severity FAILURE;
		for i in 0 to length - 1 loop
			write(l, string'(" 0x"));
			hwrite(l, ipPacket.getByte(i));
		end loop;
	end write;

  ------------------------------------------------------------------------------
	-- ARP packet
  ------------------------------------------------------------------------------
	type arpPacketType is protected body

		variable op  : natural;
		variable sha : byteVector(0 to 5);
		variable spa : naturalVector(0 to 3);
		variable tha : byteVector(0 to 5);
		variable tpa : naturalVector(0 to 3);
		variable len : natural;
		variable pkt : byteVectorPtr;

		procedure create(
			operation   : in  natural;
			senderHAddr : in  byteVector;
			senderPAddr : in  naturalVector;
			targetHAddr : in  byteVector;
			targetPAddr : in  naturalVector
		) is
		begin
			op := operation;
			sha := senderHAddr;
			spa := senderPAddr;
			tha := targetHAddr;
			tpa := targetPAddr;
			len := 28;
			pkt := new byteVector(0 to len - 1);
			pkt(0 to 5) := (x"00", x"01", x"08", x"00", x"06", x"04");
			setField(pkt, 6, op);
			pkt(8 to 13) := sha;
			for i in 0 to 3 loop
				pkt(14 + i) := std_logic_vector(to_unsigned(spa(i), 8));
			end loop;
			pkt(18 to 23) := tha;
			for i in 0 to 3 loop
				pkt(24 + i) := std_logic_vector(to_unsigned(tpa(i), 8));
			end loop;
		end create;

		procedure deallocate is
		begin
			deallocate(pkt);
		end deallocate;

		impure function getSenderHAddr return byteVector is
		begin
			return sha;
		end getSenderHAddr;

		impure function getSenderPAddr return naturalVector is
		begin
			return spa;
		end getSenderPAddr;

		impure function getTargetHAddr return byteVector is
		begin
			return tha;
		end getTargetHAddr;

		impure function getTargetPAddr return naturalVector is
		begin
			return tpa;
		end getTargetPAddr;

		impure function getLength return natural is
		begin
			if pkt = NULL then
				return 0;
			else
				return pkt'length;
			end if;
		end getLength;

		impure function getByte(
			constant idx : in  natural
		) return std_logic_vector is
		begin
			assert idx < pkt'length
				report "arpPacketType::getByte: index overflow"
				severity FAILURE;
			return pkt(idx);
		end getByte;

	end protected body arpPacketType;

	procedure write(
		variable l         : inout line;
		variable arpPacket : inout arpPacketType
	) is
		constant length : natural := arpPacket.getLength;
	begin
		assert length > 0
			report "arpPacketType::write: 0-length packet"
			severity FAILURE;
		for i in 0 to length - 1 loop
			write(l, string'(" 0x"));
			hwrite(l, arpPacket.getByte(i));
		end loop;
	end write;

  ------------------------------------------------------------------------------
	-- ethernet frame
  ------------------------------------------------------------------------------
	type etherPacketType is protected body

		variable sMac  : byteVector(0 to 5);
		variable dMac  : byteVector(0 to 5);
		variable len   : natural;
		variable pkt   : byteVectorPtr;

		impure function calcCrc return byteVector is
			constant length : natural := pkt'length - 4;
			variable crc    : std_logic_vector(31 downto 0);
			variable newCrc : std_logic_vector(31 downto 0);
			variable bv     : byteVector(0 to 3);
		begin
			crc := x"ffffffff";
			for i in 0 to length - 1 loop
				newCrc(0)  := crc(24) xor crc(30) xor pkt(i)(1) xor pkt(i)(7);
				newCrc(1)  := crc(25) xor crc(31) xor pkt(i)(0) xor pkt(i)(6) xor crc(24) xor crc(30) xor pkt(i)(1) xor pkt(i)(7);
				newCrc(2)  := crc(26) xor pkt(i)(5) xor crc(25) xor crc(31) xor pkt(i)(0) xor pkt(i)(6) xor crc(24) xor crc(30) xor pkt(i)(1) xor pkt(i)(7);
				newCrc(3)  := crc(27) xor pkt(i)(4) xor crc(26) xor pkt(i)(5) xor crc(25) xor crc(31) xor pkt(i)(0) xor pkt(i)(6);
				newCrc(4)  := crc(28) xor pkt(i)(3) xor crc(27) xor pkt(i)(4) xor crc(26) xor pkt(i)(5) xor crc(24) xor crc(30) xor pkt(i)(1) xor pkt(i)(7);
				newCrc(5)  := crc(29) xor pkt(i)(2) xor crc(28) xor pkt(i)(3) xor crc(27) xor pkt(i)(4) xor crc(25) xor crc(31) xor pkt(i)(0) xor pkt(i)(6) xor crc(24) xor crc(30) xor pkt(i)(1) xor pkt(i)(7);
				newCrc(6)  := crc(30) xor pkt(i)(1) xor crc(29) xor pkt(i)(2) xor crc(28) xor pkt(i)(3) xor crc(26) xor pkt(i)(5) xor crc(25) xor crc(31) xor pkt(i)(0) xor pkt(i)(6);
				newCrc(7)  := crc(31) xor pkt(i)(0) xor crc(29) xor pkt(i)(2) xor crc(27) xor pkt(i)(4) xor crc(26) xor pkt(i)(5) xor crc(24) xor pkt(i)(7);
				newCrc(8)  := crc(0)  xor crc(28) xor pkt(i)(3) xor crc(27) xor pkt(i)(4) xor crc(25) xor pkt(i)(6) xor crc(24) xor pkt(i)(7);
				newCrc(9)  := crc(1)  xor crc(29) xor pkt(i)(2) xor crc(28) xor pkt(i)(3) xor crc(26) xor pkt(i)(5) xor crc(25) xor pkt(i)(6);
				newCrc(10) := crc(2)  xor crc(29) xor pkt(i)(2) xor crc(27) xor pkt(i)(4) xor crc(26) xor pkt(i)(5) xor crc(24) xor pkt(i)(7);
				newCrc(11) := crc(3)  xor crc(28) xor pkt(i)(3) xor crc(27) xor pkt(i)(4) xor crc(25) xor pkt(i)(6) xor crc(24) xor pkt(i)(7);
				newCrc(12) := crc(4)  xor crc(29) xor pkt(i)(2) xor crc(28) xor pkt(i)(3) xor crc(26) xor pkt(i)(5) xor crc(25) xor pkt(i)(6) xor crc(24) xor crc(30) xor pkt(i)(1) xor pkt(i)(7);
				newCrc(13) := crc(5)  xor crc(30) xor pkt(i)(1) xor crc(29) xor pkt(i)(2) xor crc(27) xor pkt(i)(4) xor crc(26) xor pkt(i)(5) xor crc(25) xor crc(31) xor pkt(i)(0) xor pkt(i)(6);
				newCrc(14) := crc(6)  xor crc(31) xor pkt(i)(0) xor crc(30) xor pkt(i)(1) xor crc(28) xor pkt(i)(3) xor crc(27) xor pkt(i)(4) xor crc(26) xor pkt(i)(5);
				newCrc(15) := crc(7)  xor crc(31) xor pkt(i)(0) xor crc(29) xor pkt(i)(2) xor crc(28) xor pkt(i)(3) xor crc(27) xor pkt(i)(4);
				newCrc(16) := crc(8)  xor crc(29) xor pkt(i)(2) xor crc(28) xor pkt(i)(3) xor crc(24) xor pkt(i)(7);
				newCrc(17) := crc(9)  xor crc(30) xor pkt(i)(1) xor crc(29) xor pkt(i)(2) xor crc(25) xor pkt(i)(6);
				newCrc(18) := crc(10) xor crc(31) xor pkt(i)(0) xor crc(30) xor pkt(i)(1) xor crc(26) xor pkt(i)(5);
				newCrc(19) := crc(11) xor crc(31) xor pkt(i)(0) xor crc(27) xor pkt(i)(4);
				newCrc(20) := crc(12) xor crc(28) xor pkt(i)(3);
				newCrc(21) := crc(13) xor crc(29) xor pkt(i)(2);
				newCrc(22) := crc(14) xor crc(24) xor pkt(i)(7);
				newCrc(23) := crc(15) xor crc(25) xor pkt(i)(6) xor crc(24) xor crc(30) xor pkt(i)(1) xor pkt(i)(7);
				newCrc(24) := crc(16) xor crc(26) xor pkt(i)(5) xor crc(25) xor crc(31) xor pkt(i)(0) xor pkt(i)(6);
				newCrc(25) := crc(17) xor crc(27) xor pkt(i)(4) xor crc(26) xor pkt(i)(5);
				newCrc(26) := crc(18) xor crc(28) xor pkt(i)(3) xor crc(27) xor pkt(i)(4) xor crc(24) xor crc(30) xor pkt(i)(1) xor pkt(i)(7);
				newCrc(27) := crc(19) xor crc(29) xor pkt(i)(2) xor crc(28) xor pkt(i)(3) xor crc(25) xor crc(31) xor pkt(i)(0) xor pkt(i)(6);
				newCrc(28) := crc(20) xor crc(30) xor pkt(i)(1) xor crc(29) xor pkt(i)(2) xor crc(26) xor pkt(i)(5);
				newCrc(29) := crc(21) xor crc(31) xor pkt(i)(0) xor crc(30) xor pkt(i)(1) xor crc(27) xor pkt(i)(4);
				newCrc(30) := crc(22) xor crc(31) xor pkt(i)(0) xor crc(28) xor pkt(i)(3);
				newCrc(31) := crc(23) xor crc(29) xor pkt(i)(2);
				crc := newCrc;
			end loop;
			bv(0) := not(crc(24) & crc(25) & crc(26) & crc(27) & crc(28) & crc(29) & crc(30) & crc(31));
			bv(1) := not(crc(16) & crc(17) & crc(18) & crc(19) & crc(20) & crc(21) & crc(22) & crc(23));
			bv(2) := not(crc(8) & crc(9) & crc(10) & crc(11) & crc(12) & crc(13) & crc(14) & crc(15));
			bv(3) := not(crc(0) & crc(1) & crc(2) & crc(3) & crc(4) & crc(5) & crc(6) & crc(7));
			return bv;
		end calcCrc;

		procedure insertCrc is
			constant length : natural := pkt'length - 4;
			variable crc    : byteVector(0 to 3);
		begin
			crc := calcCrc;
			pkt(length + 0) := crc(0);
			pkt(length + 1) := crc(1);
			pkt(length + 2) := crc(2);
			pkt(length + 3) := crc(3);
		end insertCrc;

		impure function checkCrc return boolean is
			constant length : natural := pkt'length;
			variable crc    : byteVector(0 to 3);
			variable l      : line;
		begin
			crc := calcCrc;
			if pkt(length - 1) /= crc(3) then
				return false;
			elsif pkt(length - 2) /= crc(2) then
				return false;
			elsif pkt(length - 3) /= crc(1) then
				return false;
			elsif pkt(length - 4) /= crc(0) then
				return false;
			else
				return true;
			end if;
		end checkCrc;

		procedure create(
			dstMac    : in  byteVector;
			srcMac    : in  byteVector
		) is
			variable crc : std_logic_vector(31 downto 0);
		begin
			sMac := srcMac;
			dMac := dstMac;
			len := 18;
			pkt := new byteVector(0 to 11);
 			pkt(0 to 5) := dstMac;
			pkt(6 to 11) := srcMac;
		end create;

		procedure create(
			bytes  : in byteVector;
			length : in natural
		) is
		begin
			len := length;
			pkt := new byteVector(0 to len - 1);
			for i in 0 to len - 1 loop
				pkt(i) := bytes(i);
			end loop;
			dMac(0) := pkt(0);
			dMac(1) := pkt(1);
			dMac(2) := pkt(2);
			dMac(3) := pkt(3);
			dMac(4) := pkt(4);
			dMac(5) := pkt(5);
			sMac(0) := pkt(6);
			sMac(1) := pkt(7);
			sMac(2) := pkt(8);
			sMac(3) := pkt(9);
			sMac(4) := pkt(10);
			sMac(5) := pkt(11);
		end create;

		procedure create(
			bytes : in byteVector
		) is
		begin
			create(bytes, bytes'length);
		end create;

		procedure encapsulate(
			ipPacket : inout ip4PacketType
		) is
			variable payloadLength : natural;
			variable tmpPkt        : byteVectorPtr;
		begin
			assert pkt /= NULL
				report "etherPacketType::encapsulate[ipPacket]: packet is not empty"
				severity FAILURE;
			payloadLength := ipPacket.getLength;
			len := len + payloadLength;
			if len < 64 then
				len := 64;
			end if;
			tmpPkt := new byteVector(0 to len - 1);
			tmpPkt(0 to 11) := pkt(0 to 11);
			tmpPkt(12) := x"08"; -- \
			tmpPkt(13) := x"00"; -- / ethertype IPv4
			for i in 0 to payloadLength - 1 loop
				tmpPkt(i + 14) := ipPacket.getByte(i);
			end loop;
			for i in payloadLength + 14 to 63 loop
				tmpPkt(i) := x"00";
			end loop;
			deallocate(pkt);
			pkt := tmpPkt;
			insertCrc;
		end encapsulate;

		procedure encapsulate(
			arpPacket : inout arpPacketType
		) is
			variable payloadLength : natural;
			variable tmpPkt        : byteVectorPtr;
		begin
			assert pkt /= NULL
				report "etherPacketType::encapsulate[arpPacket]: packet is not empty"
				severity FAILURE;
			payloadLength := arpPacket.getLength;
			len := len + payloadLength;
			if len < 64 then
				len := 64;
			end if;
			tmpPkt := new byteVector(0 to len - 1);
			tmpPkt(0 to 11) := pkt(0 to 11);
			tmpPkt(12) := x"08"; -- \
			tmpPkt(13) := x"06"; -- / ARP over IPv4
			for i in 0 to payloadLength - 1 loop
				tmpPkt(i + 14) := arpPacket.getByte(i);
			end loop;
			for i in payloadLength + 14 to 63 loop
				tmpPkt(i) := x"00";
			end loop;
			deallocate(pkt);
			pkt := tmpPkt;
			insertCrc;
		end encapsulate;

		procedure deallocate is
		begin
			deallocate(pkt);
		end deallocate;

		impure function getSrcMac return byteVector is
		begin
			return sMac;
		end getSrcMac;

		impure function getDstMac return byteVector is
		begin
			return dMac;
		end getDstMac;

		impure function getPayloadLength return natural is
		begin
			return len - 18;
		end getPayloadLength;

		impure function getLength return natural is
		begin
			if pkt = NULL then
				return 0;
			else
				return pkt'length;
			end if;
		end getLength;

		impure function getByte(
			constant idx : in  natural
		) return std_logic_vector is
		begin
			assert idx < pkt'length
				report "etherPacketType::getByte: index overflow"
				severity FAILURE;
			return pkt(idx);
		end getByte;

	end protected body etherPacketType;

	procedure write(
		variable l           : inout line;
		variable etherPacket : inout etherPacketType
	) is
		constant length : natural := etherPacket.getLength;
	begin
		assert length > 0
			report "etherPacketType::write: 0-length packet"
			severity FAILURE;
		for i in 0 to length - 1 loop
			write(l, string'(" 0x"));
			hwrite(l, etherPacket.getByte(i));
		end loop;
	end write;

  ------------------------------------------------------------------------------
	-- Conversion to/from signals (for easy interfacing with entities)
  ------------------------------------------------------------------------------
  procedure packet2signal(
		signal   packetSignal : out   packetSignalType;
		variable etherPacket  : inout etherPacketType
	) is
		constant length : natural := etherPacket.getLength;
	begin
    packetSignal.length <= length;
    for i in 0 to length - 1 loop
      packetSignal.bytes(i) <= etherPacket.getByte(i);
    end loop;
    packetSignal.bytes(length to 2047) <= (others => x"00");
  end packet2signal;

  procedure signal2packet(
		variable etherPacket  : inout etherPacketType;
		signal   packetSignal : in    packetSignalType
	) is
	begin
		etherPacket.create(packetSignal.bytes, packetSignal.length);
	end signal2packet;

end package body;
