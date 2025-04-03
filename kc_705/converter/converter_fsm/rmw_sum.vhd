library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;
use work.tb_package.all;

entity rmw_sum is
    port (
        -- read
        i_clk   : in  std_logic;
        i_reset : in  std_logic;
        i_start : in  std_logic;
        i_data  : in  std_logic_vector(63 downto 0);

        o_done  : buffer std_logic;
        o_ddone : out std_logic;
        o_wbus : out ipb_wbus;
        -- mod
        i_ack : in  std_logic;
        i_rdata : in STD_LOGIC_VECTOR(31 downto 0);
        -- wr
        o_wr_data : buffer STD_LOGIC_VECTOR(31 downto 0)
    );
end entity;

architecture rtl of rmw_sum is
    -- RD
    signal active : std_logic := '0';
    signal counter : unsigned(1 downto 0) := (others => '0');  
    signal addr_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal wdata_reg : std_logic_vector(31 downto 0) := (others => '0');
    -- MD
    signal ack_internal : std_logic;
    signal done_internal : std_logic;
    signal w_start : std_logic;
    -- WR
    signal w_active : std_logic := '0';
    signal w_counter : unsigned(1 downto 0) := (others => '0');  
    signal w_addr_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal w_wdata_reg : std_logic_vector(31 downto 0) := (others => '0');
    -- COMMON FOR RD WR
    signal ipb_addr : std_logic_vector(31 downto 0);
    signal ipb_wdata : std_logic_vector(31 downto 0);
    signal ipb_strobe : std_logic;
    signal ipb_write : std_logic;

begin

    mod_proc : process (i_clk)
    begin
        if rising_edge(i_clk) then
            if ack_internal = '1' then
                o_wr_data <= std_logic_vector(unsigned(wdata_reg) + unsigned(i_rdata));
                w_start <= '1';
            else 
                o_wr_data <= (others => '0') ;
                w_start <= '0';
            end if;
            
        end if;
    end process;

    rd_proc : process(i_clk, i_reset)
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
                if counter = "10" then  
                    active <= '0';  
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;

    wr_proc : process(i_clk, i_reset)
    begin
        if rising_edge(i_clk) then
            if w_active = '0' then
                if w_start = '1' then
                    w_addr_reg    <= i_data(63 downto 32);        
                    w_wdata_reg   <= o_wr_data;         
                    w_counter <= "01"; 
                    w_active  <= '1';
                end if;
            else
                if w_counter = "10" then  
                    w_active <= '0';  
                else
                    w_counter <= w_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- MOD
    ack_internal <= i_ack AND done_internal;
    done_internal <= '1' when (active = '1' and counter = "10") else '0';
    -- OUT
    ipb_addr <= addr_reg when (active = '1' or w_active = '1') else (others => '0');
    ipb_wdata  <=  w_wdata_reg when w_active = '1' else (others => '0');
    ipb_strobe <= '1' when (active = '1' or w_active = '1')  else '0';  
    --ipb_strobe <= '1' when (active = '1' or w_active = '1') and o_done = '1' else '0';
    ipb_write  <= '1' when w_active = '1' else '0';
    -- 
    set_wbus(o_wbus,ipb_addr, ipb_wdata, ipb_strobe, ipb_write);
    o_done <= '1' when (w_active = '1' and w_counter = "10") else '0';
    delay_signal(i_clk,o_done,o_ddone);


end architecture;

