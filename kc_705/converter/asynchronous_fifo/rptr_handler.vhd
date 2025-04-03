library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;


entity rptr_handler is
    Generic ( PTR_WIDTH : integer := 3 );
    Port (
        rclk        : in  STD_LOGIC;
        rrst      : in  STD_LOGIC;
        r_en        : in  STD_LOGIC;
        g_wptr_sync : in  STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0);
        b_rptr      : out STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0);
        g_rptr      : out STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0);
        empty       : out STD_LOGIC
    );
end rptr_handler;

architecture Behavioral of rptr_handler is
    signal b_rptr_reg, b_rptr_next : STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0) := (others => '0');
    signal g_rptr_reg, g_rptr_next : STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0) := (others => '0');
    signal empty_int : STD_LOGIC := '1';
    signal rempty : STD_LOGIC;
begin
    b_rptr_next <= std_logic_vector(unsigned(b_rptr_reg) + unsigned'(to_unsigned(0,PTR_WIDTH-1) & (r_en and (not empty_int ))));
    
    --g_rptr_next <= (b_rptr_next(PTR_WIDTH-2 downto 1)) xor b_rptr_next;
    --g_rptr_next <= std_logic_vector(unsigned(b_rptr_next(PTR_WIDTH-2 downto 1)) xor unsigned(b_rptr_next));
    g_rptr_next <= std_logic_vector(shift_right(unsigned(b_rptr_next), 1) xor unsigned(b_rptr_next));

    
    process (rclk, rrst)
    begin
        if rrst = '1' then
            b_rptr_reg <= (others => '0');
            g_rptr_reg <= (others => '0');
        elsif rising_edge(rclk) then
            b_rptr_reg <= b_rptr_next;
            g_rptr_reg <= g_rptr_next;
        end if;
    end process;
    
    process (rclk, rrst)
    begin
        if rrst = '1' then
            empty_int <= '1';
        elsif rising_edge(rclk) then
            empty_int <= rempty;
        end if;
    end process;
    
    rempty <= '1' when g_wptr_sync = g_rptr_next else '0';
    
    b_rptr <= b_rptr_reg;
    g_rptr <= g_rptr_reg;
    empty <= empty_int;
end Behavioral;



