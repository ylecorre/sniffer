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
--  /   /                        Input Fixed or Variable Delay Element
-- /___/   /\      Filename    : IDELAYE3.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-------------------------------------------------------
--  Revision:
--
--  End Revision:
-------------------------------------------------------

----- CELL IDELAYE3 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library STD;
use STD.TEXTIO.all;
use IEEE.Std_Logic_TextIO.all;


library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity IDELAYE3 is
    generic (
      CASCADE : string := "NONE";
      DELAY_FORMAT : string := "TIME";
      DELAY_SRC : string := "IDATAIN";
      DELAY_TYPE : string := "FIXED";
      DELAY_VALUE : integer := 0;
      IS_CLK_INVERTED : std_ulogic := '0';
      IS_RST_INVERTED : std_ulogic := '0';
      REFCLK_FREQUENCY : real := 300.0;
      UPDATE_MODE : string := "ASYNC"
    );

    port (
      CASC_OUT             : out std_ulogic;
      CNTVALUEOUT          : out std_logic_vector(8 downto 0);
      DATAOUT              : out std_ulogic;
      CASC_IN              : in std_ulogic;
      CASC_RETURN          : in std_ulogic;
      CE                   : in std_ulogic;
      CLK                  : in std_ulogic;
      CNTVALUEIN           : in std_logic_vector(8 downto 0);
      DATAIN               : in std_ulogic;
      EN_VTC               : in std_ulogic;
      IDATAIN              : in std_ulogic;
      INC                  : in std_ulogic;
      LOAD                 : in std_ulogic;
      RST                  : in std_ulogic      
    );
  end IDELAYE3;

  architecture IDELAYE3_V of IDELAYE3 is
    
    constant MODULE_NAME : string := "IDELAYE3";
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;
    constant MAX_DELAY_COUNT	: integer := 511;
    constant MIN_DELAY_COUNT	: integer := 0;
    constant PER_BIT_FINE_DELAY	: integer := 5 ;
    constant PER_BIT_MEDIUM_DELAY	: integer := 40;
    constant INTRINSIC_FINE_DELAY	: time := 90 ps;
    constant INTRINSIC_MEDIUM_DELAY	: time := 40 ps;

    constant IDATAIN_INTRINSIC_DELAY : time := 30 ps;
    constant DATAIN_INTRINSIC_DELAY : time := 50 ps;
    constant CASC_IN_INTRINSIC_DELAY : time := 50 ps;
    --constant CASC_RET_INTRINSIC_DELAY = 50;
    constant CASC_RET_INTRINSIC_DELAY  : time := 0 ps;

    constant DATA_OUT_INTRINSIC_DELAY : time := 40 ps;
    constant CASC_OUT_INTRINSIC_DELAY : time := 40 ps;

    -- Convert bit_vector to std_logic_vector
    constant IS_CLK_INVERTED_BIN : std_ulogic := IS_CLK_INVERTED;
    constant IS_RST_INVERTED_BIN : std_ulogic := IS_RST_INVERTED;
    
    constant CASCADE_MASTER : integer := 1;
    constant CASCADE_NONE : integer := 0;
    constant CASCADE_SLAVE_END : integer := 2;
    constant CASCADE_SLAVE_MIDDLE : integer := 3;
    constant DELAY_FORMAT_COUNT : integer := 1;
    constant DELAY_FORMAT_TIME : integer := 0;
    constant DELAY_SRC_DATAIN : integer := 1;
    constant DELAY_SRC_IDATAIN : integer := 0;
    constant DELAY_TYPE_FIXED : integer := 0;
    constant DELAY_TYPE_VARIABLE : integer := 1;
    constant DELAY_TYPE_VAR_LOAD : integer := 2;
    constant DELAY_VALUE_0 : integer := 0;
    constant UPDATE_MODE_ASYNC : integer := 0;
    constant UPDATE_MODE_MANUAL : integer := 1;
    constant UPDATE_MODE_SYNC : integer := 2;

    signal CASCADE_BIN : integer;
    signal DELAY_FORMAT_BIN : integer;
    signal DELAY_SRC_BIN : integer;
    signal DELAY_TYPE_BIN : integer;
    signal DELAY_VALUE_BIN : integer;
    signal REFCLK_FREQUENCY_BIN : integer;
    signal UPDATE_MODE_BIN : integer;
    
    signal glblGSR : std_ulogic;
    
    signal CASC_OUT_out : std_ulogic;
    signal CNTVALUEOUT_out : std_logic_vector(8 downto 0);
    signal DATAOUT_out : std_ulogic;
    
    signal CASC_OUT_delay : std_ulogic;
    signal CNTVALUEOUT_delay : std_logic_vector(8 downto 0);
    signal DATAOUT_delay : std_ulogic;
    
    signal CASC_IN_delay : std_ulogic;
    signal CASC_RETURN_delay : std_ulogic;
    signal CE_delay : std_ulogic;
    signal CLK_delay : std_ulogic;
    signal CNTVALUEIN_delay : std_logic_vector(8 downto 0);
    signal DATAIN_delay : std_ulogic;
    signal EN_VTC_delay : std_ulogic;
    signal IDATAIN_delay : std_ulogic;
    signal INC_delay : std_ulogic;
    signal LOAD_delay : std_ulogic;
    signal RST_delay : std_ulogic;
    
    signal CASC_IN_in : std_ulogic;
    signal CASC_RETURN_in : std_ulogic;
    signal CE_in : std_ulogic;
    signal CLK_in : std_ulogic;
    signal CNTVALUEIN_in : std_logic_vector(8 downto 0);
    signal DATAIN_in : std_ulogic;
    signal EN_VTC_in : std_ulogic;
    signal IDATAIN_in : std_ulogic;
    signal INC_in : std_ulogic;
    signal LOAD_in : std_ulogic;
    signal RST_in : std_ulogic;

