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
-- \   \  /  \    Filename    : DSP_C_DATA.v 
--  \___\/\___\
-- 
-----------------------------------------------------------------------------
--  Revision:
--  07/15/12 - Migrate from E1.
--  12/10/12 - Add dynamic registers
--  04/22/13 - change from CLK'event to rising_edge(CLK)
--  04/23/13 - 714772 - remove sensitivity to negedge GSR
--  End Revision:
-----------------------------------------------------------------------------

----- CELL DSP_C_DATA -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity DSP_C_DATA is
  generic (
    CREG       : integer := 1;
    IS_CLK_INVERTED : std_ulogic := '0';
    IS_RSTC_INVERTED : std_ulogic := '0'
   );

  port (
    C_DATA               : out std_logic_vector(47 downto 0);
    C                    : in std_logic_vector(47 downto 0);
    CEC                  : in std_ulogic;
    CLK                  : in std_ulogic;
    RSTC                 : in std_ulogic
   );
end DSP_C_DATA;

architecture DSP_C_DATA_V of DSP_C_DATA is
--  define constants
  constant MODULE_NAME        : string := "DSP_C_DATA";
  constant IN_DELAY           : time := 0 ps;
  constant OUT_DELAY          : time := 0 ps;
  constant INCLK_DELAY        : time := 0 ps;
  constant OUTCLK_DELAY       : time := 0 ps;

--  Parameter encodings and registers
  constant CREG_0             : std_ulogic := '0';
  constant CREG_1             : std_ulogic := '1';

  signal CREG_BIN               : std_ulogic;

  signal glblGSR              : std_ulogic;

  signal attr_err             : std_ulogic := '0';

  signal C_DATA_out           : std_logic_vector(47 downto 0);

  signal C_DATA_delay         : std_logic_vector(47 downto 0);

  signal CEC_delay            : std_ulogic;
  signal CLK_delay            : std_ulogic;
  signal C_delay              : std_logic_vector(47 downto 0);
  signal RSTC_delay           : std_ulogic;

  signal CEC_in               : std_ulogic;
  signal C_in                 : std_logic_vector(47 downto 0);
  signal RSTC_in              : std_ulogic;


  signal C_reg                : std_logic_vector(47 downto 0) := (others => '0');
  signal CLK_creg             : std_ulogic;

--  input output assignments
begin
   glblGSR          <= TO_X01(GSR);
   C_DATA           <= C_DATA_delay  after OUT_DELAY;

   C_DATA_delay <= C_DATA_out;

   CLK_delay           <= CLK after INCLK_DELAY;

   CEC_delay           <= CEC after IN_DELAY;
   C_delay             <= C after IN_DELAY;
   RSTC_delay          <= RSTC after IN_DELAY;

   CEC_in <= CEC_delay;
   CLK_creg  <= '0' when (CREG_BIN = CREG_0) else CLK_delay xor IS_CLK_INVERTED;
   C_in <= C_delay;
   RSTC_in <= RSTC_delay xor IS_RSTC_INVERTED;

  INIPROC : process
  begin
-------- CREG check
    case CREG is
      when  1   =>  CREG_BIN <= CREG_1;
      when  0   =>  CREG_BIN <= CREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : CREG is not in range 0 .. 1." severity warning;
    end case;
    if  (attr_err = '1') then
       assert FALSE
       report "Error : Attribute Error(s) encountered"
       severity error;
    end if;
    wait;
  end process INIPROC;

-- *********************************************************
-- *** Input register C with 1 level deep of register
-- *********************************************************

--  CLK_creg  <=  CLK_in  when  CREG_BIN = CREG_1  else  '0';

  process (CLK_creg) begin
    if  (glblGSR = '1') then C_reg <= (others => '0');
    elsif (rising_edge(CLK_creg)) then
      if    (RSTC_in = '1') then C_reg <= (others => '0');
      elsif (CEC_in = '1')  then C_reg <= C_in;
      end if;
    end if;
  end process;

  C_DATA_out  <=  C_reg  when  CREG_BIN = CREG_1  else  C_in;


-- any timing


end DSP_C_DATA_V;
