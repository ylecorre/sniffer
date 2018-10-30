--------------------------------------------------------------------------------
--
-- txArbitrator
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 10:44:02 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Controls the flow of packets between ARP and UDP: when an ARP request has
--   been received, the interface must answer with an ARP answer.
--   The ARP request is stored until the end of the (current) UDP packet
--   transmission. Then the ARP packet is sent. If an UDP packet was to be
--   transmitted during an ARP transmit, it is delayed until the transmitter
--   is available.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity txArbitrator is
	port(
		clk     : in  std_logic; -- clock, rising-edge active
		fifoLvl : in  std_logic; -- asserted when TX fifo reaches a given level
		arpReq  : in  std_logic; -- asserted when an ARP request has been received
		arpNudp : out std_logic; -- asserted to send an ARP packet, de-asserted for UDP packet
		send    : out std_logic; -- asserted to trigger sending a packet
		doneArp : in  std_logic; -- asserted when an UDP packet has been sent
		doneUdp : in  std_logic  -- asserted when an ARP packet has been sent
	);
end txArbitrator;


architecture rtl of txArbitrator is

	type stateType is (
		S_IDLE,
		S_UDP,
		S_ARP
	);

	signal stateReg       : stateType := S_IDLE;
	signal arpNudpReg     : std_logic := '0';
	signal sendReg        : std_logic := '0';
	signal arpPendingReg  : std_logic := '0';

begin

	arpNudp <= arpNudpReg;
	send <= sendReg;

	p_main : process(clk)
		variable fifoLevelV : unsigned(10 downto 0);
	begin
		if rising_edge(clk) then

			sendReg <= '0';
			if arpReq = '1' then
				arpPendingReg <= '1';
			end if;

			case stateReg is

				when S_IDLE =>
					if fifoLvl = '1' then
						arpNudpReg <= '0';
						sendReg <= '1';
						stateReg <= S_UDP;
					elsif arpPendingReg = '1' then
						arpNudpReg <= '1';
						sendReg <= '1';
						stateReg <= S_ARP;
					end if;

				when S_UDP =>
					if doneUdp = '1' then
						stateReg <= S_IDLE;
					end if;

				when S_ARP =>
					if doneArp = '1' then
						stateReg <= S_IDLE;
						arpPendingReg <= '0';
					end if;

			end case;
		end if;
	end process;

end rtl;
