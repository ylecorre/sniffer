--------------------------------------------------------------------------------
--
-- txCtl
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 10:48:51 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 16:28:25 +0200 (Wed, 28 May 2014) $
-- $Revision: 166 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Build the ARP and UDP packets to be transmitted. Read the UDP payload from
--   the transmit fifo. When the transmit fifo is empty, the last byte is repeated
--   (depending on the fifo behaviour).
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library netitf_lib;
use netitf_lib.types_pkg.all;


entity txCtl is
	generic(
		UDP_PAYLOAD_LENGTH : natural
	);
	port(
		clk              : in  std_logic;                      -- clk, rising-edge active
		mac              : in  byteVector(0 to 5);             -- our own MAC address, 1st byte at pos. 0
		ip               : in  byteVector(0 to 3);             -- our own IP address, 1st byte at pos. 0
		targetMac        : in  byteVector(0 to 5);             -- target MAC address. 1st byte at pos. 0
		targetIp         : in  byteVector(0 to 3);             -- target IP address. 1st byte at pos.0 
		arpNudp          : in  std_logic;                      -- 1: send ARP, 0: send UDP
		send             : in  std_logic;                      -- asserted to trigger sending a packet
		doneArp          : out std_logic;                      -- asserted when an ARP packet has been transmitted
		doneUdp          : out std_logic;                      -- asserted when an UDP packet has been transmitted
		fifoRd           : out std_logic;                      -- asserted to read a byte for transmit fifo
		fifoData         : in  std_logic_vector(7 downto 0);   -- data to be transmitted in UDP packet
		fifoEmpty        : in  std_logic;                      -- asserted when transmit fifo is empty
		rmiiTxStart      : out std_logic;                      -- asserted to start rmiiTx
		rmiiTxByteReq    : in  std_logic;                      -- asserted to request rmiiTxByte to send to PHY
		rmiiTxByteRdy    : out std_logic;                      -- asserted when rmiiTxByte is valud
		rmiiTxByte       : out std_logic_vector(7 downto 0);   -- data to send to PHY
		rmiiTxDone       : out std_logic                       -- asserted to signal end of transmit to PHY
	);
end txCtl;


architecture rtl of txCtl is

	type stateType is (
		S_IDLE,
		S_PREAMBLE,
		S_DEST_MAC,
		S_SRC_MAC,
		S_ARP_HEADER,
		S_ARP_SHA,
		S_ARP_SPA,
		S_ARP_THA,
		S_ARP_TPA,
		S_IP_HEADER,
		S_IP_CHECKSUM,
		S_SRC_IP,
		S_TARGET_IP,
		S_UDP_HEADER,
		S_UDP_DATA_REQ,
		S_UDP_GET_DATA,
		S_PADDING,
		S_CRC,
		S_INTERPACKET_GAP
	);

	constant ARP_HEADER : byteVector(9 downto 0) := (
		0 => x"08", -- \
		1 => x"06", -- / ethertype (ARP)
		2 => x"00", -- \
		3 => x"01", -- / Hardware type (1 for ethernet)
		4 => x"08", -- \
		5 => x"00", -- / Protocol type (0x0800 for IPv4)
		6 => x"06", -- > Hardware address length (6 for ethernet)
		7 => x"04", -- > Protocol address length (4 for IPv4)
		8 => x"00", -- \
		9 => x"02"  -- / Operation (1 for reply)
	);

	constant IP_HEADER : byteVector(11 downto 0) := (
		0  => x"08", -- \
		1  => x"00", -- / ethertype (IPv4)
		2  => x"45", -- > version/IHL
		3  => x"00", -- > DSCP/ECN
		4  => x"00", -- \
		5  => x"00", -- / total length (to be replaced with actual packet length)
		6  => x"00", -- \
		7  => x"00", -- / ID
		8  => x"00", -- \
		9  => x"00", -- / flags/fragment offset
		10 => x"80", -- > TTL
		11 => x"11"  -- > Protocol (UDP)
	);

	constant UDP_HEADER : byteVector(7 downto 0) := (
		0 => x"dd", -- \
		1 => x"d5", -- / source port (56789)
		2 => x"dd", -- \
		3 => x"d5", -- / destination port (56789)
		4 => x"00", -- \
		5 => x"00", -- / length (incl. UDP header), to be replaced with actual UDP packet length
		6 => x"00", -- \
		7 => x"00"  -- / UDP checksum
	);

	signal stateReg         : stateType := S_IDLE;
	signal doneArpReg       : std_logic := '0';
	signal doneUdpReg       : std_logic := '0';
	signal fifoRdReg        : std_logic := '0';
	signal rmiiTxStartReg   : std_logic := '0';
	signal rmiiTxByteRdyReg : std_logic := '0';
	signal rmiiTxByteReg    : std_logic_vector(7 downto 0) := x"00";
	signal rmiiTxDoneReg    : std_logic := '0';
	signal crcClearReg      : std_logic := '0';
	signal crcEnableReg     : std_logic := '0';
	signal crc              : std_logic_vector(31 downto 0);
	signal counterReg       : unsigned(9 downto 0);
	signal ipCksumClrReg    : std_logic := '0';
	signal ipCksumEnableReg : std_logic := '0';
	signal checksum         : std_logic_vector(15 downto 0);
	signal ipCksumDinReg    : std_logic_vector(7 downto 0) := x"00";

	signal udpPayloadLength : unsigned(15 downto 0);
	signal ipLength         : unsigned(15 downto 0);
	signal udpLength        : unsigned(15 downto 0);

