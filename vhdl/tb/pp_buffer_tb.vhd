--------------------------------------------------------------------------------
--
-- Ping Pong Buffer testbench
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pp_buffer_tb is
end pp_buffer_tb;


architecture bench of pp_buffer_tb is

	constant ADDR_WIDTH : natural := 5;

	type stateType is (S_IDLE, S_ACTIVE);

	signal wrState : stateType := S_IDLE;
	signal rdState : stateType := S_IDLE;
	signal rn      : std_logic;
	signal clk     : std_logic;
	signal sel     : std_logic;
	signal wr      : std_logic := '0';
	signal wrData  : std_logic_vector(7 downto 0) := x"00";
	signal wrAddr  : unsigned(ADDR_WIDTH - 1 downto 0) := to_unsigned(0, ADDR_WIDTH);
	signal rd      : std_logic := '0';
	signal rdData  : std_logic_vector(7 downto 0) := x"00";
	signal rdAddr  : unsigned(ADDR_WIDTH - 1 downto 0) := to_unsigned(0, ADDR_WIDTH);
	signal addr    : unsigned(ADDR_WIDTH - 1 downto 0);
	signal selReg  : std_logic := '0';

begin

	i_pingPongBuffer : entity work.pingPongBuffer
		generic map(
			ADDR_WIDTH => ADDR_WIDTH
		)
		port map(
			clk    => clk,
			sel    => sel,
			rd     => rd,
			rdData => rdData,
			rdAddr => rdAddr,
			wr     => wr,
			wrData => wrData,
			wrAddr => wrAddr,
			addr   => addr
		);

	p_clock : process(rn, clk)
	begin
		if rn = '0' then
			clk <= '0';
		elsif rising_edge(rn) then
			clk <= '1' after 1 us;
		elsif clk'event then
			clk <= not clk after 0.5 us;
		end if;
	end process;

	p_sel : process(clk)
	begin
		if rising_edge(clk) then
			selReg <= sel;
		end if;
	end process;

	p_write : process(clk)
		variable counter : integer := 0;
		variable data    : integer := 0;
	begin
		if rising_edge(clk) then
			wr <= '0';
			case wrState is
				when S_IDLE =>
					if selReg /= sel then
						wrState <= S_ACTIVE;
						wrAddr <= to_unsigned(0, wrAddr'length);
						counter := 0;
					end if;
				when S_ACTIVE =>
					if counter < 8 then
						wr <= '1';
						wrAddr <= wrAddr + 1;
						wrData <= std_logic_vector(to_unsigned(data, wrData'length));
						counter := counter + 1;
						data := data + 1;
					else
						wrState <= S_IDLE;
					end if;
			end case;
		end if;
	end process;

	p_read : process(clk)
		variable counter : integer := 0;
	begin
		if rising_edge(clk) then
			rd <= '0';
			case rdState is
				when S_IDLE =>
					if selReg /= sel then
						rdState <= S_ACTIVE;
						rdAddr <= to_unsigned(0, rdAddr'length);
						counter := 0;
					end if;
				when S_ACTIVE =>
					if counter < addr then
						rd <= '1';
						rdAddr <= rdAddr + 1;
						counter := counter + 1;
					else
						rdState <= S_IDLE;
					end if;
			end case;
		end if;
	end process;

	p_stimuli : process
	begin
		rn <= '0';
		sel <= '0';
		wait for 10 ns;
		rn <= '1';

		for j in 0 to 2 loop

			for i in 0 to 15 loop
				wait until rising_edge(clk);
				sel <= '0';
			end loop;

			for i in 0 to 15 loop
				wait until rising_edge(clk);
				sel <= '1';
			end loop;

		end loop;
	
		rn <= '1';
		wait for 10 us;
		rn <= '0';
		wait for 100 ns;
		wait;
	end process;

end bench;
