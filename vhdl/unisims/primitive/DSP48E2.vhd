-----------------------------------------------------------------------------
--  Copyright (c) 2012 Xilinx Inc.
--  All Right Reserved.
-----------------------------------------------------------------------------
-- 
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor      : Xilinx
-- \   \   \/     Version     : 2012.2
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                       27X18 Signed Multiplier Followed by Three-Input
-- /___/   /\                   Adder plus ALU with Pipeline Registers
-- \   \  /  \    Filename    : DSP48E2.v 
--  \___\/\___\
-- 
-----------------------------------------------------------------------------
--  Revision:
--  07/15/12 - Migrate from E1.
--  12/10/12 - Add dynamic registers
--  01/10/13 - 694456 - DIN_in/D_in connectivity issue
--  01/11/13 - DIN, D_DATA width change (26/24) sync4 yml
--  02/13/13 - PCIN_47A change from internal feedback to PCIN(47) pin
--  03/01/13 - 699402 - U_44_DATA_3 missing from xmux process sensitivity list
--  03/06/13 - 701316 - A_B_reg no clk when REG=0
--  04/03/13 - yaml update
--  04/22/13 - 714213 - ACOUT, BCOUT wrong logic
--  04/22/13 - 713695 - Zero mult result on USE_SIMD
--  04/22/13 - 713617 - CARRYCASCOUT behaviour
--  04/22/13 - change from CLK'event to rising_edge(CLK)
--  04/23/13 - 714772 - remove sensitivity to negedge GSR
--  04/24/13 - 713706 - correct P_FDBK connection
--  06/13/13 - 722112 - x_mac_cascd missing from process sensitivity list
--  End Revision:
-----------------------------------------------------------------------------

----- CELL DSP48E2 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity DSP48E2 is
  generic (
    ACASCREG   : integer := 1;
    ADREG      : integer := 1;
    ALUMODEREG : integer := 1;
    AMULTSEL   : string := "A";
    AREG       : integer := 1;
    AUTORESET_PATDET : string := "NO_RESET";
    AUTORESET_PRIORITY : string := "RESET";
    A_INPUT    : string := "DIRECT";
    BCASCREG   : integer := 1;
    BMULTSEL   : string := "B";
    BREG       : integer := 1;
    B_INPUT    : string := "DIRECT";
    CARRYINREG : integer := 1;
    CARRYINSELREG : integer := 1;
    CREG       : integer := 1;
    DREG       : integer := 1;
    INMODEREG  : integer := 1;
    IS_ALUMODE_INVERTED : std_logic_vector(3 downto 0) := "0000";
    IS_CARRYIN_INVERTED : std_ulogic := '0';
    IS_CLK_INVERTED : std_ulogic := '0';
    IS_INMODE_INVERTED : std_logic_vector(4 downto 0) := "00000";
    IS_OPMODE_INVERTED : std_logic_vector(8 downto 0) := "000000000";
    IS_RSTALLCARRYIN_INVERTED : std_ulogic := '0';
    IS_RSTALUMODE_INVERTED : std_ulogic := '0';
    IS_RSTA_INVERTED : std_ulogic := '0';
    IS_RSTB_INVERTED : std_ulogic := '0';
    IS_RSTCTRL_INVERTED : std_ulogic := '0';
    IS_RSTC_INVERTED : std_ulogic := '0';
    IS_RSTD_INVERTED : std_ulogic := '0';
    IS_RSTINMODE_INVERTED : std_ulogic := '0';
    IS_RSTM_INVERTED : std_ulogic := '0';
    IS_RSTP_INVERTED : std_ulogic := '0';
    MASK       : std_logic_vector(47 downto 0) := X"3FFFFFFFFFFF";
    MREG       : integer := 1;
    OPMODEREG  : integer := 1;
    PATTERN    : std_logic_vector(47 downto 0) := X"000000000000";
    PREADDINSEL : string := "A";
    PREG       : integer := 1;
    RND        : std_logic_vector(47 downto 0) := X"000000000000";
    SEL_MASK   : string := "MASK";
    SEL_PATTERN : string := "PATTERN";
    USE_MULT   : string := "MULTIPLY";
    USE_PATTERN_DETECT : string := "NO_PATDET";
    USE_SIMD   : string := "ONE48";
    USE_WIDEXOR : string := "FALSE";
    XORSIMD    : string := "XOR24_48_96"
   );

  port (
    ACOUT                : out std_logic_vector(29 downto 0);
    BCOUT                : out std_logic_vector(17 downto 0);
    CARRYCASCOUT         : out std_ulogic;
    CARRYOUT             : out std_logic_vector(3 downto 0);
    MULTSIGNOUT          : out std_ulogic;
    OVERFLOW             : out std_ulogic;
    P                    : out std_logic_vector(47 downto 0);
    PATTERNBDETECT       : out std_ulogic;
    PATTERNDETECT        : out std_ulogic;
    PCOUT                : out std_logic_vector(47 downto 0);
    UNDERFLOW            : out std_ulogic;
    XOROUT               : out std_logic_vector(7 downto 0);
    A                    : in std_logic_vector(29 downto 0);
    ACIN                 : in std_logic_vector(29 downto 0);
    ALUMODE              : in std_logic_vector(3 downto 0);
    B                    : in std_logic_vector(17 downto 0);
    BCIN                 : in std_logic_vector(17 downto 0);
    C                    : in std_logic_vector(47 downto 0);
    CARRYCASCIN          : in std_ulogic;
    CARRYIN              : in std_ulogic;
    CARRYINSEL           : in std_logic_vector(2 downto 0);
    CEA1                 : in std_ulogic;
    CEA2                 : in std_ulogic;
    CEAD                 : in std_ulogic;
    CEALUMODE            : in std_ulogic;
    CEB1                 : in std_ulogic;
    CEB2                 : in std_ulogic;
    CEC                  : in std_ulogic;
    CECARRYIN            : in std_ulogic;
    CECTRL               : in std_ulogic;
    CED                  : in std_ulogic;
    CEINMODE             : in std_ulogic;
    CEM                  : in std_ulogic;
    CEP                  : in std_ulogic;
    CLK                  : in std_ulogic;
    D                    : in std_logic_vector(26 downto 0);
    INMODE               : in std_logic_vector(4 downto 0);
    MULTSIGNIN           : in std_ulogic;
    OPMODE               : in std_logic_vector(8 downto 0);
    PCIN                 : in std_logic_vector(47 downto 0);
    RSTA                 : in std_ulogic;
    RSTALLCARRYIN        : in std_ulogic;
    RSTALUMODE           : in std_ulogic;
    RSTB                 : in std_ulogic;
    RSTC                 : in std_ulogic;
    RSTCTRL              : in std_ulogic;
    RSTD                 : in std_ulogic;
    RSTINMODE            : in std_ulogic;
    RSTM                 : in std_ulogic;
    RSTP                 : in std_ulogic
   );
end DSP48E2;

architecture DSP48E2_V of DSP48E2 is
--  define constants
  constant MODULE_NAME        : string := "DSP48E2";
  constant IN_DELAY           : time := 0 ps;
  constant OUT_DELAY          : time := 0 ps;
  constant INCLK_DELAY        : time := 0 ps;
  constant OUTCLK_DELAY       : time := 0 ps;

