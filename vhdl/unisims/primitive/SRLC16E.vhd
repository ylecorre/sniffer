-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  16-Bit Shift Register Look-Up-Table with Carry and Clock Enable
-- /___/   /\     Filename : SRLC16E.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:58 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/28/11 - Change bit attribute to std_logic (CR591750)
--    01/16/12 - 591750, 586884 - revert change severe IP impact.
--    04/16/13 - PR683925 - add invertible pin support.
--    04/22/13 - 714490 - infinite loop if CLK stays X or Z causes XSIM to run forever.
-- End Revision

----- CELL SRLC16E -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VPKG.all;

entity SRLC16E is

  generic (
    INIT : bit_vector := X"0000";
    IS_CLK_INVERTED : std_ulogic := '0'
  );

  port (
    Q   : out STD_ULOGIC;
    Q15 : out STD_ULOGIC;
        
    A0  : in STD_ULOGIC;
    A1  : in STD_ULOGIC;
    A2  : in STD_ULOGIC;
    A3  : in STD_ULOGIC;
    CE  : in STD_ULOGIC;
    CLK : in STD_ULOGIC;        
    D   : in STD_ULOGIC
  ); 
end SRLC16E;

architecture SRLC16E_V of SRLC16E is
  signal SHIFT_REG : std_logic_vector (16 downto 0) := ('X' & To_StdLogicVector(INIT));
  signal CLK_in : std_ulogic;
  signal A_in    : std_logic_vector(3 downto 0);
  signal D_in    : std_ulogic;
  signal CE_in   : std_ulogic;
  signal Index : integer := 0;

begin
  CLK_in <= CLK;
  CE_in  <= CE;
  A_in   <= A3 & A2 & A1 & A0;
  D_in   <= D;

  Index <=  TO_INTEGER(UNSIGNED(A_in)) when ADDR_IS_VALID(SLV => A_in) else 0;
  Q <= SHIFT_REG(Index);
  Q15 <= SHIFT_REG(15);

  FunctionalWriteBehavior : process (CLK_in)
  begin
    if (CE_in = '1') then
      if ((rising_edge (CLK_in) and IS_CLK_INVERTED = '0') or
          (falling_edge(CLK_in) and IS_CLK_INVERTED = '1')) then
         SHIFT_REG(15 downto 0) <= (SHIFT_REG(14 downto 0) & D_in) after 100 ps;
      end if;
    end if;
  end process FunctionalWriteBehavior;
end SRLC16E_V;
