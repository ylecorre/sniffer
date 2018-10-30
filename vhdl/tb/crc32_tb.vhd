--------------------------------------------------------------------------------
--
-- crc32 testbench
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;

entity crc32_tb is
end crc32_tb;


architecture bench of crc32_tb is

	constant POLY : std_logic_vector(31 downto 0) := x"04c11db7";

	signal rn       : std_logic;
	signal clk      : std_logic;
	signal rBit     : std_logic;
	signal valid    : std_logic;
	signal crcState : std_logic_vector(31 downto 0);

	function crcBit(
		state : std_logic_vector(31 downto 0);
		b     : std_logic
	) return std_logic_vector is
		variable msb      : std_logic;
		variable nb       : std_logic;
		variable newState : std_logic_vector(31 downto 0);
		variable l        : line;
	begin
		msb := state(31);
		nb := msb xor b;
		newState := state(30 downto 0) & '0';
		if nb = '1' then
			newState := newState xor POLY;
		end if;
		return newState;
	end crcBit;

	function crcByte(
		state : std_logic_vector(31 downto 0);
		byte  : std_logic_vector(7 downto 0)
	) return std_logic_vector is
		variable newState : std_logic_vector(31 downto 0);
	begin
		newState := state;
		for i in 0 to 7 loop
			newState := crcBit(newState, byte(i));
		end loop;
		return newState;
	end crcByte;

	function reflect32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
		variable res : std_logic_vector(31 downto 0);
	begin
		for i in 31 downto 0 loop
			res(i) := x(31 - i);
		end loop;
		return res;
	end reflect32;

begin

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

	p_crc32 : process(rn, clk)
		variable crcStateNext : std_logic_vector(31 downto 0);
		variable b            : std_logic;
	begin
		if rn = '0' then
			crcState <= x"ffffffff";
		elsif rising_edge(clk) then
			if valid = '1' then
				crcStateNext := crcState(30 downto 0) & '0';
				b := crcState(31) xor rBit;
				if b = '1' then
					crcState <= crcStateNext xor POLY;
				else
					crcState <= crcStateNext;
				end if;
			end if;
		end if;
	end process;

	p_streamer : process
		variable fileOpenStatus : file_open_status;
		variable l              : line;
		variable c              : character;
		file frameFile          : text;
		variable data           : std_logic_vector(7 downto 0);
		variable state          : std_logic_vector(31 downto 0);
	begin
	valid <= '0';
	file_open(fileOpenStatus, frameFile, "./frame.dump", READ_MODE);	
	assert (fileOpenStatus = OPEN_OK) report "Can't open file ./frame.txt" severity FAILURE;
	state := x"ffffffff";
	while true loop
		if endfile(frameFile) then
			exit;
		end if;
		readline(frameFile, l);
		while True loop
			read(l, c);
			if c = 'x' then
				exit;
			end if;
		end loop;
		hread(l, data);
		for i in 0 to 7 loop
			wait until rising_edge(clk);
			valid <= '1';
			rBit <= data(i);
		end loop;
		state := crcByte(state, data);
	end loop;
	state := state xor x"ffffffff";
	state := reflect32(state);
	deallocate(l);
	write(l, string'("-- Expected CRC = 0x"));
	hwrite(l, state);
	writeline(OUTPUT, l);
	wait until rising_edge(clk);
	valid <= '0';
	wait;
	end process;

	p_main : process
		variable l : line;
	begin
		rn <= '0';
		wait for 1 us;
		rn <= '1';
		wait until valid = '1';
		wait until valid = '0';
		write(l, string'("-- Actual CRC = 0x"));
		hwrite(l, reflect32(crcState xor x"ffffffff"));
		writeline(OUTPUT, l);
		wait for 1 us;
		rn <= '0';
		wait for 1 us;
		wait;	
	end process;

end bench;
