-- $Header: $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2013 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Analog Buffer
-- /___/   /\     Filename : IBUF_ANALOG.vhd
-- \   \  /  \    Timestamp : Wed Oct 30 16:34:17 PDT 2013
--  \___\/\___\
--
-- Revision:
--    10/30/13 - Initial version.
-- End Revision

----- CELL IBUF_ANALOG                         -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUF_ANALOG is

  port(
    O : out std_ulogic := 'L';
    I : in std_ulogic := 'L'
    );

end IBUF_ANALOG;

architecture IBUF_ANALOG_V of IBUF_ANALOG is
begin

  O <= TO_X01(I) after 0 ps;

end IBUF_ANALOG_V;
