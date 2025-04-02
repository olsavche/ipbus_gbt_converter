library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_textio.all;  
use std.textio.all;             
use work.m_package.all;
use work.tb_package.all;


entity tb_top_for_sim is
end;

architecture bench of tb_top_for_sim is

    -- Ports
    signal i_clk_ipbus : std_logic;
    signal i_clk_gbt : std_logic;
    signal i_reset : std_logic;
    signal i_data_rcv : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal o_data_rcv : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal o_wr_en_rcv : std_logic;
    signal o_data_f_r : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal o_full_f_r : std_logic;
    signal o_empt_f_r : std_logic;
    signal i_empt_f_r : std_logic;
    signal o_rd_en : STD_LOGIC;
    signal o_done : STD_LOGIC;
    signal o_ack_and : STD_LOGIC;
    signal o_rbus_data : STD_LOGIC_VECTOR(31 downto 0);
    signal o_rbus_err : STD_LOGIC;
    signal o_data_gbt :  std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal o_data_f_s : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal o_full_f_s : STD_LOGIC;
    signal o_empt_f_s : STD_LOGIC;
    signal o_data_snd : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    -- rmw
    signal o_wr_data : std_logic_vector(31 downto 0);
    -- Sim
    signal MODE : integer := 4;  
        -- 0 = WRITE, 
        -- 1 = READ, 
        -- 4 = RMW_SUM & READ
        -- 5 = WRITE & READ
        -- 6 = WRITE & BLOCK_READ_NON_INC
        -- 7 = WRITE & BLOCK_READ_INC
    file log_file : text open write_mode is "log_output.txt";
    signal prev_data : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0) := (others => '0');
    signal prev_data_i_data_rcv: std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0) := (others => '0');
    
begin

    converter_fsm_inst : entity work.top_for_sim
        port map (
        i_clk_ipbus => i_clk_ipbus,
        i_clk_gbt => i_clk_gbt,
        i_reset => i_reset,
        i_data_rcv => i_data_rcv,
        o_data_rcv => o_data_rcv,
        o_wr_en_rcv => o_wr_en_rcv,
        o_data_f_r => o_data_f_r,
        o_full_f_r => o_full_f_r,
        o_empt_f_r => o_empt_f_r,
        i_empt_f_r => i_empt_f_r,
        o_rd_en => o_rd_en,
        o_done => o_done,
        o_ack_and => o_ack_and,
        o_rbus_data => o_rbus_data,
        o_rbus_err => o_rbus_err,
        o_data_gbt => o_data_gbt,
        o_data_f_s => o_data_f_s,
        o_full_f_s => o_full_f_s,
        o_empt_f_s => o_empt_f_s,
        o_data_snd => o_data_snd,
        -- rmw
        o_wr_data => o_wr_data
        );
  
p_generate_clock(i_clk_ipbus, c_IPBUS_CLOKC_PERIOD);
p_generate_clock(i_clk_gbt, c_GBT_CLOCK_PERIOD);


process(i_clk_gbt)
    variable log_line : line;
