-----------------------------------------------------------------------------
--  Copyright (c) 2012 Xilinx Inc.
--  All Right Reserved.
-----------------------------------------------------------------------------
-- 
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor      : Xilinx
-- \   \   \/     Version     : 2012.2
--  \   \         Description : Xilinx Unified Simulation Library Component
--  /   /         
-- /___/   /\     
-- \   \  /  \    Filename    : DSP_M_DATA.v 
--  \___\/\___\
-- 
-----------------------------------------------------------------------------
--  Revision:
--  07/15/12 - Migrate from E1.
--  12/10/12 - Add dynamic registers
--  04/22/13 - 713695 - Zero mult result on USE_SIMD
--  04/22/13 - change from CLK'event to rising_edge(CLK)
--  04/23/13 - 714772 - remove sensitivity to negedge GSR
--  End Revision:
-----------------------------------------------------------------------------

----- CELL DSP_M_DATA -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity DSP_M_DATA is
  generic (
    IS_CLK_INVERTED : std_ulogic := '0';
    IS_RSTM_INVERTED : std_ulogic := '0';
    MREG       : integer := 1
   );

  port (
    U_DATA               : out std_logic_vector(44 downto 0);
    V_DATA               : out std_logic_vector(44 downto 0);
    CEM                  : in std_ulogic;
    CLK                  : in std_ulogic;
    RSTM                 : in std_ulogic;
    U                    : in std_logic_vector(44 downto 0);
    V                    : in std_logic_vector(44 downto 0)
   );
end DSP_M_DATA;

architecture DSP_M_DATA_V of DSP_M_DATA is
--  define constants
  constant MODULE_NAME        : string := "DSP_M_DATA";
  constant IN_DELAY           : time := 0 ps;
  constant OUT_DELAY          : time := 0 ps;
  constant INCLK_DELAY        : time := 0 ps;
  constant OUTCLK_DELAY       : time := 0 ps;

--  Parameter encodings and registers
  constant MREG_0             : std_ulogic := '0';
  constant MREG_1             : std_ulogic := '1';

  signal MREG_BIN               : std_ulogic;

  signal glblGSR              : std_ulogic;

  signal attr_err             : std_ulogic := '0';

  signal U_DATA_out           : std_logic_vector(44 downto 0);
  signal V_DATA_out           : std_logic_vector(44 downto 0);

  signal U_DATA_delay         : std_logic_vector(44 downto 0);
  signal V_DATA_delay         : std_logic_vector(44 downto 0);

  signal CEM_delay            : std_ulogic;
  signal CLK_delay            : std_ulogic;
  signal RSTM_delay           : std_ulogic;
  signal U_delay              : std_logic_vector(44 downto 0);
  signal V_delay              : std_logic_vector(44 downto 0);

  signal CEM_in               : std_ulogic;
  signal RSTM_in              : std_ulogic;
  signal U_in                 : std_logic_vector(44 downto 0);
  signal V_in                 : std_logic_vector(44 downto 0);

  signal U_DATA_reg      : std_logic_vector(44 downto 0) := '1' & X"00000000000";
  signal V_DATA_reg      : std_logic_vector(44 downto 0) := '1' & X"00000000000";
  signal CLK_mreg        : std_ulogic;

--  input output assignments
begin
   glblGSR          <= TO_X01(GSR);
   U_DATA           <= U_DATA_delay  after OUT_DELAY;
   V_DATA           <= V_DATA_delay  after OUT_DELAY;

   U_DATA_delay <= U_DATA_out;
   V_DATA_delay <= V_DATA_out;

   CLK_delay           <= CLK after INCLK_DELAY;

   CEM_delay           <= CEM after IN_DELAY;
   RSTM_delay          <= RSTM after IN_DELAY;
   U_delay             <= U after IN_DELAY;
   V_delay             <= V after IN_DELAY;

   CEM_in <= CEM_delay;
   CLK_mreg  <= '0' when (MREG_BIN = MREG_0) else CLK_delay xor IS_CLK_INVERTED;
   RSTM_in <= RSTM_delay xor IS_RSTM_INVERTED;
   U_in <= U_delay;
   V_in <= V_delay;

  INIPROC : process
  begin
-------- MREG check
    case MREG is
      when  1   =>  MREG_BIN <= MREG_1;
      when  0   =>  MREG_BIN <= MREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : MREG is not in range 0 .. 1." severity warning;
    end case;
    if  (attr_err = '1') then
       assert FALSE
       report "Error : Attribute Error(s) encountered"
       severity error;
    end if;
    wait;
  end process INIPROC;

-- *********************************************************
-- *** Multiplier outputs U, V  with 1 level deep of register
-- *********************************************************

--  CLK_mreg <= CLK_in  when MREG_BIN = MREG_1 else '0';
  process (CLK_mreg) begin
    if (glblGSR = '1') then
      U_DATA_reg    <= '1' & X"00000000000";
      V_DATA_reg    <= '1' & X"00000000000";
    elsif (rising_edge(CLK_mreg)) then
      if (RSTM_in = '1') then
        U_DATA_reg    <= '1' & X"00000000000";
        V_DATA_reg    <= '1' & X"00000000000";
      elsif (CEM_in = '1') then
        U_DATA_reg    <= U_in;
        V_DATA_reg    <= V_in;
      end if;
    end if;
  end process;

  U_DATA_out    <= U_DATA_reg    when MREG_BIN = MREG_1 else U_in;
  V_DATA_out    <= V_DATA_reg    when MREG_BIN = MREG_1 else V_in;


-- any timing


end DSP_M_DATA_V;
