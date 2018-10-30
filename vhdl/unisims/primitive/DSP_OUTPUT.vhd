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
-- \   \  /  \    Filename    : DSP_OUTPUT.v 
--  \___\/\___\
-- 
-----------------------------------------------------------------------------
--  Revision:
--  07/15/12 - Migrate from E1.
--  12/10/12 - Add dynamic registers
--  04/03/13 - yaml update
--  04/22/13 - change from CLK'event to rising_edge(CLK)
--  04/23/13 - 714772 - remove sensitivity to negedge GSR
--  04/24/13 - 713706 - correct P_FDBK connection
--  End Revision:
-----------------------------------------------------------------------------

----- CELL DSP_OUTPUT -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity DSP_OUTPUT is
  generic (
    AUTORESET_PATDET : string := "NO_RESET";
    AUTORESET_PRIORITY : string := "RESET";
    IS_CLK_INVERTED : std_ulogic := '0';
    IS_RSTP_INVERTED : std_ulogic := '0';
    MASK       : std_logic_vector(47 downto 0) := X"3FFFFFFFFFFF";
    PATTERN    : std_logic_vector(47 downto 0) := X"000000000000";
    PREG       : integer := 1;
    SEL_MASK   : string := "MASK";
    SEL_PATTERN : string := "PATTERN";
    USE_PATTERN_DETECT : string := "NO_PATDET"
   );

  port (
    CARRYCASCOUT         : out std_ulogic;
    CARRYOUT             : out std_logic_vector(3 downto 0);
    CCOUT_FB             : out std_ulogic;
    MULTSIGNOUT          : out std_ulogic;
    OVERFLOW             : out std_ulogic;
    P                    : out std_logic_vector(47 downto 0);
    PATTERN_B_DETECT     : out std_ulogic;
    PATTERN_DETECT       : out std_ulogic;
    PCOUT                : out std_logic_vector(47 downto 0);
    P_FDBK               : out std_logic_vector(47 downto 0);
    P_FDBK_47            : out std_ulogic;
    UNDERFLOW            : out std_ulogic;
    XOROUT               : out std_logic_vector(7 downto 0);
    ALUMODE10            : in std_ulogic;
    ALU_OUT              : in std_logic_vector(47 downto 0);
    CEP                  : in std_ulogic;
    CLK                  : in std_ulogic;
    COUT                 : in std_logic_vector(3 downto 0);
    C_DATA               : in std_logic_vector(47 downto 0);
    MULTSIGN_ALU         : in std_ulogic;
    RSTP                 : in std_ulogic;
    XOR_MX               : in std_logic_vector(7 downto 0)
   );
end DSP_OUTPUT;

architecture DSP_OUTPUT_V of DSP_OUTPUT is
--  define constants
  constant MODULE_NAME        : string := "DSP_OUTPUT";
  constant IN_DELAY           : time := 0 ps;
  constant OUT_DELAY          : time := 0 ps;
  constant INCLK_DELAY        : time := 0 ps;
  constant OUTCLK_DELAY       : time := 0 ps;

