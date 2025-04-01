library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity fifo_mem is
    Generic (
        DEPTH      : integer := 8;
        DATA_WIDTH : integer := 8;
        PTR_WIDTH  : integer := 3
    );
    Port (
        wclk        : in  STD_LOGIC;
        w_en        : in  STD_LOGIC;
        rclk        : in  STD_LOGIC;
        r_en        : in  STD_LOGIC;
        b_wptr      : in  STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0);
        b_rptr      : in  STD_LOGIC_VECTOR(PTR_WIDTH-1 downto 0);
        data_in     : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        full        : in  STD_LOGIC;
        empty       : in  STD_LOGIC;
        data_out    : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
end fifo_mem;

architecture Behavioral of fifo_mem is
    type fifo_array is array (0 to DEPTH-1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal fifo : fifo_array := (others => (others => '0'));
    
    attribute ram_style : string;
    attribute ram_style of fifo : signal is "block"; -- "block" "distributed" "ultra" "registers" "auto"

    signal data_out_reg : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');

    
begin

    data_out <= data_out_reg;

    process (wclk)
    begin
        if rising_edge(wclk) then
            if (w_en = '1' and full = '0') then
                fifo(to_integer(unsigned(b_wptr(PTR_WIDTH-1 downto 0)))) <= data_in;
            end if;
        end if;
    end process;

    process (rclk)
    begin
        if rising_edge(rclk) then
            if (r_en = '1' and empty = '0') then
                data_out_reg <= fifo(to_integer(unsigned(b_rptr(PTR_WIDTH-1 downto 0))));
            end if;
        end if;
    end process;

end Behavioral;
