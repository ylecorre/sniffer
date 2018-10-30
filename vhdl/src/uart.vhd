--------------------------------------------------------------------------------
--
-- UART (115200 Bauds, 8N1)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart is
	port(
		clk         : in  std_logic;                          -- 100 MHz clock
		rx          : in  std_logic;                          -- Uart RX wire
		tx          : out std_logic;                          -- Uart TX wire
		rxEnable    : in  std_logic;                          -- asserted to enable receiver
		rxData      : out std_logic_vector(7 downto 0);       -- received byte
		rxDataValid : out std_logic;                          -- asserted when rxData is valid
		txData      : in  std_logic_vector(7 downto 0);       -- data to send
		txSend      : in  std_logic;                          -- pulse to start transmit
		txRdy       : out std_logic                           -- asserted when transmitter is available
	);
end uart;


architecture rtl of uart is

	type rxStateType is (
		S_RX_IDLE, S_RX_DETECT_START, S_RX_BITSTART,
		S_RX_BIT7, S_RX_BIT6, S_RX_BIT5, S_RX_BIT4,
		S_RX_BIT3, S_RX_BIT2, S_RX_BIT1, S_RX_BIT0,
		S_RX_STOP
	);
	signal rxState : rxStateType := S_RX_IDLE;
	signal rxCounter          : unsigned(3 downto 0) := to_unsigned(0, 4);
	signal rxPrescalerCounter : unsigned(5 downto 0) := to_unsigned(0, 6);
	signal rxPrescalerEnable  : std_logic := '0';
	signal rxDgl              : std_logic_vector(1 downto 0) := "11";
	signal rxDataReg          : std_logic_vector(7 downto 0) := x"00";
	signal rxDataValidReg     : std_logic := '0';
	signal rxSampleTick       : std_logic := '0';

	type txStateType is (
		S_TX_IDLE, S_TX_START, S_TX_BIT0, S_TX_BIT1,
		S_TX_BIT2, S_TX_BIT3, S_TX_BIT4, S_TX_BIT5,
		S_TX_BIT6, S_TX_BIT7, S_TX_STOP
	);
	signal txState   : txStateType := S_TX_IDLE;
	signal txPrescalerCounter : unsigned(9 downto 0) := to_unsigned(0, 10);
	signal txPrescalerEnable  : std_logic := '0';
	signal txReg              : std_logic := '1';
	signal txTick             : std_logic := '0';
	signal txRdyReg           : std_logic := '0';