--  Parameter encodings and registers
  constant AUTORESET_PATDET_NO_RESET : std_logic_vector(1 downto 0) := "00";
  constant AUTORESET_PATDET_RESET_MATCH : std_logic_vector(1 downto 0) := "10";
  constant AUTORESET_PATDET_RESET_NOT_MATCH : std_logic_vector(1 downto 0) := "11";
  constant AUTORESET_PRIORITY_CEP : std_ulogic := '1';
  constant AUTORESET_PRIORITY_RESET : std_ulogic := '0';
  constant PREG_0             : std_ulogic := '0';
  constant PREG_1             : std_ulogic := '1';
  constant SEL_MASK_C              : std_logic_vector(2 downto 0) := "001";
  constant SEL_MASK_MASK           : std_logic_vector(2 downto 0) := "000";
  constant SEL_MASK_ROUNDING_MODE1 : std_logic_vector(2 downto 0) := "010";
  constant SEL_MASK_ROUNDING_MODE2 : std_logic_vector(2 downto 0) := "110";
  constant SEL_PATTERN_C       : std_ulogic := '1';
  constant SEL_PATTERN_PATTERN : std_ulogic := '0';
  constant USE_PATTERN_DETECT_NO_PATDET : std_ulogic := '0';
  constant USE_PATTERN_DETECT_PATDET    : std_ulogic := '1';

  signal AUTORESET_PATDET_BIN   : std_logic_vector(1 downto 0);
  signal AUTORESET_PRIORITY_BIN : std_ulogic;
  signal MASK_BIN               : std_logic_vector(47 downto 0);
  signal PATTERN_BIN            : std_logic_vector(47 downto 0);
  signal PREG_BIN               : std_ulogic;
  signal SEL_MASK_BIN           : std_logic_vector(2 downto 0);
  signal SEL_PATTERN_BIN        : std_ulogic;
  signal USE_PATTERN_DETECT_BIN : std_ulogic;

  signal glblGSR              : std_ulogic;

  signal attr_err             : std_ulogic := '0';

  signal CARRYCASCOUT_out     : std_ulogic;
  signal CARRYOUT_out         : std_logic_vector(3 downto 0);
  signal CCOUT_FB_out         : std_ulogic;
  signal MULTSIGNOUT_out      : std_ulogic;
  signal OVERFLOW_out         : std_ulogic;
  signal PATTERN_B_DETECT_out : std_ulogic;
  signal PATTERN_DETECT_out   : std_ulogic;
  signal PCOUT_out            : std_logic_vector(47 downto 0);
  signal P_FDBK_47_out        : std_ulogic;
  signal P_FDBK_out           : std_logic_vector(47 downto 0);
  signal P_out                : std_logic_vector(47 downto 0);
  signal UNDERFLOW_out        : std_ulogic;
  signal XOROUT_out           : std_logic_vector(7 downto 0);

  signal CARRYCASCOUT_delay   : std_ulogic;
  signal CARRYOUT_delay       : std_logic_vector(3 downto 0);
  signal CCOUT_FB_delay       : std_ulogic;
  signal MULTSIGNOUT_delay    : std_ulogic;
  signal OVERFLOW_delay       : std_ulogic;
  signal PATTERN_B_DETECT_delay : std_ulogic;
  signal PATTERN_DETECT_delay : std_ulogic;
  signal PCOUT_delay          : std_logic_vector(47 downto 0);
  signal P_delay              : std_logic_vector(47 downto 0);
  signal P_FDBK_47_delay      : std_ulogic;
  signal P_FDBK_delay         : std_logic_vector(47 downto 0);
  signal UNDERFLOW_delay      : std_ulogic;
  signal XOROUT_delay         : std_logic_vector(7 downto 0);

  signal ALUMODE10_delay      : std_ulogic;
  signal ALU_OUT_delay        : std_logic_vector(47 downto 0);
  signal CEP_delay            : std_ulogic;
  signal CLK_delay            : std_ulogic;
  signal COUT_delay           : std_logic_vector(3 downto 0);
  signal C_DATA_delay         : std_logic_vector(47 downto 0);
  signal MULTSIGN_ALU_delay   : std_ulogic;
  signal RSTP_delay           : std_ulogic;
  signal XOR_MX_delay         : std_logic_vector(7 downto 0);

  signal ALUMODE10_in         : std_ulogic;
  signal ALU_OUT_in           : std_logic_vector(47 downto 0);
  signal CEP_in               : std_ulogic;
  signal COUT_in              : std_logic_vector(3 downto 0);
  signal C_DATA_in            : std_logic_vector(47 downto 0);
  signal MULTSIGN_ALU_in      : std_ulogic;
  signal RSTP_in              : std_ulogic;
  signal XOR_MX_in            : std_logic_vector(7 downto 0);

  signal the_auto_reset_patdet : std_ulogic;
  signal auto_reset_pri        : std_ulogic;
  signal the_mask         : std_logic_vector(47 downto 0) := (others => '0');
  signal the_pattern      : std_logic_vector(47 downto 0) := (others => '0');
  signal opmode_valid_flag_dou : boolean := true; -- TODO

  signal COUT_reg         : std_logic_vector(3 downto 0) := "0000";
  signal ALUMODE10_reg    : std_ulogic := '0';
  signal ALUMODE10_mux    : std_ulogic := '0';
  signal MULTSIGN_ALU_reg : std_ulogic := '0';
  signal ALU_OUT_reg      : std_logic_vector(47 downto 0) := (others => '0');
  signal XOR_MX_reg       : std_logic_vector(7 downto 0) := (others => '0');

  signal pdet_o               : std_ulogic;
  signal pdetb_o              : std_ulogic;
  signal pdet_o_mux           : std_ulogic;
  signal pdetb_o_mux          : std_ulogic;
  signal overflow_data        : std_ulogic;
  signal underflow_data       : std_ulogic;
  signal pdet_o_reg1          : std_ulogic := '0';
  signal pdet_o_reg2          : std_ulogic := '0';
  signal pdetb_o_reg1         : std_ulogic := '0';
  signal pdetb_o_reg2         : std_ulogic := '0';
  signal CLK_preg             : std_ulogic;