------------------------------------------------
-- function Idelaye3_DelayCount
------------------------------------------------

   function Idelaye3_DelayCount(
                   DelayType  : in string;
                   DelayValue : in integer;
                   CounterVal : in  std_logic_vector(8 downto 0)
   ) return integer is

  begin
       if((DelayType = "FIXED") OR (DelayType = "VARIABLE")) then  
           return integer(real(DelayValue)/2.446);
       elsif(DelayType = "VAR_LOAD") then
           return SLV_TO_INT(CounterVal); 
       else return 0;
       end if;
  end;   
------------------------------------------------
-- function Idelaye3_InitDelayCount
------------------------------------------------

   function Idelaye3_InitDelayCount(
                   DelayFormat  : in string;
                   DelayValue : in integer
   ) return integer is

  begin
       if(DelayFormat = "TIME") then 
           return integer(real(DelayValue)/2.446);
       else return integer(DelayValue);
       end if;
  end;     

-------------- variable declaration -------------------------
    signal	delay_value_calc        : time := 1 ps;
    signal	delay_value_calc_format       : time := 1 ps;
    signal	cascade_mode_delay    : integer := 2;
    signal	delay_value_casc_out  : time := 1 ps;
    signal	delay_value_casc_out_format  : time := 1 ps;
    signal	delay_value_data_out  : time := 1 ps;
    signal	idelay_count_pre       : integer := Idelaye3_InitDelayCount(DELAY_FORMAT,DELAY_VALUE);
    signal	idelay_count_sync       : integer := Idelaye3_InitDelayCount(DELAY_FORMAT,DELAY_VALUE);
    signal	idelay_count_async       : integer := Idelaye3_InitDelayCount(DELAY_FORMAT,DELAY_VALUE);
    signal	cntvalue_updated       : real := real(Idelaye3_InitDelayCount(DELAY_FORMAT,DELAY_VALUE));
    signal	cntvalue_updated_sync       : real := real(Idelaye3_InitDelayCount(DELAY_FORMAT,DELAY_VALUE));
    signal	cntvalue_updated_async       : real := real(Idelaye3_InitDelayCount(DELAY_FORMAT,DELAY_VALUE));
    signal	CNTVALUEIN_INTEGER : integer := 0;
    signal	cntvalueout_pre	   : std_logic_vector(8 downto 0);
    signal	tap_out		   : std_ulogic := 'X';
    signal	tap_out_casc_out_none		   : std_ulogic := 'X';
    signal	tap_out_casc_out		   : std_ulogic := 'X';
    signal	tap_out_data_out		   : std_ulogic := 'X';

    signal	data_mux	: std_ulogic := 'X';
    signal      clk_smux        : std_ulogic := 'X';
    signal      RST_sync1        : std_ulogic := 'X'; 
    signal      RST_sync2        : std_ulogic := 'X'; 
    signal      RST_sync3        : std_ulogic := 'X'; 
    begin
    glblGSR     <= TO_X01(GSR);
