library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.m_package.all;
use work.ipbus_reg_types.all;

entity top_for_sim is
    port (
        -- common
        i_clk_ipbus : in std_logic;
        i_clk_gbt : in std_logic;
        i_reset : in std_logic;
        -- recieve 
        i_data_rcv : in std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
        o_data_rcv : buffer std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
        o_wr_en_rcv : out std_logic;
        -- fifo_recieve
        o_data_f_r : buffer std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
        o_full_f_r : buffer std_logic;
        o_empt_f_r : buffer std_logic;
        -- converter
        i_empt_f_r : buffer std_logic; -- fifo r
        o_rd_en :out STD_LOGIC; -- fifo r
        o_done : buffer STD_LOGIC;
        o_ack_and : out STD_LOGIC;
        o_rbus_data : buffer STD_LOGIC_VECTOR(31 downto 0);
        o_rbus_err : out STD_LOGIC;
        o_data_gbt : buffer std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
        -- fifo_send
        o_data_f_s : out STD_LOGIC_VECTOR(c_GBT_FRAME_WIDTH-1 downto 0);
        o_full_f_s : out STD_LOGIC;
        o_empt_f_s : buffer STD_LOGIC;
        -- send
        o_data_snd : buffer std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);

        -- rmw
        o_wr_data : buffer std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of top_for_sim is

    
begin

    receive_swt_inst : entity work.receive_swt
        port map (
        i_clock => i_clk_gbt,
        i_reset => i_reset,
        i_data_r => i_data_rcv,
        o_data => o_data_rcv,
        o_w_en_r => o_wr_en_rcv
        );

    asynchronous_fifo_recieve : entity work.asynchronous_fifo
        generic map (
            DEPTH => 64,
            WIDTH => 80
        )
        port map (
            i_wclk => i_clk_gbt, 
            i_wrst => i_reset,
            i_rclk => i_clk_ipbus,
            i_rrst => i_reset,
            i_w_en => o_wr_en_rcv,
            i_r_en => o_rd_en,
            i_data_in => o_data_rcv,
            o_data_out => o_data_f_r,
            o_full => o_full_f_r,
            o_empty => o_empt_f_r
        );

    delay_signal(i_clk_ipbus, o_empt_f_r, i_empt_f_r);
    converter_fsm_2_inst : entity work.converter_fsm_2
        port map (
          i_clk => i_clk_ipbus,
          i_reset => i_reset,
          i_fifo_empty => i_empt_f_r, -- fifo r
          i_data_gbt => o_data_f_r, 
          o_rd_en => o_rd_en, -- fifo r 
          o_done => o_done,
          o_ack_and => o_ack_and,
          o_rbus_data => o_rbus_data,
          o_rbus_err => o_rbus_err,
          o_data_gbt => o_data_gbt,
          -- rmw
          o_wr_data => o_wr_data
        );

    asynchronous_fifo_send : entity work.asynchronous_fifo
        generic map (
            DEPTH => 64,
            WIDTH => 80
        )
        port map (
            i_wclk => i_clk_ipbus,
            i_wrst => i_reset,
            i_rclk => i_clk_gbt,
            i_rrst => i_reset,
            i_w_en => o_ack_and,
            i_r_en => '1',
            i_data_in => o_data_gbt,
            o_data_out => o_data_f_s,
            o_full => o_full_f_s,
            o_empty => o_empt_f_s
        );

    send_swt_inst : entity work.send_swt
        port map (
          i_clock => i_clk_gbt,
          i_fifo_empty => o_empt_f_s,
          i_reset => i_reset,
          i_fifo_data => o_data_f_s,
          o_data => o_data_snd
        );

end architecture;
