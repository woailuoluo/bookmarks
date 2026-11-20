package pcie_subsys_pkg;
import uvm_pkg::*;
import svt_uvm_pkg::*;
import svt_pcie_uvm_pkg::*;

import svt_axi_uvm_pkg::*;
import svt_amba_common_uvm_pkg::*;


`include `SVC_SOURCE_MAP_SUITE_UTIL_V(pcie_svc,PCIE,latest,svc_util_parms)
`include `SVC_SOURCE_MAP_SUITE_MODEL_MODULE(pcie_svc,Include,latest,pciesvc_parms)

`include "pcie_subsys_define.sv"

`ifndef DESIGNWARE_INCDIR
`include "svt_pcie_defines.svi"
`endif


`include "ral_x1_DWC_pcie_ctl.sv"
`include "ral_x2_DWC_pcie_ctl.sv"
`include "ral_x4_DWC_pcie_ctl_dsp.sv"
`include "ral_x4_DWC_pcie_ctl_usp.sv"
//`include "ral_x4_DWC_pcie_ctl_usp_dma.sv"
`include "ral_x1_DWC_DSP_ATU.sv"
`include "ral_x2_DWC_DSP_ATU.sv"
`include "ral_x4_DWC_DSP_ATU.sv"
`include "ral_x4_DWC_USP_ATU.sv"
`include "ral_x4_DWC_DSP_HDMA.sv"
`include "ral_x4_DWC_USP_HDMA.sv"
`include "ral_pcie_cus_top.sv"
`include "ral_pcie_ss_reg_top.sv"
`include "ral_host_bridge_top.sv"
`include "pcie_regmodel_noc.sv"
`include "pcie_regmodel_hnp.sv"

//axi
`include "axi_virtual_sequencer.sv"
`include "cust_svt_axi_system_configuration.sv"


//`include "pcie_scb.sv"

`include "pcie_err_catcher.sv"
`include "pcie_subsys_env.sv"

//pcie seq
`include "pcie_device_random_traffic_sequence.sv"
`include "pcie_device_address_translation_sequence.sv"
`include "pcie_driver_transaction_directed_sequence.sv"
`include "pcie_driver_transaction_rand_sequence.sv"
`include "pcie_drv_512b_pld_seq.sv"
`include "pcie_drv_512b_pld_wr_seq.sv"
`include "pcie_drv_512b_pld_rd_seq.sv"
`include "int_msg_sequence.sv"

//axi seq
`include "axi_master_random_discrete_virtual_sequence.sv"
`include "axi_master_random_discrete_sequence.sv"
`include "axi_slave_mem_response_sequence.sv"
`include "axi_slave_mem_rsp_seq_ready_delay.sv"
`include "axi_slave_mem_rsp_seq_0delay.sv"
`include "axi_simple_reset_sequence.sv"
`include "axi_null_virtual_sequence.sv"
`include "axi_master_directed_sequence.sv"
`include "axi_master_rand_sequence.sv"
`include "axi_master_size_len_rand_seq.sv"
`include "axi_mst_multi_max_len_wr_single_rd_seq.sv"
`include "axi_mst_multi_max_len_wr_rd_seq.sv"
`include "axi_reg_rd_seq.sv"
`include "axi_reg_wr_seq.sv"

//base test
//`include "pcie_subsys_base_test.sv"

endpackage:pcie_subsys_pkg