begin

	-- Outputs
	doneArp <= doneArpReg;
	doneUdp <= doneUdpReg;
	fifoRd <= fifoRdReg;
	rmiiTxStart <= rmiiTxStartReg;
	rmiiTxByteRdy <= rmiiTxByteRdyReg;
	rmiiTxByte <= rmiiTxByteReg;
	rmiiTxDone <= rmiiTxDoneReg;

	-- IP checksum
	i_ipChecksum : entity netitf_lib.ipChecksum
		port map(
			clk      => clk,
			clr      => ipCksumClrReg,
			enable   => ipCksumEnableReg,
			din      => ipCksumDinReg,
			checksum => checksum
		);

	-- pseudo-constants (should be simplified by synthesizer when udpPayloadLength is a constant)
	udpPayloadLength <= to_unsigned(UDP_PAYLOAD_LENGTH, udpPayloadLength'length);
	ipLength <= udpPayloadLength + 28;
	udpLength <= udpPayLoadLength + 8;

	-- crc module
	i_crc32 : entity netitf_lib.crc32
		port map(
			clk    => clk,
			clear  => crcClearReg,
			enable => crcEnableReg,
			data   => rmiiTxByteReg,
			crc    => crc,
			crcErr => open
		);

	-- FSM
	p_fsm : process(clk)
	begin
		if rising_edge(clk) then

			-- default
			doneArpReg <= '0';
			doneUdpReg <= '0';
			rmiiTxStartReg <= '0';
			rmiiTxByteRdyReg <= '0';
			rmiiTxDoneReg <= '0';
			crcClearReg <= '0';
			crcEnableReg <= '0';
			fifoRdReg <= '0';
			ipCksumClrReg <= '0';
			ipCksumEnableReg <= '0';

			-- stateReg decoding
			case stateReg is

				when S_IDLE =>
					if send = '1' then
						stateReg <= S_PREAMBLE;
						rmiiTxStartReg <= '1';
						counterReg <= to_unsigned(0, counterReg'length);
					end if;

				when S_PREAMBLE =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteReg <= x"55";
						rmiiTxByteRdyReg <= '1';
						counterReg <= counterReg + 1;
						if counterReg = 7  then
							rmiiTxByteReg <= x"d5";
							stateReg <= S_DEST_MAC;
							counterReg <= to_unsigned(0, counterReg'length);
							crcClearReg <= '1';
							crcEnableReg <= '1';
							ipCksumClrReg <= '1';
							ipCksumEnableReg <= '1';
						end if;
					end if;

				when S_DEST_MAC =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						if arpNudp = '1' then
							rmiiTxByteReg <= x"ff"; -- bcast MAC
						else
							rmiiTxByteReg <= targetMac(to_integer(counterReg));
						end if;
						if counterReg < 4 then
							ipCksumEnableReg <= '1';
							ipCksumDinReg <= targetIp(to_integer(counterReg));
						end if;
						if counterReg = 5 then
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_SRC_MAC;
						end if;
					end if;

				when S_SRC_MAC =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						rmiiTxByteReg <= mac(to_integer(counterReg));
						if counterReg < 4 then
							ipCksumEnableReg <= '1';
							ipCksumDinReg <= ip(to_integer(counterReg));
						end if;
						if counterReg = 5 then
							counterReg <= to_unsigned(0, counterReg'length);
							if arpNudp = '1' then
								stateReg <= S_ARP_HEADER;
							else
								stateReg <= S_IP_HEADER;
							end if;
						else
						end if;
					end if;

				when S_ARP_HEADER =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						rmiiTxByteReg <= ARP_HEADER(to_integer(counterReg));
						if counterReg = 9 then
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_ARP_SHA;
						end if;
					end if;

				when S_ARP_SHA =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						rmiiTxByteReg <= mac(to_integer(counterReg));
						if counterReg = 5 then
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_ARP_SPA;
						end if;
					end if;

				when S_ARP_SPA =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						rmiiTxByteReg <= ip(to_integer(counterReg));
						if counterReg = 3 then
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_ARP_THA;
						end if;
					end if;

				when S_ARP_THA =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						rmiiTxByteReg <= mac(to_integer(counterReg));
						if counterReg = 5 then
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_ARP_TPA;
						end if;
					end if;

				when S_ARP_TPA =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						rmiiTxByteReg <= ip(to_integer(counterReg));
						if counterReg = 3 then
							counterReg <= to_unsigned(1, counterReg'length);
							stateReg <= S_PADDING;
						else
						end if;
					end if;

				when S_CRC =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						counterReg <= counterReg + 1;
						if counterReg = 0 then
							rmiiTxByteReg <= crc(31 downto 24);
						elsif counterReg = 1 then
							rmiiTxByteReg <= crc(23 downto 16);
						elsif counterReg = 2 then
							rmiiTxByteReg <= crc(15 downto 8);
						elsif counterReg = 3 then
							rmiiTxByteReg <= crc(7 downto 0);
							stateReg <= S_INTERPACKET_GAP;
							rmiiTxDoneReg <= '1';
						end if;
					end if;

				when S_INTERPACKET_GAP =>
					if counterReg = 96 then
						stateReg <= S_IDLE;
						if arpNudp = '1' then
							doneArpReg <= '1';
						else
							doneUdpReg <= '1';
						end if;
					else
						counterReg <= counterReg + 1;
					end if;

				when S_IP_HEADER =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						if counterReg = 4 then
							rmiiTxByteReg <= std_logic_vector(ipLength(15 downto 8));
							ipCksumDinReg <= std_logic_vector(ipLength(15 downto 8));
							ipCksumEnableReg <= '1';
						elsif counterReg = 5 then
							rmiiTxByteReg <= std_logic_vector(ipLength(7 downto 0));
							ipCksumDinReg <= std_logic_vector(ipLength(7 downto 0));
							ipCksumEnableReg <= '1';
						else
							rmiiTxByteReg <= IP_HEADER(to_integer(counterReg));
							if counterReg > 1 then
								ipCksumDinReg <= IP_HEADER(to_integer(counterReg));
								ipCksumEnableReg <= '1';
							end if;
						end if;
						if counterReg = 11 then
							stateReg <= S_IP_CHECKSUM;
							counterReg <= to_unsigned(0, counterReg'length);
						end if;
					end if;

				when S_IP_CHECKSUM =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						if counterReg = 0 then
							rmiiTxByteReg <= checksum(15 downto 8);
						else
							rmiiTxByteReg <= checksum(7 downto 0);
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_SRC_IP;
						end if;
					end if;

				when S_SRC_IP =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						rmiiTxByteReg <= ip(to_integer(counterReg));
						if counterReg = 3 then
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_TARGET_IP;
						end if;
					end if;

				when S_TARGET_IP =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						rmiiTxByteReg <= targetIp(to_integer(counterReg));
						if counterReg = 3 then
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_UDP_HEADER;
						end if;
					end if;

				when S_UDP_HEADER =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						if counterReg = 4 then
							rmiiTxByteReg <= std_logic_vector(udpLength(15 downto 8));
						elsif counterReg = 5 then
							rmiiTxByteReg <= std_logic_vector(udpLength(7 downto 0));
						else
							rmiiTxByteReg <= UDP_HEADER(to_integer(counterReg));
						end if;
						if counterReg = 7 then
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_UDP_DATA_REQ;
						end if;
					end if;

				when S_UDP_DATA_REQ =>
					fifoRdReg <= '1';
					stateReg <= S_UDP_GET_DATA;

				when S_UDP_GET_DATA =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						rmiiTxByteReg <= fifoData;
						if counterReg = udpPayloadLength - 1 then
							if counterReg < 18 then
								stateReg <= S_PADDING;
							else
								counterReg <= to_unsigned(0, counterReg'length);
								stateReg <= S_CRC;
							end if;
						else
							stateReg <= S_UDP_DATA_REQ;
						end if;
					end if;

				when S_PADDING =>
					if rmiiTxByteReq = '1' then
						rmiiTxByteRdyReg <= '1';
						rmiiTxByteReg <= x"00";
						crcEnableReg <= '1';
						counterReg <= counterReg + 1;
						if counterReg = 18 then
							counterReg <= to_unsigned(0, counterReg'length);
							stateReg <= S_CRC;
						end if;
					end if;

			end case;
		end if;
	end process;

end rtl;
