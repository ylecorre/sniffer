--------------------------------------------------------------------------------
--
-- RX testbench
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.types_pkg.all;


entity rx_tb is
end rx_tb;


architecture bench of rx_tb is

  constant MAC_ADDRESS : byteVector(5 downto 0) := (
    0 => x"00",
    1 => x"10",
    2 => x"a4",
    3 => x"7b",
    4 => x"ea",
    5 => x"80"
  );

	signal rn         : std_logic;
	signal clk        : std_logic;
	signal rmiiRn     : std_logic;
	signal rmiiRxdEn  : std_logic;
	signal rmiiRxd    : std_logic_vector(1 downto 0);
	signal rmiiCrsIn  : std_logic;
	signal rmiiRefClk : std_logic;
	signal fifoRd     : std_logic;
	signal fifoRdData : std_logic_vector(7 downto 0);
	signal fifoEmpty  : std_logic;
	signal fifoFull   : std_logic;
	signal sendFrame  : std_logic;
	signal arpNudp    : std_logic;
	signal arpReq     : std_logic;
	signal ip         : byteVector(3 downto 0);
	signal senderMac  : byteVector(5 downto 0);
	signal senderIp   : byteVector(3 downto 0);

begin

	i_lan8720 : entity work.lan8720
		port map(
			rn         => rmiiRn,
			mdio       => open,
			mdc        => '0',
			txd        => "00",
			txen       => '0',
			rxd        => rmiiRxd,
			crs        => rmiiCrsIn,
			clkin      => rmiiRefClk,
			frameStart => sendFrame,
			loopback   => '0',
			arpNudp    => arpNudp,
			straps     => open
		);

	i_rmiiClk : entity work.rmiiClk
		port map(
			clk    => clk,
			refClk => rmiiRefClk
		);

	i_rx : entity work.rx
		generic map(
			FIFO_ADDR_WIDTH => 8
		)
		port map(
			clk        => clk,
			rmiiRn     => rmiiRn,
			rmiiRxdIn  => rmiiRxd,
			rmiiRxdEn  => rmiiRxdEn,
			rmiiCrsIn  => rmiiCrsIn,
			rmiiRefClk => rmiiRefClk,
			mac        => MAC_ADDRESS,
			ip         => ip,
			senderMac  => senderMac,
			senderIp   => senderIp,
			arpReq     => arpReq,
			fifoRd     => fifoRd,
			fifoRdData => fifoRdData,
			fifoEmpty  => fifoEmpty,
			fifoFull   => fifoFull
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

		procedure sendPacket(
			packetType : boolean -- false for udp, true for arp
		) is
		begin
			if packetType = false then
				arpNudp <= '0';
			else
				arpNudp <= '1';
			end if;
			sendFrame <= '1';
			wait until falling_edge(rmiiRefClk);
			sendFrame <= '0';
			wait until falling_edge(rmiiRefClk);
			wait for 10 us;
		end sendPacket;

		procedure sendUdp is
		begin
			sendPacket(false);
		end sendUdp;

		procedure sendArp is
		begin
			sendPacket(true);
		end sendArp;

		variable l : line;

	begin
		arpNudp <= '0';
		sendFrame <= '0';
		fifoRd <= '0';
		rn <= '0';
		wait for 10 ns;
		rn <= '1';
		wait until rising_edge(clk);

		wait for 140 us;

		sendArp;

		-- send an UDP packet with data
		sendUdp;

		-- download payload from FIFO
		while fifoEmpty = '0' loop
			fifoRd <= '1';
			wait until rising_edge(clk);
			fifoRd <= '0';
			wait until rising_edge(clk);
			write(l, string'("-- read data from FIFO: 0x"));
			hwrite(l, fifoRdData);
			report l.all severity NOTE;
			deallocate(l);
		end loop;
		fifoRd <= '0';
		wait until rising_edge(clk);

		rn <= '0';
		wait for 10 ns;
		wait;
	end process;

end bench;
