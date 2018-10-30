--------------------------------------------------------------------------------
--
-- rmiiRx
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:36:19 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--  Implement RMII receive side, including reset/initialization phase for
--  LAN8720A-like PHY chip.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rmiiRx is
	port(
		clk         : in  std_logic;                          -- 100 MHz clock, rising-edge active
		rn          : out std_logic;                          -- rmii reset (active low)
		rxdIn       : in  std_logic_vector(1 downto 0);       -- received data from pad (2 bits @ 50 MHz)
		rxdEn       : out std_logic;                          -- rxd pads enable
		crsIn       : in  std_logic;                          -- data valid signal
		refClk      : in  std_logic;                          -- front-end clock @ 50 MHz
		rxData      : out std_logic_vector(7 downto 0);       -- byte received from front-end
		rxDataValid : out std_logic;                          -- asserted when rxData is valid
		frameStart  : out std_logic;                          -- asserted when frame starts
		frameEnd    : out std_logic                           -- asserted when frame ends
	);
end rmiiRx;


architecture rtl of rmiiRx is

	type state_type is (
		S_RESET, S_INPUT_DELAY, S_DRIVE_DELAY, S_RELEASE_RESET_DELAY, S_IDLE,
		S_SFD, S_BITS10, S_BITS32, S_BITS54, S_BITS76, S_END
	);

	signal state            : state_type := S_RESET;
	signal rxDataReg        : std_logic_vector(7 downto 0) := x"00";
	signal rxDataValidReg   : std_logic := '0';
	signal frameStartReg    : std_logic := '0';
	signal frameEndReg      : std_logic := '0';
	signal rnReg            : std_logic := '0';
	signal resetCounter     : unsigned(13 downto 0) := to_unsigned(0, 14);
	signal rxdEnReg         : std_logic := '0';

begin

	rn <= rnReg;
	rxData <= rxDataReg;
	rxDataValid <= rxDataValidReg;
	frameStart <= frameStartReg;
	frameEnd <= frameEndReg;
	rxdEn <= rxdEnReg;

	-- sample at refClk rising edg. refClk is not an actual clock for this design
	p_sample : process(clk)
	begin
		if rising_edge(clk) then

			case state is

				when S_RESET =>
					rnReg <= '0';
					resetCounter <= to_unsigned(0, resetCounter'length);
					rxdEnReg <= '0';
					state <= S_INPUT_DELAY;

				when S_INPUT_DELAY =>
					if resetCounter = 5 then
						state <= S_DRIVE_DELAY;
						rxdEnReg <= '1';
					else
						resetCounter <= resetCounter + 1;
					end if;

				when S_DRIVE_DELAY =>
					if resetCounter = 12000 then
						-- 120 us reset time
						rnReg <= '1';
						state <= S_RELEASE_RESET_DELAY;
					else
						resetCounter <= resetCounter + 1;
					end if;

				when S_RELEASE_RESET_DELAY =>
					rxdEnReg <= '0';
					state <= S_IDLE;

				when S_IDLE =>
					frameStartReg <= '0';
					frameEndReg <= '0';
					rxDataValidReg <= '0';
					if crsIn = '1' then
						state <= S_SFD;
					end if;

				when S_SFD =>
					if crsIn = '0' or (refClk = '0' and (rxdIn /= "11" and rxdIn /= "01"))then
						state <= S_IDLE;
					elsif rxdIn = "11" and refClk = '0' then
						state <= S_BITS10;
						frameStartReg <= '1';
					end if;

				when S_BITS10 =>
					frameStartReg <= '0';
					rxDataValidReg <= '0';
					if crsIn = '0' then
						state <= S_IDLE;
						frameEndReg <= '1';
					elsif refClk = '0' then
						rxDataReg(1 downto 0) <= rxdIn;
						state <= S_BITS32;
					end if;

				when S_BITS32 =>
					if crsIn = '0' then
						state <= S_IDLE;
						frameEndReg <= '1';
					elsif refClk = '0' then
						rxDataReg(3 downto 2) <= rxdIn;
						state <= S_BITS54;
					end if;

				when S_BITS54 =>
					if crsIn = '0' then
						state <= S_IDLE;
						frameEndReg <= '1';
					elsif refClk = '0' then
						rxDataReg(5 downto 4) <= rxdIn;
						state <= S_BITS76;
					end if;

				when S_BITS76 =>
					if refClk = '0' then
						rxDataReg(7 downto 6) <= rxdIn;
						rxDataValidReg <= '1';
						if crsIn = '0' then
							state <= S_END;
						else
							state <= S_BITS10;
						end if;
					end if;

				when S_END =>
					rxDataValidReg <= '0';
					frameEndReg <= '1';
					state <= S_IDLE;

			end case;
		end if;
	end process;

end rtl;
