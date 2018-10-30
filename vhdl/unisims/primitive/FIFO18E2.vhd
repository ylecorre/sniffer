-------------------------------------------------------
--  Copyright (c) 2011 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version     : 2012.4
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                      
-- /___/   /\      Filename    : FIFO18E2.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
-------------------------------------------------------
--  Revision:
--  11/30/12 - initial
--  12/12/12 - yaml update, 691724 and 691715
--  02/07/13 - 699628 - correction to DO_PIPELINED mode
--  03/07/13 - 703882 - a few missing initial conditions on reg bits without gsr.
--  03/18/2013 - 707083 reads should clear FULL when RD & WR in CDC.
--  03/22/2013 - sync5 yaml update, port ordering, *RSTBUSY
--  03/25/2013 - 707652 - RST = 1 n enters RST sequence but does not hold it there.
--  03/26/2013 - 707719 - Add sync5 cascade feature
--  03/27/2013 - 708820 - FULL flag deassert during WREN ind clocks.
--  End Revision:
-------------------------------------------------------

----- CELL FIFO18E2 -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity FIFO18E2 is
    generic (
      CASCADE_ORDER : string := "NONE";
      CLOCK_DOMAINS : string := "INDEPENDENT";
      FIRST_WORD_FALL_THROUGH : string := "FALSE";
      INIT : std_logic_vector (35 downto 0) := X"000000000";
      IS_RDCLK_INVERTED : std_ulogic := '0';
      IS_RDEN_INVERTED : std_ulogic := '0';
      IS_RSTREG_INVERTED : std_ulogic := '0';
      IS_RST_INVERTED : std_ulogic := '0';
      IS_WRCLK_INVERTED : std_ulogic := '0';
      IS_WREN_INVERTED : std_ulogic := '0';
      PROG_EMPTY_THRESH : integer := 256;
      PROG_FULL_THRESH : integer := 256;
      RDCOUNT_TYPE : string := "RAW_PNTR";
      READ_WIDTH : integer := 4;
      REGISTER_MODE : string := "UNREGISTERED";
      RSTREG_PRIORITY : string := "RSTREG";
      SLEEP_ASYNC : string := "FALSE";
      SRVAL : std_logic_vector (35 downto 0) := X"000000000";
      WRCOUNT_TYPE : string := "RAW_PNTR";
      WRITE_WIDTH : integer := 4
    );

    port (
      CASDOUT              : out std_logic_vector(31 downto 0);
      CASDOUTP             : out std_logic_vector(3 downto 0);
      CASNXTEMPTY          : out std_ulogic;
      CASPRVRDEN           : out std_ulogic;
      DOUT                 : out std_logic_vector(31 downto 0);
      DOUTP                : out std_logic_vector(3 downto 0);
      EMPTY                : out std_ulogic;
      FULL                 : out std_ulogic;
      PROGEMPTY            : out std_ulogic;
      PROGFULL             : out std_ulogic;
      RDCOUNT              : out std_logic_vector(12 downto 0);
      RDERR                : out std_ulogic;
      RDRSTBUSY            : out std_ulogic;
      WRCOUNT              : out std_logic_vector(12 downto 0);
      WRERR                : out std_ulogic;
      WRRSTBUSY            : out std_ulogic;
      CASDIN               : in std_logic_vector(31 downto 0);
      CASDINP              : in std_logic_vector(3 downto 0);
      CASDOMUX             : in std_ulogic;
      CASDOMUXEN           : in std_ulogic;
      CASNXTRDEN           : in std_ulogic;
      CASOREGIMUX          : in std_ulogic;
      CASOREGIMUXEN        : in std_ulogic;
      CASPRVEMPTY          : in std_ulogic;
      DIN                  : in std_logic_vector(31 downto 0);
      DINP                 : in std_logic_vector(3 downto 0);
      RDCLK                : in std_ulogic;
      RDEN                 : in std_ulogic;
      REGCE                : in std_ulogic;
      RST                  : in std_ulogic;
      RSTREG               : in std_ulogic;
      SLEEP                : in std_ulogic;
      WRCLK                : in std_ulogic;
      WREN                 : in std_ulogic      
    );
  end FIFO18E2;

  architecture FIFO18E2_V of FIFO18E2 is
    
-- define constants
    constant MODULE_NAME : string := "FIFO18E2";
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;
    signal IS_RDCLK_INVERTED_BIN : std_ulogic := '0';
    signal IS_RDEN_INVERTED_BIN : std_ulogic := '0';
    signal IS_RSTREG_INVERTED_BIN : std_ulogic := '0';
    signal IS_RST_INVERTED_BIN : std_ulogic := '0';
    signal IS_WRCLK_INVERTED_BIN : std_ulogic := '0';
    signal IS_WREN_INVERTED_BIN : std_ulogic := '0';

    constant ADDR_WIDTH : integer := 14;
    constant COUNT_WIDTH : integer := 13;
    constant INIT_WIDTH : integer :=  36;
    constant D_WIDTH : integer :=  32;
    constant DP_WIDTH : integer := 4;

    constant mem_width : integer := 1;
    constant memp_width : integer := 1;
    constant mem_depth : integer := 16384;
    constant mem_depth_f : integer := 4096;
    constant memp_depth : integer := 2048;
    constant max_rd_loops   : integer := D_WIDTH/mem_width;
    constant max_wr_loops   : integer := D_WIDTH/mem_width;

    type mem_t   is array (0 to mem_depth-1) of std_ulogic;
    type memp_t  is array (0 to memp_depth-1) of std_ulogic;

    constant CASCADE_ORDER_FIRST : integer := 1;
    constant CASCADE_ORDER_LAST : integer := 2;
    constant CASCADE_ORDER_MIDDLE : integer := 3;
    constant CASCADE_ORDER_NONE : integer := 0;
    constant CASCADE_ORDER_PARALLEL : integer := 4;
    constant CLOCK_DOMAINS_COMMON : integer := 1;
    constant CLOCK_DOMAINS_INDEPENDENT : integer := 0;
    constant FIRST_WORD_FALL_THROUGH_FALSE   : integer := 0;
    constant FIRST_WORD_FALL_THROUGH_TRUE    : integer := 1;
    constant RDCOUNT_TYPE_EXTENDED_DATACOUNT : integer := 1;
    constant RDCOUNT_TYPE_RAW_PNTR : integer := 0;
    constant RDCOUNT_TYPE_SIMPLE_DATACOUNT : integer := 2;
    constant RDCOUNT_TYPE_SYNC_PNTR : integer := 3;
    constant READ_WIDTH_18  : integer := 16;
    constant READ_WIDTH_36  : integer := 32;
    constant READ_WIDTH_4   : integer := 4;
    constant READ_WIDTH_9   : integer := 8;
    constant REGISTER_MODE_DO_PIPELINED      : integer := 1;
    constant REGISTER_MODE_REGISTERED        : integer := 2;
    constant REGISTER_MODE_UNREGISTERED      : integer := 0;
    constant RSTREG_PRIORITY_REGCE : integer := 1;
    constant RSTREG_PRIORITY_RSTREG : integer := 0;
    constant SLEEP_ASYNC_FALSE : integer := 0;
    constant SLEEP_ASYNC_TRUE : integer := 1;
    constant WRCOUNT_TYPE_EXTENDED_DATACOUNT : integer := 1;
    constant WRCOUNT_TYPE_RAW_PNTR           : integer := 0;
    constant WRCOUNT_TYPE_SIMPLE_DATACOUNT   : integer := 2;
    constant WRCOUNT_TYPE_SYNC_PNTR          : integer := 3;
    constant WRITE_WIDTH_18  : integer := 16;
    constant WRITE_WIDTH_36  : integer := 32;
    constant WRITE_WIDTH_4   : integer := 4;
    constant WRITE_WIDTH_9   : integer := 8;


		function bit_or(
			 slv_in : in std_logic_vector
		 ) return std_ulogic is
			variable bit_or : std_ulogic := '0';
			constant L : natural := slv_in'length;
		begin
			 for bo in 0 to L-1 loop
				 if (slv_in(bo) = '1') then
					 bit_or := '1';
					 exit;
				 end if;
			 end loop;
			 return bit_or;
		end;

		function set_mask (
			 lmax  : in integer;
			 loops : in integer
			 ) return std_logic_vector is
			 variable mask : std_logic_vector(lmax+loops-1 downto 0) := (others=> '0');
		begin
			 mask := (std_logic_vector(to_signed(0, lmax)) &
								std_logic_vector(to_signed(-1, loops)));
			 return mask(lmax-1 downto 0);
		end;
    

    signal CASCADE_ORDER_A_BIN : integer;
    signal CLOCK_DOMAINS_BIN : integer;
    signal FIRST_WORD_FALL_THROUGH_BIN : integer;
    constant INIT_BIN : std_logic_vector (INIT_WIDTH-1 downto 0) := INIT;
    signal PROG_EMPTY_THRESH_BIN : integer := 256;
    signal PROG_FULL_THRESH_BIN : integer := 256;
    signal RDCOUNT_TYPE_BIN : integer;
    signal READ_WIDTH_BIN : integer := READ_WIDTH_4;
    signal REGISTER_MODE_BIN : integer;
    signal RSTREG_PRIORITY_BIN : integer;
    signal SLEEP_ASYNC_BIN : integer;
    constant SRVAL_BIN : std_logic_vector (INIT_WIDTH-1 downto 0) := SRVAL;
    signal WRCOUNT_TYPE_BIN : integer;
    signal WRITE_WIDTH_BIN : integer := WRITE_WIDTH_4;
 
    signal glblGSR : std_ulogic;
    
    signal CASDOUTP_out : std_logic_vector(DP_WIDTH-1 downto 0);
    signal CASDOUT_out : std_logic_vector(D_WIDTH-1 downto 0);
    signal CASNXTEMPTY_out : std_ulogic;
    signal CASPRVRDEN_out : std_ulogic;
    signal DOUTP_out : std_logic_vector(DP_WIDTH-1 downto 0);
    signal DOUT_out : std_logic_vector(D_WIDTH-1 downto 0);
    signal EMPTY_out : std_ulogic;
    signal FULL_out : std_ulogic;
    signal PROGEMPTY_out : std_ulogic := '1';
    signal PROGFULL_out : std_ulogic := '0';
    signal RDCOUNT_out : unsigned(COUNT_WIDTH-1 downto 0) := (others => '0');
    signal RDERR_out : std_ulogic:= '0';
    signal RDRSTBUSY_out : std_ulogic;
    signal WRCOUNT_out : unsigned(COUNT_WIDTH-1 downto 0) := (others => '0');
    signal WRERR_out : std_ulogic:= '0';
    signal WRRSTBUSY_out : std_ulogic;
    
    signal CASDOUTP_delay : std_logic_vector(DP_WIDTH-1 downto 0);
    signal CASDOUT_delay : std_logic_vector(D_WIDTH-1 downto 0);
    signal CASNXTEMPTY_delay : std_ulogic;
    signal CASPRVRDEN_delay : std_ulogic;
    signal DOUTP_delay : std_logic_vector(DP_WIDTH-1 downto 0);
    signal DOUT_delay : std_logic_vector(D_WIDTH-1 downto 0);
    signal EMPTY_delay : std_ulogic;
    signal FULL_delay : std_ulogic;
    signal PROGEMPTY_delay : std_ulogic := '1';
    signal PROGFULL_delay : std_ulogic := '0';
    signal RDCOUNT_delay : std_logic_vector(COUNT_WIDTH-1 downto 0);
    signal RDERR_delay : std_ulogic;
    signal RDRSTBUSY_delay : std_ulogic;
    signal WRCOUNT_delay : std_logic_vector(COUNT_WIDTH-1 downto 0);
    signal WRERR_delay : std_ulogic;
    signal WRRSTBUSY_delay : std_ulogic;
    
    signal CASDINP_delay : std_logic_vector(DP_WIDTH-1 downto 0);
    signal CASDIN_delay : std_logic_vector(D_WIDTH-1 downto 0);
    signal CASDOMUXEN_delay : std_ulogic;
    signal CASDOMUX_delay : std_ulogic;
    signal CASNXTRDEN_delay : std_ulogic;
    signal CASOREGIMUXEN_delay : std_ulogic;
    signal CASOREGIMUX_delay : std_ulogic;
    signal CASPRVEMPTY_delay : std_ulogic;
    signal DINP_delay : std_logic_vector(DP_WIDTH-1 downto 0);
    signal DIN_delay : std_logic_vector(D_WIDTH-1 downto 0);
    signal RDCLK_delay  : std_ulogic;
    signal RDEN_delay   : std_ulogic;
    signal REGCE_delay  : std_ulogic;
    signal RSTREG_delay : std_ulogic;
    signal RST_delay    : std_ulogic;
    signal SLEEP_delay : std_ulogic;
    signal WRCLK_delay  : std_ulogic;
    signal WREN_delay   : std_ulogic;
    
    signal CASDINPA_in     : std_logic_vector(DP_WIDTH-1 downto 0);
    signal CASDINA_in      : std_logic_vector(D_WIDTH-1 downto 0);
    signal CASDOMUXEN_A_in : std_ulogic;
    signal CASDOMUXA_in : std_ulogic;
