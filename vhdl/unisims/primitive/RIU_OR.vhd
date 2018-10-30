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
-- /___/   /\      Filename    : RIU_OR.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-------------------------------------------------------
--  Revision:
--
--  End Revision:
-------------------------------------------------------

----- CELL RIU_OR -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity RIU_OR is
    port (
      RIU_RD_DATA          : out std_logic_vector(15 downto 0);
      RIU_RD_VALID         : out std_ulogic;
      RIU_RD_DATA_LOW      : in std_logic_vector(15 downto 0);
      RIU_RD_DATA_UPP      : in std_logic_vector(15 downto 0);
      RIU_RD_VALID_LOW     : in std_ulogic;
      RIU_RD_VALID_UPP     : in std_ulogic      
    );
  end RIU_OR;

  architecture RIU_OR_V of RIU_OR is
    
    constant MODULE_NAME : string := "RIU_OR";
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;


    signal glblGSR : std_ulogic;
    
    signal RIU_RD_DATA_out : std_logic_vector(15 downto 0);
    signal RIU_RD_VALID_out : std_ulogic;
    
    signal RIU_RD_DATA_delay : std_logic_vector(15 downto 0);
    signal RIU_RD_VALID_delay : std_ulogic;
    
    signal RIU_RD_DATA_LOW_delay : std_logic_vector(15 downto 0);
    signal RIU_RD_DATA_UPP_delay : std_logic_vector(15 downto 0);
    signal RIU_RD_VALID_LOW_delay : std_ulogic;
    signal RIU_RD_VALID_UPP_delay : std_ulogic;
    
    signal RIU_RD_DATA_LOW_in : std_logic_vector(15 downto 0);
    signal RIU_RD_DATA_UPP_in : std_logic_vector(15 downto 0);
    signal RIU_RD_VALID_LOW_in : std_ulogic;
    signal RIU_RD_VALID_UPP_in : std_ulogic;
    
    begin
    glblGSR     <= TO_X01(GSR);
    RIU_RD_DATA <= RIU_RD_DATA_delay after OUT_DELAY;
    RIU_RD_VALID <= RIU_RD_VALID_delay after OUT_DELAY;
    
    RIU_RD_DATA_delay <= RIU_RD_DATA_out;
    RIU_RD_VALID_delay <= RIU_RD_VALID_out;
    
    RIU_RD_DATA_LOW_delay <= RIU_RD_DATA_LOW after IN_DELAY;
    RIU_RD_DATA_UPP_delay <= RIU_RD_DATA_UPP after IN_DELAY;
    RIU_RD_VALID_LOW_delay <= RIU_RD_VALID_LOW after IN_DELAY;
    RIU_RD_VALID_UPP_delay <= RIU_RD_VALID_UPP after IN_DELAY;
    
    RIU_RD_DATA_LOW_in <= RIU_RD_DATA_LOW_delay;
    RIU_RD_DATA_UPP_in <= RIU_RD_DATA_UPP_delay;
    RIU_RD_VALID_LOW_in <= RIU_RD_VALID_LOW_delay;
    RIU_RD_VALID_UPP_in <= RIU_RD_VALID_UPP_delay;

    RIU_RD_DATA_out <= RIU_RD_DATA_UPP_in or RIU_RD_DATA_LOW_in;
    RIU_RD_VALID_out <= RIU_RD_VALID_UPP_in or RIU_RD_VALID_LOW_in;
    
  end RIU_OR_V;
