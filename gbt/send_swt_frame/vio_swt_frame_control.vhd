--+--------+--------------------------+
--| Code   | Transaction              |
--+--------+--------------------------+
--| 0x0    | read                     |
--| 0x1    | write                    |
--| 0x2    | RMWbits AND              |
--| 0x3    | RMWbits OR               |
--| 0x4    | RMW sum                  |
--| 0x8    | block read               |
--| 0x9    | block read non-increment |
--+--------+--------------------------+

--+--------------------+-----------------------------+---------------------------------------------------------------+
--| Signal             | Direction                   | Description                                                   |
--+--------------------+-----------------------------+---------------------------------------------------------------+
--| i_clk              | in                          | Clock signal 40 Mhz                                           |
--| i_reset            | in                          | Reset                                                         |
--| i_sel              | in                          | Selector: swt or gbt_pattern_generator                        |
--| i_send_button      | in                          | Send SWT frame trigger (on rising edge from '0' to '1')       |
--| i_data             | in  STD_LOGIC_VECTOR(31:0)  | Data for memory write                                         |
--| i_adress           | in  STD_LOGIC_VECTOR(31:0)  | Address for read/write operation                              |
--| i_tran_type        | in  STD_LOGIC_VECTOR(3:0)   | Transaction type code                                         |
--| o_swt_frame        | out STD_LOGIC_VECTOR(79:0)  | Output SWT frame (zero if not an SWT transaction)             |
--| o_sel              | out                         | o_sel <= i_sel;                                               |
--+--------------------+-----------------------------+---------------------------------------------------------------+


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vio_swt_frane_control is
    Port (
        i_clk : in  STD_LOGIC; 
        i_reset : in  STD_LOGIC;
        i_sel : in  STD_LOGIC_VECTOR(0 downto 0);
        i_send_button : in STD_LOGIC_VECTOR(0 downto 0);
        i_data : in STD_LOGIC_VECTOR(31 downto 0);
        i_adress : in STD_LOGIC_VECTOR(31 downto 0);
        i_tran_type : in STD_LOGIC_VECTOR(3 downto 0);
        o_swt_frame : out STD_LOGIC_VECTOR(79 downto 0);
        o_sel : out  STD_LOGIC_VECTOR(0 downto 0)
    );
end vio_swt_frane_control;

architecture Behavioral of vio_swt_frane_control is
    signal send_button : STD_LOGIC_VECTOR(0 downto 0) := "0";
    constant c_SWT : std_logic_vector(3 downto 0)   := "0011";
    constant c_NOT_USED : std_logic_vector(7 downto 0)   := x"00";

begin

    process(i_clk)
    begin
        if i_reset = '1' then
            send_button <= "0";
            o_swt_frame <= (others => '0') ;
        elsif rising_edge(i_clk) then
            if send_button = "0" and i_send_button = "1" then
                o_swt_frame <=  c_SWT & c_NOT_USED & i_tran_type & i_adress & i_data;  
            else
                o_swt_frame <= (others => '0'); 
            end if;
            send_button <= i_send_button;  
        end if;
    end process;

    o_sel <= i_sel;
    
end Behavioral;


