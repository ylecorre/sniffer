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
--  /   /                        Clock Buffer
-- /___/   /\      Filename    : BUFCE_ROW.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-------------------------------------------------------
--  Revision:
--  05/15/12 - Initial version.
--  10/17/12 - 682802 - convert GSR H/L to 1/0
--  End Revision:
-------------------------------------------------------

----- CELL BUFCE_ROW -----

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

  entity BUFCE_ROW is
    generic (
      CE_TYPE : string := "SYNC";
      IS_CE_INVERTED : std_ulogic := '0';
      IS_I_INVERTED : std_ulogic := '0'
    );

    port (
      O                    : out std_ulogic;
      CE                   : in std_ulogic;
      I                    : in std_ulogic      
    );
  end BUFCE_ROW;

  architecture BUFCE_ROW_V of BUFCE_ROW is
    
    constant MODULE_NAME : string := "BUFCE_ROW";
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    signal CE_TYPE_BINARY : std_ulogic;
    signal CE_TYPE_INV    : std_ulogic;

    signal glblGSR : std_ulogic;
    
    signal O_out : std_ulogic;
    
    signal O_delay : std_ulogic;
  
    signal CE_delay : std_ulogic;
    signal I_delay : std_ulogic;
    
    signal CE_in : std_ulogic;
    signal I_in : std_ulogic;

    signal ice : std_ulogic := 'X';
    signal enable_clk : std_ulogic := '0';
    signal ce_inv : std_ulogic := 'X';


  begin

    glblGSR     <= TO_X01(GSR);
    O           <= O_delay after OUT_DELAY;
   
    O_delay     <= O_out;
    
    I_delay     <= I after INCLK_DELAY;
    
    CE_delay    <= CE after IN_DELAY;
      
    CE_in                 <= not CE_delay when IS_CE_INVERTED = '1' else CE_delay;
    I_in                  <= not I_delay  when IS_I_INVERTED = '1' else I_delay;

   --####################################################################
   --#####                     Initialize                           #####
   --#################################################################### 

    prcs_init:process
    variable FIRST_TIME : boolean := true;

    begin
      if(FIRST_TIME) then

        if((CE_TYPE = "SYNC") or (CE_TYPE = "sync")) then
          CE_TYPE_BINARY <= '0';
        elsif((CE_TYPE = "ASYNC") or (CE_TYPE= "async")) then
          CE_TYPE_BINARY <= '1';
        else
          assert FALSE report "Error : CE_TYPE = is not SYNC, ASYNC." severity error;
        end if;

        FIRST_TIME := false;

      end if;
      wait;
    end process prcs_init;

    CE_TYPE_INV <= not CE_TYPE_BINARY;
    ce_inv <=  not CE_in;
    ice <= not (CE_TYPE_INV and I_in);

    prcs_1 : process(glblGSR, ice, ce_inv)
    begin
      if (glblGSR = '1') then
        enable_clk <= '1';
      elsif (ice = '1') then
        enable_clk <= not ce_inv;
      end if;  
    end process prcs_1;

    O_out <= enable_clk and I_in;

  end BUFCE_ROW_V;
