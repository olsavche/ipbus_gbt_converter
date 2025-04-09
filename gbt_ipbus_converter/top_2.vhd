
-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

-- Custom libraries and packages:
use work.gbt_bank_package.all;
use work.vendor_specific_gbt_bank_package.all;
use work.gbt_exampledesign_package.all;

use work.ipbus.all;



entity top_2 is
    generic (
        ENABLE_DHCP  : std_logic := '0'; -- Default is build with support for RARP rather than DHCP
        USE_IPAM     : std_logic := '0'; -- Default is no, use static IP address as specified by ip_addr below
        MAC_ADDRESS  : std_logic_vector(47 downto 0) := X"000a35000102" -- add_by_my 
    );

    port (
        --===============--
        -- General reset --
        --===============--
        CPU_RESET      : in  std_logic;  
        
        --===============--
        -- Clocks scheme --
        --===============-- 
        SYSCLK_P       : in  std_logic;
        SYSCLK_N       : in  std_logic;  
        USER_CLOCK_P   : in  std_logic;
        USER_CLOCK_N   : in  std_logic;     
        SMA_MGT_REFCLK_P : in  std_logic;
        SMA_MGT_REFCLK_N : in  std_logic; 
        
        --==========--
        -- MGT(GTX) --
        --==========--                    
        SFP_TX_P       : out std_logic;
        SFP_TX_N       : out std_logic;
        SFP_RX_P       : in  std_logic;
        SFP_RX_N       : in  std_logic;    
        SFP_TX_DISABLE : out std_logic;
        
        --===============--      
        -- On-board LEDs --      
        --===============--
 --       GPIO_LED_0_LS  : out std_logic;
 --       GPIO_LED_1_LS  : out std_logic;
 --       GPIO_LED_2_LS  : out std_logic;
 --       GPIO_LED_3_LS  : out std_logic;
        GPIO_LED_4_LS  : out std_logic;
        GPIO_LED_5_LS  : out std_logic;
        GPIO_LED_6_LS  : out std_logic;
        GPIO_LED_7_LS  : out std_logic;      
        
        --====================--
        -- Signals forwarding --
        --====================--
        USER_SMA_GPIO_P : out std_logic;    
        USER_SMA_GPIO_N : out std_logic;          
        FMC_HPC_LA00_CC_P : out std_logic;       
        FMC_HPC_LA01_CC_P : out std_logic;
        FMC_HPC_LA02_P  : out std_logic; 
        FMC_HPC_LA03_P  : out std_logic; 
        FMC_HPC_LA04_P  : out std_logic; 
        FMC_HPC_LA05_P  : out std_logic;
        
        -- Ethernet interface
        --sysclk_p       : in  std_logic;
        --sysclk_n       : in  std_logic;
        leds           : out std_logic_vector(3 downto 0);
        dip_sw         : in  std_logic_vector(3 downto 0);
        gmii_gtx_clk   : out std_logic;
        gmii_tx_en     : out std_logic;
        gmii_tx_er     : out std_logic;
        gmii_txd       : out std_logic_vector(7 downto 0);
        gmii_rx_clk    : in  std_logic;
        gmii_rx_dv     : in  std_logic;
        gmii_rx_er     : in  std_logic;
        gmii_rxd       : in  std_logic_vector(7 downto 0);
        phy_rst        : out std_logic
    );
end top_2;



architecture rtl of top_2 is

begin

    top_inst : entity work.top
    generic map (
        ENABLE_DHCP => ENABLE_DHCP,
        USE_IPAM => USE_IPAM,
        MAC_ADDRESS => MAC_ADDRESS
        )
        port map (
        sysclk_p => sysclk_p,
        sysclk_n => sysclk_n,
        leds => leds,
        dip_sw => dip_sw,
        gmii_gtx_clk => gmii_gtx_clk,
        gmii_tx_en => gmii_tx_en,
        gmii_tx_er => gmii_tx_er,
        gmii_txd => gmii_txd,
        gmii_rx_clk => gmii_rx_clk,
        gmii_rx_dv => gmii_rx_dv,
        gmii_rx_er => gmii_rx_er,
        gmii_rxd => gmii_rxd,
        phy_rst => phy_rst
        );

    kc705_gbt_example_design_inst : entity work.kc705_gbt_example_design
    port map (
        CPU_RESET => CPU_RESET,
        SYSCLK_P => SYSCLK_P,
        SYSCLK_N => SYSCLK_N,
        USER_CLOCK_P => USER_CLOCK_P,
        USER_CLOCK_N => USER_CLOCK_N,
        SMA_MGT_REFCLK_P => SMA_MGT_REFCLK_P,
        SMA_MGT_REFCLK_N => SMA_MGT_REFCLK_N,
        SFP_TX_P => SFP_TX_P,
        SFP_TX_N => SFP_TX_N,
        SFP_RX_P => SFP_RX_P,
        SFP_RX_N => SFP_RX_N,
        SFP_TX_DISABLE => SFP_TX_DISABLE,
        -- GPIO_LED_0_LS => GPIO_LED_0_LS,
        -- GPIO_LED_1_LS => GPIO_LED_1_LS,
        -- GPIO_LED_2_LS => GPIO_LED_2_LS,
        -- GPIO_LED_3_LS => GPIO_LED_3_LS,
        GPIO_LED_4_LS => GPIO_LED_4_LS,
        GPIO_LED_5_LS => GPIO_LED_5_LS,
        GPIO_LED_6_LS => GPIO_LED_6_LS,
        GPIO_LED_7_LS => GPIO_LED_7_LS,
        USER_SMA_GPIO_P => USER_SMA_GPIO_P,
        USER_SMA_GPIO_N => USER_SMA_GPIO_N,
        FMC_HPC_LA00_CC_P => FMC_HPC_LA00_CC_P,
        FMC_HPC_LA01_CC_P => FMC_HPC_LA01_CC_P,
        FMC_HPC_LA02_P => FMC_HPC_LA02_P,
        FMC_HPC_LA03_P => FMC_HPC_LA03_P,
        FMC_HPC_LA04_P => FMC_HPC_LA04_P,
        FMC_HPC_LA05_P => FMC_HPC_LA05_P
        );
      
 

end architecture;