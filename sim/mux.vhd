library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.m_package.all;
use work.tb_package.all;

-- sel 0  -> ipbus 
-- sel 1  -> pbus <-> gbt

entity mux is
    generic (
        USE_CLK  : boolean := true
    );
    port (
        -- ipbus tcm
            i_wbus_tcm      : in ipb_wbus;
            o_rbus_tcm      : out ipb_rbus;
        -- payload 
            o_wbus_pld      : out ipb_wbus;
            i_rbus_pld      : in ipb_rbus;
        -- ipbus <-> gbt 
            i_wbus_wr       : in ipb_wbus;
            o_rbus_wr       : out ipb_rbus;
        -- clk and sel 
            i_reset         : in std_logic;
            i_ipb_clk       : in std_logic;
            i_sel           : in std_logic
        );
end entity;


architecture rtl of mux is

begin

    gen_sync : if USE_CLK generate
        process(i_ipb_clk)
        begin
            if rising_edge(i_ipb_clk) then
                if i_reset = '1' then
                    o_wbus_pld  <= ipb_wbus_zero;
                    o_rbus_tcm  <= ipb_rbus_zero;
                    o_rbus_wr   <= ipb_rbus_zero;
                elsif i_sel = '0' then
                    o_wbus_pld  <= i_wbus_tcm;
                    o_rbus_tcm  <= i_rbus_pld;
                    o_rbus_wr   <= ipb_rbus_zero;
                else
                    o_wbus_pld  <= i_wbus_wr;
                    o_rbus_wr   <= i_rbus_pld;
                    o_rbus_tcm  <= ipb_rbus_zero;
                end if;
            end if;
        end process;
    end generate;

    gen_async : if not USE_CLK generate
        process(i_sel, i_wbus_tcm, i_rbus_pld, i_wbus_wr)
        begin
                if i_sel = '0' then
                    o_wbus_pld  <= i_wbus_tcm;
                    o_rbus_tcm  <= i_rbus_pld;
                    o_rbus_wr   <= ipb_rbus_zero;
                else
                    o_wbus_pld  <= i_wbus_wr;
                    o_rbus_wr   <= i_rbus_pld;
                    o_rbus_tcm  <= ipb_rbus_zero;
                end if;
        end process;
    end generate;


end rtl;


