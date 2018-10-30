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
-- \   \  /  \    Filename    : DSP_MULTIPLIER.v 
--  \___\/\___\
-- 
-----------------------------------------------------------------------------
--  Revision:
--  07/15/12 - Migrate from E1.
--  12/10/12 - Add dynamic registers
--  End Revision:
-----------------------------------------------------------------------------

----- CELL DSP_MULTIPLIER -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity DSP_MULTIPLIER is
  generic (
    AMULTSEL   : string := "A";
    BMULTSEL   : string := "B";
    USE_MULT   : string := "MULTIPLY"
   );

  port (
    AMULT26              : out std_ulogic;
    BMULT17              : out std_ulogic;
    U                    : out std_logic_vector(44 downto 0);
    V                    : out std_logic_vector(44 downto 0);
    A2A1                 : in std_logic_vector(26 downto 0);
    AD_DATA              : in std_logic_vector(26 downto 0);
    B2B1                 : in std_logic_vector(17 downto 0)
   );
end DSP_MULTIPLIER;

architecture DSP_MULTIPLIER_V of DSP_MULTIPLIER is
--  define constants
  constant MODULE_NAME        : string := "DSP_MULTIPLIER";
  constant IN_DELAY           : time := 0 ps;
  constant OUT_DELAY          : time := 0 ps;
  constant INCLK_DELAY        : time := 0 ps;
  constant OUTCLK_DELAY       : time := 0 ps;

--  Parameter encodings and registers
  constant AMULTSEL_A         : std_ulogic := '0';
  constant AMULTSEL_AD        : std_ulogic := '1';
  constant BMULTSEL_AD        : std_ulogic := '1';
  constant BMULTSEL_B         : std_ulogic := '0';
  constant USE_MULT_DYNAMIC   : std_logic_vector(1 downto 0) := "11";
  constant USE_MULT_MULTIPLY  : std_logic_vector(1 downto 0) := "01";
  constant USE_MULT_NONE      : std_logic_vector(1 downto 0) := "10";

  signal AMULTSEL_BIN           : std_ulogic;
  signal BMULTSEL_BIN           : std_ulogic;
  signal USE_MULT_BIN           : std_logic_vector(1 downto 0);

  signal glblGSR              : std_ulogic;

  signal attr_err             : std_ulogic := '0';

  signal AMULT26_out          : std_ulogic;
  signal BMULT17_out          : std_ulogic;
  signal U_out                : std_logic_vector(44 downto 0);
  signal V_out                : std_logic_vector(44 downto 0);

  signal AMULT26_delay        : std_ulogic;
  signal BMULT17_delay        : std_ulogic;
  signal U_delay              : std_logic_vector(44 downto 0);
  signal V_delay              : std_logic_vector(44 downto 0);

  signal A2A1_delay           : std_logic_vector(26 downto 0);
  signal AD_DATA_delay        : std_logic_vector(26 downto 0);
  signal B2B1_delay           : std_logic_vector(17 downto 0);

  signal A2A1_in              : std_logic_vector(26 downto 0);
  signal AD_DATA_in           : std_logic_vector(26 downto 0);
  signal B2B1_in              : std_logic_vector(17 downto 0);

  signal b_mult_mux       : signed (17 downto 0);
  signal a_mult_mux_26_18 : unsigned (17 downto 0);
  signal a_mult_mux       : signed (26 downto 0);
  signal b_mult_mux_17_27 : unsigned (26 downto 0);
  signal mult      : signed (44 downto 0);
  signal ps_u_mask : unsigned (43 downto 0) := X"55555555555";
  signal ps_v_mask : unsigned (43 downto 0) := X"aaaaaaaaaaa";

--  input output assignments
begin
   glblGSR          <= TO_X01(GSR);
   AMULT26          <= AMULT26_delay  after OUT_DELAY;
   BMULT17          <= BMULT17_delay  after OUT_DELAY;
   U                <= U_delay  after OUT_DELAY;
   V                <= V_delay  after OUT_DELAY;

   AMULT26_delay <= AMULT26_out;
   BMULT17_delay <= BMULT17_out;
   U_delay <= U_out;
   V_delay <= V_out;

   A2A1_delay          <= A2A1 after IN_DELAY;
   AD_DATA_delay       <= AD_DATA after IN_DELAY;
   B2B1_delay          <= B2B1 after IN_DELAY;

   A2A1_in <= A2A1_delay;
   AD_DATA_in <= AD_DATA_delay;
   B2B1_in <= B2B1_delay;

  INIPROC : process
  begin
-------- AMULTSEL check
    -- case AMULTSEL is
      if(AMULTSEL = "A") then
        AMULTSEL_BIN <= AMULTSEL_A;
      elsif(AMULTSEL = "AD") then
        AMULTSEL_BIN <= AMULTSEL_AD;
      else
        attr_err <= '1';
        assert FALSE report "Error : AMULTSEL is not A, AD." severity warning;
      end if;
    -- end case;
-------- BMULTSEL check
    -- case BMULTSEL is
      if(BMULTSEL = "B") then
        BMULTSEL_BIN <= BMULTSEL_B;
      elsif(BMULTSEL = "AD") then
        BMULTSEL_BIN <= BMULTSEL_AD;
      else
        attr_err <= '1';
        assert FALSE report "Error : BMULTSEL is not B, AD." severity warning;
      end if;
    -- end case;
-------- USE_MULT check
    -- case USE_MULT is
      if(USE_MULT = "MULTIPLY") then
        USE_MULT_BIN <= USE_MULT_MULTIPLY;
      elsif(USE_MULT = "DYNAMIC") then
        USE_MULT_BIN <= USE_MULT_DYNAMIC;
      elsif(USE_MULT = "NONE") then
        USE_MULT_BIN <= USE_MULT_NONE;
      else
        attr_err <= '1';
        assert FALSE report "Error : USE_MULT is not MULTIPLY, DYNAMIC, NONE." severity warning;
      end if;
    -- end case;
    if  (attr_err = '1') then
       assert FALSE
       report "Error : Attribute Error(s) encountered"
       severity error;
    end if;
    wait;
  end process INIPROC;

  a_mult_mux <= signed(A2A1_in) when AMULTSEL_BIN = AMULTSEL_A else
                signed(AD_DATA_in);
  b_mult_mux <= signed(B2B1_in) when BMULTSEL_BIN = BMULTSEL_B else
                signed(AD_DATA_in(17 downto 0)) ;
-- replace {18{a_mult_mux[26]}} shorthand
  a_mult_mux_26_18 <= "000000000000000000" when a_mult_mux(26) = '0' else
                      "111111111111111111";
-- replace {27{b_mult_mux[17]}} shorthand
  b_mult_mux_17_27 <= "000000000000000000000000000" when b_mult_mux(17) = '0' else
                      "111111111111111111111111111";

  AMULT26_out <= a_mult_mux(26);
  BMULT17_out <= b_mult_mux(17);
  U_out <= std_logic_vector('1'          & (unsigned(mult(43 downto 0)) and ps_u_mask));
  V_out <= std_logic_vector(not mult(44) & (unsigned(mult(43 downto 0)) and ps_v_mask));

  mult <= (others => '0') when USE_MULT_BIN = USE_MULT_NONE else
          a_mult_mux * b_mult_mux;
--          (a_mult_mux_26_18 & a_mult_mux) * (b_mult_mux_17_27 & b_mult_mux);


-- any timing


end DSP_MULTIPLIER_V;
