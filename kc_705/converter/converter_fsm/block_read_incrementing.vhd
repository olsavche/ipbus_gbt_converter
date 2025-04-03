

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;

entity block_read_incrementing is
    Port (
        i_clk                   : in  STD_LOGIC;
        i_reset                 : in  STD_LOGIC;
        i_start                 : in  STD_LOGIC;
        i_address               : in  STD_LOGIC_VECTOR(31 downto 0); 
        i_number_of_rd_words    : in  STD_LOGIC_VECTOR(31 downto 0);
        o_done                  : out STD_LOGIC;
        o_wbus                  : out ipb_wbus
    );
end block_read_incrementing;

architecture Behavioral of block_read_incrementing is
    signal address_reg     : unsigned(31 downto 0);
    signal word_counter    : unsigned(31 downto 0);
    signal delay_counter   : std_logic := '0';
    signal strobe          : std_logic := '0';
    signal done_reg        : std_logic := '0'; 
begin

    process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            address_reg    <= (others => '0');
            word_counter   <= (others => '0');
            delay_counter  <= '0';
            strobe         <= '0';
            done_reg       <= '0';
        elsif rising_edge(i_clk) then
            -- Сбро�? done_reg через 1 такт
            if done_reg = '1' then
                done_reg <= '0';
            end if;

            if i_start = '1' and strobe = '0' then
                address_reg    <= unsigned(i_address);
                word_counter   <= (others => '0');
                delay_counter  <= '0';
                strobe         <= '1';
            elsif strobe = '1' then
                if delay_counter = '1' then
                    if word_counter < unsigned(i_number_of_rd_words) - 1 then
                        address_reg  <= address_reg + 1;
                        word_counter <= word_counter + 1;
                    else
                        strobe    <= '0';
                        done_reg <= '1';  
                    end if;
                end if;
                delay_counter <= not delay_counter;
            end if;
        end if;
    end process;

    o_done <= done_reg;

    set_wbus(o_wbus, std_logic_vector(address_reg), (others => '0'), strobe, '0');

end Behavioral;