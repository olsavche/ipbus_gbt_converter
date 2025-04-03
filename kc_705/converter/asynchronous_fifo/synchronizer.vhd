library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity synchronizer is
    Generic ( WIDTH : integer := 3 );
    Port (
        clk   : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        d_in  : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0); 
        d_out : out STD_LOGIC_VECTOR(WIDTH-1 downto 0) 
    );
end synchronizer;

architecture Behavioral of synchronizer is
    signal q1 : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := (others => '0'); 
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q1    <= (others => '0');
                d_out <= (others => '0');
            else
                q1    <= d_in;
                d_out <= q1;
            end if;
        end if;
    end process;
    
end Behavioral;