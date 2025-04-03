library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;

entity converter is
    port (
        i_clk_ipbus : in std_logic;
        i_clk_gbt : in std_logic;
        i_reset : in std_logic;
        -- recieve_swt 
        i_data_rcv : in std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
        -- send_swt
        o_data_snd : buffer std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
        -- to pyaload 
        o_wbus : buffer ipb_wbus;
        i_rbus : in ipb_rbus
    );
end entity;

architecture rtl of converter is

    -- receive_swt_inst out signals
    signal data_rcv : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal wr_en_rcv : std_logic := '0';
    -- send_swt_inst out signals
    -- asynchronous_fifo_recieve_inst out signals
    signal data_f_r : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal full_f_r : std_logic := '0';
    signal empt_f_r, d_empt_f_r : std_logic := '0';
    -- asynchronous_fifo_send_inst out signals
    signal data_f_s : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal full_f_s : std_logic := '0';
    signal empt_f_s : std_logic := '0';
    -- converter_fsm_inst out signals
    signal data_gbt : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal rd_en : std_logic := '0';
    signal ack_and : std_logic := '0';

begin
    -- swt inst
    receive_swt_inst : entity work.receive_swt
        port map (
        i_clock => i_clk_gbt,
        i_reset => i_reset, 
        i_data_r => i_data_rcv, 
        o_data => data_rcv, 
        o_w_en_r => wr_en_rcv
        );

    send_swt_inst : entity work.send_swt
        port map (
        i_clock => i_clk_gbt, 
        i_reset => i_reset, 
        i_fifo_empty => empt_f_s, 
        i_fifo_data => data_f_s, 
        o_data => o_data_snd 
        );
    -- fifo inst 
    asynchronous_fifo_recieve_inst : entity work.asynchronous_fifo
        generic map (
        DEPTH => 64,
        WIDTH => c_GBT_FRAME_WIDTH
        )
        port map (
        i_wclk => i_clk_gbt, 
        i_wrst => i_reset, 
        i_rclk => i_clk_ipbus, 
        i_rrst => i_reset, 
        i_w_en => wr_en_rcv, 
        i_r_en => rd_en, -- from converter
        i_data_in => data_rcv, 
        o_data_out => data_f_r, 
        o_full => full_f_r, 
        o_empty => empt_f_r 
        );
    
    asynchronous_fifo_send_inst : entity work.asynchronous_fifo
        generic map (
        DEPTH => c_FIFO_DEPTH,
        WIDTH => c_GBT_FRAME_WIDTH
        )
        port map (
        i_wclk => i_clk_ipbus, 
        i_wrst => i_reset, 
        i_rclk => i_clk_gbt, 
        i_rrst => i_reset, 
        i_w_en => ack_and,
        i_r_en => '1', 
        i_data_in => data_gbt, -- from converter
        o_data_out => data_f_s, 
        o_full => full_f_s, 
        o_empty => empt_f_s 
        );
    -- converter_inst
    delay_signal(i_clk_ipbus, empt_f_r, d_empt_f_r);
    converter_fsm_inst : entity work.converter_fsm
        port map (
        i_clk => i_clk_ipbus, 
        i_reset => i_reset, 
        i_fifo_empty => d_empt_f_r, -- fifo r
        i_data_gbt => data_f_r, -- fifo r
        o_rd_en => rd_en, -- fifo r 
        o_ack_and => ack_and, -- fifo_s i_w_en => ack_and
        o_data_gbt => data_gbt, -- fifo_s

        -- ipbus
        o_wbus => o_wbus, 
        i_rbus => i_rbus 
        );




end architecture;