--  Parameter encodings and registers
  constant ACASCREG_0         : std_logic_vector(1 downto 0) := "00"; -- logic depends on ACASCREG, AREG encoding the same
  constant ACASCREG_1         : std_logic_vector(1 downto 0) := "01";
  constant ACASCREG_2         : std_logic_vector(1 downto 0) := "10";
  constant ADREG_0            : std_ulogic := '0';
  constant ADREG_1            : std_ulogic := '1';
  constant ALUMODEREG_0       : std_ulogic := '0';
  constant ALUMODEREG_1       : std_ulogic := '1';
  constant AMULTSEL_A         : std_ulogic := '0';
  constant AMULTSEL_AD        : std_ulogic := '1';
  constant AREG_0             : std_logic_vector(1 downto 0) := "00";
  constant AREG_1             : std_logic_vector(1 downto 0) := "01";
  constant AREG_2             : std_logic_vector(1 downto 0) := "10";
  constant AUTORESET_PATDET_NO_RESET : std_logic_vector(1 downto 0) := "00";
  constant AUTORESET_PATDET_RESET_MATCH : std_logic_vector(1 downto 0) := "10";
  constant AUTORESET_PATDET_RESET_NOT_MATCH : std_logic_vector(1 downto 0) := "11";
  constant AUTORESET_PRIORITY_CEP : std_ulogic := '1';
  constant AUTORESET_PRIORITY_RESET : std_ulogic := '0';
  constant A_INPUT_CASCADE    : std_ulogic := '1';
  constant A_INPUT_DIRECT     : std_ulogic := '0';
  constant BCASCREG_0         : std_logic_vector(1 downto 0) := "00";
  constant BCASCREG_1         : std_logic_vector(1 downto 0) := "01";
  constant BCASCREG_2         : std_logic_vector(1 downto 0) := "10";
  constant BMULTSEL_AD        : std_ulogic := '1';
  constant BMULTSEL_B         : std_ulogic := '0';
  constant BREG_0             : std_logic_vector(1 downto 0) := "00";
  constant BREG_1             : std_logic_vector(1 downto 0) := "01";
  constant BREG_2             : std_logic_vector(1 downto 0) := "10";
  constant B_INPUT_CASCADE    : std_ulogic := '1';
  constant B_INPUT_DIRECT     : std_ulogic := '0';
  constant CARRYINREG_0       : std_ulogic := '0';
  constant CARRYINREG_1       : std_ulogic := '1';
  constant CARRYINSELREG_0    : std_ulogic := '0';
  constant CARRYINSELREG_1    : std_ulogic := '1';
  constant CREG_0             : std_ulogic := '0';
  constant CREG_1             : std_ulogic := '1';
  constant DREG_0             : std_ulogic := '0';
  constant DREG_1             : std_ulogic := '1';
  constant INMODEREG_0        : std_ulogic := '0';
  constant INMODEREG_1        : std_ulogic := '1';
  constant MREG_0             : std_ulogic := '0';
  constant MREG_1             : std_ulogic := '1';
  constant OPMODEREG_0        : std_ulogic := '0';
  constant OPMODEREG_1        : std_ulogic := '1';
  constant PREADDINSEL_A      : std_ulogic := '0';
  constant PREADDINSEL_B      : std_ulogic := '1';
  constant PREG_0             : std_ulogic := '0';
  constant PREG_1             : std_ulogic := '1';
  constant SEL_MASK_C              : std_logic_vector(2 downto 0) := "001";
  constant SEL_MASK_MASK           : std_logic_vector(2 downto 0) := "000";
  constant SEL_MASK_ROUNDING_MODE1 : std_logic_vector(2 downto 0) := "010";
  constant SEL_MASK_ROUNDING_MODE2 : std_logic_vector(2 downto 0) := "110";
  constant SEL_PATTERN_C       : std_ulogic := '1';
  constant SEL_PATTERN_PATTERN : std_ulogic := '0';
  constant USE_MULT_DYNAMIC   : std_logic_vector(1 downto 0) := "11";
  constant USE_MULT_MULTIPLY  : std_logic_vector(1 downto 0) := "01";
  constant USE_MULT_NONE      : std_logic_vector(1 downto 0) := "10";
  constant USE_PATTERN_DETECT_NO_PATDET : std_ulogic := '0';
  constant USE_PATTERN_DETECT_PATDET    : std_ulogic := '1';
  constant USE_SIMD_FOUR12     : std_logic_vector(2 downto 0) := "111";
  constant USE_SIMD_ONE48      : std_logic_vector(2 downto 0) := "000";
  constant USE_SIMD_TWO24      : std_logic_vector(2 downto 0) := "010";
  constant USE_WIDEXOR_FALSE   : std_ulogic := '0';
  constant USE_WIDEXOR_TRUE    : std_ulogic := '1';
  constant XORSIMD_XOR12       : std_ulogic := '1';
  constant XORSIMD_XOR24_48_96 : std_ulogic := '0';

  signal ACASCREG_BIN           : std_logic_vector(1 downto 0);
  signal ADREG_BIN              : std_ulogic;
  signal ALUMODEREG_BIN         : std_ulogic;
  signal AMULTSEL_BIN           : std_ulogic;
  signal AREG_BIN               : std_logic_vector(1 downto 0);
  signal AUTORESET_PATDET_BIN   : std_logic_vector(1 downto 0);
  signal AUTORESET_PRIORITY_BIN : std_ulogic;
  signal A_INPUT_BIN            : std_ulogic;
  signal BCASCREG_BIN           : std_logic_vector(1 downto 0);
  signal BMULTSEL_BIN           : std_ulogic;
  signal BREG_BIN               : std_logic_vector(1 downto 0);
  signal B_INPUT_BIN            : std_ulogic;
  signal CARRYINREG_BIN         : std_ulogic;
  signal CARRYINSELREG_BIN      : std_ulogic;
  signal CREG_BIN               : std_ulogic;
  signal DREG_BIN               : std_ulogic;
  signal INMODEREG_BIN          : std_ulogic;
  signal MASK_BIN               : std_logic_vector(47 downto 0);
  signal MREG_BIN               : std_ulogic;
  signal OPMODEREG_BIN          : std_ulogic;
  signal PATTERN_BIN            : std_logic_vector(47 downto 0);
  signal PREADDINSEL_BIN        : std_ulogic;
  signal PREG_BIN               : std_ulogic;
  signal RND_BIN                : std_logic_vector(47 downto 0);
  signal SEL_MASK_BIN           : std_logic_vector(2 downto 0);
  signal SEL_PATTERN_BIN        : std_ulogic;
  signal USE_MULT_BIN           : std_logic_vector(1 downto 0);
  signal USE_PATTERN_DETECT_BIN : std_ulogic;
  signal USE_SIMD_BIN           : std_logic_vector(2 downto 0);
  signal USE_WIDEXOR_BIN        : std_ulogic;
  signal XORSIMD_BIN            : std_ulogic;

  signal glblGSR              : std_ulogic;

  signal attr_err             : std_ulogic := '0';

  signal A1_DATA_out          : std_logic_vector(26 downto 0);
  signal A2A1_out             : std_logic_vector(26 downto 0);
  signal A2_DATA_out          : std_logic_vector(26 downto 0);
  signal ACOUT_out            : std_logic_vector(29 downto 0);
  signal ADDSUB_out           : std_ulogic;
  signal AD_DATA_out          : std_logic_vector(26 downto 0);
  signal AD_out               : std_logic_vector(26 downto 0);
--  signal A_ALU_out            : std_logic_vector(29 downto 0);
  signal ALUMODE10_out        : std_ulogic;
  signal ALU_OUT_out          : std_logic_vector(47 downto 0);
  signal AMULT26_out          : std_ulogic;
  signal B1_DATA_out          : std_logic_vector(17 downto 0);
  signal B2B1_out             : std_logic_vector(17 downto 0);
  signal B2_DATA_out          : std_logic_vector(17 downto 0);
  signal BCOUT_out            : std_logic_vector(17 downto 0);
  signal BMULT17_out          : std_ulogic;