--    signal CASNXTRDEN_in  : std_ulogic;
    signal CASOREGIMUXEN_A_in : std_ulogic;
    signal CASOREGIMUXA_in : std_ulogic;
    signal CASPRVEMPTY_in : std_ulogic;
    signal DINP_in : std_logic_vector(DP_WIDTH-1 downto 0);
    signal DIN_in  : std_logic_vector(D_WIDTH-1 downto 0);
    signal RDCLK_in  : std_ulogic;
    signal RDEN_in   : std_ulogic;
    signal REGCE_in  : std_ulogic;
    signal RSTREG_in : std_ulogic;
    signal RST_in    : std_ulogic;
    signal SLEEP_in : std_ulogic;
    signal WRCLK_in  : std_ulogic;
    signal WREN_in   : std_ulogic;
    
-- internal variables, signals, busses
    signal i              : integer := 0;
    signal j              : integer := 0;
    signal k              : integer := 0;
    signal ra             : integer := 0;
    signal raa            : integer := 0;
    signal wb             : integer := 0;
    signal rd_loops_a     : integer := 1;
    signal wr_loops_b     : integer := 1;
    signal INIT_MEM : std_ulogic := '0';
--    signal INIT_BIN : std_logic_vector(255 downto 0) := (others => '0');
    signal rdcount_adj    : integer := 0;
    signal wrcount_adj    : integer := 0;
    signal wr_adj         : integer := 0;
    signal RDEN_lat       : std_ulogic;
    signal RDEN_reg       : std_ulogic;
    signal fill_lat       : std_ulogic := '0';
    signal fill_reg       : std_ulogic := '0';
    signal SLEEP_int  : std_ulogic;
    signal SLEEP_reg  : std_ulogic := '0';
    signal SLEEP_reg1 : std_ulogic := '0';
    signal RSTREG_A_int     : std_ulogic;
    signal REGCE_A_int      : std_ulogic;
    signal CASDOMUXA_reg    : std_ulogic:= '0';
    signal CASOREGIMUXA_reg : std_ulogic:= '0';
    signal prog_empty     : std_ulogic;
    signal ram_full_c     : std_ulogic := '0';
    signal ram_full_i     : std_ulogic := '0';
    signal ram_empty      : std_ulogic;
    signal ram_empty_i    : std_ulogic:= '1';
    signal ram_empty_c    : std_ulogic:= '1';
    signal o_lat_empty    : std_ulogic := '1';
    signal o_reg_empty    : std_ulogic := '1';
    signal output_stages      : integer  := 0;
    signal o_stages_full  : std_ulogic;
    signal o_stages_empty : std_ulogic;
    signal o_stages_full_sync  : std_ulogic :='0';
    signal o_stages_full_sync1 : std_ulogic :='0';
    signal o_stages_full_sync2 : std_ulogic :='0';
    signal o_stages_full_sync3 : std_ulogic :='0';
    signal prog_full      : std_ulogic;
    signal INIT_A_int  : std_logic_vector (INIT_WIDTH-1 downto 0);
    signal SRVAL_A_int : std_logic_vector (INIT_WIDTH-1 downto 0);

    signal mem_rm_a   : std_logic_vector (D_WIDTH-1 downto 0) := (others => '0');
    signal memp_rm_a   : std_logic_vector (DP_WIDTH-1 downto 0) := (others => '0');
    signal mem_wm_b   : std_logic_vector (D_WIDTH-1 downto 0) := (others => '0');
    signal mem_wr_clk_b : std_ulogic;
    signal mem_wr_en_b : std_ulogic;
    signal mem_wr_en_b_wf : std_ulogic := '0';
    signal mem_we_b   : std_logic_vector (D_WIDTH-1 downto 0) := (others => '0');
    signal memp_we_b   : std_logic_vector (DP_WIDTH-1 downto 0) := (others => '0');
    signal mem_rm_douta_x  : std_logic_vector (D_WIDTH-1 downto 0) := (others => 'X');
    signal memp_rm_douta_x : std_logic_vector (DP_WIDTH-1 downto 0) := (others => 'X');
    signal mem_rm_douta  : std_logic_vector (D_WIDTH-1 downto 0);
    signal memp_rm_douta : std_logic_vector (DP_WIDTH-1 downto 0);
    signal mem_rd_clk_a : std_ulogic;
    signal mem_rd_en_a : std_ulogic;
    signal mem_rst_a : std_ulogic;

    signal mem       : mem_t;
    signal mem_rd_a    : std_logic_vector(D_WIDTH-1 downto 0);
    signal mem_wr_b    : std_logic_vector(D_WIDTH-1 downto 0) := (others => '0');
    signal wr_b_event  : std_ulogic := '0';
    signal mem_rd_b_rf : std_logic_vector(D_WIDTH-1 downto 0);
    signal mem_rd_b_wf : std_logic_vector(D_WIDTH/2-1 downto 0);
    signal mem_a_reg     : std_logic_vector (D_WIDTH-1 downto 0) := (others => '0');
    signal mem_a_reg_mux : std_logic_vector (D_WIDTH-1 downto 0);
    signal mem_a_mux     : std_logic_vector (D_WIDTH-1 downto 0);
    signal mem_a_lat     : std_logic_vector (D_WIDTH-1 downto 0) := (others => '0');
    signal mem_a_out     : std_logic_vector (D_WIDTH-1 downto 0);
    signal mem_a_pipe  : std_logic_vector (D_WIDTH-1 downto 0) := (others => '0');
    signal memp      : memp_t;
    signal memp_rd_a    : std_logic_vector(DP_WIDTH-1 downto 0);
    signal memp_wr_b    : std_logic_vector(DP_WIDTH-1 downto 0) := (others => '0');
    signal memp_rd_b_rf : std_logic_vector(DP_WIDTH-1 downto 0);
    signal memp_rd_b_wf : std_logic_vector(DP_WIDTH/2-1 downto 0);
    signal memp_a_reg     : std_logic_vector (DP_WIDTH-1 downto 0) := (others => '0');
    signal memp_a_reg_mux : std_logic_vector (DP_WIDTH-1 downto 0) := (others => '0');
    signal memp_a_mux     : std_logic_vector (DP_WIDTH-1 downto 0) := (others => '0');
    signal memp_a_lat     : std_logic_vector (DP_WIDTH-1 downto 0);
    signal memp_a_out     : std_logic_vector (DP_WIDTH-1 downto 0);
    signal memp_a_pipe  : std_logic_vector (DP_WIDTH-1 downto 0) := (others => '0');
    signal wr_addr_b_mask    : std_logic_vector (ADDR_WIDTH-1 downto 0) := (others => '1');
    signal rd_addr_a_slv     : std_logic_vector (ADDR_WIDTH-1 downto 0) := (others => '0');
    signal rd_addr_a         : unsigned (ADDR_WIDTH-1 downto 0) := (others => '0');
    signal rd_addr_a_wr      : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal wr_addr_b         : unsigned (ADDR_WIDTH-1 downto 0) := (others => '0');
    signal wr_addr_b_rd      : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal rd_addr           : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal wr_addr           : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
