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
-- \   \  /  \    Filename    : DSP_PREADD_DATA.v 
--  \___\/\___\
-- 
-----------------------------------------------------------------------------
--  Revision:
--  07/15/12 - Migrate from E1.
--  12/10/12 - Add dynamic registers
--  01/11/13 - DIN, D_DATA width change (26/24) sync4 yml
--  04/22/13 - change from CLK'event to rising_edge(CLK)
--  04/23/13 - 714772 - remove sensitivity to negedge GSR
--  End Revision:
-----------------------------------------------------------------------------

----- CELL DSP_PREADD_DATA -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity DSP_PREADD_DATA is
  generic (
    ADREG      : integer := 1;
    AMULTSEL   : string := "A";
    BMULTSEL   : string := "B";
    DREG       : integer := 1;
    INMODEREG  : integer := 1;
    IS_CLK_INVERTED : std_ulogic := '0';
    IS_INMODE_INVERTED : std_logic_vector(4 downto 0) := "00000";
    IS_RSTD_INVERTED : std_ulogic := '0';
    IS_RSTINMODE_INVERTED : std_ulogic := '0';
    PREADDINSEL : string := "A";
    USE_MULT   : string := "MULTIPLY"
   );

  port (
    A2A1                 : out std_logic_vector(26 downto 0);
    ADDSUB               : out std_ulogic;
    AD_DATA              : out std_logic_vector(26 downto 0);
    B2B1                 : out std_logic_vector(17 downto 0);
    D_DATA               : out std_logic_vector(26 downto 0);
    INMODE_2             : out std_ulogic;
    PREADD_AB            : out std_logic_vector(26 downto 0);
    A1_DATA              : in std_logic_vector(26 downto 0);
    A2_DATA              : in std_logic_vector(26 downto 0);
    AD                   : in std_logic_vector(26 downto 0);
    B1_DATA              : in std_logic_vector(17 downto 0);
    B2_DATA              : in std_logic_vector(17 downto 0);
    CEAD                 : in std_ulogic;
    CED                  : in std_ulogic;
    CEINMODE             : in std_ulogic;
    CLK                  : in std_ulogic;
    DIN                  : in std_logic_vector(26 downto 0);
    INMODE               : in std_logic_vector(4 downto 0);
    RSTD                 : in std_ulogic;
    RSTINMODE            : in std_ulogic
   );
end DSP_PREADD_DATA;

architecture DSP_PREADD_DATA_V of DSP_PREADD_DATA is
--  define constants
  constant MODULE_NAME        : string := "DSP_PREADD_DATA";
  constant IN_DELAY           : time := 0 ps;
  constant OUT_DELAY          : time := 0 ps;
  constant INCLK_DELAY        : time := 0 ps;
  constant OUTCLK_DELAY       : time := 0 ps;

