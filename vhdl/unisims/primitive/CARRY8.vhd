-------------------------------------------------------------------------------
-- Copyright (c) 2012 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 2012.2
--  \   \         Description : Xilinx Function Simulation Library Component
--  /   /                  Fast Carry Logic with Look Ahead
-- /___/   /\     Filename : CARRY8.vhd
-- \   \  /  \    
--  \___\/\___\
-- Revision:
--    09/26/12 - Initial version.
--    05/13/13 - 718066 - S used in logic rather than S_in.
--    05/24/13 - Add CARRY_TYPE and CI_TOP
-- End Revision
-------------------------------------------------------------------------------

----- CELL CARRY8 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library unisim;
use unisim.vpkg.all;
use unisim.VCOMPONENTS.all;

entity CARRY8 is
  generic (
    CARRY_TYPE : string := "SINGLE_CY8"
  );

  port (
    CO          : out std_logic_vector(7 downto 0);
    O           : out std_logic_vector(7 downto 0);
    CI          : in std_ulogic := '0';
    CI_TOP      : in std_ulogic := '0';
    DI          : in std_logic_vector(7 downto 0) := (others => '0');
    S           : in std_logic_vector(7 downto 0) := (others => '0')
  );
end CARRY8;

architecture CARRY8_V of CARRY8 is

  constant MODULE_NAME : string := "CARRY8";
  constant IN_DELAY : time := 0 ps;
  constant OUT_DELAY : time := 0 ps;
  constant INCLK_DELAY : time := 0 ps;
  constant OUTCLK_DELAY : time := 0 ps;

-- Parameter encodings and registers
  constant CARRY_TYPE_DUAL_CY4 : std_ulogic := '1';
  constant CARRY_TYPE_SINGLE_CY8 : std_ulogic := '0';

  signal CARRY_TYPE_BIN : std_ulogic;

  signal glblGSR      : std_ulogic;
  
  signal attr_err     : std_ulogic := '0';

  signal CO_out : std_logic_vector(7 downto 0);
  signal O_out  : std_logic_vector(7 downto 0);

  signal CO_delay : std_logic_vector(7 downto 0);
  signal O_delay  : std_logic_vector(7 downto 0);
  
  signal CI_TOP_delay : std_ulogic;
  signal CI_delay : std_ulogic;
  signal DI_delay : std_logic_vector(7 downto 0);
  signal S_delay  : std_logic_vector(7 downto 0);

  signal CI_TOP_in : std_ulogic;
  signal CI_in : std_ulogic;
  signal DI_in : std_logic_vector(7 downto 0);
  signal S_in  : std_logic_vector(7 downto 0);

begin
  glblGSR     <= TO_X01(GSR);

  CO <= CO_delay after OUT_DELAY;
  O <= O_delay after OUT_DELAY;
  
  CO_delay <= CO_out;
  O_delay <= O_out;
  
  CI_TOP_delay <= CI_TOP after IN_DELAY when (CI_TOP = '1' or CI_TOP = 'X') else '0';
  CI_delay <= CI after IN_DELAY when (CI = '1' or CI = 'X') else '0';
  DI_delay(7) <= DI(7) after IN_DELAY when (DI(7) = '1' or DI(7) = 'X') else '0';
  DI_delay(6) <= DI(6) after IN_DELAY when (DI(6) = '1' or DI(6) = 'X') else '0';
  DI_delay(5) <= DI(5) after IN_DELAY when (DI(5) = '1' or DI(5) = 'X') else '0';
  DI_delay(4) <= DI(4) after IN_DELAY when (DI(4) = '1' or DI(4) = 'X') else '0';
  DI_delay(3) <= DI(3) after IN_DELAY when (DI(3) = '1' or DI(3) = 'X') else '0';
  DI_delay(2) <= DI(2) after IN_DELAY when (DI(2) = '1' or DI(2) = 'X') else '0';
  DI_delay(1) <= DI(1) after IN_DELAY when (DI(1) = '1' or DI(1) = 'X') else '0';
  DI_delay(0) <= DI(0) after IN_DELAY when (DI(0) = '1' or DI(0) = 'X') else '0';
  S_delay(7) <= S(7) after IN_DELAY when (S(7) = '1' or S(7) = 'X') else '0';
  S_delay(6) <= S(6) after IN_DELAY when (S(6) = '1' or S(6) = 'X') else '0';
  S_delay(5) <= S(5) after IN_DELAY when (S(5) = '1' or S(5) = 'X') else '0';
  S_delay(4) <= S(4) after IN_DELAY when (S(4) = '1' or S(4) = 'X') else '0';
  S_delay(3) <= S(3) after IN_DELAY when (S(3) = '1' or S(3) = 'X') else '0';
  S_delay(2) <= S(2) after IN_DELAY when (S(2) = '1' or S(2) = 'X') else '0';
  S_delay(1) <= S(1) after IN_DELAY when (S(1) = '1' or S(1) = 'X') else '0';
  S_delay(0) <= S(0) after IN_DELAY when (S(0) = '1' or S(0) = 'X') else '0';
  
  CI_TOP_in <= CI_TOP_delay when CARRY_TYPE_BIN = CARRY_TYPE_DUAL_CY4 else CO_out(3);
  CI_in <= CI_delay;
  DI_in <= DI_delay;
  S_in <= S_delay;
  
  CARRY_TYPE_BIN <= 
    CARRY_TYPE_SINGLE_CY8 when (CARRY_TYPE = "SINGLE_CY8") else
    CARRY_TYPE_DUAL_CY4 when (CARRY_TYPE = "DUAL_CY4") else
    CARRY_TYPE_SINGLE_CY8;

 INIPROC : process
  begin
-------- CARRY_TYPE check
  -- case CARRY_TYPE is
    if((CARRY_TYPE /= "SINGLE_CY8") and (CARRY_TYPE /= "DUAL_CY4")) then
      attr_err <= '1';
      assert FALSE report "Error : CARRY_TYPE is not SINGLE_CY8, DUAL_CY4." severity warning;
    end if;
  -- end case;
  if  (attr_err = '1') then
    assert FALSE
    report "Error : Attribute Error(s) encountered"
    severity error;
  end if;
  wait;
  end process INIPROC;

  O_out     <= S_in xor ( CO_out(6 downto 4) & CI_TOP_in & CO_out(2 downto 0) & CI_in );
  CO_out(0) <= CI_in     when S_in(0) = '1' else DI_in(0) when S_in(0) = '0' else 'X'; 
  CO_out(1) <= CO_out(0) when S_in(1) = '1' else DI_in(1) when S_in(1) = '0' else 'X'; 
  CO_out(2) <= CO_out(1) when S_in(2) = '1' else DI_in(2) when S_in(2) = '0' else 'X'; 
  CO_out(3) <= CO_out(2) when S_in(3) = '1' else DI_in(3) when S_in(3) = '0' else 'X'; 
  CO_out(4) <= CI_TOP_in when S_in(4) = '1' else DI_in(4) when S_in(4) = '0' else 'X'; 
  CO_out(5) <= CO_out(4) when S_in(5) = '1' else DI_in(5) when S_in(5) = '0' else 'X'; 
  CO_out(6) <= CO_out(5) when S_in(6) = '1' else DI_in(6) when S_in(6) = '0' else 'X'; 
  CO_out(7) <= CO_out(6) when S_in(7) = '1' else DI_in(7) when S_in(7) = '0' else 'X'; 

end CARRY8_V;
