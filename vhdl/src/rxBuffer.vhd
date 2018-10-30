--------------------------------------------------------------------------------
--
-- RX buffer
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rxBuffer is
	generic(
		DEPTH : natural := 8
	);
	port(
		clk              : in  std_logic;
		rxData           : in  std_logic_vector(7 downto 0);
		rxDataValid      : in  std_logic;
		frameStart       : in  std_logic;
		frameEnd         : in  std_logic;
		capture          : in  std_logic;
		dump             : in  std_logic;
		rd               : in  std_logic;
		data             : out std_logic_vector(7 downto 0);
		dataValid        : out std_logic;
		dumpDone         : out std_logic;
		captureRunning   : out std_logic;
		captureTriggered : out std_logic;
		captureRdy       : out std_logic;
		length           : out unsigned(10 downto 0);
		crcStatus        : out std_logic
	);
end rxBuffer;


architecture rtl of rxBuffer is

	type byteArrayType is array(natural range <>) of std_logic_vector(7 downto 0);
	type stateType is (S_IDLE, S_WAIT_FRAME_START, S_WRITE_FRAME, S_CRC, S_DUMP);

	signal state               : stateType := S_IDLE;
	signal addr                : integer range 0 to DEPTH - 1 := 0;
	signal maxAddr             : integer range 0 to DEPTH - 1 := 0;
	signal crcClear            : std_logic := '0';
	signal crcEnable           : std_logic := '0';
	signal crc                 : std_logic_vector(31 downto 0);
	signal crcErr              : std_logic;
	signal dataReg             : std_logic_vector(7 downto 0) := x"00";
	signal dataValidReg        : std_logic := '0';
	signal dumpDoneReg         : std_logic := '0';
	signal captureRunningReg   : std_logic := '0';
	signal captureTriggeredReg : std_logic := '0';
	signal captureRdyReg       : std_logic := '0';
	signal crcStatusReg        : std_logic := '0';

begin

	data <= dataReg;
	dataValid <= dataValidReg;
	dumpDone <= dumpDoneReg;
	captureRunning <= captureRunningReg;
	captureTriggered <= captureTriggeredReg;
	captureRdy <= captureRdyReg;
	length <= to_unsigned(maxAddr, length'length);
	crcStatus <= crcStatusReg;

	i_crc32 : entity work.crc32
    port map(
      clk    => clk,
      clear  => crcClear,
      enable => crcEnable,
      data   => rxData,
      crc    => crc,
      crcErr => crcErr
    );

	p_main : process(clk)
		variable byteArray : byteArrayType(DEPTH - 1 downto 0);
	begin
		if rising_edge(clk) then

			-- defaults
			dataValidReg <= '0';
			dumpDoneReg <= '0';
			captureRunningReg <= '0';
			crcClear <= '0';
			crcEnable <= '0';

			-- state decoding
			case state is

				when S_IDLE =>
					captureTriggeredReg <= '0';
					if capture = '1' then
						state <= S_WAIT_FRAME_START;
					elsif dump = '1' then
						addr <= 0;
						state <= S_DUMP;
					end if;
	
				when S_WAIT_FRAME_START =>
					captureTriggeredReg <= '1';
					if frameStart = '1' then
						crcEnable <= '1';
						crcClear <= '1';
						state <= S_WRITE_FRAME;
						addr <= 0;
					end if;

				when S_WRITE_FRAME =>
					captureRunningReg <= '1';
					if rxDataValid = '1' then
						byteArray(addr) := rxData;
						addr <= addr + 1;	
						crcEnable <= '1';
					end if;
					if frameEnd = '1' then
						state <= S_CRC;
						maxAddr <= addr;
					end if;

				when S_CRC =>
					captureRdyReg <= '1';
					if crcErr = '1' then
						crcStatusReg <= '0';
					else
						crcStatusReg <= '1';
					end if;
					state <= S_IDLE;

				when S_DUMP =>
					captureRdyReg <= '0';
					if rd = '1' then
						dataReg <= byteArray(addr);
						addr <= addr + 1;
						dataValidReg <= '1';
						if addr = maxAddr - 1 then
							dumpDoneReg <= '1';
							state <= S_IDLE;
							crcStatusReg <= '0';
						end if;
					end if;

			end case;
		end if;
	end process;

end rtl;
