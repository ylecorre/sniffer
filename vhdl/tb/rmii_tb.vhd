--------------------------------------------------------------------------------
--
-- RMII testbench
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;


use std.textio.all;

entity rmii_tb is
end rmii_tb;


architecture bench of rmii_tb is

	signal rn          : std_logic;
	signal clk         : std_logic;                          -- 100 MHz clock
	signal txd         : std_logic_vector(1 downto 0);       -- data to be sent (2 bits @ 50 MHz)
	signal txen        : std_logic;                          -- asserted when txd is ready
	signal rxd         : std_logic_vector(1 downto 0);       -- received data (2 bits @ 50 MHz)
	signal crs         : std_logic;                          -- data valid signal
	signal refClk      : std_logic;                          -- front-end clock @ 50 MHz
	signal rxData      : std_logic_vector(7 downto 0);       -- byte received from front-end
	signal rxDataValid : std_logic;                          -- asserted when rxData is valid

begin

	i_rmii : entity work.rmii
		port map(
			clk         => clk,
			txd         => txd,
			txen        => txen,
			rxd         => rxd,
			crs         => crs,
			refClk      => refClk,
			rxData      => rxData,
			rxDataValid => rxDataValid
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

	p_receive : process(rxdataValid)
		variable l : line;
	begin
		if rising_edge(rxDataValid) then
			hwrite(l, rxData);
			writeline(OUTPUT, l);
		end if;
	end process;

	p_stim : process
		variable fileOpenStatus : file_open_status;
		variable byte           : std_logic_vector(7 downto 0);
		variable l              : line;
		file     frameFile      : text;
	begin
		rn <= '0';
		crs <= '0';
		file_open(fileOpenStatus, frameFile, "./frame.txt", READ_MODE);
		if (fileOpenStatus /= OPEN_OK) then
			report "Can't open file ./frame.txt" severity FAILURE;
		end if;
		wait for 30 ns;
		rn <= '1';
		wait until falling_edge(refClk);
		while true loop
			crs <= '1';
			readline(frameFile, l);
			hread(l, byte);
			for i in 0 to 3 loop
				wait until falling_edge(refClk);
				rxd <= byte(2*i + 1 downto 2*i);
			end loop;
			if endfile(frameFile) then
				exit;
			end if;
		end loop;
		wait until falling_edge(refClk);
		rn <= '0';
		wait for 30 ns;
		wait;
	end process;

end bench;