--  input output assignments
begin
   glblGSR          <= TO_X01(GSR);
   CARRYCASCOUT     <= CARRYCASCOUT_delay  after OUT_DELAY;
   CARRYOUT         <= CARRYOUT_delay  after OUT_DELAY;
   CCOUT_FB         <= CCOUT_FB_delay  after OUT_DELAY;
   MULTSIGNOUT      <= MULTSIGNOUT_delay  after OUT_DELAY;
   OVERFLOW         <= OVERFLOW_delay  after OUT_DELAY;
   P                <= P_delay  after OUT_DELAY;
   PATTERN_B_DETECT <= PATTERN_B_DETECT_delay  after OUT_DELAY;
   PATTERN_DETECT   <= PATTERN_DETECT_delay  after OUT_DELAY;
   PCOUT            <= PCOUT_delay  after OUT_DELAY;
   P_FDBK           <= P_FDBK_delay  after OUT_DELAY;
   P_FDBK_47        <= P_FDBK_47_delay  after OUT_DELAY;
   UNDERFLOW        <= UNDERFLOW_delay  after OUT_DELAY;
   XOROUT           <= XOROUT_delay  after OUT_DELAY;

   CARRYCASCOUT_delay <= CARRYCASCOUT_out;
   CARRYOUT_delay <= CARRYOUT_out;
   CCOUT_FB_delay <= CCOUT_FB_out;
   MULTSIGNOUT_delay <= MULTSIGNOUT_out;
   OVERFLOW_delay <= OVERFLOW_out;
   PATTERN_B_DETECT_delay <= PATTERN_B_DETECT_out;
   PATTERN_DETECT_delay <= PATTERN_DETECT_out;
   PCOUT_delay <= PCOUT_out;
   P_FDBK_47_delay <= P_FDBK_47_out;
   P_FDBK_delay <= P_FDBK_out;
   P_delay <= P_out;
   UNDERFLOW_delay <= UNDERFLOW_out;
   XOROUT_delay <= XOROUT_out;

   CLK_delay           <= CLK after INCLK_DELAY;

   ALUMODE10_delay     <= ALUMODE10 after IN_DELAY;
   ALU_OUT_delay       <= ALU_OUT after IN_DELAY;
   CEP_delay           <= CEP after IN_DELAY;
   COUT_delay          <= COUT after IN_DELAY;
   C_DATA_delay        <= C_DATA after IN_DELAY;
   MULTSIGN_ALU_delay  <= MULTSIGN_ALU after IN_DELAY;
   RSTP_delay          <= RSTP after IN_DELAY;
   XOR_MX_delay        <= XOR_MX after IN_DELAY;

   ALUMODE10_in <= ALUMODE10_delay;
   ALU_OUT_in <= ALU_OUT_delay after 1 ps; --  break 0 delay feedback
   CEP_in <= CEP_delay;
   CLK_preg  <= '0' when (PREG_BIN = PREG_0) else CLK_delay xor IS_CLK_INVERTED;
   COUT_in <= COUT_delay;
   C_DATA_in <= C_DATA_delay;
   MULTSIGN_ALU_in <= MULTSIGN_ALU_delay;
   RSTP_in <= RSTP_delay xor IS_RSTP_INVERTED;
   XOR_MX_in <= XOR_MX_delay;

  INIPROC : process
  begin