--  signal B_ALU_out            : std_logic_vector(17 downto 0);
  signal CARRYCASCOUT_out     : std_ulogic;
  signal CARRYOUT_out         : std_logic_vector(3 downto 0);
  signal CCOUT_FB_out         : std_ulogic;
  signal COUT_out             : std_logic_vector(3 downto 0);
  signal C_DATA_out           : std_logic_vector(47 downto 0);
  signal D_DATA_out           : std_logic_vector(26 downto 0);
  signal INMODE_2_out         : std_ulogic;
  signal MULTSIGN_ALU_out     : std_ulogic;
  signal MULTSIGNOUT_out      : std_ulogic;
  signal OVERFLOW_out         : std_ulogic;
  signal PATTERN_B_DETECT_out : std_ulogic;
  signal PATTERN_DETECT_out   : std_ulogic;
  signal PCOUT_out            : std_logic_vector(47 downto 0);
  signal PREADD_AB_out        : std_logic_vector(26 downto 0);
  signal P_FDBK_47_out        : std_ulogic;
  signal P_FDBK_out           : std_logic_vector(47 downto 0);
  signal P_out                : std_logic_vector(47 downto 0);
  signal UNDERFLOW_out        : std_ulogic;
  signal U_DATA_out           : std_logic_vector(44 downto 0);
  signal U_out                : std_logic_vector(44 downto 0);
  signal V_DATA_out           : std_logic_vector(44 downto 0);
  signal V_out                : std_logic_vector(44 downto 0);
  signal XOROUT_out           : std_logic_vector(7 downto 0);
  signal XOR_MX_out           : std_logic_vector(7 downto 0);

  signal A1_DATA_delay        : std_logic_vector(26 downto 0);
  signal A2A1_delay           : std_logic_vector(26 downto 0);
  signal A2_DATA_delay        : std_logic_vector(26 downto 0);
  signal ACOUT_delay          : std_logic_vector(29 downto 0);
  signal ADDSUB_delay         : std_ulogic;
  signal AD_DATA_delay        : std_logic_vector(26 downto 0);
  signal AD_delay             : std_logic_vector(26 downto 0);
  signal ALUMODE10_delay      : std_ulogic;
  signal ALU_OUT_delay        : std_logic_vector(47 downto 0);
  signal AMULT26_delay        : std_ulogic;
  signal A_ALU_delay          : std_logic_vector(29 downto 0);
  signal B1_DATA_delay        : std_logic_vector(17 downto 0);
  signal B2B1_delay           : std_logic_vector(17 downto 0);
  signal B2_DATA_delay        : std_logic_vector(17 downto 0);
  signal BMULT17_delay        : std_ulogic;
  signal BCOUT_delay          : std_logic_vector(17 downto 0);
  signal B_ALU_delay          : std_logic_vector(17 downto 0);
  signal CARRYCASCOUT_delay   : std_ulogic;
  signal CARRYOUT_delay       : std_logic_vector(3 downto 0);
  signal CCOUT_FB_delay       : std_ulogic;
  signal COUT_delay           : std_logic_vector(3 downto 0);
  signal C_DATA_delay         : std_logic_vector(47 downto 0);
  signal D_DATA_delay         : std_logic_vector(26 downto 0);
  signal INMODE_2_delay       : std_ulogic;
  signal MULTSIGN_ALU_delay   : std_ulogic;
  signal MULTSIGNOUT_delay    : std_ulogic;
  signal OVERFLOW_delay       : std_ulogic;
  signal PATTERN_B_DETECT_delay : std_ulogic;
  signal PATTERN_DETECT_delay : std_ulogic;
  signal PCOUT_delay          : std_logic_vector(47 downto 0);
  signal PREADD_AB_delay      : std_logic_vector(26 downto 0);
  signal P_delay              : std_logic_vector(47 downto 0);
  signal P_FDBK_47_delay      : std_ulogic;
  signal P_FDBK_delay         : std_logic_vector(47 downto 0);
  signal UNDERFLOW_delay      : std_ulogic;
  signal U_DATA_delay         : std_logic_vector(44 downto 0);
  signal U_delay              : std_logic_vector(44 downto 0);
  signal V_DATA_delay         : std_logic_vector(44 downto 0);
  signal V_delay              : std_logic_vector(44 downto 0);
  signal XOROUT_delay         : std_logic_vector(7 downto 0);
  signal XOR_MX_delay         : std_logic_vector(7 downto 0);

  signal ACIN_delay           : std_logic_vector(29 downto 0);
  signal ALUMODE_delay        : std_logic_vector(3 downto 0);
  signal A_delay              : std_logic_vector(29 downto 0);
  signal BCIN_delay           : std_logic_vector(17 downto 0);
  signal B_delay              : std_logic_vector(17 downto 0);
  signal CARRYCASCIN_delay    : std_ulogic;
  signal CARRYINSEL_delay     : std_logic_vector(2 downto 0);
  signal CARRYIN_delay        : std_ulogic;
  signal CEA1_delay           : std_ulogic;
  signal CEA2_delay           : std_ulogic;
  signal CEAD_delay           : std_ulogic;
  signal CEALUMODE_delay      : std_ulogic;
  signal CEB1_delay           : std_ulogic;
  signal CEB2_delay           : std_ulogic;
  signal CECARRYIN_delay      : std_ulogic;
  signal CECTRL_delay         : std_ulogic;
  signal CEC_delay            : std_ulogic;
  signal CED_delay            : std_ulogic;
  signal CEINMODE_delay       : std_ulogic;
  signal CEM_delay            : std_ulogic;
  signal CEP_delay            : std_ulogic;
  signal CLK_delay            : std_ulogic;
  signal C_delay              : std_logic_vector(47 downto 0);
  signal D_delay              : std_logic_vector(26 downto 0);
  signal INMODE_delay         : std_logic_vector(4 downto 0);
  signal MULTSIGNIN_delay     : std_ulogic;
  signal OPMODE_delay         : std_logic_vector(8 downto 0);
  signal PCIN_delay           : std_logic_vector(47 downto 0);
  signal RSTALLCARRYIN_delay  : std_ulogic;
  signal RSTALUMODE_delay     : std_ulogic;
  signal RSTA_delay           : std_ulogic;
  signal RSTB_delay           : std_ulogic;
  signal RSTCTRL_delay        : std_ulogic;
  signal RSTC_delay           : std_ulogic;
  signal RSTD_delay           : std_ulogic;
  signal RSTINMODE_delay      : std_ulogic;
  signal RSTM_delay           : std_ulogic;
  signal RSTP_delay           : std_ulogic;

  signal A1_DATA_in           : std_logic_vector(26 downto 0);
  signal A2A1_in              : std_logic_vector(26 downto 0);
  signal A2_DATA_in           : std_logic_vector(26 downto 0);
  signal ACIN_in              : std_logic_vector(29 downto 0);
  signal ADDSUB_in            : std_ulogic;
  signal AD_DATA_in           : std_logic_vector(26 downto 0);
  signal AD_in                : std_logic_vector(26 downto 0);
  signal ALUMODE10_in         : std_ulogic;
  signal ALUMODE_in           : std_logic_vector(3 downto 0);
  signal ALU_OUT_in           : std_logic_vector(47 downto 0);
  signal AMULT26_in           : std_ulogic;
  signal A_ALU_in             : std_logic_vector(29 downto 0);
  signal A_in                 : std_logic_vector(29 downto 0);
  signal B1_DATA_in           : std_logic_vector(17 downto 0);
  signal B2B1_in              : std_logic_vector(17 downto 0);
  signal B2_DATA_in           : std_logic_vector(17 downto 0);
  signal BCIN_in              : std_logic_vector(17 downto 0);
  signal BMULT17_in           : std_ulogic;
  signal B_ALU_in             : std_logic_vector(17 downto 0);
  signal B_in                 : std_logic_vector(17 downto 0);
  signal CARRYCASCIN_in       : std_ulogic;
  signal CARRYINSEL_in        : std_logic_vector(2 downto 0);
  signal CARRYIN_in           : std_ulogic;
  signal CCOUT_in             : std_ulogic;
  signal CEA1_in              : std_ulogic;
  signal CEA2_in              : std_ulogic;
  signal CEAD_in              : std_ulogic;
  signal CEALUMODE_in         : std_ulogic;
  signal CEB1_in              : std_ulogic;
  signal CEB2_in              : std_ulogic;
  signal CECARRYIN_in         : std_ulogic;
  signal CECTRL_in            : std_ulogic;
  signal CEC_in               : std_ulogic;
  signal CED_in               : std_ulogic;
  signal CEINMODE_in          : std_ulogic;
  signal CEM_in               : std_ulogic;
  signal CEP_in               : std_ulogic;
  signal CLK_in               : std_ulogic;
  signal COUT_in              : std_logic_vector(3 downto 0);
  signal C_DATA_in            : std_logic_vector(47 downto 0);
  signal C_in                 : std_logic_vector(47 downto 0);
  signal DIN_in               : std_logic_vector(26 downto 0);
  signal D_DATA_in            : std_logic_vector(26 downto 0);
  signal D_in                 : std_logic_vector(26 downto 0);
  signal INMODE_2_in          : std_ulogic;
  signal INMODE_in            : std_logic_vector(4 downto 0);
  signal MULTSIGNIN_in        : std_ulogic;
  signal MULTSIGN_ALU_in      : std_ulogic;
  signal OPMODE_in            : std_logic_vector(8 downto 0);
  signal PCIN_in              : std_logic_vector(47 downto 0);
  signal PREADD_AB_in         : std_logic_vector(26 downto 0);
  signal P_FDBK_47_in         : std_ulogic;
  signal P_FDBK_in            : std_logic_vector(47 downto 0);
  signal RSTALLCARRYIN_in     : std_ulogic;
  signal RSTALUMODE_in        : std_ulogic;
  signal RSTA_in              : std_ulogic;
  signal RSTB_in              : std_ulogic;
  signal RSTCTRL_in           : std_ulogic;
  signal RSTC_in              : std_ulogic;
  signal RSTD_in              : std_ulogic;
  signal RSTINMODE_in         : std_ulogic;
  signal RSTM_in              : std_ulogic;
  signal RSTP_in              : std_ulogic;
  signal U_DATA_in            : std_logic_vector(44 downto 0);
  signal U_in                 : std_logic_vector(44 downto 0);
  signal V_DATA_in            : std_logic_vector(44 downto 0);
  signal V_in                 : std_logic_vector(44 downto 0);
  signal XOR_MX_in            : std_logic_vector(7 downto 0);

--  DSP_ALU wires
  constant MAX_ALU_FULL       : integer := 48;
  constant MAX_CARRYOUT       : integer := 4;

  signal CARRYIN_mux          : std_ulogic;
  signal CARRYIN_reg          : std_ulogic := '0';
  signal ALUMODE_mux          : std_logic_vector(3 downto 0);
  signal ALUMODE_reg          : std_logic_vector(3 downto 0) := (others => '0');
  signal CARRYINSEL_mux       : std_logic_vector(2 downto 0);
  signal CARRYINSEL_reg       : std_logic_vector(2 downto 0) := (others => '0');
  signal OPMODE_mux           : std_logic_vector(8 downto 0);
  signal OPMODE_reg           : std_logic_vector(8 downto 0) := (others => '0');
