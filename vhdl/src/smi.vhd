--------------------------------------------------------------------------------
--
-- Serial management interface (SMI)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity smi is
	port(
		clk     : in  std_logic;
		mdIn    : in  std_logic;
		mdOut   : out std_logic;
		mdEn    : out std_logic;
		mdc     : out std_logic;
		phyAddr : in  std_logic_vector(4 downto 0); 
		regAddr : in  std_logic_vector(4 downto 0);
		wdata   : in  std_logic_vector(15 downto 0);
		rdata   : out std_logic_vector(15 downto 0);
		send    : in  std_logic;
		rnw     : in  std_logic;
		done    : out std_logic
	);
end smi;


architecture rtl of smi is

	constant WRITE_PREAMBLE : std_logic_vector(35 downto 0) := x"ffffffff5";
	constant READ_PREAMBLE  : std_logic_vector(35 downto 0) := x"ffffffff6";

	type stateType is (
		S_IDLE, S_PREAMBLE, S_PHY_ADDR, S_REG_ADDR, S_TURN_AROUND_0, S_TURN_AROUND_1, S_DATA, S_DONE
	);

	signal state           : stateType := S_IDLE;
	signal mdOutReg        : std_logic := '0';
	signal mdEnReg         : std_logic := '1';
	signal bitCounter      : unsigned(5 downto 0) := to_unsigned(0, 6);
	signal rdataReg        : std_logic_vector(15 downto 0) := x"0000";
	signal mdcRisingEdge   : std_logic := '0';
	signal mdcSamplingEdge : std_logic := '0';
	signal mdcCounter      : unsigned(5 downto 0) := to_unsigned(0, 6);
	signal mdcEnable       : std_logic := '0';
	signal doneReg         : std_logic := '0';
	signal mdcReg          : std_logic := '0';

begin

	mdOut <= mdOutReg;
	mdEn <= mdEnReg;
	mdc <= mdcReg;
	rdata <= rdataReg;
	done <= doneReg;

	p_mdc : process(clk)
	begin
		if rising_edge(clk) then
			if mdcEnable = '1' then
				if mdcCounter = 59 then
					mdcCounter <= to_unsigned(0, mdcCounter'length);
					mdcReg <= '0';
				else
					mdcSamplingEdge <= '0';
					mdcCounter <= mdcCounter + 1;
					mdcRisingEdge <= '0';
					if mdcCounter = 29 then
						mdcRisingEdge <= '1';
						mdcReg <= '1';
					elsif mdcCounter = 20 then
						mdcSamplingEdge <= '1';
					end if;
				end if;
			else
				mdcCounter <= to_unsigned(0, mdcCounter'length);
				mdcReg <= '0';
			end if;
		end if;
	end process;

	p_main : process(clk)
	begin
		if rising_edge(clk) then
			case state is

				when S_IDLE =>
					doneReg <= '0';
					mdcEnable <= '0';
					mdEnReg <= '0';
					mdOutReg <= '0';
					if send = '1' then
						bitCounter <= to_unsigned(WRITE_PREAMBLE'length - 1, bitCounter'length);
						state <= S_PREAMBLE;
					end if;

				when S_PREAMBLE =>
					mdcEnable <= '1';
					mdEnReg <= '1';
					if rnw = '0' then
						mdOutReg <= WRITE_PREAMBLE(to_integer(bitCounter));
					else
						mdOutReg <= READ_PREAMBLE(to_integer(bitCounter));
					end if;
					if mdcRisingEdge = '1' then
						if bitCounter = 0 then
							bitCounter <= to_unsigned(4, bitCounter'length);
							state <= S_PHY_ADDR;
						else
							bitCounter <= bitCounter - 1;
						end if;
					end if;

				when S_PHY_ADDR =>
					mdOutReg <= phyAddr(to_integer(bitCounter));
					if mdcRisingEdge = '1' then
						if bitCounter = 0 then
							bitCounter <= to_unsigned(4, bitCounter'length);
							state <= S_REG_ADDR;
						else
							bitCounter <= bitCounter - 1;
						end if;
					end if;

				when S_REG_ADDR =>
					mdOutReg <= regAddr(to_integer(bitCounter));
					if mdcRisingEdge = '1' then
						if bitCounter = 0 then
							bitCounter <= to_unsigned(4, bitCounter'length);
							state <= S_TURN_AROUND_0;
						else
							bitCounter <= bitCounter - 1;
						end if;
					end if;

				when S_TURN_AROUND_0 =>
					if rnw = '1' then
						mdEnReg <= '0';
					else
						mdOutReg <= '1';
					end if;
					if mdcRisingEdge = '1' then
						state <= S_TURN_AROUND_1;
					end if;

				when S_TURN_AROUND_1 =>
					mdOutReg <= '0';
					if mdcRisingEdge = '1' then
						bitCounter <= to_unsigned(15, bitCounter'length);
						state <= S_DATA;
					end if;

				when S_DATA =>
					if rnw = '0' then
						mdOutReg <= wdata(to_integer(bitCounter));
					elsif rnw ='1' and mdcSamplingEdge = '1' then
						rdataReg(to_integer(bitCounter)) <= mdIn;					
					end if;
					if mdcRisingEdge = '1' then
						if bitCounter = 0 then
							state <= S_DONE;
						else
							bitCounter <= bitCounter - 1;
						end if;
					end if;

					when S_DONE =>
						if mdcRisingEdge = '1' then
							state <= S_IDLE;
							doneReg <= '1';
						end if;

			end case;
		end if;
	end process;

end rtl;
