tri0 common_pwr_on_reset = reset ? 1'b1 : 1'bz;

/* Multi bit clkreq_n pull ups. One bit for each link */
//tri1 [31:0] clkreq_n; 

/* Bit wake_n pull ups. */
//tri1 wake_n; 


`define SIM_PCIE_INTF_DEF(port_num,is_root,link_width) \
  parameter SVT_PCIE_UI_PCIE_SPEC_VER_P``port_num`` = `SVT_PCIE_UI_PCIE_SPEC_VER_5_0; \
  parameter SVT_PCIE_UI_PIPE_SPEC_VER_P``port_num`` = `SVT_PCIE_UI_PIPE_SPEC_VER_4_4; \
  parameter SVT_PCIE_UI_NUM_PHYSICAL_LANES_P``port_num`` = link_width; \
  parameter SVT_PCIE_UI_NUM_PMA_INTERFACE_BITS_P``port_num`` = 10; \
`ifdef SVT_PCIE_PIPE_DATA_WIDTH \
  parameter SVT_PCIE_UI_NUM_PIPE_INTERFACE_BITS_P``port_num`` = `SVT_PCIE_PIPE_DATA_WIDTH; \
`else \
  parameter SVT_PCIE_UI_NUM_PIPE_INTERFACE_BITS_P``port_num`` = 32; \
`endif \
  parameter SVT_PCIE_UI_HIERARCHY_NUMBER_P``port_num`` = 0; \
  parameter SVT_PCIE_UI_MPIPE_P``port_num`` = 1;  \
  parameter SVT_PCIE_UI_PHY_INTERFACE_TYPE_P``port_num`` = `SVT_PCIE_UI_PHY_INTERFACE_TYPE_SERDES; \
  parameter SVT_PCIE_UI_MON_PHY_INTERFACE_TYPE_P``port_num`` = `SVT_PCIE_UI_PHY_INTERFACE_TYPE_SERDES; \
  parameter SVT_PCIE_UI_DEVICE_IS_ROOT_P``port_num`` = is_root;    /*behave as a root complex  */ \
  parameter SVT_PCIE_UI_ENABLE_SHADOW_MEMORY_CHECKING_P``port_num`` = 0;  /*If set, applications will check memory reads againsshadow memory*/ \
  parameter SVT_PCIE_UI_ENABLE_CFG_BLOCK_P``port_num`` = 1; \
  parameter SVT_PCIE_UI_DUT_IN_V2V_CTL_TB_P``port_num`` = 0;  /*Ignore this parameter, will be deprecated in future */ \
  parameter SVT_PCIE_UI_CONNECT_ACTIVE_VIP_P``port_num`` = 1; \
  parameter SVT_PCIE_UI_PIPE_CLK_FROM_MAC_P``port_num`` = 1'b0; \
  parameter SVT_PCIE_UI_TRANSMIT_BIT_CLOCK_MODE_P``port_num`` = 1'b1; \
  parameter SVT_PCIE_UI_ENABLE_IO_SKEW_P``port_num`` = 1'b0; \
  parameter realtime SVT_PCIE_UI_SETUP_PS_P``port_num`` = 10ps; \
  parameter realtime SVT_PCIE_UI_HOLD_PS_P``port_num`` = 5ps; \
  svt_pcie_if port_if_``port_num``(clkreq_n[port_num], wake_n[port_num]); \
  svt_pcie_single_port_device_agent_hdl spd_``port_num``(port_if_``port_num``); \
  localparam string port_num_string_``port_num`` = `"port_num`"; \
  defparam spd_``port_num``.SVT_PCIE_UI_DISPLAY_NAME = {"spd_",port_num_string_``port_num``,"."}; \
  defparam spd_``port_num``.SVT_PCIE_UI_ENABLE_CFG_BLOCK = SVT_PCIE_UI_ENABLE_CFG_BLOCK_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_PCIE_SPEC_VER = SVT_PCIE_UI_PCIE_SPEC_VER_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_PIPE_SPEC_VER = SVT_PCIE_UI_PIPE_SPEC_VER_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_NUM_PHYSICAL_LANES = SVT_PCIE_UI_NUM_PHYSICAL_LANES_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_NUM_PMA_INTERFACE_BITS = SVT_PCIE_UI_NUM_PMA_INTERFACE_BITS_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_NUM_PIPE_INTERFACE_BITS = SVT_PCIE_UI_NUM_PIPE_INTERFACE_BITS_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_HIERARCHY_NUMBER = SVT_PCIE_UI_HIERARCHY_NUMBER_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_MPIPE = SVT_PCIE_UI_MPIPE_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_PHY_INTERFACE_TYPE = SVT_PCIE_UI_PHY_INTERFACE_TYPE_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_DEVICE_IS_ROOT = SVT_PCIE_UI_DEVICE_IS_ROOT_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_ENABLE_SHADOW_MEMORY_CHECKING = SVT_PCIE_UI_ENABLE_SHADOW_MEMORY_CHECKING_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_DUT_IN_V2V_CTL_TB = SVT_PCIE_UI_DUT_IN_V2V_CTL_TB_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_CONNECT_ACTIVE_VIP = SVT_PCIE_UI_CONNECT_ACTIVE_VIP_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_PIPE_CLK_FROM_MAC = SVT_PCIE_UI_PIPE_CLK_FROM_MAC_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_TRANSMIT_BIT_CLOCK_MODE = SVT_PCIE_UI_TRANSMIT_BIT_CLOCK_MODE_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_ENABLE_IO_SKEW = SVT_PCIE_UI_ENABLE_IO_SKEW_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_SETUP_PS = SVT_PCIE_UI_SETUP_PS_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_HOLD_PS = SVT_PCIE_UI_HOLD_PS_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_MON_PHY_INTERFACE_TYPE = SVT_PCIE_UI_MON_PHY_INTERFACE_TYPE_P``port_num``; \
  assign   spd_``port_num``.vip_port_if.ser_if.reset = common_pwr_on_reset; \
  initial begin \
      spd_``port_num``.update_if_variables(port_num, 0, "uvm_test_top", "uvm_test_top"); \
  end

