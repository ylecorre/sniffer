-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  D Flip-Flop with Asynchronous Clear and Clock Enable
-- /___/   /\     Filename : FDCE.vhd
-- \   \  /  \    
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
--    04/16/13 - PR683925 - add invertible pin support.
-- End Revision

----- CELL FDCE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity FDCE is
  generic(
    INIT : bit := '0';
    IS_CLR_INVERTED : std_ulogic := '0';
    IS_C_INVERTED : std_ulogic := '0';
    IS_D_INVERTED : std_ulogic := '0'
    );

  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    CE  : in std_ulogic;
    CLR : in std_ulogic;
    D   : in std_ulogic
    );
end FDCE;

architecture FDCE_V of FDCE is
  
  signal IS_D_INVERTED_BIN : std_ulogic := IS_D_INVERTED;
  signal q_o : std_ulogic := TO_X01(INIT);
  signal gsr_in : std_ulogic;
  signal CLR_in : std_ulogic;
  signal C_in : std_ulogic;
  signal CE_in : std_ulogic;
  signal D_in : std_ulogic;

begin
 
  Q <=  q_o;
  gsr_in <= TO_X01(GSR);
  CLR_in <= CLR;
  C_in <= C;
  CE_in <= CE;
  D_in <= D xor IS_D_INVERTED_BIN;

  FunctionalBehavior         : process(C_in, CLR_in, gsr_in)
  begin

    if (gsr_in = '1') then
      q_o   <= TO_X01(INIT);
    elsif ((CLR_in = '1' and IS_CLR_INVERTED = '0') or
           (CLR_in = '0' and IS_CLR_INVERTED = '1')) then
      q_o   <= '0';
    elsif ((rising_edge(C_in) and IS_C_INVERTED = '0') or
           (falling_edge(C_in) and IS_C_INVERTED = '1')) then
      if (CE_in = '1') then
        q_o <= D_in after 100 ps;
      end if;
    end if;
  end process;

end FDCE_V;


