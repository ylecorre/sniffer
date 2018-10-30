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
-- /___/   /\      Filename    : OBUFTDSE3.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-----------------------------------------------------------------------------
--  Revision:
--
--  End Revision:
-----------------------------------------------------------------------------

----- CELL OBUFTDSE3 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

library UNISIM;
use UNISIM.VPKG.all;
use UNISIM.VCOMPONENTS.all;

entity OBUFTDSE3 is
  generic (
    IOSTANDARD : string := "DEFAULT"
  );

  port (
    O                    : out std_ulogic;
    OB                   : out std_ulogic;
    I                    : in std_ulogic;
    T                    : in std_ulogic    
  );
end OBUFTDSE3;

architecture OBUFTDSE3_V of OBUFTDSE3 is
  
  constant MODULE_NAME : string := "OBUFTDSE3";
  constant IN_DELAY : time := 0 ps;
  constant OUT_DELAY : time := 0 ps;
  constant INCLK_DELAY : time := 0 ps;
  constant OUTCLK_DELAY : time := 0 ps;

-- Parameter encodings and registers
  constant IOSTANDARD_DEFAULT : std_ulogic := '0';

  signal IOSTANDARD_BIN : std_ulogic;

  signal glblGSR      : std_ulogic;
  
  signal attr_err     : std_ulogic := '0';
  
  signal OB_out : std_ulogic;
  signal O_out : std_ulogic;
  
  signal OB_delay : std_ulogic;
  signal O_delay : std_ulogic;
  
  signal I_delay : std_ulogic;
  signal T_delay : std_ulogic;
  
  signal I_in : std_ulogic;
  signal T_in : std_ulogic;
  
  begin
  glblGSR     <= TO_X01(GSR);
  O <= O_delay after OUT_DELAY;
  OB <= OB_delay after OUT_DELAY;
  
  OB_delay <= OB_out;
  O_delay <= O_out;
  
  I_delay <= I after IN_DELAY;
  T_delay <= T after IN_DELAY;
  
  I_in <= I_delay;
  T_in <= T_delay;
  
  IOSTANDARD_BIN <= 
    IOSTANDARD_DEFAULT when (IOSTANDARD = "DEFAULT") else
    IOSTANDARD_DEFAULT;

  
  INIPROC : process
  begin
-------- IOSTANDARD check
  -- case IOSTANDARD is
    if((IOSTANDARD = "DEFAULT") or (IOSTANDARD = "default")) then
      null;
    else
      attr_err <= '1';
      assert FALSE report "Error : IOSTANDARD is not DEFAULT." severity warning;
    end if;
  -- end case;
  if  (attr_err = '1') then
    assert FALSE
    report "Error : Attribute Error(s) encountered"
    severity error;
  end if;
  wait;
  end process INIPROC;
    FunctionalBehavior_OBUFTDSE3    : process (I_in, T_in)
  begin

    if ((T_in = '1') or (T_in = 'H')) then
      O_out <= 'Z';
    elsif ((T_in = '0') or (T_in = 'L')) then
      if ((I_in = '1') or (I_in = 'H')) then
        O_out <= '1';
      elsif ((I_in = '0') or (I_in = 'L')) then
        O_out <= '0';
      elsif (I_in = 'U') then
        O_out <= 'U';
      else
        O_out <= 'X';  
      end if;
    elsif (T_in = 'U') then
      O_out <= 'U';          
    else                                      
      O_out <= 'X';  
    end if;

    if ((T_in = '1') or (T_in = 'H')) then
      OB_out <= 'Z';
    elsif ((T_in = '0') or (T_in = 'L')) then
      if (((not I_in) = '1') or ((not I_in) = 'H')) then
        OB_out <= '1';
      elsif (((not I_in) = '0') or ((not I_in) = 'L')) then
        OB_out <= '0';
      elsif ((not I_in) = 'U') then
        OB_out <= 'U';
      else
        OB_out <= 'X';  
      end if;
    elsif (T_in = 'U') then
      OB_out <= 'U';          
    else                                      
      OB_out <= 'X';  
    end if;        
  end process;
  
end OBUFTDSE3_V;