-------- AUTORESET_PATDET check
    -- case AUTORESET_PATDET is
      if(AUTORESET_PATDET = "NO_RESET") then
        AUTORESET_PATDET_BIN <= AUTORESET_PATDET_NO_RESET;
      elsif(AUTORESET_PATDET = "RESET_MATCH") then
        AUTORESET_PATDET_BIN <= AUTORESET_PATDET_RESET_MATCH;
      elsif(AUTORESET_PATDET = "RESET_NOT_MATCH") then
        AUTORESET_PATDET_BIN <= AUTORESET_PATDET_RESET_NOT_MATCH;
      else
        attr_err <= '1';
        assert FALSE report "Error : AUTORESET_PATDET is not NO_RESET, RESET_MATCH, RESET_NOT_MATCH." severity warning;
      end if;
    -- end case;
-------- AUTORESET_PRIORITY check
    -- case AUTORESET_PRIORITY is
      if(AUTORESET_PRIORITY = "RESET") then
        AUTORESET_PRIORITY_BIN <= AUTORESET_PRIORITY_RESET;
      elsif(AUTORESET_PRIORITY = "CEP") then
        AUTORESET_PRIORITY_BIN <= AUTORESET_PRIORITY_CEP;
      else
        attr_err <= '1';
        assert FALSE report "Error : AUTORESET_PRIORITY is not RESET, CEP." severity warning;
      end if;
    -- end case;
-------- MASK check
    MASK_BIN <= MASK;

-------- PATTERN check
    PATTERN_BIN <= PATTERN;

-------- PREG check
    case PREG is
      when  1   =>  PREG_BIN <= PREG_1;
      when  0   =>  PREG_BIN <= PREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : PREG is not in range 0 .. 1." severity warning;
    end case;
-------- SEL_MASK check
    -- case SEL_MASK is
      if(SEL_MASK = "MASK") then
        SEL_MASK_BIN <= SEL_MASK_MASK;
      elsif(SEL_MASK = "C") then
        SEL_MASK_BIN <= SEL_MASK_C;
      elsif(SEL_MASK = "ROUNDING_MODE1") then
        SEL_MASK_BIN <= SEL_MASK_ROUNDING_MODE1;
      elsif(SEL_MASK = "ROUNDING_MODE2") then
        SEL_MASK_BIN <= SEL_MASK_ROUNDING_MODE2;
      else
        attr_err <= '1';
        assert FALSE report "Error : SEL_MASK is not MASK, C, ROUNDING_MODE1, ROUNDING_MODE2." severity warning;
      end if;
    -- end case;
-------- SEL_PATTERN check
    -- case SEL_PATTERN is
      if(SEL_PATTERN = "PATTERN") then
        SEL_PATTERN_BIN <= SEL_PATTERN_PATTERN;
      elsif(SEL_PATTERN = "C") then
        SEL_PATTERN_BIN <= SEL_PATTERN_C;
      else
        attr_err <= '1';
        assert FALSE report "Error : SEL_PATTERN is not PATTERN, C." severity warning;
      end if;
    -- end case;
-------- USE_PATTERN_DETECT check
    -- case USE_PATTERN_DETECT is
      if(USE_PATTERN_DETECT = "NO_PATDET") then
        USE_PATTERN_DETECT_BIN <= USE_PATTERN_DETECT_NO_PATDET;
      elsif(USE_PATTERN_DETECT = "PATDET") then
        USE_PATTERN_DETECT_BIN <= USE_PATTERN_DETECT_PATDET;
      else
        attr_err <= '1';
        assert FALSE report "Error : USE_PATTERN_DETECT is not NO_PATDET, PATDET." severity warning;
      end if;
    -- end case;
    if  (attr_err = '1') then
       assert FALSE
       report "Error : Attribute Error(s) encountered"
       severity error;
    end if;
    wait;
  end process INIPROC;

