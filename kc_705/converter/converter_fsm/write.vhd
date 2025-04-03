library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;
use work.tb_package.all;

entity write is
    port (
        i_clk   : in  std_logic;
        i_reset : in  std_logic;
        i_start : in  std_logic;
        i_data  : in  std_logic_vector(63 downto 0);

        o_done  : buffer std_logic;
        o_ddone : out std_logic;
        o_wbus : out ipb_wbus
    );
end entity;

architecture rtl of write is

    signal active       : std_logic := '0';
    signal counter      : unsigned(1 downto 0) := (others => '0');  
    signal addr_reg     : std_logic_vector(31 downto 0) := (others => '0');
    signal wdata_reg    : std_logic_vector(31 downto 0) := (others => '0');
    --
    signal   ipb_addr  :  std_logic_vector(31 downto 0);
    signal   ipb_wdata :  std_logic_vector(31 downto 0);
    signal   ipb_strobe    :  std_logic;
    signal   ipb_write :  std_logic;

begin

    process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            active  <= '0';
            counter <= (others => '0');
            addr_reg    <= (others => '0');
            wdata_reg   <= (others => '0');
        elsif rising_edge(i_clk) then
            if active = '0' then
                if i_start = '1' then
                    addr_reg    <= i_data(63 downto 32);
                    wdata_reg   <= i_data(31 downto 0);
                    counter <= "01"; 
                    active  <= '1';
                end if;
            else
                if counter = "10" then  -- 2 i_clk
                    active <= '0';  
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- signals
    ipb_addr   <= addr_reg when active = '1' else (others => '0');
    ipb_wdata  <= wdata_reg when active = '1' else (others => '0');
    --ipb_strobe <= '1' when active = '1' else '0';
    ipb_strobe <= '1' when (active = '1') and o_done = '1' else '0';
    ipb_write  <= '1' when (active = '1') and o_done = '1' else '0';
    -- out
    set_wbus(o_wbus,ipb_addr, ipb_wdata, ipb_strobe, ipb_write);
    o_done <= '1' when (active = '1' and counter = "10") else '0'; -- ipb_strobe <= '1' when (active = '1') and o_done = '1' else '0';
    delay_signal(i_clk,o_done,o_ddone);

end architecture;