`define SIM_4LANE_CONNECTION(spd,s_pos) \
    spd.vip_port_if.ser_if.rx_datap_0  = txp[0 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datap_1  = txp[1 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datap_2  = txp[2 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datap_3  = txp[3 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datan_0  = txn[0 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datan_1  = txn[1 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datan_2  = txn[2 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datan_3  = txn[3 + s_pos] ;\
    rxp[0 + s_pos]  = spd.vip_port_if.ser_if.tx_datap_0 ;\
    rxp[1 + s_pos]  = spd.vip_port_if.ser_if.tx_datap_1 ;\
    rxp[2 + s_pos]  = spd.vip_port_if.ser_if.tx_datap_2 ;\
    rxp[3 + s_pos]  = spd.vip_port_if.ser_if.tx_datap_3 ;\
    rxn[0 + s_pos]  = spd.vip_port_if.ser_if.tx_datan_0 ;\
    rxn[1 + s_pos]  = spd.vip_port_if.ser_if.tx_datan_1 ;\
    rxn[2 + s_pos]  = spd.vip_port_if.ser_if.tx_datan_2 ;\
    rxn[3 + s_pos]  = spd.vip_port_if.ser_if.tx_datan_3 ;

`define SIM_2LANE_CONNECTION(spd,s_pos) \
    spd.vip_port_if.ser_if.rx_datap_0  = txp[0 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datap_1  = txp[1 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datan_0  = txn[0 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datan_1  = txn[1 + s_pos] ;\
    rxp[0 + s_pos]  = spd.vip_port_if.ser_if.tx_datap_0 ;\
    rxp[1 + s_pos]  = spd.vip_port_if.ser_if.tx_datap_1 ;\
    rxn[0 + s_pos]  = spd.vip_port_if.ser_if.tx_datan_0 ;\
    rxn[1 + s_pos]  = spd.vip_port_if.ser_if.tx_datan_1 ;

`define SIM_1LANE_CONNECTION(spd,s_pos) \
    spd.vip_port_if.ser_if.rx_datap_0  = txp[0 + s_pos] ;\
    spd.vip_port_if.ser_if.rx_datan_0  = txn[0 + s_pos] ;\
    rxp[0 + s_pos]  = spd.vip_port_if.ser_if.tx_datap_0 ;\
    rxn[0 + s_pos]  = spd.vip_port_if.ser_if.tx_datan_0 ;\
