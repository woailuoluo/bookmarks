
`timescale  1 ns/ 1fs

/** Enable Gen5 */
`define SVT_PCIE_ENABLE_GEN5

/** Defines required for PCIE SVC */
`define EXPERTIO_PCIESVC_GLOBAL_SHADOW_PATH test_top.global_shadow0
`define SVC_RANDOM_SEED_SCOPE               test_top.global_random_seed
`define DUT_PATH                            test_top.dut
//`define PHY_PATH                            test_top.dut.u_phy
`define PHY0_PATH                           test_top.dut.u_pcie_subsystem.u_pcie_wrap0.shared_phy__u_phy.phy0
`define PHY1_PATH                           test_top.dut.u_pcie_subsystem.u_pcie_wrap0.shared_phy__u_phy.phy1
`define PHY2_PATH                           test_top.dut.u_pcie_subsystem.u_pcie_wrap1.direct_phy__u_phy.phy0

`define PCIE_CORE                           test_top.dut.x16_DWC_pcie_ctl.u_DWC_pcie_core 

/** Include the PCIE SVT UvM package */
module test_top;

  timeunit 1ns;
  timeprecision 1fs;
  parameter simulation_cycle  =50;
  parameter pcie_mem_bus_clk_cycle =1.0;//1Ghz
  parameter pcie_cfg_bus_clk_cycle =4.807;//208mhz
  parameter phy_ref_clk_cycle =10.0;//100mzh
  parameter phy_ref_clk_alt_cycle =10.0;//100mzh
  parameter clk_1G_cycle     =1.0;//1Ghz
  parameter aux_clk_cycle     =20.833;//48mzh

  bit  systemclock;
  bit  pcie_mem_bus_clk;
  bit  pcie_cfg_bus_clk;
  bit  phy_ref_clk_bit;
  wire phy_ref_clk_wire[3];
  bit  phy_ref_clk_alt;
  bit  aux_clk;
  bit  pcie_cfg_bus_reset_n;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import svt_uvm_pkg::*;
  import svt_pcie_uvm_pkg::*;
  import pcie_subsys_pkg::*;

  //`include "import_pcie_svt_uvm_pkgs.svi"

  /** Include Util parms*/
  //`include `SVC_SOURCE_MAP_SUITE_UTIL_V(pcie_svc,PCIE,latest,svc_util_parms)
  //`include `SVC_SOURCE_MAP_SUITE_MODEL_MODULE(pcie_svc,Include,latest,pciesvc_parms)

  svt_axi_if axi_if();

  //assign axi_if.common_aclk = pcie_mem_bus_clk ;//1Ghz 
  assign axi_if.master_if[0].aresetn = pcie_cfg_bus_reset_n;
  assign axi_if.master_if[0].aclk = pcie_cfg_bus_clk;//program register
  assign axi_if.master_if[1].aresetn = pcie_cfg_bus_reset_n;
  assign axi_if.master_if[1].aclk = pcie_mem_bus_clk;//transaction
  assign axi_if.master_if[2].aresetn = pcie_cfg_bus_reset_n;
  assign axi_if.master_if[2].aclk = pcie_mem_bus_clk;//cfg its
  assign axi_if.slave_if[0].aresetn  = pcie_cfg_bus_reset_n;//acelite slv0, for x1,x2,x4_0 its. normal trans and msi-x table
  assign axi_if.slave_if[0].aclk = pcie_mem_bus_clk;
  assign axi_if.slave_if[1].aresetn  = pcie_cfg_bus_reset_n;//acelite slv1, for x4_1 its. normal trans and msi-x table
  assign axi_if.slave_if[1].aclk = pcie_mem_bus_clk;
  assign axi_if.slave_if[2].aresetn  = pcie_cfg_bus_reset_n;//axi stream slv, for x1,x2,x4_0/x4_1 msi/msix
  assign axi_if.slave_if[2].aclk = pcie_mem_bus_clk;
  assign axi_if.slave_if[3].aresetn  = pcie_cfg_bus_reset_n;//acelite slv-qtw, for x4_0/x4_1 table walk
  assign axi_if.slave_if[3].aclk = pcie_mem_bus_clk;


  tri1 [31:0] clkreq_n;
  tri1 [31:0] wake_n;

  bit[1:0] link_mode;
  bit[3:0] device_type_x4_0;
  bit[3:0] device_type_x4_1;

  `include "dut_inst.sv"
  
  bit reset;


  `include "pcie_ser_con_macro.sv"
  `include "pcie_ser_con.sv"


  /** Global random seed */
  int unsigned global_random_seed;

  //---------------------------------------------------------//
  /**Instantiate Global Memory Shadow*/
 //-----------------------------------------------------------//
  pciesvc_global_shadow#(.DISPLAY_NAME( "global_shadow0.")) global_shadow0();

  //include all tests
 `include "pcie_subsys_tests.f"

  //------------------------------------------------------
  /**Set up the Global random seed*/
  //-------------------------------------------------
  `ifndef SVC_RANDOM_BY_THREAD
    initial begin:L_Randseed
        `ifdef SVC_RANDOM_SEED
              global_random_seed= `SVC_RANDOM_SEED ;
        `else
              global_random_seed =0;
        `endif
            `uvm_info("test_top",$psprintf("Global random seed being set to %0d", global_random_seed), UVM_LOW)
    end
  `endif

  //---------------------------------------------------------------
  /**optionally dump the sim variable for waveform display */
  //---------------------------

  
  `ifdef COMPILE_WAVE
    initial begin
      if($test$plusargs("DUMP_WAVE"))begin
           $display("start to dump fsdb file,@%t",$time);
           $fsdbDumpfile("test_top");
           $fsdbDumpvars;
           $fsdbDumpMDA();
      end
      else begin
          $display("NO WAVE IS DUMP!!");
      end
    end
  `endif

  //-----------------------------
  /**
  *Setup the reset.
  */
  //-------------------------------------------
  initial begin
      $timeformat(-9,5," ns",12);
      test_top.reset = 1;
      #200;
      test_top.reset = 0;
  end

  initial begin
      $timeformat(-9,5," ns",12);
      //pcie_cfg_bus_reset_n=1;
      //#200;
      pcie_cfg_bus_reset_n=0;
      #200;
      pcie_cfg_bus_reset_n=1;
  end

  initial begin
      systemclock = 0;
      forever begin
          #(simulation_cycle/2) systemclock = ~systemclock;
      end
  end

  //pcie_mem_bus_clk:1Ghz
  initial begin
      pcie_mem_bus_clk =0;
      forever begin
          #(pcie_mem_bus_clk_cycle/2) pcie_mem_bus_clk = ~pcie_mem_bus_clk;
      end
  end

  //pcie_cfg_bus_clk:208Mhz
  initial begin
      pcie_cfg_bus_clk =0;
      forever begin
          #(pcie_cfg_bus_clk_cycle/2) pcie_cfg_bus_clk = ~pcie_cfg_bus_clk;
      end
  end

  assign phy_ref_clk_wire[0] = phy_ref_clk_bit;
  assign phy_ref_clk_wire[1] = phy_ref_clk_bit;
  assign phy_ref_clk_wire[2] = phy_ref_clk_bit;
  //phy_ref_clk:100mhz
  initial begin
      phy_ref_clk_bit =0;
      forever begin
          #(phy_ref_clk_cycle/2) phy_ref_clk_bit = ~phy_ref_clk_bit;
      end
  end

  //phy_ref_clk_alt:100mhz
  initial begin
      phy_ref_clk_alt =0;
      forever begin
          #(phy_ref_clk_alt_cycle/2) phy_ref_clk_alt = ~phy_ref_clk_alt;
      end
  end


  //aux_clk:48mhz
  initial begin
      aux_clk=0;
      forever begin
          #(aux_clk_cycle/2) aux_clk = ~aux_clk;//48m
      end
  end


  //----------------------------------------------------------
  /**UM test phase initiator*/
  //----------------------------------------------------------
  initial begin
      uvm_config_db#(virtual svt_axi_if)::set(uvm_root::get(), "uvm_test_top.env.axi_system_env", "vif", axi_if);

      /** start the M tests */
      repeat (100) #0; // Invoke run test after set config db calls in other/peer initial blocks have been executed
      run_test();
  end

  initial begin
      $assertoff(0,test_top.dut);
  end

endmodule :test_top
