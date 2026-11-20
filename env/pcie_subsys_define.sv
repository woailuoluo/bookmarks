`define SVT_PCIE_MAX_NUM_LINKS 1
`define PCIESUB_APB_NUM        1

typedef enum{
GEN1_MY,
GEN2_MY,
GEN3_MY,
GEN4_MY,
GEN5_MY
} MY_PCIE_SPEED_e;

typedef enum bit [1:0] {
    LINK_MODE_A=2'b00,   
    LINK_MODE_B=2'b01,   
    LINK_MODE_C=2'b10   
} LINK_MODE_e;

`define PHY0_ADDR          32'h0_0000
`define PHY1_ADDR          32'h4_0000
`define PHY2_ADDR          32'h8_0000


`define SUP_DIG_IDCODE_LO_offset             32'h0
`define SUP_DIG_IDCODE_HI_offset             (32'h1<<2)
`define SUP_DIG_REFCLKA_OVRD_IN_0_offset     (32'h2<<2)
`define SUP_DIG_REFCLKB_OVRD_IN_0_offset     (32'h3<<2)
`define SUP_DIG_REFCLK_OVRD_IN_1_offset      (32'h4<<2)
`define SUP_DIG_SUP_OVRD_MISC_offset         (32'h42<<2)
`define RAWCMN_DIG_LANE_FSM_OP_XTND          (32'h101<<2)

`define RAWMEM_DIG_ROM_CMN0_B0_R0_offset     32'h8000<<2)
`define RAWMEM_DIG_ROM_CMN31_B15_R31_offset  32'hbfff<<2)
`define RAWMEM_DIG_RAM_CMN0_B0_R0_offset     32'hc000<<2)
`define RAWMEM_DIG_RAM_CMN31_B15_R31_offset  32'hffff<<2)

`define RAWLANEAONN_DIG_RX_COARSE_ADPT_SKIP_BITS_lane0_offset (32'h314f<<2)
`define RAWLANEAONN_DIG_RX_COARSE_ADPT_SKIP_BITS_lane1_offset (32'h334f<<2)
`define RAWLANEAONN_DIG_RX_COARSE_ADPT_SKIP_BITS_lane2_offset (32'h354f<<2)
`define RAWLANEAONN_DIG_RX_COARSE_ADPT_SKIP_BITS_lane3_offset (32'h374f<<2)

//16k space
`define SRAM_BASE    32'hc000
`define SRAM_END     32'hffff
`define SRAM_BASE_H  (32'hc000 +32'h4000)
`define SRAM_END_H   (32'hffff +32'h4000)
