library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_xpm_fifo_async is
end tb_xpm_fifo_async;

architecture sim of tb_xpm_fifo_async is

    signal rst           : std_logic := '1';
    signal wr_clk        : std_logic := '0';
    signal rd_clk        : std_logic := '0';
    signal wr_en         : std_logic := '0';
    signal rd_en         : std_logic := '0';
    signal din           : std_logic_vector(79 downto 0) := (others => '0');
    signal dout          : std_logic_vector(79 downto 0);
    signal full          : std_logic;
    signal empty         : std_logic;
    signal wr_data_count : std_logic_vector(3 downto 0);
    signal rd_data_count : std_logic_vector(3 downto 0);

begin

    uut: entity work.top_xpm_fifo_async
        port map (
            rst           => rst,
            wr_clk        => wr_clk,
            rd_clk        => rd_clk,
            wr_en         => wr_en,
            rd_en         => rd_en,
            din           => din,
            dout          => dout,
            full          => full,
            empty         => empty,
            wr_data_count => wr_data_count,
            rd_data_count => rd_data_count
        );

    wr_clk_process : process
    begin
        wr_clk <= '0';
        wait for 5 ns;
        wr_clk <= '1';
        wait for 5 ns;
    end process;

    rd_clk_process : process
    begin
        rd_clk <= '0';
        wait for 6.25 ns;
        rd_clk <= '1';
        wait for 6.25 ns;
    end process;

    stim_proc: process
    begin
       
        wait for 20 ns;
        rst <= '0';
        wait for 2000 ns;
        wr_en <= '1';
        din   <= std_logic_vector(to_unsigned(4, 79));
        wait for 20 ns;
        wr_en <= '0';
        rd_en <= '1';
        wait for 50 ns;
        wait;
        
    end process;
end sim;