-- --####################################################################
-- --#####                    Pattern Detector                      #####
-- --####################################################################

--  new

--  select pattern
  the_pattern <= PATTERN_BIN when SEL_PATTERN_BIN = SEL_PATTERN_PATTERN else C_DATA_in;

--  selet mask
  the_mask <= C_DATA_in when (SEL_MASK_BIN = SEL_MASK_C) else
      (not(C_DATA_in(46 downto 0)) & '0')  when (SEL_MASK_BIN = SEL_MASK_ROUNDING_MODE1) else
      (not(C_DATA_in(45 downto 0)) & "00") when (SEL_MASK_BIN = SEL_MASK_ROUNDING_MODE2) else
      MASK_BIN;

--  process (C_DATA_in) begin
--    case  SEL_MASK_BIN  is
--      when  SEL_MASK_MASK           => the_mask <= MASK_BIN;
--      when  SEL_MASK_C              => the_mask <= C_DATA_in;
--      when  SEL_MASK_ROUNDING_MODE1 =>
--                       the_mask <= not(C_DATA_in (46 downto 0) & '0');
--      when  SEL_MASK_ROUNDING_MODE2 =>
--                       the_mask <= not(C_DATA_in (45 downto 0) & "00");
--      when  others                  => the_mask <= MASK_BIN;
--    end case;
--  end process;

-- --  now do the pattern detection

  pdet_o  <= '1' when (    the_pattern or the_mask) = (ALU_OUT_in or the_mask)
                 else '0';
  pdetb_o <= '1' when (not the_pattern or the_mask) = (ALU_OUT_in or the_mask)
                 else '0';

  PATTERN_DETECT_out   <= pdet_o_mux  when opmode_valid_flag_dou else 'X';
  PATTERN_B_DETECT_out <= pdetb_o_mux when opmode_valid_flag_dou else 'X';

--  CLK_preg  <=  CLK_in  when  PREG_BIN = PREG_1  else  '0';

-- *** Output register PATTERN DETECT and UNDERFLOW / OVERFLOW 

-- -- the previous values are used in Underflow/Overflow
  process (CLK_preg) begin
    if (glblGSR = '1') then
      pdet_o_reg1  <= '0';
      pdet_o_reg2  <= '0';
      pdetb_o_reg1 <= '0';
      pdetb_o_reg2 <= '0';
    elsif (rising_edge(CLK_preg)) then
      if (RSTP_in = '1' or the_auto_reset_patdet = '1') then
        pdet_o_reg1  <= '0';
        pdet_o_reg2  <= '0';
        pdetb_o_reg1 <= '0';
        pdetb_o_reg2 <= '0';
      elsif  (CEP_in = '1') then
        pdet_o_reg2  <= pdet_o_reg1;
        pdet_o_reg1  <= pdet_o;
        pdetb_o_reg2 <= pdetb_o_reg1;
        pdetb_o_reg1 <= pdetb_o;
      end if;
    end if;
  end process;

  pdet_o_mux     <= pdet_o_reg1  when (PREG_BIN = PREG_1) else pdet_o;
  pdetb_o_mux    <= pdetb_o_reg1 when (PREG_BIN = PREG_1) else pdetb_o;
  overflow_data  <= pdet_o_reg2  when (PREG_BIN = PREG_1) else pdet_o;
  underflow_data <= pdetb_o_reg2 when (PREG_BIN = PREG_1) else pdetb_o;

-- --####################################################################
-- --#####                     AUTORESET_PATDET                     #####
-- --####################################################################
  auto_reset_pri <= '1' when (AUTORESET_PRIORITY_BIN = AUTORESET_PRIORITY_RESET) else CEP_in;

  the_auto_reset_patdet <= auto_reset_pri and pdet_o_mux
           when (AUTORESET_PATDET_BIN = AUTORESET_PATDET_RESET_MATCH) else
                           auto_reset_pri and overflow_data and not pdet_o_mux
           when (AUTORESET_PATDET_BIN = AUTORESET_PATDET_RESET_NOT_MATCH) else
                           '0'; -- _RESET
