-----------------------------------------------------------------------------
--  Copyright (c) 2013 Xilinx Inc.
--  All Right Reserved.
-----------------------------------------------------------------------------
--
--   ____  ____
--  /   /\/   /
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version     : 2012.2 
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                      
-- /___/   /\      Filename    : HPIO_VREF.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-----------------------------------------------------------------------------
--  Revision:
--
--  End Revision:
-----------------------------------------------------------------------------

----- CELL HPIO_VREF -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;

library UNISIM;
use UNISIM.VPKG.all;
use UNISIM.VCOMPONENTS.all;

entity HPIO_VREF is
  generic (
    VREF_CNTR : string := "OFF"
  );

  port (
    VREF                 : out std_ulogic;
    FABRIC_VREF_TUNE     : in std_logic_vector(6 downto 0)    
  );
end HPIO_VREF;

architecture HPIO_VREF_V of HPIO_VREF is
  
  constant MODULE_NAME : string := "HPIO_VREF";
  constant IN_DELAY : time := 0 ps;
  constant OUT_DELAY : time := 0 ps;
  constant INCLK_DELAY : time := 0 ps;
  constant OUTCLK_DELAY : time := 0 ps;

-- Parameter encodings and registers
  constant VREF_CNTR_FABRIC_RANGE1 : std_logic_vector(1 downto 0) := "01";
  constant VREF_CNTR_FABRIC_RANGE2 : std_logic_vector(1 downto 0) := "10";
  constant VREF_CNTR_OFF : std_logic_vector(1 downto 0) := "00";

  signal VREF_CNTR_BIN : std_logic_vector(1 downto 0);

  signal glblGSR      : std_ulogic;
  
  signal attr_err     : std_ulogic := '0';
  
  signal VREF_out : std_ulogic := '1';
  
  signal VREF_delay : std_ulogic;
  
  signal FABRIC_VREF_TUNE_delay : std_logic_vector(6 downto 0);
  
  signal FABRIC_VREF_TUNE_in : std_logic_vector(6 downto 0);
  
  begin
  glblGSR     <= TO_X01(GSR);
  VREF <= VREF_delay after OUT_DELAY;
  
  VREF_delay <= VREF_out;
  
  FABRIC_VREF_TUNE_delay <= FABRIC_VREF_TUNE after IN_DELAY;
  
  FABRIC_VREF_TUNE_in <= FABRIC_VREF_TUNE_delay;
  
  VREF_CNTR_BIN <= 
    VREF_CNTR_OFF when (VREF_CNTR = "OFF") else
    VREF_CNTR_FABRIC_RANGE1 when (VREF_CNTR = "FABRIC_RANGE1") else
    VREF_CNTR_FABRIC_RANGE2 when (VREF_CNTR = "FABRIC_RANGE2") else
    VREF_CNTR_OFF;

  
  INIPROC : process
  begin
-------- VREF_CNTR check
  -- case VREF_CNTR is
    if((VREF_CNTR = "OFF") or (VREF_CNTR = "off")) then
      null;
    elsif((VREF_CNTR = "FABRIC_RANGE1") or (VREF_CNTR = "fabric_range1")) then
      null;
    elsif((VREF_CNTR = "FABRIC_RANGE2") or (VREF_CNTR = "fabric_range2")) then
      null;
    else
      attr_err <= '1';
      assert FALSE report "Error : VREF_CNTR is not OFF, FABRIC_RANGE1, FABRIC_RANGE2." severity warning;
    end if;
  -- end case;
  if  (attr_err = '1') then
    assert FALSE
    report "Error : Attribute Error(s) encountered"
    severity error;
  end if;
  wait;
  end process INIPROC;

  HPIO_VREF_Behav : process (FABRIC_VREF_TUNE_in)
  variable  Message : line;
  begin
  Write (Message, string'("Fabric Tune Value changed to " ));
  Write (Message, FABRIC_VREF_TUNE_in);
  Writeline (OUTPUT,Message);
  end process HPIO_VREF_Behav;
end HPIO_VREF_V;
