
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.m_package.all;
use work.tb_package.all;


entity ipbus_peephole_ram_tb is
end;

architecture bench of ipbus_peephole_ram_tb is
    -- Ports
    signal clk : std_logic;
    signal reset : std_logic;
    signal ipbus_in : ipb_wbus;
    signal ipbus_out : ipb_rbus;

    constant GEN_TESTCASE : integer := 1;
begin

ipbus_peephole_ram_inst : entity work.ipbus_peephole_ram
    generic map (
    ADDR_WIDTH => 3
    )
    port map (
    clk => clk,
    reset => reset,
    ipbus_in => ipbus_in,
    ipbus_out => ipbus_out
    );

p_generate_clock(clk,c_IPBUS_CLOKC_PERIOD);

process 
    begin
        wait for c_IPBUS_CLOKC_PERIOD*20;
        p_init_signals(ipbus_in.ipb_addr);
        p_init_signals(ipbus_in.ipb_wdata);
        p_init_signals(ipbus_in.ipb_strobe);
        p_init_signals(ipbus_in.ipb_write);
        p_reset_signal(reset,c_IPBUS_CLOKC_PERIOD,c_IPBUS_CLOKC_PERIOD*5);

        if GEN_TESTCASE = 0 then  
            wait for c_IPBUS_CLOKC_PERIOD*5; 
            ipbus_in.ipb_addr <= int_to_vector(1,32);
            ipbus_in.ipb_wdata <= int_to_vector(1,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD; 
            ipbus_in.ipb_addr <= int_to_vector(0,32);
            ipbus_in.ipb_wdata <= int_to_vector(0,32);
            ipbus_in.ipb_strobe <= '0';
            ipbus_in.ipb_write <= '0';

        elsif GEN_TESTCASE = 1 then -- 1 clock addr, wdata, strobe
            -- 1.1 
            wait for c_IPBUS_CLOKC_PERIOD*5; 
            ipbus_in.ipb_addr <= int_to_vector(1,32);
            ipbus_in.ipb_wdata <= int_to_vector(1,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD; 
            ipbus_in.ipb_addr <= int_to_vector(2,32);
            ipbus_in.ipb_wdata <= int_to_vector(2,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD; 
            ipbus_in.ipb_addr <= int_to_vector(3,32);
            ipbus_in.ipb_wdata <= int_to_vector(3,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD; 
            ipbus_in.ipb_addr <= int_to_vector(0,32);
            ipbus_in.ipb_wdata <= int_to_vector(0,32);
            ipbus_in.ipb_strobe <= '0';
            ipbus_in.ipb_write <= '0';

        elsif GEN_TESTCASE = 2 then
            wait for c_IPBUS_CLOKC_PERIOD*5; 
            ipbus_in.ipb_addr <= int_to_vector(2,32);
            ipbus_in.ipb_wdata <= int_to_vector(2,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD; 
            ipbus_in.ipb_addr <= int_to_vector(0,32);
            ipbus_in.ipb_wdata <= int_to_vector(0,32);
            ipbus_in.ipb_strobe <= '0';
            ipbus_in.ipb_write <= '0';

        elsif GEN_TESTCASE = 3 then
            wait for c_IPBUS_CLOKC_PERIOD*5; 
            ipbus_in.ipb_addr <= int_to_vector(2,32);
            ipbus_in.ipb_wdata <= int_to_vector(1,32);
            ipbus_in.ipb_strobe <= '0';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD; 
            ipbus_in.ipb_addr <= int_to_vector(2,32);
            ipbus_in.ipb_wdata <= int_to_vector(1,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '0';
            wait for c_IPBUS_CLOKC_PERIOD; 
            ipbus_in.ipb_addr <= int_to_vector(0,32);
            ipbus_in.ipb_wdata <= int_to_vector(0,32);
            ipbus_in.ipb_strobe <= '0';
            ipbus_in.ipb_write <= '0';
        
        elsif GEN_TESTCASE = 4 then
            wait for c_IPBUS_CLOKC_PERIOD*5; 
            ipbus_in.ipb_addr <= int_to_vector(2,32);
            ipbus_in.ipb_wdata <= int_to_vector(2,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD; 
            ipbus_in.ipb_addr <= int_to_vector(2,32);
            ipbus_in.ipb_wdata <= int_to_vector(2,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD; 
            ipbus_in.ipb_addr <= int_to_vector(0,32);
            ipbus_in.ipb_wdata <= int_to_vector(0,32);
            ipbus_in.ipb_strobe <= '0';
            ipbus_in.ipb_write <= '0';

        elsif GEN_TESTCASE = 5 then -- 2 clock addr, wdata, strobe

            wait for c_IPBUS_CLOKC_PERIOD*5; 
            ipbus_in.ipb_addr <= int_to_vector(1,32);
            ipbus_in.ipb_wdata <= int_to_vector(1,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD*2; 
            ipbus_in.ipb_addr <= int_to_vector(2,32);
            ipbus_in.ipb_wdata <= int_to_vector(2,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD*2; 
            ipbus_in.ipb_addr <= int_to_vector(3,32);
            ipbus_in.ipb_wdata <= int_to_vector(3,32);
            ipbus_in.ipb_strobe <= '1';
            ipbus_in.ipb_write <= '1';
            wait for c_IPBUS_CLOKC_PERIOD*2; 
            ipbus_in.ipb_addr <= int_to_vector(0,32);
            ipbus_in.ipb_wdata <= int_to_vector(0,32);
            ipbus_in.ipb_strobe <= '0';
            ipbus_in.ipb_write <= '0';
        end if;

        wait;
    end process;
end;