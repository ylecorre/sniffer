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
-- /___/   /\      Filename    : IBUFE3.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-----------------------------------------------------------------------------
--  Revision:
--
--  End Revision:
-----------------------------------------------------------------------------

----- CELL IBUFE3 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

library UNISIM;
use UNISIM.VPKG.all;
use UNISIM.VCOMPONENTS.all;

entity IBUFE3 is
  generic (
    IBUF_LOW_PWR : boolean := TRUE;
    IOSTANDARD : string := "DEFAULT";
    SIM_INPUT_BUFFER_OFFSET : integer := 0 
  );

  port (
    O                    : out std_ulogic;
    I                    : in std_ulogic;
    OSC                  : in std_logic_vector(3 downto 0);
    OSC_EN               : in std_ulogic;
    VREF                 : in std_ulogic    
  );
end IBUFE3;

architecture IBUFE3_V of IBUFE3 is
  ---------------------------------------------------------------------------
  -- Function SLV_TO_INT converts a std_logic_vector TO INTEGER
  ---------------------------------------------------------------------------
  function SLV_TO_INT(SLV: in std_logic_vector
                      ) return integer is

    variable int : integer;
  begin
    int := 0;
    for i in SLV'high downto SLV'low loop
      int := int * 2;
      if SLV(i) = '1' then
        int := int + 1;
      end if;
    end loop;
    return int;
  end;

  constant MODULE_NAME : string := "IBUFE3";
  constant IN_DELAY : time := 0 ps;
  constant OUT_DELAY : time := 0 ps;
  constant INCLK_DELAY : time := 0 ps;
  constant OUTCLK_DELAY : time := 0 ps;
--  constant SIM_INPUT_BUFFER_OFFSET : integer := -50;

-- Parameter encodings and registers
  constant IBUF_LOW_PWR_FALSE : std_ulogic := '1';
  constant IBUF_LOW_PWR_TRUE : std_ulogic := '0';
  constant IOSTANDARD_DEFAULT : std_ulogic := '0';

  signal IBUF_LOW_PWR_BIN : std_ulogic;
  signal IOSTANDARD_BIN : std_ulogic;
  signal SIM_INPUT_BUFFER_OFFSET_BIN : std_logic_vector(5 downto 0);
-- SIM_INPUT_BUFFER_OFFSET num 1 min  max 


  signal glblGSR      : std_ulogic;
  
  signal attr_err     : std_ulogic := '0';
  
  signal O_out : std_ulogic;
  
  signal O_delay : std_ulogic;
  
  signal I_delay : std_ulogic;
  signal OSC_EN_delay : std_ulogic;
  signal OSC_delay : std_logic_vector(3 downto 0);
  signal VREF_delay : std_ulogic;
  
  signal I_in : std_ulogic;
  signal OSC_EN_in : std_ulogic;
  signal OSC_in : std_logic_vector(3 downto 0);
  signal O_OSC_in : std_ulogic;
  signal VREF_in : std_ulogic;

  
  begin
  glblGSR     <= TO_X01(GSR);
  O <= O_delay after OUT_DELAY;
  
  O_delay <= O_out;
  
  I_delay <= I after IN_DELAY;
  OSC_EN_delay <= OSC_EN after IN_DELAY;
  OSC_delay <= OSC after IN_DELAY;
  VREF_delay <= VREF after IN_DELAY;
  
  I_in <= I_delay;
  OSC_EN_in <= OSC_EN_delay;
  OSC_in <= OSC_delay;
  VREF_in <= VREF_delay;
  
  IBUF_LOW_PWR_BIN <=
    IBUF_LOW_PWR_FALSE when (IBUF_LOW_PWR = FALSE) else
    IBUF_LOW_PWR_TRUE  when (IBUF_LOW_PWR = TRUE)  else
    IBUF_LOW_PWR_TRUE;

  IOSTANDARD_BIN <= 
    IOSTANDARD_DEFAULT when (IOSTANDARD = "DEFAULT") else
    IOSTANDARD_DEFAULT;

  --SIM_INPUT_BUFFER_OFFSET_BIN <= std_logic_vector(to_unsigned(to_integer(SIM_INPUT_BUFFER_OFFSET),6));
-- SIM_INPUT_BUFFER_OFFSET num 1 min -50 max 50

  
  INIPROC : process
  begin
-------- IOSTANDARD check
  -- case IOSTANDARD is
    if((IOSTANDARD = "DEFAULT") or (IOSTANDARD = "default")) then
      null;
    else
      attr_err <= '1';
      assert FALSE report "Error : IOSTANDARD is not DEFAULT." severity warning;
    end if;
  -- end case;
-------- SIM_INPUT_BUFFER_OFFSET check
  if ((SIM_INPUT_BUFFER_OFFSET >= -50) and (SIM_INPUT_BUFFER_OFFSET <= 50)) then
    null;
  else
    attr_err <= '1';
    assert FALSE report "Error : SIM_INPUT_BUFFER_OFFSET is not in range -50 .. 50." severity warning;
  end if;
case IBUF_LOW_PWR is
  when FALSE   =>  null;
when TRUE    =>  null;
when others  =>
  attr_err <= '1';
  assert FALSE report "Error : IBUF_LOW_PWR is neither TRUE nor FALSE." severity warning;
  end case;
  if  (attr_err = '1') then
    assert FALSE
    report "Error : Attribute Error(s) encountered"
    severity error;
  end if;
  wait;
  end process INIPROC;
  OSC_Enable : process(OSC_in,OSC_EN_in)
  variable OSC_int : integer := 0;
  begin
    if (OSC_in(3) = '0') then
    OSC_int := -1 * SLV_TO_INT(OSC_in(2 downto 0)) * 5;
    else
    OSC_int := SLV_TO_INT(OSC_in(2 downto 0)) * 5;
    end if;
    if (OSC_EN_in = '1') then
      if ((SIM_INPUT_BUFFER_OFFSET + OSC_int) < 0) then 
          O_OSC_in <= '0';
      elsif ((SIM_INPUT_BUFFER_OFFSET + OSC_int) > 0) then
          O_OSC_in <= '1';
      elsif ((SIM_INPUT_BUFFER_OFFSET + OSC_int) = 0 ) then
          O_OSC_in <= not O_OSC_in;
      end if;	  
    end if;
  end process OSC_Enable;
 
O_out <= O_OSC_in when OSC_EN_in = '1' else
         TO_X01(I_in);

end IBUFE3_V;
