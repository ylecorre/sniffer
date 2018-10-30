--------------------------------------------------------------------------------
--
-- tx testbench
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types_pkg.all;


entity tx_tb is
end tx_tb;


architecture bench of tx_tb is

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

	constant UDP_PAYLOAD_LENGTH : unsigned(15 downto 0) := to_unsigned(4, 16);

	signal rn         : std_logic;
	signal clk        : std_logic;
	signal arpNudp    : std_logic;
	signal send       : std_logic;
	signal doneArp    : std_logic;
	signal doneUdp    : std_logic;
	signal rmiiRefClk : std_logic;
	signal rmiiTxd    : std_logic_vector(1 downto 0);
	signal rmiiTxen   : std_logic;
	signal rmiiRxd    : std_logic_vector(1 downto 0);
	signal rmiiCrs    : std_logic;
	signal rmiiMdio   : std_logic;
	signal fifoWr     : std_logic;
	signal fifoWrData : std_logic_vector(7 downto 0);
	signal fifoFull   : std_logic;
	signal targetMac  : byteVector(5 downto 0);
	signal targetIp   : byteVector(3 downto 0);

begin

	i_lan8720 : entity work.lan8720
		port map(
			rn         => rn,
			mdio       => rmiiMdio,
			mdc        => '0',
			txd        => rmiiTxd,
			txen       => rmiiTxen,
			rxd        => rmiiRxd,
			crs        => rmiiCrs,
			clkin      => rmiiRefClk,
			frameStart => '0',
			loopback   => '0',
			arpNudp    => '0',
			straps     => open
		);

	rmiiRxd <= "HH";
	rmiiCrs <= 'H';
	rmiiMdio <= '0';

	i_rmiiClk : entity work.rmiiClk
		port map(
			clk    => clk,
			refClk => rmiiRefClk
		);

	i_tx : entity work.tx
		port map(
			clk              => clk,
			mac              => MAC_ADDRESS,
			ip               => IP_ADDRESS,
			targetMac        => targetMac,
			targetIp         => targetIp,
			udpPayloadLength => UDP_PAYLOAD_LENGTH,
      arpNudp          => arpNudp,
      send             => send,
      doneArp          => doneArp,
      doneUdp          => doneUdp,
			fifoWr           => fifoWr,
			fifoWrData       => fifoWrData,
			fifoFull         => fifoFull,
      rmiiRefClk       => rmiiRefClk,
      rmiiTxd          => rmiiTxd,
      rmiiTxen         => rmiiTxen
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

	p_main : process
	begin
		rn <= '0';
		targetMac <= (x"ab", x"cd", x"ef", x"98", x"76", x"44");
		targetIp <= (x"01", x"00", x"a8", x"c0");
		arpNudp <= '0';
		send <= '0';
		wait for 10 ns;

		-- startup
		rn <= '1';
		wait until rising_edge(clk);

		-- send arp
		arpNudp <= '1';
		send <= '1';
		wait until rising_edge(clk);
		send <= '0';
		wait until rising_edge(clk);
 		wait until rising_edge(clk) and doneArp = '1';

		-- download payload in fifo
		for i in 0 to 7 loop
			fifoWr <= '1';
			fifoWrData <= std_logic_vector(to_unsigned(i + 128, 8));
			wait until rising_edge(clk);
			fifoWr <= '0';
			wait until rising_edge(clk);
		end loop;

		-- send udp
		arpNudp <= '0';
		send <= '1';
		wait until rising_edge(clk);
		send <= '0';
		wait until rising_edge(clk);
 		wait until rising_edge(clk) and doneUdp = '1';

		-- end
		wait for 5 ns;
		rn <= '0';
		wait for 10 ns;
		wait;

	end process;

end bench;
