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
-- /___/   /\      Filename    : OBUFTE3.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-----------------------------------------------------------------------------
--  Revision:
--
--  End Revision:
-----------------------------------------------------------------------------

----- CELL OBUFTE3 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

library UNISIM;
use UNISIM.VPKG.all;
use UNISIM.VCOMPONENTS.all;

entity OBUFTE3 is
  generic (
    DRIVE : integer := 12;
    IOSTANDARD : string := "DEFAULT"
  );

  port (
    O                    : out std_ulogic;
    I                    : in std_ulogic;
    T                    : in std_ulogic    
  );
end OBUFTE3;

architecture OBUFTE3_V of OBUFTE3 is
  
  constant MODULE_NAME : string := "OBUFTE3";
  constant IN_DELAY : time := 0 ps;
  constant OUT_DELAY : time := 0 ps;
  constant INCLK_DELAY : time := 0 ps;
  constant OUTCLK_DELAY : time := 0 ps;

-- Parameter encodings and registers
  constant IOSTANDARD_DEFAULT : std_ulogic := '0';

  signal DRIVE_BIN : std_logic_vector(4 downto 0);
-- DRIVE num 1 min  max 

  signal IOSTANDARD_BIN : std_ulogic;

  signal glblGSR      : std_ulogic;
  
  signal attr_err     : std_ulogic := '0';
  
  signal O_out : std_ulogic;
  
  signal O_delay : std_ulogic;
  
  signal I_delay : std_ulogic;
  signal T_delay : std_ulogic;
  
  signal I_in : std_ulogic;
  signal T_in : std_ulogic;
  
  begin
  glblGSR     <= TO_X01(GSR);
  O <= O_delay after OUT_DELAY;
  
  O_delay <= O_out;
  
  I_delay <= I after IN_DELAY;
  T_delay <= T after IN_DELAY;
  
  I_in <= I_delay;
  T_in <= T_delay;
  
  DRIVE_BIN <= std_logic_vector(to_unsigned(DRIVE,5));
-- DRIVE num 1 min 2 max 24

  IOSTANDARD_BIN <= 
    IOSTANDARD_DEFAULT when (IOSTANDARD = "DEFAULT") else
    IOSTANDARD_DEFAULT;

  
  INIPROC : process
  begin
-------- DRIVE check
  if ((DRIVE >= 2) and (DRIVE <= 24)) then
    null;
  else
    attr_err <= '1';
    assert FALSE report "Error : DRIVE is not in range 2 .. 24." severity warning;
  end if;
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
  FunctionalBehavior_OBUFTE3   : process (I_in, T_in)
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
  end process;

end OBUFTE3_V;
