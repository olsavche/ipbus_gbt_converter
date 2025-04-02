library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;

package m_package is

-----------------------------------------------------------------------------------------------------------
-- type ipb_wbus, ipb_rbus, gbt_frame
-----------------------------------------------------------------------------------------------------------

    type ipb_wbus is record
			ipb_addr     : std_logic_vector(31 downto 0);
			ipb_wdata    : std_logic_vector(31 downto 0);
			ipb_strobe   : std_logic;
			ipb_write    : std_logic;
		end record;
	
	type ipb_rbus is record
            ipb_rdata   : std_logic_vector(31 downto 0);
            ipb_ack     : std_logic;
            ipb_err     : std_logic;
        end record;

    type gbt_frame is record 
            swt_id              : std_logic_vector(3 downto 0);     -- (79 downto 76)
            not_used            : std_logic_vector(7 downto 0);     -- (75 downto 68)
            transaction_type    : std_logic_vector(3 downto 0);     -- (67 downto 64)
            address             : std_logic_vector(31 downto 0);    -- (63 downto 32)
            data                : std_logic_vector(31 downto 0);    -- (31 downto 0)
    end record gbt_frame;
    
    type ipb_wbus_array is array(natural range <>) of ipb_wbus;
    
-----------------------------------------------------------------------------------------------------------
-- constants
-----------------------------------------------------------------------------------------------------------
    -- swt constants
    -----------------
    -- swt_id idle_idpa
    constant c_SWT                  : std_logic_vector(3 downto 0)   := "0011";
    constant c_IDLE                 : std_logic_vector(3 downto 0)   := "0000";
    -- not_used
    constant c_NOT_USED             : std_logic_vector(7 downto 0)   := x"00";
    -- transaction_type
    constant c_N_TYPE               : integer                        := 7;
    constant c_READ                 : std_logic_vector(3 downto 0)   := "0000";
    constant c_WRITE                : std_logic_vector(3 downto 0)   := "0001";
    constant c_RMW_AND              : std_logic_vector(3 downto 0)   := "0010";
    constant c_RMW_OR               : std_logic_vector(3 downto 0)   := "0011";
    constant c_RMW_SUM              : std_logic_vector(3 downto 0)   := "0100";
    constant c_BLOCK_READ_INC       : std_logic_vector(3 downto 0)   := "1000";
    constant c_BLOCK_READ_NON_INC   : std_logic_vector(3 downto 0)   := "1001";
    -- address
    constant c_ADDRESS_x0           : std_logic_vector(31 downto 0)  := x"00000000";
    constant c_ADDRESS_x1           : std_logic_vector(31 downto 0)  := x"00000001";
    constant c_ADDRESS_x2           : std_logic_vector(31 downto 0)  := x"00000002";
    constant c_ADDRESS_x3           : std_logic_vector(31 downto 0)  := x"00000003";
    constant c_ADDRESS_x4           : std_logic_vector(31 downto 0)  := x"00000004";
    constant c_ADDRESS_x5           : std_logic_vector(31 downto 0)  := x"00000005";
    constant c_ADDRESS_x6           : std_logic_vector(31 downto 0)  := x"00000006";
    constant c_ADDRESS_x7           : std_logic_vector(31 downto 0)  := x"00000007";
    -- data
    constant c_DATA_x0              : std_logic_vector(31 downto 0)  := x"00000000";
    constant c_DATA_x1              : std_logic_vector(31 downto 0)  := x"00000001";
    constant c_DATA_x2              : std_logic_vector(31 downto 0)  := x"00000002";
    constant c_DATA_x3              : std_logic_vector(31 downto 0)  := x"00000003";
    constant c_DATA_x4              : std_logic_vector(31 downto 0)  := x"00000004";
    constant c_DATA_x5              : std_logic_vector(31 downto 0)  := x"00000005";
    constant c_DATA_x6              : std_logic_vector(31 downto 0)  := x"00000006";
    constant c_DATA_x7              : std_logic_vector(31 downto 0)  := x"00000007";
    -- whole frame
    constant c_WHOLE_FRAME_ZERO     : std_logic_vector(79 downto 0)  := x"00000000000000000000";
    -- swt constants
    ----------------- 
    constant c_GBT_FRAME_WIDTH      : integer   := 80;
    constant c_DEPTH                : integer   := 64;
    -----------------
    -- ipbus
    constant c_GBT_CLOCK_PERIOD     : time      := 25 ns; 
    constant c_IPBUS_CLOKC_PERIOD   : time      := 32 ns;
    constant c_N_REG                : integer   := 10; -- ipbus_reg_v
    constant t_ZERO                 : time      := 0 ns; 
    -----------------
    constant c_GBT_ZERO_FRAME : gbt_frame := (
        swt_id           => (others => '0'),
        not_used         => (others => '0'),
        transaction_type => (others => '0'),
        address          => (others => '0'),
        data             => (others => '0')
        );
