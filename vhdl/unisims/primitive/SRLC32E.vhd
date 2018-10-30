-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  32-Bit Shift Register Look-Up-Table with Carry and Clock Enable
-- /___/   /\     Filename : SRLC32E.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:58 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/15/04 - Initial version.
--    04/22/05 - Change input A type from ulogic vector to logic vector.
--    11/28/11 - Change bit attribute to std_logic (CR591750)
--    01/16/12 - 591750, 586884 - revert change severe IP impact.
--    04/16/13 - PR683925 - add invertible pin support.
--    04/22/13 - 714426 - A_in <= A connection missing.
--    04/22/13 - 714490 - infinite loop if CLK stays X or Z causes XSIM to run forever.
-- End Revision

----- CELL SRLC32E -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VPKG.all;

entity SRLC32E is

  generic (
    INIT : bit_vector := X"00000000";
    IS_CLK_INVERTED : std_ulogic := '0'
  );

  port (
    Q   : out STD_ULOGIC;
    Q31 : out STD_ULOGIC;

    A   : in STD_LOGIC_VECTOR (4 downto 0) := "00000";
    CE  : in STD_ULOGIC;
    CLK : in STD_ULOGIC;        
    D   : in STD_ULOGIC
  ); 
end SRLC32E;

architecture SRLC32E_V of SRLC32E is
  signal SHIFT_REG : std_logic_vector (31 downto 0) :=  To_StdLogicVector(INIT);
  signal CLK_in : std_ulogic;
  signal A_in   : std_logic_vector(4 downto 0);
  signal D_in   : std_ulogic;
  signal CE_in  : std_ulogic;
  signal Index : integer := 0;
begin

  Index <=  TO_INTEGER(UNSIGNED(A_in)) when ADDR_IS_VALID(SLV => A_in) else 0;
  Q <= SHIFT_REG(Index);
  Q31 <= SHIFT_REG(31);
  CLK_in <= CLK;
  CE_in  <= CE;
  A_in   <= A;
  D_in   <= D;

  WriteBehavior : process (CLK_in)
  begin
    if (CE_in = '1') then
      if ((rising_edge (CLK_in) and IS_CLK_INVERTED = '0') or 
          (falling_edge(CLK_in) and IS_CLK_INVERTED = '1')) then
        SHIFT_REG(31 downto 0) <= (SHIFT_REG(30 downto 0) & D_in) after 100 ps;
      end if;
    end if;
  end process WriteBehavior;
end SRLC32E_V;