--    CASC_OUT <= CASC_OUT_delay after OUT_DELAY;
--    CNTVALUEOUT <= CNTVALUEOUT_delay after OUT_DELAY;
--    DATAOUT <= DATAOUT_delay after OUT_DELAY;
    
--    CASC_OUT_delay <= CASC_OUT_out;
--    CNTVALUEOUT_delay <= CNTVALUEOUT_out;
--    DATAOUT_delay <= DATAOUT_out;
    
    CLK_delay <= CLK after INCLK_DELAY;
    
    CASC_IN_delay <= CASC_IN after IN_DELAY;
    CASC_RETURN_delay <= CASC_RETURN after IN_DELAY;
    CE_delay <= CE after IN_DELAY;
    CNTVALUEIN_delay <= CNTVALUEIN after IN_DELAY;
    DATAIN_delay <= DATAIN after IN_DELAY;
    EN_VTC_delay <= EN_VTC after IN_DELAY;
    IDATAIN_delay <= IDATAIN after IN_DELAY;
    INC_delay <= INC after IN_DELAY;
    LOAD_delay <= LOAD after IN_DELAY;
    RST_delay <= RST after IN_DELAY;
    
    CASC_IN_in <= CASC_IN_delay;
    CASC_RETURN_in <= CASC_RETURN_delay;
    CE_in <= CE_delay;
    CLK_in <= not CLK_delay when IS_CLK_INVERTED = '1' else CLK_delay;
    CNTVALUEIN_in <= CNTVALUEIN_delay;
    DATAIN_in <= DATAIN_delay;
    EN_VTC_in <= EN_VTC_delay;
    IDATAIN_in <= IDATAIN_delay;
    INC_in <= INC_delay;
    LOAD_in <= LOAD_delay;
    RST_in <= not RST_delay when IS_RST_INVERTED = '1' else RST_delay;
    
    
    INIPROC : process
    begin
    -- case CASCADE is
      if((CASCADE = "NONE") or (CASCADE = "none")) then
        CASCADE_BIN <= CASCADE_NONE;
      elsif((CASCADE = "MASTER") or (CASCADE = "master")) then
        CASCADE_BIN <= CASCADE_MASTER;
      elsif((CASCADE = "SLAVE_END") or (CASCADE = "slave_end")) then
        CASCADE_BIN <= CASCADE_SLAVE_END;
      elsif((CASCADE = "SLAVE_MIDDLE") or (CASCADE = "slave_middle")) then
        CASCADE_BIN <= CASCADE_SLAVE_MIDDLE;
      else
        assert FALSE report "Error : CASCADE = is not NONE, MASTER, SLAVE_END, SLAVE_MIDDLE." severity error;
      end if;
    -- end case;
    -- case DELAY_FORMAT is
      if((DELAY_FORMAT = "TIME") or (DELAY_FORMAT = "time")) then
        DELAY_FORMAT_BIN <= DELAY_FORMAT_TIME;
      elsif((DELAY_FORMAT = "COUNT") or (DELAY_FORMAT = "count")) then
        DELAY_FORMAT_BIN <= DELAY_FORMAT_COUNT;
      else
        assert FALSE report "Error : DELAY_FORMAT = is not TIME, COUNT." severity error;
      end if;
    -- end case;
    -- case DELAY_SRC is
      if((DELAY_SRC = "IDATAIN") or (DELAY_SRC = "idatain")) then
        DELAY_SRC_BIN <= DELAY_SRC_IDATAIN;
      elsif((DELAY_SRC = "DATAIN") or (DELAY_SRC = "datain")) then
        DELAY_SRC_BIN <= DELAY_SRC_DATAIN;
      else
        assert FALSE report "Error : DELAY_SRC = is not IDATAIN, DATAIN." severity error;
      end if;
    -- end case;
    -- case DELAY_TYPE is
      if((DELAY_TYPE = "FIXED") or (DELAY_TYPE = "fixed")) then
        DELAY_TYPE_BIN <= DELAY_TYPE_FIXED;
      elsif((DELAY_TYPE = "VARIABLE") or (DELAY_TYPE = "variable")) then
        DELAY_TYPE_BIN <= DELAY_TYPE_VARIABLE;
      elsif((DELAY_TYPE = "VAR_LOAD") or (DELAY_TYPE = "var_load")) then
        DELAY_TYPE_BIN <= DELAY_TYPE_VAR_LOAD;
      else
        assert FALSE report "Error : DELAY_TYPE = is not FIXED, VARIABLE, VAR_LOAD." severity error;
      end if;
    -- end case;
    -- case UPDATE_MODE is
      if((UPDATE_MODE = "ASYNC") or (UPDATE_MODE = "async")) then
        UPDATE_MODE_BIN <= UPDATE_MODE_ASYNC;
      elsif((UPDATE_MODE = "MANUAL") or (UPDATE_MODE = "manual")) then
        UPDATE_MODE_BIN <= UPDATE_MODE_MANUAL;
      elsif((UPDATE_MODE = "SYNC") or (UPDATE_MODE = "sync")) then
        UPDATE_MODE_BIN <= UPDATE_MODE_SYNC;
      else
        assert FALSE report "Error : UPDATE_MODE = is not ASYNC, MANUAL, SYNC." severity error;
      end if;
    -- end case;
      if ((DELAY_VALUE >= 0) and (DELAY_VALUE <= 1250)) then
          DELAY_VALUE_BIN <= DELAY_VALUE;
      else  assert FALSE report "Error : DELAY_VALUE is not in range 0 .. 1250." severity error;
      end if;
    if ((REFCLK_FREQUENCY >= 300.0) and (REFCLK_FREQUENCY <= 1333.0)) then
      REFCLK_FREQUENCY_BIN <= integer(REFCLK_FREQUENCY);
    else
      assert FALSE report "Error : REFCLK_FREQUENCY is not in range 300.0 .. 1333.0." severity error;
    end if;
    wait;
    end process INIPROC;