--  Parameter encodings and registers
  constant ADREG_0            : std_ulogic := '0';
  constant ADREG_1            : std_ulogic := '1';
  constant AMULTSEL_A         : std_ulogic := '0';
  constant AMULTSEL_AD        : std_ulogic := '1';
  constant BMULTSEL_AD        : std_ulogic := '1';
  constant BMULTSEL_B         : std_ulogic := '0';
  constant DREG_0             : std_ulogic := '0';
  constant DREG_1             : std_ulogic := '1';
  constant INMODEREG_0        : std_ulogic := '0';
  constant INMODEREG_1        : std_ulogic := '1';
  constant PREADDINSEL_A      : std_ulogic := '0';
  constant PREADDINSEL_B      : std_ulogic := '1';
  constant USE_MULT_DYNAMIC   : std_logic_vector(1 downto 0) := "11";
  constant USE_MULT_MULTIPLY  : std_logic_vector(1 downto 0) := "01";
  constant USE_MULT_NONE      : std_logic_vector(1 downto 0) := "10";

  signal ADREG_BIN              : std_ulogic;
  signal AMULTSEL_BIN           : std_ulogic;
  signal BMULTSEL_BIN           : std_ulogic;
  signal DREG_BIN               : std_ulogic;
  signal INMODEREG_BIN          : std_ulogic;
  signal PREADDINSEL_BIN        : std_ulogic;
  signal USE_MULT_BIN           : std_logic_vector(1 downto 0);

  signal glblGSR              : std_ulogic;

  signal attr_err             : std_ulogic := '0';

  signal A2A1_out             : std_logic_vector(26 downto 0);
  signal ADDSUB_out           : std_ulogic;
  signal AD_DATA_out          : std_logic_vector(26 downto 0);
  signal B2B1_out             : std_logic_vector(17 downto 0);
  signal D_DATA_out           : std_logic_vector(26 downto 0);
  signal INMODE_2_out         : std_ulogic;
  signal PREADD_AB_out        : std_logic_vector(26 downto 0);

  signal A2A1_delay           : std_logic_vector(26 downto 0);
  signal ADDSUB_delay         : std_ulogic;
  signal AD_DATA_delay        : std_logic_vector(26 downto 0);
  signal B2B1_delay           : std_logic_vector(17 downto 0);
  signal D_DATA_delay         : std_logic_vector(26 downto 0);
  signal INMODE_2_delay       : std_ulogic;
  signal PREADD_AB_delay      : std_logic_vector(26 downto 0);

  signal A1_DATA_delay        : std_logic_vector(26 downto 0);
  signal A2_DATA_delay        : std_logic_vector(26 downto 0);
  signal AD_delay             : std_logic_vector(26 downto 0);
  signal B1_DATA_delay        : std_logic_vector(17 downto 0);
  signal B2_DATA_delay        : std_logic_vector(17 downto 0);
  signal CEAD_delay           : std_ulogic;
  signal CED_delay            : std_ulogic;
  signal CEINMODE_delay       : std_ulogic;
  signal CLK_delay            : std_ulogic;
  signal DIN_delay            : std_logic_vector(26 downto 0);
  signal INMODE_delay         : std_logic_vector(4 downto 0);
  signal RSTD_delay           : std_ulogic;
  signal RSTINMODE_delay      : std_ulogic;

  signal A1_DATA_in           : std_logic_vector(26 downto 0);
  signal A2_DATA_in           : std_logic_vector(26 downto 0);
  signal AD_in                : std_logic_vector(26 downto 0);
  signal B1_DATA_in           : std_logic_vector(17 downto 0);
  signal B2_DATA_in           : std_logic_vector(17 downto 0);
  signal CEAD_in              : std_ulogic;
  signal CED_in               : std_ulogic;
  signal CEINMODE_in          : std_ulogic;
  signal DIN_in               : std_logic_vector(26 downto 0);
  signal INMODE_in            : std_logic_vector(4 downto 0);
  signal RSTD_in              : std_ulogic;
  signal RSTINMODE_in         : std_ulogic;


  signal a1a2_i_mux   : std_logic_vector(26 downto 0);
  signal b1b2_i_mux   : std_logic_vector(17 downto 0);
  signal b1b2_i_mux_17_9 : std_logic_vector(8 downto 0);
  signal INMODE_mux   : std_logic_vector(4 downto 0);
  signal INMODE_reg   : std_logic_vector(4 downto 0) := (others => '0');
  signal AD_DATA_reg  : std_logic_vector(26 downto 0) := (others => '0');
  signal D_DATA_reg   : std_logic_vector(26 downto 0) := (others => '0');
  signal CLK_inmode   : std_ulogic;
  signal CLK_dreg     : std_ulogic;
  signal CLK_adreg    : std_ulogic;

