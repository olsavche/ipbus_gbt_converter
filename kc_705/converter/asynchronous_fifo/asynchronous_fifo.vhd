library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity asynchronous_fifo is
    Generic (
        DEPTH               : integer := 64;
        WIDTH               : integer := 80
    );
    Port (
        i_wclk        : in  STD_LOGIC;
        i_wrst        : in  STD_LOGIC;
        i_rclk        : in  STD_LOGIC;
        i_rrst        : in  STD_LOGIC;
        i_w_en        : in  STD_LOGIC;
        i_r_en        : in  STD_LOGIC;
        i_data_in     : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        o_data_out    : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        o_full        : out STD_LOGIC;
        o_empty       : out STD_LOGIC
    );
end asynchronous_fifo;

architecture Behavioral of asynchronous_fifo is
    function log2ceil(N : integer) return integer is
        variable i : integer := 0;
        variable val : integer := 1;
    begin
        while val < N loop
            val := val * 2;
            i := i + 1;
        end loop;
        return i;
    end function;

    constant PTR_WIDTH : integer := log2ceil(DEPTH);
    
    signal g_wptr_sync, g_rptr_sync : STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0) := (others => '0');
    signal b_wptr, b_rptr : STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0) := (others => '0');
    signal g_wptr, g_rptr : STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0) := (others => '0');
    signal full_int, empty_int : STD_LOGIC := '0';

begin

    sync_wptr : entity work.synchronizer
        Generic Map (WIDTH => PTR_WIDTH)
        Port Map (
            clk   => i_rclk,
            rst => i_rrst,
            d_in  => g_wptr,
            d_out => g_wptr_sync
        );
    
    sync_rptr : entity work.synchronizer
        Generic Map (WIDTH => PTR_WIDTH)
        Port Map (
            clk   => i_wclk,
            rst => i_wrst,
            d_in  => g_rptr,
            d_out => g_rptr_sync
        );
    
    wptr_h : entity work.wptr_handler
        Generic Map (PTR_WIDTH => PTR_WIDTH)
        Port Map (
            wclk        => i_wclk,
            wrst        => i_wrst,
            w_en        => i_w_en,
            g_rptr_sync => g_rptr_sync,
            b_wptr      => b_wptr,
            g_wptr      => g_wptr,
            full        => full_int
        );
    
    rptr_h : entity work.rptr_handler
        Generic Map (PTR_WIDTH => PTR_WIDTH)
        Port Map (
            rclk        => i_rclk,
            rrst        => i_rrst,
            r_en        => i_r_en,
            g_wptr_sync => g_wptr_sync,
            b_rptr      => b_rptr,
            g_rptr      => g_rptr,
            empty       => empty_int
        );
    
    fifom : entity work.fifo_mem
        Generic Map (
            DEPTH      => DEPTH,
            DATA_WIDTH => WIDTH,
            PTR_WIDTH  => PTR_WIDTH
        )
        Port Map (
            wclk    => i_wclk,
            w_en    => i_w_en,
            rclk    => i_rclk,
            r_en    => i_r_en,
            b_wptr  => b_wptr,
            b_rptr  => b_rptr,
            data_in => i_data_in,
            full    => full_int,
            empty   => empty_int,
            data_out=> o_data_out
        );
    
    o_full  <= full_int;
    o_empty <= empty_int;
end Behavioral;