begin

  --------------------------------------------------------------------------------
 	-- RX
  --------------------------------------------------------------------------------
	rxData <= rxDataReg;
	rxDataValid <= rxDataValidReg;

	-- prescaler: generate 115200x16 from 100 MHz => divide by 54 (error is less than 0.5%)
	p_rx_prescaler : process(clk)
	begin
		if rising_edge(clk) then
			if (rxPrescalerEnable = '1') then
				if (rxPrescalerCounter = 53) then
					rxPrescalerCounter <= to_unsigned(0, rxPrescalerCounter'length);
					rxCounter <= rxCounter + 1; -- will wrap around at some point but it is expected
					if rxCounter = 10 then
						rxSampleTick <= '1';
					else
						rxSampleTick <= '0';
					end if;
				else
					rxPrescalerCounter <= rxPrescalerCounter + 1;
					rxSampleTick <= '0';
				end if;
			else
				rxPrescalerCounter <= to_unsigned(0, rxPrescalerCounter'length);
				rxCounter <= to_unsigneD(0, rxCounter'length);
				rxSampleTick <= '0';
			end if;
		end if;
	end process;

	-- rx deglitching
	p_rx_deglitch : process(clk)
	begin
		if rising_edge(clk) then
			rxDgl(1 downto 0) <= rxDgl(0) & rx;
		end if;
	end process;

	-- rx sampling FSM
	p_rx_sampling : process(clk)
	begin
		if rising_edge(clk) then
			case rxState is

				when S_RX_IDLE =>
					rxDataValidReg <= '0';
					if rxEnable = '1' then
						rxState <= S_RX_DETECT_START;
					end if;

				when S_RX_DETECT_START =>
					if rxDgl(1) = '0' then
						rxPrescalerEnable <= '1';
						rxState <= S_RX_BITSTART;
					end if;

				when S_RX_BITSTART =>
					if rxSampleTick = '1' then
						rxState <= S_RX_BIT0;
					end if;

				when S_RX_BIT0 =>
					if rxSampleTick = '1' then
						rxDataReg(0) <= rxDgl(1);
						rxState <= S_RX_BIT1;
					end if;

				when S_RX_BIT1 =>
					if rxSampleTick = '1' then
						rxDataReg(1) <= rxDgl(1);
						rxState <= S_RX_BIT2;
					end if;

				when S_RX_BIT2 =>
					if rxSampleTick = '1' then
						rxDataReg(2) <= rxDgl(1);
						rxState <= S_RX_BIT3;
					end if;

				when S_RX_BIT3 =>
					if rxSampleTick = '1' then
						rxDataReg(3) <= rxDgl(1);
						rxState <= S_RX_BIT4;
					end if;

				when S_RX_BIT4 =>
					if rxSampleTick = '1' then
						rxDataReg(4) <= rxDgl(1);
						rxState <= S_RX_BIT5;
					end if;

				when S_RX_BIT5 =>
					if rxSampleTick = '1' then
						rxDataReg(5) <= rxDgl(1);
						rxState <= S_RX_BIT6;
					end if;

				when S_RX_BIT6 =>
					if rxSampleTick = '1' then
						rxDataReg(6) <= rxDgl(1);
						rxState <= S_RX_BIT7;
					end if;

				when S_RX_BIT7 =>
					if rxSampleTick = '1' then
						rxDataReg(7) <= rxDgl(1);
						rxState <= S_RX_STOP;
						rxDataValidReg <= '1';
					end if;

				when S_RX_STOP =>
					rxDataValidReg <= '0';
					if rxDgl(1) = '1' then
						rxPrescalerEnable <= '0';
						rxState <= S_RX_IDLE;
					end if;

			end case;
		end if;
	end process;

  --------------------------------------------------------------------------------
 	-- TX
  --------------------------------------------------------------------------------
	tx <= txReg;
	txRdy <= txRdyReg;

	p_tx_prescaler : process(clk)
	begin
		if rising_edge(clk) then
			if txPrescalerEnable = '1' then
				if txPrescalerCounter = 867 then
					txTick <= '1';
					txPrescalerCounter <= to_unsigned(0, txPrescalerCounter'length);
				else
					txTick <= '0';
					txPrescalerCounter <= txPrescalerCounter + 1;
				end if;
			else
				txTick <= '0';
				txPrescalerCounter <= to_unsigned(0, txPrescalerCounter'length);
			end if;
		end if;
	end process;

	p_tx : process(clk)
	begin
		if rising_edge(clk) then
			case txState is

				when S_TX_IDLE =>
					txRdyReg <= '1';
					txReg <= '1';
					if txSend = '1' then
						txState <= S_TX_START;
						txRdyReg <= '0';
						txPrescalerEnable <= '1';
					end if;

				when S_TX_START =>
					txReg <= '0';
					if txTick = '1' then
						txState <= S_TX_BIT0;
					end if;

				when S_TX_BIT0 =>
					txReg <= txData(0);
					if txTick = '1' then
						txState <= S_TX_BIT1;
					end if;

				when S_TX_BIT1 =>
					txReg <= txData(1);
					if txTick = '1' then
						txState <= S_TX_BIT2;
					end if;

				when S_TX_BIT2 =>
					txReg <= txData(2);
					if txTick = '1' then
						txState <= S_TX_BIT3;
					end if;

				when S_TX_BIT3 =>
					txReg <= txData(3);
					if txTick = '1' then
						txState <= S_TX_BIT4;
					end if;

				when S_TX_BIT4 =>
					txReg <= txData(4);
					if txTick = '1' then
						txState <= S_TX_BIT5;
					end if;

				when S_TX_BIT5 =>
					txReg <= txData(5);
					if txTick = '1' then
						txState <= S_TX_BIT6;
					end if;

				when S_TX_BIT6 =>
					txReg <= txData(6);
					if txTick = '1' then
						txState <= S_TX_BIT7;
					end if;

				when S_TX_BIT7 =>
					txReg <= txDatA(7);
					if txTick = '1' then
						txState <= S_TX_STOP;
					end if;

				when S_TX_STOP =>
					txReg <= '1';
					if txTick = '1' then
						txState <= S_TX_IDLE;
						txPrescalerEnable <= '0';
					end if;

			end case;
		end if;
	end process;

end rtl;
