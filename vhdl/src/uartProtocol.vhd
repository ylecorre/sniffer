--------------------------------------------------------------------------------
--
-- Uart Protocol
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uartProtocol is
	port(
		clk              : in  std_logic;
		uartRxByte       : in  std_logic_vector(7 downto 0);
		uartRxByteValid  : in  std_logic;
		uartTxByte       : out std_logic_vector(7 downto 0);
		uartTxSend       : out std_logic;
		uartTxRdy        : in  std_logic;
		smiWdata         : out std_logic_vector(15 downto 0);
		smiRdata         : in  std_logic_vector(15 downto 0);
		smiRegAddr       : out std_logic_vector(4 downto 0);
		smiRnw           : out std_logic;
		smiSend          : out std_logic;
		smiDone          : in  std_logic;
		capture          : out std_logic;
		captureRunning   : in  std_logic;
		captureTriggered : in  std_logic;
		captureRdy       : in  std_logic;
		rxBufferRd       : out std_logic;
		rxBufferDump     : out std_logic;
		rxBufferDumpDone : in  std_logic;
		rxBufferData     : in  std_logic_vector(7 downto 0);
		rxBufferDataRdy  : in  std_logic;
		rxBufferLength   : in  unsigned(10 downto 0);
		send             : out std_logic;
		txRunning        : in  std_logic;
		load             : out std_logic;
		loaded           : in  std_logic;
		loadDone         : out std_logic;
		txBufferData     : out std_logic_vector(7 downto 0);
		txBufferWr       : out std_logic;
		crcStatus        : in  std_logic
	);
end uartProtocol;


architecture rtl of uartProtocol is

	constant CMD_CAPTURE : std_logic_vector(7 downto 0) := x"fd";
	constant CMD_STATUS  : std_logic_vector(7 downto 0) := x"fe";
	constant CMD_SEND    : std_logic_vector(7 downto 0) := x"f8";
	constant CMD_READ    : std_logic_vector(7 downto 0) := x"f2";
	constant CMD_WRITE   : std_logic_vector(7 downto 0) := x"f4";
	constant CMD_TEST    : std_logic_vector(7 downto 0) := x"f0";

	type stateType is (
		S_IDLE, S_SMI_WR_MSB, S_SMI_WR_LSB,
		S_SMI_RD_SEND, S_SMI_RD_WAIT, S_SMI_RD_MSB, S_SMI_RD_MSB_WAIT, S_SMI_RD_LSB,
		S_SMI_RD_LSB_WAIT, S_SMI_RD_DONE,
		S_TEST, S_STATUS, S_WRITE, S_WRITE_WAIT_LENGTH, S_WRITE_WAIT_BYTE,
		S_READ, S_READ_REQ_BYTE, S_READ_WAIT_BYTE, S_READ_SEND_TX_BYTE, S_READ_WAIT_TX_BYTE,
		S_READ_LENGTH_MSB, S_READ_LENGTH_LSB, S_READ_LENGTH_LSB_WAIT
	);

	signal state     : stateType := S_IDLE;
	signal dumpDone  : std_logic := '0';
	signal length    : unsigned(7 downto 0) := to_unsigned(0, 8);
	signal maxLength : unsigned(7 downto 0) := to_unsigned(0, 8);

	signal smiRegAddrReg   : std_logic_vector(4 downto 0) := "00000";
	signal smiWdataReg     : std_logic_vector(15 downto 0) := x"0000";
	signal smiSendReg      : std_logic := '0';
	signal smiRnwReg       : std_logic := '0';
	signal uartTxByteReg   : std_logic_vector(7 downto 0) := x"00";
	signal uartTxSendReg   : std_logic := '0';
	signal captureReg      : std_logic := '0';
	signal rxBufferDumpReg : std_logic := '0';
	signal sendReg         : std_logic := '0';
	signal loadReg         : std_logic := '0';
	signal loadDoneReg     : std_logic := '0';
	signal txBufferDataReg : std_logic_vector(7 downto 0) := x"00";
	signal txBufferWrReg   : std_logic := '0';
	signal rxBufferRdReg   : std_logic := '0';

