--------------------------------------------------------------------------------
--
-- sniffer controller
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity snifferCtl is
	port(
		clk            : in  std_logic;
		capture        : in  std_logic;
		frameTooLong   : out std_logic;
		captureRunning : out std_logic;
		frameRdy       : out std_logic;
		rmiiByteValid  : in  std_logic;
		rmiiFrameStart : in  std_logic;
		rmiiFrameEnd   : in  std_logic;
		rmiiTxByteReq  : in  std_logic;
		rmiiTxByteRdy  : out std_logic;
		rxFifoWrite    : out std_logic;
		rxFifoFull     : in  std_logic;
		txFifoRead     : out std_logic
	);
end snifferCtl;


architecture rtl of snifferCtl is

	type uartStateType is (S_UART_IDLE, S_UART_WAIT_RDY);
	type ctlStateType is (S_CTL_IDLE, S_CTL_WAIT_FRAME_START, S_CTL_CAPTURE);

	signal rxFifoWriteReg      : std_logic := '0';
	signal frameTooLongReg   : std_logic := '0';
	signal ctlState          : ctlStateType := S_CTL_IDLE;
	signal captureRunningReg : std_logic := '0';
	signal frameRdyReg       : std_logic := '0';

begin

	rxFifoWrite <= rxFifoWriteReg;
	frameTooLong <= frameTooLongReg;
	frameRdy <= frameRdyReg;
	captureRunning <= captureRunningReg;

	p_rxCtl : process(clk)
	begin
		if rising_edge(clk) then
			case ctlState is

				when S_CTL_IDLE =>
					captureRunningReg <= '0';
					if capture = '1' then
						captureRunningReg <= '1';
						frameRdyReg <= '0';
						ctlState <= S_CTL_WAIT_FRAME_START;
					end if;
	
				when S_CTL_WAIT_FRAME_START =>
					frameTooLongReg <= '0';
					if rmiiFrameStart = '1' then
						ctlState <= S_CTL_CAPTURE;
					end if;

				when S_CTL_CAPTURE =>
					if rmiiByteValid = '1' and rxFifoFull = '0' then
						rxFifoWriteReg <= '1';
					else
						rxFifoWriteReg <= '0';
					end if;
					if rmiiFrameEnd = '1'then
						ctlState <= S_CTL_IDLE;
						if rxFifoFull = '1' then
							frameTooLongReg <= '1';
						end if;
						frameRdyReg <= '1';
					end if;

			end case;
		end if;
	end process;

	txFifoRead <= rmiiTxByteReq;

	p_txCtl : process(clk)
	begin
		if rising_edge(clk) then
			-- no delay on fifo read
			rmiiTxByteRdy <= rmiiTxByteReq;
		end if;
	end process;

end rtl;