--  signal ALU_OUT_tmp          : std_logic_vector(47 downto 0);
  signal alu_o                : std_logic_vector(47 downto 0);

  signal u_43_data            : std_ulogic;
  signal x_mac_cascd          : std_logic_vector(47 downto 0);

  signal wmux                 : unsigned (47 downto 0);
  signal xmux                 : unsigned (47 downto 0);
  signal ymux                 : unsigned (47 downto 0);
  signal zmux                 : unsigned (47 downto 0);
  signal z_optinv             : unsigned (47 downto 0);

  signal cin                  : std_ulogic;
  signal cin_b                : std_ulogic;
  signal rst_carryin_g        : std_ulogic;
  signal qmultcarryin         : std_ulogic;

  signal c_mult                : std_ulogic;
  signal ce_m_g                : std_ulogic;  
  signal d_carryin_int         : std_ulogic; 
  signal dr_carryin_int        : std_ulogic;
  signal multcarryin_data      : std_ulogic;

  signal invalid_opmode        : std_ulogic := '1';
  signal opmode_valid_flag_dal : boolean := true; -- used in OPMODE DRC
  signal ping_opmode_drc_check : std_ulogic := '0';

  signal co                   : unsigned (MAX_ALU_FULL-1 downto 0);
  signal s                    : unsigned (MAX_ALU_FULL-1 downto 0);
  signal s_slv                : std_logic_vector(MAX_ALU_FULL-1 downto 0);
  signal comux                : unsigned (MAX_ALU_FULL-1 downto 0);
  signal comux_w              : unsigned (MAX_ALU_FULL-1 downto 0);
  signal comux4simd           : unsigned (MAX_ALU_FULL-1 downto 0);
  signal smux                 : unsigned (MAX_ALU_FULL-1 downto 0);
  signal smux_w               : unsigned (MAX_ALU_FULL-1 downto 0);
  signal a_int                : unsigned (48 downto 0);
  signal b_int                : unsigned (47 downto 0);
  signal s0                   : unsigned (12 downto 0);
  signal cout0                : std_ulogic;
  signal intc1                : std_ulogic;
  signal co12_lsb             : std_ulogic;
  signal s1                   : unsigned (12 downto 0);
  signal cout1                : std_ulogic;
  signal intc2                : std_ulogic;
  signal co24_lsb             : std_ulogic;
  signal s2                   : unsigned (12 downto 0);
  signal cout2                : std_ulogic;
  signal intc3                : std_ulogic;
  signal co36_lsb             : std_ulogic;
  signal s3                   : unsigned (13 downto 0);
  signal cout3                : std_ulogic;
  signal cout4                : std_ulogic;
  signal xor_12a              : std_ulogic;
  signal xor_12b              : std_ulogic;
  signal xor_12c              : std_ulogic;
  signal xor_12d              : std_ulogic;
  signal xor_12e              : std_ulogic;
  signal xor_12f              : std_ulogic;
  signal xor_12g              : std_ulogic;
  signal xor_12h              : std_ulogic;
  signal xor_24a              : std_ulogic;
  signal xor_24b              : std_ulogic;
  signal xor_24c              : std_ulogic;
  signal xor_24d              : std_ulogic;
  signal xor_48a              : std_ulogic;
  signal xor_48b              : std_ulogic;
  signal xor_96               : std_ulogic;
  signal cout_0               : std_ulogic;
  signal cout_1               : std_ulogic;
  signal cout_2               : std_ulogic;
  signal cout_3               : std_ulogic;
  signal mult_or_logic        : boolean;

  signal PCIN_IN47_9   : std_logic_vector(8 downto 0);
  signal PCIN_IN47_8   : std_logic_vector(7 downto 0);
  signal P_FDBK_47_9   : std_logic_vector(8 downto 0);
  signal P_FDBK_IN47_8 : std_logic_vector(7 downto 0);
  signal U_44_DATA_3   : unsigned (2 downto 0);

--  DSP_A_B_DATA wires
  signal A_ACIN_mux   : std_logic_vector(29 downto 0);
  signal A1_reg_mux   : std_logic_vector(29 downto 0);
  signal A2_reg_mux   : std_logic_vector(29 downto 0);
  signal A1_reg       : std_logic_vector(29 downto 0) := (others => '0');
  signal A2_reg       : std_logic_vector(29 downto 0) := (others => '0');
  signal B_BCIN_mux   : std_logic_vector(17 downto 0);
  signal B1_reg_mux   : std_logic_vector(17 downto 0);
  signal B2_reg_mux   : std_logic_vector(17 downto 0);
  signal B1_reg       : std_logic_vector(17 downto 0) := (others => '0');
  signal B2_reg       : std_logic_vector(17 downto 0) := (others => '0');
  signal CLK_areg1            : std_ulogic;
  signal CLK_areg2            : std_ulogic;
  signal CLK_breg1            : std_ulogic;
  signal CLK_breg2            : std_ulogic;

--  DSP_C_DATA wires

  signal C_reg                : std_logic_vector(47 downto 0) := (others => '0');
  signal CLK_creg             : std_ulogic;

--  DSP_MULTIPLIER wires
  signal b_mult_mux       : signed (17 downto 0);
  signal a_mult_mux_26_18 : unsigned (17 downto 0);
  signal a_mult_mux       : signed (26 downto 0);
  signal b_mult_mux_17_27 : unsigned (26 downto 0);
  signal mult      : signed (44 downto 0);
  signal ps_u_mask : unsigned (43 downto 0) := X"55555555555";
  signal ps_v_mask : unsigned (43 downto 0) := X"aaaaaaaaaaa";

--  DSP_M_DATA wires
  signal U_DATA_reg      : std_logic_vector(44 downto 0) := '1' & X"00000000000";
  signal V_DATA_reg      : std_logic_vector(44 downto 0) := '1' & X"00000000000";
  signal CLK_mreg        : std_ulogic;

--  DSP_OUTPUT wires
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

--  DSP_PREADD wires
  signal D_DATA_mux           : std_logic_vector(26 downto 0);

--  DSP_PREADD_DATA wires

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

-- functions, tasks

    function xor_6 (
      vec : in unsigned (5 downto 0)
    ) return std_ulogic is
    variable xor6 : std_ulogic := '0';
    begin
      xor6 := vec(5) xor vec(4) xor vec(3) xor vec(2) xor vec(1) xor vec(0);
      return xor6;
    end;

