--------------------------------------------------------------------------------
--
-- Serial management interface (SMI)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;


entity smi_tb is
end smi_tb;


architecture bench of smi_tb is

	signal rn      : std_logic;
	signal clk     : std_logic;
	signal mdio    : std_logic;
	signal mdOut   : std_logic;
	signal mdEn    : std_logic;
	signal mdc     : std_logic;
	signal phyAddr : std_logic_vector(4 downto 0);
	signal regAddr : std_logic_vector(4 downto 0);
	signal wdata   : std_logic_vector(15 downto 0);
	signal rdata   : std_logic_vector(15 downto 0);
	signal send    : std_logic;
	signal rnw     : std_logic;
	signal done    : std_logic;

begin

	phyAddr <= "00001";

	mdio <= mdOut when mdEn = '1' else 'Z';

	i_smi : entity work.smi
		port map(
			clk     => clk,
			mdIn    => mdio,
			mdOut   => mdOut,
			mdEn    => mdEn,
			mdc     => mdc,
			phyAddr => phyAddr,
			regAddr => regAddr,
			wdata   => wdata,
			rdata   => rdata,
			send    => send,
			rnw     => rnw,
			done    => done
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

	p_smi : process
		type regsType is array(31 downto 0) of std_logic_vector(15 downto 0);
		variable regs     : regsType := (others => x"0000");
		variable rwV      : std_logic_vector(1 downto 0);
		variable phyAddrV : std_logic_vector(4 downto 0);
		variable regAddrV : std_logic_vector(4 downto 0);
		variable dataV    : std_logic_vector(15 downto 0);
		variable l        : line;
	begin
		mdio <= 'Z';
		-- preamble
		for i in 0 to 15 loop
			wait until rising_edge(mdc) and mdio = '1';
		end loop;
		-- start of frame
		wait until rising_edge(mdc) and mdio = '0';
		wait until rising_edge(mdc) and mdio = '1';
		-- read/write symbol
		wait until rising_edge(mdc);
		rwV(1) := mdio;
		wait until rising_edge(mdc);
		rwV(0) := mdio;
		-- phyAddr
		for i in 4 downto 0 loop
			wait until rising_edge(mdc);
			phyAddrV(i) := mdio;
		end loop;
		-- regAddr
		for i in 4 downto 0 loop
			wait until rising_edge(mdc);
			regAddrV(i) := mdio;
		end loop;
		-- turnaround
		if rwV = "01" then
			wait until falling_edge(mdc);
			if phyAddrV = "00001" then
				mdio <= '0';
			end if;
			-- read
			wait until falling_edge(mdc);
			-- data
			for i in 15 downto 0 loop
				if phyAddrV = "00001" then
					mdio <= regs(to_integer(unsigned(regAddrV)))(i);
				end if;
				wait until falling_edge(mdc);
			end loop;
		elsif rwV = "10" then
			wait until rising_edge(mdc);
			-- write
			wait until rising_edge(mdc);
			-- data
			for i in 15 downto 0 loop
				wait until rising_edge(mdc);
				dataV(i) := mdio;
			end loop;
			if phyAddrV = "00001" then
				regs(to_integer(unsigned(regAddrV))) := dataV;
			end if;
		end if;
		wait until rising_edge(mdc);
	end process;

	p_stim : process

		procedure writeReg(
			addr : in  std_logic_vector(7 downto 0);
			data : in  std_logic_vector(15 downto 0)
		) is
		begin
			wdata <= data;
			regAddr <= addr(4 downto 0);
			send <= '1';
			rnw <= '0';
			wait until rising_edge(clk);
			send <= '0';
			wait until rising_edge(clk) and done = '1';
		end writeReg;

		procedure readReg(
			addr : in  std_logic_vector(7 downto 0);
			data : out std_logic_vector(15 downto 0)
		) is
		begin
			regAddr <= addr(4 downto 0);
			send <= '1';
			rnw <= '1';
			wait until rising_edge(clk);
			send <= '0';
			wait until rising_edge(clk) and done = '1';
			data := rdata;
		end readReg;

		variable data : std_logic_vector(15 downto 0);
		variable d    : integer;
		variable nErr : integer;

	begin
		nErr := 0;
		rnw <= '0';
		wdata <= x"0000";
		regAddr <= "00000";
		send <= '0';
		rn <= '0';
		wait for 10 ns;
		rn <= '1';
		wait until rising_edge(clk);
		for i in 0 to 31 loop
			writeReg(std_logic_vector(to_unsigned(i, 8)), std_logic_vector(to_unsigned(i + 1234, 16)));
		end loop;
		for i in 0 to 31 loop
			readReg(std_logic_vector(to_unsigned(i, 8)), data);
			d := to_integer(unsigned(data));
			if d /= i + 1234 then
				report "Expected = " & integer'image(i + 1234) & ", actual = " & integer'image(d) severity ERROR;
				nErr := nErr + 1;
			end if;
		end loop;
		wait for 10 ns;
		rn <= '0';
		wait for 10 ns;
		if nErr = 0 then
			report "-- Testbench finished successfully" severity NOTE;
		else
			report "-- Testbench finished with " & integer'image(nErr) & " error(s)" severity ERROR;
		end if;
		wait;
	end process;

end bench;
