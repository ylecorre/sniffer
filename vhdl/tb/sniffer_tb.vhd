--------------------------------------------------------------------------------
--
-- sniffer testbench
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;


entity sniffer_tb is
end sniffer_tb;


architecture bench of sniffer_tb is

	signal rn         : std_logic;
	signal clk        : std_logic;
	signal uartRx     : std_logic := '1';
	signal uartTx     : std_logic;
	signal rmiiResetN : std_logic;
	signal rmiiTxd    : std_logic_vector(1 downto 0);
	signal rmiiTxen   : std_logic;
	signal rmiiRxd    : std_logic_vector(1 downto 0);
	signal rmiiCrs    : std_logic;
  signal rmiiClk    : std_logic;
	signal rmiiMdio   : std_logic;
	signal rmiiMdc    : std_logic;
	signal straps     : std_logic_vector(2 downto 0);
	signal loopback   : std_logic;

	signal ethernetFrameStart : std_logic;
	signal txBuffer           : std_logic_vector(7 downto 0);
	signal txBufferRdy        : std_logic := '0';
	signal phyResetN          : std_logic;

begin

  ------------------------------------------------------------------------------
	-- DUT
   -----------------------------------------------------------------------------
	i_sniffer : entity work.sniffer
		port map(
			clk        => clk,
			uartRx     => uartRx,
			uartTx     => uartTx,
			rmiiResetN => rmiiResetN,
			rmiiMdio   => rmiiMdio,
			rmiiMdc    => rmiiMdc,
			rmiiTxd    => rmiiTxd,
			rmiiTxen   => rmiiTxen,
			rmiiRxd    => rmiiRxd,
			rmiiCrs    => rmiiCrs,
			rmiiClk    => rmiiClk
		);

  ------------------------------------------------------------------------------
	-- phy
  -----------------------------------------------------------------------------
	i_phy : entity work.phy
		generic map(
			address => 1,
			rmii    => 1
		)
		port map(
			rstn            => phyResetN,
			mdio            => rmiiMdio,
			tx_clk          => open,
			rx_clk          => open,
			rxd             => open,
			rx_dv           => open,
			rx_er           => open,
			rx_col          => open,
			rx_crs          => open,
			txd(7 downto 2) => "000000",
			txd(1 downto 0) => rmiiTxd,
			tx_en           => rmiiTxen,
			tx_er           => '0',
			mdc             => rmiiMdc,
			gtx_clk         => rmiiClk,
			loopback        => loopback
		);

	phyResetN <= '0' when rn = '0' else rmiiResetN;
	rmiiMdio <= 'H';

  ------------------------------------------------------------------------------
	-- Clock
   -----------------------------------------------------------------------------
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

  ------------------------------------------------------------------------------
	-- lan8720 ethernet PHY
   -----------------------------------------------------------------------------
	i_lan8720 : entity work.lan8720
		port map(
			rn         => rmiiResetN,
			mdio       => open, -- rmiiMdio,
			mdc        => rmiiMdc,
			txd        => rmiiTxd,
			txen       => rmiiTxen,
			rxd        => rmiiRxd,
			crs        => rmiiCrs,
			clkin      => rmiiClk,
			frameStart => ethernetFrameStart,
			straps     => straps,
			loopback   => loopback
		);

  ------------------------------------------------------------------------------
	-- Uart Receiver
   -----------------------------------------------------------------------------
	p_uartReceiver : process
		constant BITDURATION : time := 8.68 us;
		constant PREWAIT     : time := 6 us;
	begin
		wait until falling_edge(uartTx);
		txBufferRdy <= '0';
		wait for BITDURATION;
		wait for PREWAIT;
		for i in 0 to 7 loop
			txBuffer(i) <= uartTx;
			wait for BITDURATION;
		end loop;
		txBufferRdy <= '1';
		wait for 1 ns;
		txBufferRdy <= '0';
	end process;

  ------------------------------------------------------------------------------
	-- Stimuli
   -----------------------------------------------------------------------------
	p_stim : process

		-- send a byte to the uart
		procedure send(
			data        : std_logic_vector;
			bitDuration : time := 8.68 us
		) is
			variable data_v : std_logic_vector(7 downto 0);
		begin
			-- constants std_logic_vector are defined with (0 to ...) by ghdl (!)
			if data'ascending = true then
				for i in 0 to 7 loop
					data_v(i) := data(7 - i);
				end loop;
			else
				data_v := data;
			end if;
			wait for 8 ns;
			uartRx <= '0'; -- start bit
			wait for bitDuration;
			for i in 0 to 7 loop
				uartRx <= data_v(i);
				wait for bitDuration;
			end loop;
			uartRx <= '1';
			wait for bitDuration;
		end send;

		procedure recv(
			timeout : out boolean;
			data    : out std_logic_vector
		) is
		begin
			wait until rising_edge(txBufferRdy) for 1 ms;
			if txBufferRdy = '0' then
				timeout := true;
			else
				data := txBuffer;
			end if;
		end recv;

		-- write a SMI register
		procedure writeReg(
			addr : std_logic_vector(7 downto 0);
			data : std_logic_vector(15 downto 0)
		) is
			variable tmp : std_logic_vector(7 downto 0);
		begin
			tmp := x"7f" and addr;
			send(tmp);
			send(data(15 downto 8));
			send(data(7 downto 0));
		end writeReg;

		-- read a SMI register
		procedure readReg(
			addr : std_logic_vector(7 downto 0);
			data : out std_logic_vector(15 downto 0)
		) is
			variable tmp : std_logic_vector(7 downto 0);
		begin
			tmp := x"80" or addr;
			send(tmp);
			wait until rising_edge(txBufferRdy);
			data(15 downto 8) := txBuffer;
			wait until rising_edge(txBufferRdy);
			data(7 downto 0) := txBuffer;
		end readReg;

		variable data16  : std_logic_vector(15 downto 0);
		variable data8   : std_logic_vector(7 downto 0);
		variable length  : integer;
		variable d       : integer;
		variable l       : line;
		variable timeout : boolean;

	begin
		ethernetFrameStart <= '0';
		rn <= '0';
		uartRx <= '1';
		wait for 10 ns;
		rn <= '1';
		wait until rising_edge(rmiiResetN);
		wait for 20 ns;
		report "== Testing straps" severity NOTE;
		if straps = "111" then
			report "-- Straps are correct" severity NOTE;
		else
			report "-- Straps are NOT correct" severity ERROR;
		end if;
		wait until rising_edge(rmiiClk);

		report "== Testing basic test command" severity NOTE;
		send(x"f0");
		recv(timeout, data8);
		if data8 /= x"a9" then
			report "-- Basic test failed" severity ERROR;
		else
			report "-- Basic test succeeded" severity NOTE;
		end if;

		-- testing transmit
		report "== Testing transmit" severity NOTE;

		send(x"fe");
		recv(timeout, data8);
		write(l, string'("-- status = 0x"));
		hwrite(l, data8);
		report l.all severity NOTE;
		deallocate(l);

		send(x"f4"); -- write
		send(x"0f"); -- length
		send(x"55");
		send(x"55");
		send(x"55");
		send(x"55");
		send(x"55");
		send(x"55");
		send(x"D5");
		send(x"83");
		send(x"84");
		send(x"85");
		send(x"86");

		send(x"8e");
		send(x"3f");
		send(x"bb");
		send(x"7a");

		send(x"fd"); -- trigger capture
		send(x"f8"); -- trigger transmit
		-- poll status register until end of cature
		while true loop
			send(x"fe");
			recv(timeout, data8);
			if data8(0) = '1' then
				exit;
			end if;
		end loop;
		-- check CRC
		if data8(7) = '1' then
			report "-- CRC OK" severity NOTE;
		else
			report "-- CRC ERROR" severity ERROR;
		end if;

		send(x"f2");
		recv(timeout, data8);
		assert timeout = false
			report "-- Timout triggered while waiting for MSB of RX_BUFFER length"
			severity ERROR;
		length := to_integer(unsigned(data8))*256;
		recv(timeout, data8);
		assert timeout = false
			report "-- Timout triggered while waiting for LSB of RX_BUFFER length"
			severity ERROR;
		length := length + to_integer(unsigned(data8));
		report "-- length of RX buffer is " & integer'image(length) & " bytes" severity NOTE;
		for i in 1 to length loop
			recv(timeout, data8);
			assert timeout = false
				report "-- Timeout triggered while waiting for RX sample " & integer'image(i)
				severity ERROR;
			write(l, string'("-- loopback: 0x"));
			hwrite(l, data8);
			report l.all severity NOTE;
			deallocate(l);
		end loop;

		-- trigger capture
		report "== Testing frame capture" severity NOTE;
		writeReg(x"00", x"1140"); -- disable loopback
		deallocate(l);
		send(x"fd"); -- trigger capture
		wait until rising_edge(rmiiClk);
		ethernetFrameStart <= '1';
		wait until rising_edge(rmiiClk);
		ethernetFrameStart <= '0';
		-- poll status register until end of cature
		while true loop
			send(x"fe");
			recv(timeout, data8);
			if data8(0) = '1' then
				exit;
			end if;
		end loop;
		-- check CRC
		if data8(7) = '1' then
			report "-- CRC OK" severity NOTE;
		else
			report "-- CRC ERROR" severity ERROR;
		end if;

		-- download captured frame
		send(x"f2");
		recv(timeout, data8);
		assert timeout = false
			report "-- Timout triggered while waiting for MSB of RX_BUFFER length"
			severity ERROR;
		length := to_integer(unsigned(data8))*256;
		recv(timeout, data8);
		assert timeout = false
			report "-- Timout triggered while waiting for LSB of RX_BUFFER length"
			severity ERROR;
		length := length + to_integer(unsigned(data8));
		report "-- length of RX buffer is " & integer'image(length) & " bytes" severity NOTE;
		for i in 1 to length loop
			recv(timeout, data8);
			assert timeout = false
				report "-- Timeout triggered while waiting for RX sample " & integer'image(i)
				severity ERROR;
			write(l, string'("-- loopback: 0x"));
			hwrite(l, data8);
			report l.all severity NOTE;
			deallocate(l);
		end loop;

		wait for 100 us;

		-- trigger capture (2)
		report "== Testing frame capture (2)" severity NOTE;
		send(x"fd");
		wait until rising_edge(rmiiClk);
		ethernetFrameStart <= '1';
		wait until rising_edge(rmiiClk);
		ethernetFrameStart <= '0';
		-- poll status register until end of cature
		while true loop
			send(x"fe");
			recv(timeout, data8);
			if data8(0) = '1' then
				exit;
			end if;
		end loop;
		-- check CRC
		if data8(7) = '1' then
			report "-- CRC OK" severity NOTE;
		else
			report "-- CRC ERROR" severity ERROR;
		end if;

		-- download captured frame
		send(x"f2");
		recv(timeout, data8);
		assert timeout = false
			report "-- Timout triggered while waiting for MSB of RX_BUFFER length"
			severity ERROR;
		length := to_integer(unsigned(data8))*256;
		recv(timeout, data8);
		assert timeout = false
			report "-- Timout triggered while waiting for LSB of RX_BUFFER length"
			severity ERROR;
		length := length + to_integer(unsigned(data8));
		report "-- length of RX buffer is " & integer'image(length) & " bytes" severity NOTE;
		for i in 1 to length loop
			recv(timeout, data8);
			assert timeout = false
				report "-- Timeout triggered while waiting for RX sample " & integer'image(i)
				severity ERROR;
			write(l, string'("-- loopback: 0x"));
			hwrite(l, data8);
			report l.all severity NOTE;
			deallocate(l);
		end loop;

		-- test smi
		report "== Testing Serial Management Interface" severity NOTE;
		readReg(x"02", data16);
		if data16 = x"bbcd" then
			report "-- Register 0x02 value is correct" severity NOTE;
		else
			write(l, string'("reg02 = 0x"));
			hwrite(l, data16);
			report l.all severity ERROR;
			deallocate(l);
		end if;
		readReg(x"03", data16);
		if data16 = x"9c83" then
			report "-- Register 0x03 value is correct" severity NOTE;
		else
			write(l, string'("reg03 = 0x"));
			hwrite(l, data16);
			report l.all severity ERROR;
			deallocate(l);
		end if;
		readReg(x"07", data16);
		if data16 = x"2001" then
			report "-- Register 0x07 value is correct" severity NOTE;
		else
			write(l, string'("reg07 = 0x"));
			hwrite(l, data16);
			report l.all severity ERROR;
			deallocate(l);
		end if;
		report "-- Writing reg 0x07" severity NOTE;
		writeReg(x"07", x"20ff");
		readReg(x"07", data16);
		if data16 = x"907f" then
			report "-- Register 0x07 value is correct" severity NOTE;
		else
			write(l, string'("reg07 = 0x"));
			hwrite(l, data16);
			report l.all severity ERROR;
			deallocate(l);
		end if;

		-- end of testbench
		rn <= '0';
		wait for 20 ns;
		report "-- Testbench finished" severity NOTE;
		wait;
	end process;

end bench;