--  input output assignments
begin
   glblGSR          <= TO_X01(GSR);
   A2A1             <= A2A1_delay  after OUT_DELAY;
   ADDSUB           <= ADDSUB_delay  after OUT_DELAY;
   AD_DATA          <= AD_DATA_delay  after OUT_DELAY;
   B2B1             <= B2B1_delay  after OUT_DELAY;
   D_DATA           <= D_DATA_delay  after OUT_DELAY;
   INMODE_2         <= INMODE_2_delay  after OUT_DELAY;
   PREADD_AB        <= PREADD_AB_delay  after OUT_DELAY;

   A2A1_delay <= A2A1_out;
   ADDSUB_delay <= ADDSUB_out;
   AD_DATA_delay <= AD_DATA_out;
   B2B1_delay <= B2B1_out;
   D_DATA_delay <= D_DATA_out;
   INMODE_2_delay <= INMODE_2_out;
   PREADD_AB_delay <= PREADD_AB_out;

   CLK_delay           <= CLK after INCLK_DELAY;

   A1_DATA_delay       <= A1_DATA after IN_DELAY;
   A2_DATA_delay       <= A2_DATA after IN_DELAY;
   AD_delay            <= AD after IN_DELAY;
   B1_DATA_delay       <= B1_DATA after IN_DELAY;
   B2_DATA_delay       <= B2_DATA after IN_DELAY;
   CEAD_delay          <= CEAD after IN_DELAY;
   CED_delay           <= CED after IN_DELAY;
   CEINMODE_delay      <= CEINMODE after IN_DELAY;
   DIN_delay           <= DIN after IN_DELAY;
   INMODE_delay        <= INMODE after IN_DELAY;
   RSTD_delay          <= RSTD after IN_DELAY;
   RSTINMODE_delay     <= RSTINMODE after IN_DELAY;

   A1_DATA_in <= A1_DATA_delay;
   A2_DATA_in <= A2_DATA_delay;
   AD_in <= AD_delay;
   B1_DATA_in <= B1_DATA_delay;
   B2_DATA_in <= B2_DATA_delay;
   CEAD_in <= CEAD_delay;
   CED_in <= CED_delay;
   CEINMODE_in <= CEINMODE_delay;
   CLK_inmode <=  '0' when (INMODEREG_BIN = INMODEREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_dreg   <=  '0' when (DREG_BIN = DREG_0)           else CLK_delay xor IS_CLK_INVERTED;
   CLK_adreg  <=  '0' when (ADREG_BIN = ADREG_0)         else CLK_delay xor IS_CLK_INVERTED;
   DIN_in <= DIN_delay;
   INMODE_in <= INMODE_delay xor IS_INMODE_INVERTED;
   RSTD_in <= RSTD_delay xor IS_RSTD_INVERTED;
   RSTINMODE_in <= RSTINMODE_delay xor IS_RSTINMODE_INVERTED;

  INIPROC : process
  begin
-------- ADREG check
    case ADREG is
      when  1   =>  ADREG_BIN <= ADREG_1;
      when  0   =>  ADREG_BIN <= ADREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : ADREG is not in range 0 .. 1." severity warning;
    end case;
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
-------- DREG check
    case DREG is
      when  1   =>  DREG_BIN <= DREG_1;
      when  0   =>  DREG_BIN <= DREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : DREG is not in range 0 .. 1." severity warning;
    end case;
-------- INMODEREG check
    case INMODEREG is
      when  1   =>  INMODEREG_BIN <= INMODEREG_1;
      when  0   =>  INMODEREG_BIN <= INMODEREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : INMODEREG is not in range 0 .. 1." severity warning;
    end case;
-------- PREADDINSEL check
    -- case PREADDINSEL is
      if(PREADDINSEL = "A") then
        PREADDINSEL_BIN <= PREADDINSEL_A;
      elsif(PREADDINSEL = "B") then
        PREADDINSEL_BIN <= PREADDINSEL_B;
      else
        attr_err <= '1';
        assert FALSE report "Error : PREADDINSEL is not A, B." severity warning;
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

  a1a2_i_mux    <= A1_DATA_in      when INMODE_mux(0) = '1' else A2_DATA_in;
  b1b2_i_mux    <= B1_DATA_in      when INMODE_mux(4) = '1' else B2_DATA_in;
-- replace {9{b1b2_i_mux[17]}} shorthand
  b1b2_i_mux_17_9 <= "000000000" when b1b2_i_mux(17) = '0' else
                     "111111111";
  A2A1_out  <= (others => '0') when (INMODE_mux(1) = '1' and PREADDINSEL_BIN = PREADDINSEL_A)
                else a1a2_i_mux;
  B2B1_out  <= (others => '0') when (INMODE_mux(1) = '1' and PREADDINSEL_BIN = PREADDINSEL_B)
                else b1b2_i_mux;
  ADDSUB_out    <= INMODE_mux(3);
  INMODE_2_out  <= INMODE_mux(2);
  PREADD_AB_out <= (b1b2_i_mux_17_9 & B2B1_out) when PREADDINSEL_BIN = PREADDINSEL_B
                   else A2A1_out;

-- *********************************************************
-- **********  INMODE signal registering        ************
-- *********************************************************
--  new 
--  CLK_inmode  <=  CLK_in  when  INMODEREG_BIN = INMODEREG_1  else  '0';
  process (CLK_inmode) begin
    if  (glblGSR = '1') then INMODE_reg <= (others => '0');
    elsif (rising_edge(CLK_inmode)) then
      if    (RSTINMODE_in = '1') then INMODE_reg <= (others => '0');
      elsif (CEINMODE_in = '1')  then INMODE_reg <= INMODE_in;
      end if;
    end if;
  end process;

  INMODE_mux  <=  INMODE_reg  when  INMODEREG_BIN = INMODEREG_1  else  INMODE_in;

-- *********************************************************
-- *** Input register D with 1 level deep of register
-- *********************************************************
--  CLK_dreg  <=  CLK_in  when  DREG_BIN = DREG_1  else  '0';
  process (CLK_dreg) begin
    if (glblGSR = '1') then D_DATA_reg <= (others => '0');
    elsif (rising_edge(CLK_dreg)) then
      if    (RSTD_in = '1') then D_DATA_reg <= (others => '0');
      elsif (CED_in = '1')  then D_DATA_reg <= DIN_in;
      end if;
    end if;
  end process;

  D_DATA_out  <=  D_DATA_reg  when  DREG_BIN = DREG_1  else  DIN_in;

-- *********************************************************
-- *** Input register AD with 1 level deep of register
-- *********************************************************
--  CLK_adreg  <=  CLK_in  when  ADREG_BIN = ADREG_1  else  '0';
  process (CLK_adreg) begin
    if  (glblGSR = '1') then AD_DATA_reg <= (others => '0');
    elsif (rising_edge(CLK_adreg)) then
      if    (RSTD_in = '1') then AD_DATA_reg <= (others => '0');
      elsif (CEAD_in = '1') then AD_DATA_reg <= AD_in;
      end if;
    end if;
  end process;

  AD_DATA_out  <=  AD_DATA_reg  when  ADREG_BIN = ADREG_1  else  AD_in;


-- any timing


end DSP_PREADD_DATA_V;
