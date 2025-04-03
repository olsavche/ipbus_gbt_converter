library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.my_package.all;
use work.tb_package.all;





entity tb_vio_swt_frane_control is
end;

architecture bench of tb_vio_swt_frane_control is

-- Ports
signal i_clk : STD_LOGIC;
signal i_reset : STD_LOGIC;
signal i_sel : STD_LOGIC;
signal i_send_button : STD_LOGIC;
signal i_data : STD_LOGIC_VECTOR(31 downto 0);
signal i_adress : STD_LOGIC_VECTOR(31 downto 0);
signal i_tran_type : STD_LOGIC_VECTOR(3 downto 0);
signal o_swt_frame : STD_LOGIC_VECTOR(79 downto 0);
signal o_sel : STD_LOGIC;

begin

vio_swt_frane_control_inst : entity work.vio_swt_frane_control
    port map (
    i_clk => i_clk,
    i_reset => i_reset,
    i_sel => i_sel,
    i_send_button => i_send_button,
    i_data => i_data,
    i_adress => i_adress,
    i_tran_type => i_tran_type,
    o_swt_frame => o_swt_frame,
    o_sel => o_sel
    );

p_generate_clock(i_clk, c_IPBUS_CLOKC_PERIOD);

process
    begin
            p_init_signals(i_reset); 
            p_init_signals(i_sel); 
            p_init_signals(i_send_button);
            p_init_signals(i_data);
            p_init_signals(i_adress);
            p_init_signals(i_tran_type);
            p_reset_signal(i_reset,c_IPBUS_CLOKC_PERIOD*5,c_IPBUS_CLOKC_PERIOD*5);
        wait for c_IPBUS_CLOKC_PERIOD*5;
            i_send_button  <= '1';
            i_data  <= int_to_vector(55,32);
            i_adress  <= int_to_vector(24,32);
            i_tran_type  <= int_to_vector(4,4);
        wait for c_IPBUS_CLOKC_PERIOD*5;
            i_send_button  <= '0';
        wait for c_IPBUS_CLOKC_PERIOD*5;
            i_send_button  <= '1';
            i_data  <= int_to_vector(22,32);
            i_adress  <= int_to_vector(33,32);
            i_tran_type  <= int_to_vector(9,4);
        wait for c_IPBUS_CLOKC_PERIOD*5;
            i_send_button  <= '0';


    wait;
    end process;
end;