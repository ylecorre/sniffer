--------------------------------------------------------------------------------
--
-- NetItf testbench
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;

use work.types_pkg.all;


entity netitf_tb is
end netitf_tb;


architecture bench of netitf_tb is

	signal clk              : std_logic;
  signal rmiiMdio         : std_logic;
	signal rmiiRn           : std_logic;
	signal rmiiRxd          : std_logic_vector(1 downto 0);
	signal rmiiRxdEn        : std_logic;
	signal rmiiCrs          : std_logic;
	signal rmiiRefClk       : std_logic;
	signal rmiiTxd          : std_logic_vector(1 downto 0);
	signal rmiiTxen         : std_logic;
	signal txFifoWr         : std_logic;
	signal txFifoData       : std_logic_vector(7 downto 0);
	signal txFifoFull       : std_logic;
	signal rxFifoRd         : std_logic;
	signal rxFifoData       : std_logic_vector(7 downto 0);
	signal rxFifoFull       : std_logic;
	signal rxFifoEmpty      : std_logic;

	signal rn        : std_logic;
	signal sendFrame : std_logic;
	signal loopback  : std_logic;
	signal arpNudp   : std_logic;

  constant MAC_ADDRESS : byteVector(5 downto 0) := (
    0 => x"00",
    1 => x"10",
    2 => x"a4",
    3 => x"7b",
    4 => x"ea",
    5 => x"80"
  );

	constant IP_ADDRESS : byteVector(3 downto 0) := (
    0 => x"c0",
    1 => x"a8",
    2 => x"00",
    3 => x"2c"
	);

	constant UDP_PAYLOAD_LENGTH : unsigned(15 downto 0) := to_unsigned(10, 16);

begin

  rmiiRxd <= "HH";
  rmiiCrs <= 'H';
  rmiiMdio <= '0';

	i_lan8720 : entity work.lan8720
		port map(
			rn         => rmiiRn,
			mdio       => rmiiMdio,
			mdc        => '0',
			txd        => rmiiTxd,
			txen       => rmiiTxen,
			rxd        => rmiiRxd,
			crs        => rmiiCrs,
			clkin      => rmiiRefClk,
			frameStart => sendFrame,
			loopback   => loopback,
			arpNudp    => arpNudp,
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

	i_netItf : entity work.netItf
		generic map(
			RX_FIFO_ADDR_WIDTH => 8,
			TX_FIFO_ADDR_WIDTH => 8
		)
		port map(
			clk              => clk,
			mac              => MAC_ADDRESS,
			ip               => IP_ADDRESS,
			udpPayloadLength => UDP_PAYLOAD_LENGTH,
			rmiiRn           => rmiiRn,
			rmiiRxdIn        => rmiiRxd,
			rmiiRxdEn        => rmiiRxdEn,
			rmiiCrsIn        => rmiiCrs,
			rmiiRefClk       => rmiiRefClk,
			rmiiTxd          => rmiiTxd,
			rmiiTxen         => rmiiTxen,
			txFifoWr         => txFifoWr,
			txFifoData       => txFifoData,
			txFifoFull       => txFifoFull,
			rxFifoRd         => rxFifoRd,
			rxFifoData       => rxFifoData,
			rxFifoFull       => rxFifoFull,
			rxFifoEmpty      => rxFifoEmpty
		);

	p_stimuli : process
	begin
		arpNudp <= '0';
		sendFrame <= '0';
		loopback <= '0';
		rn <= '0';
		wait for 10 ns;
		rn <= '1';
		wait for 130 us; -- reset delay for LAN8720A

		-- netif will receive an ARP request and reply with a gratuitous (!) ARP packet
		wait until rising_edge(rmiiRefClk);
		arpNudp <= '1';
		sendFrame <= '1';
		wait until rising_edge(rmiiRefClk);
		sendFrame <= '0';

		wait for 100 us;

		-- fill FIFO
		for i in 0 to 30 loop
			txFifoWr <= '1';
			txFifoData <= std_logic_vector(to_unsigned(i + 128, 8));
			wait until rising_edge(clk);
		end loop;
		txFifoWr <= '0';
		wait until rising_edge(clk);

		wait for 100 us;

		rn <= '0';
		wait for 10 ns;
		wait;
	end process;

end bench;
