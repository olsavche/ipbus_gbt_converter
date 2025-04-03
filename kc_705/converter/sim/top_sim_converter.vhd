library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;



entity top_sim_converter is
    port (
        i_clk_ipbus : in std_logic;
        i_clk_gbt : in std_logic;
        i_reset : in std_logic;
        -- recieve_swt 
        i_data_rcv : in std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
        -- send_swt
        o_data_snd : buffer std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of top_sim_converter is
    -- wire
    signal o_wbus :  ipb_wbus;
    signal i_rbus :  ipb_rbus;
begin

    ipbus_ram_inst : entity work.ipbus_ram
    generic map (
      ADDR_WIDTH => 3
    )
    port map (
      clk => i_clk_ipbus,
      reset => i_reset,
      ipbus_in => o_wbus,
      ipbus_out => i_rbus
    );
  
converter_inst : entity work.converter
    port map (
    i_clk_ipbus => i_clk_ipbus,
    i_clk_gbt => i_clk_gbt,
    i_reset => i_reset,
    i_data_rcv => i_data_rcv,
    o_data_snd => o_data_snd,
    o_wbus => o_wbus,
    i_rbus => i_rbus
    );
  
end architecture;



    

