library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;


entity wptr_handler is
    Generic ( PTR_WIDTH : integer := 3 );
    Port (
        wclk        : in  STD_LOGIC;
        wrst      : in  STD_LOGIC;
        w_en        : in  STD_LOGIC;
        g_rptr_sync : in  STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0);
        b_wptr      : out STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0); 
        g_wptr      : out STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0); 
        full        : out STD_LOGIC
    );
end wptr_handler;

architecture Behavioral of wptr_handler is
    signal b_wptr_reg, b_wptr_next : STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0) := (others => '0');
    signal g_wptr_reg, g_wptr_next : STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0) := (others => '0');
    signal full_int : STD_LOGIC := '0';
    signal wfull : STD_LOGIC;
begin
    
    b_wptr_next <= std_logic_vector(unsigned(b_wptr_reg) + unsigned'(to_unsigned(0,PTR_WIDTH-1) & (w_en and (not full_int))));
    
    
    --g_wptr_next <= (b_wptr_next(PTR_WIDTH-1 downto 1)) xor b_wptr_next;
    g_wptr_next <= std_logic_vector((unsigned(b_wptr_next) srl 1) xor unsigned(b_wptr_next));

    
    
    process (wclk, wrst)
    begin
        if wrst = '1' then
            b_wptr_reg <= (others => '0');
            g_wptr_reg <= (others => '0');
        elsif rising_edge(wclk) then
            b_wptr_reg <= b_wptr_next;
            g_wptr_reg <= g_wptr_next;
        end if;
    end process;
    
    process (wclk, wrst)
    begin
        if wrst = '1' then
            full_int <= '0';
        elsif rising_edge(wclk) then
            full_int <= wfull;
        end if;
    end process;
    
    wfull <= '1' when g_wptr_next = (not g_rptr_sync(PTR_WIDTH-1 downto PTR_WIDTH-2)) & g_rptr_sync(PTR_WIDTH-3 downto 0) else '0';
    
    b_wptr <= b_wptr_reg;
    g_wptr <= g_wptr_reg;
    full <= full_int;
end Behavioral;