begin

	smiRegAddr <= smiRegAddrReg;
	smiWdata <= smiWdataReg;
	smiSend <= smiSendReg;
	smiRnw <= smiRnwReg;
	uartTxByte <= uartTxByteReg;
	uartTxSend <= uartTxSendReg;
	capture <= captureReg;
	rxBufferDump <= rxBufferDumpReg;
	send <= sendReg;
	load <= loadReg;
	txBufferData <= txBufferDataReg;
	txBufferWr <= txBufferWrReg;
	rxBufferRd <= rxBufferRdReg;
	loadDone <= loadDoneReg;

	p_main : process(clk)
	begin
		if rising_edge(clk) then

			------------------------------------------------------------------------
			-- Defaults
			------------------------------------------------------------------------
			captureReg <= '0';
			smiSendReg <= '0';
			uartTxSendReg <= '0';
			rxBufferDumpReg <= '0';
			sendReg <= '0';
			loadReg <= '0';
			loadDoneReg <= '0';
			txBufferWrReg <= '0';
			rxBufferRdReg <= '0';

			case state is

        ------------------------------------------------------------------------
				-- Decode opcode
        ------------------------------------------------------------------------
				when S_IDLE =>
					if uartRxByteValid = '1' then
						case uartRxByte is
							when CMD_CAPTURE =>
								captureReg <= '1';
							when CMD_STATUS =>
								state <= S_STATUS;
							when CMD_TEST =>
								state <= S_TEST;
							when CMD_READ =>
								state <= S_READ;
							when CMD_WRITE =>
								state <= S_WRITE;
							when CMD_SEND =>
								sendReg <= '1';
							when others =>
								smiRegAddrReg <= uartRxByte(4 downto 0);
								if uartRxByte(7) = '0' then
									state <= S_SMI_WR_MSB;
									smiRnwReg <= '0';
								else
									state <= S_SMI_RD_SEND;
									smiRnwReg <= '1';
								end if;
						end case;
					end if;

        ------------------------------------------------------------------------
				-- SMI write logic
        ------------------------------------------------------------------------
				when S_SMI_WR_MSB =>
					if uartRxByteValid = '1' then
						smiWdataReg(15 downto 8) <= uartRxByte;
						state <= S_SMI_WR_LSB;
					end if;

				when S_SMI_WR_LSB =>
					if uartRxByteValid = '1' then
						smiWdataReg(7 downto 0) <= uartRxByte;
						smiSendReg <= '1';
						smiRnwReg <= '0';
						state <= S_IDLE;
					end if;

        ------------------------------------------------------------------------
				-- SMI read logic
        ------------------------------------------------------------------------
				when S_SMI_RD_SEND =>
					smiSendReg <= '1';
					state <= S_SMI_RD_WAIT;

				when S_SMI_RD_WAIT =>
					if smiDone = '1' then
						state <= S_SMI_RD_MSB;
					end if;

				when S_SMI_RD_MSB =>
					uartTxByteReg <= smiRdata(15 downto 8);
					uartTxSendReg <= '1';
					state <= S_SMI_RD_MSB_WAIT;

				when S_SMI_RD_MSB_WAIT =>
					state <= S_SMI_RD_LSB;

				when S_SMI_RD_LSB =>
					if uartTxRdy = '1' then
						uartTxByteReg <= smiRdata(7 downto 0);
						uartTxSendReg <= '1';
						state <= S_SMI_RD_LSB_WAIT;
					end if;

				when S_SMI_RD_LSB_WAIT =>
					state <= S_SMI_RD_DONE;

				when S_SMI_RD_DONE =>
					if uartTxRdy = '1' then
						state <= S_IDLE;
					end if;

        ------------------------------------------------------------------------
				-- Status logic
        ------------------------------------------------------------------------
				when S_STATUS =>
					uartTxByteReg <= crcStatus & "00" & captureTriggered & loaded & txRunning & captureRunning & captureRdy;
					uartTxSendReg <= '1';
					state <= S_IDLE;

        ------------------------------------------------------------------------
				-- Read logic
        ------------------------------------------------------------------------
				when S_READ =>
					rxBufferDumpReg <= '1';
					uartTxByteReg <= "00000" & std_logic_vector(rxBufferLength(10 downto 8));
					uartTxSendReg <= '1';
					state <= S_READ_LENGTH_MSB;

				when S_READ_LENGTH_MSB =>
					state <= S_READ_LENGTH_LSB;

				when S_READ_LENGTH_LSB =>
					if uartTxRdy = '1' then
						uartTxByteReg <= std_logic_vector(rxBufferLength(7 downto 0));
						uartTxSendReg <= '1';
						state <= S_READ_LENGTH_LSB_WAIT;
					end if;

				when S_READ_LENGTH_LSB_WAIT =>
					state <= S_READ_REQ_BYTE;

				when S_READ_REQ_BYTE =>
					if uartTxRdy = '1' then
						rxBufferRdReg <= '1';
						state <= S_READ_WAIT_BYTE;
					end if;

				when S_READ_WAIT_BYTE =>
					dumpDone <= rxBufferDumpDone;
					if rxBufferDataRdy = '1' then
						uartTxByteReg <= rxBufferData;
						uartTxSendReg <= '1';
						state <= S_READ_SEND_TX_BYTE;
					end if;

				when S_READ_SEND_TX_BYTE =>
					state <= S_READ_WAIT_TX_BYTE;

				when S_READ_WAIT_TX_BYTE =>
					if uartTxRdy = '1' then
						if dumpDone = '1' then
							state <= S_IDLE;
						else
							state <= S_READ_REQ_BYTE;
						end if;
					end if;

        ------------------------------------------------------------------------
				-- Write logic
        ------------------------------------------------------------------------
				when S_WRITE =>
					loadReg <= '1';
					state <= S_WRITE_WAIT_LENGTH;

				when S_WRITE_WAIT_LENGTH =>
					length <= to_unsigned(0, length'length);
					if uartRxByteValid = '1' then
						maxLength <= unsigned(uartRxByte);
						state <= S_WRITE_WAIT_BYTE;
					end if;

				when S_WRITE_WAIT_BYTE =>
					if uartRxByteValid = '1' then
						length <= length + 1;
						txBufferDataReg <= uartRxByte;
						txBufferWrReg <= '1';
					end if;
					if length = maxLength then
						state <= S_IDLE;
						loadDoneReg <= '1';
					end if;

        ------------------------------------------------------------------------
				-- Test logic
        ------------------------------------------------------------------------
				when S_TEST =>
					uartTxByteReg <= x"a9";
					uartTxSendReg <= '1';
					state <= S_IDLE;

			end case;
		end if;
	end process;

end rtl;
