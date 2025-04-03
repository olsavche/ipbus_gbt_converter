library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;
use work.tb_package.all;


entity tb_top_sim_converter is
end;

architecture bench of tb_top_sim_converter is

    -- Ports
    signal i_clk_ipbus : std_logic;
    signal i_clk_gbt : std_logic;
    signal i_reset : std_logic;
    signal i_data_rcv : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal o_data_snd : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    -- Sim 
    signal MODE : integer := 3;

begin

  top_sim_converter_inst : entity work.top_sim_converter
  port map (
    i_clk_ipbus => i_clk_ipbus,
    i_clk_gbt => i_clk_gbt,
    i_reset => i_reset,
    i_data_rcv => i_data_rcv,
    o_data_snd => o_data_snd
  );

p_generate_clock(i_clk_ipbus,c_IPBUS_CLOKC_PERIOD);
p_generate_clock(i_clk_gbt,c_GBT_CLOCK_PERIOD);



process 
begin
    p_init_signals(i_data_rcv);
    p_init_signals(i_reset);
    p_reset_signal(i_reset,c_IPBUS_CLOKC_PERIOD*5,c_IPBUS_CLOKC_PERIOD*5);
    if MODE = 0 then
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x0 & c_DATA_x1;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x1 & c_DATA_x2;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x2 & c_DATA_x3;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_WRITE & c_ADDRESS_x3 & c_DATA_x4; --c_IDLE

    elsif MODE = 1 then
        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x0 & c_DATA_x1;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x1 & c_DATA_x2;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_WRITE & c_ADDRESS_x2 & c_DATA_x3;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_WRITE & c_ADDRESS_x3 & c_DATA_x4; -- c_IDLE

        wait for c_GBT_CLOCK_PERIOD*20;
        i_data_rcv <= c_SWT & c_NOT_USED & c_READ & c_ADDRESS_x0 & c_DATA_x1;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_READ & c_ADDRESS_x1 & c_DATA_x1;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_SWT & c_NOT_USED & c_READ & c_ADDRESS_x2 & c_DATA_x1;
        wait for c_GBT_CLOCK_PERIOD;
        i_data_rcv <= c_IDLE & c_NOT_USED & c_READ & c_ADDRESS_x3 & c_DATA_x1; -- c_IDLE

    elsif MODE = 2 then
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

    elsif MODE = 3 then
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
    end if;

wait; 
end process;

end;