--    signal rd_addr_sync_wr3  : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal rd_addr_sync_wr2  : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal rd_addr_sync_wr1  : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal rd_addr_sync_wr   : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
--    signal wr_addr_sync_rd3  : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal wr_addr_sync_rd2  : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal wr_addr_sync_rd1  : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal wr_addr_sync_rd   : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal rd_addr_wr        : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal wr_addr_rd        : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal wr_simple_raw     : unsigned (COUNT_WIDTH-1 downto 0) := (others => '0');
    signal rd_simple_raw     : unsigned (COUNT_WIDTH-1 downto 0) := (others => '0');
    signal wr_simple         : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal rd_simple         : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal wr_simple_sync    : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
    signal rd_simple_sync    : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');

-- reset logic variables
    signal WRRST_int           : std_ulogic := '0';
    signal RST_sync            : std_ulogic := '0';
    signal WRRST_done          : std_ulogic := '0';
    signal WRRST_done1         : std_ulogic := '0';
    signal WRRST_done2         : std_ulogic := '0';
    signal RDRST_int           : std_ulogic;
    signal RDRST_done          : std_ulogic := '0';
    signal RDRST_done1         : std_ulogic := '0';
    signal RDRST_done2         : std_ulogic := '0';
    signal WRRST_done_wr       : std_ulogic := '0';
    signal WRRST_in_sync_rd    : std_ulogic := '0';
    signal WRRST_in_sync_rd1   : std_ulogic := '0';
    signal RDRSTBUSY_dly       : std_ulogic := '0';
    signal RDRSTBUSY_dly1      : std_ulogic := '0';
    signal RDRSTBUSY_dly2      : std_ulogic := '0';
    signal WRRSTBUSY_dly       : std_ulogic := '0';
    signal WRRSTBUSY_dly1      : std_ulogic := '0';

    signal sdp_mode     : std_ulogic := '1';
    signal sdp_mode_wr  : std_ulogic := '1';
    signal sdp_mode_rd  : std_ulogic := '1';

-- full/empty variables
   signal full_count_raw    : unsigned (COUNT_WIDTH-1 downto 0) := (others => '0');
   signal full_count_masked : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
   signal full_count        : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
   signal n_full : integer := 0;
   signal m_full : integer := 0;
   signal m_full_raw : integer := 0;
   signal n_empty : integer := 0;
   signal unr_ratio : integer := 1;
   signal prog_full_val : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
   signal prog_empty_val : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
   signal prog_empty_val_int : integer := 0;

   signal ram_one_from_full : boolean := FALSE;
   signal ram_two_from_full : boolean := FALSE;
   signal ram_one_read_from_not_full : boolean := FALSE;

   signal empty_count_raw : unsigned (COUNT_WIDTH-1 downto 0) := (others => '0');
   signal empty_count     : unsigned (COUNT_WIDTH-2 downto 0) := (others => '0');
   signal ram_one_read_from_empty : boolean := FALSE;
   signal ram_one_write_from_not_empty : boolean := FALSE;
   signal en_clk_sync : std_ulogic := '0';
   signal INIT_A_BIN_8_4   : std_logic_vector (3 downto 0) := (others => '0');
   signal INIT_A_BIN_7_0_4 : std_logic_vector (31 downto 0) := (others => '0');
   signal INIT_A_BIN_17_16_2 : std_logic_vector (3 downto 0) := (others => '0');
   signal INIT_A_BIN_15_0_2 : std_logic_vector (31 downto 0) := (others => '0');
   signal SRVAL_A_BIN_8_4   : std_logic_vector (3 downto 0) := (others => '0');
   signal SRVAL_A_BIN_7_0_4 : std_logic_vector (31 downto 0) := (others => '0');
   signal SRVAL_A_BIN_17_16_2 : std_logic_vector (3 downto 0) := (others => '0');
   signal SRVAL_A_BIN_15_0_2 : std_logic_vector (31 downto 0) := (others => '0');

    begin
-- input output assignments
    glblGSR     <= TO_X01(GSR);
    CASDOUT     <= CASDOUT_delay after OUT_DELAY;
    CASDOUTP    <= CASDOUTP_delay after OUT_DELAY;
    CASNXTEMPTY <= CASNXTEMPTY_delay after OUT_DELAY;
    CASPRVRDEN  <= CASPRVRDEN_delay after OUT_DELAY;
    DOUT        <= DOUT_delay after OUT_DELAY;
    DOUTP       <= DOUTP_delay after OUT_DELAY;
    EMPTY       <= EMPTY_delay after OUT_DELAY;
    FULL        <= FULL_delay after OUT_DELAY;
    PROGEMPTY   <= PROGEMPTY_delay after OUT_DELAY;
    PROGFULL    <= PROGFULL_delay after OUT_DELAY;
    RDCOUNT     <= RDCOUNT_delay after OUT_DELAY;
    RDERR       <= RDERR_delay after OUT_DELAY;
    RDRSTBUSY   <= RDRSTBUSY_delay after OUT_DELAY;
    WRCOUNT     <= WRCOUNT_delay after OUT_DELAY;
    WRERR       <= WRERR_delay after OUT_DELAY;
    WRRSTBUSY   <= WRRSTBUSY_delay after OUT_DELAY;
    
    CASDOUTP_delay    <= CASDOUTP_out;
    CASDOUT_delay     <= CASDOUT_out;
    CASNXTEMPTY_delay <= CASNXTEMPTY_out;
    CASPRVRDEN_delay  <= CASPRVRDEN_out;
    DOUTP_delay       <= DOUTP_out;
    DOUT_delay        <= DOUT_out;
    EMPTY_delay       <= EMPTY_out;
    FULL_delay        <= FULL_out;
    PROGEMPTY_delay   <= PROGEMPTY_out;
    PROGFULL_delay    <= PROGFULL_out;
    RDCOUNT_delay     <= std_logic_vector(RDCOUNT_out);
    RDERR_delay       <= RDERR_out;
    RDRSTBUSY_delay   <= RDRSTBUSY_out;
    WRCOUNT_delay     <= std_logic_vector(WRCOUNT_out);
    WRERR_delay       <= WRERR_out;
    WRRSTBUSY_delay   <= WRRSTBUSY_out;
    
    RDCLK_delay       <= RDCLK after INCLK_DELAY;
    WRCLK_delay       <= WRCLK after INCLK_DELAY;
    
    CASDINP_delay     <= CASDINP after IN_DELAY;
    CASDIN_delay      <= CASDIN after IN_DELAY;
    CASDOMUXEN_delay <= CASDOMUXEN after IN_DELAY;
    CASDOMUX_delay <= CASDOMUX after IN_DELAY;
    CASNXTRDEN_delay  <= CASNXTRDEN after IN_DELAY;
    CASOREGIMUXEN_delay <= CASOREGIMUXEN after IN_DELAY;
    CASOREGIMUX_delay <= CASOREGIMUX after IN_DELAY;
    CASPRVEMPTY_delay <= CASPRVEMPTY after IN_DELAY;
    DINP_delay        <= DINP after IN_DELAY;
    DIN_delay         <= DIN after IN_DELAY;
    RDEN_delay   <= RDEN after IN_DELAY;
    REGCE_delay  <= REGCE after IN_DELAY;
    RSTREG_delay <= RSTREG after IN_DELAY;
    RST_delay    <= RST after IN_DELAY;
    SLEEP_delay <= SLEEP after IN_DELAY;
    WREN_delay   <= WREN after IN_DELAY;
    
    CASDINPA_in  <= CASDINP_delay;
    CASDINA_in   <= CASDIN_delay;
    CASDOMUXEN_A_in <= CASDOMUXEN_delay;
    CASDOMUXA_in <= CASDOMUX_delay;
