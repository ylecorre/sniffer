--------------------------------------------------------------------------------
--
-- crc32
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 09:12:57 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 11:00:10 +0200 (Wed, 28 May 2014) $
-- $Revision: 159 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Implements Ethernet crc32, with a byte-level implementation.
--   Data are input byte per byte, in the incoming order. crcErr is asserted
--   when the crc is not equal to the magic number
-- Mode of operation:
--  1) right before receiving the first byte, assert clear and enable to initialize
--     then CRC
--  2) when an input byte is available, assert enable
--  3) check crcErr after the last byte has been input
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity crc32 is
  port(
    clk    : in  std_logic;                             -- clock, rising-edge active
    clear  : in  std_logic;                             -- asserted to clear crc
    enable : in  std_logic;                             -- asserted when new data is available
    data   : in  std_logic_vector(7 downto 0);          -- input data
    crc    : out std_logic_vector(31 downto 0);         -- crc output
    crcErr : out std_logic                              -- cleared when crc is equal to magic number
	);
end crc32;


architecture rtl of crc32 is
 
  signal crcReg : std_logic_vector(31 downto 0) := x"00000000";
	signal crcNxt : std_logic_vector(31 downto 0);
 
begin
 
  crcNxt(0)  <= crcReg(24) xor crcReg(30) xor data(1) xor data(7);
  crcNxt(1)  <= crcReg(25) xor crcReg(31) xor data(0) xor data(6) xor crcReg(24) xor crcReg(30) xor data(1) xor data(7);
  crcNxt(2)  <= crcReg(26) xor data(5) xor crcReg(25) xor crcReg(31) xor data(0) xor data(6) xor crcReg(24) xor crcReg(30) xor data(1) xor data(7);
  crcNxt(3)  <= crcReg(27) xor data(4) xor crcReg(26) xor data(5) xor crcReg(25) xor crcReg(31) xor data(0) xor data(6);
  crcNxt(4)  <= crcReg(28) xor data(3) xor crcReg(27) xor data(4) xor crcReg(26) xor data(5) xor crcReg(24) xor crcReg(30) xor data(1) xor data(7);
  crcNxt(5)  <= crcReg(29) xor data(2) xor crcReg(28) xor data(3) xor crcReg(27) xor data(4) xor crcReg(25) xor crcReg(31) xor data(0) xor data(6) xor crcReg(24) xor crcReg(30) xor data(1) xor data(7);
  crcNxt(6)  <= crcReg(30) xor data(1) xor crcReg(29) xor data(2) xor crcReg(28) xor data(3) xor crcReg(26) xor data(5) xor crcReg(25) xor crcReg(31) xor data(0) xor data(6);
  crcNxt(7)  <= crcReg(31) xor data(0) xor crcReg(29) xor data(2) xor crcReg(27) xor data(4) xor crcReg(26) xor data(5) xor crcReg(24) xor data(7);
  crcNxt(8)  <= crcReg(0) xor crcReg(28) xor data(3) xor crcReg(27) xor data(4) xor crcReg(25) xor data(6) xor crcReg(24) xor data(7);
  crcNxt(9)  <= crcReg(1) xor crcReg(29) xor data(2) xor crcReg(28) xor data(3) xor crcReg(26) xor data(5) xor crcReg(25) xor data(6);
  crcNxt(10) <= crcReg(2) xor crcReg(29) xor data(2) xor crcReg(27) xor data(4) xor crcReg(26) xor data(5) xor crcReg(24) xor data(7);
  crcNxt(11) <= crcReg(3) xor crcReg(28) xor data(3) xor crcReg(27) xor data(4) xor crcReg(25) xor data(6) xor crcReg(24) xor data(7);
  crcNxt(12) <= crcReg(4) xor crcReg(29) xor data(2) xor crcReg(28) xor data(3) xor crcReg(26) xor data(5) xor crcReg(25) xor data(6) xor crcReg(24) xor crcReg(30) xor data(1) xor data(7);
  crcNxt(13) <= crcReg(5) xor crcReg(30) xor data(1) xor crcReg(29) xor data(2) xor crcReg(27) xor data(4) xor crcReg(26) xor data(5) xor crcReg(25) xor crcReg(31) xor data(0) xor data(6);
  crcNxt(14) <= crcReg(6) xor crcReg(31) xor data(0) xor crcReg(30) xor data(1) xor crcReg(28) xor data(3) xor crcReg(27) xor data(4) xor crcReg(26) xor data(5);
  crcNxt(15) <= crcReg(7) xor crcReg(31) xor data(0) xor crcReg(29) xor data(2) xor crcReg(28) xor data(3) xor crcReg(27) xor data(4);
  crcNxt(16) <= crcReg(8) xor crcReg(29) xor data(2) xor crcReg(28) xor data(3) xor crcReg(24) xor data(7);
  crcNxt(17) <= crcReg(9) xor crcReg(30) xor data(1) xor crcReg(29) xor data(2) xor crcReg(25) xor data(6);
  crcNxt(18) <= crcReg(10) xor crcReg(31) xor data(0) xor crcReg(30) xor data(1) xor crcReg(26) xor data(5);
  crcNxt(19) <= crcReg(11) xor crcReg(31) xor data(0) xor crcReg(27) xor data(4);
  crcNxt(20) <= crcReg(12) xor crcReg(28) xor data(3);
  crcNxt(21) <= crcReg(13) xor crcReg(29) xor data(2);
  crcNxt(22) <= crcReg(14) xor crcReg(24) xor data(7);
  crcNxt(23) <= crcReg(15) xor crcReg(25) xor data(6) xor crcReg(24) xor crcReg(30) xor data(1) xor data(7);
  crcNxt(24) <= crcReg(16) xor crcReg(26) xor data(5) xor crcReg(25) xor crcReg(31) xor data(0) xor data(6);
  crcNxt(25) <= crcReg(17) xor crcReg(27) xor data(4) xor crcReg(26) xor data(5);
  crcNxt(26) <= crcReg(18) xor crcReg(28) xor data(3) xor crcReg(27) xor data(4) xor crcReg(24) xor crcReg(30) xor data(1) xor data(7);
  crcNxt(27) <= crcReg(19) xor crcReg(29) xor data(2) xor crcReg(28) xor data(3) xor crcReg(25) xor crcReg(31) xor data(0) xor data(6);
  crcNxt(28) <= crcReg(20) xor crcReg(30) xor data(1) xor crcReg(29) xor data(2) xor crcReg(26) xor data(5);
  crcNxt(29) <= crcReg(21) xor crcReg(31) xor data(0) xor crcReg(30) xor data(1) xor crcReg(27) xor data(4);
  crcNxt(30) <= crcReg(22) xor crcReg(31) xor data(0) xor crcReg(28) xor data(3);
  crcNxt(31) <= crcReg(23) xor crcReg(29) xor data(2);
 
  p_main : process(clk)
  begin 
   if rising_edge(clk) then
     if clear = '1' then
       crcReg <= (others => '1');
     elsif enable = '1' then
       crcReg <= crcNxt;
     end if;
   end if;
  end process;
 
  crc(31 downto 24) <= not (crcReg(24) & crcReg(25) & crcReg(26) & crcReg(27) & crcReg(28) & crcReg(29) & crcReg(30) & crcReg(31));
  crc(23 downto 16) <= not (crcReg(16) & crcReg(17) & crcReg(18) & crcReg(19) & crcReg(20) & crcReg(21) & crcReg(22) & crcReg(23));
  crc(15 downto 8) <= not (crcReg(8) & crcReg(9) & crcReg(10) & crcReg(11) & crcReg(12) & crcReg(13) & crcReg(14) & crcReg(15));
  crc(7 downto 0) <= not (crcReg(0) & crcReg(1) & crcReg(2) & crcReg(3) & crcReg(4) & crcReg(5) & crcReg(6) & crcReg(7));
 
  crcErr <= '1' when crcReg /= x"c704dd7b" else '0';  -- CRC not equal to magic number
 
end rtl;
