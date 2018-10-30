--------------------------------------------------------------------------------
--
-- rxCtl
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 10:22:16 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 16:28:25 +0200 (Wed, 28 May 2014) $
-- $Revision: 166 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Implements the decoding of the UDP/ARP RX packet:
--    - filter out incoming packet if no match on MAC address (nor broadcast)
--    - NO crc check (since it errors are unlikely and we don't want to spend
--      ressources to handle them)
--    - filter out incoming packet on IPv4 address (broadcast not supported)
--    - NO IP checksum
--    - filter out incoming packet on UDP port
--    - save UDP payload in receive FIFO
--    - memorize sender MAC/IP when receiving ARP request so they can be used in
--      the answer
--    - signals higher level layer that an ARP request has been received
--   No packet fragmentation is supported.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library netitf_lib;
use netitf_lib.types_pkg.all;


entity rxCtl is
	port(
		clk             : in  std_logic;                         -- clock, rising-edge active
		rmiiRxData      : in  std_logic_vector(7 downto 0);      -- byte receive from PHY
		rmiiRxDataValid : in  std_logic;                         -- asserted when rmiiRxData is valid
		rmiiFrameStart  : in  std_logic;                         -- asserted for 1st rmiiRxData of the frame
		rmiiFrameEnd    : in  std_logic;                         -- asserted after last rmiiRxData of the frame
		mac             : in  byteVector(0 to 5);                -- our own MAC address. 1st byte is at pos. 0
		ip              : in  byteVector(0 to 3);                -- our own IP address. 1st byte is at pos. 0
		udpPort         : in  byteVector(0 to 1);                -- UDP port. LSB is at pos. 0
		senderMac       : out byteVector(0 to 5);                --	MAC address of last ARP request received
		senderIp        : out byteVector(0 to 3);                -- IP address of the last ARP request received
		arpReq          : out std_logic;                         -- asserted when an ARP request is received
		fifoData        : out std_logic_vector(7 downto 0);      -- data to be written in receive fifo
		fifoWr          : out std_logic                          -- asserted to write fifoData in receive fifo
	);
end rxCtl;


architecture rtl of rxCtl is

	-- byte counter width. Note that this also limits the UDP payload (to 2048 with current value)
	constant COUNTERS_WIDTH : natural := 11;

	-- Don't change if you don't know what it is
	constant IPV4_ETHERTYPE : byteVector(1 downto 0) := (
		0 => x"08",
		1 => x"00"
	);

	-- Don't change if you don't know what it is
	constant ARP_ETHERTYPE : byteVector(1 downto 0) := (
		0 => x"08",
		1 => x"06"
	);

	-- Don't change if you don't know what it is
	constant ARP_HEADER : byteVector(7 downto 0) := (
		0 => x"00",
		1 => x"01",
		2 => x"08",
		3 => x"00",
		4 => x"06",
		5 => x"04",
		6 => x"00",
		7 => x"01"
	);

	type stateType is (
		S_IDLE,
		S_FILTER_MAC,
		S_FILTER_ETHERTYPE,
		S_UDP_DEST_PORT,
		S_UDP_LENGTH,
		S_UDP_PAYLOAD,
		S_ARP_REQUEST,
		S_SENDER_MAC,
		S_SENDER_IP,
		S_TARGET_MAC,
		S_TARGET_IP,
		S_DISCARD
	);

	signal stateReg       : stateType := S_IDLE;
	signal fifoDataReg    : std_logic_vector(7 downto 0) := x"00";
	signal fifoWrReg      : std_logic := '0';
	signal counterReg     : unsigned(COUNTERS_WIDTH - 1 downto 0) := to_unsigned(0, COUNTERS_WIDTH);
	signal macOkReg       : std_logic := '0';
	signal bcastOkReg     : std_logic := '0';
	signal ipOkReg        : std_logic := '0';
	signal ipv4OkReg      : std_logic := '0';
	signal arpOkReg       : std_logic := '0';
	signal payloadLength  : unsigned(COUNTERS_WIDTH - 1 downto 0) := to_unsigned(0, COUNTERS_WIDTH);
	signal senderMacReg   : byteVector(0 to 5) := (x"00", x"00", x"00", x"00", x"00", x"00");
	signal senderIpReg    : byteVector(0 to 3) := (x"00", x"00", x"00", x"00");
	signal arpReqReg      : std_logic := '0';