--####################################################################
--#####                       cntvalueout                        #####
--####################################################################
  prcs_cntvalueout:process(idelay_count_sync, idelay_count_async,cntvalue_updated_sync,cntvalue_updated_async)
  begin
    if(UPDATE_MODE = "SYNC") then
      cntvalueout_pre <= CONV_STD_LOGIC_VECTOR(idelay_count_sync, 9);
      cntvalue_updated <= cntvalue_updated_sync;
    else
      cntvalueout_pre <= CONV_STD_LOGIC_VECTOR(idelay_count_async, 9);
      cntvalue_updated <= cntvalue_updated_async;
    end if;
  end process prcs_cntvalueout;

--####################################################################
--#####                       clk_smux                        #####
--####################################################################  
  prcs_clk_smux: process(CLK_in,RST_in, RST_sync1, RST_sync2, RST_sync3)
  begin
	  if(RST_in = '1' or RST_sync1 = '1' or RST_sync2 = '1' or RST_sync3 = '1') then
		  clk_smux <= '0';
	  elsif(RST_sync3 = '0') then
	          clk_smux <= CLK_in;
	  end if;
  end process prcs_clk_smux;
--####################################################################
--#####                       RST_sync                        #####
--####################################################################  
  prcs_RST_sync: process(CLK_in)
  begin
	  if(rising_edge(CLK_in)) then
		  RST_sync1 <= RST_in;
		  RST_sync2 <= RST_sync1;
		  RST_sync3 <= RST_sync2;
	  end if;
  end process prcs_RST_sync;
--####################################################################
--#####                  CALCULATE iDelay                        #####
--####################################################################
  prcs_calc_idelay:process(CLK_in,clk_smux, glblGSR, RST_in,RST_sync1,RST_sync2, RST_sync3)
  variable idelay_count_var : integer := 0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  variable bcat : std_logic_vector(2 downto 0);
  variable  Message : line;
  begin
