#-------------------------------------------------------------------------------
#
#   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#                                     - - -
#
#   Additional information about ipbus-firmare and the list of ipbus-firmware
#   contacts are available at
#
#       https://ipbus.web.cern.ch/ipbus
#
#-------------------------------------------------------------------------------


set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# System clock (200MHz)
create_clock -period 5.000 -name sysclk [get_ports sysclk_p]

set_false_path -through [get_pins infra/clocks/rst_reg/Q]
set_false_path -through [get_nets infra/clocks/nuke_i]

set_property IOSTANDARD LVDS [get_ports sysclk_*]
set_property PACKAGE_PIN AD12 [get_ports sysclk_p]
set_property PACKAGE_PIN AD11 [get_ports sysclk_n]

set_property IOSTANDARD LVCMOS15 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AB8 [get_ports {leds[0]}]
set_property PACKAGE_PIN AA8 [get_ports {leds[1]}]
set_property PACKAGE_PIN AC9 [get_ports {leds[2]}]
set_property PACKAGE_PIN AB9 [get_ports {leds[3]}]
false_path {leds[*]} sysclk

set_property IOSTANDARD LVCMOS25 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN Y29 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN W29 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN AA28 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN Y28 [get_ports {dip_sw[3]}]
false_path {dip_sw[*]} sysclk

set_property IOSTANDARD LVCMOS25 [get_ports {gmii* phy_rst}]
set_property PACKAGE_PIN K30 [get_ports gmii_gtx_clk]
set_property PACKAGE_PIN M27 [get_ports gmii_tx_en]
set_property PACKAGE_PIN N29 [get_ports gmii_tx_er]
set_property PACKAGE_PIN N27 [get_ports {gmii_txd[0]}]
set_property PACKAGE_PIN N25 [get_ports {gmii_txd[1]}]
set_property PACKAGE_PIN M29 [get_ports {gmii_txd[2]}]
set_property PACKAGE_PIN L28 [get_ports {gmii_txd[3]}]
set_property PACKAGE_PIN J26 [get_ports {gmii_txd[4]}]
set_property PACKAGE_PIN K26 [get_ports {gmii_txd[5]}]
set_property PACKAGE_PIN L30 [get_ports {gmii_txd[6]}]
set_property PACKAGE_PIN J28 [get_ports {gmii_txd[7]}]
set_property PACKAGE_PIN U27 [get_ports gmii_rx_clk]
set_property PACKAGE_PIN R28 [get_ports gmii_rx_dv]
set_property PACKAGE_PIN V26 [get_ports gmii_rx_er]
set_property PACKAGE_PIN U30 [get_ports {gmii_rxd[0]}]
set_property PACKAGE_PIN U25 [get_ports {gmii_rxd[1]}]
set_property PACKAGE_PIN T25 [get_ports {gmii_rxd[2]}]
set_property PACKAGE_PIN U28 [get_ports {gmii_rxd[3]}]
set_property PACKAGE_PIN R19 [get_ports {gmii_rxd[4]}]
set_property PACKAGE_PIN T27 [get_ports {gmii_rxd[5]}]
set_property PACKAGE_PIN T26 [get_ports {gmii_rxd[6]}]
set_property PACKAGE_PIN T28 [get_ports {gmii_rxd[7]}]
set_property PACKAGE_PIN L20 [get_ports phy_rst]


# IPbus clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT3]

# Other derived clocks
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT4]

# Declare the oscillator clock, ipbus clock and aux clock as unrelated
set_clock_groups -asynchronous -group [get_clocks sysclk] -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_aux]]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk200]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 80 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {data_rcv[0]} {data_rcv[1]} {data_rcv[2]} {data_rcv[3]} {data_rcv[4]} {data_rcv[5]} {data_rcv[6]} {data_rcv[7]} {data_rcv[8]} {data_rcv[9]} {data_rcv[10]} {data_rcv[11]} {data_rcv[12]} {data_rcv[13]} {data_rcv[14]} {data_rcv[15]} {data_rcv[16]} {data_rcv[17]} {data_rcv[18]} {data_rcv[19]} {data_rcv[20]} {data_rcv[21]} {data_rcv[22]} {data_rcv[23]} {data_rcv[24]} {data_rcv[25]} {data_rcv[26]} {data_rcv[27]} {data_rcv[28]} {data_rcv[29]} {data_rcv[30]} {data_rcv[31]} {data_rcv[32]} {data_rcv[33]} {data_rcv[34]} {data_rcv[35]} {data_rcv[36]} {data_rcv[37]} {data_rcv[38]} {data_rcv[39]} {data_rcv[40]} {data_rcv[41]} {data_rcv[42]} {data_rcv[43]} {data_rcv[44]} {data_rcv[45]} {data_rcv[46]} {data_rcv[47]} {data_rcv[48]} {data_rcv[49]} {data_rcv[50]} {data_rcv[51]} {data_rcv[52]} {data_rcv[53]} {data_rcv[54]} {data_rcv[55]} {data_rcv[56]} {data_rcv[57]} {data_rcv[58]} {data_rcv[59]} {data_rcv[60]} {data_rcv[61]} {data_rcv[62]} {data_rcv[63]} {data_rcv[64]} {data_rcv[65]} {data_rcv[66]} {data_rcv[67]} {data_rcv[68]} {data_rcv[69]} {data_rcv[70]} {data_rcv[71]} {data_rcv[72]} {data_rcv[73]} {data_rcv[74]} {data_rcv[75]} {data_rcv[76]} {data_rcv[77]} {data_rcv[78]} {data_rcv[79]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 80 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {data_snd[0]} {data_snd[1]} {data_snd[2]} {data_snd[3]} {data_snd[4]} {data_snd[5]} {data_snd[6]} {data_snd[7]} {data_snd[8]} {data_snd[9]} {data_snd[10]} {data_snd[11]} {data_snd[12]} {data_snd[13]} {data_snd[14]} {data_snd[15]} {data_snd[16]} {data_snd[17]} {data_snd[18]} {data_snd[19]} {data_snd[20]} {data_snd[21]} {data_snd[22]} {data_snd[23]} {data_snd[24]} {data_snd[25]} {data_snd[26]} {data_snd[27]} {data_snd[28]} {data_snd[29]} {data_snd[30]} {data_snd[31]} {data_snd[32]} {data_snd[33]} {data_snd[34]} {data_snd[35]} {data_snd[36]} {data_snd[37]} {data_snd[38]} {data_snd[39]} {data_snd[40]} {data_snd[41]} {data_snd[42]} {data_snd[43]} {data_snd[44]} {data_snd[45]} {data_snd[46]} {data_snd[47]} {data_snd[48]} {data_snd[49]} {data_snd[50]} {data_snd[51]} {data_snd[52]} {data_snd[53]} {data_snd[54]} {data_snd[55]} {data_snd[56]} {data_snd[57]} {data_snd[58]} {data_snd[59]} {data_snd[60]} {data_snd[61]} {data_snd[62]} {data_snd[63]} {data_snd[64]} {data_snd[65]} {data_snd[66]} {data_snd[67]} {data_snd[68]} {data_snd[69]} {data_snd[70]} {data_snd[71]} {data_snd[72]} {data_snd[73]} {data_snd[74]} {data_snd[75]} {data_snd[76]} {data_snd[77]} {data_snd[78]} {data_snd[79]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_40]