-- functions & procedures
-----------------------------------------------------------------------------------------------------------
    function ipb_wbus_zero return ipb_wbus;
    ------------------------------------------------------------
    function ipb_rbus_zero return ipb_rbus;
    ------------------------------------------------------------
    function int_to_vector(val : integer; width : natural) return std_logic_vector;
    --
    procedure set_wbus(
        signal ipbus_in : out ipb_wbus;
        s_ipb_addr      : in  std_logic_vector(31 downto 0);
        s_ipb_wdata     : in  std_logic_vector(31 downto 0);
        s_ipb_strobe    : in  std_logic;
        s_ipb_write     : in  std_logic
        );
    --
    procedure unpack_wbus (
        signal wbus_in         : in  ipb_wbus;
        signal o_addr      : out std_logic_vector(31 downto 0);
        signal o_wdata     : out std_logic_vector(31 downto 0);
        signal o_strobe    : out std_logic;
        signal o_write     : out std_logic
        );
    -- 
    procedure set_rbus(
        signal ipbus_out : out ipb_rbus;
        s_ipb_rdata      : in  std_logic_vector(31 downto 0);
        s_ipb_ack        : in  std_logic;
        s_ipb_err        : in  std_logic
        );
    --
    procedure unpack_rbus (
        signal rbus_in        : in  ipb_rbus;
        signal o_rdata    : out std_logic_vector(31 downto 0);
        signal o_ack      : out std_logic;
        signal o_err      : out std_logic
        );
    --
    procedure delay_signal (
        signal clk    : in std_logic;
        signal din    : in std_logic;
        signal dout   : out std_logic
        );

    procedure clk_div2 (
        -- signal i_clk       : in  STD_LOGIC;
        signal i_reset     : in  STD_LOGIC;
               i_enable    : in  STD_LOGIC;
        signal internal_clk : inout STD_LOGIC; 
        signal clk_out     : out STD_LOGIC
        );

end package m_package;

package body m_package is
-----------------------------------------------------------------------------------------------------------
-- functions & procedures
-----------------------------------------------------------------------------------------------------------
    function ipb_wbus_zero return ipb_wbus is
            variable tmp : ipb_wbus;
        begin
            tmp.ipb_addr   := (others => '0');
            tmp.ipb_wdata  := (others => '0');
            tmp.ipb_strobe := '0';
            tmp.ipb_write  := '0';
            return tmp;
        end function;

    function ipb_rbus_zero return ipb_rbus is
            variable tmp : ipb_rbus;
        begin
            tmp.ipb_rdata := (others => '0');
            tmp.ipb_ack   := '0';
            tmp.ipb_err   := '0';
            return tmp;
        end function;

    function int_to_vector(val : integer; width : natural) return std_logic_vector is
        begin
            return std_logic_vector(to_unsigned(val, width));
        end function;
     
    -- set_wbus(ipbus_in, s_ipb_addr, s_ipb_wdata, s_ipb_strobe, s_ipb_write);
    procedure set_wbus(
        signal ipbus_in : out ipb_wbus;
        s_ipb_addr      : in  std_logic_vector(31 downto 0);
        s_ipb_wdata     : in  std_logic_vector(31 downto 0);
        s_ipb_strobe    : in  std_logic;
        s_ipb_write     : in  std_logic
            ) is
        begin
            ipbus_in.ipb_addr   <= s_ipb_addr;
            ipbus_in.ipb_wdata  <= s_ipb_wdata;
            ipbus_in.ipb_strobe <= s_ipb_strobe;
            ipbus_in.ipb_write  <= s_ipb_write;
        end procedure;

    procedure unpack_wbus (
            signal wbus_in         : in  ipb_wbus;
            signal o_addr      : out std_logic_vector(31 downto 0);
            signal o_wdata     : out std_logic_vector(31 downto 0);
            signal o_strobe    : out std_logic;
            signal o_write     : out std_logic
        ) is
        begin
            o_addr   <= wbus_in.ipb_addr;
            o_wdata  <= wbus_in.ipb_wdata;
            o_strobe <= wbus_in.ipb_strobe;
            o_write  <= wbus_in.ipb_write;
        end procedure unpack_wbus;

    -- set_rbus(ipbus_out, rdata, '1', '0')
    procedure set_rbus(
        signal ipbus_out : out ipb_rbus;
        s_ipb_rdata      : in  std_logic_vector(31 downto 0);
        s_ipb_ack        : in  std_logic;
        s_ipb_err        : in  std_logic
            ) is
        begin
            ipbus_out.ipb_rdata <= s_ipb_rdata;
            ipbus_out.ipb_ack   <= s_ipb_ack;
            ipbus_out.ipb_err   <= s_ipb_err;
        end procedure;

    procedure unpack_rbus (
        signal rbus_in        : in  ipb_rbus;
        signal o_rdata    : out std_logic_vector(31 downto 0);
        signal o_ack      : out std_logic;
        signal o_err      : out std_logic
    ) is
    begin
        o_rdata <= rbus_in.ipb_rdata;
        o_ack   <= rbus_in.ipb_ack;
        o_err   <= rbus_in.ipb_err;
    end procedure unpack_rbus;

    procedure delay_signal (
        signal clk    : in std_logic;
        signal din    : in std_logic;
        signal dout   : out std_logic
            ) is
        begin
        if rising_edge(clk) then
            dout <= din;  
            end if;
        end procedure delay_signal;
    
    -- clk_div2 not nested <- use only inside "" if rising_edge(i_clk) ""
    procedure clk_div2 (                       
        signal i_reset     : in  STD_LOGIC;
        i_enable    : in  STD_LOGIC;
        signal internal_clk: inout STD_LOGIC;
        signal clk_out     : out STD_LOGIC
            ) is
        begin
        if i_reset = '1' then
            internal_clk <= '0';
            clk_out      <= '0';
        elsif i_enable = '1' then
            internal_clk <= not internal_clk;
            clk_out      <= internal_clk;
        else
            internal_clk <= '0';
            clk_out      <= '0';
        end if;
        end procedure;
-----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
end package body m_package;
