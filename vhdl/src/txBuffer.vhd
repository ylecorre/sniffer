--------------------------------------------------------------------------------
--
-- TX buffer
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity txBuffer is
	generic(
		DEPTH : natural := 8
	);
	port(
		clk            : in  std_logic;
		txByte         : out std_logic_vector(7 downto 0);
		txByteReq      : in  std_logic;
		txByteRdy      : out std_logic;
		txStart        : out std_logic;
		txDone         : out std_logic;
		load           : in  std_logic;
		loadDone       : in  std_logic;
		send           : in  std_logic;
		txRunning      : out std_logic;
		txLoaded       : out std_logic;
		uartByte       : in  std_logic_vector(7 downto 0);
		uartByteWr     : in  std_logic
	);
end txBuffer;


architecture rtl of txBuffer is

	type byteArrayType is array(natural range <>) of std_logic_vector(7 downto 0);
	type stateType is (
		S_IDLE, S_WRITE, S_SEND, S_SEND_BYTE
	);

	signal state             : stateType := S_IDLE;
	signal addr              : integer range 0 to DEPTH - 1 := 0;
	signal maxAddr           : integer range 0 to DEPTH - 1 := 0;
	signal txByteReg         : std_logic_vector(7 downto 0) := x"00";
	signal txByteRdyReg      : std_logic := '0';
	signal txStartReg        : std_logic := '0';
	signal txDoneReg         : std_logic := '0';
	signal txRunningReg      : std_logic := '0';
	signal txLoadedReg       : std_logic := '0';

begin

	txByte <=txByteReg;
	txByteRdy <= txByteRdyReg;
	txStart <= txStartReg;
	txDone <= txDoneReg;
	txRunning <= txRunningReg;
	txLoaded <= txLoadedReg;

	p_main : process(clk)
		variable byteArray : byteArrayType(DEPTH - 1 downto 0);
	begin
		if rising_edge(clk) then

			-- defaults
			txStartReg <= '0';
			txByteRdyReg <= '0';
			txDoneReg <= '0';
			txRunningReg <= '0';

			-- state decoding
			case state is

				when S_IDLE =>
					addr <= 0;
					if load = '1' then
						state <= S_WRITE;
					elsif send = '1' then
						state <= S_SEND;
					end if;

				when S_WRITE =>
					if uartByteWr = '1' then
						byteArray(addr) := uartByte;
						addr <= addr + 1;
					end if;
					if loadDone = '1' then
						maxAddr <= addr;
						txLoadedReg <= '1';
						state <= S_IDLE;
					end if;

				when S_SEND =>
					addr <= 0;
					txLoadedReg <= '0';
					txStartReg <= '1';
					state <= S_SEND_BYTE;

				when S_SEND_BYTE =>
					txRunningReg <= '1';
					if txByteReq = '1' then
						txByteReg <= byteArray(addr);
						txByteRdyReg <= '1';
						addr <= addr + 1;
					end if;					
					if addr = maxAddr then
						state <= S_IDLE;
						txDoneReg <= '1';
					end if;

			end case;
		end if;
	end process;

end rtl;
