------------------------------------------------------------------------------
-- Copyright (c) 1995/2013 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  
-- /___/   /\     Filename : SYSMONE1.vhd
-- \   \  /  \    Timestamp : 
--  \___\/\___\
-- Revision:
--    02/08/13 - Initial version.
--    03/19/13 - Fixed fatal width problem (CR 707214).
--             - Update MUXADDR width (CR 706758).
--    03/20/13 - Fixed output MSB problem (CR 706163).
--             - Remove SCL and SDA ports (CR 707646). 
--    04/26/13 - Add invertible pin support (PR 683925).
--    05/08/13 - Changed Vuser1-4 to Vuser 0-3 (CR 716783).
--    05/29/13 - Fixed dr_sram index with mixture of hex and int (CR 717955).
--    06/04/13 - Added I2CSCLK and I2CSDA ports (CR 721147).
--    10/15/13 - Added I2C simulation support (CR 707725).
--    10/28/13 - Removed DRC for event mode timing (CR 736315).
--    11/15/13 - Updated I2C support for in and output instead of inout (CR 742395).
-- End Revision

----- CELL SYSMONE1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.NUMERIC_STD.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity SYSMONE1 is

generic (

  INIT_40 : bit_vector := X"0000";
  INIT_41 : bit_vector := X"0000";
  INIT_42 : bit_vector := X"0000";
  INIT_43 : bit_vector := X"0000";
  INIT_44 : bit_vector := X"0000";
  INIT_45 : bit_vector := X"0000";
  INIT_46 : bit_vector := X"0000";
  INIT_47 : bit_vector := X"0000";
  INIT_48 : bit_vector := X"0000";
  INIT_49 : bit_vector := X"0000";
  INIT_4A : bit_vector := X"0000";
  INIT_4B : bit_vector := X"0000";
  INIT_4C : bit_vector := X"0000";
  INIT_4D : bit_vector := X"0000";
  INIT_4E : bit_vector := X"0000";
  INIT_4F : bit_vector := X"0000";
  INIT_50 : bit_vector := X"0000";
  INIT_51 : bit_vector := X"0000";
  INIT_52 : bit_vector := X"0000";
  INIT_53 : bit_vector := X"0000";
  INIT_54 : bit_vector := X"0000";
  INIT_55 : bit_vector := X"0000";
  INIT_56 : bit_vector := X"0000";
  INIT_57 : bit_vector := X"0000";
  INIT_58 : bit_vector := X"0000";
  INIT_59 : bit_vector := X"0000";
  INIT_5A : bit_vector := X"0000";
  INIT_5B : bit_vector := X"0000";
  INIT_5C : bit_vector := X"0000";
  INIT_5D : bit_vector := X"0000";
  INIT_5E : bit_vector := X"0000";
  INIT_5F : bit_vector := X"0000";
  INIT_60 : bit_vector := X"0000";
  INIT_61 : bit_vector := X"0000";
  INIT_62 : bit_vector := X"0000";
  INIT_63 : bit_vector := X"0000";
  INIT_64 : bit_vector := X"0000";
  INIT_65 : bit_vector := X"0000";
  INIT_66 : bit_vector := X"0000";
  INIT_67 : bit_vector := X"0000";
  INIT_68 : bit_vector := X"0000";
  INIT_69 : bit_vector := X"0000";
  INIT_6A : bit_vector := X"0000";
  INIT_6B : bit_vector := X"0000";
  INIT_6C : bit_vector := X"0000";
  INIT_6D : bit_vector := X"0000";
  INIT_6E : bit_vector := X"0000";
  INIT_6F : bit_vector := X"0000";
  INIT_70 : bit_vector := X"0000";
  INIT_71 : bit_vector := X"0000";
  INIT_72 : bit_vector := X"0000";
  INIT_73 : bit_vector := X"0000";
  INIT_74 : bit_vector := X"0000";
  INIT_75 : bit_vector := X"0000";
  INIT_76 : bit_vector := X"0000";
  INIT_77 : bit_vector := X"0000";
  INIT_78 : bit_vector := X"0000";
  INIT_79 : bit_vector := X"0000";
  INIT_7A : bit_vector := X"0000";
  INIT_7B : bit_vector := X"0000";
  INIT_7C : bit_vector := X"0000";
  INIT_7D : bit_vector := X"0000";
  INIT_7E : bit_vector := X"0000";
  INIT_7F : bit_vector := X"0000";
  IS_CONVSTCLK_INVERTED : std_ulogic := '0';
  IS_DCLK_INVERTED : std_ulogic := '0';
  SIM_MONITOR_FILE : string := "design.txt";
  SYSMON_VUSER0_BANK : integer := 0;
  SYSMON_VUSER0_MONITOR : string := "NONE";
  SYSMON_VUSER1_BANK : integer := 0;
  SYSMON_VUSER1_MONITOR : string := "NONE";
  SYSMON_VUSER2_BANK : integer := 0;
  SYSMON_VUSER2_MONITOR : string := "NONE";
  SYSMON_VUSER3_BANK : integer := 0;
  SYSMON_VUSER3_MONITOR : string := "NONE"
  );

port (
                ALM : out std_logic_vector(15 downto 0);
                BUSY : out std_ulogic;
                CHANNEL : out std_logic_vector(5 downto 0);
                DO : out std_logic_vector(15 downto 0);
                DRDY : out std_ulogic;
                EOC : out std_ulogic;
                EOS : out std_ulogic;
                I2C_SCLK_TS : out std_ulogic;
                I2C_SDA_TS : out std_ulogic;
                JTAGBUSY : out std_ulogic;
                JTAGLOCKED : out std_ulogic;
                JTAGMODIFIED : out std_ulogic;
                MUXADDR : out std_logic_vector(4 downto 0);
                OT : out std_ulogic;

                CONVST : in std_ulogic;
                CONVSTCLK : in std_ulogic;
                DADDR : in std_logic_vector(7 downto 0);
                DCLK : in std_ulogic;
                DEN : in std_ulogic;
                DI : in std_logic_vector(15 downto 0);
                DWE : in std_ulogic;
                I2C_SCLK : in std_ulogic;
                I2C_SDA : in std_ulogic;
                RESET : in std_ulogic;
                VAUXN : in std_logic_vector(15 downto 0);
                VAUXP : in std_logic_vector(15 downto 0);
                VN : in std_ulogic;
                VP : in std_ulogic

     );



end SYSMONE1;


