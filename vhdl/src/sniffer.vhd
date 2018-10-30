--------------------------------------------------------------------------------
--
-- sniffer
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sniffer is
	port(
		clk        : in    std_logic;
		uartRx     : in    std_logic;
		uartTx     : out   std_logic;
		rmiiResetN : out   std_logic;
		rmiiMdio   : inout std_logic;
		rmiiMdc    : out   std_logic;
		rmiiTxd    : out   std_logic_vector(1 downto 0);
		rmiiTxen   : out   std_logic;
		rmiiRxd    : inout std_logic_vector(1 downto 0);
		rmiiCrs    : inout std_logic;
		rmiiClk    : out   std_logic
	);
end sniffer;


architecture rtl of sniffer is

	constant PHY_ADDR : std_logic_vector(4 downto 0) := "00001";

	signal rmiiRxdEn         : std_logic;
	signal rmiiByte          : std_logic_vector(7 downto 0);
	signal rmiiByteValid     : std_logic;
	signal rmiiFrameStart    : std_logic;
	signal rmiiFrameEnd      : std_logic;
	signal rmiiTxStart       : std_logic;
	signal rmiiTxByte        : std_logic_vector(7 downto 0);
	signal rmiiTxByteReq     : std_logic;
	signal rmiiTxByteRdy     : std_logic;
	signal rmiiTxFrameLength : unsigned(10 downto 0);
	signal uartRxByte        : std_logic_vector(7 downto 0);
	signal uartRxByteValid   : std_logic;
	signal uartTxByte        : std_logic_vector(7 downto 0);
	signal uartTxSend        : std_logic;
	signal uartTxRdy         : std_logic;
	signal uartByte          : std_logic_vector(7 downto 0);
	signal capture           : std_logic;
	signal captureRunning    : std_logic;
	signal captureTriggered  : std_logic;
	signal smiMdOut          : std_logic;
	signal smiMdEn           : std_logic;
	signal smiWdata          : std_logic_vector(15 downto 0);
	signal smiRdata          : std_logic_vector(15 downto 0);
	signal smiRegAddr        : std_logic_vector(4 downto 0);
	signal smiRnw            : std_logic;
	signal smiSend           : std_logic;
	signal smiDone           : std_logic;
	signal txDone            : std_logic;
	signal rxBufferDump      : std_logic;
	signal rxBufferRd        : std_logic;
	signal rxBufferData      : std_logic_vector(7 downto 0);
	signal rxBufferDataRdy   : std_logic;
	signal rxBufferLength    : unsigned(10 downto 0);
	signal rxBufferDumpDone  : std_logic;
	signal captureRdy        : std_logic;
	signal load              : std_logic;
	signal loaded            : std_logic;
	signal loadDone          : std_logic;
	signal send              : std_logic;
	signal txRunning         : std_logic;
	signal txBufferData      : std_logic_vector(7 downto 0);
	signal txBufferWr        : std_logic;
	signal crcStatus         : std_logic;

begin

	rmiiMdio <= smiMdOut when smiMdEn = '1' else 'Z';
	rmiiRxd <= "HH" when rmiiRxdEn = '1' else "ZZ";
	rmiiCrs <= 'H' when rmiiRxdEn = '1' else 'Z';

	i_smi : entity work.smi
		port map(
			clk     => clk,
			mdIn    => rmiiMdio,
			mdOut   => smiMdOut,
			mdEn    => smiMdEn,
			mdc     => rmiiMdc,
			phyAddr => PHY_ADDR,
			regAddr => smiRegAddr,
			wdata   => smiWdata,
			rdata   => smiRdata,
			send    => smiSend,
			rnw     => smiRnw,
			done    => smiDone
		);

	i_rmii : entity work.rmii
		port map(
			clk           => clk,
			rn            => rmiiResetN,
			txd           => rmiiTxd,
			txen          => rmiiTxen,
			rxdIn         => rmiiRxd,
			rxdEn         => rmiiRxdEn,
			crsIn         => rmiiCrs,
			refClk        => rmiiClk,
			rxData        => rmiiByte, 
			rxDataValid   => rmiiByteValid,
			frameStart    => rmiiFrameStart,
			frameEnd      => rmiiFrameEnd,
			txStart       => rmiiTxStart,
			txByte        => rmiiTxByte,
			txByteReq     => rmiiTxByteReq,
			txByteRdy     => rmiiTxByteRdy,
			txDone        => txDone
		);

	i_rxBuffer : entity work.rxBuffer
		generic map(
			DEPTH => 1600
		)
		port map(
			clk              => clk,
			rxData           => rmiiByte, 
			rxDataValid      => rmiiByteValid,
			frameStart       => rmiiFrameStart,
			frameEnd         => rmiiFrameEnd,
			capture          => capture,
			dump             => rxBufferDump,
			rd               => rxBufferRd,
			data             => rxBufferData,
			dataValid        => rxBufferDataRdy,
			dumpDone         =>	rxBufferDumpDone,
			captureRunning   => captureRunning,
			captureTriggered => captureTriggered,
			captureRdy       => captureRdy,
			length           => rxBufferLength,
			crcStatus        => crcStatus
		);

	i_txBuffer : entity work.txBuffer
		generic map(
			DEPTH => 256
		)
		port map(
			clk            => clk,
			txByte         => rmiiTxByte,
			txByteReq      => rmiiTxByteReq,
			txByteRdy      => rmiiTxByteRdy,
			txStart        => rmiiTxStart,
			txDone         => txDone,
			load           => load,
			loadDone       => loadDone,
			send           => send,
			txRunning      => txRunning,
			txLoaded       => loaded,
			uartByte       => txBufferData,
			uartByteWr     => txBufferWr
		);

	i_uartProtocl : entity work.uartProtocol
		port map(
			clk              => clk,
			uartRxByte       => uartRxByte,
			uartRxByteValid  => uartRxByteValid,
			uartTxByte       => uartTxByte,
			uartTxSend       => uartTxSend,
			uartTxRdy        => uartTxRdy,
			smiWdata         => smiWdata,
			smiRdata         => smiRdata,
			smiRegAddr       => smiRegAddr,
			smiRnw           => smiRnw,
			smiSend          => smiSend,
			smiDone          => smiDone,
			capture          => capture,
			captureRunning   => captureRunning,
			captureTriggered => captureTriggered,
			captureRdy       => captureRdy,
			rxBufferRd       => rxBufferRd,
			rxBufferDump     => rxBufferDump,
			rxBufferDumpDone => rxBufferDumpDone,
			rxBufferData     => rxBufferData,
			rxBufferDataRdy  => rxBufferDataRdy,
			rxBufferLength   => rxBufferLength,
			send             => send,
			txRunning        => txRunning,
			load             => load,
			loadDone         => loadDone,
			loaded           => loaded,
			txBufferData     => txBufferData,
			txBufferWr       => txBufferWr,
			crcStatus        => crcStatus
		);

	i_uart : entity work.uart
		port map(
			clk         => clk,
			rx          => uartRx,
			tx          => uartTx,
			rxEnable    => '1',
			rxData      => uartRxByte,
			rxDataValid => uartRxByteValid,
			txData      => uartTxByte,
			txSend      => uartTxSend,
			txRdy       => uartTxRdy
		);

end rtl;
