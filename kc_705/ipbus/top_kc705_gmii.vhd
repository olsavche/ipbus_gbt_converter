---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


-- Top-level design for ipbus demo
--
-- This version is for KC705 eval board, using SFP ethernet interface
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 23/2/11

library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.ipbus.all;
use work.my_package.all;

entity top is generic (
	ENABLE_DHCP  : std_logic := '0'; -- Default is build with support for RARP rather than DHCP
	USE_IPAM     : std_logic := '0'; -- Default is no, use static IP address as specified by ip_addr below
	MAC_ADDRESS  : std_logic_vector(47 downto 0) := X"000a35000102"
	);
	port (
    sysclk_p     : in  std_logic;
    sysclk_n     : in  std_logic;
    leds         : out std_logic_vector(3 downto 0);  -- status LEDs
    dip_sw       : in  std_logic_vector(3 downto 0);  -- switches
    gmii_gtx_clk : out std_logic;
    gmii_tx_en   : out std_logic;
    gmii_tx_er   : out std_logic;
    gmii_txd     : out std_logic_vector(7 downto 0);
    gmii_rx_clk  : in  std_logic;
    gmii_rx_dv   : in  std_logic;
    gmii_rx_er   : in  std_logic;
    gmii_rxd     : in  std_logic_vector(7 downto 0);
    phy_rst      : out std_logic
    );

end top;

architecture rtl of top is

    signal clk_ipb, rst_ipb, clk_aux, rst_aux, nuke, soft_rst, phy_rst_e, userled : std_logic;
    signal mac_addr : std_logic_vector(47 downto 0);
    signal ip_addr : std_logic_vector(31 downto 0);
    signal ipb_out : ipb_wbus;
    signal ipb_in : ipb_rbus; 
    -- my signals
    signal clk_125, clk_40  : std_logic;
    signal converter_rbus, rbus_mux_mem : ipb_rbus;
    signal converter_wbus, wbus_mux_mem : ipb_wbus;
    signal data_rcv, data_snd : std_logic_vector(c_GBT_FRAME_WIDTH-1 downto 0);
    signal sel : std_logic_vector(0 downto 0);
    -- vio
    signal probe_sel : std_logic_vector(0 downto 0);
    signal probe_send_button : std_logic_vector(0 downto 0);
    signal probe_data : std_logic_vector(31 downto 0);
    signal probe_adress : std_logic_vector(31 downto 0);
    signal probe_tran_type : std_logic_vector(3 downto 0);

    attribute MARK_DEBUG : string;
    attribute MARK_DEBUG of data_rcv, data_snd : signal is "TRUE";

    
    COMPONENT clk_wiz_0
        port(
        clk_out1          : out    std_logic;
        reset             : in     std_logic;
        clk_in1           : in     std_logic);
        end COMPONENT;

    COMPONENT vio_0
        PORT (
        clk : IN STD_LOGIC;
        probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        probe_out3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        probe_out4 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
        END COMPONENT;

begin

-- Infrastructure

    infra : entity work.kc705_gmii_infra
		generic map(
			DHCP_not_RARP => ENABLE_DHCP
		)
        port map(
            sysclk_p     => sysclk_p,
            sysclk_n     => sysclk_n,
            clk_ipb_o    => clk_ipb,
            rst_ipb_o    => rst_ipb,
            rst_125_o    => phy_rst_e,
            clk_aux_o    => clk_aux,
            rst_aux_o    => rst_aux,
            nuke         => nuke,
            soft_rst     => soft_rst,
            leds         => leds(1 downto 0),
            gmii_gtx_clk => gmii_gtx_clk,
            gmii_txd     => gmii_txd,
            gmii_tx_en   => gmii_tx_en,
            gmii_tx_er   => gmii_tx_er,
            gmii_rx_clk  => gmii_rx_clk,
            gmii_rxd     => gmii_rxd,
            gmii_rx_dv   => gmii_rx_dv,
            gmii_rx_er   => gmii_rx_er,
            mac_addr     => mac_addr,
            ip_addr      => ip_addr,
            ipam_select  => USE_IPAM,
            ipb_in       => ipb_in,
            ipb_out      => ipb_out,
            clk_125_o    => clk_125
            ); 

    leds(3 downto 2) <= '0' & userled;
    phy_rst          <= not phy_rst_e;

    mac_addr <= MAC_ADDRESS;
    ip_addr <= X"c0a8010f"; -- 192.168.1.15
	--ip_addr <= X"c0a8c82" & dip_sw; -- 192.168.200.32+n

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

    payload : entity work.payload
        port map(
        ipb_clk  => clk_ipb,
        ipb_rst  => rst_ipb,
        ipb_in   => wbus_mux_mem, -- from mux
        ipb_out  => rbus_mux_mem, -- from mux
        clk      => clk_aux,
        rst      => rst_aux,
        nuke     => nuke,
        soft_rst => soft_rst,
        userled  => userled
        );

    clk_wiz_0_inst : clk_wiz_0
        port map ( 
        clk_out1 => clk_40,
        reset => '0',
        clk_in1 => clk_125
        );
        
    vio_0_inst : vio_0
        PORT MAP (
        clk => clk_40,
        probe_out0 => probe_sel,
        probe_out1 => probe_send_button,
        probe_out2 => probe_data,
        probe_out3 => probe_adress,
        probe_out4 => probe_tran_type);


    
    mux_inst : entity work.mux
        generic map (
        USE_CLK => false
        )
        port map (
        i_wbus_kc705 => ipb_out,
        o_rbus_kc705 => ipb_in,
        o_wbus_mem => wbus_mux_mem,
        i_rbus_mem => rbus_mux_mem,
        i_wbus_converter => converter_wbus,
        o_rbus_converter => converter_rbus,
        i_reset => '0',
        i_ipb_clk => clk_ipb,
        i_sel => sel
        );

    converter_inst : entity work.converter
        port map (
        i_clk_ipbus => clk_ipb,
        i_clk_gbt => clk_40,
        i_reset =>  '0',
        i_data_rcv => data_rcv, -- 
        o_data_snd => data_snd, -- 
        o_wbus => converter_wbus, -- mux 
        i_rbus => converter_rbus -- mux 
        );

    vio_swt_frane_control_inst : entity work.vio_swt_frane_control
        port map (
        i_clk => clk_40,
        i_reset => '0',
        i_sel => probe_sel, -- VIO
        i_send_button => probe_send_button, -- VIO
        i_data => probe_data, -- VIO
        i_adress => probe_adress, -- VIO
        i_tran_type => probe_tran_type, -- VIO
        o_swt_frame => data_rcv,
        o_sel => sel
        );
        

end rtl;