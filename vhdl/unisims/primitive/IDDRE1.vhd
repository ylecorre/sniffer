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
-- /___/   /\      Filename    : IDDRE1.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-----------------------------------------------------------------------------
--  Revision:
--
--  End Revision:
-----------------------------------------------------------------------------

----- CELL IDDRE1 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

library UNISIM;
use UNISIM.VPKG.all;
use UNISIM.VCOMPONENTS.all;

entity IDDRE1 is
  generic (
    DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
    IS_C_INVERTED : std_ulogic := '0'
  );

  port (
    Q1                   : out std_ulogic;
    Q2                   : out std_ulogic;
    C                    : in std_ulogic;
    CB                   : in std_ulogic;
    D                    : in std_ulogic;
    R                   : in std_ulogic    
  );
end IDDRE1;

architecture IDDRE1_V of IDDRE1 is
  
  constant MODULE_NAME : string := "IDDRE1";
  constant IN_DELAY : time := 0 ps;
  constant OUT_DELAY : time := 0 ps;
  constant INCLK_DELAY : time := 0 ps;
  constant OUTCLK_DELAY : time := 0 ps;

-- Parameter encodings and registers
  constant DDR_CLK_EDGE_OPPOSITE_EDGE : integer := 1;
  constant DDR_CLK_EDGE_SAME_EDGE : integer := 2;
  constant DDR_CLK_EDGE_SAME_EDGE_PIPELINED : integer := 3;

  signal DDR_CLK_EDGE_BIN : integer;

  signal glblGSR      : std_ulogic;
  
  signal attr_err     : std_ulogic := '0';
  
  signal Q1_out : std_ulogic;
  signal Q2_out : std_ulogic;
  
  signal Q1_delay : std_ulogic;
  signal Q2_delay : std_ulogic;
  
  signal CB_delay : std_ulogic;
  signal C_delay : std_ulogic;
  signal D_delay : std_ulogic;
  signal R_delay : std_ulogic;
  
  signal CB_in : std_ulogic;
  signal C_in : std_ulogic;
  signal D_in : std_ulogic;
  signal R_in : std_ulogic;

  signal Q1_o_reg	: std_ulogic := 'X';
  signal Q2_o_reg	: std_ulogic := 'X';
  signal Q3_o_reg	: std_ulogic := 'X';
  signal Q4_o_reg	: std_ulogic := 'X';
  
  begin
  glblGSR     <= TO_X01(GSR);
  Q1 <= Q1_delay after OUT_DELAY;
  Q2 <= Q2_delay after OUT_DELAY;
  
  Q1_delay <= Q1_out;
  Q2_delay <= Q2_out;
  
  CB_delay <= CB after INCLK_DELAY;
  C_delay <= C after INCLK_DELAY;
  
  D_delay <= D after IN_DELAY;
  R_delay <= R after IN_DELAY;
  
  CB_in <= CB_delay;
  C_in <= C_delay xor IS_C_INVERTED;
  D_in <= D_delay;
  R_in <= R_delay;
  
  DDR_CLK_EDGE_BIN <= 
    DDR_CLK_EDGE_OPPOSITE_EDGE when (DDR_CLK_EDGE = "OPPOSITE_EDGE") else
    DDR_CLK_EDGE_SAME_EDGE when (DDR_CLK_EDGE = "SAME_EDGE") else
    DDR_CLK_EDGE_SAME_EDGE_PIPELINED when (DDR_CLK_EDGE = "SAME_EDGE_PIPELINED") else
    DDR_CLK_EDGE_OPPOSITE_EDGE;

  
  INIPROC : process
  begin
-------- DDR_CLK_EDGE check
  -- case DDR_CLK_EDGE is
    if((DDR_CLK_EDGE = "OPPOSITE_EDGE") or (DDR_CLK_EDGE = "opposite_edge")) then
      null;
    elsif((DDR_CLK_EDGE = "SAME_EDGE") or (DDR_CLK_EDGE = "same_edge")) then
      null;
    elsif((DDR_CLK_EDGE = "SAME_EDGE_PIPELINED") or (DDR_CLK_EDGE = "same_edge_pipelined")) then
      null;
    else
      attr_err <= '1';
      assert FALSE report "Error : DDR_CLK_EDGE is not OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED." severity warning;
    end if;
  -- end case;
  if  (attr_err = '1') then
    assert FALSE
    report "Error : Attribute Error(s) encountered"
    severity error;
  end if;
  wait;
  end process INIPROC;

  PROC_C_CB : process(C_in, CB_in, D_in, glblGSR, R_in)
  begin
    if(glblGSR = '1') then
      q1_o_reg <= '0';
      q2_o_reg <= '0';
      q3_o_reg <= '0';
      q4_o_reg <= '0';
    elsif(glblGSR = '0') then
      if(R_in = '1') then
        q1_o_reg <= '0';
        q2_o_reg <= '0';
        q3_o_reg <= '0';
        q4_o_reg <= '0';
      elsif(R_in = '0' or R_in = 'L' or R_in = 'U') then
        if(rising_edge(C_in)) then
	  q3_o_reg <= q1_o_reg;
	  q1_o_reg <= D_in;
	  q4_o_reg <= q2_o_reg;
	end if;
	if(rising_edge(CB_in)) then
	  q2_o_reg <= D_in;
	end if;
      end if;
    end if;  
  end process PROC_C_CB;

  PROC_Q1_Q2_MUX: process(q1_o_reg,q2_o_reg,q3_o_reg,q4_o_reg)
  begin
    case DDR_CLK_EDGE_BIN is
      when 1 =>
                Q1_out <= q1_o_reg;
		Q2_out <= q2_o_reg;
      when 2 =>
                Q1_out <= q1_o_reg;
		Q2_out <= q4_o_reg;
      when 3 =>
      		Q1_out <= q3_o_reg;
		Q2_out <= q4_o_reg;
      when others =>
      		null;
     end case; 		
  end process PROC_Q1_Q2_MUX;
end IDDRE1_V;
