library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;


package tb_package is
    procedure p_generate_clock(signal clk : out std_logic; constant clk_period : time);
    procedure p_init_signals(signal sl : out std_logic);
    procedure p_init_signals(signal slv : out std_logic_vector); 
    procedure p_reset_signal(
        signal reset_signal : out std_logic;
        constant reset_delay : time := 100 ns;
        constant reset_duration : time := 100 ns);
            
end package tb_package;


package body tb_package is
    -- 
    procedure p_generate_clock(signal clk : out std_logic; constant clk_period : time) is
        begin
            while true loop
                clk <= '0';
                wait for clk_period / 2;
                clk <= '1';
                wait for clk_period / 2;
            end loop;
        end procedure p_generate_clock;
    --
    procedure p_init_signals(signal sl : out std_logic) is
        begin
            sl <= '0';
        end procedure;
    --
    procedure p_init_signals(signal slv : out std_logic_vector) is
        begin
            slv <= (others => '0');
        end procedure;
    -- 
    procedure p_reset_signal(
            signal reset_signal : out std_logic;
            constant reset_delay : time := 100 ns;
            constant reset_duration : time := 100 ns) is
        begin
            wait for reset_delay;      
                reset_signal <= '1';       
            wait for reset_duration;   
                reset_signal <= '0';       
        end procedure;

end package body tb_package;
