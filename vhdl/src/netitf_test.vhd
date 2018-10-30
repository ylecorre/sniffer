--------------------------------------------------------------------------------
--
-- NetItf performance test platform
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library netitf_lib;
use netitf_lib.types_pkg.all;


entity netitf_test is
	port(
		clk        : in    std_logic;
		rmiiMdio   : inout std_logic;
		rmiiMdc    : out   std_logic;
		rmiiRn     : out   std_logic;
		rmiiRxd    : inout std_logic_vector(1 downto 0);
		rmiiCrs    : inout std_logic;
		rmiiRefClk : out   std_logic;
		rmiiTxd    : out   std_logic_vector(1 downto 0);
		rmiiTxen   : out   std_logic
	);
end netitf_test;


architecture rtl of netitf_test is

  constant MAC_ADDRESS : byteVector(0 to 5) := (
    0 => x"00",
    1 => x"10",
    2 => x"a4",
    3 => x"7b",
    4 => x"ea",
    5 => x"80"
  );

  constant IP_ADDRESS : byteVector(0 to 3) := (
    0 => x"c0", -- 192
    1 => x"a8", -- 168
    2 => x"00", -- 0
    3 => x"2c"  -- 44
  );

	constant UDP_PORT : byteVector(0 to 1) := (
		0 => x"dd", -- 221 \
		1 => x"d5"  -- 213 / => 56789
	);

	constant UDP_PAYLOAD_LENGTH : natural := 64;

	signal rmiiRxdEn    : std_logic;
	signal rxFifoData   : std_logic_vector(7 downto 0);
	signal txFifoData   : std_logic_vector(7 downto 0);
	signal txFifoFull   : std_logic;
	signal txFifoWr : std_logic := '0';
	signal rxFifoFull   : std_logic;
	signal rxFifoEmpty  : std_logic;
	signal rxFifoRd     : std_logic;
	signal streamEnable : std_logic;
	signal streamFreq   : std_logic_vector(6 downto 0);

begin

  ------------------------------------------------------------------------------
	-- pads
  ------------------------------------------------------------------------------
	rmiiMdio <= 'H';
	rmiiMdc <= '0';
	rmiiRxd <= "HH" when rmiiRxdEn = '1' else "ZZ";
	rmiiCrs <= 'H' when rmiiRxdEn = '1' else 'Z';

  ------------------------------------------------------------------------------
	-- netitf
  ------------------------------------------------------------------------------
	i_netItf : entity netitf_lib.netItf
		generic map(
			UDP_PAYLOAD_LENGTH => UDP_PAYLOAD_LENGTH
		)
		port map(
			clk              => clk,
			mac              => MAC_ADDRESS,
			ip               => IP_ADDRESS,
			udpPort          => UDP_PORT,
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

  ------------------------------------------------------------------------------
	-- controller
  ------------------------------------------------------------------------------
	i_controller : entity netitf_lib.controller
		port map(
			clk          => clk,
			fifoData     => rxFifoData,
			fifoEmpty    => rxFifoEmpty,
			fifoRd       => rxFifoRd,
			streamEnable => streamEnable,
			streamFreq   => streamFreq
		);

  ------------------------------------------------------------------------------
	-- stream generator
  ------------------------------------------------------------------------------
	i_stream : entity netitf_lib.stream
		port map(
			clk     => clk,
			enable  => streamEnable,
			freq    => streamFreq,
			byte    => txFifoData,
			byteRdy => txFifoWr
		);

end rtl;
