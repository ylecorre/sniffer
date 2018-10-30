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
-- /___/   /\      Filename    : BUFGCE_DIV.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-------------------------------------------------------
--  Revision:
--  05/15/12 - Initial version.
--  10/17/12 - 682802 - convert GSR H/L to 1/0
--  02/28/13 - Update BUFGCE_DIV attribute
--  06/20/13 - 723918 - Add latch on CE to match HW
--  End Revision:
-------------------------------------------------------

----- CELL BUFGCE_DIV -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity BUFGCE_DIV is
    generic (
      BUFGCE_DIVIDE : integer := 1;
      IS_CE_INVERTED : std_ulogic := '0';
      IS_CLR_INVERTED : std_ulogic := '0';
      IS_I_INVERTED : std_ulogic := '0'
    );

    port (
      O                    : out std_ulogic;
      CE                   : in std_ulogic;
      CLR                  : in std_ulogic;
      I                    : in std_ulogic      
    );
  end BUFGCE_DIV;

  architecture BUFGCE_DIV_V of BUFGCE_DIV is
    
    constant MODULE_NAME : string := "BUFGCE_DIV";
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    signal glblGSR : std_ulogic;
    
    signal O_out : std_ulogic;
    
    signal O_delay : std_ulogic;
    
    signal CE_delay : std_ulogic;
    signal CLR_delay : std_ulogic;
    signal I_delay : std_ulogic;
    
    signal CE_in : std_ulogic;
    signal CLR_in : std_ulogic;
    signal I_in : std_ulogic;

    signal ce_en	        : std_ulogic := '0';
    signal i_ce	        : std_ulogic := '0';

    signal divide   	: boolean    := false;
    signal FIRST_TOGGLE_COUNT     : integer    := -1;
    signal SECOND_TOGGLE_COUNT    : integer    := -1;
    
    begin
    glblGSR     <= TO_X01(GSR);
    O <= O_delay after OUT_DELAY;
    
    I_delay <= I after INCLK_DELAY;
    
    CE_delay <= CE after IN_DELAY;
    CLR_delay <= CLR after IN_DELAY;
    

    CE_in <= not CE_delay when IS_CE_INVERTED = '1' else CE_delay;
    CLR_in <= not CLR_delay when IS_CLR_INVERTED = '1' else CLR_delay;
    I_in <= not I_delay when IS_I_INVERTED = '1' else I_delay;


  --####################################################################
  --#####                     Initialize                           #####
  --####################################################################

    prcs_init:process
    variable FIRST_TOGGLE_COUNT_var  : integer    := -1;
    variable SECOND_TOGGLE_COUNT_var : integer    := -1;
    variable divide_var  	   : boolean    := false;

    begin
      if(BUFGCE_DIVIDE = 1) then
         divide_var    := false;
         FIRST_TOGGLE_COUNT_var  := 1;
         SECOND_TOGGLE_COUNT_var := 1;
      elsif(BUFGCE_DIVIDE = 2) then
         divide_var    := true;
         FIRST_TOGGLE_COUNT_var  := 2;
         SECOND_TOGGLE_COUNT_var := 2;
      elsif(BUFGCE_DIVIDE = 3) then
         divide_var    := true;
         FIRST_TOGGLE_COUNT_var  := 2;
         SECOND_TOGGLE_COUNT_var := 4;
      elsif(BUFGCE_DIVIDE = 4) then
         divide_var    := true;
         FIRST_TOGGLE_COUNT_var  := 4;
         SECOND_TOGGLE_COUNT_var := 4;
      elsif(BUFGCE_DIVIDE = 5) then
         divide_var    := true;
         FIRST_TOGGLE_COUNT_var  := 4;
         SECOND_TOGGLE_COUNT_var := 6;
      elsif(BUFGCE_DIVIDE = 6) then
         divide_var    := true;
         FIRST_TOGGLE_COUNT_var  := 6;
         SECOND_TOGGLE_COUNT_var := 6;
      elsif(BUFGCE_DIVIDE = 7) then
         divide_var    := true;
         FIRST_TOGGLE_COUNT_var  := 6;
         SECOND_TOGGLE_COUNT_var := 8;
      elsif(BUFGCE_DIVIDE = 8) then
         divide_var    := true;
         FIRST_TOGGLE_COUNT_var  := 8;
         SECOND_TOGGLE_COUNT_var := 8;
      else
        assert FALSE report "Error : BUFGCE_DIVIDE is not in range 1 .. 8." severity error;
      end if;

      FIRST_TOGGLE_COUNT  <= FIRST_TOGGLE_COUNT_var; 
      SECOND_TOGGLE_COUNT <= SECOND_TOGGLE_COUNT_var; 

      divide    <= divide_var;

     wait;
    end process prcs_init;

    prcs_lce : process(glblGSR, CLR_in, I_in, CE_in)
    begin
      if (glblGSR = '1' or CLR_in = '1') then
        ce_en <= '0';
      elsif (I_in = '0') then
        ce_en <= CE_in;
    end if;
    end process prcs_lce;

    i_ce  <= I_in and ce_en;

  --####################################################################
  --#####                       CLK-I                              #####
  --####################################################################

    prcs_I:process(i_ce, glblGSR, CLR_in)
    variable clk_count          : integer := 0;
    variable toggle_count       : integer := 0;
    variable first_half_period  : boolean := true;
    variable FIRST_RISE         : boolean := true;
    begin
      if(divide) then
          if((glblGSR = '1') or (CLR_in = '1')) then
            O_out       <= '0';
            clk_count  := 1;
            first_half_period  := true;
            FIRST_RISE := true;
          elsif((glblGSR = '0') and (CLR_in = '0')) then
              if((i_ce='1') and (FIRST_RISE)) then
                    O_out <= '1';
                    clk_count  := 1;
                    first_half_period        := true;
                    toggle_count := FIRST_TOGGLE_COUNT;
                    FIRST_RISE := false;
              elsif ((i_ce'event) and ( FIRST_RISE = false)) then
                    if(clk_count = toggle_count) then
                       O_out <= not O_out;
                       clk_count := 1;
                       if(first_half_period = false) then
                         toggle_count := FIRST_TOGGLE_COUNT;
                       else
                         toggle_count := SECOND_TOGGLE_COUNT;
                       end if;
                       first_half_period := not first_half_period;
                    else
                       clk_count := clk_count + 1;
                    end if;
             end if;
          end if;
       else
          O_out <= i_ce;
       end if;
    end process prcs_I;

  --####################################################################
  --#####                         OUTPUT                           #####
  --####################################################################
  --####################################################################
    O_delay <= O_out;


end BUFGCE_DIV_V;

