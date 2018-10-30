--------------------------------------------------------------------------------
--
-- lan8720
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 11:55:41 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 16:28:25 +0200 (Wed, 28 May 2014) $
-- $Revision: 166 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Implements a simple simulation model of LAN8720A. The model has the following
--   capabilities:
--   - emulates reset phase with strap configuration
--   - emulates loopback mode
--   - dump all received packets (throught the RMII TX interface) to a file
--   - dump all received sent packets (through the RMII RX interface) to a file
--   - emulates the reception of a packet (from network cable through RMII RX)
--  SMI support is minimal (no actual emulation of configuration registers)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library netitf_lib;
use netitf_lib.pcap_pkg.all;
use netitf_lib.packet_pkg.all;
use netitf_lib.rmii_pkg.all;


entity lan8720 is
	generic(
		DUMP_FILE_NAME : string := "dump.pcap"             -- name of the file where packet dumps are written
	);
	port(
		rn         : in    std_logic;                      -- \
		mdio       : inout std_logic;                      -- |
		mdc        : in    std_logic;                      -- |
		txd        : in    std_logic_vector(1 downto 0);   -- |
		txen       : in    std_logic;                      -- | see LAN8720A datasheet
		rxd        : inout std_logic_vector(1 downto 0);   -- |
		crs        : inout std_logic;                      -- |
		clkin      : in    std_logic;											 -- /
		packet     : in    packetSignalType;               -- packet to be received by the PHY
		frameStart : in    std_logic;                      -- asserted when the packet is to be received by the PHY
		loopback   : in    std_logic;                      -- asserted to enable loopback mode
		straps     : out   std_logic_vector(2 downto 0)    -- straps values (as decoded by LAN8720A during reset)
	);
end lan8720;


architecture bhv of lan8720 is

	signal strapsReg    : std_logic_vector(2 downto 0) := "UUU";
	signal crsWire      : std_logic := 'H';
	signal rxdWire      : std_logic_vector(1 downto 0) := "HH";
	signal txData       : std_logic_vector(7 downto 0);

	shared variable pcapFile : pcapFileType;

begin

	straps <= strapsReg;
	mdio <= 'L';

	p_straps : process(rn)
	begin
		if rising_edge(rn) then
			strapsReg <= To_X01(crs & rxd);
		end if;
	end process;

	rxd <= "HH" when rn = '0' else
	       txd when loopback = '1' else
	       rxdWire;
	crs <= 'H' when rn = '0' else 
	       txen when loopback = '1' else
	       crsWire;

  ------------------------------------------------------------------------------
  -- pcap file initialization
  ------------------------------------------------------------------------------
	p_pcap : process
	begin
		pcapFile.create(DUMP_FILE_NAME);
		wait;
	end process;

  ------------------------------------------------------------------------------
  -- receive path
  ------------------------------------------------------------------------------
	p_rx : process
		variable etherPacket : etherPacketType;
		variable l           : line;
	begin
		rxdWire <= "00";
		crsWire <= '0';
		while true loop
			wait until frameStart = '1';
			signal2packet(etherPacket, packet);
			pcapFile.dump(etherPacket);
			rmiiReceive(clkin, rxdWire, crsWire, etherPacket);
			write(l, string'("PHY::RX:"));
			write(l, etherPacket);
			report l.all severity NOTE;
			deallocate(l);
			etherPacket.deallocate;
		end loop;
	end process;

  ------------------------------------------------------------------------------
  -- transmit path
  ------------------------------------------------------------------------------
	p_tx : process
		variable l            : line;
		variable etherPacket  : etherPacketType;
	begin
		rmiiTransmit(clkin, txen, txd, etherPacket);
		pcapFile.dump(etherPacket);
		write(l, string'("PHY::TX:"));
		write(l, etherPacket);
		if etherPacket.checkCrc = true then
			write(l, string'(" [CRC OK]"));
		else
			write(l, string'(" [CRC ERROR]"));
		end if;
		report l.all severity NOTE;
		deallocate(l);
		etherPacket.deallocate;
	end process;

  ------------------------------------------------------------------------------
  -- serial management interface
  ------------------------------------------------------------------------------
	p_smi : process
		type regsType is array(31 downto 0) of std_logic_vector(15 downto 0);
		variable regs     : regsType := (others => x"0000");
		variable rwV      : std_logic_vector(1 downto 0);
		variable phyAddrV : std_logic_vector(4 downto 0);
		variable regAddrV : std_logic_vector(4 downto 0);
		variable dataV    : std_logic_vector(15 downto 0);
		variable l        : line;
	begin
		mdio <= 'Z';
		-- preamble
		for i in 0 to 15 loop
			wait until rising_edge(mdc) and mdio = '1';
		end loop;
		-- start of frame
		wait until rising_edge(mdc) and mdio = '0';
		wait until rising_edge(mdc) and mdio = '1';
		-- read/write symbol
		wait until rising_edge(mdc);
		rwV(1) := mdio;
		wait until rising_edge(mdc);
		rwV(0) := mdio;
		-- phyAddr
		for i in 4 downto 0 loop
			wait until rising_edge(mdc);
			phyAddrV(i) := mdio;
		end loop;
		-- regAddr
		for i in 4 downto 0 loop
			wait until rising_edge(mdc);
			regAddrV(i) := mdio;
		end loop;
		-- turnaround
		if rwV = "01" then
			wait until falling_edge(mdc);
			if phyAddrV = "00001" then
				mdio <= '0';
			end if;
			-- read
			wait until falling_edge(mdc);
			-- data
			for i in 15 downto 0 loop
				if phyAddrV = "00001" then
					mdio <= regs(to_integer(unsigned(regAddrV)))(i);
				end if;
				wait until falling_edge(mdc);
			end loop;
		elsif rwV = "10" then
			wait until rising_edge(mdc);
			-- write
			wait until rising_edge(mdc);
			-- data
			for i in 15 downto 0 loop
				wait until rising_edge(mdc);
				dataV(i) := mdio;
			end loop;
			if phyAddrV = "00001" then
				regs(to_integer(unsigned(regAddrV))) := dataV;
			end if;
		end if;
		wait until rising_edge(mdc);
	end process;

end bhv;
