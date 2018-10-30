-------------------------------------------------------
--  Copyright (c) 2013 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   /
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version     : 2013.2 
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                      
-- /___/   /\      Filename    : FRAME_ECCE3.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-------------------------------------------------------
--  Revision:
--     05/30/13 - Initial version.
--  End Revision
-------------------------------------------------------

----- CELL FRAME_ECCE3 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity FRAME_ECCE3 is

    port (
      CRCERROR             : out std_ulogic;
      ECCERRORNOTSINGLE    : out std_ulogic;
      ECCERRORSINGLE       : out std_ulogic;
      ENDOFFRAME           : out std_ulogic;
      ENDOFSCAN            : out std_ulogic;
      FAR                  : out std_logic_vector(25 downto 0);
      FARSEL               : in  std_logic_vector(1 downto 0);
      ICAPBOTCLK           : in  std_ulogic;
      ICAPTOPCLK           : in  std_ulogic      
    );
  end FRAME_ECCE3;

  architecture FRAME_ECCE3_V of FRAME_ECCE3 is
    
    signal glblGSR : std_ulogic;
    
    begin

      glblGSR     <= TO_X01(GSR);
    
  end FRAME_ECCE3_V;