--  the_auto_reset_patdet <= '1' when
--  (((AUTORESET_PATDET_BIN = AUTORESET_PATDET_RESET_MATCH) and
--    (pdet_o_reg1 = '1')) or
--   ((AUTORESET_PATDET_BIN = AUTORESET_PATDET_RESET_NOT_MATCH) and
--    ((pdet_o_reg2 = '1') and (pdet_o_reg1 = '0')))) and
--  ((CEP_in = '1') or
--   (AUTORESET_PRIORITY_BIN = AUTORESET_PRIORITY_RESET)) else '0';

-- --####################################################################
-- --#### CARRYOUT, CARRYCASCOUT. MULTSIGNOUT, PCOUT and XOROUT reg ##### 
-- --####################################################################
-- *** register with 1 level of register
  process (CLK_preg) begin
    if (glblGSR = '1') then
      COUT_reg <= "0000";
      ALUMODE10_reg <= '0';
      MULTSIGN_ALU_reg <= '0';
      ALU_OUT_reg <= (others => '0');
      XOR_MX_reg <= (others => '0');
    elsif (rising_edge(CLK_preg)) then
      if  (RSTP_in = '1' or the_auto_reset_patdet = '1') then
        COUT_reg <= "0000";
        ALUMODE10_reg <= '0';
        MULTSIGN_ALU_reg <= '0';
        ALU_OUT_reg <= (others => '0');
        XOR_MX_reg <= (others => '0');
      elsif (CEP_in = '1') then
        COUT_reg <= COUT_in;
        ALUMODE10_reg <= ALUMODE10_in;
        MULTSIGN_ALU_reg <= MULTSIGN_ALU_in;
        ALU_OUT_reg <= ALU_OUT_in;
        XOR_MX_reg <= XOR_MX_in;
      end if;
    end if;
  end process;

 CARRYOUT_out    <= COUT_reg         when PREG_BIN = PREG_1 else COUT_in;
 MULTSIGNOUT_out <= MULTSIGN_ALU_reg when PREG_BIN = PREG_1 else MULTSIGN_ALU_in;
 P_out           <= ALU_OUT_reg      when PREG_BIN = PREG_1 else ALU_OUT_in;
 ALUMODE10_mux   <= ALUMODE10_reg    when PREG_BIN = PREG_1 else ALUMODE10_in;
 XOROUT_out      <= XOR_MX_reg       when PREG_BIN = PREG_1 else XOR_MX_in;
 CCOUT_FB_out     <= ALUMODE10_reg xor COUT_reg(3);
 CARRYCASCOUT_out <= ALUMODE10_mux xor CARRYOUT_out(3);
 P_FDBK_out      <= ALU_OUT_reg      when PREG_BIN = PREG_1 else ALU_OUT_in;
 P_FDBK_47_out   <= ALU_OUT_reg(47)  when PREG_BIN = PREG_1 else ALU_OUT_in(47);
 PCOUT_out       <= ALU_OUT_reg      when PREG_BIN = PREG_1 else ALU_OUT_in;


-- --####################################################################
-- --#####                    Underflow / Overflow                  #####
-- --####################################################################

  OVERFLOW_out  <= not pdet_o_mux and not pdetb_o_mux and overflow_data when
                ((USE_PATTERN_DETECT_BIN = USE_PATTERN_DETECT_PATDET) or (PREG_BIN = PREG_1))
                   else 'X';
  UNDERFLOW_out <= not pdet_o_mux and not pdetb_o_mux and underflow_data when
                ((USE_PATTERN_DETECT_BIN = USE_PATTERN_DETECT_PATDET) or (PREG_BIN = PREG_1))
                   else 'X';


-- any timing


end DSP_OUTPUT_V;
