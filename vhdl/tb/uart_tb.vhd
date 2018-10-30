--------------------------------------------------------------------------------
--
-- Uart testbench
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;


entity uart_tb is
end uart_tb;


architecture bench of uart_tb is

	signal clk         : std_logic;                          -- 100 MHz clock
	signal rx          : std_logic;                          -- Uart RX wire
	signal tx          : std_logic;                          -- Uart TX wire
	signal rxEnable    : std_logic;                          -- asserted to enable receiver
	signal rxData      : std_logic_vector(7 downto 0);       -- received byte
	signal rxDataValid : std_logic;                          -- asserted when rxData is valid
	signal txData      : std_logic_vector(7 downto 0);       -- data to send
	signal txSend      : std_logic;                          -- pulse to start transmit
	signal txRdy       : std_logic;                          -- asserted when transmitter is available
	signal rn          : std_logic;
	signal rxBuffer    : std_logic_vector(7 downto 0);
	signal txBuffer    : std_logic_vector(7 downto 0);

begin

	i_uart : entity work.uart
		port map(
			clk         => clk,
			rx          => rx,
			tx          => tx,
			rxEnable    => rxEnable,
			rxData      => rxData,
			rxDataValid => rxDataValid,
			txData      => txData,
			txSend      => txSend,
			txRdy       => txRdy
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

	p_receiver_check : process(clk)
	begin
		if rising_edge(clk) then
			if rxDataValid = '1' then
				rxBuffer <= rxData;
			end if;
		end if;
	end process;


	p_transmitter_check : process
		constant BITDURATION : time := 8.68 us;
		constant PREWAIT     : time := 6 us;
	begin
		wait until falling_edge(tx);
		wait for BITDURATION;
		wait for PREWAIT;
		for i in 0 to 7 loop
			txBuffer(i) <= tx;
			wait for BITDURATION;
		end loop;
	end process;

	p_stim : process

		procedure send(data : std_logic_vector; bitDuration : time := 8.68 us) is
		begin
			wait for 8 ns;
			rx <= '0'; -- start bit
			wait for bitDuration;
			for i in 0 to 7 loop
				rx <= data(i);
				wait for bitDuration;
			end loop;
			rx <= '1';
			wait for bitDuration;
		end send;

		variable data    : std_logic_vector(7 downto 0);
		variable nErrors : integer;
		variable l       : line;

	begin
		nErrors := 0;
		rxEnable <= '0';
		rn <= '0';
		rx <= '1';
		wait for 10 ns;
		rn <= '1';
		wait until rising_edge(clk);
		wait for 100 ns;

		-- TX testing
		for i in 0 to 255 loop
			data := std_logic_vector(to_unsigned(i, 8));
			txData <= data;
			txSend <= '1';
			wait until rising_edge(clk);
			txSend <= '0';
			wait until rising_edge(clk) and txRdy = '1';
			if txBuffer /= data then
				write(l, string'("Expected = 0x"));
				hwrite(l, data);
				write(l, string'(", actual = 0x"));
				hwrite(l, txBuffer);
				report l.all severity ERROR;
				deallocate(l);
				nErrors := nErrors + 1;
			end if;
		end loop;
		wait for 50 ns;

		-- RX testing
		rxEnable <= '1';
		wait for 100 ns;
		for i in 0 to 255 loop
			data := std_logic_vector(to_unsigned(i, 8));
			send(data);
			if data /= rxBuffer then
				write(l, string'("Expected = 0x"));
				hwrite(l, data);
				write(l, string'(", actual = 0x"));
				hwrite(l, rxBuffer);
				report l.all severity ERROR;
				deallocate(l);
				nErrors := nErrors + 1;
			end if;
		end loop;

		wait for 50 ns;
		rn <= '0';
		wait for 10 ns;
		if nErrors > 0 then
			report "-- Found " & integer'image(nErrors) severity ERROR;
		else
			report "-- Testbench completed successfully" severity NOTE;
		end if;
		wait;
	end process;

end bench;
