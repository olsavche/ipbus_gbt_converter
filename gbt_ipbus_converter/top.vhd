
entity top is
    port (

    );
end entity;



architecture rtl of top is

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
        GPIO_LED_0_LS => GPIO_LED_0_LS,
        GPIO_LED_1_LS => GPIO_LED_1_LS,
        GPIO_LED_2_LS => GPIO_LED_2_LS,
        GPIO_LED_3_LS => GPIO_LED_3_LS,
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