begin

	fifoData <= fifoDataReg;
	fifoWr <= fifoWrReg;
	senderMac <= senderMacReg;
	senderIp <= senderIpReg;
	arpReq <= arpReqReg;

	p_main : process(clk)
	begin
		if rising_edge(clk) then

			-- default
			fifoWrReg <= '0';
			arpReqReg <= '0';

			-- state decoding
			case stateReg is

				when S_IDLE =>
					macOkReg <= '1';
					bcastOkReg <= '1';
					ipOkReg <= '0';
					ipv4OkReg <= '1';
					arpOkReg <= '1';
					counterReg <= to_unsigned(0, counterReg'length);
					if rmiiFrameStart = '1' then
						stateReg <= S_FILTER_MAC;
					end if;

				when S_FILTER_MAC =>
					if rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg < 6 then
							if rmiiRxData = mac(to_integer(counterReg)) and macOkReg = '1' then
								macOkReg <= '1';
							else
								macOkReg <= '0';
							end if;
							if rmiiRxData = x"ff" and bcastOkReg = '1' then
								bcastOkReg <= '1';
							else
								bcastOkReg <= '0';
							end if;
						else
							if macOkReg = '1' or bcastOkReg = '1' then
								stateReg <= S_FILTER_ETHERTYPE;
							else
								stateReg <= S_DISCARD;
							end if;
						end if;
					end if;

				when S_FILTER_ETHERTYPE =>
					if rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg = 12 or counterReg = 13 then
							if rmiiRxData = IPV4_ETHERTYPE(to_integer(counterReg) - 12) and ipv4OkReg = '1' then
								ipv4OkReg <= '1';
							else
								ipv4OkReg <= '0';
							end if;
							if rmiiRxData = ARP_ETHERTYPE(to_integer(counterReg) - 12) and arpOkReg = '1' then
								arpOkReg <= '1';
							else
								arpOkReg <= '0';
							end if;
						elsif counterReg = 14 then
							if ipv4OkReg = '1' then
								stateReg <= S_UDP_DEST_PORT;
							elsif arpOkReg = '1' then
								if rmiiRxData = ARP_HEADER(0) then
									stateReg <= S_ARP_REQUEST;
									counterReg <= to_unsigned(1, counterReg'length);
								else
									stateReg <= S_DISCARD;
								end if;
							else
								stateReg <= S_DISCARD;
							end if;
						end if;
					end if;

				when S_UDP_DEST_PORT =>
					if rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg = 36 and rmiiRxData /= udpPort(0) then
							stateReg <= S_DISCARD;
						elsif counterReg = 37 then
							if rmiiRxData /= udpPort(1) then
								stateReg <= S_DISCARD;
							else
								stateReg <= S_UDP_LENGTH;
							end if;
						end if;
					end if;

				when S_UDP_LENGTH =>
					if rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg = 38 then
							payloadLength(COUNTERS_WIDTH - 1 downto 8) <= unsigned(rmiiRxData(COUNTERS_WIDTH - 9 downto 0));
						elsif counterReg = 39 then
							payloadLength <= (payloadLength(COUNTERS_WIDTH - 1 downto 8) & unsigned(rmiiRxData)) - 8;
						elsif counterReg = 42 then
							stateReg <= S_UDP_PAYLOAD;
							counterReg <= to_unsigned(1, counterReg'length);
							fifoWrReg <= '1';
							fifoDataReg <= rmiiRxData;
						end if;
					end if;

				when S_UDP_PAYLOAD =>
					if rmiiFrameEnd = '1' then
							stateReg <= S_IDLE;
					elsif rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg < payloadLength then
							fifoWrReg <= '1';
							fifoDataReg <= rmiiRxData;
						else
							stateReg <= S_IDLE;
						end if;
					end if;

				when S_ARP_REQUEST =>
					if rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg < 8 then
							if rmiiRxData = ARP_HEADER(to_integer(counterReg)) and arpOkReg = '1' then
								arpOkReg <= '1';
							else
								arpOkReg <= '0';
							end if;
						else
							if arpOkReg = '1' then
								stateReg <= S_SENDER_MAC;
								senderMacReg(0) <= rmiiRxData;
								counterReg <= to_unsigned(1, counterReg'length);
							else
								stateReg <= S_DISCARD;
							end if;
						end if;
					end if;

				when S_SENDER_MAC =>
					if rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg < 6 then
							senderMacReg(to_integer(counterReg)) <= rmiiRxData;
						else
							stateReg <= S_SENDER_IP;
							senderIpReg(0) <= rmiiRxData;
							counterReg <= to_unsigned(1, counterReg'length);
						end if;
					end if;

				when S_SENDER_IP =>
					if rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg < 4 then
							senderIpReg(to_integer(counterReg)) <= rmiiRxData;
						else
							stateReg <= S_TARGET_MAC;
							macOkReg <= '1';
							counterReg <= to_unsigned(1, counterReg'length);
						end if;
					end if;

				when S_TARGET_MAC =>
					if rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg = 6 then
							counterReg <= to_unsigned(1, counterReg'length);
							if rmiiRxData = ip(0) then
								ipOkReg <= '1';
								stateReg <= S_TARGET_IP;
							else
								stateReg <= S_DISCARD;
							end if;
						end if;
					end if;

				when S_TARGET_IP =>
					if rmiiFrameEnd = '1' then
						stateReg <= S_IDLE;
						if ipOkReg = '1' then
							arpReqReg <= '1';
						end if;
					elsif rmiiRxDataValid = '1' then
						counterReg <= counterReg + 1;
						if counterReg < 4 and (rmiiRxData /= ip(to_integer(counterReg))) then
							ipOkReg <= '0';
						end if;
					end if;

				when S_DISCARD =>
					if rmiiFrameEnd = '1' then
						stateReg <= S_IDLE;
					end if;

			end case;

		end if;
	end process;

end rtl;
