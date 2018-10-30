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
-- \   \  /  \    Filename    : DSP_A_B_DATA.v 
--  \___\/\___\
-- 
-----------------------------------------------------------------------------
--  Revision:
--  07/15/12 - Migrate from E1.
--  12/10/12 - Add dynamic registers
--  03/06/13 - 701316 - A_B_reg no clk when REG=0
--  04/22/13 - 714213 - ACOUT, BCOUT wrong logic
--  04/22/13 - change from CLK'event to rising_edge(CLK)
--  04/23/13 - 714772 - remove sensitivity to negedge GSR
--  End Revision:
-----------------------------------------------------------------------------

----- CELL DSP_A_B_DATA -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity DSP_A_B_DATA is
  generic (
    ACASCREG   : integer := 1;
    AREG       : integer := 1;
    A_INPUT    : string := "DIRECT";
    BCASCREG   : integer := 1;
    BREG       : integer := 1;
    B_INPUT    : string := "DIRECT";
    IS_CLK_INVERTED : std_ulogic := '0';
    IS_RSTA_INVERTED : std_ulogic := '0';
    IS_RSTB_INVERTED : std_ulogic := '0'
   );

  port (
    A1_DATA              : out std_logic_vector(26 downto 0);
    A2_DATA              : out std_logic_vector(26 downto 0);
    ACOUT                : out std_logic_vector(29 downto 0);
    A_ALU                : out std_logic_vector(29 downto 0);
    B1_DATA              : out std_logic_vector(17 downto 0);
    B2_DATA              : out std_logic_vector(17 downto 0);
    BCOUT                : out std_logic_vector(17 downto 0);
    B_ALU                : out std_logic_vector(17 downto 0);
    A                    : in std_logic_vector(29 downto 0);
    ACIN                 : in std_logic_vector(29 downto 0);
    B                    : in std_logic_vector(17 downto 0);
    BCIN                 : in std_logic_vector(17 downto 0);
    CEA1                 : in std_ulogic;
    CEA2                 : in std_ulogic;
    CEB1                 : in std_ulogic;
    CEB2                 : in std_ulogic;
    CLK                  : in std_ulogic;
    RSTA                 : in std_ulogic;
    RSTB                 : in std_ulogic
   );
end DSP_A_B_DATA;

architecture DSP_A_B_DATA_V of DSP_A_B_DATA is
--  define constants
  constant MODULE_NAME        : string := "DSP_A_B_DATA";
  constant IN_DELAY           : time := 0 ps;
  constant OUT_DELAY          : time := 0 ps;
  constant INCLK_DELAY        : time := 0 ps;
  constant OUTCLK_DELAY       : time := 0 ps;

--  Parameter encodings and registers
  constant ACASCREG_0         : std_logic_vector(1 downto 0) := "00"; -- logic depends on ACASCREG, AREG encoding the same
  constant ACASCREG_1         : std_logic_vector(1 downto 0) := "01";
  constant ACASCREG_2         : std_logic_vector(1 downto 0) := "10";
  constant AREG_0             : std_logic_vector(1 downto 0) := "00";
  constant AREG_1             : std_logic_vector(1 downto 0) := "01";
  constant AREG_2             : std_logic_vector(1 downto 0) := "10";
  constant A_INPUT_CASCADE    : std_ulogic := '1';
  constant A_INPUT_DIRECT     : std_ulogic := '0';
  constant BCASCREG_0         : std_logic_vector(1 downto 0) := "00";
  constant BCASCREG_1         : std_logic_vector(1 downto 0) := "01";
  constant BCASCREG_2         : std_logic_vector(1 downto 0) := "10";
  constant BREG_0             : std_logic_vector(1 downto 0) := "00";
  constant BREG_1             : std_logic_vector(1 downto 0) := "01";
  constant BREG_2             : std_logic_vector(1 downto 0) := "10";
  constant B_INPUT_CASCADE    : std_ulogic := '1';
  constant B_INPUT_DIRECT     : std_ulogic := '0';

  signal ACASCREG_BIN           : std_logic_vector(1 downto 0);
  signal AREG_BIN               : std_logic_vector(1 downto 0);
  signal A_INPUT_BIN            : std_ulogic;
  signal BCASCREG_BIN           : std_logic_vector(1 downto 0);
  signal BREG_BIN               : std_logic_vector(1 downto 0);
  signal B_INPUT_BIN            : std_ulogic;

  signal glblGSR              : std_ulogic;

  signal attr_err             : std_ulogic := '0';

  signal A1_DATA_out          : std_logic_vector(26 downto 0);
  signal A2_DATA_out          : std_logic_vector(26 downto 0);
  signal ACOUT_out            : std_logic_vector(29 downto 0);
--  signal A_ALU_out            : std_logic_vector(29 downto 0);
  signal B1_DATA_out          : std_logic_vector(17 downto 0);
  signal B2_DATA_out          : std_logic_vector(17 downto 0);
  signal BCOUT_out            : std_logic_vector(17 downto 0);
