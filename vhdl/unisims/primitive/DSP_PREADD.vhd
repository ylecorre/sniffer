--  $Header: $
-----------------------------------------------------------------------------
--   Copyright (c) 2012 Xilinx Inc.
--   All Right Reserved.
-----------------------------------------------------------------------------
--  
--    ____   ___
--   /   /\/   /
--  /___/  \  /    Vendor      : Xilinx
--  \   \   \/     Version     : 2012.2
--   \   \         Description : Xilinx Unified Simulation Library Component
--   /   /         
--  /___/   /\     
--  \   \  /  \    Filename    : DSP_PREADD.v 
--   \___\/\___\
--  
-----------------------------------------------------------------------------
--   Revision:
--   07/15/12 - Migrate from E1.
--   12/10/12 - Add dynamic registers
--   01/11/13 - DIN, D_DATA width change (26/24) sync4 yml
--   End Revision:
-----------------------------------------------------------------------------

----- CELL DSP_PREADD -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity DSP_PREADD is

  port (
    AD                   : out std_logic_vector(26 downto 0);
    ADDSUB               : in std_ulogic;
    D_DATA               : in std_logic_vector(26 downto 0);
    INMODE2              : in std_ulogic;
    PREADD_AB            : in std_logic_vector(26 downto 0)
   );
end DSP_PREADD;

architecture DSP_PREADD_V of DSP_PREADD is
--  define constants
  constant MODULE_NAME        : string := "DSP_PREADD";
  constant in_delay           : time := 0 ps;
  constant out_delay          : time := 0 ps;
  constant inclk_delay        : time := 0 ps;
  constant outclk_delay       : time := 0 ps;

--  Parameter encodings and registers


  signal glblGSR              : std_ulogic;

  signal attr_err             : std_ulogic := '0';

  signal AD_out               : std_logic_vector (26 downto 0);

  signal AD_delay             : std_logic_vector (26 downto 0);

  signal ADDSUB_in            : std_ulogic;
  signal INMODE_2_in          : std_ulogic;
  signal D_DATA_in            : std_logic_vector (26 downto 0);
  signal PREADD_AB_in         : std_logic_vector (26 downto 0);

  signal ADDSUB_delay         : std_ulogic;
  signal INMODE_2_delay       : std_ulogic;
  signal D_DATA_delay         : std_logic_vector (26 downto 0);
  signal PREADD_AB_delay      : std_logic_vector (26 downto 0);

  signal D_DATA_mux           : std_logic_vector (26 downto 0);

--  input output assignments
begin
   glblGSR          <= TO_X01(GSR);
   AD               <= AD_delay  after out_delay;

    ADDSUB_delay        <= ADDSUB after in_delay;
    D_DATA_delay        <= D_DATA after in_delay;
    INMODE_2_delay      <= INMODE2 after in_delay;
    PREADD_AB_delay     <= PREADD_AB after in_delay;

  AD_delay <= AD_out;

  ADDSUB_in <= ADDSUB_delay;
  D_DATA_in <= D_DATA_delay;
  INMODE_2_in <= INMODE_2_delay;
  PREADD_AB_in <= PREADD_AB_delay;

-- *********************************************************
-- *** Preaddsub AD
-- *********************************************************
  D_DATA_mux <= D_DATA_in when INMODE_2_in = '1' else (others => '0');
  AD_out <= std_logic_vector(unsigned(D_DATA_mux) - unsigned(PREADD_AB_in))
            when (ADDSUB_in = '1') else
            std_logic_vector(unsigned(D_DATA_mux) + unsigned(PREADD_AB_in));


-- any timing


end DSP_PREADD_V;