-- CR 595286
       bcat := LOAD_in & CE_in & INC_in;	  
       if((glblGSR = '1') or (FIRST_TIME) or (RST_in = '1'))then
          idelay_count_async <= idelay_count_pre;
          FIRST_TIME   := false;
       elsif(glblGSR = '0') then
             if (RST_in = '1' or RST_sync1 = '1' or RST_sync2 = '1' or RST_sync3 = '1') then
                 idelay_count_async <= idelay_count_pre;
	     elsif(RST_sync3 = '0') then
                 if(rising_edge(clk_smux)) then
		     case DELAY_TYPE_BIN is
			     when 0 => null; 
			     when 2 =>
				     case bcat is
				       when "000" => null;
				       when "001" => null;
				       when "010" =>
					       if (idelay_count_async > MAX_DELAY_COUNT) then
					         idelay_count_async <= idelay_count_async - 1;
					       elsif (idelay_count_async = MIN_DELAY_COUNT) then
					         idelay_count_async <= MAX_DELAY_COUNT;
                                               end if;
					       if(UPDATE_MODE /= "MANUAL") then
						 cntvalue_updated_async <= real(idelay_count_async);
					       end if;	 
				       when "011" =>
					       if (idelay_count_async < MAX_DELAY_COUNT) then
					         idelay_count_async <= idelay_count_async + 1;
					       elsif (idelay_count_async = MAX_DELAY_COUNT) then
					         idelay_count_async <= MIN_DELAY_COUNT;
              				       end if;
					       if(UPDATE_MODE /= "MANUAL") then
						 cntvalue_updated_async <= real(idelay_count_async);
              				       end if;
				       when "100"|"101" =>
					       idelay_count_async <= SLV_TO_INT(CNTVALUEIN_in);
					       if (UPDATE_MODE /= "MANUAL") then
					         cntvalue_updated_async <= real(idelay_count_async);
              				       end if;
				       when "110" =>
					       if (UPDATE_MODE /= "MANUAL") then
         				         assert false
						 report "FAILURE: Invalid scenario. LOAD = 1, CE = 1 INC = 0 is valid only for UPDATE_MODE = MANUAL and DELAY_TYPE = VAR_LOAD"
       						 severity Warning;
					       else
					         cntvalue_updated_async <= real(idelay_count_async);
              				       end if;
         			       when "111" =>
					       if (UPDATE_MODE /= "MANUAL") then
         				         assert false
						 report "FAILURE: Invalid scenario. LOAD = 1, CE = 1 INC = 1 is valid only for UPDATE_MODE = MANUAL and DELAY_TYPE = VAR_LOAD"
       						 severity Warning;
					       else
					         idelay_count_async <= idelay_count_async + SLV_TO_INT(CNTVALUEIN_in);
              				       end if;
				       when others =>  Write ( Message, string'("Invalid Scenario LOAD  = "));
				                       Write (Message, LOAD_in);
						       Write (Message, string'(" CE = "));
						       Write (Message, CE_in);
						       Write (Message, string'(" INC = "));
						       Write (Message, INC_in);
						       Write ( Message, string'(" are invalid for DELAY_TYPE = VAR_LOAD "));
				                      assert false
				                      report Message.all
       						      severity Warning;
						      DEALLOCATE (Message);
				     end case; 
			     when 1 =>
				     case bcat is
				       when "000" => null;
				       when "001" => null;
				       when "010" =>
					       if (idelay_count_async > MAX_DELAY_COUNT) then
					         idelay_count_async <= idelay_count_async - 1;
					       elsif (idelay_count_async = MIN_DELAY_COUNT) then
					         idelay_count_async <= MAX_DELAY_COUNT;
                                               end if;
						 cntvalue_updated_async <= real(idelay_count_async);
				       when "011" =>
					       if (idelay_count_async < MAX_DELAY_COUNT) then
					         idelay_count_async <= idelay_count_async + 1;
					       elsif (idelay_count_async = MAX_DELAY_COUNT) then
					         idelay_count_async <= MIN_DELAY_COUNT;
              				       end if;
						 cntvalue_updated_async <= real(idelay_count_async);
				       when others =>  Write ( Message, string'("Invalid Scenario LOAD = "));
				                       Write (Message, LOAD_in);
						       Write (Message, string'(" CE = "));
						       Write (Message, CE_in);
						       Write (Message, string'(" INC = "));
						       Write (Message, INC_in);
						        Write ( Message, string'(" are invalid for DELAY_TYPE = VARIABLE "));
							assert false
				                      report Message.all 
       						      severity Warning;
						      DEALLOCATE (Message);
				     end case;
			     when others => assert false	     
         				    report "Attribute Syntax Error : Legal values for DELAY_TYPE on IDELAYE3 instance are FIXED or VAR_LOAD or VARIABLE."
         				    severity Failure;
		     end case;
             end if; -- CLK_in
          end if; -- RST_in
       end if; -- glblGSR
  end process prcs_calc_idelay;

  prcs_calc_idelay_sync:process(data_mux, glblGSR, RST_in, RST_sync1, RST_sync2, RST_sync3)
  variable idelay_count_var : integer := 0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  variable bcat : std_logic_vector(2 downto 0);
  variable  Message : line;
  begin
-- CR 595286
       bcat := LOAD_in & CE_in & INC_in;
       if((glblGSR = '1') or (FIRST_TIME) or (RST_in = '1'))then
          idelay_count_sync <= idelay_count_pre;
          FIRST_TIME   := false;
       elsif(glblGSR = '0') then
          if (RST_in = '1' or RST_sync1 = '1' or RST_sync2 = '1' or RST_sync3 = '1') then
                 idelay_count_sync <= idelay_count_pre;
	  elsif (RST_sync3 = '0') then
              if(rising_edge(data_mux)) then
		     if (UPDATE_MODE = "SYNC") then
		     case DELAY_TYPE_BIN is
			     when 2 =>
				     case bcat is
				       when "000" => null;
				       when "001" => null;
				       when "010" =>
					       if (idelay_count_sync > MAX_DELAY_COUNT) then
					         idelay_count_sync <= idelay_count_sync - 1;
					       elsif (idelay_count_sync = MIN_DELAY_COUNT) then
					         idelay_count_sync <= MAX_DELAY_COUNT;
                                               end if;
					       if(UPDATE_MODE /= "MANUAL") then
						 cntvalue_updated_sync <= real(idelay_count_sync);
					       end if;	 
				       when "011" =>
					       if (idelay_count_sync < MAX_DELAY_COUNT) then
					         idelay_count_sync <= idelay_count_sync + 1;
					       elsif (idelay_count_sync = MAX_DELAY_COUNT) then
					         idelay_count_sync <= MIN_DELAY_COUNT;
              				       end if;
					       if(UPDATE_MODE /= "MANUAL") then
						 cntvalue_updated_sync <= real(idelay_count_sync);
              				       end if;
				       when "100"|"101" =>
					       idelay_count_sync <= SLV_TO_INT(CNTVALUEIN_in);
					       if (UPDATE_MODE /= "MANUAL") then
					         cntvalue_updated_sync <= real(idelay_count_sync);
              				       end if;
				       when "110" =>
					       if (UPDATE_MODE /= "MANUAL") then
         				         assert false
						 report "FAILURE: Invalid scenario. LOAD = 1, CE = 1 INC = 0 is valid only for UPDATE_MODE = MANUAL and DELAY_TYPE = VAR_LOAD"
       						 severity Warning;
					       else
					         cntvalue_updated_sync <= real(idelay_count_sync);
              				       end if;
         			       when "111" =>
					       if (UPDATE_MODE /= "MANUAL") then
         				         assert false
						 report "FAILURE: Invalid scenario. LOAD = 1, CE = 1 INC = 1 is valid only for UPDATE_MODE = MANUAL and DELAY_TYPE = VAR_LOAD"
       						 severity Warning;
					       else
					         idelay_count_sync <= idelay_count_sync + SLV_TO_INT(CNTVALUEIN_in);
              				       end if;
				       when others =>  Write ( Message, string'("Invalid Scenario LOAD = "));
						       Write (Message, LOAD_in);
						       Write (Message, string'(" CE = "));
						       Write (Message, CE_in);
						       Write (Message, string'(" INC = "));
						       Write (Message, INC_in);
						       Write ( Message, string'(" are invalid for DELAY_TYPE = VAR_LOAD and UPDATE_MODE= SYNC"));
						       Writeline (output, Message);
				                       assert false
				                       report Message.all
       						       severity Warning;
						       DEALLOCATE (Message);
				     end case; 
			     when others => assert false	     
			     		    report "Attribute Syntax Error : UPDATE_MODE= SYNC is valid only for DELAY_TYPE=VAR_LOAD."
         				    severity Failure;
		     end case;
             end if; -- UPDATE_MODE
             end if; -- CLK_in
          end if; -- RST_in
       end if; -- glblGSR
  end process prcs_calc_idelay_sync;
  
--####################################################################
--#####                      SELECT IDATA_MUX                    #####
--####################################################################
  prcs_data_mux:process(DATAIN_in, IDATAIN_in, CASC_IN_in)
  begin
      if((CASCADE = "MASTER") or (CASCADE = "NONE")) then	  
      	if(DELAY_SRC = "IDATAIN") then 
            data_mux <= IDATAIN_in;
      	elsif(DELAY_SRC = "DATAIN") then
            data_mux <= DATAIN_in;
      	else
         assert false
         report "Attribute Syntax Error : Legal values for DELAY_SRC on IDELAYE3 instance are DATAIN or IDATAIN."
         severity Failure;
      	end if; --DELAY_SRC
      elsif((CASCADE = "SLAVE_END") or (CASCADE = "SLAVE_MIDDLE")) then
         data_mux <= CASC_IN_in;
      else
       assert false
       report "Attribute Syntax Error : Legal values for CASCADE on IDELAYE3 instance are NONE or MASTER or SLAVE_END or SLAVE_MIDDLE."
       severity Failure;
       end if; --CASCADE 	       
  end process prcs_data_mux;   

--####################################################################
--#####                      CALC DELAY                       #####
--####################################################################
  prcs_DelayData:process(cntvalue_updated, data_mux, CASC_RETURN_in)
  variable cntvalue : std_logic_vector(8 downto 0);
  variable cntvalue_lower_nibble : integer;
  variable cntvalue_upper_nibble : integer;
  begin
	  cntvalue := CONV_STD_LOGIC_VECTOR(integer(cntvalue_updated), 9);
	  cntvalue_lower_nibble := SLV_TO_INT(cntvalue(2 downto 0));
	  cntvalue_upper_nibble := SLV_TO_INT(cntvalue(8 downto 3));
	  if (DELAY_FORMAT = "TIME") then
            delay_value_calc_format <= ((cntvalue_updated * 2.446)* 1 ps) + INTRINSIC_FINE_DELAY + INTRINSIC_MEDIUM_DELAY;
	    cascade_mode_delay <=  integer(cntvalue_updated * 2.446);
            delay_value_casc_out_format <= (cascade_mode_delay/2)* 1 ps + INTRINSIC_FINE_DELAY + INTRINSIC_MEDIUM_DELAY ;
	    if (integer(cascade_mode_delay) rem 2 = 1) then 
      		delay_value_data_out <= ((cascade_mode_delay / 2) + 1) * 1 ps;
	    else 	
      		delay_value_data_out <= (cascade_mode_delay / 2) * 1 ps;	
	    end if;
	  else
            delay_value_calc_format <= ((cntvalue_lower_nibble * PER_BIT_FINE_DELAY)* 1 ps) + (cntvalue_upper_nibble * PER_BIT_MEDIUM_DELAY * 1 ps) + INTRINSIC_FINE_DELAY + INTRINSIC_MEDIUM_DELAY;
            cascade_mode_delay <=  integer((cntvalue_lower_nibble * PER_BIT_FINE_DELAY) + (cntvalue_upper_nibble * PER_BIT_MEDIUM_DELAY));
            delay_value_casc_out_format <= (((cntvalue_lower_nibble * PER_BIT_FINE_DELAY)+(cntvalue_upper_nibble * PER_BIT_MEDIUM_DELAY)) / 2)*1 ps + INTRINSIC_FINE_DELAY + INTRINSIC_MEDIUM_DELAY;
	    if (integer(cascade_mode_delay) rem 2 = 1) then 
      		delay_value_data_out <= ((((cntvalue_lower_nibble * PER_BIT_FINE_DELAY)+(cntvalue_upper_nibble * PER_BIT_MEDIUM_DELAY)) / 2) + 1) * 1 ps;
            else 	
      		delay_value_data_out <= (((cntvalue_lower_nibble * PER_BIT_FINE_DELAY)+(cntvalue_upper_nibble * PER_BIT_MEDIUM_DELAY)) / 2) * 1 ps;		  
	    end if;
	  end if;

	if((CASCADE = "MASTER") or (CASCADE = "NONE")) then	  
      		if(DELAY_SRC = "IDATAIN") then 
            		delay_value_calc <= delay_value_calc_format + IDATAIN_INTRINSIC_DELAY;
			delay_value_casc_out <= delay_value_casc_out_format + IDATAIN_INTRINSIC_DELAY;
      		elsif(DELAY_SRC = "DATAIN") then
            		delay_value_calc <= delay_value_calc_format + DATAIN_INTRINSIC_DELAY;
			delay_value_casc_out <= delay_value_casc_out_format + DATAIN_INTRINSIC_DELAY;
      		else
         		assert false
         		report "Attribute Syntax Error : Legal values for DELAY_SRC on IDELAYE3 instance are DATAIN or IDATAIN."
         		severity Failure;
      		end if; --DELAY_SRC
        elsif((CASCADE = "SLAVE_END") or (CASCADE = "SLAVE_MIDDLE")) then
            		delay_value_calc <= delay_value_calc_format + CASC_IN_INTRINSIC_DELAY;
			delay_value_casc_out <= delay_value_casc_out_format + CASC_IN_INTRINSIC_DELAY;
        else
       		assert false
       		report "Attribute Syntax Error : Legal values for CASCADE on IDELAYE3 instance are NONE or MASTER or SLAVE_END or SLAVE_MIDDLE."
       		severity Failure;
        end if; --CASCADE 	       

	  tap_out <= transport data_mux after delay_value_calc;
	  if (cntvalue_upper_nibble >= 31 ) then
         	tap_out_casc_out_none <= transport data_mux after delay_value_casc_out;
          else 
         	tap_out_casc_out_none <= '0';
          end if;
	  if (cntvalue_upper_nibble = 63 ) then
        	tap_out_data_out <= transport not CASC_RETURN_in after delay_value_data_out;
        	tap_out_casc_out <= transport not data_mux after delay_value_casc_out;
      	  else 
        	tap_out_data_out <= transport data_mux after delay_value_calc ;
		tap_out_casc_out <= '1';
          end if;
  end process prcs_DelayData;


--####################################################################
--#####                      OUTPUT  TAP                         #####
--####################################################################

    CNTVALUEOUT_out <= cntvalueout_pre;

  prcs_tapout:process(tap_out, tap_out_data_out,  tap_out_casc_out,  tap_out_casc_out_none)
  begin
      if((CASCADE = "NONE") or (CASCADE = "SLAVE_END")) then	  
        DATAOUT_out <= transport tap_out after DATA_OUT_INTRINSIC_DELAY;
	CASC_OUT_out <= transport tap_out_casc_out_none after CASC_OUT_INTRINSIC_DELAY;
      elsif((CASCADE = "MASTER") or (CASCADE = "SLAVE_MIDDLE")) then
        DATAOUT_out <= transport tap_out_data_out after DATA_OUT_INTRINSIC_DELAY;
	CASC_OUT_out <= transport tap_out_casc_out after CASC_OUT_INTRINSIC_DELAY;
      else
       assert false
       report "Attribute Syntax Error : Legal values for CASCADE on IDELAYE3 instance are NONE or MASTER or SLAVE_END or SLAVE_MIDDLE."
       severity Failure;
       end if; --CASCADE 
  end process prcs_tapout;

--####################################################################
--#####                           OUTPUT                         #####
--####################################################################
  prcs_output:process(DATAOUT_out, CNTVALUEOUT_out, CASC_OUT_out)
  begin
      CNTVALUEOUT    <= CNTVALUEOUT_out;
      DATAOUT        <= DATAOUT_out;
      CASC_OUT       <= CASC_OUT_out;
  end process prcs_output;  
  end IDELAYE3_V;
