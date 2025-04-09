##===================================================================================================##
##========================= Xilinx design constraints (XDC) information =============================##
##===================================================================================================##
##
## Company:               WUT (ISE PERG)
## Engineer:              Adrian Byszuk (a.byszuk@elka.pw.edu.pl)
##
## Project Name:          GBT-FPGA
## XDC File Name:         KC705 - GBT Bank example design clocks
##
## Target Device:         KC705 (Xilinx Kintex 7)
## Tool version:          Vivado 2014.4
##
## Version:               4.0
##
## Description:
##
## Versions history:      DATE         VERSION   AUTHOR              DESCRIPTION
##
##                        17/12/2014   1.0       Julian Mendez       First .xdc definition
##
## Additional Comments:
##
##===================================================================================================##
##===================================================================================================##

##===================================================================================================##
##=========================================  CLOCKS  ================================================##
##===================================================================================================##

##==============##
## FABRIC CLOCK ##
##==============##

set_property IOSTANDARD LVDS [get_ports SYSCLK_N]
set_property PACKAGE_PIN AD12 [get_ports SYSCLK_P]
set_property PACKAGE_PIN AD11 [get_ports SYSCLK_N]
set_property IOSTANDARD LVDS [get_ports SYSCLK_P]

create_clock -period 5.000 -name SYSCLK_P [get_ports SYSCLK_P]
set_clock_groups -asynchronous -group SYSCLK_P

##==============##
## FABRIC CLOCK ##
##==============##

# IO_L13P_T2_MRCC_15
set_property IOSTANDARD LVDS_25 [get_ports USER_CLOCK_P]
# IO_L13N_T2_MRCC_15
set_property PACKAGE_PIN K28 [get_ports USER_CLOCK_P]
set_property PACKAGE_PIN K29 [get_ports USER_CLOCK_N]
set_property IOSTANDARD LVDS_25 [get_ports USER_CLOCK_N]

create_clock -period 6.400 -name USER_CLOCK [get_ports USER_CLOCK_P]
set_clock_groups -asynchronous -group USER_CLOCK

##===========##
## MGT CLOCK ##
##===========##

## Comment: * The MGT reference clock MUST be provided by an external clock generator.
##
##          * The MGT reference clock frequency must be 120MHz for the latency-optimized GBT Bank.

# MGTREFCLK1P_117
# MGTREFCLK1N_117
set_property PACKAGE_PIN J8 [get_ports SMA_MGT_REFCLK_P]
set_property PACKAGE_PIN J7 [get_ports SMA_MGT_REFCLK_N]

create_clock -period 8.333 -name SMA_MGT_REFCLK [get_ports SMA_MGT_REFCLK_P]

##===================================================================================================##
##===================================================================================================##


##===================================================================================================##
##===================================IPBUS===========================================================##
##===================================================================================================##

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]


set_false_path -through [get_pins infra/clocks/rst_reg/Q]
set_false_path -through [get_nets infra/clocks/nuke_i]

set_property IOSTANDARD LVCMOS15 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AB8 [get_ports {leds[0]}]
set_property PACKAGE_PIN AA8 [get_ports {leds[1]}]
set_property PACKAGE_PIN AC9 [get_ports {leds[2]}]
set_property PACKAGE_PIN AB9 [get_ports {leds[3]}]
#false_path {leds[*]} sysclk

set_property IOSTANDARD LVCMOS25 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN Y29 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN W29 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN AA28 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN Y28 [get_ports {dip_sw[3]}]
#false_path {dip_sw[*]} sysclk

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