architecture SYSMONE1_V of SYSMONE1 is
 
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


  ---------------------------------------------------------------------------
  -- Function ADDR_IS_VALID checks for the validity of the argument. A FALSE
  -- is returned if any argument bit is other than a '0' or '1'.
  ---------------------------------------------------------------------------
  function ADDR_IS_VALID (
    SLV : in std_logic_vector
    ) return boolean is

    variable IS_VALID : boolean := TRUE;

  begin
    for I in SLV'high downto SLV'low loop
      if (SLV(I) /= '0' AND SLV(I) /= '1') then
        IS_VALID := FALSE;
      end if;
    end loop;
    return IS_VALID;
  end ADDR_IS_VALID;

  ---------------------------------------------------------------------------
  -- Function SLV_TO_STR returns a string version of the std_logic_vector
  -- argument.
  ---------------------------------------------------------------------------
  function SLV_TO_STR (
    SLV : in std_logic_vector
    ) return string is

    variable j : integer := SLV'length;
    variable STR : string (SLV'length downto 1);
  begin
    for I in SLV'high downto SLV'low loop
      case SLV(I) is
        when '0' => STR(J) := '0';
        when '1' => STR(J) := '1';
        when 'X' => STR(J) := 'X';
        when 'U' => STR(J) := 'U';
        when others => STR(J) := 'X';
      end case;
      J := J - 1;
    end loop;
    return STR;
  end SLV_TO_STR;

  function real2int( real_in : in real) return integer is
    variable int_value : integer;
    variable tmpt : time;
    variable tmpt1 : time;
    variable tmpa : real;
    variable tmpr : real;
    variable int_out : integer;
  begin
    tmpa := abs(real_in);
    tmpt := tmpa * 1 ps;
    int_value := (tmpt / 1 ps ) * 1;
    tmpt1 := int_value * 1 ps;
      tmpr := real(int_value);  

    if ( real_in < 0.0000) then
       if (tmpr > tmpa) then
           int_out := 1 - int_value;
       else
           int_out := -int_value;
       end if;
    else
      if (tmpr > tmpa) then 
           int_out := int_value - 1;
      else
           int_out := int_value;
      end if;
    end if;
    return int_out;
  end real2int;


    FUNCTION  To_Upper  ( CONSTANT  val    : IN String
                         ) RETURN STRING IS
        VARIABLE result   : string (1 TO val'LENGTH) := val;
        VARIABLE ch       : character;
    BEGIN
        FOR i IN 1 TO val'LENGTH LOOP
            ch := result(i);
            EXIT WHEN ((ch = NUL) OR (ch = nul));
            IF ( ch >= 'a' and ch <= 'z') THEN
                  result(i) := CHARACTER'VAL( CHARACTER'POS(ch)
                                       - CHARACTER'POS('a')
                                       + CHARACTER'POS('A') );
            END IF;
        END LOOP;
        RETURN result;
    END To_Upper;

    procedure get_token(buf : inout LINE; token : out string;
                            token_len : out integer) 
    is
       variable index : integer := buf'low;
       variable tk_index : integer := 0;
       variable old_buf : LINE := buf; 
    BEGIN
         while ((index <= buf' high) and ((buf(index) = ' ') or
                                         (buf(index) = HT))) loop
              index := index + 1; 
         end loop;
        
         while((index <= buf'high) and ((buf(index) /= ' ') and 
                                    (buf(index) /= HT))) loop 
              tk_index := tk_index + 1;
              token(tk_index) := buf(index);
              index := index + 1; 
         end loop;
   
         token_len := tk_index;
        
         buf := new string'(old_buf(index to old_buf'high));
           old_buf := NULL;
    END;

    procedure skip_blanks(buf : inout LINE) 
    is
         variable index : integer := buf'low;
         variable old_buf : LINE := buf; 
    BEGIN
         while ((index <= buf' high) and ((buf(index) = ' ') or 
                                       (buf(index) = HT))) loop
              index := index + 1; 
         end loop;
         buf := new string'(old_buf(index to old_buf'high));
           old_buf := NULL;
    END;

    procedure infile_format
    is
         variable message_line : line;
    begin

    write(message_line, string'("***** SYSMONE1 Simulation Analog Data File Format ******"));
    writeline(output, message_line);
    write(message_line, string'("NAME: design.txt or user file name passed with generic sim_monitor_file"));
    writeline(output, message_line);
    write(message_line, string'("FORMAT: First line is header line. Valid column name are: TIME TEMP VCCINT VCCAUX VBRAM VCCPINT VCCPAUX VCCDDRO VP VN VAUXP[0] VAUXN[0] ...."));
    writeline(output, message_line);
    write(message_line, string'("TIME must be in first column."));
    writeline(output, message_line);
    write(message_line, string'("Time value need to be integer in ns scale"));
    writeline(output, message_line);
    write(message_line, string'("Analog  value need to be real and contain a decimal  point '.', zero should be 0.0, 3 should be 3.0"));
    writeline(output, message_line);
    write(message_line, string'("Each line including header line can not have extra space after the last character/digit."));
    writeline(output, message_line);
    write(message_line, string'("Each data line must have same number of columns as the header line."));
    writeline(output, message_line);
    write(message_line, string'("Comment line start with -- or //"));
    writeline(output, message_line);
    write(message_line, string'("Example:"));
    writeline(output, message_line);
    write(message_line, string'("TIME TEMP VCCINT  VP VN VAUXP[0] VAUXN[0]"));
    writeline(output, message_line);
    write(message_line, string'("000  125.6  1.0  0.7  0.4  0.3  0.6"));
    writeline(output, message_line);
    write(message_line, string'("200  25.6   0.8  0.5  0.3  0.8  0.2"));
    writeline(output, message_line);

    end infile_format;


       type     REG_FILE   is  array (integer range <>) of 
                            std_logic_vector(15 downto 0);
       signal   dr_sram     :  REG_FILE(64 to 173);
       type     adc_zntat    is (S1_ST, S2_ST, S3_ST, S4_ST, S5_ST, S6_ST);
       type     mn_DATA    is array (0 to 35) of real;
       type     DR_data_reg    is array (0 to 63) of 
                                  std_logic_vector(15 downto 0);
  
       type     ACC_ARRAY      is array (0 to 63) of integer;
       type     int_array      is array(0 to 31) of integer;
       type     seq_array      is array(32 downto 0 ) of integer;


       signal   data_reg         : DR_data_reg
                                  :=( 36 to 39 => "1111111111111111",
                                      44 to 46 => "1111111111111111",
                                     others=>"0000000000000000");
  
       signal   ot_limit_reg     : std_logic_vector(15 downto 0) := X"CA30";
     
       signal   adc_state         : adc_zntat := S3_ST;
       signal   next_state        : adc_zntat;
       signal   cfg_reg0         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg0_adc     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg0_seq     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg1         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg1_init    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg2         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg3         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq1_0           : std_logic_vector(3 downto 0) := "0000";
       signal   curr_seq1_0      : std_logic_vector(3 downto 0) := "0000";
       signal   curr_seq1_0_lat  : std_logic_vector(3 downto 0) := "0000";
       signal   busy_r           : std_ulogic := '0';
       signal   busy_r_rst       : std_ulogic := '0';
       signal   busy_rst         : std_ulogic := '0';
       signal   busy_conv        : std_ulogic := '0';
       signal   busy_out_tmp     : std_ulogic := '0';
       signal   busy_out_dly     : std_ulogic := '0';
       signal   busy_out_sync    : std_ulogic := '0';
       signal   busy_out_low_edge : std_ulogic := '0';
       signal   shorten_acq      : integer := 1;
       signal   busy_seq_rst     : std_ulogic := '0';
       signal   busy_sync1       : std_ulogic := '0';
       signal   busy_sync2       : std_ulogic := '0';
       signal   busy_sync_fall   : std_ulogic := '0';
       signal   busy_sync_rise   : std_ulogic := '0';
       signal   cal_chan_update  : std_ulogic := '0';
       signal   first_cal_chan   : std_ulogic := '0';
       signal   seq_reset_flag   : std_ulogic := '0';
       signal   seq_reset_flag_dly   : std_ulogic := '0';
       signal   seq_reset_dly   : std_ulogic := '0';
       signal   seq_reset_busy_out  : std_ulogic := '0';
       signal   rst_in_not_seq   : std_ulogic := '0';
       signal   rst_in_out       : std_ulogic := '0';
       signal   rst_lock_early   : std_ulogic := '0';
       signal   rst_lock_late   : std_ulogic := '0';
       signal   conv_count       : integer := 0;
       signal   acq_count       : integer := 1;
       signal   do_out_rdtmp     : std_logic_vector(15 downto 0);
       signal   rst_in1          : std_ulogic := '0';
       signal   rst_in2          : std_ulogic := '0';
       signal   int_rst          : std_ulogic := '1';
       signal   rst_input_t      : std_ulogic := '0';
       signal   rst_in           : std_ulogic := '0';
       signal   ot_en            : std_logic := '1';
       signal   curr_clkdiv_sel  : std_logic_vector(7 downto 0) 
                                                  := "00000000";
       signal   curr_clkdiv_sel_int : integer := 0;
       signal   adcclk           : std_ulogic := '0';
       signal   adcclk_r           : std_ulogic := '0';
       signal   adcclk_div1      : std_ulogic := '0';
       signal   sysclk           : std_ulogic := '0';
       signal   curr_adc_resl    : std_logic_vector(2 downto 0) := "010";
       signal   nx_seq           : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   curr_seq         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   curr_seq_m       : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   curr_seq2        : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   acq_cnt          : integer := 0;
       signal   acq_chan         : std_logic_vector(5 downto 0) := "000000";
       signal   acq_chan_m       : std_logic_vector(4 downto 0) := "00000";
       signal   acq_chan_index   : integer := 0;
       signal   acq_chan_lat     : std_logic_vector(5 downto 0) := "000000";
       signal   curr_chan        : std_logic_vector(5 downto 0) := "000000";
       signal   curr_chan_dly    : std_logic_vector(5 downto 0) := "000000";
       signal   curr_chan_lat    : std_logic_vector(5 downto 0) := "000000";
       signal   curr_pj_set     : std_logic_vector(1 downto 0) := "00";
       signal   acq_avg          : std_logic_vector(1 downto 0) := "00";
       signal   ext_mux         : std_logic:= '0';
       signal   ext_mux_chan_idx   : integer := 0;
       signal   curr_e_c         : std_logic:= '0';
       signal   acq_e_c          : std_logic:= '0';
       signal   acq_b_u          : std_logic:= '0';
       signal   curr_b_u         : std_logic:= '0';
       signal   acq_acqsel       : std_logic:= '0';
       signal   curr_acq         : std_logic:= '0';
       signal   seq_cnt          : integer := 0;
       signal   busy_rst_cnt     : integer := 0;
       signal   adc_s1_flag      : std_ulogic := '0';
       signal   adc_convst       : std_ulogic := '0';
       signal   conv_start       : std_ulogic := '0';
       signal   conv_end         : std_ulogic := '0'; 
       signal   eos_en           : std_ulogic := '0';
       signal   eos_tmp_en       : std_ulogic := '0';
       signal   seq_cnt_en       : std_ulogic := '0'; 
       signal   sysmone1_en          : std_ulogic := '0';
       signal   sysmone12_en          : std_ulogic := '0';
       signal   eoc_en           : std_ulogic := '0';
       signal   eoc_en_delay       : std_ulogic := '0';
       signal   eoc_out_tmp     : std_ulogic := '0';
       signal   eos_out_tmp     : std_ulogic := '0';
       signal   eoc_out_tmp1     : std_ulogic := '0';
       signal   eos_out_tmp1     : std_ulogic := '0';
       signal   eoc_up_data      : std_ulogic := '0';
       signal   eoc_up_alarm    : std_ulogic := '0';
       signal   conv_time        : integer := 17;
       signal   conv_time_cal_1  : integer := 95;
       signal   conv_time_cal    : integer := 95;
       signal   conv_result      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   conv_result_reg  : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   data_written     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   conv_result_int  : integer := 0;
       signal   conv_result_int_resl  : integer := 0;
       signal   mn_in_uni    : mn_DATA :=(others=>0.0); 
       signal   mn_in_diff   : mn_DATA :=(others=>0.0); 
       signal   mn_in        : mn_DATA :=(others=>0.0); 
       signal   mn_in_comm   : mn_DATA :=(others=>0.0); 
       signal   chan_val_tmp   : mn_DATA :=(others=>0.0); 
       signal   chan_valn_tmp   : mn_DATA :=(others=>0.0); 
--       signal   data_reg         : DR_data_reg
--                                  :=( 36 to 39 => "1111111111111111",
--                                      44 to 46 => "1111111111111111",
--                                     others=>"0000000000000000");
       signal   tmp_data_reg_out : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   tmp_dr_sram_out  : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_chan_reg1    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_chan_reg2    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_chan_reg3    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_acq_reg1     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_acq_reg2     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_acq_reg3     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_pj_reg1     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_pj_reg2     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_pj_reg3     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_du_reg1      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_du_reg2      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_du_reg3      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_count        : integer := 1;
       signal   seq_count_a      : integer := 1;
       signal   seq_count_en     : std_ulogic := '0';
       signal   conv_acc         : ACC_ARRAY :=(others=>0);
       signal   conv_pj_count   : ACC_ARRAY :=(others=>0);
       signal   conv_acc_vec     : std_logic_vector (20 downto 1);
       signal   conv_acc_result  : std_logic_vector(15 downto 0);
       signal   seq_status_avg   : integer := 0;
       signal   curr_chan_index       : integer := 0;
       signal   curr_chan_index_lat   : integer := 0;
       signal   conv_pj_cnt     : int_array :=(others=>0);
       signal   mn_mux_in    : real := 0.0;
       signal   adc_temp_result  : real := 0.0;
       signal   adc_intpwr_result : real := 0.0;
       signal   adc_ext_result    : real := 0.0;
       signal   seq_reset        : std_ulogic := '0';
       signal   seq_en           : std_ulogic := '0';
       signal   seq_en_drp       : std_ulogic := '0';
       signal   seq_en_init      : std_ulogic := '0';
       signal   seq_en_dly       : std_ulogic := '0';
       signal   seq_num          : integer := 0;
       signal   seq_mem          : seq_array :=(others=>0);
       signal   adc_seq_reset       : std_ulogic := '0';
       signal   adc_seq_en          : std_ulogic := '0';
       signal   adc_seq_reset_dly   : std_ulogic := '0';
       signal   adc_seq_en_dly      : std_ulogic := '0';
       signal   adc_seq_reset_hold  : std_ulogic := '0';
       signal   adc_seq_en_hold     : std_ulogic := '0';
       signal   rst_lock            : std_ulogic := '1';
       signal   sim_file_flag       : std_ulogic := '0';
       signal   gsr_in              : std_ulogic := '0';
       signal   convstclk_in       : std_ulogic := '0';
       signal   convst_raw_in      : std_ulogic := '0';
       signal   convst_in          : std_ulogic := '0';
       signal   convst_in_tmp          : std_ulogic := '0';
       signal   dclk_in            : std_ulogic := '0';
       signal   den_in             : std_ulogic := '0';
       signal   rst_input          : std_ulogic := '0';
       signal   dwe_in             : std_ulogic := '0';
       signal   di_in              : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   daddr_in           : std_logic_vector(7 downto 0) := "00000000";
       signal   daddr_in_lat       : std_logic_vector(7 downto 0) := "00000000";
       signal   daddr_in_lat_int   : integer := 0;
       signal   drdy_out_tmp1      : std_ulogic := '0';
       signal   drdy_out_tmp2      : std_ulogic := '0';
       signal   drdy_out_tmp3      : std_ulogic := '0';
       signal   drdy_out_tmp4      : std_ulogic := '0';
       signal   drp_update         : std_ulogic := '0';
       signal   alarm_en           : std_logic_vector(15 downto 0) := "1111111111111111";
       signal   alarm_update       : std_ulogic := '0';
       signal   adcclk_tmp         : std_ulogic := '0';
       signal   ot_out_reg         : std_ulogic := '0';
       signal   alarm_out_reg      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   conv_end_reg_read  :  std_logic_vector(3 downto 0) := "0000";
       signal   busy_reg_read      : std_ulogic := '0';
       signal   single_chan_conv_end : std_ulogic := '0';
       signal   first_acq          : std_ulogic := '1';
       signal   conv_start_cont    : std_ulogic := '0';
       signal   conv_start_sel     : std_ulogic := '0';
       signal   reset_conv_start   : std_ulogic := '0';
       signal   reset_conv_start_tmp   : std_ulogic := '0';
       signal   busy_r_rst_done    : std_ulogic := '0';
       signal   op_count           : integer := 15;
       signal   simd_f : std_ulogic := '0';
       signal   rst_in1_tmp5 : std_ulogic := '0';
       signal   rst_in1_tmp6 : std_ulogic := '0';
       signal   rst_in2_tmp5 : std_ulogic := '0';
       signal   rst_in2_tmp6 : std_ulogic := '0';
       signal   soft_reset : std_ulogic := '0';
       signal   flag_reg0 : std_logic_vector(15 downto 0);
       signal   flag_reg1 : std_logic_vector(15 downto 0);
       signal   acq_e_c_tmp5 : std_ulogic := '0';
       signal   acq_e_c_tmp6 : std_ulogic := '0';
       signal   cfg_reg0_adc_tmp5 : std_logic_vector(15 downto 0) := X"0000";
       signal   cfg_reg0_adc_tmp6 : std_logic_vector(15 downto 0) := X"0000";
       signal   cfg_reg0_seq_tmp5 : std_logic_vector(15 downto 0) := X"0000";
       signal   cfg_reg0_seq_tmp6 : std_logic_vector(15 downto 0) := X"0000";
      

-- Input/Output Pin signals

        signal   DI_ipd  :  std_logic_vector(15 downto 0);
        signal   DADDR_ipd  :  std_logic_vector(7 downto 0);
        signal   DEN_ipd  :  std_ulogic;
        signal   DWE_ipd  :  std_ulogic;
        signal   DCLK_ipd  :  std_ulogic;
        signal   CONVSTCLK_ipd  :  std_ulogic;
        signal   RESET_ipd  :  std_ulogic;
        signal   CONVST_ipd  :  std_ulogic;

        signal   do_out  :  std_logic_vector(15 downto 0) := "0000000000000000";
        signal   drdy_out  :  std_ulogic := '0';
        signal   ot_out  :  std_ulogic := '0';
        signal   alarm_out  :  std_logic_vector(15 downto 0) := "0000000000000000";
        signal   channel_out  :  std_logic_vector(5 downto 0) := "000000";
        signal   muxaddr_out  :  std_logic_vector(4 downto 0) := "00000";
        signal   muxaddr_o  :  std_logic_vector(4 downto 0) := "00000";
        signal   eoc_out  :  std_ulogic := '0';
        signal   eoc_out_t  :  std_ulogic := '0';
        signal   eos_out  :  std_ulogic := '0';
        signal   busy_out  :  std_ulogic := '0';

        signal   DI_dly  :  std_logic_vector(15 downto 0);
        signal   DADDR_dly  :  std_logic_vector(7 downto 0);
        signal   DEN_dly  :  std_ulogic;
        signal   DWE_dly  :  std_ulogic;
        signal   DCLK_dly  :  std_ulogic;
        signal   CONVSTCLK_dly  :  std_ulogic;
        signal   RESET_dly  :  std_ulogic;
        signal   CONVST_dly  :  std_ulogic;

        signal   halt_adc : integer := 0;
        signal   int_rst_halt_adc : std_ulogic := '0';
        signal   trig_halt_adc_dr_sram : std_ulogic := '0';
        signal   trig_halt_adc : std_ulogic := '0';

        signal i2c_sclk_in : std_ulogic;
        signal i2c_sda_in : std_ulogic;
        signal i2c_sda_out : std_ulogic := '0';
        signal i2c_sda_out_en : std_ulogic := '0';
        signal i2c_sda_in_sync : std_ulogic;
        signal i2c_sda_in_sync_d1 : std_ulogic;
        signal i2c_sda_in_sync_d2 : std_ulogic;
        signal i2c_sclk_in_sync : std_ulogic;
        signal i2c_sclk_in_sync_d1 : std_ulogic;
        signal i2c_sclk_in_sync_d2 : std_ulogic;
        signal detect_ack : std_ulogic;
        signal byte_cnt : integer := 0;
        signal bit_cnt : integer := 8;
        signal i2c_data_in :  std_logic_vector(31 downto 0) := (others => '0');
        signal i2c_data_in70 :  std_logic_vector(7 downto 0) := (others => '0');
        signal i2c_data_in158 :  std_logic_vector(7 downto 0) := (others => '0');
        signal i2c_data_in2316 :  std_logic_vector(7 downto 0) := (others => '0');
        signal i2c_data_in3124 :  std_logic_vector(7 downto 0) := (others => '0');
        signal i2c_sda_out_70_tmp : std_logic_vector(7 downto 0);
        signal i2c_sda_out_158_tmp : std_logic_vector(7 downto 0);
        signal i2c_address : std_logic_vector(7 downto 0);
        signal i2c_sda_out_tmp : std_ulogic;
        signal i2c_sda_xmit : std_ulogic;
        signal i2c_sda_setup_sync : std_ulogic;
        signal i2c_clk : std_ulogic := '0';
        signal addr_match : std_ulogic := '0';
        signal sda_falling : std_ulogic := '0';
        signal sda_rising : std_ulogic := '0';
        signal sda_changing : std_ulogic := '0';
        signal i2c_sda_setup_cnt : integer := 8;
        signal new_written_data : std_ulogic := '0';
        signal i2c_start : std_ulogic := '0';
        signal i2c_stop : std_ulogic := '0';
        type   i2c_fsm is (IDLE, HEADER, ACK_HEADER, RCV_DATA, ACK_DATA, XMIT_DATA, WAIT_ACK);
        signal i2c_state : i2c_fsm;
        signal i2c_addr : std_logic_vector(6 downto 0);
        signal i2c_header : std_logic_vector(7 downto 0) := (others => '0');
        signal sclk_falling_sync : std_ulogic;
        signal sclk_falling_sync_d1 : std_ulogic;
        signal sclk_falling_sync_d2 : std_ulogic;
        signal sclk_falling_sync_d3 : std_ulogic;
        signal sclk_rising_sync : std_ulogic;
        signal data_ff : std_logic_vector(15 downto 0) := (others => '0');
        signal addr_ff_int : integer;
        signal i2c_wr_dr_sram : std_ulogic := '0';

  
begin 

   -- I2C
   i2c_sclk_in <= I2C_SCLK;
   i2c_sda_in <= I2C_SDA;
   I2C_SCLK_TS <= i2c_sda_setup_sync;
   I2C_SDA_TS <=  i2c_sda_out_tmp;
  
   BUSY <= busy_out after 100 ps;
   DRDY <= drdy_out after 100 ps;
   EOC <= eoc_out after 100 ps;
   EOS <= eos_out after 100 ps;
   OT <= ot_out after 100 ps;
   DO <= do_out after 100 ps;
   CHANNEL <= channel_out after 100 ps;
   MUXADDR <= muxaddr_out after 100 ps;
   ALM <= alarm_out after 100 ps;

   dclk_in <= DCLK xor IS_DCLK_INVERTED;
   convstclk_in <= CONVSTCLK xor IS_CONVSTCLK_INVERTED;
   convst_raw_in <= CONVST;
   den_in <= DEN;
   rst_input <= RESET;
   dwe_in <= DWE;
   di_in <= Di;
   daddr_in <= DADDR;

   gsr_in <= TO_X01(GSR);
   convst_in_tmp <= '1' when (convst_raw_in = '1' or convstclk_in = '1') else  '0';
   JTAGLOCKED <= '0';
   JTAGMODIFIED <= '0';
   JTAGBUSY <= '0';

   convst_in_p : process( convst_in_tmp, rst_in)
   begin
     if (rst_in = '1' ) then
        convst_in <= '0';
     elsif (rising_edge(convst_in_tmp)) then
        if (rst_lock = '1') then
           convst_in <= '0';
        else
           convst_in <= '1';
        end if;
     elsif (falling_edge(convst_in_tmp)) then
           convst_in <= '0';
     end if;
   end process;

   DEFAULT_CHECK : process
       variable init40h_tmp : std_logic_vector(15 downto 0);
       variable init41h_tmp : std_logic_vector(15 downto 0);
       variable init42h_tmp : std_logic_vector(15 downto 0);
       variable init4eh_tmp : std_logic_vector(15 downto 0);
       variable init40h_tmp_chan : integer;
       variable init42h_tmp_clk : integer;
       variable tmp_value : std_logic_vector(7 downto 0);
   begin

        init40h_tmp := TO_STDLOGICVECTOR(INIT_40);
        init40h_tmp_chan := SLV_TO_INT(SLV=>init40h_tmp(5 downto 0));
        init41h_tmp := TO_STDLOGICVECTOR(INIT_41);
        init42h_tmp := TO_STDLOGICVECTOR(INIT_42);
        tmp_value :=  init42h_tmp(15 downto 8);
        init42h_tmp_clk := SLV_TO_INT(SLV=>tmp_value);
        init4eh_tmp := TO_STDLOGICVECTOR(INIT_4E);
 
        if ((init41h_tmp(15 downto 12)="0011") and (init40h_tmp(8)='1') and (init40h_tmp_chan /= 3 ) and (init40h_tmp_chan < 16)) then
          assert false report " Attribute Syntax warning : The attribute INIT_40 bit[8] must be set to 0 on SYSMONE1. Long acquistion mode is only allowed for external channels."
          severity warning;
        end if;

        if ((init41h_tmp(15 downto 12) /="0011") and (init4eh_tmp(10 downto 0) /= "00000000000") and (init4eh_tmp(15 downto 12) /= "0000")) then
           assert false report " Attribute Syntax warning : The attribute INIT_4E Bit[15:12] and bit[10:0] must be set to 0. Long acquistion mode is only allowed for external channels."
          severity warning;
        end if;

        if ((init41h_tmp(15 downto 12)="0011") and (init40h_tmp(13 downto 12) /= "00") and (INIT_48 /=X"0000") and (INIT_49 /= X"0000")) then
           assert false report " Attribute Syntax warning : The attribute INIT_48 and INIT_49 must be set to 0000h in single channel mode and averaging enabled."
          severity warning;
        end if;

        if (init42h_tmp(1 downto 0) /= "00") then
             assert false report
             " Attribute Syntax Error : The attribute INIT_42 Bit[1:0] must be set to 00."
              severity Error;
        end if;

        if (INIT_45 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_45 must   be set to 0000."
             severity warning;
        end if;

        if (not(IS_DCLK_INVERTED = '0' or IS_DCLK_INVERTED = '1')) then
          assert false report " Attribute Syntax Error : The attribute IS_DCLK_INVERTED must be set to 0 or 1."
            severity failure;
        end if;

        
        if (not(IS_CONVSTCLK_INVERTED = '0' or IS_CONVSTCLK_INVERTED = '1')) then
          assert false report " Attribute Syntax Error : The attribute IS_CONVSTCLK_INVERTED must be set to 0 or 1."
            severity failure;
        end if;

        
        wait;
   end process;


   curr_chan_index <= SLV_TO_INT(curr_chan);
   curr_chan_index_lat <= SLV_TO_INT(curr_chan_lat);

   
  CHEK_COMM_P : process( busy_r )
       variable Message : line;
  begin 
  if (busy_r'event and busy_r = '1' ) then
   if (rst_in = '0' and acq_b_u = '0' and ((acq_chan_index = 3) or (acq_chan_index >= 16 and acq_chan_index <= 31))) then
      if ( chan_valn_tmp(acq_chan_index) > chan_val_tmp(acq_chan_index)) then
       Write ( Message, string'("Input File Warning: The N input for external channel "));
       Write ( Message, acq_chan_index);
       Write ( Message, string'(" must be smaller than P input when in unipolar mode (P="));
       Write ( Message, chan_val_tmp(acq_chan_index));
       Write ( Message, string'(" N="));
       Write ( Message, chan_valn_tmp(acq_chan_index));
       Write ( Message, string'(") for SYSMONE1."));
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;

     if (( chan_valn_tmp(acq_chan_index) > 0.5) or  (chan_valn_tmp(acq_chan_index) < 0.0)) then
       Write ( Message, string'("Input File Warning: The N input for external channel "));
       Write ( Message, acq_chan_index);
       Write ( Message, string'(" should be between 0V to 0.5V when in unipolar mode (N="));
       Write ( Message, chan_valn_tmp(acq_chan_index));
      Write ( Message, string'(") for SYSMONE1."));
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;

   end if;
  end if;
  end process;

  busy_mkup_p : process( dclk_in, rst_in_out)
  begin
    if (rst_in_out = '1') then
       busy_rst <= '1';
       rst_lock <= '1';
       rst_lock_early <= '1';
       rst_lock_late  <= '1';
       busy_rst_cnt <= 0;
    elsif (rising_edge(dclk_in)) then
       if (rst_lock = '1') then
          if (busy_rst_cnt < 29) then
               busy_rst_cnt <= busy_rst_cnt + 1;
               if ( busy_rst_cnt = 26) then
                    rst_lock_early <= '0';
               end if;
          else
               busy_rst <= '0';
               rst_lock <= '0';
          end if;
       end if;
       if (busy_out = '0') then
          rst_lock_late <= '0';
       end if;
    end if;
  end process;

  busy_out_p : process (busy_rst, busy_conv, rst_lock)
  begin
     if (rst_lock = '1') then
         busy_out <= busy_rst;
     else
         busy_out <= busy_conv;
     end if;
  end process;      

  busy_conv_p : process (dclk_in, rst_in)
  begin
    if (rst_in = '1') then
       busy_conv <= '0';
       cal_chan_update <= '0';
    elsif (rising_edge(dclk_in)) then
        if (seq_reset_flag = '1'  and curr_clkdiv_sel_int <= 3)  then
             busy_conv <= busy_seq_rst;
        elsif (busy_sync_fall = '1') then
            busy_conv <= '0';
        elsif (busy_sync_rise = '1') then
            busy_conv <= '1';
        end if;

        if (conv_count = 21 and curr_chan = "01000" ) then
              cal_chan_update  <= '1';
         else
              cal_chan_update  <= '0';
         end if;
    end if;
  end process;

  busy_sync_p : process (dclk_in, rst_lock)
  begin
     if (rst_lock = '1') then 
        busy_sync1 <= '0';
        busy_sync2 <= '0';
     elsif (rising_edge (dclk_in)) then 
         busy_sync1 <= busy_r;
         busy_sync2 <= busy_sync1;
     end if;
  end process;

  busy_sync_fall <= '1' when (busy_r = '0' and busy_sync1 = '1') else '0';
  busy_sync_rise <= '1' when (busy_sync1 = '1' and busy_sync2 = '0') else '0';

  busy_seq_rst_p : process
    variable tmp_uns_div : unsigned(7 downto 0);
  begin
     if (falling_edge(busy_out) or rising_edge(busy_r)) then
        if (seq_reset_flag = '1' and seq1_0 = "0000" and curr_clkdiv_sel_int <= 3) then
           wait until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           busy_seq_rst <= '1';
        elsif (seq_reset_flag = '1' and seq1_0 /= "0000" and curr_clkdiv_sel_int <= 3) then
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
           busy_seq_rst <= '1';
        else
           busy_seq_rst <= '0';
        end if;
     end if;
    wait on busy_out, busy_r;
   end process;

  muxaddr_out_p : process 
  begin
    if (rst_in_out = '1') then
      muxaddr_out <= "00000";
    elsif (rst_lock_early = '0' and rst_lock_late = '1' ) then
      muxaddr_out <= muxaddr_o;
    elsif (rising_edge(busy_out)) then
      wait until falling_edge(adcclk);
      wait until falling_edge(adcclk);
      wait until falling_edge(adcclk);
      wait until falling_edge(adcclk);
      wait until falling_edge(adcclk);
      wait until falling_edge(adcclk);
      wait until falling_edge(adcclk);
      wait until falling_edge(adcclk);
      muxaddr_out <= muxaddr_o;
    end if;
    wait on busy_out, rst_in_out, rst_lock_early;
  end process;


  chan_out_p : process(busy_out, rst_in_out, cal_chan_update)
  begin
   if (rst_in_out = '1' or rst_lock_late = '1') then
         channel_out <= "000000";
   elsif (rising_edge(busy_out) or rising_edge(cal_chan_update)) then
           if ( busy_out = '1' and cal_chan_update = '1') then
                channel_out <= "001000";
           end if;
   elsif (falling_edge(busy_out)) then
         if ((curr_seq1_0_lat(3 downto 2) /= "10" and sysmone12_en = '0') or sysmone12_en = '1') then
           channel_out <= curr_chan;
         else
           channel_out <= "000000";
         end if;
          curr_chan_lat <= curr_chan;
   end if;
  end process;

--CR 675227
   halt_adc_p : process
   begin
     if (rst_input = '1') then
       halt_adc <= 0;
     elsif (trig_halt_adc'event) then
       halt_adc <= halt_adc + 1;
     end if;

     
     if (halt_adc = 2 and seq1_0 = "0001") then
       halt_adc <= 0;
       int_rst_halt_adc <= '1';
       wait until (rising_edge(dclk_in));
       int_rst_halt_adc <= '0';
     end if;

     wait on rst_input, seq1_0, dclk_in, trig_halt_adc;
     
   end process;
       
   
  INT_RST_GEN_P : process
  begin
    int_rst <= '1';
    wait until (rising_edge(dclk_in));
    wait until (rising_edge(dclk_in));
    int_rst <= '0';
    wait;
  end process;

--CR 675227   
   rst_input_t <= int_rst_halt_adc or rst_input or int_rst or soft_reset after 1 ps;
--  rst_input_t <= rst_input or int_rst or soft_reset after 1 ps;


  RST_DE_SYNC_V6_P: process(adcclk, rst_input_t)
  begin
      if (rst_input_t = '1') then
              rst_in2_tmp6 <= '1';
              rst_in1_tmp6 <= '1';
      elsif (adcclk'event and adcclk='1') then
              rst_in2_tmp6 <= rst_in1_tmp6;
              rst_in1_tmp6 <= rst_input_t;
      end if;
  end process;

    rst_in2 <= rst_in2_tmp6;
    rst_in_not_seq <= rst_in2;
    rst_in <= rst_in2 or seq_reset_dly;
    rst_in_out <= rst_in2 or seq_reset_busy_out;

  seq_reset_dly_p : process
  begin
   if (rising_edge(seq_reset)) then
    wait until rising_edge(dclk_in);
    wait until rising_edge(dclk_in);
       seq_reset_dly <= '1';
    wait until rising_edge(dclk_in);
    wait until falling_edge(dclk_in);
       seq_reset_busy_out <= '1';
    wait until rising_edge(dclk_in);
    wait until rising_edge(dclk_in);
    wait until rising_edge(dclk_in);
       seq_reset_dly <= '0';
       seq_reset_busy_out <= '0';
   end if;
    wait on seq_reset, dclk_in;
  end process;


  seq_reset_flag_p : process (seq_reset_dly, busy_r)
    begin
       if (rising_edge(seq_reset_dly)) then
          seq_reset_flag <= '1';
       elsif (rising_edge(busy_r)) then
          seq_reset_flag <= '0';
       end if;
    end process;

  seq_reset_flag_dly_p : process (seq_reset_flag, busy_out)
    begin
       if (rising_edge(seq_reset_flag)) then
          seq_reset_flag_dly <= '1';
       elsif (rising_edge(busy_out)) then
           seq_reset_flag_dly <= '0';
       end if;
    end process;

  first_cal_chan_p : process ( busy_out)
    begin
      if (rising_edge(busy_out )) then
          if (seq_reset_flag_dly = '1' and  acq_chan = "001000" and seq1_0 = "0000") then
                  first_cal_chan <= '1';
          else 
                  first_cal_chan <= '0';
          end if;
      end if;
    end process;


  ADC_SM: process (adcclk, rst_in, sim_file_flag)
  begin
--CR 675227
   if (not(halt_adc = 2 and seq1_0 = "0011")) then
    if (sim_file_flag = '1') then
        adc_state <= S1_ST;
     elsif (rst_in = '1' or rst_lock_early = '1') then
        adc_state <= S1_ST;
     elsif (adcclk'event and adcclk = '1') then
         adc_state <= next_state;
     end if;
    end if;
  end process;

  next_state_p : process (adc_state, eos_en, conv_start , conv_end, curr_seq1_0_lat)
  begin
      case (adc_state) is
      when S1_ST => next_state <= S2_ST;

      when  S2_ST => if (conv_start = '1') then
                                  next_state <= S3_ST;
                              else
                                  next_state <= S2_ST;
                              end if;

      when  S3_ST => if (conv_end = '1') then
                                   next_state <= S5_ST;
                               else
                                   next_state <= S3_ST;
                                end if;

      when  S5_ST => if (curr_seq1_0_lat = "0001")  then

--CR 675227			if (eos_en = '1') then
                                if (eos_tmp_en = '1') then                   
                                    next_state <= S6_ST;
                                else
                                    next_state <= S2_ST;
                                end if;
                            else
                                next_state <= S2_ST;
                            end if;

      when  S6_ST => next_state <= S1_ST;

      when  others => next_state <= S1_ST;
    end case;
  end process;

  seq_en_init_p : process
  begin
      seq_en_init <= '0';
      if (cfg_reg1_init(15 downto 12) /= "0011" ) then
          wait for 20 ps;
          seq_en_init <= '1';
          wait for 150 ps;
          seq_en_init <= '0';
      end if;
      wait;
  end process;

  
      seq_en <= seq_en_init or  seq_en_drp;

  drdy_out_p : process
  begin
    if (gsr_in = '1') then
         drdy_out <= '0';
    elsif (rising_edge(drdy_out_tmp3)) then
      wait until rising_edge(dclk_in);
         drdy_out  <= '1';
      wait until rising_edge(dclk_in);
         drdy_out <= '0';
    end if;
    wait on drdy_out_tmp3, gsr_in;
  end process;


  DRPORT_DO_OUT_P : process(dclk_in, gsr_in, trig_halt_adc_dr_sram, eoc_out_t, rst_in_not_seq, i2c_wr_dr_sram)
       variable message : line;
       variable di_str : string (16 downto 1);
       variable daddr_str : string (7 downto  1);
       variable valid_daddr : boolean := false;
       variable address : integer := 0;
       variable tmp_value : integer := 0;
       variable tmp_value1 : std_logic_vector (7 downto 0);
       variable en_data_flag : integer := 0;
       variable init53h_tmp : std_logic_vector (15 downto 0);
       variable first_time : boolean := true;
       variable tmp_uns1 : unsigned(15 downto 0);
       variable tmp_uns2 : unsigned(15 downto 0);
       variable tmp_uns3 : unsigned(15 downto 0);
       
  begin
    if (first_time = true) then

          dr_sram(64) <= TO_STDLOGICVECTOR(INIT_40);
          dr_sram(65) <= TO_STDLOGICVECTOR(INIT_41);
          dr_sram(66) <= TO_STDLOGICVECTOR(INIT_42);
          dr_sram(67) <= TO_STDLOGICVECTOR(INIT_43);
          dr_sram(68) <= TO_STDLOGICVECTOR(INIT_44);
          dr_sram(69) <= TO_STDLOGICVECTOR(INIT_45);
          dr_sram(70) <= TO_STDLOGICVECTOR(INIT_46);
          dr_sram(71) <= TO_STDLOGICVECTOR(INIT_47);
          dr_sram(72) <= TO_STDLOGICVECTOR(INIT_48);
          dr_sram(73) <= TO_STDLOGICVECTOR(INIT_49);
          dr_sram(74) <= TO_STDLOGICVECTOR(INIT_4A);
          dr_sram(75) <= TO_STDLOGICVECTOR(INIT_4B);
          dr_sram(76) <= TO_STDLOGICVECTOR(INIT_4C);
          dr_sram(77) <= TO_STDLOGICVECTOR(INIT_4D);
          dr_sram(78) <= TO_STDLOGICVECTOR(INIT_4E);
          dr_sram(79) <= TO_STDLOGICVECTOR(INIT_4F);
          dr_sram(80) <= TO_STDLOGICVECTOR(INIT_50);
          dr_sram(81) <= TO_STDLOGICVECTOR(INIT_51);
          dr_sram(82) <= TO_STDLOGICVECTOR(INIT_52);
          init53h_tmp := TO_STDLOGICVECTOR(INIT_53);
          if (init53h_tmp(3 downto 0)="0011")  then
             dr_sram(83) <= init53h_tmp;
             ot_limit_reg  <= init53h_tmp;
          else
            dr_sram(83) <= X"CA30";
            ot_limit_reg  <= X"CA30";
          end if;
          dr_sram(84) <= TO_STDLOGICVECTOR(INIT_54);
          dr_sram(85) <= TO_STDLOGICVECTOR(INIT_55);
          dr_sram(86) <= TO_STDLOGICVECTOR(INIT_56);
          dr_sram(87) <= TO_STDLOGICVECTOR(INIT_57);
          dr_sram(88) <= TO_STDLOGICVECTOR(INIT_58);
          dr_sram(89) <= TO_STDLOGICVECTOR(INIT_59);
          dr_sram(90) <= TO_STDLOGICVECTOR(INIT_5A);
          dr_sram(91) <= TO_STDLOGICVECTOR(INIT_5B);
          dr_sram(92) <= TO_STDLOGICVECTOR(INIT_5C);
          dr_sram(93) <= TO_STDLOGICVECTOR(INIT_5D);
          dr_sram(94) <= TO_STDLOGICVECTOR(INIT_5E);
          dr_sram(95) <= TO_STDLOGICVECTOR(INIT_5F);
          dr_sram(96) <= TO_STDLOGICVECTOR(INIT_60);
          dr_sram(97) <= TO_STDLOGICVECTOR(INIT_61);
          dr_sram(98) <= TO_STDLOGICVECTOR(INIT_62);
          dr_sram(99) <= TO_STDLOGICVECTOR(INIT_63);
          dr_sram(104) <= TO_STDLOGICVECTOR(INIT_68);
          dr_sram(105) <= TO_STDLOGICVECTOR(INIT_69);
          dr_sram(106) <= TO_STDLOGICVECTOR(INIT_6A);
          dr_sram(107) <= TO_STDLOGICVECTOR(INIT_6B);
          dr_sram(120) <= TO_STDLOGICVECTOR(INIT_78);
          dr_sram(121) <= TO_STDLOGICVECTOR(INIT_79);
        first_time := false;
      end if;


        if (rst_in_not_seq = '1' and rst_in_not_seq'event) then
            for k in  32 to  39 loop
                if (k >= 36) then
                    data_reg(k) <= "1111111111111111";
                else
                    data_reg(k) <= "0000000000000000";
                end if;
            end loop;
            data_reg(40) <= "0000000000000000";
            data_reg(41) <= "0000000000000000";
            data_reg(42) <= "0000000000000000";
            data_reg(44) <= "1111111111111111";
            data_reg(45) <= "1111111111111111";
            data_reg(46) <= "1111111111111111";
            dr_sram(160) <= "0000000000000000";
            dr_sram(161) <= "0000000000000000";
            dr_sram(162) <= "0000000000000000";
            dr_sram(163) <= "0000000000000000";
            dr_sram(168) <= "1111111111111111";
            dr_sram(169) <= "1111111111111111";
            dr_sram(170) <= "1111111111111111";
            dr_sram(171) <= "1111111111111111";
        elsif (rising_edge(eoc_out_t)) then
            if ( rst_lock = '0') then
              if (eoc_out = '1') then
                if ((curr_chan_index_lat >= 0 and curr_chan_index_lat <= 3) or 
                    curr_chan_index_lat = 6 or 
                   (curr_chan_index_lat >= 13 and curr_chan_index_lat <= 31)) then
                    if (curr_pj_set = "00") then
                        data_reg(curr_chan_index_lat) <= conv_result_reg;
                    else
                        data_reg(curr_chan_index_lat) <= conv_acc_result;
                    end if;
                end if;

                if (curr_chan_index_lat = 32) then
                    if (curr_pj_set = "00") then
                        dr_sram(128) <= conv_result_reg;
                    else
                        dr_sram(128) <= conv_acc_result;
                    end if;
                end if;
                
               if (curr_chan_index_lat = 33) then
                    if (curr_pj_set = "00") then
                        dr_sram(129) <= conv_result_reg;
                    else
                        dr_sram(129) <= conv_acc_result;
                    end if;
                end if;

               if (curr_chan_index_lat = 34) then
                    if (curr_pj_set = "00") then
                        dr_sram(130) <= conv_result_reg;
                    else
                        dr_sram(130) <= conv_acc_result;
                    end if;
                end if;

               if (curr_chan_index_lat = 35) then
                    if (curr_pj_set = "00") then
                        dr_sram(131) <= conv_result_reg;
                    else
                        dr_sram(131) <= conv_acc_result;
                    end if;
                end if;

                if (curr_chan_index_lat = 4) then
                    data_reg(curr_chan_index_lat) <= X"D555";
                end if;
                if (curr_chan_index_lat = 5) then
                    data_reg(curr_chan_index_lat) <= X"0000";
                end if;
                
                if (curr_chan_index_lat = 0 or curr_chan_index_lat = 1 or curr_chan_index_lat = 2) then
                    tmp_uns2 := UNSIGNED(data_reg(32 + curr_chan_index_lat));
                    tmp_uns3 := UNSIGNED(data_reg(36 + curr_chan_index_lat));
                    if (curr_pj_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(32 + curr_chan_index_lat) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(36 + curr_chan_index_lat) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(32 + curr_chan_index_lat) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(36 + curr_chan_index_lat) <= conv_acc_result;
                        end if;
                    end if;
                end if;

                if (curr_chan_index_lat = 6) then
                    tmp_uns2 := UNSIGNED(data_reg(35));
                    tmp_uns3 := UNSIGNED(data_reg(39));
                    if (curr_pj_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(35) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(39) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(35) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(39) <= conv_acc_result;
                        end if;
                    end if;
                end if;

                if (curr_chan_index_lat = 13) then
                    tmp_uns2 := UNSIGNED(data_reg(40));
                    tmp_uns3 := UNSIGNED(data_reg(44));
                    if (curr_pj_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(40) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(44) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(40) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(44) <= conv_acc_result;
                        end if;
                    end if;
                end if;

                if (curr_chan_index_lat = 14) then
                    tmp_uns2 := UNSIGNED(data_reg(41));
                    tmp_uns3 := UNSIGNED(data_reg(45));
                    if (curr_pj_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(41) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(45) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(41) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(45) <= conv_acc_result;
                        end if;
                    end if;
                end if;
                if (curr_chan_index_lat = 15) then
                    tmp_uns2 := UNSIGNED(data_reg(42));
                    tmp_uns3 := UNSIGNED(data_reg(46));
                    if (curr_pj_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(42) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(46) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(42) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(46) <= conv_acc_result;
                        end if;
                    end if;
                end if;

                if (curr_chan_index_lat = 32) then  -- Vuser0
                    tmp_uns2 := UNSIGNED(dr_sram(160));
                    tmp_uns3 := UNSIGNED(dr_sram(168));
                    if (curr_pj_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            dr_sram(160) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            dr_sram(168) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            dr_sram(160) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            dr_sram(168) <= conv_acc_result;
                        end if;
                    end if;
                end if;

                if (curr_chan_index_lat = 33) then  -- Vuser1
                    tmp_uns2 := UNSIGNED(dr_sram(161));
                    tmp_uns3 := UNSIGNED(dr_sram(169));
                    if (curr_pj_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            dr_sram(161) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            dr_sram(169) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            dr_sram(161) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            dr_sram(169) <= conv_acc_result;
                        end if;
                    end if;
                end if;

                if (curr_chan_index_lat = 34) then  -- Vuser2
                    tmp_uns2 := UNSIGNED(dr_sram(162));
                    tmp_uns3 := UNSIGNED(dr_sram(170));
                    if (curr_pj_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            dr_sram(162) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            dr_sram(170) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            dr_sram(162) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            dr_sram(170) <= conv_acc_result;
                        end if;
                    end if;
                end if;

                if (curr_chan_index_lat = 35) then  -- Vuser3
                    tmp_uns2 := UNSIGNED(dr_sram(163));
                    tmp_uns3 := UNSIGNED(dr_sram(171));
                    if (curr_pj_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            dr_sram(163) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            dr_sram(171) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            dr_sram(163) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            dr_sram(171) <= conv_acc_result;
                        end if;
                    end if;
                end if;
                
              end if;

           end if;
       end if;

   
--CR 675227
      if (trig_halt_adc_dr_sram'event) then
        dr_sram(65)(15 downto 12) <= "0011";
      end if;
      
     if (gsr_in = '1') then 
         daddr_in_lat  <= "00000000";
         do_out <= "0000000000000000";
     elsif (rising_edge(dclk_in)) then
       if (den_in = '1') then
         if (drdy_out_tmp1 = '0') then
             drdy_out_tmp1 <= '1';
             en_data_flag := 1;
             daddr_in_lat  <= daddr_in;
          else 
            if (daddr_in /= daddr_in_lat) then
              Write ( Message, string'(" Warning : input pin DEN on SYSMONE1 can not continue set to high. Need wait DRDY high and then set DEN high again."));
              assert false report Message.all  severity warning;
              DEALLOCATE(Message);
            end if;
          end if;
        else
           drdy_out_tmp1 <= '0';
        end if;
        
        drdy_out_tmp2 <= drdy_out_tmp1;
        drdy_out_tmp3 <= drdy_out_tmp2;
        drdy_out_tmp4 <= drdy_out_tmp3;

        if (drdy_out_tmp1 = '1') then
            en_data_flag := 0;
        end if;

        if (drdy_out_tmp3 = '1') then
            do_out <= do_out_rdtmp;
        end if;
 
        if (den_in = '1') then
           valid_daddr := addr_is_valid(daddr_in);
           if (valid_daddr) then
               address := slv_to_int(daddr_in);
               if (address > 173 or (address > 165 and address < 168) or (address > 133 and address < 160) or (address > 121 and address < 128) or (address > 117 and address < 120) or (address > 109 and address < 115) or (address > 101 and address < 104) or (address > 46 and address < 60) or (address > 50 and address < 56) or address = 43 or address = 47) then
                 Write ( Message, string'(" Invalid Input Warning : The DADDR "));
                 Write ( Message, string'(SLV_TO_STR(daddr_in)));
                 Write ( Message, string'("  is not defined. The data in this location is invalid."));
                 assert false report Message.all  severity warning;
                 DEALLOCATE(Message);
                 end if;
            end if;
         end if;


-- write  all available daddr addresses

        if (dwe_in = '1' and en_data_flag = 1) then  
           if (valid_daddr and address >= 64 and address <= 95) then
               dr_sram(address) <= di_in;
           end if;

            if (address = 3) then
                 soft_reset <= '1';
            end if;
            if ( address = 83) then
                 if (di_in(3 downto 0) = "0011") then
                    ot_limit_reg(15 downto 4)  <= di_in(15 downto 4);
                 end if;
             end if;

            if ( address = 66 and  di_in( 2 downto 0) /= "000") then
             Write ( Message, string'(" Invalid Input Error : The DI bit[2:0] "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in(2 downto 0))));
             Write ( Message, string'("  at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" of SYSMONE1 is invalid. These must be set to 000."));
             assert false report Message.all  severity error;
           end if;

           tmp_value1 := di_in(15 downto 8) ; 
           tmp_value := SLV_TO_INT(SLV=>tmp_value1);


           if ( (address >= 115 and address <= 117) and di_in(15 downto 0) /= "0000000000000000") then
             Write ( Message, string'(" Invalid Input Error : The DI value "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in)));
             Write ( Message, string'("  at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" of SYSMONE1 is invalid. These must be set to 0000."));
             assert false report Message.all  severity error;
             DEALLOCATE(Message);
           end if;

          tmp_value := SLV_TO_INT(SLV=>di_in(5 downto 0));
      
          if (address = 64) then

           if ((( tmp_value = 7) or ((tmp_value >= 10) and (tmp_value <= 15)))) then
             Write ( Message, string'(" Invalid Input Warning : The DI bit[5:0] at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" is  "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in(7 downto 0))));
             Write ( Message, string'(", which is invalid analog channel."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((cfg_reg1(15 downto 12)="0011") and (di_in(8)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The DI value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in)));
             Write ( Message, string'(" at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(". Bit[8] of DI must be set to 0. Long acquistion mode is only allowed for external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

--           if ((cfg_reg1(15 downto 12)="0011") and (di_in(9)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
--             Write ( Message, string'(" Invalid Input Warning : The DI value is "));
--             Write ( Message, bit_vector'(TO_BITVECTOR(di_in)));
--             Write ( Message, string'(" at DADDR "));
--             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
--             Write ( Message, string'(". Bit[9] of DI must be set to 0. Event mode timing can only be used with external channels."));
--             assert false report Message.all  severity warning;
--             DEALLOCATE(Message);
--           end if;

           if ((cfg_reg1(15 downto 12)="0011") and (di_in(13 downto 12)/="00") and (seq_chan_reg1 /= X"0000") and (seq_chan_reg2 /= X"0000") and (seq_chan_reg3 /= X"0000")) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 46h, 48h and 49h are "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg3)));
             Write ( Message, string'(",  "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg1)));
             Write ( Message, string'(" and  "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg2)));
             Write ( Message, string'(". Those registers should be set to 0000h in single channel mode and averaging enabled."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;
        end if;

          tmp_value := SLV_TO_INT(SLV=>cfg_reg0(5 downto 0));

          if (address = 65 and en_data_flag = 1) then

           if ((di_in(15 downto 12)="0011") and (cfg_reg0(8)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 40h value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(cfg_reg0)));
             Write ( Message, string'(". Bit[8] of Control Regiter 40h must be set to 0. Long acquistion mode is only allowed for external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

--           if ((di_in(15 downto 12)="0011") and (cfg_reg0(9)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
--             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 40h value is "));
--             Write ( Message, bit_vector'(TO_BITVECTOR(cfg_reg0)));
--             Write ( Message, string'(". Bit[9] of Control Regiter 40h must be set to 0. Event mode timing can only be used with external channels."));
--             assert false report Message.all  severity warning;
--             DEALLOCATE(Message);
--           end if;

           if ((di_in(15 downto 12) /= "0011") and (seq_acq_reg1(10 downto 0) /= "00000000000") and (seq_acq_reg1(15 downto 12) /= "0000")) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 4Eh is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_acq_reg1)));
             Write ( Message, string'(". Bit[15:12] and bit[10:0] of this register must be set to 0. Long acquistion mode is only allowed for external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((di_in(15 downto 12) = "0011") and (cfg_reg0(13 downto 12) /= "00") and (seq_chan_reg1 /= X"0000") and (seq_chan_reg2 /= X"0000") and (seq_chan_reg3 /= X"0000")) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 46h, 48h and 49h are "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg3)));
             Write ( Message, string'(",  "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg1)));
             Write ( Message, string'(" and  "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg2)));
             Write ( Message, string'(". Those registers should be set to 0000h in single channel mode and averaging enabled."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;
        end if;
       end if;



        if (daddr_in = "1000001"  and en_data_flag = 1) then
           if (dwe_in = '1' and den_in = '1') then

                if (di_in(15 downto 12) /= cfg_reg1(15 downto 12)) then
                            seq_reset <= '1';
                else
                            seq_reset <= '0';
                end if;

                if (di_in(15 downto 12) /= "0011" ) then
                            seq_en_drp <= '1';
                else
                            seq_en_drp <= '0';
                end if;
             else  
                        seq_reset <= '0';
                        seq_en_drp <= '0';
             end if;
        end if;
        if (soft_reset = '1') then
           soft_reset <= '0';
        end if;
        if (seq_en_drp = '1') then
            seq_en_drp <= '0';
        end if;
        if (seq_reset = '1') then
            seq_reset <= '0';
        end if;
     end if;


-- i2c write dr_sram
  if (i2c_wr_dr_sram = '1') then
    dr_sram(addr_ff_int) <= data_ff;
  end if;
  
  
  end process;

  tmp_dr_sram_out <= dr_sram(daddr_in_lat_int) when (daddr_in_lat_int >= 64 and
                daddr_in_lat_int <= 173) else "0000000000000000";

  flag_reg0 <= ("00000000" & alarm_out(6 downto 3) & ot_out & alarm_out(2 downto 0));
  flag_reg1 <= ("0000000000" & alarm_out(13 downto 8));
  

  tmp_data_reg_out <= data_reg(daddr_in_lat_int) when (daddr_in_lat_int >= 0 and
                daddr_in_lat_int <= 46) else "0000000000000000";

  do_out_rdtmp_p : process( daddr_in_lat, tmp_data_reg_out, tmp_dr_sram_out,
                            flag_reg0, flag_reg1 ) 
      variable Message : line;
      variable valid_daddr : boolean := false;
  begin
           valid_daddr := addr_is_valid(daddr_in_lat);
           daddr_in_lat_int <= slv_to_int(daddr_in_lat);
           if (valid_daddr) then
              if ((daddr_in_lat_int > 173) or 
                     (daddr_in_lat_int >= 134  and daddr_in_lat_int < 160)) then 
                    do_out_rdtmp <= "XXXXXXXXXXXXXXXX";
              end if;

              if (daddr_in_lat_int = 62) then
                   do_out_rdtmp <= flag_reg1;
              end if;
              
              if (daddr_in_lat_int = 63) then
                   do_out_rdtmp <= flag_reg0;
              end if;

              if ((daddr_in_lat_int >= 0 and   daddr_in_lat_int <= 61)) then

                   do_out_rdtmp <= tmp_data_reg_out;

               elsif (daddr_in_lat_int >= 64 and daddr_in_lat_int <= 173) then
 
                    do_out_rdtmp <= tmp_dr_sram_out;
             end if;
          end if;
   end process;

-- end DRP RAM


  cfg_reg0 <= dr_sram(64);
  cfg_reg1 <= dr_sram(65);
  cfg_reg2 <= dr_sram(66);
  cfg_reg3 <= dr_sram(67);
  seq_chan_reg1 <= dr_sram(72);
  seq_chan_reg2 <= dr_sram(73);
  seq_chan_reg3 <= dr_sram(70);
  seq_pj_reg1 <= dr_sram(74);
  seq_pj_reg2 <= dr_sram(75);
  seq_pj_reg3 <= dr_sram(71);
  seq_du_reg1 <= dr_sram(76);
  seq_du_reg2 <= dr_sram(77);
  seq_du_reg3 <= dr_sram(120);
  seq_acq_reg1 <= dr_sram(78);
  seq_acq_reg2 <= dr_sram(79);
  seq_acq_reg3 <= dr_sram(121);

  seq1_0 <= cfg_reg1(15 downto 12);
  ext_mux <= cfg_reg0(11);
  ext_mux_chan_idx <= SLV_TO_INT(cfg_reg0(4 downto 0));
--  ext_mux_chan2_idx <= 24 + SLV_TO_INT(cfg_reg0(2 downto 0));

  drp_update_p : process 
    variable seq_bits : std_logic_vector( 3 downto 0);
   begin
    if (rst_in = '1') then
       wait until (rising_edge(dclk_in));
       wait until (rising_edge(dclk_in));
           seq_bits := seq1_0;
    elsif (rising_edge(drp_update)) then
       seq_bits := curr_seq1_0;
    end if;

    if (rising_edge(drp_update) or (rst_in = '1')) then
       if (seq_bits = "0000") then 
         alarm_en <= "0000000000000000";
         ot_en <= '1';
       else 
         ot_en  <= not cfg_reg1(0);
         alarm_en(2 downto 0) <= not cfg_reg1(3 downto 1);
         alarm_en(6 downto 3) <= not cfg_reg1(11 downto 8);
       end if;
    end if;
      wait on drp_update, rst_in;
   end process;


-------------------------------------------------------------------------------
-- i2c start
-------------------------------------------------------------------------------

    i2c_clk_p : process
    begin
      wait for 10000 ps;
      i2c_clk <= not i2c_clk;
    end process;

 

   i2c_reg_input_p : process (i2c_clk, rst_input)
     begin

       if (rst_input = '1') then
         i2c_sda_in_sync <= '0';
         i2c_sda_in_sync_d1 <= '0';
         i2c_sda_in_sync_d2 <= '0';
         i2c_sclk_in_sync <= '0';
         i2c_sclk_in_sync_d1 <= '0';
         i2c_sclk_in_sync_d2 <= '0';
       elsif (rising_edge(i2c_clk)) then
         i2c_sda_in_sync <= i2c_sda_in;
         i2c_sda_in_sync_d1 <= i2c_sda_in_sync;
         i2c_sda_in_sync_d2 <= i2c_sda_in_sync_d1;
         i2c_sclk_in_sync <= i2c_sclk_in;
         i2c_sclk_in_sync_d1 <= i2c_sclk_in_sync;
         i2c_sclk_in_sync_d2 <= i2c_sclk_in_sync_d1;
       end if;

     end process;
     

     sda_falling <= i2c_sda_in_sync_d2 and (not i2c_sda_in_sync_d1);
     sda_rising <= (not i2c_sda_in_sync_d2) and i2c_sda_in_sync_d1;
     sda_changing <= sda_falling or sda_rising;

     
     -- detect i2c start
       i2c_det_start_p : process (i2c_clk, rst_input)
       begin

         if (rst_input = '1') then
           i2c_start <= '0';
         elsif (rising_edge(i2c_clk) and cfg_reg3(7) = '1') then
           if (i2c_state = HEADER) then
             i2c_start <= '0';
           else
             if(i2c_sda_in_sync_d2 = '1' and i2c_sda_in_sync_d1 ='0') then
               if(i2c_sclk_in_sync_d1 = '1' or i2c_sclk_in_sync_d1 = 'H') then
                 i2c_start <= '1';
               else
		 i2c_start <= '0';
               end if;
             end if;
           end if;
         end if;
         
       end process;
  
     
     -- detect i2c stop
       i2c_det_stop_p : process (i2c_clk, rst_input)
       begin

         if (rst_input = '1') then
           i2c_stop <= '0';
         elsif (rising_edge(i2c_clk) and cfg_reg3(7) = '1') then
           if((i2c_sda_in_sync_d2 = '0' or i2c_sda_in_sync_d2 = 'L') and i2c_sda_in_sync_d1 ='1') then
               if(i2c_sclk_in_sync_d1 = '1' or i2c_sclk_in_sync_d1 = 'H') then
                 i2c_stop <= '1';
               else
		 i2c_stop <= '0';
               end if;
           end if;
         end if;
         
       end process;


   i2c_reg_rf_p : process (i2c_clk, rst_input)
     begin

       if (rst_input = '1') then
	 sclk_falling_sync <= '0';
	 sclk_rising_sync <= '0';
       elsif (rising_edge(i2c_clk)) then
	 sclk_falling_sync <= i2c_sclk_in_sync_d2 and (not i2c_sclk_in_sync_d1);
	 sclk_falling_sync_d1 <= sclk_falling_sync;
	 sclk_falling_sync_d2 <= sclk_falling_sync_d1;
	 sclk_falling_sync_d3 <= sclk_falling_sync_d2;
	 sclk_rising_sync <= (not i2c_sclk_in_sync_d2) and i2c_sclk_in_sync_d1;
       end if;

     end process;

     
     i2c_det_ack_p : process (i2c_clk, rst_input)
       begin

         if (rst_input = '1') then
           detect_ack <= '0';
         elsif (rising_edge(i2c_clk)) then
           if (sclk_rising_sync = '1') then
             detect_ack <= i2c_sda_in_sync_d1;  -- 0 = ack, 1 nack
           end if;
         end if;

       end process;
       

     i2c_addr_map_p : process (cfg_reg3(15 downto 7), data_reg(3))
     begin
  
       if (cfg_reg3(7) = '1') then
	 if (cfg_reg3(15) = '1') then
	   i2c_addr <= cfg_reg3(14 downto 8);
	 else
	    case (data_reg(3)(15 downto 12)) is
	       when X"0" => i2c_addr <= "0110010";
	       when X"1" => i2c_addr <= "0001011";
	       when X"2" => i2c_addr <= "0010011";
	       when X"3" => i2c_addr <= "0011011";
	       when X"4" => i2c_addr <= "0100011";
	       when X"5" => i2c_addr <= "0101011";
	       when X"6" => i2c_addr <= "0110011";
	       when X"7" => i2c_addr <= "0111011";
	       when X"8" => i2c_addr <= "1000011";
	       when X"9" => i2c_addr <= "1001011";
	       when X"a" => i2c_addr <= "1010011";
	       when X"b" => i2c_addr <= "1011011";
	       when X"c" => i2c_addr <= "1100011";
	       when X"d" => i2c_addr <= "1101011";
	       when X"e" => i2c_addr <= "1110011";
	       when X"f" => i2c_addr <= "0111010";
               when others => i2c_addr <= "0000000";
            end case;
	 
         end if;
       end if;

     end process;
     

     i2c_fsm_p : process (i2c_clk, rst_input)
     begin

        if (rst_input = '1') then
          i2c_state <= IDLE;
        elsif (rising_edge(i2c_clk)) then
          if (sclk_falling_sync_d2 = '1') then

            case i2c_state is
            
              when IDLE => if (i2c_start = '1') then
                             i2c_state <= HEADER;
                           end if;   
              
              when HEADER => if (bit_cnt = 0) then
                               i2c_state <= ACK_HEADER;
                             end if;   

              when ACK_HEADER => if (detect_ack = '0' or detect_ack = 'L') then       -- Ack has been received
                                   if (addr_match = '1') then    -- If aas_ff is true then addressed as slave
                                     if (i2c_header(0) =  '0') then  -- Check i2c_header[0] to determine direction
                                       i2c_state <= RCV_DATA;              -- Receive Mode
                                     else
                                       i2c_state <= XMIT_DATA;             -- Transmit Mode  
                                     end if;
                                   end if;
                                  else
                                    i2c_state <= IDLE;
                                  end if; 
	   
              when RCV_DATA => if (i2c_start = '1') then
                                 i2c_state <= HEADER;
                               elsif (bit_cnt = 0) then
                                 i2c_state <= ACK_DATA;
                               end if; 

              when XMIT_DATA => if (i2c_start = '1') then
                                  i2c_state <= HEADER;
                                elsif (bit_cnt = 1) then   -- after transmitted 8 bit now wait for acknowledge
                                  i2c_state <= WAIT_ACK;
                                end if; 
                         
              when ACK_DATA => if (detect_ack = '0' or detect_ack = 'L') then
                                 i2c_state <= RCV_DATA;
                               else  -- NACK received
                                 i2c_state <= IDLE;
                               end if;   

              when WAIT_ACK => if(detect_ack = '0' or detect_ack = 'L') then  -- wait for acknowlege from master 0 ack, 1 nack
                                 i2c_state <= XMIT_DATA;
                               else
                                 i2c_state <= IDLE;
                               end if;  
                         
              when others => i2c_state <= IDLE;

            end case;
     
            if (i2c_stop = '1') then
              i2c_state <= IDLE;
            end if;

          end if;
          
        end if;

     end process;
       

     -- bit count from 8 to 1 -> bit 7 to bit 0
     i2c_bit_cnt_p : process (i2c_clk, rst_input)
       begin

         if ((rst_input = '1') or (i2c_state = IDLE) or (i2c_state = ACK_HEADER) or (i2c_state = ACK_DATA) or 
             (i2c_state = WAIT_ACK) or (i2c_start = '1')) then
           bit_cnt <= 8;
         elsif (rising_edge(i2c_clk) and ((i2c_state = HEADER and sclk_falling_sync = '1') or 
              (i2c_state = RCV_DATA  and sclk_falling_sync = '1') or 
              (i2c_state = XMIT_DATA and sclk_falling_sync_d2 = '1'))) then
           bit_cnt <= bit_cnt - 1;
         end if;

       end process;
       

     -- byte count
     i2c_byte_cnt_p : process (i2c_clk, rst_input)
       begin

         if ((rst_input = '1') or (i2c_state = IDLE) or (i2c_state = ACK_HEADER) or (i2c_start = '1')) then
           byte_cnt <= 0;
         elsif (rising_edge(i2c_clk) and ((i2c_state = RCV_DATA and sclk_falling_sync_d1 = '1' and byte_cnt <= 3 and bit_cnt = 0) or
                (i2c_state = XMIT_DATA and sclk_falling_sync_d1 = '1' and byte_cnt <= 1 and bit_cnt = 1))) then
                 byte_cnt <= byte_cnt + 1;
         end if;
      
       end process;
       

     i2c_header_p : process (i2c_clk)
       begin

         if (rst_input = '0' and rising_edge(i2c_clk)) then
               if (i2c_state = HEADER and sclk_rising_sync = '1'  and bit_cnt > 0) then
                 i2c_header <= i2c_header(6 downto 0) & i2c_sda_in_sync_d1;
               end if;
         end if;

       end process;
         
      
     -- matching I2C slave address from i2c_sda bus
     i2c_addr_match_p : process (i2c_header(7 downto 1), i2c_addr)
       begin

         if(i2c_header(7 downto 1) = i2c_addr(6 downto 0)) then
           addr_match <= '1';
         else
           addr_match <= '0'; 
         end if;

       end process;


     -- I2C Data recevie
     i2c_data_rcv_p : process (i2c_clk, rst_input)
       begin

         if (rst_input = '1') then
           i2c_data_in70 <= (others => '0');
           i2c_data_in158 <= (others => '0');
           i2c_data_in2316 <= (others => '0');
           i2c_data_in3124 <= (others => '0');
         elsif (rising_edge(i2c_clk)) then
           if (i2c_state = RCV_DATA and sclk_rising_sync = '1' and i2c_start = '0' and bit_cnt > 0) then
             if (byte_cnt = 0) then
               i2c_data_in70 <= i2c_data_in70(6 downto 0) & i2c_sda_in_sync_d1;
             elsif (byte_cnt = 1) then
               i2c_data_in158 <= i2c_data_in158(6 downto 0) & i2c_sda_in_sync_d1;
             elsif (byte_cnt = 2) then
               i2c_data_in2316 <= i2c_data_in2316(6 downto 0) & i2c_sda_in_sync_d1;
             elsif (byte_cnt = 3) then
               i2c_data_in3124 <= i2c_data_in3124(6 downto 0) & i2c_sda_in_sync_d1;
             end if;
           end if;
         end if;
         
       end process;
           

     i2c_data_rcv_conc_p : process (i2c_clk, rst_input)
       begin

         if (rst_input = '1') then
           i2c_data_in <= (others => '0');
         elsif (rising_edge(i2c_clk)) then
            if (bit_cnt = 0 and byte_cnt = 4) then
              i2c_data_in <= i2c_data_in3124 & i2c_data_in2316 & i2c_data_in158 & i2c_data_in70;
              new_written_data <= '1';
            else
              new_written_data <= '0';
            end if;
         end if;
         
       end process;

       
     -- Decode I2C incoming data
     i2c_data_rcv_decode_p : process (i2c_clk, rst_input)
       variable addr_ff : std_logic_vector(7 downto 0) := (others => '0');
       variable addr_ff_int_var : integer;
       variable den_ff_var : std_ulogic := '0';
       variable dwe_ff_var : std_ulogic := '0';
     begin

         if (rst_input = '1') then
           data_ff <= (others => '0');
           addr_ff := (others => '0');
           den_ff_var := '0';
           dwe_ff_var := '0';
         elsif (rising_edge(i2c_clk) and new_written_data = '1') then
           data_ff <= i2c_data_in(15 downto 0);
           addr_ff := i2c_data_in(23 downto 16);                 
           
           case (i2c_data_in(29 downto 26)) is
             when "0001" => den_ff_var := '1';
                            dwe_ff_var := '0';
             when "0010" => den_ff_var := '1';    
                            dwe_ff_var := '1';
             when others => den_ff_var := '0';
                            dwe_ff_var := '0';
           end case;

           addr_ff_int_var := slv_to_int(addr_ff);
           

           if (den_ff_var = '1' and  dwe_ff_var = '1') then        -- write
             if (addr_ff_int_var >= 64 and addr_ff <= 121) then
               i2c_wr_dr_sram <= '1';
             end if;
           elsif (den_ff_var = '1' and dwe_ff_var = '0') then    -- read
             if (addr_ff_int_var >= 64) then
               i2c_sda_out_70_tmp <= dr_sram(addr_ff_int_var)(7 downto 0);
               i2c_sda_out_158_tmp <= dr_sram(addr_ff_int_var)(15 downto 8);
             elsif (addr_ff_int_var < 64) then
               i2c_sda_out_70_tmp <= data_reg(addr_ff_int_var)(7 downto 0);
               i2c_sda_out_158_tmp <= data_reg(addr_ff_int_var)(15 downto 8);
             end if;  
           else
             i2c_wr_dr_sram <= '0';
           end if;
         end if;


       -- I2C Data transmit
       if (rising_edge(i2c_clk)) then

         if (i2c_state = XMIT_DATA and sclk_falling_sync_d3 = '1' and i2c_start = '0') then
           if (den_ff_var = '1' and dwe_ff_var = '0') then     -- read
	    if (byte_cnt = 0) then
              i2c_sda_xmit <= i2c_sda_out_70_tmp(7);
	       i2c_sda_out_70_tmp <= i2c_sda_out_70_tmp(6 downto 0) & '0';
	    elsif (byte_cnt = 1) then
              i2c_sda_xmit <= i2c_sda_out_158_tmp(7);
	       i2c_sda_out_158_tmp <= i2c_sda_out_158_tmp(6 downto 0) & '0';
	    end if;
           end if;
         end if;
       end if;

     addr_ff_int <= addr_ff_int_var;
         
    end process;


    -- clock stretching
    i2c_clk_stretch_p : process (i2c_clk, rst_input)
      begin
        if (rst_input = '1') then
          i2c_sda_setup_sync <= '1';
        else
          if ((rising_edge(i2c_clk)) and (i2c_sda_in /= i2c_sda_in_sync) and (i2c_sclk_in = '0' or i2c_sclk_in = 'L')) then
	    i2c_sda_setup_sync <= '0';
          elsif (i2c_sda_setup_cnt = 15) then   -- i2c_clk predefined by HW as 15
	    i2c_sda_setup_sync <= '1'; 
          end if;
        end if;
      end process;


      i2c_sda_setup_cnt_p : process (i2c_clk, sda_changing, rst_input)
      begin
        if (rst_input = '1') then
          i2c_sda_setup_cnt <= 0;
        elsif (sda_changing = '1') then
          i2c_sda_setup_cnt <= 1;
        elsif (rising_edge(i2c_clk) and i2c_sda_setup_sync = '0') then
	 i2c_sda_setup_cnt <= i2c_sda_setup_cnt + 1;
        end if;
      end process;
      
    
    i2c_sda_xmit_p : process (i2c_clk, rst_input)
      begin
        if (rst_input = '1') then
          i2c_sda_out_tmp <= '1';
        else
          if ((addr_match = '1' and i2c_state = ACK_HEADER) or (i2c_state = ACK_DATA)) then  -- send ACK
	    i2c_sda_out_tmp <= '0';   
          elsif (i2c_state = XMIT_DATA) then
                 i2c_sda_out_tmp <= i2c_sda_xmit;
          else
            i2c_sda_out_tmp <= '1';  
          end if;
        end if;
        
      end process;

-------------------------------------------------------------------------------
-- i2c end
-------------------------------------------------------------------------------
    

-- Clock divider, generate  and adcclk

    sysclk_p : process(dclk_in)
    begin
      if (rising_edge(dclk_in)) then
          sysclk <= not sysclk;
      end if;
    end process;


    curr_clkdiv_sel_int_p : process (curr_clkdiv_sel)
    begin
        curr_clkdiv_sel_int <= SLV_TO_INT(curr_clkdiv_sel);
    end process;

    clk_count_p : process(dclk_in)
       variable clk_count : integer := -1;
    begin
     
       if (rising_edge(dclk_in)) then
        if (curr_clkdiv_sel_int > 2 ) then 
            if (clk_count >= curr_clkdiv_sel_int - 1) then
                clk_count := 0;
            else
                clk_count := clk_count + 1;
            end if;

            if (clk_count > (curr_clkdiv_sel_int/2) - 1) then
               adcclk_tmp <= '1';
            else
               adcclk_tmp <= '0';
            end if;
        else
             adcclk_tmp <= not adcclk_tmp;
         end if;
      end if;
   end process;

        sysmone1_en <= '0' when (cfg_reg2(5) = '1' and cfg_reg2(4) = '1') else '1';
        sysmone12_en <= '0' when (cfg_reg2(5) = '1') else '1';
        curr_clkdiv_sel <= cfg_reg2(15 downto 8);
        adcclk_div1 <= '0' when (curr_clkdiv_sel_int > 2) else '1';
        adcclk_r <=  not sysclk when adcclk_div1 = '1' else adcclk_tmp;
        adcclk <= adcclk_r when (sysmone1_en = '1') else '0';
        muxaddr_o <= "00000" when (rst_lock_early = '1') 
                   else acq_chan_m when ((curr_seq1_0_lat(3 downto 2) /= "10" and
                       sysmone12_en = '0') or  sysmone12_en = '1') else "00000";

    acq_chan_m_p : process ( seq1_0, adc_s1_flag, curr_seq_m, cfg_reg0_adc, rst_in)
       variable tmp_v : integer;
    begin
        if (rst_in = '0') then
          if (seq1_0(3 downto 2) = "11") then 
            acq_chan_m <= curr_seq_m(4 downto 0);
          elsif (seq1_0 /= "0011" and  adc_s1_flag = '0') then
            acq_chan_m <= curr_seq_m(4 downto 0);
          else 
            acq_chan_m <= cfg_reg0_adc(4 downto 0);
          end if;
        end if;
    end process;


--CR 675227    acq_latch_p : process ( seq1_0, adc_s1_flag, curr_seq, curr_seq2, cfg_reg0_adc, rst_in)
    acq_latch_p : process (adc_s1_flag, curr_seq, curr_seq2, cfg_reg0_adc, rst_in)
       variable tmp_v : integer;
    begin
        if ((seq1_0 = "0001" and adc_s1_flag = '0') or seq1_0 = "0010" or seq1_0(3 downto 2) = "11") then
            acq_acqsel <= curr_seq(8);
        elsif (seq1_0 = "0011") then
            acq_acqsel <= cfg_reg0_adc(8);
        else
            acq_acqsel <= '0';
        end if;

        if (rst_in = '0') then
          if (seq1_0(3 downto 2) = "11") then 
            acq_avg  <= "01";
            acq_chan <= curr_seq(5 downto 0);
            acq_b_u <= '0';
          elsif (seq1_0 /= "0011" and  adc_s1_flag = '0') then
            acq_avg <= curr_seq(13 downto 12);
            acq_chan <= curr_seq(5 downto 0);
            acq_b_u <= curr_seq(10);
          else 
            acq_avg <= cfg_reg0_adc(13 downto 12);
            acq_chan <= cfg_reg0_adc(5 downto 0);
            acq_b_u <= cfg_reg0_adc(10);

--CR 675227	  
            if (seq1_0 = "0001") then
              trig_halt_adc <= not trig_halt_adc;
            end if;
	      
            if (halt_adc = 2) then
              trig_halt_adc_dr_sram <= not trig_halt_adc_dr_sram;
            end if;
               
          end if;
        end if;
    end process;

    acq_chan_index <= SLV_TO_INT(acq_chan);

    
    conv_end_reg_read_P : process ( adcclk, rst_in)
    begin
       if (rst_in = '1') then
           conv_end_reg_read <= "0000";
       elsif (rising_edge(adcclk)) then
           conv_end_reg_read(3 downto 1) <= conv_end_reg_read(2 downto 0);  
           conv_end_reg_read(0) <= single_chan_conv_end or conv_end;
       end if;
   end process;

-- synch to DCLK
       busy_reg_read_P : process ( dclk_in, rst_in)
    begin
       if (rst_in = '1') then
           busy_reg_read <= '1';
       elsif (rising_edge(dclk_in)) then
           busy_reg_read <= not conv_end_reg_read(2);
       end if;
   end process;


-- i2c write
   cfg_reg0_adc <= cfg_reg0 when (i2c_stop = '1') else cfg_reg0_adc_tmp6;
--   cfg_reg0_adc <= cfg_reg0_adc_tmp6;
   cfg_reg0_seq <= cfg_reg0_seq_tmp6;
   acq_e_c <= acq_e_c_tmp6;

   cfg_reg0_adc6_P : process
      variable  first_after_reset : std_ulogic := '1';
   begin
       if (rst_in='1') then
          cfg_reg0_seq_tmp6 <= X"0000";
          cfg_reg0_adc_tmp6  <= X"0000";
          acq_e_c_tmp6 <= '0';
          first_after_reset := '1';
       elsif (falling_edge(busy_out) or falling_edge(rst_in)) then
          wait until (rising_edge(dclk_in));
          wait until (rising_edge(dclk_in));
          wait until (rising_edge(dclk_in));
          if (first_after_reset = '1') then
             first_after_reset := '0';
             cfg_reg0_adc_tmp6 <= cfg_reg0;
             cfg_reg0_seq_tmp6 <= cfg_reg0;
          else
             cfg_reg0_adc_tmp6 <= cfg_reg0_seq;
             cfg_reg0_seq_tmp6 <= cfg_reg0;
          end if;
          acq_e_c_tmp6 <= cfg_reg0(9);
       end if;
       wait on busy_out, rst_in;
   end process;

   busy_r_p : process(conv_start, busy_r_rst, rst_in)
   begin
      if (rst_in = '1') then
         busy_r <= '0';
      elsif (rising_edge(conv_start) and rst_lock = '0') then
          busy_r <= '1';
      elsif (rising_edge(busy_r_rst)) then
          busy_r <= '0';
      end if;
   end process;

   curr_seq1_0_p : process( busy_out)
   begin
     if (falling_edge( busy_out)) then
        if (adc_s1_flag = '1') then
            curr_seq1_0 <= "0000";
        else
            curr_seq1_0 <= seq1_0;
        end if;
     end if;
   end process;

   start_conv_p : process ( conv_start, rst_in)
      variable       Message : line;
      variable       tmp_seq1_0 : std_logic_vector(1 downto 0);
   begin
     if (rst_in = '1') then
        mn_mux_in <= 0.0;
        curr_chan <= "000000";
     elsif (rising_edge(conv_start)) then
        if ( ((acq_chan_index = 3) or (acq_chan_index >= 16 and acq_chan_index <= 31))) then
           if (ext_mux = '1') then
            mn_mux_in <= mn_in_diff(ext_mux_chan_idx);
           else
            mn_mux_in <= mn_in_diff(acq_chan_index);
           end if;
        else
             mn_mux_in <= mn_in_uni(acq_chan_index);
        end if;

        tmp_seq1_0 := curr_seq1_0(3 downto 2);

        curr_chan <= acq_chan;
        curr_seq1_0_lat <= curr_seq1_0;
          
        if (acq_chan_index = 7 or (acq_chan_index >= 10 and acq_chan_index <= 12)) then
            Write ( Message, string'(" Invalid Input Warning : The mn channel  "));
            Write ( Message, acq_chan_index);
            Write ( Message, string'(" to SYSMONE1 is invalid."));
            assert false report Message.all severity warning;
        end if;
           
        if ((seq1_0 = "0001" and adc_s1_flag = '0') or seq1_0 = "0010" 
            or seq1_0 = "0000" or seq1_0(3 downto 2) = "11") then
                curr_pj_set <= curr_seq(13 downto 12);
                curr_b_u <= curr_seq(10);
                curr_e_c <= curr_seq(9);
                curr_acq <= curr_seq(8);
         else 
                curr_pj_set <= acq_avg;
                curr_b_u <= acq_b_u;
                curr_e_c <= cfg_reg0(9);
                curr_acq <= cfg_reg0(8);
        end if;
      end if; 

    end  process;

-- end latch configuration registers

-- sequence control

     seq_en_dly <= seq_en after 1 ps;

    seq_num_p : process(seq_en_dly)
       variable seq_num_tmp : integer := 0;
       variable si_tmp : integer := 0;
       variable si : integer := 0;
    begin
     if (rising_edge(seq_en_dly)) then
       if (seq1_0  = "0001" or seq1_0 = "0010") then
          seq_num_tmp := 0;
          for I in 0 to 15 loop
              si := I;
              if (seq_chan_reg1(si) = '1') then
                 seq_num_tmp := seq_num_tmp + 1;
                 seq_mem(seq_num_tmp) <= si;
              end if;
          end loop;
          for I in 16 to 31 loop
              si := I;
              si_tmp := si-16;
              if (seq_chan_reg2(si_tmp) = '1') then
                   seq_num_tmp := seq_num_tmp + 1;
                   seq_mem(seq_num_tmp) <= si;
              end if;
          end loop;
          for I in 32 to 35 loop
              si := I;
              si_tmp := si-32;
              if (seq_chan_reg2(si_tmp) = '1') then
                   seq_num_tmp := seq_num_tmp + 1;
                   seq_mem(seq_num_tmp) <= si;
              end if;
          end loop;
          seq_num <= seq_num_tmp;
        elsif (seq1_0  = "0000" or seq1_0(3 downto 2) = "11") then
          if (simd_f = '0') then
           seq_num <= 5;
           seq_mem(1) <= 0;
           seq_mem(2) <= 8;
           seq_mem(3) <= 9;
           seq_mem(4) <= 10;
           seq_mem(5) <= 14;
          end if;
         end if;
     end if;
   end process;

   curr_seq_m_p : process(seq_count_a, seq_en_dly)
      variable seq_curr_i : std_logic_vector(4 downto 0);
      variable seq_curr_index : integer;
      variable tmp_value : integer;
      variable curr_seq_tmp : std_logic_vector(15  downto 0);
    begin
    if (seq_count_a'event or falling_edge(seq_en_dly)) then
      seq_curr_index := seq_mem(seq_count_a);
      seq_curr_i := STD_LOGIC_VECTOR(TO_UNSIGNED(seq_curr_index, 5));
      curr_seq_tmp := "0000000000000000";
      if (seq_curr_index >= 0 and seq_curr_index <= 15) then
          curr_seq_tmp(2 downto 0) := seq_curr_i(2 downto 0);
          curr_seq_tmp(4 downto 3) := "01";
          curr_seq_tmp(8) := seq_acq_reg1(seq_curr_index);
          curr_seq_tmp(10) := seq_du_reg1(seq_curr_index);
          if (seq1_0 = "0000" or seq1_0(3 downto 2) = "11") then
             curr_seq_tmp(13 downto 12) := "01";
          elsif (seq_pj_reg1(seq_curr_index) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
          if (seq_curr_index >= 0 and seq_curr_index <= 7) then
             curr_seq_tmp(4 downto 3) := "01";
          else
             curr_seq_tmp(4 downto 3) := "00";
          end if;
      elsif (seq_curr_index >= 16 and seq_curr_index <= 31) then
          tmp_value := seq_curr_index -16;
          curr_seq_tmp(4 downto 0) := seq_curr_i;
          curr_seq_tmp(8) := seq_acq_reg2(tmp_value);
          curr_seq_tmp(10) := seq_du_reg2(tmp_value);
          if (seq_pj_reg2(tmp_value) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
      elsif (seq_curr_index > 31 and seq_curr_index <= 35) then
          tmp_value := seq_curr_index -32;
          curr_seq_tmp(4 downto 0) := seq_curr_i;
          curr_seq_tmp(8) := seq_acq_reg3(tmp_value);
          curr_seq_tmp(10) := seq_du_reg3(tmp_value);
          if (seq_pj_reg3(tmp_value) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
      end if;
      curr_seq_m <= curr_seq_tmp;
   end if;
   end process;


   curr_seq_p : process(seq_count, seq_en_dly)
      variable seq_curr_i : std_logic_vector(4 downto 0);
      variable seq_curr_i2 : std_logic_vector(4 downto 0);
      variable seq_curr_index : integer;
      variable tmp_value : integer;
      variable tmp_value2 : integer;
      variable curr_seq_tmp : std_logic_vector(15  downto 0) := X"0000";
      variable curr_seq2_tmpi : std_logic_vector(15  downto 0) := X"0000";
    begin
    if (seq_count'event or falling_edge(seq_en_dly)) then
      seq_curr_index := seq_mem(seq_count);
      seq_curr_i := STD_LOGIC_VECTOR(TO_UNSIGNED(seq_curr_index, 5));
      curr_seq_tmp := "0000000000000000";
      if (seq_curr_index >= 0 and seq_curr_index <= 15) then
          curr_seq_tmp(2 downto 0) := seq_curr_i(2 downto 0);
          curr_seq_tmp(4 downto 3) := "01";
          curr_seq_tmp(8) := seq_acq_reg1(seq_curr_index);
          curr_seq_tmp(10) := seq_du_reg1(seq_curr_index);
          if (seq1_0 = "0000" or seq1_0(3 downto 2) = "11") then
             curr_seq_tmp(13 downto 12) := "01";
          elsif (seq_pj_reg1(seq_curr_index) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
          if (seq_curr_index >= 0 and seq_curr_index <= 7) then
             curr_seq_tmp(4 downto 3) := "01";
          else
             curr_seq_tmp(4 downto 3) := "00";
          end if;
      elsif (seq_curr_index >= 16 and seq_curr_index <= 31) then
          tmp_value := seq_curr_index -16;
          curr_seq_tmp(4 downto 0) := seq_curr_i;
          curr_seq_tmp(8) := seq_acq_reg2(tmp_value);
          curr_seq_tmp(10) := seq_du_reg2(tmp_value);
          if (seq_pj_reg2(tmp_value) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
      elsif (seq_curr_index > 31 and seq_curr_index <= 35) then
          tmp_value := seq_curr_index -32;
          curr_seq_tmp(4 downto 0) := seq_curr_i;
          curr_seq_tmp(8) := seq_acq_reg3(tmp_value);
          curr_seq_tmp(10) := seq_du_reg3(tmp_value);
          if (seq_pj_reg3(tmp_value) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
      end if;
      curr_seq <= curr_seq_tmp;
   end if;
   end process;

   seq_count_a_p : process (busy_out, rst_in )
   begin
     if (rst_in = '1' or rst_lock = '1' ) then 
          seq_count_a <= 1;
     elsif (rising_edge(busy_out)) then
       if ( curr_seq1_0_lat = "0011" ) then
          seq_count_a <= 1;
       else  
           if (seq_count_a >= 32 or seq_count_a >= seq_num) then
                 seq_count_a <= 1;
           else
                 seq_count_a <= seq_count_a + 1;
           end if;
       end if;
    end if;
  end process;

   
   eos_en_p : process (adcclk, rst_in)
   begin
        if (rst_in = '1') then 
            seq_count <= 1;
            eos_en <= '0';
        elsif (rising_edge(adcclk)) then

            if ((seq_count = seq_num  ) and (adc_state = S3_ST and next_state = S5_ST)
                 and  (curr_seq1_0_lat /= "0011") and rst_lock = '0') then
                eos_tmp_en <= '1';
            else
                eos_tmp_en <= '0';
            end if;

            if ((eos_tmp_en = '1') and (seq_status_avg = 0))  then
                eos_en <= '1';
            else
                eos_en <= '0';
            end if;

            if (eos_tmp_en = '1' or curr_seq1_0_lat = "0011") then
                seq_count <= 1;
            elsif (seq_count_en = '1' ) then
               if (seq_count >= 32) then
                  seq_count <= 1;
               else
                seq_count <= seq_count +1;
               end if;
            end if;
        end if; 
   end process;

-- end sequence control

-- Acquisition

   busy_out_dly <= busy_out after 10 ps;

   short_acq_p : process(adc_state, rst_in, first_acq)
   begin
       if (rst_in = '1') then
           shorten_acq <= 0;
       elsif (adc_state'event or first_acq'event) then
         if  ((busy_out_dly = '0') and (adc_state=S2_ST) and (first_acq='1')) then
           shorten_acq <= 1;
         else
           shorten_acq <= 0;
         end if;
       end if;
   end process;

   acq_count_p : process (adcclk, rst_in)
   begin
        if (rst_in = '1' or rst_lock = '1') then
            acq_count <= 1;
            first_acq <= '1';
        elsif (rising_edge(adcclk)) then
            if (adc_state = S2_ST and rst_lock = '0' and acq_e_c = '0') then 
                first_acq <= '0';

                if (acq_acqsel = '1') then
                    if (acq_count <= 11) then
                        acq_count <= acq_count + 1 + shorten_acq;
                    end if;
                else 
                    if (acq_count <= 4) then
                        acq_count <= acq_count + 1 + shorten_acq;
                    end if;
                end if;

                if (next_state = S3_ST) then
                    if ((acq_acqsel = '1' and acq_count < 10) or (acq_acqsel = '0' and acq_count < 4)) then
                    assert false report "Warning: Acquisition time not enough for SYSMONE1."
                    severity warning;
                    end if;
                end if;
            else
                if (first_acq = '1') then
                    acq_count <= 1;
                else
                    acq_count <= 0;
                end if;
            end if;
        end if; 
    end process;

    conv_start_con_p: process(adc_state, acq_acqsel, acq_count)
    begin
      if (adc_state = S2_ST) then
        if (rst_lock = '0') then
         if ((seq_reset_flag = '0' or (seq_reset_flag = '1' and curr_clkdiv_sel_int > 3))
           and ((acq_acqsel = '1' and acq_count > 10) or (acq_acqsel = '0' and acq_count > 4))) then
                 conv_start_cont <= '1';
         else
                 conv_start_cont <= '0';
         end if;
       end if;
     else
         conv_start_cont <= '0';
     end if;
   end process;
 
   conv_start_sel <= convst_in when (acq_e_c = '1') else conv_start_cont;
   reset_conv_start_tmp <= '1' when (conv_count=2) else '0';
   reset_conv_start <= rst_in or reset_conv_start_tmp;
  
   conv_start_p : process(conv_start_sel, reset_conv_start)
   begin
      if (reset_conv_start ='1') then
          conv_start <= '0';
      elsif (rising_edge(conv_start_sel)) then
          conv_start <= '1';
      end if;
   end process;

-- end acquisition


-- Conversion
    conv_result_p : process (adc_state, next_state, curr_chan, curr_chan_index, mn_mux_in, curr_b_u)
       variable conv_result_int_i : integer := 0;
       variable conv_result_int_tmp : integer := 0;
       variable conv_result_int_tmp_rl : real := 0.0;
       variable adc_mn_tmp : real := 0.0;
    begin
        if ((adc_state = S3_ST and next_state = S5_ST) or adc_state = S5_ST) then
            if (curr_chan = "00000") then    -- temperature conversion
                    adc_mn_tmp := (mn_mux_in + 273.15) * 130.0382;
                    adc_temp_result <= adc_mn_tmp;
                    if (adc_mn_tmp >= 65535.0) then
                        conv_result_int_i := 65535;
                    elsif (adc_mn_tmp < 0.0) then
                        conv_result_int_i := 0;
                    else 
                        conv_result_int_tmp := real2int(adc_mn_tmp);
                        conv_result_int_tmp_rl := real(conv_result_int_tmp);
                        if (adc_mn_tmp - conv_result_int_tmp_rl > 0.9999) then
                            conv_result_int_i := conv_result_int_tmp + 1;
                        else
                            conv_result_int_i := conv_result_int_tmp;
                        end if;
                    end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_result_int_i, 16));
            elsif (curr_chan = "00001" or curr_chan = "00010" or curr_chan = "00110"
                   or curr_chan = "01101" or curr_chan = "01110" or curr_chan = "01111"
                   or ((curr_chan_index >= 32) and (curr_chan_index <= 35))) then     -- internal power conversion
                    adc_mn_tmp := mn_mux_in * 65536.0 / 3.0;
                    adc_intpwr_result <= adc_mn_tmp;
                    if (adc_mn_tmp >= 65535.0) then
                        conv_result_int_i := 65535;
                    elsif (adc_mn_tmp < 0.0) then
                        conv_result_int_i := 0;
                    else 
                       conv_result_int_tmp := real2int(adc_mn_tmp);
                        conv_result_int_tmp_rl := real(conv_result_int_tmp);
                        if (adc_mn_tmp - conv_result_int_tmp_rl > 0.9999) then
                            conv_result_int_i := conv_result_int_tmp + 1;
                        else
                            conv_result_int_i := conv_result_int_tmp;
                        end if;
                    end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_result_int_i, 16));
            elsif ((curr_chan = "00011") or ((curr_chan_index >= 16) and  (curr_chan_index <= 31))) then
                    adc_mn_tmp :=  (mn_mux_in) * 65536.0;
                    adc_ext_result <= adc_mn_tmp;
                    if (curr_b_u = '1')  then
                        if (adc_mn_tmp > 32767.0) then
                             conv_result_int_i := 32767;
                        elsif (adc_mn_tmp < -32768.0) then
                             conv_result_int_i := -32768;
                        else 
                            conv_result_int_tmp := real2int(adc_mn_tmp);
                            conv_result_int_tmp_rl := real(conv_result_int_tmp);
                            if (adc_mn_tmp - conv_result_int_tmp_rl > 0.9999) then
                                conv_result_int_i := conv_result_int_tmp + 1;
                            else
                                conv_result_int_i := conv_result_int_tmp;
                            end if;
                        end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_SIGNED(conv_result_int_i, 16));
                    else
                       if (adc_mn_tmp  > 65535.0) then
                             conv_result_int_i := 65535;
                        elsif (adc_mn_tmp  < 0.0) then
                             conv_result_int_i := 0;
                        else
                            conv_result_int_tmp := real2int(adc_mn_tmp);
                            conv_result_int_tmp_rl := real(conv_result_int_tmp);
                            if (adc_mn_tmp - conv_result_int_tmp_rl > 0.9999) then
                                conv_result_int_i := conv_result_int_tmp + 1;
                            else
                                conv_result_int_i := conv_result_int_tmp;
                            end if;
                        end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_result_int_i, 16));
                    end if;
            else 
                conv_result_int <= 0;
                conv_result <= "0000000000000000";
            end if;
         end if;
    end process;


    conv_count_p : process (adcclk, rst_in)
    begin
        if (rst_in = '1') then
            conv_count <= 6;
            conv_end <= '0';
            seq_status_avg <= 0;
            busy_r_rst <= '0';
            busy_r_rst_done <= '0';
            for i in 0 to 31 loop
                conv_pj_count(i) <= 0;     -- array of integer
            end loop;
            single_chan_conv_end <= '0';
        elsif (rising_edge(adcclk)) then
            if (adc_state = S2_ST) then
               if (busy_r_rst_done = '0') then
                    busy_r_rst <= '1';
               else
                    busy_r_rst <= '0';
               end if;
               busy_r_rst_done <= '1';
            end if;

            if (adc_state = S2_ST and conv_start = '1') then
                conv_count <= 0;
                conv_end <= '0';
            elsif (adc_state = S3_ST ) then
                busy_r_rst_done <= '0';
                conv_count <= conv_count + 1;

                if (((curr_chan /= "01000" ) and (conv_count = conv_time )) or 
              ((curr_chan = "01000") and (conv_count = conv_time_cal_1) and (first_cal_chan = '1'))
              or ((curr_chan = "01000") and (conv_count = conv_time_cal) and (first_cal_chan = '0'))) then
                    conv_end <= '1';
                else
                    conv_end <= '0';
                end if;
            else  
                conv_end <= '0';
                conv_count <= 0;
            end if;

           single_chan_conv_end <= '0';
           if ( (conv_count = conv_time) or (conv_count = 44)) then
                   single_chan_conv_end <= '1';
           end if;

            if (adc_state = S3_ST and next_state = S5_ST and rst_lock = '0') then
                case curr_pj_set is
                    when "00" => eoc_en <= '1';
                                conv_pj_count(curr_chan_index) <= 0;
                    when "01" =>
                                if (conv_pj_count(curr_chan_index) = 15) then
                                  eoc_en <= '1';
                                  conv_pj_count(curr_chan_index) <= 0;
                                  seq_status_avg <= seq_status_avg - 1;
                                else 
                                  eoc_en <= '0';
                                  if (conv_pj_count(curr_chan_index) = 0) then
                                      seq_status_avg <= seq_status_avg + 1;
                                  end if;
                                  conv_pj_count(curr_chan_index) <= conv_pj_count(curr_chan_index) + 1;
                                end if;
                   when "10" =>
                                if (conv_pj_count(curr_chan_index) = 63) then
                                    eoc_en <= '1';
                                    conv_pj_count(curr_chan_index) <= 0;
                                    seq_status_avg <= seq_status_avg - 1;
                                else 
                                    eoc_en <= '0';
                                    if (conv_pj_count(curr_chan_index) = 0) then
                                        seq_status_avg <= seq_status_avg + 1;
                                    end if;
                                    conv_pj_count(curr_chan_index) <= conv_pj_count(curr_chan_index) + 1;
                                end if;
                    when "11" => 
                                if (conv_pj_count(curr_chan_index) = 255) then
                                    eoc_en <= '1';
                                    conv_pj_count(curr_chan_index) <= 0;
                                    seq_status_avg <= seq_status_avg - 1;
                                else 
                                    eoc_en <= '0';
                                    if (conv_pj_count(curr_chan_index) = 0) then
                                        seq_status_avg <= seq_status_avg + 1;
                                    end if;
                                    conv_pj_count(curr_chan_index) <= conv_pj_count(curr_chan_index) + 1;
                                end if;
                   when  others => eoc_en <= '0';
                end case;

            else
                eoc_en <= '0';
            end if;

            if (adc_state = S5_ST) then
                   conv_result_reg <= conv_result;
            end if;
        end if;
   end process;

-- end conversion

   
-- average
    
    conv_acc_result_p : process(adcclk, rst_in)
       variable conv_acc_vec : std_logic_vector(23 downto 0);
       variable conv_acc_vec_int  : integer;
    begin
        if (rst_in = '1') then 
            for j in 0 to 31 loop
                conv_acc(j) <= 0;
            end loop;
            conv_acc_result <= "0000000000000000";
        elsif (rising_edge(adcclk)) then
            if (adc_state = S3_ST and  next_state = S5_ST) then
                if (curr_pj_set /= "00" and rst_lock /= '1') then
                    conv_acc(curr_chan_index) <= conv_acc(curr_chan_index) + conv_result_int;
                else
                    conv_acc(curr_chan_index) <= 0;
                end if;
            elsif (eoc_en = '1') then
                conv_acc_vec_int := conv_acc(curr_chan_index);
                if ((curr_b_u = '1') and (((curr_chan_index >= 16) and (curr_chan_index <= 31))
                   or (curr_chan_index = 3))) then
                    conv_acc_vec := STD_LOGIC_VECTOR(TO_SIGNED(conv_acc_vec_int, 24));
                else
                    conv_acc_vec := STD_LOGIC_VECTOR(TO_UNSIGNED(conv_acc_vec_int, 24));
                end if;
                case curr_pj_set(1 downto 0) is
                  when "00" => conv_acc_result <= "0000000000000000";
                  when "01" => conv_acc_result <= conv_acc_vec(19 downto 4);
                  when "10" => conv_acc_result <= conv_acc_vec(21 downto 6);
                  when "11" => conv_acc_result <= conv_acc_vec(23 downto 8);
                  when others => conv_acc_result <= "0000000000000000";
                end case;
                conv_acc(curr_chan_index) <= 0;
            end if;
        end if;
    end process;

-- end average   

-- single sequence
    adc_s1_flag_p : process(adcclk, rst_in)
    begin
        if (rst_in = '1') then
            adc_s1_flag <= '0';
        elsif (rising_edge(adcclk)) then 
            if (adc_state = S6_ST) then
                adc_s1_flag <= '1';
            end if;
        end if;
    end process;


--  end state
    eos_eoc_p: process(adcclk, rst_in)
    begin
        if (rst_in = '1') then
            seq_count_en <= '0';
            eos_out_tmp <= '0';
            eoc_out_tmp <= '0';
        elsif (rising_edge(adcclk)) then
            if ((adc_state = S3_ST and next_state = S5_ST) and (curr_seq1_0_lat /= "0011")
                  and (rst_lock = '0')) then
                seq_count_en <= '1';
            else
                seq_count_en <= '0';
            end if;

            if (rst_lock = '0') then
                 eos_out_tmp <= eos_en;
                 eoc_en_delay <= eoc_en;
                 eoc_out_tmp <= eoc_en_delay;
               if (curr_seq1_0_lat(3 downto 2)  /= "00") then
               end if;
            else 
                 eos_out_tmp <= '0';
                 eoc_en_delay <= '0';
                 eoc_out_tmp <= '0';
            end if;
        end if;
   end process;

    eoc_out_t <= eoc_out after 1 ps;


    data_written_p : process(busy_r, rst_in_not_seq)
    begin
       if (rst_in_not_seq = '1') then
            data_written <= X"0000";
       elsif (falling_edge(busy_r)) then
        if (curr_seq1_0(3 downto 2) /= "10") then
          if (curr_pj_set = "00") then
               data_written <= conv_result_reg;
           else
              data_written <= conv_acc_result;
           end if;
         end if;
       end if;
    end process;

-- eos and eoc

    eoc_out_tmp1_p : process (eoc_out_tmp, eoc_out, rst_in)
    begin
           if (rst_in = '1') then
              eoc_out_tmp1 <= '0';
           elsif (rising_edge(eoc_out)) then
               eoc_out_tmp1 <= '0';
           elsif (rising_edge(eoc_out_tmp)) then
               if (curr_chan /= "01000" and ( sysmone12_en = '1' or 
                 (curr_seq1_0(3 downto 2) /= "10" and  sysmone12_en = '0'))) then
                  eoc_out_tmp1 <= '1';
               else
                  eoc_out_tmp1 <= '0';
               end if;
           end if;
    end process;


    eos_out_tmp1_p : process (eos_out_tmp, eos_out, rst_in)
    begin
           if (rst_in = '1') then
              eos_out_tmp1 <= '0';
           elsif (rising_edge(eos_out)) then
               eos_out_tmp1 <= '0';
           elsif (rising_edge(eos_out_tmp) and ( sysmone12_en = '1' or (curr_seq1_0(3 downto 2) /= "10" and  sysmone12_en = '0'))) then
               eos_out_tmp1 <= '1';
           end if;
    end process;

    busy_out_low_edge <= '1' when (busy_out='0' and busy_out_sync='1') else '0';

    eoc_eos_out_p : process (dclk_in, rst_in)
    begin
      if (rst_in = '1') then
          op_count <= 15;
          busy_out_sync <= '0';
          drp_update <= '0';
          alarm_update <= '0';
          eoc_out <= '0';
          eos_out <= '0';
      elsif ( rising_edge(dclk_in)) then
         busy_out_sync <= busy_out;   
         if (op_count = 3) then
            drp_update <= '1';
          else 
            drp_update <= '0';
          end if;
          if (op_count = 5 and eoc_out_tmp1 = '1') then
             alarm_update <= '1';
          else
             alarm_update <= '0';
          end if;
          if (op_count = 16 ) then
             eoc_out <= eoc_out_tmp1;
          else
             eoc_out <= '0';
          end if;
          if (op_count = 16) then
             eos_out <= eos_out_tmp1;
          else
             eos_out <= '0';
          end if;
          if (busy_out_low_edge = '1') then
              op_count <= 0;
          elsif (op_count < 22) then
              op_count <= op_count +1;
          end if;
      end if;
   end process;

-- end eos and eoc


-- alarm

    alm_reg_p : process(alarm_update, rst_in_not_seq )
       variable  tmp_unsig1 : unsigned(15 downto 0);
       variable  tmp_unsig2 : unsigned(15 downto 0);
       variable  tmp_unsig3 : unsigned(15 downto 0);
    begin
     if (rst_in_not_seq = '1') then
        ot_out_reg <= '0';
        alarm_out_reg <= "0000000000000000";
     elsif (rising_edge(alarm_update)) then
       if (rst_lock = '0') then
          if (curr_chan_lat = "000000") then
            tmp_unsig1 := UNSIGNED(data_written);
            tmp_unsig2 := UNSIGNED(dr_sram(87));
            if (data_written >= ot_limit_reg) then
                ot_out_reg <= '1';
            elsif (tmp_unsig1 < tmp_unsig2) then
                ot_out_reg <= '0';
            end if;
            tmp_unsig2 := UNSIGNED(dr_sram(80));
            tmp_unsig3 := UNSIGNED(dr_sram(84));
            if ( tmp_unsig1 > tmp_unsig2) then
                     alarm_out_reg(0) <= '1';
            elsif (tmp_unsig1 <= tmp_unsig3) then
                     alarm_out_reg(0) <= '0';
            end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(81));
          tmp_unsig3 := UNSIGNED(dr_sram(85));
          if (curr_chan_lat = "000001") then
             if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(1) <= '1';
             else
                      alarm_out_reg(1) <= '0';
             end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(82));
          tmp_unsig3 := UNSIGNED(dr_sram(86));
          if (curr_chan_lat = "000010") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(2) <= '1';
                 else
                      alarm_out_reg(2) <= '0';
              end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(88));
          tmp_unsig3 := UNSIGNED(dr_sram(92));
          if (curr_chan_lat = "000110") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(3) <= '1';
                 else
                      alarm_out_reg(3) <= '0';
              end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(89));
          tmp_unsig3 := UNSIGNED(dr_sram(93));
          if (curr_chan_lat = "001101") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(4) <= '1';
                 else
                      alarm_out_reg(4) <= '0';
              end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(90));
          tmp_unsig3 := UNSIGNED(dr_sram(94));
          if (curr_chan_lat = "001110") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(5) <= '1';
                 else
                      alarm_out_reg(5) <= '0';
              end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(91));
          tmp_unsig3 := UNSIGNED(dr_sram(95));
          if (curr_chan_lat = "001111") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(6) <= '1';
                 else
                      alarm_out_reg(6) <= '0';
              end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(96));
          tmp_unsig3 := UNSIGNED(dr_sram(104));
          if (curr_chan_lat = "100000") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(8) <= '1';
                 else
                      alarm_out_reg(8) <= '0';
              end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(97));
          tmp_unsig3 := UNSIGNED(dr_sram(105));
          if (curr_chan_lat = "100001") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(9) <= '1';
                 else
                      alarm_out_reg(9) <= '0';
              end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(98));
          tmp_unsig3 := UNSIGNED(dr_sram(106));
          if (curr_chan_lat = "100010") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(10) <= '1';
                 else
                      alarm_out_reg(10) <= '0';
              end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(99));
          tmp_unsig3 := UNSIGNED(dr_sram(107));
          if (curr_chan_lat = "100000") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(11) <= '1';
                 else
                      alarm_out_reg(11) <= '0';
              end if;
          end if;
     end if;
    end if;
   end process;


    alm_p : process(ot_out_reg, ot_en, alarm_out_reg, alarm_en)
    begin
             ot_out <= ot_out_reg and ot_en;
             alarm_out(0) <= alarm_out_reg(0) and alarm_en(0);
             alarm_out(1) <= alarm_out_reg(1) and alarm_en(1);
             alarm_out(2) <= alarm_out_reg(2) and alarm_en(2);
             alarm_out(3) <= alarm_out_reg(3) and alarm_en(3);
             alarm_out(4) <= alarm_out_reg(4) and alarm_en(4);
             alarm_out(5) <= alarm_out_reg(5) and alarm_en(5);
             alarm_out(6) <= alarm_out_reg(6) and alarm_en(6);
             alarm_out(7) <= (alarm_out_reg(0) and alarm_en(0)) or
                            (alarm_out_reg(1) and alarm_en(1)) or
                            (alarm_out_reg(2) and alarm_en(2)) or
                            (alarm_out_reg(3) and alarm_en(3)) or
                            (alarm_out_reg(4) and alarm_en(4)) or
                            (alarm_out_reg(5) and alarm_en(5)) or
                            (alarm_out_reg(6) and alarm_en(6));
             alarm_out(8) <= alarm_out_reg(8) and alarm_en(8);
             alarm_out(9) <= alarm_out_reg(9) and alarm_en(9);
             alarm_out(10) <= alarm_out_reg(10) and alarm_en(10);
             alarm_out(11) <= alarm_out_reg(11) and alarm_en(11);
             alarm_out(15) <= (alarm_out_reg(8) and alarm_en(8)) or
                            (alarm_out_reg(9) and alarm_en(9)) or
                            (alarm_out_reg(10) and alarm_en(10)) or
                            (alarm_out_reg(11) and alarm_en(11)) or
                            (alarm_out_reg(12) and alarm_en(12)) or
                            (alarm_out_reg(13) and alarm_en(13)) or
                            (alarm_out_reg(14) and alarm_en(14));
             
    end process;

-- end alarm


  READFILE_P : process
      file in_file : text;
      variable open_status : file_open_status;
      variable in_buf    : line;
      variable str_token : string(1 to 12);
      variable str_token_in : string(1 to 12);
      variable str_token_tmp : string(1 to 12);
      variable next_time     : time := 0 ps; 
      variable pre_time : time := 0 ps; 
      variable time_val : integer := 0;
      variable a1   : real;

      variable commentline : boolean := false;
      variable HeaderFound : boolean := false;
      variable read_ok : boolean := false;
      variable token_len : integer := 0;
      variable HeaderCount : integer := 0;

      variable vals : mn_DATA := (others => 0.0);
      variable valsn : mn_DATA := (others => 0.0);
      variable inchannel : integer := 0 ;
      type int_a is array (0 to 44) of integer;
      variable index_to_channel : int_a := (others => -1);
      variable low : integer := -1;
      variable low2 : integer := -1;
      variable sim_file_flag1 : std_ulogic := '0';
      variable file_line : integer := 0;

      type channm_array is array (0 to 35) of string(1 to  12);
      constant chanlist_p : channm_array := (
       0 => "TEMP" & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       1 => "VCCINT" & NUL & NUL & NUL & NUL & NUL & NUL,
       2 => "VCCAUX" & NUL & NUL & NUL & NUL & NUL & NUL,	
       3 => "VP" & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       4 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       5 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       6 => "VBRAM" & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       7 => "xxxxxxxxxxxx",
       8 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       9 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       10 => "xxxxxxxxxxxx",
       11 => "xxxxxxxxxxxx",
       12 => "xxxxxxxxxxxx",
       13 => "VCCPINT" & NUL & NUL & NUL & NUL & NUL,
       14 => "VCCPAUX" & NUL & NUL & NUL & NUL & NUL,
       15 => "VCCDDRO" & NUL & NUL & NUL & NUL & NUL,
       16 => "VAUXP[0]" & NUL & NUL & NUL & NUL,
       17 => "VAUXP[1]" & NUL & NUL & NUL & NUL,
       18 => "VAUXP[2]" & NUL & NUL & NUL & NUL,
       19 => "VAUXP[3]" & NUL & NUL & NUL & NUL,
       20 => "VAUXP[4]" & NUL & NUL & NUL & NUL,
       21 => "VAUXP[5]" & NUL & NUL & NUL & NUL,
       22 => "VAUXP[6]" & NUL & NUL & NUL & NUL,
       23 => "VAUXP[7]" & NUL & NUL & NUL & NUL,
       24 => "VAUXP[8]" & NUL & NUL & NUL & NUL,
       25 => "VAUXP[9]" & NUL & NUL & NUL & NUL,
       26 => "VAUXP[10]" & NUL & NUL & NUL,
       27 => "VAUXP[11]" & NUL & NUL & NUL,
       28 => "VAUXP[12]" & NUL & NUL & NUL,
       29 => "VAUXP[13]" & NUL & NUL & NUL,
       30 => "VAUXP[14]" & NUL & NUL & NUL,
       31 => "VAUXP[15]" & NUL & NUL & NUL,
       32 => "VUSER0" & NUL & NUL & NUL & NUL & NUL & NUL,
       33 => "VUSER1" & NUL & NUL & NUL & NUL & NUL & NUL,
       34 => "VUSER2" & NUL & NUL & NUL & NUL & NUL & NUL,
       35 => "VUSER3" & NUL & NUL & NUL & NUL & NUL & NUL
      );
       
      constant chanlist_n : channm_array := (
       0 => "xxxxxxxxxxxx",
       1 => "xxxxxxxxxxxx",
       2 => "xxxxxxxxxxxx",
       3 => "VN" & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       4 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       5 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       6 => "xxxxxxxxxxxx",
       7 => "xxxxxxxxxxxx",
       8 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       9 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       10 => "xxxxxxxxxxxx",
       11 => "xxxxxxxxxxxx",
       12 => "xxxxxxxxxxxx",
       13 => "xxxxxxxxxxxx",
       14 => "xxxxxxxxxxxx",
       15 => "xxxxxxxxxxxx",
       16 => "VAUXN[0]" & NUL & NUL & NUL & NUL,
       17 => "VAUXN[1]" & NUL & NUL & NUL & NUL,
       18 => "VAUXN[2]" & NUL & NUL & NUL & NUL,
       19 => "VAUXN[3]" & NUL & NUL & NUL & NUL,
       20 => "VAUXN[4]" & NUL & NUL & NUL & NUL,
       21 => "VAUXN[5]" & NUL & NUL & NUL & NUL,
       22 => "VAUXN[6]" & NUL & NUL & NUL & NUL,
       23 => "VAUXN[7]" & NUL & NUL & NUL & NUL,
       24 => "VAUXN[8]" & NUL & NUL & NUL & NUL,
       25 => "VAUXN[9]" & NUL & NUL & NUL & NUL,
       26 => "VAUXN[10]" & NUL & NUL & NUL,
       27 => "VAUXN[11]" & NUL & NUL & NUL,
       28 => "VAUXN[12]" & NUL & NUL & NUL,
       29 => "VAUXN[13]" & NUL & NUL & NUL,
       30 => "VAUXN[14]" & NUL & NUL & NUL,
       31 => "VAUXN[15]" & NUL & NUL & NUL,
       32 => "VUSER0" & NUL & NUL & NUL & NUL & NUL & NUL,
       33 => "VUSER1" & NUL & NUL & NUL & NUL & NUL & NUL,
       34 => "VUSER2" & NUL & NUL & NUL & NUL & NUL & NUL,
       35 => "VUSER3" & NUL & NUL & NUL & NUL & NUL & NUL
           );

  begin
 
    file_open(open_status, in_file, SIM_MONITOR_FILE, read_mode);
    if (open_status /= open_ok) then
         assert false report
         "*** Warning: The analog data file for SYSMONE1 was not found. Use the SIM_MONITOR_FILE generic to specify the input analog data file name or use default name: design.txt. "
         severity warning; 
         sim_file_flag1 := '1';
         sim_file_flag <= '1';
    end if;

   if ( sim_file_flag1 = '0') then
      while (not endfile(in_file) and (not HeaderFound)) loop
        commentline := false;
        readline(in_file, in_buf);
        file_line := file_line + 1;
        if (in_buf'LENGTH > 0 ) then
          skip_blanks(in_buf);
        
          low := in_buf'low;
          low2 := in_buf'low+2;
           if ( low2 <= in_buf'high) then
              if ((in_buf(in_buf'low to in_buf'low+1) = "//" ) or 
                  (in_buf(in_buf'low to in_buf'low+1) = "--" ) or
                   (in_buf(in_buf'low to in_buf'low+1) = NUL & NUL )) then
                 commentline := true;
               end if;

               while((in_buf'LENGTH > 0 ) and (not commentline)) loop
                   HeaderFound := true;
                   get_token(in_buf, str_token_in, token_len);
                   str_token_tmp := To_Upper(str_token_in);
                   if (str_token_tmp(1 to 4) = "TEMP") then
                      str_token := "TEMP" & NUL & NUL & NUL & NUL & NUL 
                                                  & NUL & NUL & NUL;
                   else
                      str_token := str_token_tmp;
                   end if;

                   if(token_len > 0) then
                    HeaderCount := HeaderCount + 1;
                   end if;
       
                   if (HeaderCount=1) then
                      if (str_token(1 to token_len) /= "TIME") then
                         infile_format;
                         assert false report
                  " Analog Data File Error : No TIME label is found in the input file for SYSMONE1."
                         severity failure;
                      end if;
                   elsif (HeaderCount > 1) then
                      inchannel := -1;
                      for i in 0 to 35 loop
                          if (chanlist_p(i) = str_token and str_token(1) /= NUL) then
                             inchannel := i;
                             index_to_channel(headercount) := i;
                           end if;
                       end loop;
                       if (inchannel = -1) then
                         for i in 0 to 35 loop
                           if ( chanlist_n(i) = str_token and str_token(1) /= NUL) then
                             inchannel := i;
                             index_to_channel(headercount) := i+36;
                           end if;
                         end loop;
                       end if;
                       if (inchannel = -1 and token_len >0) then
                           infile_format;
                           assert false report
                    "Analog Data File Error : No valid channel name in the input file for SYSMONE1. Valid names: TEMP VCCINT VCCAUX VBRAM VCCPINT VCCPAUX VCCDDRO VP VN VAUXP[1] VAUXN[1] ....."
                           severity failure;
                       end if;
                  else
                       infile_format;
                       assert false report
                    "Analog Data File Error : NOT found header in the input file for SYSMONE1. The header is: TIME TEMP VCCINT VCCAUX VBRAM VCCPINT VCCPAUX VCCDDRO VP VN VAUXP[1] VAUXN[1] ..."
                           severity failure;
                  end if;

           str_token_in := NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
                           NUL & NUL & NUL & NUL;
        end loop;
        end if;
       end if;
      end loop;

-----  Read Values
      while (not endfile(in_file)) loop
        commentline := false;
        readline(in_file, in_buf);
        file_line := file_line + 1;
        if (in_buf'length > 0) then
           skip_blanks(in_buf);
        
           if (in_buf'low < in_buf'high) then
             if((in_buf(in_buf'low to in_buf'low+1) = "//" ) or 
                    (in_buf(in_buf'low to in_buf'low+1) = "--" )) then
              commentline := true;
             end if;
 
          if(not commentline and in_buf'length > 0) then
            for i IN 1 to HeaderCount Loop
              if ( i=1) then
                 read(in_buf, time_val, read_ok);
                if (not read_ok) then
                  infile_format;
                  assert false report
                   " Analog Data File Error : The time value should be integer in ns scale and the last time value needs bigger than simulation time."
                  severity failure;
                 end if;
                 next_time := time_val * 1 ns; 
              else
               read(in_buf, a1, read_ok);
               if (not read_ok) then
                  assert false report
                    "*** Analog Data File Error: The data type should be REAL, e.g. 3.0  0.0  -0.5 "
                  severity failure;
               end if;
               inchannel:= index_to_channel(i);
              if (inchannel >= 36) then
                valsn(inchannel-36):=a1;
              else
                vals(inchannel):=a1;
              end if;
            end if;
           end loop;  -- i loop

           if ( now < next_time) then
               wait for ( next_time - now ); 
           end if;
           for i in 0 to 35 loop
                 chan_val_tmp(i) <= vals(i);
                 chan_valn_tmp(i) <= valsn(i);
                 mn_in_diff(i) <= vals(i)-valsn(i);
                 mn_in_uni(i) <= vals(i);
           end loop;
        end if;
        end if;
       end if;
      end loop;  -- while loop
      file_close(in_file);
    end if;
    wait;
  end process READFILE_P;



end SYSMONE1_V;

