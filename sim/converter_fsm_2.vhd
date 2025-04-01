library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.m_package.all;
use work.ipbus_reg_types.all;

entity converter_fsm_2 is
    port (
        i_clk : in std_logic;
        i_reset : in std_logic;
        -- fifo from gbt
        i_fifo_empty : in std_logic;
        i_data_gbt : in std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
        o_data_gbt : out std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
        o_rd_en :out STD_LOGIC;
        -- converter
        o_done : buffer STD_LOGIC;
        o_ack_and : out STD_LOGIC;
        o_rbus_data : buffer STD_LOGIC_VECTOR(31 downto 0);
        o_rbus_err : out STD_LOGIC;
        --rmv
        o_wr_data : buffer STD_LOGIC_VECTOR(31 downto 0)
    );
end entity;

architecture rtl of converter_fsm_2 is
    -- fsm
    type t_fsm is (t_IDEL, t_SEND_RD_EN, t_WAIT, t_DATA, t_TRAN, t_READ, t_WRITE,t_RMW_AND, t_RMW_OR, t_RMW_SUM, t_BLOCK_READ_INC, t_WAIT_2);
    signal state, next_state : t_fsm;
    -- c_N_TYPE 
    signal start : STD_LOGIC_VECTOR(c_N_TYPE-1 downto 0)  := (others => '0'); 
    signal done : STD_LOGIC_VECTOR(4 downto 0); ----------------------------------!!!!!!!!!!!!!!!!!!!!!!!!! Сhange 3 to c_N_TYPE 
    -- wbus_array, wbus, rbus 
    type ipb_wbus_array is array (0 to c_N_TYPE-1) of ipb_wbus;
    signal wbus_array : ipb_wbus_array;
    signal wbus_to_reg_v : ipb_wbus;
    signal rbus_from_reg_v : ipb_rbus;
    -- reg_v
    signal q: ipb_reg_v(c_N_REG - 1 downto 0);
    signal qmask: ipb_reg_v(c_N_REG - 1 downto 0) := (others => (others => '1'));
    signal stb:  std_logic_vector(c_N_REG - 1 downto 0);
    -- gbt
    signal gbt_data : gbt_frame;
    -- ipbus
    signal rbus_ack : std_logic;
    -- rmw 
    signal i_ack : std_logic;
    signal i_rdata : STD_LOGIC_VECTOR(31 downto 0);
    -- signal o_wr_data : STD_LOGIC_VECTOR(31 downto 0);
    -- other
    signal clk_div : std_logic;
    signal internal_clk : std_logic;
    constant BLOCK_SELECT : integer := 2;
        
