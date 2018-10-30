-- $Header: $
-------------------------------------------------------
--  Copyright (c) 2011 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   /
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version     : 2012.2 
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                      
-- /___/   /\      Filename    : IBUFCTRL.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-------------------------------------------------------
--  Revision:
--
--  End Revision:
-------------------------------------------------------

----- CELL IBUFCTRL -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity IBUFCTRL is
    generic (
      ISTANDARD : string := "UNUSED";
      USE_IBUFDISABLE : string := "FALSE"
    );

    port (
      O                    : out std_ulogic;
      I                    : in std_ulogic;
      IBUFDISABLE          : in std_ulogic;
      INTERMDISABLE        : in std_ulogic;
      T                    : in std_ulogic      
    );
  end IBUFCTRL;

  architecture IBUFCTRL_V of IBUFCTRL is
    
    constant MODULE_NAME : string := "IBUFCTRL";
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    constant ISTANDARD_UNUSED : std_ulogic := '0';
    constant USE_IBUFDISABLE_FALSE : integer := 1;
    constant USE_IBUFDISABLE_TRUE : integer := 0;

    signal USE_IBUFDISABLE_BIN : integer;
    
    signal ISTANDARD_BIN : std_ulogic;
    signal glblGSR : std_ulogic;
    
    signal O_out : std_ulogic;
    
    signal O_delay : std_ulogic;
    
    signal IBUFDISABLE_delay : std_ulogic;
    signal INTERMDISABLE_delay : std_ulogic;
    signal I_delay : std_ulogic;
    signal T_delay : std_ulogic;
    
    signal IBUFDISABLE_in : std_ulogic;
    signal INTERMDISABLE_in : std_ulogic;
    signal I_in : std_ulogic;
    signal T_in : std_ulogic;
    
    begin
    glblGSR     <= TO_X01(GSR);
    O <= O_delay after OUT_DELAY;
    
    O_delay <= O_out;
    
    IBUFDISABLE_delay <= IBUFDISABLE after IN_DELAY;
    INTERMDISABLE_delay <= INTERMDISABLE after IN_DELAY;
    I_delay <= I after IN_DELAY;
    T_delay <= T after IN_DELAY;
    
    IBUFDISABLE_in <= IBUFDISABLE_delay;
    INTERMDISABLE_in <= INTERMDISABLE_delay;
    I_in <= I_delay;
    T_in <= T_delay;
   
     ISTANDARD_BIN <= 
    ISTANDARD_UNUSED when (ISTANDARD = "UNUSED") else
    ISTANDARD_UNUSED;

    
    INIPROC : process
    begin
    -------- ISTANDARD check
  -- case ISTANDARD is
    if((ISTANDARD = "UNUSED") or (ISTANDARD = "unused")) then
      null;
    else
      assert FALSE report "Error : ISTANDARD is not UNUSED." severity error;
    end if;
  -- end case;
    -- case USE_IBUFDISABLE is
      if((USE_IBUFDISABLE = "TRUE") or (USE_IBUFDISABLE = "true")) then
        USE_IBUFDISABLE_BIN <= USE_IBUFDISABLE_TRUE;
      elsif((USE_IBUFDISABLE = "FALSE") or (USE_IBUFDISABLE = "false")) then
        USE_IBUFDISABLE_BIN <= USE_IBUFDISABLE_FALSE;
      else
        assert FALSE report "Error : USE_IBUFDISABLE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    wait;
    end process INIPROC;

 Behavior     : process (IBUFDISABLE_in, I_in, T_in)
  variable NOT_T_OR_IBUFDISABLE   : std_ulogic := '0';  
  begin
    if(USE_IBUFDISABLE = "TRUE") then
       NOT_T_OR_IBUFDISABLE := IBUFDISABLE_in OR (not T_in);

       if(NOT_T_OR_IBUFDISABLE = '1') then
          O_out  <= '0';
       elsif (NOT_T_OR_IBUFDISABLE = '0') then
          O_out  <= TO_X01(I_in);
       end if; 
    elsif(USE_IBUFDISABLE = "FALSE") then
          O_out  <= TO_X01(I_in);
    end if;	  
  end process;
  end IBUFCTRL_V;