--  signal B_ALU_out            : std_logic_vector(17 downto 0);

  signal A1_DATA_delay        : std_logic_vector(26 downto 0);
  signal A2_DATA_delay        : std_logic_vector(26 downto 0);
  signal ACOUT_delay          : std_logic_vector(29 downto 0);
  signal A_ALU_delay          : std_logic_vector(29 downto 0);
  signal B1_DATA_delay        : std_logic_vector(17 downto 0);
  signal B2_DATA_delay        : std_logic_vector(17 downto 0);
  signal BCOUT_delay          : std_logic_vector(17 downto 0);
  signal B_ALU_delay          : std_logic_vector(17 downto 0);

  signal ACIN_delay           : std_logic_vector(29 downto 0);
  signal A_delay              : std_logic_vector(29 downto 0);
  signal BCIN_delay           : std_logic_vector(17 downto 0);
  signal B_delay              : std_logic_vector(17 downto 0);
  signal CEA1_delay           : std_ulogic;
  signal CEA2_delay           : std_ulogic;
  signal CEB1_delay           : std_ulogic;
  signal CEB2_delay           : std_ulogic;
  signal CLK_delay            : std_ulogic;
  signal RSTA_delay           : std_ulogic;
  signal RSTB_delay           : std_ulogic;

  signal ACIN_in              : std_logic_vector(29 downto 0);
  signal A_in                 : std_logic_vector(29 downto 0);
  signal BCIN_in              : std_logic_vector(17 downto 0);
  signal B_in                 : std_logic_vector(17 downto 0);
  signal CEA1_in              : std_ulogic;
  signal CEA2_in              : std_ulogic;
  signal CEB1_in              : std_ulogic;
  signal CEB2_in              : std_ulogic;
  signal RSTA_in              : std_ulogic;
  signal RSTB_in              : std_ulogic;

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

--  input output assignments
begin
   glblGSR          <= TO_X01(GSR);
   A1_DATA          <= A1_DATA_delay  after OUT_DELAY;
   A2_DATA          <= A2_DATA_delay  after OUT_DELAY;
   ACOUT            <= ACOUT_delay  after OUT_DELAY;
   A_ALU            <= A_ALU_delay  after OUT_DELAY;
   B1_DATA          <= B1_DATA_delay  after OUT_DELAY;
   B2_DATA          <= B2_DATA_delay  after OUT_DELAY;
   BCOUT            <= BCOUT_delay  after OUT_DELAY;
   B_ALU            <= B_ALU_delay  after OUT_DELAY;

   A1_DATA_delay <= A1_DATA_out;
   A2_DATA_delay <= A2_DATA_out;
   ACOUT_delay   <= ACOUT_out;
   A_ALU_delay   <= A2_reg_mux;
   B1_DATA_delay <= B1_DATA_out;
   B2_DATA_delay <= B2_DATA_out;
   BCOUT_delay <= BCOUT_out;
   B_ALU_delay <= B2_reg_mux;

   CLK_delay           <= CLK after INCLK_DELAY;

   ACIN_delay          <= ACIN after IN_DELAY;
   A_delay             <= A after IN_DELAY;
   BCIN_delay          <= BCIN after IN_DELAY;
   B_delay             <= B after IN_DELAY;
   CEA1_delay          <= CEA1 after IN_DELAY;
   CEA2_delay          <= CEA2 after IN_DELAY;
   CEB1_delay          <= CEB1 after IN_DELAY;
   CEB2_delay          <= CEB2 after IN_DELAY;
   RSTA_delay          <= RSTA after IN_DELAY;
   RSTB_delay          <= RSTB after IN_DELAY;

   ACIN_in <= ACIN_delay;
   A_in <= A_delay;
   BCIN_in <= BCIN_delay;
   B_in <= B_delay;
   CEA1_in <= CEA1_delay;
   CEA2_in <= CEA2_delay;
   CEB1_in <= CEB1_delay;
   CEB2_in <= CEB2_delay;
   CLK_areg1 <= '0' when (AREG_BIN = AREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_areg2 <= '0' when (AREG_BIN = AREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_breg1 <= '0' when (BREG_BIN = BREG_0) else CLK_delay xor IS_CLK_INVERTED;
   CLK_breg2 <= '0' when (BREG_BIN = BREG_0) else CLK_delay xor IS_CLK_INVERTED;
   RSTA_in <= RSTA_delay xor IS_RSTA_INVERTED;
   RSTB_in <= RSTB_delay xor IS_RSTB_INVERTED;

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
    if  (attr_err = '1') then
       assert FALSE
       report "Error : Attribute Error(s) encountered"
       severity error;
    end if;
    wait;
  end process INIPROC;

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


-- any timing


end DSP_A_B_DATA_V;