--  input output assignments
begin
   glblGSR          <= TO_X01(GSR);
   ACOUT            <= ACOUT_delay  after OUT_DELAY;
   BCOUT            <= BCOUT_delay  after OUT_DELAY;
   CARRYCASCOUT     <= CARRYCASCOUT_delay  after OUT_DELAY;
   CARRYOUT         <= CARRYOUT_delay  after OUT_DELAY;
   MULTSIGNOUT      <= MULTSIGNOUT_delay  after OUT_DELAY;
   OVERFLOW         <= OVERFLOW_delay  after OUT_DELAY;
   P                <= P_delay  after OUT_DELAY;
   PATTERNBDETECT   <= PATTERN_B_DETECT_delay  after OUT_DELAY;
   PATTERNDETECT    <= PATTERN_DETECT_delay  after OUT_DELAY;
   PCOUT            <= PCOUT_delay  after OUT_DELAY;
   UNDERFLOW        <= UNDERFLOW_delay  after OUT_DELAY;
   XOROUT           <= XOROUT_delay  after OUT_DELAY;

   A1_DATA_delay <= A1_DATA_out;
   A2A1_delay <= A2A1_out;
   A2_DATA_delay <= A2_DATA_out;
   ACOUT_delay   <= ACOUT_out;
   ADDSUB_delay <= ADDSUB_out;
   AD_DATA_delay <= AD_DATA_out;
   AD_delay <= AD_out;
   ALUMODE10_delay <= ALUMODE10_out;
   ALU_OUT_delay <= ALU_OUT_out;
   AMULT26_delay <= AMULT26_out;
   A_ALU_delay   <= A2_reg_mux;
   B1_DATA_delay <= B1_DATA_out;
   B2B1_delay <= B2B1_out;
   B2_DATA_delay <= B2_DATA_out;
   BCOUT_delay <= BCOUT_out;
   BMULT17_delay <= BMULT17_out;
   B_ALU_delay <= B2_reg_mux;
   CARRYCASCOUT_delay <= CARRYCASCOUT_out;
   CARRYOUT_delay <= CARRYOUT_out;
   CCOUT_FB_delay <= CCOUT_FB_out;
   COUT_delay <= COUT_out;
   C_DATA_delay <= C_DATA_out;
   D_DATA_delay <= D_DATA_out;
   INMODE_2_delay <= INMODE_2_out;
   MULTSIGNOUT_delay <= MULTSIGNOUT_out;
   MULTSIGN_ALU_delay <= MULTSIGN_ALU_out;
   OVERFLOW_delay <= OVERFLOW_out;
   PATTERN_B_DETECT_delay <= PATTERN_B_DETECT_out;
   PATTERN_DETECT_delay <= PATTERN_DETECT_out;
   PCOUT_delay <= PCOUT_out;
   P_FDBK_47_delay <= P_FDBK_47_out;
   P_FDBK_delay <= P_FDBK_out;
   PREADD_AB_delay <= PREADD_AB_out;
   P_delay <= P_out;
   UNDERFLOW_delay <= UNDERFLOW_out;
   U_delay <= U_out;
   U_DATA_delay <= U_DATA_out;
   V_delay <= V_out;
   V_DATA_delay <= V_DATA_out;
   XOROUT_delay <= XOROUT_out;
   XOR_MX_delay <= XOR_MX_out;

   CLK_delay           <= CLK after INCLK_DELAY;

   ACIN_delay          <= ACIN after IN_DELAY;
   ALUMODE_delay       <= ALUMODE after IN_DELAY;
   A_delay             <= A after IN_DELAY;
   BCIN_delay          <= BCIN after IN_DELAY;
   B_delay             <= B after IN_DELAY;
   CARRYCASCIN_delay   <= CARRYCASCIN after IN_DELAY;
   CARRYINSEL_delay    <= CARRYINSEL after IN_DELAY;
   CARRYIN_delay       <= CARRYIN after IN_DELAY;
   CEA1_delay          <= CEA1 after IN_DELAY;
   CEA2_delay          <= CEA2 after IN_DELAY;
   CEAD_delay          <= CEAD after IN_DELAY;
   CEALUMODE_delay     <= CEALUMODE after IN_DELAY;
   CEB1_delay          <= CEB1 after IN_DELAY;
   CEB2_delay          <= CEB2 after IN_DELAY;
   CECARRYIN_delay     <= CECARRYIN after IN_DELAY;
   CECTRL_delay        <= CECTRL after IN_DELAY;
   CEC_delay           <= CEC after IN_DELAY;
   CED_delay           <= CED after IN_DELAY;
   CEINMODE_delay      <= CEINMODE after IN_DELAY;
   CEM_delay           <= CEM after IN_DELAY;
   CEP_delay           <= CEP after IN_DELAY;
   C_delay             <= C after IN_DELAY;
   D_delay             <= D after IN_DELAY;
   INMODE_delay        <= INMODE after IN_DELAY;
   MULTSIGNIN_delay    <= MULTSIGNIN after IN_DELAY;
   OPMODE_delay        <= OPMODE after IN_DELAY;
   PCIN_delay          <= PCIN after IN_DELAY;
   RSTALLCARRYIN_delay <= RSTALLCARRYIN after IN_DELAY;
   RSTALUMODE_delay    <= RSTALUMODE after IN_DELAY;
   RSTA_delay          <= RSTA after IN_DELAY;
   RSTB_delay          <= RSTB after IN_DELAY;
   RSTCTRL_delay       <= RSTCTRL after IN_DELAY;
   RSTC_delay          <= RSTC after IN_DELAY;
   RSTD_delay          <= RSTD after IN_DELAY;
   RSTINMODE_delay     <= RSTINMODE after IN_DELAY;
   RSTM_delay          <= RSTM after IN_DELAY;
   RSTP_delay          <= RSTP after IN_DELAY;

   A1_DATA_in <= A1_DATA_delay;
   A2A1_in <= A2A1_delay;
   A2_DATA_in <= A2_DATA_delay;
   ACIN_in <= ACIN_delay;
   ADDSUB_in <= ADDSUB_delay;
   AD_DATA_in <= AD_DATA_delay;
   AD_in <= AD_delay;
   ALUMODE10_in <= ALUMODE10_delay;
   ALUMODE_in <= ALUMODE_delay xor IS_ALUMODE_INVERTED;
   ALU_OUT_in <= ALU_OUT_delay after 1 ps; --  break 0 delay feedback
   AMULT26_in <= AMULT26_delay;
   A_ALU_in <= A_ALU_delay;
   A_in <= A_delay;
   B1_DATA_in <= B1_DATA_delay;
   B2B1_in <= B2B1_delay;
   B2_DATA_in <= B2_DATA_delay;
   BCIN_in <= BCIN_delay;
   BMULT17_in <= BMULT17_delay;
   B_ALU_in <= B_ALU_delay;
   B_in <= B_delay;
   CARRYCASCIN_in <= CARRYCASCIN_delay;
   CARRYINSEL_in <= CARRYINSEL_delay;
   CARRYIN_in <= CARRYIN_delay xor IS_CARRYIN_INVERTED;
   CCOUT_in <= CCOUT_FB_delay;
   CEA1_in <= CEA1_delay;
   CEA2_in <= CEA2_delay;
   CEAD_in <= CEAD_delay;
   CEALUMODE_in <= CEALUMODE_delay;
   CEB1_in <= CEB1_delay;
   CEB2_in <= CEB2_delay;
   CECARRYIN_in <= CECARRYIN_delay;
   CECTRL_in <= CECTRL_delay;
   CEC_in <= CEC_delay;
   CED_in <= CED_delay;
   CEINMODE_in <= CEINMODE_delay;
   CEM_in <= CEM_delay;
   CEP_in <= CEP_delay;
   CLK_in <= CLK_delay xor IS_CLK_INVERTED;
   CLK_areg1 <= '0' when (AREG_BIN = AREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_areg2 <= '0' when (AREG_BIN = AREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_breg1 <= '0' when (BREG_BIN = BREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_breg2 <= '0' when (BREG_BIN = BREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_creg  <= '0' when (CREG_BIN = CREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_mreg  <= '0' when (MREG_BIN = MREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_inmode <=  '0' when (INMODEREG_BIN = INMODEREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_dreg   <=  '0' when (DREG_BIN = DREG_0)           else CLK_delay xor IS_CLK_INVERTED;
   CLK_adreg  <=  '0' when (ADREG_BIN = ADREG_0)         else CLK_delay xor IS_CLK_INVERTED;
   CLK_preg  <= '0' when (PREG_BIN = PREG_0) else CLK_delay xor IS_CLK_INVERTED;
   COUT_in <= COUT_delay;
   C_DATA_in <= C_DATA_delay;
   C_in <= C_delay;
   DIN_in <= D_delay;
   D_DATA_in <= D_DATA_delay;
   D_in <= D_delay;
   INMODE_2_in <= INMODE_2_delay;
   INMODE_in <= INMODE_delay xor IS_INMODE_INVERTED;
   MULTSIGNIN_in <= MULTSIGNIN_delay;
   MULTSIGN_ALU_in <= MULTSIGN_ALU_delay;
   OPMODE_in <= OPMODE_delay xor IS_OPMODE_INVERTED;
   PCIN_in <= PCIN_delay;
   PREADD_AB_in <= PREADD_AB_delay;
   P_FDBK_47_in <= P_FDBK_47_delay;
   P_FDBK_in <= P_FDBK_delay;
   RSTALLCARRYIN_in <= RSTALLCARRYIN_delay xor IS_RSTALLCARRYIN_INVERTED;
   RSTALUMODE_in <= RSTALUMODE_delay xor IS_RSTALUMODE_INVERTED;
   RSTA_in <= RSTA_delay xor IS_RSTA_INVERTED;
   RSTB_in <= RSTB_delay xor IS_RSTB_INVERTED;
   RSTCTRL_in <= RSTCTRL_delay xor IS_RSTCTRL_INVERTED;
   RSTC_in <= RSTC_delay xor IS_RSTC_INVERTED;
   RSTD_in <= RSTD_delay xor IS_RSTD_INVERTED;
   RSTINMODE_in <= RSTINMODE_delay xor IS_RSTINMODE_INVERTED;
   RSTM_in <= RSTM_delay xor IS_RSTM_INVERTED;
   RSTP_in <= RSTP_delay xor IS_RSTP_INVERTED;
   U_DATA_in <= U_DATA_delay when USE_SIMD_BIN = USE_SIMD_ONE48 else '1' & X"00000000000";
   U_in <= U_delay;
   V_DATA_in <= V_DATA_delay when USE_SIMD_BIN = USE_SIMD_ONE48 else '1' & X"00000000000";
   V_in <= V_delay;
   XOR_MX_in <= XOR_MX_delay;

  INIPROC : process
  begin
-------- ACASCREG check
    case ACASCREG is
      when  1   =>  ACASCREG_BIN <= ACASCREG_1;
      when  0   =>  ACASCREG_BIN <= ACASCREG_0;
      when  2   =>  ACASCREG_BIN <= ACASCREG_2;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : ACASCREG is not in range 0 .. 2." severity warning;
    end case;
-------- ADREG check
    case ADREG is
      when  1   =>  ADREG_BIN <= ADREG_1;
      when  0   =>  ADREG_BIN <= ADREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : ADREG is not in range 0 .. 1." severity warning;
    end case;
-------- ALUMODEREG check
    case ALUMODEREG is
      when  1   =>  ALUMODEREG_BIN <= ALUMODEREG_1;
      when  0   =>  ALUMODEREG_BIN <= ALUMODEREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : ALUMODEREG is not in range 0 .. 1." severity warning;
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
-------- AREG check vs ACASCREG
    case AREG is
      when 1    =>  AREG_BIN <= AREG_1;
        if (ACASCREG /= 1) then
        attr_err <= '1';
        assert FALSE report "Error : ACASCREG must be 1 when AREG is 1" severity warning;
        end if;
      when 0    =>  AREG_BIN <= AREG_0;
        if (ACASCREG /= 0) then
        attr_err <= '1';
        assert FALSE report "Error : ACASCREG must be 0 when AREG is 0" severity warning;
        end if;
      when 2    =>  AREG_BIN <= AREG_2;
        if (ACASCREG = 0) then
        attr_err <= '1';
        assert FALSE report "Error : ACASCREG must be 2 or 1 when AREG is 2" severity warning;
        end if;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : AREG is not in range 0 .. 2." severity warning;
    end case;
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
-------- A_INPUT check
    -- case A_INPUT is
      if(A_INPUT = "DIRECT") then
        A_INPUT_BIN <= A_INPUT_DIRECT;
      elsif(A_INPUT = "CASCADE") then
        A_INPUT_BIN <= A_INPUT_CASCADE;
      else
        attr_err <= '1';
        assert FALSE report "Error : A_INPUT is not DIRECT, CASCADE." severity warning;
      end if;
    -- end case;
-------- BCASCREG check
    case BCASCREG is
      when  1   =>  BCASCREG_BIN <= BCASCREG_1;
      when  0   =>  BCASCREG_BIN <= BCASCREG_0;
      when  2   =>  BCASCREG_BIN <= BCASCREG_2;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : BCASCREG is not in range 0 .. 2." severity warning;
    end case;
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
------ BREG check vs BCASCREG
    case BREG is
      when 1    =>  BREG_BIN <= BREG_1;
        if (BCASCREG /= 1) then
        attr_err <= '1';
        assert FALSE report "Error : BCASCREG must be 1 when BREG is 1" severity warning;
        end if;
      when 0    =>  BREG_BIN <= BREG_0;
        if (BCASCREG /= 0) then
        attr_err <= '1';
        assert FALSE report "Error : BCASCREG must be 0 when BREG is 0" severity warning;
        end if;
      when 2    =>  BREG_BIN <= BREG_2;
        if (BCASCREG = 0) then
        attr_err <= '1';
        assert FALSE report "Error : BCASCREG must be 2 or 1 when BREG is 2" severity warning;
        end if;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : BREG is not in range 0 .. 2." severity warning;
    end case;
-------- B_INPUT check
    -- case B_INPUT is
      if(B_INPUT = "DIRECT") then
        B_INPUT_BIN <= B_INPUT_DIRECT;
      elsif(B_INPUT = "CASCADE") then
        B_INPUT_BIN <= B_INPUT_CASCADE;
      else
        attr_err <= '1';
        assert FALSE report "Error : B_INPUT is not DIRECT, CASCADE." severity warning;
      end if;
    -- end case;
-------- CARRYINREG check
    case CARRYINREG is
      when  1   =>  CARRYINREG_BIN <= CARRYINREG_1;
      when  0   =>  CARRYINREG_BIN <= CARRYINREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : CARRYINREG is not in range 0 .. 1." severity warning;
    end case;
-------- CARRYINSELREG check
    case CARRYINSELREG is
      when  1   =>  CARRYINSELREG_BIN <= CARRYINSELREG_1;
      when  0   =>  CARRYINSELREG_BIN <= CARRYINSELREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : CARRYINSELREG is not in range 0 .. 1." severity warning;
    end case;
-------- CREG check
    case CREG is
      when  1   =>  CREG_BIN <= CREG_1;
      when  0   =>  CREG_BIN <= CREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : CREG is not in range 0 .. 1." severity warning;
    end case;
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
-------- MASK check
    MASK_BIN <= MASK;

-------- MREG check
    case MREG is
      when  1   =>  MREG_BIN <= MREG_1;
      when  0   =>  MREG_BIN <= MREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : MREG is not in range 0 .. 1." severity warning;
    end case;
-------- OPMODEREG check
    case OPMODEREG is
      when  1   =>  OPMODEREG_BIN <= OPMODEREG_1;
      when  0   =>  OPMODEREG_BIN <= OPMODEREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : OPMODEREG is not in range 0 .. 1." severity warning;
    end case;
-------- PATTERN check
    PATTERN_BIN <= PATTERN;

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
-------- PREG check
    case PREG is
      when  1   =>  PREG_BIN <= PREG_1;
      when  0   =>  PREG_BIN <= PREG_0;
      when others  =>
        attr_err <= '1';
        assert FALSE report "Error : PREG is not in range 0 .. 1." severity warning;
    end case;
-------- RND check
    RND_BIN <= RND;

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
-------- USE_SIMD check
   -- case USE_SIMD is
      if(USE_SIMD = "ONE48") then
        USE_SIMD_BIN <= USE_SIMD_ONE48;
      elsif(USE_SIMD = "FOUR12") then
        USE_SIMD_BIN <= USE_SIMD_FOUR12;
      elsif(USE_SIMD = "TWO24") then
        USE_SIMD_BIN <= USE_SIMD_TWO24;
      else
        attr_err <= '1';
        assert FALSE report "Error : USE_SIMD is not ONE48, FOUR12, TWO24." severity warning;
      end if;
    -- end case;
-------- USE_WIDEXOR check
    -- case USE_WIDEXOR is
      if(USE_WIDEXOR = "FALSE") then
        USE_WIDEXOR_BIN <= USE_WIDEXOR_FALSE;
      elsif(USE_WIDEXOR = "TRUE") then
        USE_WIDEXOR_BIN <= USE_WIDEXOR_TRUE;
      else
        attr_err <= '1';
        assert FALSE report "Error : USE_WIDEXOR is not FALSE, TRUE." severity warning;
      end if;
    -- end case;
-------- XORSIMD check
    -- case XORSIMD is
      if(XORSIMD = "XOR24_48_96") then
        XORSIMD_BIN <= XORSIMD_XOR24_48_96;
      elsif(XORSIMD = "XOR12") then
        XORSIMD_BIN <= XORSIMD_XOR12;
      else
        attr_err <= '1';
        assert FALSE report "Error : XORSIMD is not XOR24_48_96, XOR12." severity warning;
      end if;
    -- end case;

    if  (attr_err = '1') then
       assert FALSE
       report "Error : Attribute Error(s) encountered"
       severity error;
    end if;
    wait;
  end process INIPROC;

--  DSP_ALU
-- *** GLOBAL hidden GSR pin

--  process (glblGSR)
--  begin
--    if  (glblGSR = '1' ) then
--      CARRYIN_reg <= '0';
--      CARRYINSEL_reg <= "000";
--      OPMODE_reg <= "0000000";
--      ALUMODE_reg <= "0000";
--    else
--      CARRYIN_reg;
--      CARRYINSEL_reg;
--      OPMODE_reg;
--      ALUMODE_reg;
--    end if;
--  end process;

--*** W mux
  WMUX_P : process (C_DATA_in,P_FDBK_in,RND_BIN,OPMODE_mux(8 downto 7))
  begin
    case  OPMODE_mux(8 downto 7)  is
      when  "00"  => wmux <= (others => '0');
      when  "01"  => wmux <= unsigned(P_FDBK_in);
      when  "10"  => wmux <= unsigned(RND_BIN);
      when  "11"  => wmux <= unsigned(C_DATA_in);
      when others => wmux <= (others => 'X');
    end case;
  end process;

-- *** X mux
--  To support MAC-cascade add multsignin to bit 1 of X
--                 {{46{1'b0}},MULTSIGNIN_in,1'b0} : {48{1'b0}}
--                   2           44              1            1
  x_mac_cascd  <=  ("00" & X"00000000000" &  MULTSIGNIN_in & '0')  when  OPMODE_mux (6 downto 4) = "100" else  (others => '0');
  U_44_DATA_3 <= "000" when U_DATA_in(44) = '0' else "111";

  XMUX_P : process (A_ALU_in,B_ALU_in,P_FDBK_in,U_44_DATA_3,U_DATA_in,OPMODE_mux(1 downto 0),x_mac_cascd)
  begin
    case  OPMODE_mux (1 downto 0)  is
      when  "00"  => xmux <= unsigned(x_mac_cascd);
      when  "01"  => xmux <= U_44_DATA_3 & unsigned(U_DATA_in);
      when  "10"  => xmux <= unsigned(P_FDBK_in);
      when  "11"  => xmux <= unsigned(A_ALU_in & B_ALU_in);
      when others => xmux <= (others => 'X');
    end case;
  end process;

-- *** Y mux

  YMUX_P : process (C_DATA_in,V_DATA_in,OPMODE_mux(3 downto 2))
  begin
    case  OPMODE_mux(3 downto 2) is
      when  "00"  => ymux <= (others => '0');
      when  "01"  => ymux <= "000" & unsigned(V_DATA_in);
      when  "10"  => ymux <= (others => '1');
      when  "11"  => ymux <= unsigned(C_DATA_in);
      when others => ymux <= (others => 'X');
    end case;
  end process;

  PCIN_IN47_9    <= PCIN_in(47)  & PCIN_in(47)  & PCIN_in(47) &
                    PCIN_in(47)  & PCIN_in(47)  & PCIN_in(47) & 
                    PCIN_in(47)  & PCIN_in(47) & PCIN_in(47);
  PCIN_IN47_8    <= PCIN_in(47)  & PCIN_in(47)  & PCIN_in(47) &
                    PCIN_in(47)  & PCIN_in(47)  & PCIN_in(47) & 
                    PCIN_in(47)  & PCIN_in(47);
  P_FDBK_47_9    <= P_FDBK_47_in & P_FDBK_47_in & P_FDBK_47_in &
                    P_FDBK_47_in & P_FDBK_47_in & P_FDBK_47_in & 
                    P_FDBK_47_in & P_FDBK_47_in & P_FDBK_47_in;
  P_FDBK_IN47_8  <= P_FDBK_in(47) & P_FDBK_in(47) & P_FDBK_in(47) &
                    P_FDBK_in(47) & P_FDBK_in(47) & P_FDBK_in(47) & 
                    P_FDBK_in(47) & P_FDBK_in(47);
-- *** Z mux
  ZMUX_P : process (C_DATA_in,PCIN_in,P_FDBK_in,OPMODE_mux(6 downto 4),PCIN_IN47_9,PCIN_IN47_8,P_FDBK_47_9,P_FDBK_IN47_8)
  begin
    case  OPMODE_mux (6 downto 4)  is
      when "000" => zmux <= (others => '0');
      when "001" => zmux <= unsigned(PCIN_in);
      when "010" => zmux <= unsigned(P_FDBK_in);
      when "011" => zmux <= unsigned(C_DATA_in);
      when "100" => zmux <= unsigned(P_FDBK_in);
      when "101" => zmux <= unsigned(PCIN_IN47_9 & PCIN_IN47_8   & PCIN_in(47 downto 17));
      when "110" => zmux <= unsigned(P_FDBK_47_9 & P_FDBK_IN47_8 & P_FDBK_in(47 downto 17));
      when "111" => zmux <= unsigned(P_FDBK_47_9 & P_FDBK_IN47_8 & P_FDBK_in(47 downto 17));
      when others => zmux <= (others => 'X');
    end case;
  end process;

-- *** CARRYINSEL and OPMODE with 1 level of register
  process (CLK_in)
  begin
    if  (glblGSR = '1') then CARRYINSEL_reg <= (others => '0');
    elsif (rising_edge(CLK_in)) then
      if    (RSTCTRL_in = '1') then CARRYINSEL_reg <= (others => '0');
      elsif (CECTRL_in = '1') then CARRYINSEL_reg <= CARRYINSEL_in;
      end if;
    end if;
  end process;

  CARRYINSEL_mux <= CARRYINSEL_reg when (CARRYINSELREG_BIN = CARRYINSELREG_1)
                                   else  CARRYINSEL_in;

  process (CLK_in)
  begin
    if  (glblGSR = '1') then OPMODE_reg <= (others => '0');
    elsif (rising_edge(CLK_in)) then
      if    (RSTCTRL_in = '1') then OPMODE_reg <= (others => '0');
      elsif (CECTRL_in = '1') then OPMODE_reg <= OPMODE_in;
      end if;
    end if;
  end process;

  OPMODE_mux <= OPMODE_reg when (OPMODEREG_BIN = OPMODEREG_1)
                           else OPMODE_in;

  cis_drc:process(CARRYCASCIN_in,CARRYINSEL_mux,MULTSIGNIN_in,OPMODE_mux)
  begin
     if(CARRYINSEL_mux = "010") then
        if (not((MULTSIGNIN_in = 'X') or
                ((OPMODE_mux = "001001000") and (MULTSIGNIN_in /= 'X')) or
                ((MULTSIGNIN_in = '0') and (CARRYCASCIN_in = '0')))) then
           assert false
           report "DRC warning : CARRYCASCIN can only be used in the current DSP48E2 instance if the previous DSP48E2  is performing a two input ADD operation, or the current DSP48E2 is configured in the MAC extend opmode(6:0) equals 1001000. "
           severity Warning;
           assert false
           report "DRC warning note : The simulation model does not know the placement of the DSP48E2 slices used, so it cannot fully confirm the above warning. It is necessary to view the placement of the DSP48E2 slices and ensure that these warnings are not being breached"
           severity Warning;

        end if;
     end if;
  end process cis_drc;

-- *** ALUMODE with 1 level of register
  ALUM_REG_P : process (CLK_in)
  begin
    if  (glblGSR = '1') then ALUMODE_reg <= (others => '0');
    elsif (rising_edge(CLK_in)) then
      if    (RSTALUMODE_in = '1') then ALUMODE_reg <= (others => '0');
      elsif (CEALUMODE_in = '1')  then ALUMODE_reg <= ALUMODE_in;
      end if;
    end if;
  end process;

  ALUMODE_mux <= ALUMODE_reg when ALUMODEREG_BIN = ALUMODEREG_1
                             else  ALUMODE_in;
------------------------------------------------------------------
-- *** DRC for OPMODE
------------------------------------------------------------------
-- needs PREG from output block
-- ~2000 lines code  - skip for now - copy/rework from DSP48E1.

-- --####################################################################
-- --#####                         ALU                              #####
-- --####################################################################

--  ADDSUB block - first stage of ALU develops sums and carries for Final Adder
--  Invert Z for subtract operation using alumode<0>

  z_optinv <= not zmux when (ALUMODE_mux(0) = '1') else zmux;

--  Add W, X, Y, Z carry-save style; basically full adder logic below
  co <= ((xmux and ymux) or (z_optinv and ymux) or (xmux and z_optinv));
--  s has a fan-out of 2 (1) FA with W (2) second leg of XOR tree
  s     <= (z_optinv xor xmux xor ymux);
  s_slv <= std_logic_vector(s);
--  Mux S and CO to do 2 operands logic operations
--  S = produce XOR/XNOR, NOT functions
--  CO = produce AND/NAND, OR/NOR functions
  comux <= (others => '0') when (ALUMODE_mux(2) = '1') else co;
  smux  <= co              when (ALUMODE_mux(3) = '1') else s ;

--  Carry mux to handle SIMD mode 
--  SIMD must be used here since addition of W requires carry propogation
  comux4simd  <=  comux(47 downto 36) &
                 (comux(35) and not USE_SIMD_BIN(2)) &
                  comux(34 downto 24) &
                 (comux(23) and not USE_SIMD_BIN(1)) &
                  comux(22 downto 12) &
                 (comux(11) and not USE_SIMD_BIN(0)) &
                  comux(10 downto 0);

--  FA to combine W-mux with s and co
--  comux must be shifted to properly reflect carry operation

  smux_w  <=   smux xor (comux4simd(46 downto 0) & '0') xor wmux;
  comux_w <= ((smux and (comux4simd(46 downto 0) & '0')) or
              (wmux and (comux4simd(46 downto 0) & '0')) or
              (smux and wmux));

--  alumode10 indicates a subtraction, used to correct carryout polarity
  ALUMODE10_out <= (ALUMODE_mux(0) and ALUMODE_mux(1));

--  prepare data for Final Adder
--  a_int(0) is in fact the cin bit, adder inputs: a_int(48 downto 1), b_int(47 downto 0), cin= a_int(0)
  a_int <= unsigned(comux_w) & cin;
  b_int <= unsigned(smux_w);

--  FINAL ADDER - second stage develops final sums and carries 
  s0       <= ('0' & a_int(11 downto 0)) + ('0' & b_int(11 downto 0));
--  invert if alumode10
  cout0    <= ALUMODE10_out xor (a_int(12) xor s0(12) xor comux(11));
--  internal carry is zero'd out on mc_simd = 1
  intc1    <= not USE_SIMD_BIN(0) and s0(12);
--  next lsb is zero'd out on mc_simd = 1
  co12_lsb <= not USE_SIMD_BIN(0) and a_int(12);
--  
  s1       <= ('0' & a_int(23 downto 13) & co12_lsb) +
              ('0' & b_int(23 downto 12)) +
              (X"000" & intc1);
  cout1    <= ALUMODE10_out xor (a_int(24) xor s1(12) xor comux(23));
  intc2    <= not USE_SIMD_BIN(1) and s1(12);
  co24_lsb <= not USE_SIMD_BIN(1) and a_int(24);
--  
  s2       <= ('0' & a_int(35 downto 25) & co24_lsb) +
              ('0' & b_int(35 downto 24)) +
              (X"000" & intc2);
  cout2    <= ALUMODE10_out xor (a_int(36) xor s2(12) xor comux(35));
  intc3    <= not USE_SIMD_BIN(2) and s2(12);
  co36_lsb <= not USE_SIMD_BIN(2) and a_int(36);
--  
  s3       <= ('0' & a_int(48 downto 37) & co36_lsb) +
              ('0' & comux4simd(47) & b_int(47 downto 36)) +
              (X"000" & intc3);
  cout3    <= ALUMODE10_out xor s3(12);

--  Not gated with alumode10 since used to propogate carry in wide multiply
--  (above is true in Fuji - need to revisit for Olympus)
  cout4 <= s3 (13);

--  Wide XOR
  xor_12a <= xor_6(s(5  downto 0))  when (USE_WIDEXOR_BIN = '1') else '0';
  xor_12b <= xor_6(s(11 downto 6))  when (USE_WIDEXOR_BIN = '1') else '0';
  xor_12c <= xor_6(s(17 downto 12)) when (USE_WIDEXOR_BIN = '1') else '0';
  xor_12d <= xor_6(s(23 downto 18)) when (USE_WIDEXOR_BIN = '1') else '0';
  xor_12e <= xor_6(s(29 downto 24)) when (USE_WIDEXOR_BIN = '1') else '0';
  xor_12f <= xor_6(s(35 downto 30)) when (USE_WIDEXOR_BIN = '1') else '0';
  xor_12g <= xor_6(s(41 downto 36)) when (USE_WIDEXOR_BIN = '1') else '0';
  xor_12h <= xor_6(s(47 downto 42)) when (USE_WIDEXOR_BIN = '1') else '0';
  xor_24a <= xor_12a xor xor_12b;
  xor_24b <= xor_12c xor xor_12d;
  xor_24c <= xor_12e xor xor_12f;
  xor_24d <= xor_12g xor xor_12h;
  xor_48a <= xor_24a xor xor_24b;
  xor_48b <= xor_24c xor xor_24d;
  xor_96  <= xor_48a xor xor_48b;

--   "X" carryout for multiply and logic operations
  mult_or_logic <= ((OPMODE_mux(3 downto 0)   = "0101") or
                    (ALUMODE_mux(3 downto 2) /= "00"));
-- allow carrycascout to not X in output atom
--  cout_3 <= 'X' when mult_or_logic else cout3;
  cout_3 <=                             cout3;
  cout_2 <= 'X' when mult_or_logic else cout2;
  cout_1 <= 'X' when mult_or_logic else cout1;
  cout_0 <= 'X' when mult_or_logic else cout0;
-- drive signals to Output Atom
-- turn SIMD X on
  COUT_out(3) <= cout_3;
  COUT_out(2) <= cout_2 when USE_SIMD_BIN  = USE_SIMD_FOUR12 else  'X';
  COUT_out(1) <= cout_1 when USE_SIMD_BIN /= USE_SIMD_ONE48  else  'X';
  COUT_out(0) <= cout_0 when USE_SIMD_BIN  = USE_SIMD_FOUR12 else  'X';
--  COUT_out(3) <= cout_3;
--  COUT_out(2) <= cout_2;
--  COUT_out(1) <= cout_1;
--  COUT_out(0) <= cout_0;
  MULTSIGN_ALU_out <= s3(13); -- from alu rtl but doesn't seem right
-- From E1
--  MULTSIGN_ALU_out <= MULTSIGNIN_in when OPMODE_mux (6 downto 4) = "100" else
--                      V_43_DATA_in;
  alu_o       <= std_logic_vector(s3(11 downto 0) & s2(11 downto 0) &
                                  s1(11 downto 0) & s0(11 downto 0));
  ALU_OUT_out   <= alu_o   when ALUMODE_mux(1) = '0' else not alu_o;
  XOR_MX_out(0) <= xor_12a when XORSIMD_BIN = '1' else xor_24a;
  XOR_MX_out(1) <= xor_12b when XORSIMD_BIN = '1' else xor_48a;
  XOR_MX_out(2) <= xor_12c when XORSIMD_BIN = '1' else xor_24b;
  XOR_MX_out(3) <= xor_12d when XORSIMD_BIN = '1' else xor_96;
  XOR_MX_out(4) <= xor_12e when XORSIMD_BIN = '1' else xor_24c;
  XOR_MX_out(5) <= xor_12f when XORSIMD_BIN = '1' else xor_48b;
  XOR_MX_out(6) <= xor_12g when XORSIMD_BIN = '1' else xor_24d;
  XOR_MX_out(7) <= xor_12h;

-- --########################### END ALU ################################

-- *** CarryIn Mux and Register

-------  input 0

  process (CLK_in)
  begin
    if  (glblGSR = '1') then CARRYIN_reg <= '0';
    elsif (rising_edge(CLK_in)) then
      if (RSTALLCARRYIN_in = '1') then CARRYIN_reg <= '0';
      elsif (CECARRYIN_in = '1')  then CARRYIN_reg <= CARRYIN_in;
      end if;
    end if;
  end process;

  CARRYIN_mux <= CARRYIN_reg when CARRYINREG_BIN = CARRYINREG_1 else
                 CARRYIN_in;

--  INTERNAL CARRYIN REGISTER
  c_mult        <= AMULT26_in xnor BMULT17_in;
  ce_m_g        <= CEM_in and not glblGSR; -- & gwe
  rst_carryin_g <= RSTALLCARRYIN_in and not glblGSR; -- & gwe
  d_carryin_int <= c_mult when ce_m_g = '1' else qmultcarryin;

--  rstallcarryin is injected through data path
  dr_carryin_int <= '0' when rst_carryin_g = '1' else d_carryin_int;
  process (CLK_in)
  begin
    if (glblGSR = '1') then qmultcarryin <= '0';
    elsif (rising_edge(CLK_in)) then
      qmultcarryin <= dr_carryin_int;
    end if;
  end process;

--  bypass register mux
  multcarryin_data  <=  qmultcarryin when MREG_BIN = MREG_1 else c_mult;

  process (CARRYINSEL_mux,CARRYIN_mux,PCIN_in(47),CARRYCASCIN_in,CCOUT_in,P_FDBK_in(47),multcarryin_data)
  begin
    case  CARRYINSEL_mux  is
      when "000"  => cin_b <= not CARRYIN_mux;
      when "001"  => cin_b <= PCIN_in(47);
      when "010"  => cin_b <= not CARRYCASCIN_in;
      when "011"  => cin_b <= not PCIN_in(47);
      when "100"  => cin_b <= not CCOUT_in;
      when "101"  => cin_b <= P_FDBK_in(47);
      when "110"  => cin_b <= not multcarryin_data;
      when "111"  => cin_b <= not P_FDBK_in(47);
      when others => cin_b <= 'X';
    end case;
  end process;
--  disable carryin when performing logic operation
  cin <= '0' when ((ALUMODE_mux(3) or ALUMODE_mux(2)) = '1') else not cin_b;

--  DSP_A_B_DATA
-- *********************************************************
-- *** Input register A with 2 level deep of registers
-- *********************************************************

  A_ACIN_mux <= ACIN_in when (A_INPUT_BIN = A_INPUT_CASCADE) else  A_in;
--  CLK_areg1  <= '0' when (AREG_BIN = AREG_0) else CLK_in  ;
--  CLK_areg2  <= '0' when (AREG_BIN = AREG_0) else CLK_in  ;

  process (CLK_areg1) begin
    if  (glblGSR = '1') then A1_reg <= (others => '0');
    elsif (rising_edge(CLK_areg1)) then
      if     (RSTA_in = '1') then A1_reg <= (others => '0');
      elsif  (CEA1_in = '1') then A1_reg <= A_ACIN_mux;
      end if;
    end if;
  end process;

  A1_reg_mux  <=  A1_reg when (AREG_BIN = AREG_2) else A_ACIN_mux;

  process (CLK_areg2)
  begin
    if  (glblGSR = '1') then A2_reg <= (others => '0');
    elsif (rising_edge(CLK_areg2)) then
      if    (RSTA_in = '1') then A2_reg <= (others => '0');
      elsif (CEA2_in = '1') then A2_reg <= A1_reg_mux;
      end if;
    end if;
  end process;

  A2_reg_mux  <= A1_reg_mux when (AREG_BIN = AREG_0) else A2_reg;

-- assumes encoding the same for ACASCREG and AREG
  ACOUT_out   <= A2_reg_mux when ACASCREG_BIN = AREG_BIN else A1_reg;
  A1_DATA_out <= A1_reg (26 downto 0);
  A2_DATA_out <= A2_reg_mux (26 downto 0);

-- *********************************************************
-- *** Input register B with 2 level deep of registers
-- *********************************************************

  B_BCIN_mux <= BCIN_in when (B_INPUT_BIN = B_INPUT_CASCADE) else B_in;
--  CLK_breg1  <= '0' when (BREG_BIN = BREG_0) else CLK_in ;
--  CLK_breg2  <= '0' when (BREG_BIN = BREG_0) else CLK_in ;

  process (CLK_breg1) begin
    if (glblGSR = '1') then B1_reg <= (others => '0');
    elsif (rising_edge(CLK_breg1)) then
      if    (RSTB_in = '1') then B1_reg <= (others => '0');
      elsif (CEB1_in = '1') then B1_reg <= B_BCIN_mux;
      end if;
    end if;
  end process;

  B1_reg_mux  <= B1_reg when (BREG_BIN = BREG_2) else B_BCIN_mux;

  process (CLK_breg2) begin
    if (glblGSR = '1') then B2_reg <= (others => '0');
    elsif (rising_edge(CLK_breg2)) then
      if    (RSTB_in = '1') then B2_reg <= (others => '0');
      elsif (CEB2_in = '1') then B2_reg <= B1_reg_mux;
      end if;
    end if;
  end process;

  B2_reg_mux <=  B1_reg_mux when (BREG_BIN = BREG_0) else B2_reg;

-- assumes encoding the same for BCASCREG and BREG
  BCOUT_out   <= B2_reg_mux when BCASCREG_BIN = BREG_BIN else B1_reg;
  B1_DATA_out <= B1_reg;
  B2_DATA_out <= B2_reg_mux;

--  DSP_C_DATA
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

--  DSP_MULTIPLIER
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

--  DSP_M_DATA
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

--  DSP_OUTPUT
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

--  DSP_PREADD
-- *********************************************************
-- *** Preaddsub AD
-- *********************************************************
  D_DATA_mux <= D_DATA_in when INMODE_2_in = '1' else (others => '0');
  AD_out <= std_logic_vector(unsigned(D_DATA_mux) - unsigned(PREADD_AB_in))
            when (ADDSUB_in = '1') else
            std_logic_vector(unsigned(D_DATA_mux) + unsigned(PREADD_AB_in));

--  DSP_PREADD_DATA
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


  process (OPMODE_mux) begin
    if  (((OPMODE_mux(1 downto 0) = "11") and (USE_MULT_BIN = USE_MULT_MULTIPLY)) and
         ((AREG = 0 and BREG = 0 and MREG = 0) or
          (AREG = 0 and BREG = 0 and PREG = 0) or
          (MREG = 0 and PREG = 0))) then
          assert false
          report "OPMODE Input Warning : The OPMODE(1:0) (11) on DSP48E2 is invalid when using attributes USE_MULT = MULTIPLY and (A, B and M) or (A, B and P) or (M and P) are not REGISTERED. Please set USE_MULT to either NONE or DYNAMIC or REGISTER one of each group. (A or B) and (M or P) to satisfy the requirement."
          severity Warning;
    end if;
    if  ((OPMODE_mux(3 downto 0) = "0101") and
         ((USE_MULT_BIN = USE_MULT_NONE) or (USE_SIMD_BIN /= USE_SIMD_ONE48))) then
          assert false
          report "OPMODE Input Warning : The OPMODE(3:0) (0101) on DSP48E2 is invalid when using attributes USE_MULT = NONE or USE_SIMD = TWO24 or USE_SIMD = FOUR12."
          severity Warning;
    end if;
  end process;


-- any timing


end DSP48E2_V;
