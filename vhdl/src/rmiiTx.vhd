--------------------------------------------------------------------------------
--
-- rmiiTx
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:37:19 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Implements RMII transmit side for a LAN8720A-like PHY chip.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rmiiTx is
	port(
		clk           : in  std_logic;                     -- 100 MHz clock, rising-edge active
		refClk        : in  std_logic;                     -- \
		txd           : out std_logic_vector(1 downto 0);  -- | RMII interface signals
		txen          : out std_logic;                     -- /
		txStart       : in  std_logic;                     -- asserted to start rmiiTx
		txByte        : in  std_logic_vector(7 downto 0);  -- data to be transmitted to the PHY
		txByteReq     : out std_logic;                     -- asserted to request new txByte
		txByteRdy     : in  std_logic;                     -- asserted to acknowledge txByte
		txDone        : in  std_logic                      -- asserted to signal the rmiiTx should switch off after having sent txByte
	);
end rmiiTx;


architecture rtl of rmiiTx is

	type stateType is (
		S_IDLE, S_SEND_BITS01, S_SEND_BITS23, S_SEND_BITS45, S_SEND_BITS67, S_WAIT_BYTE, S_OFF_DELAY
	);

	signal state        : stateType := S_IDLE;
	signal txenReg      : std_logic := '0';
	signal txdReg       : std_logic_vector(1 downto 0);
	signal txByteReqReg : std_logic := '0';
	signal lastByte     : std_logic := '0';

begin

	txen <= txenReg;
	txd <= txdReg;
	txByteReq <= txByteReqReg;

	p_tx : process(clk)
	begin
		if rising_edge(clk) then

			-- defaults
			txByteReqReg <= '0';

			-- state decoding
			case state is

				when S_IDLE =>
					txenReg <= '0';
					txdReg <= "00";
					if txStart = '1' then
						state <= S_WAIT_BYTE;
						txByteReqReg <= '1';
					end if;

				when S_WAIT_BYTE =>
					state <= S_SEND_BITS01;

				when S_SEND_BITS01 =>
					if refClk = '1' then
						txenReg <= '1';
						txdReg <= txByte(1 downto 0);
						state <= S_SEND_BITS23;
					end if;

				when S_SEND_BITS23 =>
					if refClk = '1' then
						txdReg <= txByte(3 downto 2);
						state <= S_SEND_BITS45;
					end if;

				when S_SEND_BITS45 =>
					if refClk = '1' then
						txdReg <= txByte(5 downto 4);
						state <= S_SEND_BITS67;
					end if;

				when S_SEND_BITS67 =>
					if refClk = '1' then
						txdReg <= txByte(7 downto 6);
						txByteReqReg <= '1';
						if lastByte = '1' then
							state <= S_OFF_DELAY;
							lastByte <= '0';
						else
							state <= S_SEND_BITS01;
						end if;
					end if;

				when S_OFF_DELAY =>
					if refClk = '1' then
						txenReg <= '0';
						txdReg <= "00";
						state <= S_IDLE;
					end if;

			end case;

			if txDone = '1' then
				lastByte <= '1';
			end if;

		end if;
	end process;

end rtl;