begin

    fsm_1: process (i_clk)
        begin
            if rising_edge(i_clk) then
                if i_reset = '1' then
                    state <= t_IDEL;
                else
                    state <= next_state;
                end if;
            end if;
        end process;

    fsm_2: process (all)
        begin
            case state is
                when t_IDEL                 => 
                                            if i_fifo_empty = '0' then
                                                next_state <= t_SEND_RD_EN;
                                                else
                                                next_state <= t_IDEL;
                                                end if;
                when t_SEND_RD_EN           =>  next_state <= t_WAIT;
                when t_WAIT                 =>  next_state <= t_DATA;
                when t_DATA                 =>  next_state <= t_TRAN;
                when t_TRAN                 =>  next_state <= t_WAIT_2;
                when t_WAIT_2               =>  
                                            if o_done = '1' then
                                                next_state <= t_IDEL;
                                                else
                                                next_state <= t_WAIT_2;
                                                end if;
                when others                 =>  next_state <= t_IDEL;
            end case;
        end process;

    fsm_3: process (i_clk)
        begin
            if rising_edge(i_clk) then
                case state is
                    when t_IDEL =>              o_rd_en <= '0';
                                                clk_div2(i_reset,'0',internal_clk,clk_div);
                    when t_SEND_RD_EN =>        o_rd_en <= '1';
                    when t_WAIT =>              o_rd_en <= '0';
                    when t_DATA =>          
                                                gbt_data.swt_id <= i_data_gbt(79 downto 76);
                                                gbt_data.not_used <= i_data_gbt(75 downto 68);
                                                gbt_data.transaction_type <= i_data_gbt(67 downto 64);
                                                gbt_data.address <= i_data_gbt(63 downto 32);
                                                gbt_data.data <= i_data_gbt(31 downto 0);
                    when t_TRAN =>              
                                                case gbt_data.transaction_type is
                                                    when c_READ =>                  start(0) <= '1';
                                                    when c_WRITE =>                 start(1) <= '1';
                                                    when c_RMW_AND =>               start(2) <= '1';
                                                    when c_RMW_OR =>                start(3) <= '1';
                                                    when c_RMW_SUM =>               start(4) <= '1';
                                                    when c_BLOCK_READ_INC =>        start(5) <= '1';
                                                    when c_BLOCK_READ_NON_INC =>    start(6) <= '1';
                                                    when others =>                  start  <= (others => '0') ;
                                                end case;   
                    when t_WAIT_2 =>            start  <= int_to_vector(0,c_N_TYPE);
                                                clk_div2(i_reset,'1',internal_clk,clk_div);
                    when others =>              null;
                end case;
                
            end if;
        end process;

    process (all)
        begin
            case gbt_data.transaction_type is
                when c_READ =>                  wbus_to_reg_v <= wbus_array(0);
                when c_WRITE =>                 wbus_to_reg_v <= wbus_array(1);
                when c_RMW_AND =>               wbus_to_reg_v <= wbus_array(2);
                when c_RMW_OR =>                wbus_to_reg_v <= wbus_array(3);
                when c_RMW_SUM =>               wbus_to_reg_v <= wbus_array(4);
                when c_BLOCK_READ_INC =>        wbus_to_reg_v <= wbus_array(5);
                when c_BLOCK_READ_NON_INC =>    wbus_to_reg_v <= wbus_array(6);
                when others =>                  set_wbus(wbus_to_reg_v,(others => '0'),(others => '0'),'0','0');
            end case;  
        end process;

    mem_sel_1 : if BLOCK_SELECT = 1 generate
        ipbus_reg_v_inst : entity work.ipbus_reg_v
            generic map (
            N_REG => c_N_REG
            )
            port map (
            clk => i_clk,
            reset => i_reset,
            ipbus_in => wbus_to_reg_v, --wbus
            ipbus_out => rbus_from_reg_v, --rbus
            q => q,
            qmask => qmask,
            stb => stb
            );
        end generate;
    
    mem_sel_2 : if BLOCK_SELECT = 2 generate
        ipbus_ram_inst : entity work.ipbus_ram
            generic map (
            ADDR_WIDTH => 3
            )
            port map (
            clk => i_clk,
            reset => i_reset,
            ipbus_in => wbus_to_reg_v,
            ipbus_out => rbus_from_reg_v
            );
        end generate;
      
            
    mem_sel_3 : if BLOCK_SELECT = 3 generate
        ipbus_peephole_ram_inst : entity work.ipbus_peephole_ram
            generic map (
            ADDR_WIDTH => 3
            )
            port map (
            clk => i_clk,
            reset => i_reset,
            ipbus_in => wbus_to_reg_v,
            ipbus_out => rbus_from_reg_v
            );
        end generate;

    
    write_inst : entity work.write
        port map (
        i_clk => i_clk,
        i_reset => i_reset,
        i_start => start(1),
        i_data => (gbt_data.address & gbt_data.data),
        o_wbus => wbus_array(1),
        o_done => done(1),
        o_ddone => open
        );

    read_inst : entity work.read
        port map (
        i_clk => i_clk,
        i_reset => i_reset,
        i_start => start(0),
        i_data => (gbt_data.address & gbt_data.data),
        o_done => done(0),
        o_ddone => open,
        o_wbus => wbus_array(0)
        );
    
    block_read_incrementing_inst : entity work.block_read_incrementing
        port map (
        i_clk => i_clk,
        i_reset => i_reset,
        i_start => start(5),
        i_address => gbt_data.address,
        i_number_of_rd_words => gbt_data.data,
        o_done => done(2),
        o_wbus => wbus_array(5)
        );

    block_read_non_incrementing_inst : entity work.block_read_non_incrementing
        port map (
        i_clk => i_clk,
        i_reset => i_reset,
        i_start => start(6),
        i_address => gbt_data.address,
        i_number_of_rd_words => gbt_data.data,
        o_done => done(3),
        o_wbus => wbus_array(6)
        );

    rmw_sum_inst : entity work.rmw_sum
        port map (
        i_clk => i_clk,
        i_reset => i_reset,
        i_start => start(4),
        i_data =>  (gbt_data.address & gbt_data.data),
        o_done => done(4),
        o_ddone => open,
        o_wbus => wbus_array(4),
        -- mod
        i_ack  => o_ack_and,
        i_rdata => rbus_from_reg_v.ipb_rdata,
        -- wr
        o_wr_data => o_wr_data
        );

        --  <= 
        o_done <= done(0) or done(1) or done(2) or done(3) or done(4); ----------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!
        o_ack_and <= '0'    when    (gbt_data.transaction_type = c_WRITE or 
                                    wbus_array(4).ipb_write = '1' ) 
                            else    (clk_div AND rbus_from_reg_v.ipb_ack); --o_ack_and <= clk_div AND rbus_from_reg_v.ipb_ack; 

        unpack_rbus(rbus_from_reg_v,o_rbus_data,rbus_ack,o_rbus_err);
        o_data_gbt <= gbt_data.swt_id & gbt_data.not_used & gbt_data.transaction_type & gbt_data.address & o_rbus_data;





end architecture;
