-----------------------------------------------------------------------------
--  Copyright (c) 2011 Xilinx Inc.
--  All Right Reserved.
-----------------------------------------------------------------------------
--
--   ____  ____
--  /   /\/   /
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version     : 2012.2 
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                      
-- /___/   /\      Filename    : HARD_SYNC.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-----------------------------------------------------------------------------
--  Revision:
--  01/30/13 Initial version
--  05/17/13 fix BIN encoding, remove SR, add IS_CLK_INVERTED
--  End Revision:
-----------------------------------------------------------------------------

----- CELL HARD_SYNC -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;
use UNISIM.VCOMPONENTS.all;

entity HARD_SYNC is
  generic (
    INIT : std_ulogic := '0';
    IS_CLK_INVERTED : std_ulogic := '0';
    LATENCY : integer := 2
  );

  port (
    DOUT                 : out std_ulogic;
    CLK                  : in std_ulogic;
    DIN                  : in std_ulogic
  );
end HARD_SYNC;

architecture HARD_SYNC_V of HARD_SYNC is
    
  constant MODULE_NAME : string := "HARD_SYNC";
  constant IN_DELAY : time := 0 ps;
  constant OUT_DELAY : time := 0 ps;
  constant INCLK_DELAY : time := 0 ps;
  constant OUTCLK_DELAY : time := 0 ps;

  constant LATENCY_2 : std_ulogic := '0';
  constant LATENCY_3 : std_ulogic := '1';

  signal INIT_BIN : std_ulogic;
  signal IS_CLK_INVERTED_BIN : std_ulogic;
  signal LATENCY_BIN : std_ulogic;
    
  signal glblGSR : std_ulogic;
    
  signal attr_err : std_ulogic := '0';

  signal DOUT_out : std_ulogic;
    
  signal DOUT_delay : std_ulogic;
    
  signal CLK_delay : std_ulogic;
  signal DIN_delay : std_ulogic;
    
  signal CLK_in : std_ulogic;
  signal DIN_in : std_ulogic;
    
  signal D1_reg   : std_ulogic;
  signal D2_reg   : std_ulogic;
  signal D3_reg   : std_ulogic;

  begin
  glblGSR     <= TO_X01(GSR);
  DOUT <= DOUT_delay after OUT_DELAY;
  
  DOUT_delay <= DOUT_out;
    
  CLK_delay <= CLK after IN_DELAY;
  DIN_delay <= DIN after IN_DELAY;
    
  CLK_in <= CLK_delay xor IS_CLK_INVERTED_BIN;
  DIN_in <= DIN_delay;
    
  INIT_BIN <= INIT;

  IS_CLK_INVERTED_BIN <= IS_CLK_INVERTED;

  LATENCY_BIN <= 
    LATENCY_2 when (LATENCY = 2) else
    LATENCY_3 when (LATENCY = 3) else
    LATENCY_2;

  INIPROC : process
  begin
  if((LATENCY /= 2) and (LATENCY /= 3)) then
    attr_err <= '1';
    assert FALSE report "Error : LATENCY is not in range 2 .. 3." severity warning;
  end if;

  if  (attr_err = '1') then
     assert FALSE
     report "Error : Attribute Error(s) encountered"
     severity error;
  end if;
  wait;
  end process INIPROC;

  DOUT_out <= D2_reg when (LATENCY_BIN = LATENCY_2) else D3_reg;

  sync : process (CLK_in, glblGSR) begin
    if (glblGSR = '1') then
      D3_reg <= INIT_BIN;
      D2_reg <= INIT_BIN;
      D1_reg <= INIT_BIN;
    elsif (rising_edge(CLK_in)) then
      D3_reg <= D2_reg;
      D2_reg <= D1_reg;
      D1_reg <= DIN_in;
    end if;
  end process;
end HARD_SYNC_V;
