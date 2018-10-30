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
-- /___/   /\      Filename    : ODDRE1.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-----------------------------------------------------------------------------
--  Revision:
--
--  End Revision:
-----------------------------------------------------------------------------

----- CELL ODDRE1 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

library UNISIM;
use UNISIM.VPKG.all;
use UNISIM.VCOMPONENTS.all;

entity ODDRE1 is
  generic (
    IS_C_INVERTED : std_ulogic := '0';
    IS_D1_INVERTED : std_ulogic := '0';
    IS_D2_INVERTED : std_ulogic := '0';
    SRVAL : std_ulogic := '0'
  );

  port (
    Q                    : out std_ulogic;
    C                    : in std_ulogic;
    D1                   : in std_ulogic;
    D2                   : in std_ulogic;
    SR                   : in std_ulogic    
  );
end ODDRE1;

architecture ODDRE1_V of ODDRE1 is
  
  constant MODULE_NAME : string := "ODDRE1";
  constant IN_DELAY : time := 0 ps;
  constant OUT_DELAY : time := 0 ps;
  constant INCLK_DELAY : time := 0 ps;
  constant OUTCLK_DELAY : time := 0 ps;

-- Parameter encodings and registers

  signal SRVAL_BIN : std_ulogic;

  signal glblGSR      : std_ulogic;
  
  signal attr_err     : std_ulogic := '0';
  
  signal Q_out : std_ulogic;
  
  signal Q_delay : std_ulogic;
  
  signal C_delay : std_ulogic;
  signal D1_delay : std_ulogic;
  signal D2_delay : std_ulogic;
  signal SR_delay : std_ulogic;
  
  signal C_in : std_ulogic;
  signal D1_in : std_ulogic;
  signal D2_in : std_ulogic;
  signal SR_in : std_ulogic;
  signal QD2_posedge_int : std_ulogic;
  signal      R_sync1        : std_ulogic := '0'; 
  signal      R_sync2        : std_ulogic := '0'; 
  signal      R_sync3        : std_ulogic := '0'; 

  
  begin
  glblGSR     <= TO_X01(GSR);
  Q <= Q_delay after OUT_DELAY;
  
  Q_delay <= Q_out;
  
  C_delay <= C after INCLK_DELAY;
  
  D1_delay <= D1 after IN_DELAY;
  D2_delay <= D2 after IN_DELAY;
  SR_delay <= SR after IN_DELAY;
  
  C_in <= C_delay xor IS_C_INVERTED;
  D1_in <= D1_delay xor IS_D1_INVERTED;
  D2_in <= D2_delay xor IS_D2_INVERTED;
  SR_in <= SR_delay;
  
  SRVAL_BIN <= SRVAL;

  
  INIPROC : process
  begin
-------- SRVAL check
  -- SRVAL_BIN <= SRVAL;
  if  (attr_err = '1') then
    assert FALSE
    report "Error : Attribute Error(s) encountered"
    severity error;
  end if;
  wait;
  end process INIPROC;
  
--####################################################################
--#####                       R_sync                        #####
--####################################################################  
  prcs_R_sync: process(C_in)
  begin
	  if(rising_edge(C_in)) then
		  R_sync1 <= SR_in;
		  R_sync2 <= R_sync1;
		  R_sync3 <= R_sync2;
	  end if;
  end process prcs_R_sync;
  
  PRCS_C : process(C_in,glblGSR,SR_in)
  begin
    if(glblGSR = '1') then
       Q_out <= TO_X01(SRVAL);
       QD2_posedge_int <= TO_X01(SRVAL);
    elsif(glblGSR = '0') then
      if (SR_in = '1' or R_sync1 = '1' or R_sync2 = '1' or R_sync3 = '1') then
        Q_out <= TO_X01(SRVAL);
	QD2_posedge_int <= TO_X01(SRVAL);
      elsif (R_sync3 = '0' or R_sync3 = 'L' or R_sync3 = 'U') then
        if(rising_edge(C_in)) then
	  Q_out <= D1_in;
	  QD2_posedge_int <= D2_in;
	end if;
	if (falling_edge(C_in)) then
	  Q_out <= QD2_posedge_int;
	end if;
      end if;	
    end if;
  
  end process PRCS_C;
end ODDRE1_V;
