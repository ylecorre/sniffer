-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  D Flip-Flop with Asynchronous Preset and Clock Enable
-- /___/   /\     Filename : FDPE.vhd
-- \   \  /  \    
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
--    05/22/12 - 659432 - Add GSR
--    04/16/13 - PR683925 - add invertible pin support.
-- End Revision

----- CELL FDPE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity FDPE is
  generic(
      INIT : bit := '1';
      IS_C_INVERTED : std_ulogic := '0';
      IS_D_INVERTED : std_ulogic := '0';
      IS_PRE_INVERTED : std_ulogic := '0'
    );

  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    CE  : in std_ulogic;
    D   : in std_ulogic;
    PRE : in std_ulogic
    );
end FDPE;

architecture FDPE_V of FDPE is
  signal q_o : std_ulogic := TO_X01(INIT);
  signal gsr_in : std_ulogic;
  signal C_in : std_ulogic;
  signal PRE_in : std_ulogic;
  signal CE_in : std_ulogic;
  signal D_in : std_ulogic;
  signal IS_D_INVERTED_BIN : std_ulogic := IS_D_INVERTED;
begin
 
  gsr_in <= TO_X01(GSR);
  Q <=  q_o;
  C_in <= C;
  PRE_in <= PRE;
  CE_in <= CE;
  D_in <= D xor IS_D_INVERTED_BIN;

  FunctionalBehavior         : process(C_in, PRE_in, gsr_in)

  begin

    if (gsr_in = '1') then
      q_o   <= TO_X01(INIT);
    elsif ((PRE_in = '1' and IS_PRE_INVERTED = '0') or
           (PRE_in = '0' and IS_PRE_INVERTED = '1')) then
      q_o   <= '1';
    elsif ((rising_edge(C_in) and IS_C_INVERTED = '0') or
           (falling_edge(C_in) and IS_C_INVERTED = '1')) then
      if (CE_in = '1') then
        q_o <= D_in after 100 ps;
      end if;
    end if;
  end process;
end FDPE_V;