--    CASNXTRDEN_in <= CASNXTRDEN_delay;
    CASOREGIMUXEN_A_in <= CASOREGIMUXEN_delay;
    CASOREGIMUXA_in <= CASOREGIMUX_delay;
    CASPRVEMPTY_in <= CASPRVEMPTY_delay;
    DINP_in <= CASDINP_delay when ((CASCADE_ORDER_A_BIN = CASCADE_ORDER_LAST) or
                                   (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) else
               DINP_delay;
    DIN_in <=  CASDIN_delay  when ((CASCADE_ORDER_A_BIN = CASCADE_ORDER_LAST) or
                                   (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) else
               DIN_delay;
    RDCLK_in <= WRCLK_delay xor IS_WRCLK_INVERTED_BIN when
                ((CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON) and (en_clk_sync = '1')) else
                RDCLK_delay xor IS_RDCLK_INVERTED_BIN;
    RDEN_in  <= RDEN_delay xor IS_RDEN_INVERTED_BIN;
    REGCE_in  <= REGCE_delay;
    RSTREG_in <= RSTREG_delay xor IS_RSTREG_INVERTED_BIN;
    RST_in    <= RST_delay xor IS_RST_INVERTED_BIN;
    SLEEP_in <= SLEEP_delay;
    WRCLK_in  <= WRCLK_delay xor IS_WRCLK_INVERTED_BIN;
    WREN_in  <= WREN_delay xor IS_WREN_INVERTED_BIN;

  mem_rd_clk_a <= RDCLK_in;
  mem_wr_clk_b <= WRCLK_in;
  mem_wr_b <= DIN_in;

  mem_wr_en_b  <= WREN_in and not FULL_out and not WRRSTBUSY_out;
  mem_rd_en_a  <= RDEN_lat and not ram_empty and not RDRST_int;

  memp_wr_b <= DINP_in;
    
    IS_RDCLK_INVERTED_BIN  <= '1' when IS_RDCLK_INVERTED = '1' else '0';
    IS_RDEN_INVERTED_BIN   <= '1' when IS_RDEN_INVERTED = '1' else '0';
    IS_RSTREG_INVERTED_BIN <= '1' when IS_RSTREG_INVERTED = '1' else '0';
    IS_RST_INVERTED_BIN    <= '1' when IS_RST_INVERTED = '1' else '0';
    IS_WRCLK_INVERTED_BIN  <= '1' when IS_WRCLK_INVERTED = '1' else '0';
    IS_WREN_INVERTED_BIN   <= '1' when IS_WREN_INVERTED = '1' else '0';
    INIPROC : process
    variable Message : line;
    begin
      INIT_MEM <= '1' after 100 ps, '0' after 200 ps;
    -- case CLOCK_DOMAINS is
      if(CLOCK_DOMAINS = "INDEPENDENT") then
        CLOCK_DOMAINS_BIN <= CLOCK_DOMAINS_INDEPENDENT;
      elsif(CLOCK_DOMAINS = "COMMON") then
        CLOCK_DOMAINS_BIN <= CLOCK_DOMAINS_COMMON;
      else
        assert FALSE report "Error : CLOCK_DOMAINS = is not INDEPENDENT, COMMON." severity error;
      end if;
    -- end case;
    -- case FIRST_WORD_FALL_THROUGH is
      if(FIRST_WORD_FALL_THROUGH = "FALSE") then
        FIRST_WORD_FALL_THROUGH_BIN <= FIRST_WORD_FALL_THROUGH_FALSE;
      elsif(FIRST_WORD_FALL_THROUGH = "TRUE") then
        FIRST_WORD_FALL_THROUGH_BIN <= FIRST_WORD_FALL_THROUGH_TRUE;
      else
        assert FALSE report "Error : FIRST_WORD_FALL_THROUGH = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case RDCOUNT_TYPE is
      if(RDCOUNT_TYPE = "RAW_PNTR") then
        RDCOUNT_TYPE_BIN <= RDCOUNT_TYPE_RAW_PNTR;
      elsif(RDCOUNT_TYPE = "EXTENDED_DATACOUNT") then
        RDCOUNT_TYPE_BIN <= RDCOUNT_TYPE_EXTENDED_DATACOUNT;
      elsif(RDCOUNT_TYPE = "SIMPLE_DATACOUNT") then
        RDCOUNT_TYPE_BIN <= RDCOUNT_TYPE_SIMPLE_DATACOUNT;
      elsif(RDCOUNT_TYPE = "SYNC_PNTR") then
        RDCOUNT_TYPE_BIN <= RDCOUNT_TYPE_SYNC_PNTR;
      else
        assert FALSE report "Error : RDCOUNT_TYPE = is not RAW_PNTR, EXTENDED_DATACOUNT, SIMPLE_DATACOUNT, SYNC_PNTR." severity error;
      end if;
    -- end case;
    -- case REGISTER_MODE is
      if(REGISTER_MODE = "UNREGISTERED") then
        REGISTER_MODE_BIN <= REGISTER_MODE_UNREGISTERED;
      elsif(REGISTER_MODE = "DO_PIPELINED") then
        REGISTER_MODE_BIN <= REGISTER_MODE_DO_PIPELINED;
      elsif(REGISTER_MODE = "REGISTERED") then
        REGISTER_MODE_BIN <= REGISTER_MODE_REGISTERED;
      else
        assert FALSE report "Error : REGISTER_MODE = is not UNREGISTERED, DO_PIPELINED, REGISTERED." severity error;
      end if;
    -- end case;
    -- case RSTREG_PRIORITY is
      if(RSTREG_PRIORITY = "RSTREG") then
        RSTREG_PRIORITY_BIN <= RSTREG_PRIORITY_RSTREG;
      elsif(RSTREG_PRIORITY = "REGCE") then
        RSTREG_PRIORITY_BIN <= RSTREG_PRIORITY_REGCE;
      else
        assert FALSE report "Error : RSTREG_PRIORITY = is not RSTREG, REGCE." severity error;
      end if;
    -- end case;
    -- case SLEEP_ASYNC is
      if(SLEEP_ASYNC = "FALSE") then
        SLEEP_ASYNC_BIN <= SLEEP_ASYNC_FALSE;
      elsif(SLEEP_ASYNC = "TRUE") then
        SLEEP_ASYNC_BIN <= SLEEP_ASYNC_TRUE;
      else
        assert FALSE report "Error : SLEEP_ASYNC = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case WRCOUNT_TYPE is
      if(WRCOUNT_TYPE = "RAW_PNTR") then
        WRCOUNT_TYPE_BIN <= WRCOUNT_TYPE_RAW_PNTR;
      elsif(WRCOUNT_TYPE = "EXTENDED_DATACOUNT") then
        WRCOUNT_TYPE_BIN <= WRCOUNT_TYPE_EXTENDED_DATACOUNT;
      elsif(WRCOUNT_TYPE = "SIMPLE_DATACOUNT") then
        WRCOUNT_TYPE_BIN <= WRCOUNT_TYPE_SIMPLE_DATACOUNT;
      elsif(WRCOUNT_TYPE = "SYNC_PNTR") then
        WRCOUNT_TYPE_BIN <= WRCOUNT_TYPE_SYNC_PNTR;
      else
        assert FALSE report "Error : WRCOUNT_TYPE = is not RAW_PNTR, EXTENDED_DATACOUNT, SIMPLE_DATACOUNT, SYNC_PNTR." severity error;
      end if;
    -- end case;
    case READ_WIDTH is
      when  4    =>  READ_WIDTH_BIN <= READ_WIDTH_4; rd_loops_a <= 4;
      when  9    =>  READ_WIDTH_BIN <= READ_WIDTH_9; rd_loops_a <= 8;
      when  18   =>  READ_WIDTH_BIN <= READ_WIDTH_18; rd_loops_a <= 16;
      when  36   =>  READ_WIDTH_BIN <= READ_WIDTH_36; rd_loops_a <= 32;
      when others  =>  assert FALSE report "Error : READ_WIDTH is not 4, 9, 18 or 36." severity error;
    end case;
    case WRITE_WIDTH is
      when  4    =>  WRITE_WIDTH_BIN <= WRITE_WIDTH_4; wr_loops_b <= 4;
                     wr_addr_b_mask(5 downto 0) <= "111100";
      when  9    =>  WRITE_WIDTH_BIN <= WRITE_WIDTH_9; wr_loops_b <= 8;
                     wr_addr_b_mask(5 downto 0) <= "111000";
      when  18   =>  WRITE_WIDTH_BIN <= WRITE_WIDTH_18; wr_loops_b <= 16;
                     wr_addr_b_mask(5 downto 0) <= "110000";
      when  36   =>  WRITE_WIDTH_BIN <= WRITE_WIDTH_36; wr_loops_b <= 32;
                     wr_addr_b_mask(5 downto 0) <= "100000";
      when others  =>  assert FALSE report "Error : WRITE_WIDTH is not 4, 9, 18 or 36." severity error;
    end case;
    case READ_WIDTH is
      when  4   =>
        if (PROG_EMPTY_THRESH >= 1) and (PROG_EMPTY_THRESH <= mem_depth_f) then 
          PROG_EMPTY_THRESH_BIN <= PROG_EMPTY_THRESH;
        else 
          Write ( Message, string'("Error : PROG_EMPTY_THRESH is not in range 1 .. "));
          Write ( Message, mem_depth_f);
          Write ( Message, string'("."));
          assert FALSE report Message.all severity error;
          DEALLOCATE(Message);
        end if;
      when  9   => 
        if (PROG_EMPTY_THRESH >= 1) and (PROG_EMPTY_THRESH <= mem_depth_f/2) then 
          PROG_EMPTY_THRESH_BIN <= PROG_EMPTY_THRESH;
        else 
          Write ( Message, string'("Error : PROG_EMPTY_THRESH is not in range 1 .. "));
          Write ( Message, mem_depth_f/2);
          Write ( Message, string'("."));
          assert FALSE report Message.all severity error;
          DEALLOCATE(Message);
        end if;
      when  18   =>
        if (PROG_EMPTY_THRESH >= 1) and (PROG_EMPTY_THRESH <= mem_depth_f/4) then 
          PROG_EMPTY_THRESH_BIN <= PROG_EMPTY_THRESH;
        else 
          Write ( Message, string'("Error : PROG_EMPTY_THRESH is not in range 1 .. "));
          Write ( Message, mem_depth_f/4);
          Write ( Message, string'("."));
          assert FALSE report Message.all severity error;
          DEALLOCATE(Message);
        end if;
      when  36   =>
        if (PROG_EMPTY_THRESH >= 1) and (PROG_EMPTY_THRESH <= mem_depth_f/8) then 
          PROG_EMPTY_THRESH_BIN <= PROG_EMPTY_THRESH;
        else 
          Write ( Message, string'("Error : PROG_EMPTY_THRESH is not in range 1 .. "));
          Write ( Message, mem_depth_f/8);
          Write ( Message, string'("."));
          assert FALSE report Message.all severity error;
          DEALLOCATE(Message);
        end if;
      when others  =>  assert FALSE report "Error : READ_WIDTH is out of range in PROG_EMPTY_THRESH check" severity error;
    end case;
    case WRITE_WIDTH is
      when  4   =>
        if (PROG_FULL_THRESH >= 1) and (PROG_FULL_THRESH <= mem_depth_f) then 
          PROG_FULL_THRESH_BIN <= PROG_FULL_THRESH;
        else 
          Write ( Message, string'("Error : PROG_FULL_THRESH is not in range 1 .. "));
          Write ( Message, mem_depth_f);
          Write ( Message, string'("."));
          assert FALSE report Message.all severity error;
          DEALLOCATE(Message);
        end if;
      when  9   => 
        if (PROG_FULL_THRESH >= 1) and (PROG_FULL_THRESH <= mem_depth_f/2) then 
          PROG_FULL_THRESH_BIN <= PROG_FULL_THRESH;
        else 
          Write ( Message, string'("Error : PROG_FULL_THRESH is not in range 1 .. "));
          Write ( Message, mem_depth_f/2);
          Write ( Message, string'("."));
          assert FALSE report Message.all severity error;
          DEALLOCATE(Message);
        end if;
      when  18   =>
        if (PROG_FULL_THRESH >= 1) and (PROG_FULL_THRESH <= mem_depth_f/4) then 
          PROG_FULL_THRESH_BIN <= PROG_FULL_THRESH;
        else 
          Write ( Message, string'("Error : PROG_FULL_THRESH is not in range 1 .. "));
          Write ( Message, mem_depth_f/4);
          Write ( Message, string'("."));
          assert FALSE report Message.all severity error;
          DEALLOCATE(Message);
        end if;
      when  36   =>
        if (PROG_FULL_THRESH >= 1) and (PROG_FULL_THRESH <= mem_depth_f/8) then 
          PROG_FULL_THRESH_BIN <= PROG_FULL_THRESH;
        else 
          Write ( Message, string'("Error : PROG_FULL_THRESH is not in range 1 .. "));
          Write ( Message, mem_depth_f/8);
          Write ( Message, string'("."));
          assert FALSE report Message.all severity error;
          DEALLOCATE(Message);
        end if;
      when others  =>  assert FALSE report "Error : WRITE_WIDTH is out of range in PROG_FULL_THRESH check" severity error;
    end case;
    wait;
    end process INIPROC;

    INITPROC : process (INIT_MEM)
    begin
      if (rising_edge(INIT_MEM)) then
        mem_rm_a  <= set_mask(D_WIDTH, rd_loops_a);
        memp_rm_a  <= set_mask(DP_WIDTH, rd_loops_a/8);
        mem_wm_b  <= set_mask(D_WIDTH, wr_loops_b);
      end if;
    end process INITPROC;

   SLR : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if (glblGSR = '1') then
          SLEEP_reg <= '0';
          SLEEP_reg1 <= '0';
       else
          SLEEP_reg <= SLEEP_in;
          SLEEP_reg1 <= SLEEP_reg;
       end if;
     end if;
     end process SLR;

   SLEEP_int <= SLEEP_reg when (SLEEP_ASYNC_BIN = SLEEP_ASYNC_FALSE) else SLEEP_in;

   REGCE_A_int  <= RDEN_reg when (REGISTER_MODE_BIN /= REGISTER_MODE_DO_PIPELINED) else REGCE_in;
   RSTREG_A_int <= RDRST_int when (REGISTER_MODE_BIN /= REGISTER_MODE_DO_PIPELINED) else
                   RSTREG_in  when (RSTREG_PRIORITY_BIN = RSTREG_PRIORITY_RSTREG) else
                   RSTREG_in and REGCE_A_int;
   RDEN_lat   <= RDEN_in or fill_reg or fill_lat;
   RDEN_reg  <= RDEN_in or fill_reg ;
   DOUT_out  <= CASDINA_in when (((CASCADE_ORDER_A_BIN = CASCADE_ORDER_LAST) or
                   (CASCADE_ORDER_A_BIN = CASCADE_ORDER_PARALLEL) or
                   (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) and CASDOMUXA_reg = '1') else
                (mem_a_mux xor mem_rm_douta);
   DOUTP_out <= CASDINPA_in when (((CASCADE_ORDER_A_BIN = CASCADE_ORDER_LAST) or
                   (CASCADE_ORDER_A_BIN = CASCADE_ORDER_PARALLEL) or
                   (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) and CASDOMUXA_reg = '1') else
                (memp_a_mux xor memp_rm_douta);

   mem_a_mux  <= mem_a_reg when ((REGISTER_MODE_BIN = REGISTER_MODE_REGISTERED) or
                     (REGISTER_MODE_BIN = REGISTER_MODE_DO_PIPELINED)) else mem_a_lat;
   memp_a_mux <= memp_a_reg when ((REGISTER_MODE_BIN = REGISTER_MODE_REGISTERED) or
                     (REGISTER_MODE_BIN = REGISTER_MODE_DO_PIPELINED)) else memp_a_lat;
   INIT_A_BIN_8_4     <= INIT_BIN(8) & INIT_BIN(8) & INIT_BIN(8) & INIT_BIN(8);
   INIT_A_BIN_7_0_4   <= INIT_BIN(7 downto 0) & INIT_BIN(7 downto 0) &
                         INIT_BIN(7 downto 0) & INIT_BIN(7 downto 0);
   INIT_A_BIN_17_16_2 <= INIT_BIN(17 downto 16) & INIT_BIN(17 downto 16);
   INIT_A_BIN_15_0_2  <= INIT_BIN(15 downto 0) & INIT_BIN(15 downto 0);
   INIT_A_int <=
    (INIT_A_BIN_8_4     & INIT_A_BIN_7_0_4)  when (READ_WIDTH_BIN = READ_WIDTH_9) else
    (INIT_A_BIN_17_16_2 & INIT_A_BIN_15_0_2) when (READ_WIDTH_BIN = READ_WIDTH_18) else
     INIT_BIN;
   SRVAL_A_BIN_8_4     <= SRVAL_BIN(8) & SRVAL_BIN(8) & SRVAL_BIN(8) & SRVAL_BIN(8);
   SRVAL_A_BIN_7_0_4   <= SRVAL_BIN(7 downto 0) & SRVAL_BIN(7 downto 0) &
                         SRVAL_BIN(7 downto 0) & SRVAL_BIN(7 downto 0);
   SRVAL_A_BIN_17_16_2 <= SRVAL_BIN(17 downto 16) & SRVAL_BIN(17 downto 16);
   SRVAL_A_BIN_15_0_2  <= SRVAL_BIN(15 downto 0) & SRVAL_BIN(15 downto 0);
   SRVAL_A_int <=
    (SRVAL_A_BIN_8_4     & SRVAL_A_BIN_7_0_4)  when (READ_WIDTH_BIN = READ_WIDTH_9) else
    (SRVAL_A_BIN_17_16_2 & SRVAL_A_BIN_15_0_2) when (READ_WIDTH_BIN = READ_WIDTH_18) else
     SRVAL_BIN;

   rd_addr <= rd_addr_a(ADDR_WIDTH-1 downto 2);
   wr_addr <= wr_addr_b(ADDR_WIDTH-1 downto 2);
   rd_addr_wr <= rd_addr when (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON) else rd_addr_sync_wr;
   wr_addr_rd <= wr_addr when (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON) else wr_addr_sync_rd;
-- need to add ecc cases
   o_stages_empty <= ram_empty   when  (output_stages=0) else
                     o_lat_empty when  (output_stages=1) else
                     o_reg_empty; -- 2
   o_stages_full <= not o_stages_empty when (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON)
                   else o_stages_full_sync;

-- cascade out
   CASDOUT_out  <= DOUT_out when ((CASCADE_ORDER_A_BIN = CASCADE_ORDER_FIRST) or
                            (CASCADE_ORDER_A_BIN = CASCADE_ORDER_PARALLEL) or
                            (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) else (others => '0');
   CASDOUTP_out <= DOUTP_out when ((CASCADE_ORDER_A_BIN = CASCADE_ORDER_FIRST) or
                            (CASCADE_ORDER_A_BIN = CASCADE_ORDER_PARALLEL) or
                            (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) else (others => '0');
   CASNXTEMPTY_out <= EMPTY_out when ((CASCADE_ORDER_A_BIN = CASCADE_ORDER_FIRST) or
                            (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) else '0';
   CASPRVRDEN_out  <= not (CASPRVEMPTY_in or FULL_out) when 
                          ((CASCADE_ORDER_A_BIN = CASCADE_ORDER_LAST ) or
                           (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) else '0';

-- start model internals

  WADJ : process begin
    if (rd_loops_a >= wr_loops_b) then wr_adj <= rd_loops_a/wr_loops_b;
    else wr_adj <= 1; end if;
    wait on wr_loops_b, rd_loops_a;
    end process WADJ;

  OS : process
    variable output_stages_tmp : integer;
    begin
      output_stages_tmp := 0;
      if (REGISTER_MODE_BIN = REGISTER_MODE_REGISTERED) then
          output_stages_tmp := output_stages_tmp + 1; end if;
      if (FIRST_WORD_FALL_THROUGH_BIN = FIRST_WORD_FALL_THROUGH_TRUE) then
          output_stages_tmp := output_stages_tmp + 1; end if;
      output_stages <= output_stages_tmp;
  wait on REGISTER_MODE_BIN, FIRST_WORD_FALL_THROUGH_BIN;
  end process OS;

  CADJ : process begin
     if (((wr_loops_b>=rd_loops_a) and (output_stages=0)) or
         ((wr_loops_b>=output_stages*rd_loops_a) and (output_stages>0))) then
          wrcount_adj <= 1;
     elsif ((output_stages>1) or
            (FIRST_WORD_FALL_THROUGH_BIN = FIRST_WORD_FALL_THROUGH_TRUE)) then
          wrcount_adj <= output_stages*wr_adj;
     else
          wrcount_adj <= 0;
     end if;
     rdcount_adj <= output_stages;
     wait on wr_adj, output_stages, wr_loops_b, rd_loops_a;
     end process CADJ;

-- reset logic
   RDRSTBUSY_out <= RDRST_int;
   WRRSTBUSY_out <= WRRST_int or WRRSTBUSY_dly;
   mem_rst_a <= RDRST_int;

-- RST_in sampled by WRCLK cleared by WR done
   WRI : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if (RST_in = '1' and RST_sync = '0') then
         RST_sync <= '1';
       elsif ((WRRST_done = '1')) then
         RST_sync <= '0';
       end if;
     end if;
     end process WRI;

   WRRST_done_wr <= WRRST_int when (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON) else WRRST_done;
   WRR : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if (RST_in = '1' and WRRSTBUSY_out = '0') then
         WRRST_int <= '1' after 1 ps;
       elsif ((WRRST_done_wr = '1')) then
         WRRST_int <= '0' after 1 ps;
       end if;
     end if;
     end process WRR;

-- WRRST_int sampled by RDCLK twice => RDRST_int in CDI
   RDRST_int <= WRRST_int when (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON) else
                WRRST_in_sync_rd;
   WRIRD : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if (glblGSR = '1') then
          WRRST_in_sync_rd1 <= '0';
          WRRST_in_sync_rd  <= '0';
       else
          WRRST_in_sync_rd1 <= WRRST_int after 1 ps;
          WRRST_in_sync_rd  <= WRRST_in_sync_rd1 after 1 ps;
       end if;
     end if;
     end process WRIRD;

-- 3 rdclks to be done RD side
   RRD : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (RDRST_int = '0') or
           (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON)) then
          RDRST_done2 <= '0';
          RDRST_done1 <= '0';
          RDRST_done  <= '0';
       else
          RDRST_done2 <= RDRST_int;
          RDRST_done1 <= RDRST_done2;
          RDRST_done  <= RDRST_done1;
       end if;
     end if;
     end process RRD;

-- 3 wrclks to be done WR side after RDRST_done
   WRD : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if ((glblGSR = '1') or (WRRST_done = '1') or (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON)) then
          WRRST_done2 <= '0';
          WRRST_done1 <= '0';
          WRRST_done  <= '0';
       elsif (WRRST_int = '1') then
          WRRST_done2 <= RDRST_done;
          WRRST_done1 <= WRRST_done2;
          WRRST_done  <= WRRST_done1;
       end if;
     end if;
     end process WRD;

-- bug fix
   RBD : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON)) then
          RDRSTBUSY_dly2 <= '0';
          RDRSTBUSY_dly1 <= '0';
          RDRSTBUSY_dly  <= '0';
       else
          RDRSTBUSY_dly2 <= RDRST_int;
          RDRSTBUSY_dly1 <= RDRSTBUSY_dly2;
          RDRSTBUSY_dly  <= RDRSTBUSY_dly1;
       end if;
     end if;
     end process RBD;

   WBD : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if ((glblGSR = '1') or (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON)) then
          WRRSTBUSY_dly1 <= '0';
          WRRSTBUSY_dly  <= '0';
       else
          WRRSTBUSY_dly1 <= RDRSTBUSY_dly;
          WRRSTBUSY_dly  <= WRRSTBUSY_dly1;
       end if;
     end if;
     end process WBD;

-- cascade control
   COMA : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if (glblGSR = '1') then
          CASDOMUXA_reg <= '0';
       elsif (CASDOMUXEN_A_in = '1') then
          CASDOMUXA_reg <= CASDOMUXA_in;
       end if;
     end if;
     end process COMA;

   CORA : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if (glblGSR = '1') then
          CASOREGIMUXA_reg <= '0';
       elsif (CASOREGIMUXEN_A_in = '1') then
          CASOREGIMUXA_reg <= CASOREGIMUXA_in;
       end if;
     end if;
     end process CORA;

-- output register
   mem_a_reg_mux  <= CASDINA_in when
                     (((CASCADE_ORDER_A_BIN = CASCADE_ORDER_LAST) or
                       (CASCADE_ORDER_A_BIN = CASCADE_ORDER_PARALLEL) or
                       (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) and
                      CASOREGIMUXA_reg = '1') else mem_a_lat;
   memp_a_reg_mux  <= CASDINPA_in when
                      (((CASCADE_ORDER_A_BIN = CASCADE_ORDER_LAST) or
                        (CASCADE_ORDER_A_BIN = CASCADE_ORDER_PARALLEL) or
                        (CASCADE_ORDER_A_BIN = CASCADE_ORDER_MIDDLE)) and
                       CASOREGIMUXA_reg = '1') else memp_a_lat;

   ORA : process (mem_rd_clk_a, INIT_MEM) begin
     if (rising_edge(mem_rd_clk_a) or INIT_MEM = '1') then
       if (glblGSR = '1' or INIT_MEM = '1') then
         memp_a_reg <= INIT_A_int(D_WIDTH+DP_WIDTH-1 downto D_WIDTH);
         mem_a_reg  <= INIT_A_int(D_WIDTH-1 downto 0);
       elsif (RSTREG_A_int = '1') then
         memp_a_reg <= SRVAL_A_int(D_WIDTH+DP_WIDTH-1 downto D_WIDTH);
         mem_a_reg  <= SRVAL_A_int(D_WIDTH-1 downto 0);
       elsif (REGCE_A_int = '1') then
         mem_a_reg <= mem_a_reg_mux;
         memp_a_reg <= memp_a_reg_mux;
       end if;
     end if;
     end process ORA;

-- RDCOUNT sync to RDCLK
   rd_simple_raw <= ('1' & wr_addr_rd) - ('0' & rd_addr);
   rd_simple     <= rd_simple_raw(COUNT_WIDTH-2 downto 0);
   RCO : process begin
     if (RDRST_int ='1') then
      RDCOUNT_out <= (others => '0');
     elsif (RDCOUNT_TYPE_BIN = RDCOUNT_TYPE_RAW_PNTR) then
      RDCOUNT_out(COUNT_WIDTH-2 downto 0) <= rd_addr/(rd_loops_a/4);
     elsif (RDCOUNT_TYPE_BIN = RDCOUNT_TYPE_SYNC_PNTR) then
      RDCOUNT_out(COUNT_WIDTH-2 downto 0) <= rd_addr_wr/(rd_loops_a/4);
     elsif (RDCOUNT_TYPE_BIN = RDCOUNT_TYPE_SIMPLE_DATACOUNT) then
      RDCOUNT_out(COUNT_WIDTH-2 downto 0) <= rd_simple_sync/(rd_loops_a/4);
     elsif (RDCOUNT_TYPE_BIN = RDCOUNT_TYPE_EXTENDED_DATACOUNT) then
      RDCOUNT_out(COUNT_WIDTH-2 downto 0) <= rd_simple_sync/(rd_loops_a/4) + rdcount_adj;
     else 
      RDCOUNT_out <= (others => '0');
     end if;
     wait on RDRST_int, RDCOUNT_TYPE_BIN, rd_loops_a, rd_addr, rd_addr_wr, rd_simple_sync, rdcount_adj;
   end process RCO;

   RDSS : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (RDRST_int = '1')) then
         rd_simple_sync <= (others => '0');
       else 
         if ((rd_simple = 0) and (FULL_out = '1')) then
            rd_simple_sync <= '1' & rd_simple(COUNT_WIDTH-3 downto 0);
         else
            rd_simple_sync <= rd_simple;
         end if;
       end if;
     end if;
     end process RDSS;

-- WRCOUNT sync to WRCLK
   wr_simple_raw <= ('1' & wr_addr) - ('0' & rd_addr_wr);
   wr_simple     <= wr_simple_raw(COUNT_WIDTH-2 downto 0);
   WCO : process begin
     if (WRRST_int ='1') then
      WRCOUNT_out <= (others => '0');
     elsif (WRCOUNT_TYPE_BIN = WRCOUNT_TYPE_RAW_PNTR) then
      WRCOUNT_out(COUNT_WIDTH-2 downto 0) <= wr_addr/(wr_loops_b/4);
     elsif (WRCOUNT_TYPE_BIN = WRCOUNT_TYPE_SYNC_PNTR) then
      WRCOUNT_out(COUNT_WIDTH-2 downto 0) <= wr_addr_rd/(wr_loops_b/4);
     elsif (WRCOUNT_TYPE_BIN = WRCOUNT_TYPE_SIMPLE_DATACOUNT) then
      WRCOUNT_out(COUNT_WIDTH-2 downto 0) <= wr_simple_sync/(wr_loops_b/4);
     elsif (WRCOUNT_TYPE_BIN = WRCOUNT_TYPE_EXTENDED_DATACOUNT) then
      WRCOUNT_out(COUNT_WIDTH-2 downto 0) <= wr_simple_sync/(wr_loops_b/4) + wrcount_adj;
     else 
      WRCOUNT_out <= (others => '0');
     end if;
     wait on WRRST_int, WRCOUNT_TYPE_BIN, wr_loops_b, wr_addr, wr_addr_rd, wr_simple_sync, rdcount_adj;
   end process WCO;

   WDSS : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if ((glblGSR = '1') or (WRRST_int = '1')) then
         wr_simple_sync <= (others => '0');
       else 
         wr_simple_sync <= wr_simple;
       end if;
     end if;
     end process WDSS;

-- with any output stage or FWFT fill the ouptut latch
-- when ram not empty and o_latch empty
   OLE  : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (RDRST_int = '1')) then
          o_lat_empty <= '1';
       elsif (fill_lat = '1') then
          o_lat_empty <= '0';
       elsif ((ram_empty = '1') and (RDEN_lat = '1')) then
          o_lat_empty <= '1';
       end if;
     end if;
     end process OLE;

   OLF  : process (mem_rd_clk_a) begin
     if (falling_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (RDRST_int = '1')) then
          fill_lat <= '0';
       elsif ((ram_empty = '0') and (o_lat_empty = '1') and (output_stages>0)) then
          fill_lat <= '1';
       else
          fill_lat <= '0';
       end if;
     end if;
     end process OLF;

-- FWFT and 
-- REGISTERED fill the ouptut register when o_latch not empty.
-- Empty on external read and prev stage also empty

   ORE  : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (RDRST_int = '1')) then
          o_reg_empty <= '1';
       elsif ((o_lat_empty = '0') and (RDEN_reg = '1')) then
          o_reg_empty <= '0';
       elsif ((o_lat_empty = '1') and (RDEN_reg = '1')) then
          o_reg_empty <= '1';
       end if;
     end if;
     end process ORE;

   ORF  : process (mem_rd_clk_a) begin
     if (falling_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (RDRST_int = '1')) then
          fill_reg <= '0';
       elsif ((o_lat_empty = '0') and (o_reg_empty = '1') and
              (output_stages=2)) then
          fill_reg <= '1';
       else
          fill_reg <= '0';
       end if;
     end if;
     end process ORF;


-- read engine
   RDE  : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if (glblGSR = '1') then
         RDERR_out <= '0';
       elsif ((RDEN_in = '1') and  ((EMPTY_out = '1') or (RDRST_int = '1'))) then
         RDERR_out <= '1';
       else
         RDERR_out <= '0';
       end if;
     end if;
     end process RDE;

   WAS  : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if (glblGSR = '1' or RDRST_int = '1') then
         rd_addr_a <= (others => '0');
         rd_addr_a_wr <= (others => '0');
         wr_addr_sync_rd2 <= (others => '0');
         wr_addr_sync_rd1 <= (others => '0');
         wr_addr_sync_rd  <= (others => '0');
       else
         if (mem_rd_en_a = '1') then
           rd_addr_a <= rd_addr_a + rd_loops_a;
         end if;
         rd_addr_a_wr <= rd_addr;
         wr_addr_sync_rd2 <= wr_addr_b_rd;
         wr_addr_sync_rd1 <= wr_addr_sync_rd2;
         wr_addr_sync_rd  <= wr_addr_sync_rd1;
       end if;
     end if;
     end process WAS;

   MRAA : process (rd_addr_a, mem_rd_en_a, wr_b_event, INIT_MEM) begin
     if ((mem_rd_en_a = '1' or INIT_MEM = '1') and ADDR_IS_VALID(rd_addr_a_slv) and 
         (mem_rst_a = '0')) then
       for raa in 0 to (rd_loops_a-1) loop
         mem_rd_a(raa) <= mem(to_integer(rd_addr_a) + raa);
         if (raa<mem_width*rd_loops_a/8) then
           memp_rd_a(raa) <= memp(to_integer(rd_addr_a)/8 + raa);
         end if;
       end loop;
     end if;
   end process MRAA;

   MRA  : process
     variable Message : line;
     begin
     if (rising_edge(mem_rd_clk_a) or INIT_MEM='1') then
       if (glblGSR = '1' or INIT_MEM='1') then
         for ra in 0 to (rd_loops_a-1) loop
           mem_a_lat(ra) <= INIT_A_int(ra);
           if (ra<rd_loops_a/8) then
             memp_a_lat(ra) <= INIT_A_int(D_WIDTH + ra);
           end if;
         end loop;
       elsif ((SLEEP_in = '1' or SLEEP_int = '1') and mem_rd_en_a = '1') then
         Write ( Message, string'("DRC Error on "));
         Write ( Message, string'(MODULE_NAME));
         Write ( Message, string'(" : instance "));
         Write ( Message, string'(FIFO18E2_V'INSTANCE_NAME));
         Write ( Message, string'(" at time "));
         Write ( Message, now);
         Write ( Message, string'("."));
         Write ( Message, LF);
         Write ( Message, string'("READ on port A attempted while in SLEEP mode."));
         assert false report Message.all severity warning;
         DEALLOCATE (Message);
         for ra in 0 to (rd_loops_a-1) loop
           mem_a_lat(ra) <= 'X';
           if (ra<rd_loops_a/8) then
             memp_a_lat(ra) <= 'X';
           end if;
         end loop;
       elsif (mem_rst_a = '1') then
         for ra in 0 to (rd_loops_a-1) loop
           mem_a_lat(ra) <= SRVAL_A_int(ra);
           if (ra<rd_loops_a/8) then
             memp_a_lat(ra) <= SRVAL_A_int(D_WIDTH + ra);
           end if;
         end loop;
       elsif (mem_rd_en_a = '1') then
           mem_a_lat <= mem_rd_a;
           memp_a_lat <= memp_rd_a;
       end if;
     end if;
     wait on mem_rd_clk_a, INIT_MEM;
   end process MRA;

   WDE  : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if (glblGSR = '1') then
         WRERR_out <= '0';
       elsif ((WREN_in = '1') and  ((FULL_out = '1') or (WRRSTBUSY_out = '1'))) then
         WRERR_out <= '1';
       else
         WRERR_out <= '0';
       end if;
     end if;
     end process WDE;

   RAS  : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if ((glblGSR = '1') or (WRRSTBUSY_out = '1')) then
         wr_addr_b <= (others => '0');
         wr_addr_b_rd <= (others => '0');
         o_stages_full_sync2 <= '0';
         o_stages_full_sync1 <= '0';
         o_stages_full_sync  <= '0';
         rd_addr_sync_wr2 <= (others => '0');
         rd_addr_sync_wr1 <= (others => '0');
         rd_addr_sync_wr  <= (others => '0');
       else
         if (mem_wr_en_b = '1') then
           wr_addr_b <= wr_addr_b + wr_loops_b;
         end if;
         wr_addr_b_rd <= wr_addr;
         o_stages_full_sync2 <= not o_stages_empty;
         o_stages_full_sync1 <= o_stages_full_sync2;
         o_stages_full_sync  <= o_stages_full_sync1;
         rd_addr_sync_wr2 <= rd_addr_a_wr;
         rd_addr_sync_wr1 <= rd_addr_sync_wr2;
         rd_addr_sync_wr  <= rd_addr_sync_wr1;
       end if;
     end if;
     end process RAS;

-- write engine
   MWE  : process
     variable Message : line;
     begin
     if (rising_edge(mem_wr_clk_b) and (mem_wr_en_b = '1')) then
       if (SLEEP_in = '1' or SLEEP_int = '1') then
         Write ( Message, string'("DRC Error on "));
         Write ( Message, string'(MODULE_NAME));
         Write ( Message, string'(" : instance "));
         Write ( Message, string'(FIFO18E2_V'INSTANCE_NAME));
         Write ( Message, string'(" at time "));
         Write ( Message, now);
         Write ( Message, string'("."));
         Write ( Message, LF);
         Write ( Message, string'("WRITE on port B attempted while in SLEEP mode."));
         assert false report Message.all severity warning;
         DEALLOCATE (Message);
       else
         for wb in 0 to wr_loops_b-1 loop
           if (mem_we_b(wb) = '1') then
             mem (to_integer(wr_addr_b)+wb) <= mem_wr_b(wb);
           end if;
           if (wb<wr_loops_b/8) then
             if (memp_we_b(wb) = '1') then
               memp (to_integer(wr_addr_b)/8 + wb) <= memp_wr_b(wb);
             end if;
           end if;
         end loop;
         wr_b_event <= not wr_b_event;
       end if;
     end if;
     wait on mem_wr_clk_b;
   end process MWE;

  mem_rm_douta <= not mem_rm_a and mem_rm_douta_x
                  when sdp_mode_rd = '0' else (others => '0');
  memp_rm_douta <= not memp_rm_a and memp_rm_douta_x
                   when sdp_mode_rd = '0' else (others => '0');
  rd_addr_a_slv <= std_logic_vector(rd_addr_a);
  mem_we_b  <= std_logic_vector(to_signed(-1, D_WIDTH));
  memp_we_b <= std_logic_vector(to_signed(-1, DP_WIDTH)) when 
               (WRITE_WIDTH_BIN > WRITE_WIDTH_4) else std_logic_vector(to_signed(0,DP_WIDTH));
-- full flag
   prog_full <= '1' when ((full_count_masked <= prog_full_val) and
                          ((full_count > 0) or (FULL_out = '1'))) else '0';
   prog_full_val <= mem_depth_f - (PROG_FULL_THRESH_BIN*wr_loops_b/4) + to_unsigned(m_full,COUNT_WIDTH-1);
   unr_ratio <= wr_loops_b/rd_loops_a - 1 when (wr_loops_b>=rd_loops_a) else 0;
   m_full <= ((((m_full_raw-1)/wr_loops_b)+1)*wr_loops_b)/4;
   m_full_raw <= output_stages*rd_loops_a/4 when ((output_stages>1) and
                                          (o_stages_full = '1')) else
             rd_loops_a/4 when (output_stages=1) else unr_ratio;
   n_empty <= output_stages;
   prog_empty_val_int <= (PROG_EMPTY_THRESH_BIN - output_stages)*rd_loops_a/4 + rd_loops_a/4;
   prog_empty_val <= TO_UNSIGNED(prog_empty_val_int,COUNT_WIDTH-1);

   full_count_raw <= ('1' & rd_addr_wr) - ('0' & wr_addr);
   full_count     <= full_count_raw(COUNT_WIDTH-2 downto 0);
   full_count_masked <= unsigned(std_logic_vector(full_count) and wr_addr_b_mask(COUNT_WIDTH downto 2));
   FULL_out <= ram_full_c when (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON) else ram_full_i;
-- ram_full independent clocks is one_from_full common clocks
   ram_one_from_full <= ((full_count < 2*wr_loops_b/4) and (full_count > 0));
   ram_two_from_full <= ((full_count < 3*wr_loops_b/4) and (full_count > 0));
-- when full common clocks, next read makes it not full
   ram_one_read_from_not_full <= ((full_count + rd_loops_a/4 >= wr_loops_b/4) and (ram_full_c = '1'));

   RFC  : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if ((glblGSR = '1') or (WRRSTBUSY_out = '1')) then
         ram_full_c <= '0';
       elsif ((mem_wr_en_b = '1') and ((mem_rd_en_a = '1') and (rd_loops_a < wr_loops_b)) and ram_one_from_full) then
         ram_full_c <= '1';
       elsif ((mem_wr_en_b = '1') and (mem_rd_en_a = '0') and ram_one_from_full) then
         ram_full_c <= '1';
       elsif ((mem_rd_en_a = '1') and ram_one_read_from_not_full) then
         ram_full_c <= '0';
       else
         ram_full_c <= ram_full_c;
       end if;
     end if;
     end process RFC;

   RFI  : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if ((glblGSR = '1') or (WRRSTBUSY_out = '1')) then
         ram_full_i <= '0';
       elsif ((mem_wr_en_b = '1') and ram_two_from_full and (ram_full_i = '0')) then
         ram_full_i <= '1';
       elsif (not ram_one_from_full) then
         ram_full_i <= '0';
       else
         ram_full_i <= ram_full_i;
       end if;
     end if;
     end process RFI;

   PFO  : process (mem_wr_clk_b) begin
     if (rising_edge(mem_wr_clk_b)) then
       if ((glblGSR = '1') or (WRRSTBUSY_out = '1')) then
         PROGFULL_out <= '0';
       else
         PROGFULL_out <= prog_full;
       end if;
     end if;
     end process PFO;

-- empty flag
   empty_count_raw <= ('1' & wr_addr_rd) - ('0' & rd_addr);
   empty_count     <= empty_count_raw(COUNT_WIDTH-2 downto 0);
   EMPTY_out <= o_stages_empty;
   ram_empty <= ram_empty_c when (CLOCK_DOMAINS_BIN = CLOCK_DOMAINS_COMMON) else ram_empty_i;
   ram_one_read_from_empty <= (empty_count < 2*rd_loops_a/4) and (empty_count >= rd_loops_a/4) and (ram_empty = '0');
   ram_one_write_from_not_empty <= (EMPTY_out = '1') when (rd_loops_a < wr_loops_b) else ((empty_count + wr_loops_b/4) >= rd_loops_a/4);
   prog_empty <= '1' when (((empty_count < prog_empty_val) or (ram_empty = '1')) and (FULL_out = '0')) else '0';

   REC : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (RDRST_int = '1')) then
         ram_empty_c <= '1';
-- RD only makes empty
       elsif ((mem_wr_en_b = '0') and (mem_rd_en_a = '1' and (ram_one_read_from_empty or (ram_empty_c = '1')))) then
         ram_empty_c <= '1';
-- RD and WR when one read from empty and RD more than WR makes empty
       elsif ((mem_wr_en_b = '1') and ((mem_rd_en_a = '1') and (rd_loops_a > wr_loops_b)) and ram_one_read_from_empty) then
         ram_empty_c <= '1';
-- CR701309 CC WR when empty always makes not empty. simultaneous RD gets ERR
       elsif ((mem_wr_en_b = '1') and (ram_one_write_from_not_empty and (ram_empty_c = '1'))) then
         ram_empty_c <= '0';
       else
         ram_empty_c <= ram_empty_c;
       end if;
     end if;
     end process REC;

   REI : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (RDRST_int = '1')) then
         ram_empty_i <= '1';
       elsif ((mem_rd_en_a = '1') and ram_one_read_from_empty) then -- RDEN_in ?
         ram_empty_i <= '1';
       elsif (empty_count < rd_loops_a/4) then
         ram_empty_i <= '1';
       else
         ram_empty_i <= '0';
       end if;
     end if;
     end process REI;


   PEO : process (mem_rd_clk_a) begin
     if (rising_edge(mem_rd_clk_a)) then
       if ((glblGSR = '1') or (RDRST_int = '1')) then
         PROGEMPTY_out <= '1';
       else
         PROGEMPTY_out <= prog_empty;
       end if;
     end if;
     end process PEO;
  end FIFO18E2_V;
