--------------------------------------------------------------------------------
--
-- fifo testbench
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;


entity fifo_tb is
end fifo_tb;


architecture bench of fifo_tb is

	signal clk         : std_logic;                       -- clock
	signal din         : std_logic_vector(7 downto 0);    -- input data
	signal dout        : std_logic_vector(7 downto 0);    -- output data
	signal doutXilinx  : std_logic_vector(7 downto 0);    -- output data
	signal wr          : std_logic;                       -- asserted to write din in fifo
	signal rd          : std_logic;                       -- asserted to read dout from fifo
	signal fullXilinx  : std_logic;                       -- asserted when fifo is full
	signal full        : std_logic;                       -- asserted when fifo is full
	signal emptyXilinx : std_logic;                       -- asserted when fifo is full
	signal empty       : std_logic;                       -- asserted when fifo is full
	signal rn          : std_logic;

begin

	i_fifoXilinx : entity work.fifoXilinx
		port map(
			clk   => clk,
			din   => din,
			dout  => doutXilinx,
			wr    => wr,
			rd    => rd,
			full  => fullXilinx,
			empty => emptyXilinx
		);

	i_fifo : entity work.fifo
		generic map(
			ADDR_WIDTH => 11
		)
		port map(
			clk   => clk,
			din   => din,
			dout  => dout,
			wr    => wr,
			rd    => rd,
			full  => full,
			empty => empty
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

	p_stim : process
		variable l    : line;
		variable data : std_logic_vector(7 downto 0);
	begin
		rn <= '0';
		wr <= '0';
		rd <= '0';
		din <= x"00";
		wait for 10 ns;
		rn <= '1';
		wait for 10 ns;

		-- wait for 10 clock periods for fifo (Xilinx) reset
		for i in 0 to 9 loop
			wait until rising_edge(clk);
		end loop;

		wait until rising_edge(clk);
		for i in 1 to 2048 loop
			din <= std_logic_vector(to_unsigned(i mod 256, 8));
			wr <= '1';
			wait until rising_edge(clk);
			wr <= '0';
			wait until rising_edge(clk);
			if full /= '0' and i /= 2048 then
				report "-- full should be low" severity ERROR;
			end if;
			if full /= '1' and i = 2048 then
				report "-- full should be high" severity ERROR;
			end if;
		end loop;
		for i in 1 to 2048 loop
			rd <= '1';
			wait until rising_edge(clk);
			rd <= '0';
			data := std_logic_vector(to_unsigned(i mod 256, 8));
			wait until rising_edge(clk);
			if dout /= data then
				write(l, string'("-- Expected = 0x"));
				hwrite(l, data);
				write(l, string'(", actual = 0x"));
				hwrite(l, dout);
				report l.all severity ERROR;
				deallocate(l);
			end if;
			if full /= '0' then
				report "-- full should be low" severity ERROR;
			end if;
		end loop;
		
		wait for 10 ns;
		rn <= '0';
		wait for 10 ns;
		wait;
	end process;

	p_check : process(clk)
	begin
		if falling_edge(clk) then
			assert doutXilinx = dout and falling_edge(clk)
				report "-- Mismatch between dout and doutXilinx"
				severity ERROR;
			assert emptyXilinx = empty and falling_edge(clk)
				report "-- Mismatch between empty and emptyXilinx"
				severity ERROR;
			assert fullXilinx = full and falling_edge(clk)
				report "-- Mismatch between full and fullXilinx"
				severity ERROR;
		end if;
	end process;


end bench;