begin
    if rising_edge(i_clk_gbt) then
        if o_data_snd /= prev_data then
            write(log_line, string'("o_data_snd = "));
            write(log_line, string'("SWT = "));
            write(log_line, to_integer(unsigned(o_data_snd(79 downto 76))));
            write(log_line, string'(" NOT_USED = "));
            write(log_line, to_integer(unsigned(o_data_snd(75 downto 68))));
            write(log_line, string'(" OP_TYPE = "));
            write(log_line, to_integer(unsigned(o_data_snd(67 downto 64))));
            write(log_line, string'(" ADDR = "));
            write(log_line, to_integer(unsigned(o_data_snd(63 downto 32))));
            write(log_line, string'(" DATA = "));
            write(log_line, to_integer(unsigned(o_data_snd(31 downto 0))));
            writeline(log_file, log_line);
            write(log_line, string'("  ")); writeline(log_file, log_line);
        end if;

        prev_data <= o_data_snd;
    end if;
end process;

process(i_clk_gbt)
    variable log_line : line;
begin
    if rising_edge(i_clk_gbt) then
        if i_data_rcv /= prev_data_i_data_rcv then
            write(log_line, string'("i_data_rcv = "));
            write(log_line, string'("SWT = "));
            write(log_line, to_integer(unsigned(i_data_rcv(79 downto 76))));
            write(log_line, string'(" NOT_USED = "));
            write(log_line, to_integer(unsigned(i_data_rcv(75 downto 68))));
            write(log_line, string'(" OP_TYPE = "));
            write(log_line, to_integer(unsigned(i_data_rcv(67 downto 64))));
            write(log_line, string'(" ADDR = "));
            write(log_line, to_integer(unsigned(i_data_rcv(63 downto 32))));
            write(log_line, string'(" DATA = "));
            write(log_line, to_integer(unsigned(i_data_rcv(31 downto 0))));
            writeline(log_file, log_line);
            write(log_line, string'("  ")); writeline(log_file, log_line);
            --write(log_line, c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x0 & c_DATA_x1); --i_data_rcv);
            --writeline(log_file, log_line);
        end if;

        prev_data_i_data_rcv <= i_data_rcv;
    end if;
end process;


process 
    variable log_line : line;
begin
    write(log_line, string'("Simulation started...")); writeline(log_file, log_line);
    p_init_signals(i_reset);
    p_init_signals(i_data_rcv);
    p_reset_signal(i_reset,t_ZERO,c_IPBUS_CLOKC_PERIOD*5);

    if MODE = 0 then -- WRITE
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x0 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x1 & c_DATA_x2 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x2 & c_DATA_x3 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_WRITE & c_ADDRESS_x3 & c_DATA_x4 ;--c_IDLE
        
    elsif MODE = 1 then -- READ
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_READ & c_ADDRESS_x0 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_READ & c_ADDRESS_x1 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_READ & c_ADDRESS_x2 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_READ & c_ADDRESS_x3 & c_DATA_x1 ;--c_IDLE
    elsif MODE = 2 then -- BLOCK_READ_NON_INC
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_BLOCK_READ_NON_INC & c_ADDRESS_x1 & c_DATA_x3 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_READ & c_ADDRESS_x4 & c_DATA_x1 ;--c_IDLE
    elsif MODE = 3 then -- BLOCK_READ_INC
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_BLOCK_READ_INC & c_ADDRESS_x1 & c_DATA_x3 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_READ & c_ADDRESS_x4 & c_DATA_x1 ;--c_IDLE
    elsif MODE = 4 then  -- RMW_SUM & READ
        wait for c_GBT_CLOCK_PERIOD*40;
        i_data_rcv <= c_SWT & c_NOT_USED & c_RMW_SUM & c_ADDRESS_x0 & c_DATA_x3;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_RMW_SUM & c_ADDRESS_x0 & c_DATA_x1; --c_IDLE

        wait for c_GBT_CLOCK_PERIOD*40;
        i_data_rcv <= c_SWT & c_NOT_USED & c_RMW_SUM & c_ADDRESS_x0 & c_DATA_x4;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_RMW_SUM & c_ADDRESS_x0 & c_DATA_x1; --c_IDLE

        wait for c_GBT_CLOCK_PERIOD*40;
        i_data_rcv <= c_SWT & c_NOT_USED & c_RMW_SUM & c_ADDRESS_x0 & c_DATA_x5;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_RMW_SUM & c_ADDRESS_x0 & c_DATA_x1 ; --c_IDLE

    elsif MODE = 5 then  -- WRITE & READ
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x0 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x1 & c_DATA_x2 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x2 & c_DATA_x3 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_WRITE & c_ADDRESS_x3 & c_DATA_x4 ; --c_IDLE
        --
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_READ & c_ADDRESS_x0 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_READ & c_ADDRESS_x1 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_READ & c_ADDRESS_x2 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_READ & c_ADDRESS_x3 & c_DATA_x1 ; --c_IDLE
    elsif MODE = 6 then -- WRITE & BLOCK_READ_NON_INC
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x0 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x1 & c_DATA_x2 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x2 & c_DATA_x3 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_WRITE & c_ADDRESS_x3 & c_DATA_x4 ;--c_IDLE

        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_BLOCK_READ_NON_INC & c_ADDRESS_x0 & c_DATA_x3 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_READ & c_ADDRESS_x4 & c_DATA_x1 ;--c_IDLE

    elsif MODE = 7 then -- WRITE & BLOCK_READ_INC
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x0 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x1 & c_DATA_x2 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x2 & c_DATA_x3 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_WRITE & c_ADDRESS_x3 & c_DATA_x4 ;--c_IDLE

        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_BLOCK_READ_INC & c_ADDRESS_x0 & c_DATA_x3 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_READ & c_ADDRESS_x4 & c_DATA_x1 ;--c_IDLE
    
    elsif MODE = 8 then -- WRITE & BLOCK_READ_INC
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x0 & c_DATA_x1 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x1 & c_DATA_x2 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x2 & c_DATA_x3 ;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_WRITE & c_ADDRESS_x3 & c_DATA_x4 ;--c_IDLE



    end if;
    wait;
end process;

end;


