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
-- /___/   /\      Filename    : IBUFDSE3.vhd
-- \   \  /  \
--  \__ \/\__ \
--
-----------------------------------------------------------------------------
--  Revision:
--
--  End Revision:
-----------------------------------------------------------------------------

----- CELL IBUFDSE3 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

library UNISIM;
use UNISIM.VPKG.all;
use UNISIM.VCOMPONENTS.all;

entity IBUFDSE3 is
  generic (
    DQS_BIAS : string := "FALSE";
    IBUF_LOW_PWR : boolean := TRUE;
    IOSTANDARD : string := "DEFAULT";
    SIM_INPUT_BUFFER_OFFSET : integer := 0
  );

  port (
    O                    : out std_ulogic;
    I                    : in std_ulogic;
    IB                   : in std_ulogic;
    OSC                  : in std_logic_vector(3 downto 0);
    OSC_EN               : in std_logic_vector(1 downto 0);
    VREF                 : in std_ulogic    
  );
end IBUFDSE3;

architecture IBUFDSE3_V of IBUFDSE3 is

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
  
  constant MODULE_NAME : string := "IBUFDSE3";
  constant IN_DELAY : time := 0 ps;
  constant OUT_DELAY : time := 0 ps;
  constant INCLK_DELAY : time := 0 ps;
  constant OUTCLK_DELAY : time := 0 ps;
  --constant SIM_INPUT_BUFFER_OFFSET : integer := -50;


-- Parameter encodings and registers
  constant DQS_BIAS_FALSE : std_ulogic := '0';
  constant DQS_BIAS_TRUE : std_ulogic := '1';
  constant IBUF_LOW_PWR_FALSE : std_ulogic := '1';
  constant IBUF_LOW_PWR_TRUE : std_ulogic := '0';
  constant IOSTANDARD_DEFAULT : std_ulogic := '0';

  signal DQS_BIAS_BIN : std_ulogic;
  signal IBUF_LOW_PWR_BIN : std_ulogic;
  signal IOSTANDARD_BIN : std_ulogic;
  signal SIM_INPUT_BUFFER_OFFSET_BIN : std_logic_vector(5 downto 0);


  signal glblGSR      : std_ulogic;
  
  signal attr_err     : std_ulogic := '0';
  
  signal O_out : std_ulogic;
  
  signal O_delay : std_ulogic;
  
  signal IB_delay : std_ulogic;
  signal I_delay : std_ulogic;
  signal OSC_EN_delay : std_logic_vector(1 downto 0);
  signal OSC_delay : std_logic_vector(3 downto 0);
  signal O_OSC_in : std_logic;
  signal VREF_delay : std_ulogic;
  
  signal IB_in : std_ulogic;
  signal I_in : std_ulogic;
  signal OSC_EN_in : std_logic_vector(1 downto 0);
  signal OSC_in : std_logic_vector(3 downto 0);
  signal VREF_in : std_ulogic;
  
  begin
  glblGSR     <= TO_X01(GSR);
  O <= O_delay after OUT_DELAY;
  
  --O_delay <= O_out;
  
  IB_delay <= IB after IN_DELAY;
  I_delay <= I after IN_DELAY;
  OSC_EN_delay <= OSC_EN after IN_DELAY;
  OSC_delay <= OSC after IN_DELAY;
  VREF_delay <= VREF after IN_DELAY;
  
  IB_in <= IB_delay;
  I_in <= I_delay;
  OSC_EN_in <= OSC_EN_delay;
  OSC_in <= OSC_delay;
  VREF_in <= VREF_delay;
  
  DQS_BIAS_BIN <= 
    DQS_BIAS_FALSE when (DQS_BIAS = "FALSE") else
    DQS_BIAS_TRUE when (DQS_BIAS = "TRUE") else
    DQS_BIAS_FALSE;

  IBUF_LOW_PWR_BIN <=
    IBUF_LOW_PWR_FALSE when (IBUF_LOW_PWR = FALSE) else
    IBUF_LOW_PWR_TRUE  when (IBUF_LOW_PWR = TRUE)  else
    IBUF_LOW_PWR_TRUE;

  IOSTANDARD_BIN <= 
    IOSTANDARD_DEFAULT when (IOSTANDARD = "DEFAULT") else
    IOSTANDARD_DEFAULT;

  --SIM_INPUT_BUFFER_OFFSET_BIN <= std_logic_vector(to_unsigned(SIM_INPUT_BUFFER_OFFSET,6));
-- SIM_INPUT_BUFFER_OFFSET num 1 min -50 max 50

  
  INIPROC : process
  begin
-------- DQS_BIAS check
  -- case DQS_BIAS is
    if((DQS_BIAS = "FALSE") or (DQS_BIAS = "false")) then
      null;
    elsif((DQS_BIAS = "TRUE") or (DQS_BIAS = "true")) then
      null;
    else
      attr_err <= '1';
      assert FALSE report "Error : DQS_BIAS is not FALSE, TRUE." severity warning;
    end if;
  -- end case;
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
--  if (OSC_EN_in = "11") then
--      if (SIM_INPUT_BUFFER_OFFSET < 0) then 
--          O_OSC_in <= '0';
--      elsif (SIM_INPUT_BUFFER_OFFSET > 0) then
--          O_OSC_in <= '1';
--      elsif (SIM_INPUT_BUFFER_OFFSET = 0) then
--          O_OSC_in <= 'X';
--      end if;	  
  --  end if;
  wait;
  end process INIPROC;
 Behavior : process (I_in, IB_in, DQS_BIAS_BIN)
  begin
    if  (((I_in = '1') or (I_in = 'H')) and ((IB_in = '0') or (IB_in = 'L'))) then
      O_out <= '1';
    elsif (((I_in = '0') or (I_in = 'L')) and ((IB_in = '1') or (IB_in = 'H'))) then
      O_out <= '0';
    elsif ((I_in = 'Z' or I_in = '0' or I_in = 'L') and (IB_in = 'Z' or IB_in = '1' or IB_in = 'H')) then
      if (DQS_BIAS_BIN = '1') then
        O_out <= '0';
      else
        O_out <= 'X';
      end if;
    elsif ((I_in = 'X') or (IB_in = 'X')) then
      O_out <= 'X';
    end if;
  end process Behavior;
  OSC_Enable : process(OSC_in,OSC_EN_in)
  variable OSC_int : integer := 0;
  begin
    if (OSC_in(3) = '0') then
    OSC_int := -1 * SLV_TO_INT(OSC_in(2 downto 0)) * 5;
    else
    OSC_int := SLV_TO_INT(OSC_in(2 downto 0)) * 5;
    end if;
    if (OSC_EN_in = "11") then
      if ((SIM_INPUT_BUFFER_OFFSET + OSC_int) < 0) then
          O_OSC_in <= '0';
      elsif ((SIM_INPUT_BUFFER_OFFSET + OSC_int) > 0) then
          O_OSC_in <= '1';
      elsif ((SIM_INPUT_BUFFER_OFFSET + OSC_int) = 0 ) then
          O_OSC_in <= not O_OSC_in;
      end if;	  
    end if;
  end process OSC_Enable;
 
 O_delay <= O_OSC_in when OSC_EN_in = "11" else
            'X' when (OSC_EN_in = "10" or OSC_EN_in = "01") else
	    O_out; 

end IBUFDSE3_V;
