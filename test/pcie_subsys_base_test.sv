`ifndef GUARD_PCIE_SUBSYS_BASE_TEST_SV
    `define GUARD_PCIE_SUBSYS_BASE_TEST_SV

//import "DPI-C" function string getenv(input string env_name);
class pcie_subsys_base_test extends uvm_test;
    bit enable_phy_sram_init = 1'b0;
    reg[15:0] memory[0:32767];

    bit enable_np_serial = 1'b0;

    `uvm_component_utils(pcie_subsys_base_test )

    svt_pcie_device_configuration rc_cfg[2];
    svt_pcie_device_configuration ep_cfg[4];

    pcie_subsys_env env;

    svt_pcie_vif vif_x[`PCIE_SS_MAX_NUM_PORTS];
    svt_pcie_vif vif_1;
    svt_pcie_vif rc_port;
    svt_pcie_vif ep_port;


    //for axi
    cust_svt_axi_system_configuration cfg;
    bit  use_tlm_generic_payload = 0;

    `SVT_XVM(root) root =`SVT_XVM(root)::get();

    bit bypass_eq[4]            = {1'b1,1'b1,1'b1,1'b1};
    MY_PCIE_SPEED_e my_speed[4] = {GEN2_MY,GEN2_MY,GEN2_MY,GEN2_MY};

    bit phy_ref_used_pad     = 1'b0;

    bit enable_msi[4] = {1'b0,1'b0,1'b0,1'b0};
    bit dpc_int_en[4] = {1'b0,1'b0,1'b0,1'b0};

    bit link_bw_mgt_int_en[4]  = {1'b0,1'b0,1'b0,1'b0};
    bit link_auto_bw_int_en[4] = {1'b0,1'b0,1'b0,1'b0};

    bit enable_aspm_l0s[4]     = {1'b0,1'b0,1'b0,1'b0};

    //for tests which reduce link width. 1:x1,3:x2,7:x4,f:x8,1f:x16,3f:x32(not supported.)
    //bit[5:0]    link_width[4]  =  {6'h7,6'h7,6'h3,6'h1};
    bit[5:0]    link_width[4]  =  {6'h1,6'h3,6'h7,6'h7};
    bit[3:0]    device_type[4] =  {4'h4,4'h4,4'h4,4'h4};//4:rc(dut),0,1:ep(dut).  indx 0:x1,1:x2,2:x4_0,3:x4_1. for x1,x2 must be 4(DUT->RC)

    //for ecam access
    bit         cfg_enable=1'b1;
    bit[19:0]   cfg_ecam_base_hi20 = 20'h0;
    bit         cfg_rp_valid[4];
    bit[4:0]    cfg_rp_device[4];
    bit[7:0]    cfg_rp_primary[4];
    bit[7:0]    cfg_rp_secondary[4];
    bit[7:0]    cfg_rp_subordinate[4];
    bit[19:0]   cfg_rp_route_hi20[4];

    //for dbi access
    bit         cfg_raw_dbi_enable;
    bit[23:0]   cfg_raw_dbi_base_hi24;

    LINK_MODE_e     link_mode = LINK_MODE_A;//for x1,x2,x4_0,set by user

    semaphore  share_rst_sem;

    bit[47:0]  hnp_addr_base[4];
    bit[47:0]  hnp_addr_range[4];

    bit[47:0]  non_ecam_dbi_addr[4];//gen mem,io,cfg trans,hnp axi->pcie vip

    bit[47:0]  mem_addr_base;
    bit[47:0]  mem_addr_limit;

    bit[47:0]  io_addr_base;
    bit[47:0]  io_addr_limit;

    bit[47:0]  cfg0_addr_base;
    bit[47:0]  cfg0_addr_limit;

    bit[47:0]  cfg1_addr_base;
    bit[47:0]  cfg1_addr_limit;

    //for share phy     
    uvm_reg PHY_SHARED_PIPE_LANE_CTRL_00;
    uvm_reg PHY_SHARED_PIPE_LANE_CTRL_01;
    uvm_reg PHY_SHARED_PIPE_LANE_CTRL_02;
    uvm_reg SUBSYS_CLKREQ_WAKE_CTRL_SHARED;
    uvm_reg SUBSYS_CLKREQ_WAKE_CTRL_DIRECT;

    //common reg for rc and ep.
    uvm_reg LINK_STATUS[4];
    uvm_reg CFGINFO_LEVEL[4];
    uvm_reg APP_DBI_CTRL[4];
    uvm_reg ERR_INT_STATUS[4];
    uvm_reg ERR_INT_MASK[4];
    uvm_reg RADM_INTX_STATUS[4];
    uvm_reg RADM_INTX_MASK[4];
    uvm_reg APP_PM_CTRL[4];
    uvm_reg PM_STATUS[4];
    uvm_reg CORE_INT_MASK[4];
    uvm_reg PORT_LINK_CTRL_OFF[4];
    uvm_reg TIMER_CTRL_MAX_FUNC_NUM_OFF[4];
    uvm_reg LINK_CONTROL2_LINK_STATUS2_REG[4];
    uvm_reg GEN3_RELATED_OFF[4];
    uvm_reg GEN3_EQ_CONTROL_OFF[4];
    uvm_reg LINK_CONTROL3_REG[4];
    uvm_reg LINK_CONTROL_LINK_STATUS_REG[4];
    uvm_reg PORT_FORCE_OFF[4];
    uvm_reg PCI_MSI_CAP_ID_NEXT_CTRL_REG[4];
    uvm_reg DPC_CAP_CONTROL_OFF[4];
    uvm_reg LINK_CAPABILITIES_REG[4];
    uvm_reg BRIDGE_CTRL_INT_PIN_INT_LINE_REG[4];
    uvm_reg STATUS_COMMAND_REG[4];
    uvm_reg DEVICE_CAPABILITIES_REG[4];
    uvm_reg DEVICE_CONTROL_DEVICE_STATUS[4];
    uvm_reg MEM_LIMIT_MEM_BASE_REG[4];
    uvm_reg PREF_MEM_LIMIT_PREF_MEM_BASE_REG[4];
    uvm_reg PREF_BASE_UPPER_REG[4];
    uvm_reg PREF_LIMIT_UPPER_REG[4];
    uvm_reg SEC_STAT_IO_LIMIT_IO_BASE_REG[4];
    uvm_reg BAR0_REG[4];
    uvm_reg BAR1_REG[4];
    uvm_reg BAR2_REG[4];
    uvm_reg BAR3_REG[4];
    uvm_reg BAR4_REG[4];
    uvm_reg BAR5_REG[4];
    uvm_reg CON_STATUS_REG[4];
    uvm_reg SLOT_CONTROL_SLOT_STATUS[4];
    uvm_reg PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG[4];
    uvm_reg PL32G_CAPABILITY_REG[4];
    uvm_reg PL32G_CONTROL_REG[4];
    uvm_reg MISC_CONTROL_1_OFF[4];
    uvm_reg RASDP_ERROR_MODE_EN_OFF[4];
    uvm_reg RASDP_ERROR_MODE_CLEAR_OFF[4];
    uvm_reg ACK_F_ASPM_CTRL_OFF[4];
    uvm_reg L1SUB_CAPABILITY_REG[4];
    uvm_reg L1SUB_CONTROL1_REG[4];
    uvm_reg PHY_INTEROP_CTRL_OFF[4];
    uvm_reg IDE_CTRL_OFF[4];

    uvm_reg IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[4];
    uvm_reg IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0[4];
    uvm_reg IATU_LIMIT_ADDR_OFF_OUTBOUND_0[4];
    uvm_reg IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0[4];
    uvm_reg IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0[4];
    uvm_reg IATU_REGION_CTRL_1_OFF_OUTBOUND_0[4];
    uvm_reg IATU_REGION_CTRL_2_OFF_OUTBOUND_0[4];

    uvm_reg IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1[4];
    uvm_reg IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1[4];
    uvm_reg IATU_LIMIT_ADDR_OFF_OUTBOUND_1[4];
    uvm_reg IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1[4];
    uvm_reg IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1[4];
    uvm_reg IATU_REGION_CTRL_1_OFF_OUTBOUND_1[4];
    uvm_reg IATU_REGION_CTRL_2_OFF_OUTBOUND_1[4];

    uvm_reg IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2[4];
    uvm_reg IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2[4];
    uvm_reg IATU_LIMIT_ADDR_OFF_OUTBOUND_2[4];
    uvm_reg IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2[4];
    uvm_reg IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2[4];
    uvm_reg IATU_REGION_CTRL_1_OFF_OUTBOUND_2[4];
    uvm_reg IATU_REGION_CTRL_2_OFF_OUTBOUND_2[4];

    uvm_reg IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3[4];
    uvm_reg IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3[4];
    uvm_reg IATU_LIMIT_ADDR_OFF_OUTBOUND_3[4];
    uvm_reg IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3[4];
    uvm_reg IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3[4];
    uvm_reg IATU_REGION_CTRL_1_OFF_OUTBOUND_3[4];
    uvm_reg IATU_REGION_CTRL_2_OFF_OUTBOUND_3[4];

    extern function new(string name="pcie_subsys_base_test", uvm_component parent=null);
    extern virtual function void set_ecam_para();
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern function void end_of_elaboration_phase(uvm_phase phase);
    extern function void final_phase(uvm_phase phase);
    extern virtual task link_training(int link_idx);//0:x1,1:x2,2:x4_0,3:x4_1
    extern virtual task set_mem_io_base_limit(int link_idx);
    extern virtual task set_atu_for_mem_req(int link_idx);
    extern virtual task set_atu_for_io_req(int link_idx);
    extern virtual task set_atu_for_cfg0_req(int link_idx);
    extern virtual task set_atu_for_cfg1_req(int link_idx);
    extern virtual task gen_inbound_outboud_trans(int link_idx);
    extern virtual task write_reg(input bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, input bit[31:0] wdata,int aximst_id=0);//0:cust register,1: controler register, other:illegal
    extern virtual task read_reg(input bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, output bit[31:0] rdata,int aximst_id=0);
    extern virtual task write_phy(input bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, input bit[31:0] wdata,int aximst_id=0);//TODO
    extern virtual task read_phy(input bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, output bit[31:0] rdata,int aximst_id=0);//TODO
    //extern task phy_sram_init();
    //extern task enable_sram_ld_fl();
    //extern function void get_phy_para_from_file();
    //extern task enable_16k_sram_h(bit[31:0] base_addr);
    //extern task disable_16k_sram_h(bit[31:0] base_addr);
    extern virtual task doSpeedChange(bit[3:0] target_link_speed,int link_idx);
    extern virtual task write_cfg_reg(input bit[9:0] reg_num, input bit[31:0] wdata,input int link_idx);//link_idx must 2,3,2:x4_0,3:x4_1
    extern virtual task read_cfg_reg(input bit[9:0] reg_num, output bit[31:0] rdata,input int link_idx);//link_idx must 2,3,2:x4_0,3:x4_1
    extern virtual function bit is_rc(bit[3:0] dev_type);
    extern virtual task exec_training_and_trans(int link_idx);
endclass//pcie_subsys_base_test
function pcie_subsys_base_test::new(string name="pcie_subsys_base_test", uvm_component parent=null);
    super.new(name,parent);
    hnp_addr_base[3]  = 48'h38_0000_0000;
    hnp_addr_range[3] = 48'h8_0000_0000;

    hnp_addr_base[2]  = 48'h30_0000_0000;
    hnp_addr_range[2] = 48'h8_0000_0000;

    hnp_addr_base[1]  = 48'h28_0000_0000;
    hnp_addr_range[1] = 48'h8_0000_0000;

    hnp_addr_base[0]  = 48'h20_0000_0000;
    hnp_addr_range[0] = 48'h8_0000_0000;

    mem_addr_base    = 48'h0;
    mem_addr_limit   = 48'hffff;

    io_addr_base    = 48'h1_0000;
    io_addr_limit   = 48'h1_ffff;

    cfg0_addr_base  = 48'h2_0000;
    cfg0_addr_limit = 48'h2_ffff;

    cfg1_addr_base  = 48'h3_0000;
    cfg1_addr_limit = 48'h3_ffff;



endfunction :new

function void pcie_subsys_base_test::set_ecam_para();
    cfg_enable=1'b1;
    cfg_raw_dbi_enable = 1'b1;
    //std::randomize(cfg_ecam_base_hi20) with {cfg_ecam_base_hi20>=(hnp_addr_base>>28);cfg_ecam_base_hi20<=((hnp_addr_base+hnp_addr_range)>>28);};
    std::randomize(cfg_ecam_base_hi20,cfg_raw_dbi_base_hi24) with {cfg_ecam_base_hi20 != cfg_raw_dbi_base_hi24[23:4];};
    for (int i=0;i<4;i++) begin
	cfg_rp_valid[i] = 1'b1;
	std::randomize(cfg_rp_device[i]);
	std::randomize(cfg_rp_route_hi20[i]) with {cfg_rp_route_hi20[i]>=(hnp_addr_base[i]>>28);cfg_rp_route_hi20[i]<((hnp_addr_base[i]+hnp_addr_range[i])>>28);};
	std::randomize(cfg_rp_primary[i],cfg_rp_secondary[i],cfg_rp_subordinate[i]) with {
            cfg_rp_primary[i]<cfg_rp_secondary[i];
            cfg_rp_secondary[i]<=cfg_rp_subordinate[i];
	    cfg_rp_subordinate[i]<64*(i+1);
	    cfg_rp_primary[i] >= 64*i;
        };
	std::randomize(non_ecam_dbi_addr[i])with {non_ecam_dbi_addr[i]>=hnp_addr_base[i];non_ecam_dbi_addr[i]<=(hnp_addr_base[i]+hnp_addr_range[i]);non_ecam_dbi_addr[i][47:28]!=cfg_ecam_base_hi20;non_ecam_dbi_addr[i][47:24]!=cfg_raw_dbi_base_hi24;};
    end
    $display("show ecam cfg info:@%t",$time);
    $display("cfg_ecam_base_hi20:%0h",cfg_ecam_base_hi20);
    $display("cfg_raw_dbi_base_hi24:%0h",cfg_raw_dbi_base_hi24);
    for (int i=0;i<4;i++) begin
        $display("cfg_rp_device[%0d]:%0h",i,cfg_rp_device[i]);
        $display("cfg_rp_route_hi20[%0d]:%0h",i,cfg_rp_route_hi20[i]);
        $display("cfg_rp_primary[%0d]:%0h",i,cfg_rp_primary[i]);
        $display("cfg_rp_secondary[%0d]:%0h",i,cfg_rp_secondary[i]);
        $display("cfg_rp_subordinate[%0d]:%0h",i,cfg_rp_subordinate[i]);
        $display("non_ecam_dbi_addr[%0d]:%0h",i,non_ecam_dbi_addr[i]);
    end
endfunction:set_ecam_para

function void pcie_subsys_base_test::build_phase(uvm_phase phase);
    int num_valid_links =0;
    string cfg_name,link_port_x,link_port_b,env_name;
    int  rc_cfg_indx,ep_cfg_indx,link_idx;

    `uvm_info("build_phase", "Entered...",UVM_LOW) 

    for (int i=0;i<4;i++) begin
        $display("show link_width[%0d]:%0h in base test build phase @%t",i,link_width[i],$time);
    end
    set_ecam_para();

    //modify link_width according to link_mode
    if (LINK_MODE_A == link_mode) begin
	link_width[1] = 6'h1;//set to x1 for x2 controler
	link_width[2] = 6'h3;//set to x2 for x4_0 controler
    end

    if (LINK_MODE_B == link_mode) begin
	link_width[2] = 6'h3;//set to x2 for x4_0 controler
    end



    super.build_phase(phase);

    share_rst_sem = new(1);

    /** Set Default timeout */
    if(1'b1 == enable_phy_sram_init) begin
        root.set_timeout(60ms);
    end
    else begin
        root.set_timeout(3ms);
    end

    env_name = "env";
    env = pcie_subsys_env::type_id::create(env_name, this);

    for (int i=0; i<`PCIE_SS_MAX_NUM_PORTS; i++)begin
        link_port_x = $sformatf("link_0_vif_%0d",i);

        void'(uvm_config_db#(svt_pcie_vif)::get(this,"",link_port_x,vif_x[i]));
        if(vif_x[i] == null) begin
            `uvm_fatal("build_phase", $sformatf("vif_x[%0d] virtual interface handle(s) is/are null. Hence skipping the remaining build_phase",i));
        end
        else begin
            `uvm_info("build_phase",$sformatf("receive vif_x[%0d] from tb",i),UVM_LOW)
        end

        if (~vif_x[i].connect_active_vip) begin
             `uvm_fatal("buitd phase", $sformatf("vif_x[%0d] virtual interface handle(s) are marked ports without active components.Hence skipping the remaining build_phase",i));
        end

	link_idx = (i inside {4,5}) ? 3 : (i inside {2,3}) ? 2 : i;
	if (i inside {3,5}) begin//vip rc
            rc_cfg_indx = (i-3)/2;
	    if (vif_x[i].device_is_root != 1) begin
	        `uvm_fatal("build_phase",$sformatf("vif_x[%0d] is is not RC",i))
	    end
	    rc_cfg[rc_cfg_indx] = svt_pcie_device_configuration::type_id::create($sformatf("rc_cfg[%0d]",rc_cfg_indx),this);
            rc_cfg[rc_cfg_indx].set_initial_values_via_unified_vif(1,vif_x[i]); // Root VIP Active agent initial configuration

	    rc_cfg[rc_cfg_indx].pcie_cfg.pl_cfg.enable_equalization_verification_mode   = 1;
            rc_cfg[rc_cfg_indx].pcie_cfg.pl_cfg.enable_equalization_coefficients_checks = 1;
            rc_cfg[rc_cfg_indx].pcie_cfg.tl_cfg.remote_max_payload_size                 = 4096;

	    uvm_config_db#(svt_pcie_device_configuration)::set(this, {env_name,"*"}, $sformatf("root_cfg[%0d]",rc_cfg_indx),rc_cfg[rc_cfg_indx]);

	    `ifdef SVT_PCIE_SLED_RECORD_ENABLE
            rc_cfg[rc_cfg_indx].pcie cfg.enable_sled = 1;
            `endif
	end//vip rc
	else begin//vip ep
            ep_cfg_indx = (4==i) ? 3: i;
	    if (vif_x[i].device_is_root != 0) begin
	        `uvm_fatal("build_phase",$sformatf("vif_x[%0d] is is not EP",i))
	    end
	    ep_cfg[ep_cfg_indx] = svt_pcie_device_configuration::type_id::create($sformatf("ep_cfg[%0d]",ep_cfg_indx),this);
            ep_cfg[ep_cfg_indx].set_initial_values_via_unified_vif(1,vif_x[i]); // Endpoint VIP Active agent initial configuration

	    ep_cfg[ep_cfg_indx].pcie_cfg.pl_cfg.enable_equalization_verification_mode   = 1;
            ep_cfg[ep_cfg_indx].pcie_cfg.pl_cfg.enable_equalization_coefficients_checks = 1;
            ep_cfg[ep_cfg_indx].pcie_cfg.tl_cfg.remote_max_payload_size                 = 4096;

            uvm_config_db#(svt_pcie_device_configuration)::set(this, {env_name,"*"}, $sformatf("endpoint_cfg[%0d]",ep_cfg_indx), ep_cfg[ep_cfg_indx]);

	    `ifdef SVT_PCIE_SLED_RECORD_ENABLE
            ep_cfg[ep_cfg_indx].pcie_cfg.enable_sled   = 1;
            `endif
	end//vip ep

	`uvm_info(get_full_name(),$sformatf("show base test my_speed[%0d]:%s",link_idx,this.my_speed[link_idx].name()),UVM_LOW)
        env.bypass_eq[link_idx] = this.bypass_eq[link_idx];
        env.my_speed[link_idx]  = this.my_speed[link_idx];
        env.device_type[link_idx] = this.device_type[link_idx];
    end //for(inti=0;i<SVT_PCIE_MAX_NUM_LINKS ; i++)
    env.cfg_enable            = this.cfg_enable;
    env.cfg_ecam_base_hi20    = this.cfg_ecam_base_hi20;
    env.cfg_raw_dbi_enable    = this.cfg_raw_dbi_enable;
    env.cfg_raw_dbi_base_hi24 = this.cfg_raw_dbi_base_hi24;
    for (int ii=0;ii<4;ii++) begin
        env.cfg_rp_valid[ii]       = this.cfg_rp_valid[ii];
        env.cfg_rp_device[ii]      = this.cfg_rp_device[ii];
        env.cfg_rp_primary[ii]     = this.cfg_rp_primary[ii];
        env.cfg_rp_secondary[ii]   = this.cfg_rp_secondary[ii];
        env.cfg_rp_subordinate[ii] = this.cfg_rp_subordinate[ii];
        env.cfg_rp_route_hi20[ii]  = this.cfg_rp_route_hi20[ii];
    end
    env.link_mode = this.link_mode;


    /**Set the payload display limit */
    svt_pcie_dl_disp_pattern::default_max_payload_print_dwords = 1024;

    //for axi
    if(cfg == null) cfg = cust_svt_axi_system_configuration::type_id::create("cfg",this);
    if (use_tlm_generic_payload) begin
        cfg.master_cfg[0].use_tlm_generic_payload = 1;
        cfg.slave_cfg[0].use_tlm_generic_payload  = 1;
    end
    uvm_config_db#(cust_svt_axi_system_configuration)::set(this, "env", "cfg", this.cfg);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.axi_system_env.slave*.sequencer.run_phase", "default_sequence", axi_slave_mem_response_sequence::type_id::get());

    //to avoid warning:timed out due to bus inactivity(bus inactivity timeout='d256000)
    cfg.bus_inactivity_timeout = 0;

    std::randomize(phy_ref_used_pad);
    `uvm_info("build_phase",$sformatf("random phy_ref_used_pad:%0h",phy_ref_used_pad),UVM_LOW)

    `uvm_info("build_phase","Exiting...",UVM_LOW)
endfunction: build_phase

function void pcie_subsys_base_test::connect_phase(uvm_phase phase);
    `uvm_info("start of connection phase","Entered...",UVM_LOW)
    super.connect_phase(phase);

    //for share phy
    PHY_SHARED_PIPE_LANE_CTRL_00              = env.regacc_noc.pcie_cus_top.sub_shared.get_reg_by_name("PHY_SHARED_PIPE_LANE_CTRL_00"); 
    PHY_SHARED_PIPE_LANE_CTRL_01              = env.regacc_noc.pcie_cus_top.sub_shared.get_reg_by_name("PHY_SHARED_PIPE_LANE_CTRL_01"); 
    PHY_SHARED_PIPE_LANE_CTRL_02              = env.regacc_noc.pcie_cus_top.sub_shared.get_reg_by_name("PHY_SHARED_PIPE_LANE_CTRL_02"); 

    SUBSYS_CLKREQ_WAKE_CTRL_SHARED            = env.regacc_noc.pcie_cus_top.sub_shared.get_reg_by_name("SUBSYS_CLKREQ_WAKE_CTRL"); 
    SUBSYS_CLKREQ_WAKE_CTRL_DIRECT            = env.regacc_noc.pcie_cus_top.sub_direct.get_reg_by_name("SUBSYS_CLKREQ_WAKE_CTRL"); 

    //for x1
    LINK_STATUS[0]                            = env.regacc_noc.pcie_cus_top.core_x1.get_reg_by_name("X1_X2_LINK_STATUS");
    CFGINFO_LEVEL[0]                          = env.regacc_noc.pcie_cus_top.get_reg_by_name("X1_CFGINFO_LEVEL");
    APP_DBI_CTRL[0]                           = env.regacc_noc.pcie_cus_top.core_x1.get_reg_by_name("X1_X2_APP_DBI_CTRL");
    ERR_INT_STATUS[0]                         = env.regacc_noc.pcie_cus_top.core_x1.get_reg_by_name("X1_X2_ERR_INT_STATUS");
    ERR_INT_MASK[0]                           = env.regacc_noc.pcie_cus_top.core_x1.get_reg_by_name("X1_X2_ERR_INT_MASK");
    RADM_INTX_STATUS[0]                       = env.regacc_noc.pcie_cus_top.core_x1.get_reg_by_name("X1_X2_RADM_INTX_STATUS");
    RADM_INTX_MASK[0]                         = env.regacc_noc.pcie_cus_top.core_x1.get_reg_by_name("X1_X2_RADM_INTX_MASK");
    APP_PM_CTRL[0]                            = env.regacc_noc.pcie_cus_top.core_x1.get_reg_by_name("X1_X2_APP_PM_CTRL");
    PM_STATUS[0]                              = env.regacc_noc.pcie_cus_top.core_x1.get_reg_by_name("X1_X2_PM_STATUS");
    CORE_INT_MASK[0]                          = env.regacc_noc.pcie_cus_top.core_x1.get_reg_by_name("X1_X2_CORE_INT_MASK");
    PORT_LINK_CTRL_OFF[0]                     = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PORT_LINK_CTRL_OFF");
    TIMER_CTRL_MAX_FUNC_NUM_OFF[0]            = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("TIMER_CTRL_MAX_FUNC_NUM_OFF");
    LINK_CONTROL2_LINK_STATUS2_REG[0]         = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("LINK_CONTROL2_LINK_STATUS2_REG");
    GEN3_RELATED_OFF[0]                       = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("GEN3_RELATED_OFF");
    GEN3_EQ_CONTROL_OFF[0]                    = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("GEN3_EQ_CONTROL_OFF");
    LINK_CONTROL3_REG[0]                      = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("LINK_CONTROL3_REG");
    LINK_CONTROL_LINK_STATUS_REG[0]           = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("LINK_CONTROL_LINK_STATUS_REG");
    PORT_FORCE_OFF[0]                         = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PORT_FORCE_OFF");
    PCI_MSI_CAP_ID_NEXT_CTRL_REG[0]           = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PCI_MSI_CAP_ID_NEXT_CTRL_REG");
    DPC_CAP_CONTROL_OFF[0]                    = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("DPC_CAP_CONTROL_OFF");
    LINK_CAPABILITIES_REG[0]                  = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("LINK_CAPABILITIES_REG");
    BRIDGE_CTRL_INT_PIN_INT_LINE_REG[0]       = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("BRIDGE_CTRL_INT_PIN_INT_LINE_REG");
    STATUS_COMMAND_REG[0]                     = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("TYPE1_STATUS_COMMAND_REG");
    DEVICE_CAPABILITIES_REG[0]                = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("DEVICE_CAPABILITIES_REG");
    DEVICE_CONTROL_DEVICE_STATUS[0]           = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("DEVICE_CONTROL_DEVICE_STATUS");
    MEM_LIMIT_MEM_BASE_REG[0]                 = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("MEM_LIMIT_MEM_BASE_REG");
    PREF_MEM_LIMIT_PREF_MEM_BASE_REG[0]       = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PREF_MEM_LIMIT_PREF_MEM_BASE_REG");
    PREF_BASE_UPPER_REG[0]                    = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PREF_BASE_UPPER_REG");
    PREF_LIMIT_UPPER_REG[0]                   = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PREF_LIMIT_UPPER_REG");
    SEC_STAT_IO_LIMIT_IO_BASE_REG[0]          = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("SEC_STAT_IO_LIMIT_IO_BASE_REG");
    BAR0_REG[0]                               = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("BAR0_REG");
    BAR1_REG[0]                               = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("BAR1_REG");
    CON_STATUS_REG[0]                         = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("CON_STATUS_REG");
    SLOT_CONTROL_SLOT_STATUS[0]               = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("SLOT_CONTROL_SLOT_STATUS");
    PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG[0] = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG");
    PL32G_CAPABILITY_REG[0]                   = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PL32G_CAPABILITY_REG");
    PL32G_CONTROL_REG[0]                      = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PL32G_CONTROL_REG");
    MISC_CONTROL_1_OFF[0]                     = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("MISC_CONTROL_1_OFF");
    RASDP_ERROR_MODE_EN_OFF[0]                = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("RASDP_ERROR_MODE_EN_OFF");
    RASDP_ERROR_MODE_CLEAR_OFF[0]             = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("RASDP_ERROR_MODE_CLEAR_OFF");
    ACK_F_ASPM_CTRL_OFF[0]                    = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("ACK_F_ASPM_CTRL_OFF");
    L1SUB_CAPABILITY_REG[0]                   = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("L1SUB_CAPABILITY_REG");
    L1SUB_CONTROL1_REG[0]                     = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("L1SUB_CONTROL1_REG");
    PHY_INTEROP_CTRL_OFF[0]                   = env.regacc_hnp.x1_rc_cfg.get_reg_by_name("PHY_INTEROP_CTRL_OFF");

    IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[0]      = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0");
    IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0[0]    = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0");
    IATU_LIMIT_ADDR_OFF_OUTBOUND_0[0]         = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_0");
    IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0[0]    = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0");
    IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0[0]  = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0");
    IATU_REGION_CTRL_1_OFF_OUTBOUND_0[0]      = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_0");
    IATU_REGION_CTRL_2_OFF_OUTBOUND_0[0]      = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_0");

    IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1[0]      = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1");
    IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1[0]    = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1");
    IATU_LIMIT_ADDR_OFF_OUTBOUND_1[0]         = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_1");
    IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1[0]    = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1");
    IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1[0]  = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1");
    IATU_REGION_CTRL_1_OFF_OUTBOUND_1[0]      = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_1");
    IATU_REGION_CTRL_2_OFF_OUTBOUND_1[0]      = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_1");

    IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2[0]     = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2");
    IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2[0]   = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2");
    IATU_LIMIT_ADDR_OFF_OUTBOUND_2[0]        = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_2");
    IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2[0]   = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2");
    IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2[0] = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2");
    IATU_REGION_CTRL_1_OFF_OUTBOUND_2[0]     = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_2");
    IATU_REGION_CTRL_2_OFF_OUTBOUND_2[0]     = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_2");

    IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3[0]     = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3");
    IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3[0]   = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3");
    IATU_LIMIT_ADDR_OFF_OUTBOUND_3[0]        = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_3");
    IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3[0]   = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3");
    IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3[0] = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3");
    IATU_REGION_CTRL_1_OFF_OUTBOUND_3[0]     = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_3");
    IATU_REGION_CTRL_2_OFF_OUTBOUND_3[0]     = env.regacc_hnp.x1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_3");

    //for x2
    LINK_STATUS[1]                            = env.regacc_noc.pcie_cus_top.core_x2.get_reg_by_name("X1_X2_LINK_STATUS");
    CFGINFO_LEVEL[1]                          = env.regacc_noc.pcie_cus_top.get_reg_by_name("X2_CFGINFO_LEVEL");
    APP_DBI_CTRL[1]                           = env.regacc_noc.pcie_cus_top.core_x2.get_reg_by_name("X1_X2_APP_DBI_CTRL");
    ERR_INT_STATUS[1]                         = env.regacc_noc.pcie_cus_top.core_x2.get_reg_by_name("X1_X2_ERR_INT_STATUS");
    ERR_INT_MASK[1]                           = env.regacc_noc.pcie_cus_top.core_x2.get_reg_by_name("X1_X2_ERR_INT_MASK");
    RADM_INTX_STATUS[1]                       = env.regacc_noc.pcie_cus_top.core_x2.get_reg_by_name("X1_X2_RADM_INTX_STATUS");
    RADM_INTX_MASK[1]                         = env.regacc_noc.pcie_cus_top.core_x2.get_reg_by_name("X1_X2_RADM_INTX_MASK");
    APP_PM_CTRL[1]                            = env.regacc_noc.pcie_cus_top.core_x2.get_reg_by_name("X1_X2_APP_PM_CTRL");
    PM_STATUS[1]                              = env.regacc_noc.pcie_cus_top.core_x2.get_reg_by_name("X1_X2_PM_STATUS");
    CORE_INT_MASK[1]                          = env.regacc_noc.pcie_cus_top.core_x2.get_reg_by_name("X1_X2_CORE_INT_MASK");
    PORT_LINK_CTRL_OFF[1]                     = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PORT_LINK_CTRL_OFF");
    TIMER_CTRL_MAX_FUNC_NUM_OFF[1]            = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("TIMER_CTRL_MAX_FUNC_NUM_OFF");
    LINK_CONTROL2_LINK_STATUS2_REG[1]         = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("LINK_CONTROL2_LINK_STATUS2_REG");
    GEN3_RELATED_OFF[1]                       = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("GEN3_RELATED_OFF");
    GEN3_EQ_CONTROL_OFF[1]                    = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("GEN3_EQ_CONTROL_OFF");
    LINK_CONTROL3_REG[1]                      = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("LINK_CONTROL3_REG");
    LINK_CONTROL_LINK_STATUS_REG[1]           = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("LINK_CONTROL_LINK_STATUS_REG");
    PORT_FORCE_OFF[1]                         = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PORT_FORCE_OFF");
    PCI_MSI_CAP_ID_NEXT_CTRL_REG[1]           = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PCI_MSI_CAP_ID_NEXT_CTRL_REG");
    DPC_CAP_CONTROL_OFF[1]                    = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("DPC_CAP_CONTROL_OFF");
    LINK_CAPABILITIES_REG[1]                  = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("LINK_CAPABILITIES_REG");
    BRIDGE_CTRL_INT_PIN_INT_LINE_REG[1]       = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("BRIDGE_CTRL_INT_PIN_INT_LINE_REG");
    STATUS_COMMAND_REG[1]                     = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("TYPE1_STATUS_COMMAND_REG");
    DEVICE_CAPABILITIES_REG[1]                = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("DEVICE_CAPABILITIES_REG");
    DEVICE_CONTROL_DEVICE_STATUS[1]           = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("DEVICE_CONTROL_DEVICE_STATUS");
    MEM_LIMIT_MEM_BASE_REG[1]                 = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("MEM_LIMIT_MEM_BASE_REG");
    PREF_MEM_LIMIT_PREF_MEM_BASE_REG[1]       = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PREF_MEM_LIMIT_PREF_MEM_BASE_REG");
    PREF_BASE_UPPER_REG[1]                    = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PREF_BASE_UPPER_REG");
    PREF_LIMIT_UPPER_REG[1]                   = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PREF_LIMIT_UPPER_REG");
    SEC_STAT_IO_LIMIT_IO_BASE_REG[1]          = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("SEC_STAT_IO_LIMIT_IO_BASE_REG");
    BAR0_REG[1]                               = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("BAR0_REG");
    BAR1_REG[1]                               = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("BAR1_REG");
    CON_STATUS_REG[1]                         = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("CON_STATUS_REG");
    SLOT_CONTROL_SLOT_STATUS[1]               = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("SLOT_CONTROL_SLOT_STATUS");
    PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG[1] = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG");
    PL32G_CAPABILITY_REG[1]                   = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PL32G_CAPABILITY_REG");
    PL32G_CONTROL_REG[1]                      = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PL32G_CONTROL_REG");
    MISC_CONTROL_1_OFF[1]                     = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("MISC_CONTROL_1_OFF");
    RASDP_ERROR_MODE_EN_OFF[1]                = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("RASDP_ERROR_MODE_EN_OFF");
    RASDP_ERROR_MODE_CLEAR_OFF[1]             = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("RASDP_ERROR_MODE_CLEAR_OFF");
    ACK_F_ASPM_CTRL_OFF[1]                    = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("ACK_F_ASPM_CTRL_OFF");
    L1SUB_CAPABILITY_REG[1]                   = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("L1SUB_CAPABILITY_REG");
    L1SUB_CONTROL1_REG[1]                     = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("L1SUB_CONTROL1_REG");
    PHY_INTEROP_CTRL_OFF[1]                   = env.regacc_hnp.x2_rc_cfg.get_reg_by_name("PHY_INTEROP_CTRL_OFF");

    IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[1]      = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0");
    IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0[1]    = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0");
    IATU_LIMIT_ADDR_OFF_OUTBOUND_0[1]         = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_0");
    IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0[1]    = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0");
    IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0[1]  = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0");
    IATU_REGION_CTRL_1_OFF_OUTBOUND_0[1]      = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_0");
    IATU_REGION_CTRL_2_OFF_OUTBOUND_0[1]      = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_0");

    IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1[1]      = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1");
    IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1[1]    = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1");
    IATU_LIMIT_ADDR_OFF_OUTBOUND_1[1]         = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_1");
    IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1[1]    = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1");
    IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1[1]  = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1");
    IATU_REGION_CTRL_1_OFF_OUTBOUND_1[1]      = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_1");
    IATU_REGION_CTRL_2_OFF_OUTBOUND_1[1]      = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_1");

    IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2[1]     = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2");
    IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2[1]   = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2");
    IATU_LIMIT_ADDR_OFF_OUTBOUND_2[1]        = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_2");
    IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2[1]   = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2");
    IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2[1] = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2");
    IATU_REGION_CTRL_1_OFF_OUTBOUND_2[1]     = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_2");
    IATU_REGION_CTRL_2_OFF_OUTBOUND_2[1]     = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_2");

    IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3[1]     = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3");
    IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3[1]   = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3");
    IATU_LIMIT_ADDR_OFF_OUTBOUND_3[1]        = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_3");
    IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3[1]   = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3");
    IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3[1] = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3");
    IATU_REGION_CTRL_1_OFF_OUTBOUND_3[1]     = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_3");
    IATU_REGION_CTRL_2_OFF_OUTBOUND_3[1]     = env.regacc_hnp.x2_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_3");

    //for x4_0
    LINK_STATUS[2]   = env.regacc_noc.pcie_cus_top.core_x4_0.get_reg_by_name("X4_LINK_STATUS");
    CFGINFO_LEVEL[2] = env.regacc_noc.pcie_cus_top.get_reg_by_name("X4_0_CFGINFO_LEVEL");
    APP_DBI_CTRL[2]  = env.regacc_noc.pcie_cus_top.core_x4_0.get_reg_by_name("X4_APP_DBI_CTRL");
    ERR_INT_STATUS[2]  = env.regacc_noc.pcie_cus_top.core_x4_0.get_reg_by_name("X4_ERR_INT_STATUS");
    ERR_INT_MASK[2]    = env.regacc_noc.pcie_cus_top.core_x4_0.get_reg_by_name("X4_ERR_INT_MASK");
    RADM_INTX_STATUS[2]  = env.regacc_noc.pcie_cus_top.core_x4_0.get_reg_by_name("X4_RADM_INTX_STATUS");
    RADM_INTX_MASK[2]  = env.regacc_noc.pcie_cus_top.core_x4_0.get_reg_by_name("X4_RADM_INTX_MASK");
    APP_PM_CTRL[2]     = env.regacc_noc.pcie_cus_top.core_x4_0.get_reg_by_name("X4_APP_PM_CTRL");
    PM_STATUS[2]       = env.regacc_noc.pcie_cus_top.core_x4_0.get_reg_by_name("X4_PM_STATUS");
    CORE_INT_MASK[2]   = env.regacc_noc.pcie_cus_top.core_x4_0.get_reg_by_name("X4_CORE_INT_MASK");
    if (is_rc(device_type[2])) begin//rc
         PORT_LINK_CTRL_OFF[2]                     = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PORT_LINK_CTRL_OFF");
         TIMER_CTRL_MAX_FUNC_NUM_OFF[2]            = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("TIMER_CTRL_MAX_FUNC_NUM_OFF");
	 LINK_CONTROL2_LINK_STATUS2_REG[2]         = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("LINK_CONTROL2_LINK_STATUS2_REG");
	 GEN3_RELATED_OFF[2]                       = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("GEN3_RELATED_OFF");
         GEN3_EQ_CONTROL_OFF[2]                    = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("GEN3_EQ_CONTROL_OFF");
         LINK_CONTROL3_REG[2]                      = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("LINK_CONTROL3_REG");
         LINK_CONTROL_LINK_STATUS_REG[2]           = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("LINK_CONTROL_LINK_STATUS_REG");
         PORT_FORCE_OFF[2]                         = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PORT_FORCE_OFF");
         PCI_MSI_CAP_ID_NEXT_CTRL_REG[2]           = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PCI_MSI_CAP_ID_NEXT_CTRL_REG");
         DPC_CAP_CONTROL_OFF[2]                    = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("DPC_CAP_CONTROL_OFF");
         LINK_CAPABILITIES_REG[2]                  = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("LINK_CAPABILITIES_REG");
         BRIDGE_CTRL_INT_PIN_INT_LINE_REG[2]       = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("BRIDGE_CTRL_INT_PIN_INT_LINE_REG");
         STATUS_COMMAND_REG[2]                     = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("TYPE1_STATUS_COMMAND_REG");
         DEVICE_CAPABILITIES_REG[2]                = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("DEVICE_CAPABILITIES_REG");
         DEVICE_CONTROL_DEVICE_STATUS[2]           = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("DEVICE_CONTROL_DEVICE_STATUS");
         MEM_LIMIT_MEM_BASE_REG[2]                 = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("MEM_LIMIT_MEM_BASE_REG");
         PREF_MEM_LIMIT_PREF_MEM_BASE_REG[2]       = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PREF_MEM_LIMIT_PREF_MEM_BASE_REG");
         PREF_BASE_UPPER_REG[2]                    = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PREF_BASE_UPPER_REG");
         PREF_LIMIT_UPPER_REG[2]                   = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PREF_LIMIT_UPPER_REG");
         SEC_STAT_IO_LIMIT_IO_BASE_REG[2]          = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("SEC_STAT_IO_LIMIT_IO_BASE_REG");
         BAR0_REG[2]                               = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("BAR0_REG");
         BAR1_REG[2]                               = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("BAR1_REG");
         CON_STATUS_REG[2]                         = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("CON_STATUS_REG");
         SLOT_CONTROL_SLOT_STATUS[2]               = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("SLOT_CONTROL_SLOT_STATUS");
         PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG[2] = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG");
         PL32G_CAPABILITY_REG[2]                   = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PL32G_CAPABILITY_REG");
         PL32G_CONTROL_REG[2]                      = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PL32G_CONTROL_REG");
         MISC_CONTROL_1_OFF[2]                     = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("MISC_CONTROL_1_OFF");
         RASDP_ERROR_MODE_EN_OFF[2]                = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("RASDP_ERROR_MODE_EN_OFF");
         RASDP_ERROR_MODE_CLEAR_OFF[2]             = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("RASDP_ERROR_MODE_CLEAR_OFF");
	 ACK_F_ASPM_CTRL_OFF[2]                    = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("ACK_F_ASPM_CTRL_OFF");
	 L1SUB_CAPABILITY_REG[2]                   = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("L1SUB_CAPABILITY_REG");
	 L1SUB_CONTROL1_REG[2]                     = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("L1SUB_CONTROL1_REG");
	 PHY_INTEROP_CTRL_OFF[2]                   = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("PHY_INTEROP_CTRL_OFF");
         IDE_CTRL_OFF[2]                           = env.regacc_hnp.x4_0_rc_cfg.get_reg_by_name("IDE_CTRL_OFF");

         IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[2]      = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0");
         IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0[2]    = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0");
         IATU_LIMIT_ADDR_OFF_OUTBOUND_0[2]         = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_0");
         IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0[2]    = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0");
         IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0[2]  = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0");
         IATU_REGION_CTRL_1_OFF_OUTBOUND_0[2]      = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_0");
         IATU_REGION_CTRL_2_OFF_OUTBOUND_0[2]      = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_0");

         IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1[2]      = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1");
         IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1[2]    = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1");
         IATU_LIMIT_ADDR_OFF_OUTBOUND_1[2]         = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_1");
         IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1[2]    = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1");
         IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1[2]  = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1");
         IATU_REGION_CTRL_1_OFF_OUTBOUND_1[2]      = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_1");
         IATU_REGION_CTRL_2_OFF_OUTBOUND_1[2]      = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_1");

         IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2[2]     = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2");
         IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2[2]   = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2");
         IATU_LIMIT_ADDR_OFF_OUTBOUND_2[2]        = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_2");
         IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2[2]   = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2");
         IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2[2] = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2");
         IATU_REGION_CTRL_1_OFF_OUTBOUND_2[2]     = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_2");
         IATU_REGION_CTRL_2_OFF_OUTBOUND_2[2]     = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_2");

         IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3[2]     = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3");
         IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3[2]   = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3");
         IATU_LIMIT_ADDR_OFF_OUTBOUND_3[2]        = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_3");
         IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3[2]   = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3");
         IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3[2] = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3");
         IATU_REGION_CTRL_1_OFF_OUTBOUND_3[2]     = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_3");
         IATU_REGION_CTRL_2_OFF_OUTBOUND_3[2]     = env.regacc_hnp.x4_0_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_3");
     end
     else begin
         PORT_LINK_CTRL_OFF[2]               = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PORT_LINK_CTRL_OFF");
         TIMER_CTRL_MAX_FUNC_NUM_OFF[2]      = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("TIMER_CTRL_MAX_FUNC_NUM_OFF");
	 LINK_CONTROL2_LINK_STATUS2_REG[2]   = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("LINK_CONTROL2_LINK_STATUS2_REG");
         GEN3_RELATED_OFF[2]                 = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("GEN3_RELATED_OFF");
         GEN3_EQ_CONTROL_OFF[2]              = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("GEN3_EQ_CONTROL_OFF");
         LINK_CONTROL3_REG[2]                = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("LINK_CONTROL3_REG");
         LINK_CONTROL_LINK_STATUS_REG[2]     = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("LINK_CONTROL_LINK_STATUS_REG");
         PORT_FORCE_OFF[2]                   = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PORT_FORCE_OFF");
         PCI_MSI_CAP_ID_NEXT_CTRL_REG[2]     = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PCI_MSI_CAP_ID_NEXT_CTRL_REG");
         //DPC_CAP_CONTROL_OFF[2]              = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("DPC_CAP_CONTROL_OFF");
         LINK_CAPABILITIES_REG[2]            = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("LINK_CAPABILITIES_REG");
         //BRIDGE_CTRL_INT_PIN_INT_LINE_REG[2] = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("BRIDGE_CTRL_INT_PIN_INT_LINE_REG");
         STATUS_COMMAND_REG[2]               = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("STATUS_COMMAND_REG");
         DEVICE_CAPABILITIES_REG[2]          = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("DEVICE_CAPABILITIES_REG");
         DEVICE_CONTROL_DEVICE_STATUS[2]     = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("DEVICE_CONTROL_DEVICE_STATUS");
         //MEM_LIMIT_MEM_BASE_REG[2]           = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("MEM_LIMIT_MEM_BASE_REG");
         //PREF_MEM_LIMIT_PREF_MEM_BASE_REG[2] = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PREF_MEM_LIMIT_PREF_MEM_BASE_REG");
         //PREF_BASE_UPPER_REG[2]              = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PREF_BASE_UPPER_REG");
         //PREF_LIMIT_UPPER_REG[2]             = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PREF_LIMIT_UPPER_REG");
         //SEC_STAT_IO_LIMIT_IO_BASE_REG[2]    = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("SEC_STAT_IO_LIMIT_IO_BASE_REG");
         BAR0_REG[2]                         = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("BAR0_REG");
         BAR1_REG[2]                         = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("BAR1_REG");
         BAR2_REG[2]                         = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("BAR2_REG");
         BAR3_REG[2]                         = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("BAR3_REG");
         BAR4_REG[2]                         = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("BAR4_REG");
         BAR5_REG[2]                         = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("BAR5_REG");
         CON_STATUS_REG[2]                   = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("CON_STATUS_REG");
         PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG[2] = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG");
         PL32G_CAPABILITY_REG[2]             = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PL32G_CAPABILITY_REG");
         PL32G_CONTROL_REG[2]             = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PL32G_CONTROL_REG");
         MISC_CONTROL_1_OFF[2]               = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("MISC_CONTROL_1_OFF");
         RASDP_ERROR_MODE_EN_OFF[2]          = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("RASDP_ERROR_MODE_EN_OFF");
         RASDP_ERROR_MODE_CLEAR_OFF[2]       = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("RASDP_ERROR_MODE_CLEAR_OFF");
	 ACK_F_ASPM_CTRL_OFF[2]              = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("ACK_F_ASPM_CTRL_OFF");
	 L1SUB_CAPABILITY_REG[2]             = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("L1SUB_CAPABILITY_REG");
	 L1SUB_CONTROL1_REG[2]               = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("L1SUB_CONTROL1_REG");
	 PHY_INTEROP_CTRL_OFF[2]             = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("PHY_INTEROP_CTRL_OFF");
         IDE_CTRL_OFF[2]                     = env.regacc_hnp.x4_0_ep_cfg.get_reg_by_name("IDE_CTRL_OFF");

         IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[2]      = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0");
         IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0[2]    = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0");
         IATU_LIMIT_ADDR_OFF_OUTBOUND_0[2]         = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_0");
         IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0[2]    = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0");
         IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0[2]  = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0");
         IATU_REGION_CTRL_1_OFF_OUTBOUND_0[2]      = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_0");
         IATU_REGION_CTRL_2_OFF_OUTBOUND_0[2]      = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_0");

         IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1[2]      = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1");
         IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1[2]    = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1");
         IATU_LIMIT_ADDR_OFF_OUTBOUND_1[2]         = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_1");
         IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1[2]    = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1");
         IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1[2]  = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1");
         IATU_REGION_CTRL_1_OFF_OUTBOUND_1[2]      = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_1");
         IATU_REGION_CTRL_2_OFF_OUTBOUND_1[2]      = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_1");

         IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2[2]     = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2");
         IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2[2]   = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2");
         IATU_LIMIT_ADDR_OFF_OUTBOUND_2[2]        = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_2");
         IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2[2]   = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2");
         IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2[2] = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2");
         IATU_REGION_CTRL_1_OFF_OUTBOUND_2[2]     = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_2");
         IATU_REGION_CTRL_2_OFF_OUTBOUND_2[2]     = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_2");

         IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3[2]     = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3");
         IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3[2]   = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3");
         IATU_LIMIT_ADDR_OFF_OUTBOUND_3[2]        = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_3");
         IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3[2]   = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3");
         IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3[2] = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3");
         IATU_REGION_CTRL_1_OFF_OUTBOUND_3[2]     = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_3");
         IATU_REGION_CTRL_2_OFF_OUTBOUND_3[2]     = env.regacc_hnp.x4_0_ep_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_3");
     end


    //for x4_1
    LINK_STATUS[3]   = env.regacc_noc.pcie_cus_top.core_x4_1.get_reg_by_name("X4_LINK_STATUS");
    CFGINFO_LEVEL[3] = env.regacc_noc.pcie_cus_top.get_reg_by_name("X4_1_CFGINFO_LEVEL");
    APP_DBI_CTRL[3]  = env.regacc_noc.pcie_cus_top.core_x4_1.get_reg_by_name("X4_APP_DBI_CTRL");
    ERR_INT_STATUS[3]  = env.regacc_noc.pcie_cus_top.core_x4_1.get_reg_by_name("X4_ERR_INT_STATUS");
    ERR_INT_MASK[3]    = env.regacc_noc.pcie_cus_top.core_x4_1.get_reg_by_name("X4_ERR_INT_MASK");
    RADM_INTX_STATUS[3]  = env.regacc_noc.pcie_cus_top.core_x4_1.get_reg_by_name("X4_RADM_INTX_STATUS");
    RADM_INTX_MASK[3]  = env.regacc_noc.pcie_cus_top.core_x4_1.get_reg_by_name("X4_RADM_INTX_MASK");
    APP_PM_CTRL[3]     = env.regacc_noc.pcie_cus_top.core_x4_1.get_reg_by_name("X4_APP_PM_CTRL");
    PM_STATUS[3]       = env.regacc_noc.pcie_cus_top.core_x4_1.get_reg_by_name("X4_PM_STATUS");
    CORE_INT_MASK[3]   = env.regacc_noc.pcie_cus_top.core_x4_1.get_reg_by_name("X4_CORE_INT_MASK");
    if (is_rc(device_type[3])) begin//rc
        PORT_LINK_CTRL_OFF[3]                     = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PORT_LINK_CTRL_OFF");
        TIMER_CTRL_MAX_FUNC_NUM_OFF[3]            = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("TIMER_CTRL_MAX_FUNC_NUM_OFF");
	LINK_CONTROL2_LINK_STATUS2_REG[3]         = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("LINK_CONTROL2_LINK_STATUS2_REG");
	GEN3_RELATED_OFF[3]                       = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("GEN3_RELATED_OFF");
        GEN3_EQ_CONTROL_OFF[3]                    = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("GEN3_EQ_CONTROL_OFF");
        LINK_CONTROL3_REG[3]                      = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("LINK_CONTROL3_REG");
        LINK_CONTROL_LINK_STATUS_REG[3]           = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("LINK_CONTROL_LINK_STATUS_REG");
        PORT_FORCE_OFF[3]                         = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PORT_FORCE_OFF");
        PCI_MSI_CAP_ID_NEXT_CTRL_REG[3]           = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PCI_MSI_CAP_ID_NEXT_CTRL_REG");
        DPC_CAP_CONTROL_OFF[3]                    = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("DPC_CAP_CONTROL_OFF");
        LINK_CAPABILITIES_REG[3]                  = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("LINK_CAPABILITIES_REG");
        BRIDGE_CTRL_INT_PIN_INT_LINE_REG[3]       = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("BRIDGE_CTRL_INT_PIN_INT_LINE_REG");
        STATUS_COMMAND_REG[3]                     = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("TYPE1_STATUS_COMMAND_REG");
        DEVICE_CAPABILITIES_REG[3]                = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("DEVICE_CAPABILITIES_REG");
        DEVICE_CONTROL_DEVICE_STATUS[3]           = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("DEVICE_CONTROL_DEVICE_STATUS");
        MEM_LIMIT_MEM_BASE_REG[3]                 = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("MEM_LIMIT_MEM_BASE_REG");
        PREF_MEM_LIMIT_PREF_MEM_BASE_REG[3]       = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PREF_MEM_LIMIT_PREF_MEM_BASE_REG");
        PREF_BASE_UPPER_REG[3]                    = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PREF_BASE_UPPER_REG");
        PREF_LIMIT_UPPER_REG[3]                   = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PREF_LIMIT_UPPER_REG");
        SEC_STAT_IO_LIMIT_IO_BASE_REG[3]          = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("SEC_STAT_IO_LIMIT_IO_BASE_REG");
        BAR0_REG[3]                               = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("BAR0_REG");
        BAR1_REG[3]                               = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("BAR1_REG");
        CON_STATUS_REG[3]                         = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("CON_STATUS_REG");
        SLOT_CONTROL_SLOT_STATUS[3]               = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("SLOT_CONTROL_SLOT_STATUS");
        PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG[3] = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG");
        PL32G_CAPABILITY_REG[3]                   = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PL32G_CAPABILITY_REG");
        PL32G_CONTROL_REG[3]                      = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PL32G_CONTROL_REG");
        MISC_CONTROL_1_OFF[3]                     = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("MISC_CONTROL_1_OFF");
        RASDP_ERROR_MODE_EN_OFF[3]                = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("RASDP_ERROR_MODE_EN_OFF");
        RASDP_ERROR_MODE_CLEAR_OFF[3]             = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("RASDP_ERROR_MODE_CLEAR_OFF");
	ACK_F_ASPM_CTRL_OFF[3]                    = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("ACK_F_ASPM_CTRL_OFF");
	L1SUB_CAPABILITY_REG[3]                   = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("L1SUB_CAPABILITY_REG");
	L1SUB_CONTROL1_REG[3]                     = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("L1SUB_CONTROL1_REG");
	PHY_INTEROP_CTRL_OFF[3]                   = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("PHY_INTEROP_CTRL_OFF");
        IDE_CTRL_OFF[3]                           = env.regacc_hnp.x4_1_rc_cfg.get_reg_by_name("IDE_CTRL_OFF");

        IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[3]      = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0");
        IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0[3]    = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0");
        IATU_LIMIT_ADDR_OFF_OUTBOUND_0[3]         = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_0");
        IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0[3]    = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0");
        IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0[3]  = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0");
        IATU_REGION_CTRL_1_OFF_OUTBOUND_0[3]      = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_0");
        IATU_REGION_CTRL_2_OFF_OUTBOUND_0[3]      = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_0");

        IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1[3]      = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1");
        IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1[3]    = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1");
        IATU_LIMIT_ADDR_OFF_OUTBOUND_1[3]         = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_1");
        IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1[3]    = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1");
        IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1[3]  = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1");
        IATU_REGION_CTRL_1_OFF_OUTBOUND_1[3]      = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_1");
        IATU_REGION_CTRL_2_OFF_OUTBOUND_1[3]      = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_1");

        IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2[3]     = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2");
        IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2[3]   = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2");
        IATU_LIMIT_ADDR_OFF_OUTBOUND_2[3]        = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_2");
        IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2[3]   = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2");
        IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2[3] = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2");
        IATU_REGION_CTRL_1_OFF_OUTBOUND_2[3]     = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_2");
        IATU_REGION_CTRL_2_OFF_OUTBOUND_2[3]     = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_2");

        IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3[3]     = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3");
        IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3[3]   = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3");
        IATU_LIMIT_ADDR_OFF_OUTBOUND_3[3]        = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_3");
        IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3[3]   = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3");
        IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3[3] = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3");
        IATU_REGION_CTRL_1_OFF_OUTBOUND_3[3]     = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_3");
        IATU_REGION_CTRL_2_OFF_OUTBOUND_3[3]     = env.regacc_hnp.x4_1_rc_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_3");
    end
    else begin
        PORT_LINK_CTRL_OFF[3]               = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PORT_LINK_CTRL_OFF");
        TIMER_CTRL_MAX_FUNC_NUM_OFF[3]      = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("TIMER_CTRL_MAX_FUNC_NUM_OFF");
	LINK_CONTROL2_LINK_STATUS2_REG[3]   = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("LINK_CONTROL2_LINK_STATUS2_REG");
        GEN3_RELATED_OFF[3]                 = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("GEN3_RELATED_OFF");
        GEN3_EQ_CONTROL_OFF[3]              = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("GEN3_EQ_CONTROL_OFF");
        LINK_CONTROL3_REG[3]                = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("LINK_CONTROL3_REG");
        LINK_CONTROL_LINK_STATUS_REG[3]     = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("LINK_CONTROL_LINK_STATUS_REG");
        PORT_FORCE_OFF[3]                   = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PORT_FORCE_OFF");
        PCI_MSI_CAP_ID_NEXT_CTRL_REG[3]     = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PCI_MSI_CAP_ID_NEXT_CTRL_REG");
        //DPC_CAP_CONTROL_OFF[3]              = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("DPC_CAP_CONTROL_OFF");
        LINK_CAPABILITIES_REG[3]            = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("LINK_CAPABILITIES_REG");
        //BRIDGE_CTRL_INT_PIN_INT_LINE_REG[3] = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("BRIDGE_CTRL_INT_PIN_INT_LINE_REG");
        STATUS_COMMAND_REG[3]               = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("STATUS_COMMAND_REG");
        DEVICE_CAPABILITIES_REG[3]          = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("DEVICE_CAPABILITIES_REG");
        DEVICE_CONTROL_DEVICE_STATUS[3]     = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("DEVICE_CONTROL_DEVICE_STATUS");
        //MEM_LIMIT_MEM_BASE_REG[3]           = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("MEM_LIMIT_MEM_BASE_REG");
        //PREF_MEM_LIMIT_PREF_MEM_BASE_REG[3] = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PREF_MEM_LIMIT_PREF_MEM_BASE_REG");
        //PREF_BASE_UPPER_REG[3]              = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PREF_BASE_UPPER_REG");
        //PREF_LIMIT_UPPER_REG[3]             = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PREF_LIMIT_UPPER_REG");
        //SEC_STAT_IO_LIMIT_IO_BASE_REG[3]    = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("SEC_STAT_IO_LIMIT_IO_BASE_REG");
        BAR0_REG[3]                         = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("BAR0_REG");
        BAR1_REG[3]                         = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("BAR1_REG");
        BAR2_REG[3]                         = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("BAR2_REG");
        BAR3_REG[3]                         = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("BAR3_REG");
        BAR4_REG[3]                         = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("BAR4_REG");
        BAR5_REG[3]                         = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("BAR5_REG");
        CON_STATUS_REG[3]                   = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("CON_STATUS_REG");
        PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG[3] = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PCIE_CAP_ID_PCIE_NEXT_CAP_PTR_PCIE_CAP_REG");
        PL32G_CAPABILITY_REG[3]             = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PL32G_CAPABILITY_REG");
        PL32G_CONTROL_REG[3]                = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PL32G_CONTROL_REG");
        MISC_CONTROL_1_OFF[3]               = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("MISC_CONTROL_1_OFF");
        RASDP_ERROR_MODE_EN_OFF[3]          = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("RASDP_ERROR_MODE_EN_OFF");
        RASDP_ERROR_MODE_CLEAR_OFF[3]       = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("RASDP_ERROR_MODE_CLEAR_OFF");
	ACK_F_ASPM_CTRL_OFF[3]              = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("ACK_F_ASPM_CTRL_OFF");
	L1SUB_CAPABILITY_REG[3]             = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("L1SUB_CAPABILITY_REG");
	L1SUB_CONTROL1_REG[3]               = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("L1SUB_CONTROL1_REG");
	PHY_INTEROP_CTRL_OFF[3]             = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("PHY_INTEROP_CTRL_OFF");
        IDE_CTRL_OFF[3]                     = env.regacc_hnp.x4_1_ep_cfg.get_reg_by_name("IDE_CTRL_OFF");

        IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[3]      = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0");
        IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0[3]    = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0");
        IATU_LIMIT_ADDR_OFF_OUTBOUND_0[3]         = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_0");
        IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0[3]    = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0");
        IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0[3]  = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0");
        IATU_REGION_CTRL_1_OFF_OUTBOUND_0[3]      = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_0");
        IATU_REGION_CTRL_2_OFF_OUTBOUND_0[3]      = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_0");

        IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1[3]      = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1");
        IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1[3]    = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1");
        IATU_LIMIT_ADDR_OFF_OUTBOUND_1[3]         = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_1");
        IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1[3]    = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1");
        IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1[3]  = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1");
        IATU_REGION_CTRL_1_OFF_OUTBOUND_1[3]      = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_1");
        IATU_REGION_CTRL_2_OFF_OUTBOUND_1[3]      = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_1");

        IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2[3]     = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2");
        IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2[3]   = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2");
        IATU_LIMIT_ADDR_OFF_OUTBOUND_2[3]        = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_2");
        IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2[3]   = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2");
        IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2[3] = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2");
        IATU_REGION_CTRL_1_OFF_OUTBOUND_2[3]     = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_2");
        IATU_REGION_CTRL_2_OFF_OUTBOUND_2[3]     = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_2");

        IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3[3]     = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3");
        IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3[3]   = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3");
        IATU_LIMIT_ADDR_OFF_OUTBOUND_3[3]        = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LIMIT_ADDR_OFF_OUTBOUND_3");
        IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3[3]   = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3");
        IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3[3] = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3");
        IATU_REGION_CTRL_1_OFF_OUTBOUND_3[3]     = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_REGION_CTRL_1_OFF_OUTBOUND_3");
        IATU_REGION_CTRL_2_OFF_OUTBOUND_3[3]     = env.regacc_hnp.x4_1_ep_atu.get_reg_by_name("IATU_REGION_CTRL_2_OFF_OUTBOUND_3");
    end

    `uvm_info("end of connection phase" , "Entered...",UVM_LOW)
endfunction

function void pcie_subsys_base_test::end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("end_of_elaboration_phase", "Entered...",UVM_LOW)
    root.print_topology();
    `uvm_info("end_of_elaboration_phase","Exiting...!",UVM_LOW)
endfunction:end_of_elaboration_phase

function void pcie_subsys_base_test::final_phase(uvm_phase phase);
    uvm_report_server svr;    
    `uvm_info("final_phase","Entered...",UVM_LOW)

    super.final_phase(phase);

    svr =uvm_report_server::get_server();


    if((svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) +
        svr.get_severity_count(UVM_WARNING) == 0))
        `uvm_info("final_phase", "\nSvtTestEpilog: Passed\n",UVM_LOW)
    else
        `uvm_info("final_phase","\nSvtTestEpilog: Failed\n", UVM_LOW)

    `uvm_info("final_phase","Exiting...",UVM_LOW)
endfunction: final_phase

task pcie_subsys_base_test::link_training(int link_idx);//0:x1,1:x2,2:x4_0,3:x4_1
    logic[31:0]   rdata;
    logic[31:0]   wdata;
    uvm_status_e  status_tmp;
    svt_pcie_dl_service_set_link_en_sequence link_en_seq[4];
    svt_pcie_device_status dev_status;
    bit[3:0] exp_cur_link_speed;
    bit[3:0] target_link_speed;

    bit[31:0] addr_tmp;

    string    reg_name;
    string    field_name;

    if (is_rc(device_type[link_idx])) begin//dut is rc
	if (2 == link_idx) begin//x4_0
            force spd_3.vip_port_if.ser_if.reset = 1'b1;//keep reset for rc vip
        end
	else if (3 == link_idx) begin//x4_1
            force spd_5.vip_port_if.ser_if.reset = 1'b1;//keep reset for rc vip
	end
    end
    else if (is_rc(device_type[link_idx])==0)  begin//dut is ep
	if (2 == link_idx) begin//x4_0
            force spd_2.vip_port_if.ser_if.reset = 1'b1;//keep reset for ep vip
        end
        else if (3 == link_idx) begin//x4_1
            force spd_4.vip_port_if.ser_if.reset = 1'b1;//keep reset for ep vip
        end
    end
    else begin
        `uvm_fatal("LINK TRAINING",$sformatf("device_type[%0d]:%0h is illegal",link_idx,device_type[link_idx]))
    end

    //`uvm_info("SHOW_PL_CFG",$sformatf("ep pl_cfg:\n%s",env.endpoint_cfg[link_idx].pcie_cfg.pl_cfg.sprint()),UVM_LOW)
    $display("AAAAA exec link_training for %s, @%t",this.my_speed[link_idx].name(),$time);
    if(this.my_speed[link_idx] == GEN5_MY)begin
        exp_cur_link_speed = 4'h5;//the max speed is gen5.
        target_link_speed  = 4'h5;//the max speed is gen5.
    end
    else if(this.my_speed[link_idx] == GEN4_MY)begin
        exp_cur_link_speed = 4'h4;//the max speed is gen4.
        target_link_speed  = 4'h4;//the max speed is gen4.
    end
    else if(this.my_speed[link_idx] == GEN3_MY)begin
        exp_cur_link_speed =4'h3;//the max speed is gen3.
        target_link_speed  =4'h3;//the max speed is gen3.
    end
    else if(this.my_speed[link_idx] ==GEN2_MY)begin
        exp_cur_link_speed =4'h2;//the max speed is gen2.
        target_link_speed  =4'h2;//the max speed is gen2.
    end
    else begin
        exp_cur_link_speed =4'h1;//the max speed is gen1.
        target_link_speed  =4'h1;//the max speed is gen1.
    end

    $display("enter main phase for link_idx:%0d, @%t",link_idx,$time);
    link_en_seq[link_idx] = svt_pcie_dl_service_set_link_en_sequence::type_id::create($sformatf("link_en_seq[%0d]",link_idx),this);
    if (is_rc(device_type[link_idx])) begin//dut is rc
        env.endpoint[link_idx].get_device_status(dev_status);
    end
    else if (is_rc(device_type[link_idx]) == 0)  begin//dut is ep
        env.root[link_idx-2].get_device_status(dev_status);
    end
    else begin
        `uvm_fatal("LINK TRAINING",$sformatf("device_type[%0d]:%0h is illegal",link_idx,device_type[link_idx]))
    end

    //@(posedge test_top.pcie_cfg_bus_reset_n);
    wait(test_top.pcie_cfg_bus_reset_n == 1'b1);
    //@(posedge test_top.link_init_niu.init64_to_Link_PwrDisc_SlvRdy);//TODO wait niu has ready
    wait(test_top.link_init_niu.init64_to_Link_PwrDisc_SlvRdy == 1'b1);
    $display("start to test reg test for link_idx:%0d, @%t",link_idx,$time);
    #100ns;

    //step0 program phy register if need ??
    if(1'b1 ==enable_phy_sram_init)begin
        //enable_sram_ld_fl();
    end

    //program ecam register
    $display("show ECAM_CTRL addr:%0h for link_idx:%0d @%t",env.regacc_noc.get_reg_by_name("ECAM_CTRL").get_address(),link_idx,$time);
    env.regacc_noc.get_reg_by_name("ECAM_CTRL").read(status_tmp, rdata);
    env.regacc_noc.get_reg_by_name("ECAM_CTRL").get_field_by_name("cfg_enable").set(this.cfg_enable);
    env.regacc_noc.get_reg_by_name("ECAM_CTRL").update(status_tmp);
    $display("finish ECAM_CTRL write for link_idx:%0d @%t",link_idx,$time);

    env.regacc_noc.get_reg_by_name("ECAM_BASE_HI20").get_field_by_name("cfg_ecam_base_hi20").set(this.cfg_ecam_base_hi20);
    env.regacc_noc.get_reg_by_name("ECAM_BASE_HI20").update(status_tmp);

    //program dbi register
    $display("show RAW_DBI_CTRL addr:%0h for link_idx:%0d @%t",env.regacc_noc.get_reg_by_name("RAW_DBI_CTRL").get_address(),link_idx,$time);
    env.regacc_noc.get_reg_by_name("RAW_DBI_CTRL").read(status_tmp, rdata);
    env.regacc_noc.get_reg_by_name("RAW_DBI_CTRL").get_field_by_name("cfg_raw_dbi_enable").set(this.cfg_raw_dbi_enable);
    env.regacc_noc.get_reg_by_name("RAW_DBI_CTRL").update(status_tmp);
    $display("finish RAW_DBI_CTRL write for link_idx:%0d @%t",link_idx,$time);

    env.regacc_noc.get_reg_by_name("RAW_DBI_BASE_HI24").get_field_by_name("cfg_raw_dbi_base_hi24").set(this.cfg_raw_dbi_base_hi24);
    env.regacc_noc.get_reg_by_name("RAW_DBI_BASE_HI24").update(status_tmp);

    reg_name   = $sformatf("RP%0d_CFG",link_idx);
    env.regacc_noc.get_reg_by_name(reg_name).read(status_tmp, rdata);

    field_name = $sformatf("cfg_rp%0d_valid",link_idx);
    env.regacc_noc.get_reg_by_name(reg_name).get_field_by_name(field_name).set(this.cfg_rp_valid[link_idx]);

    field_name = $sformatf("cfg_rp%0d_device",link_idx);
    env.regacc_noc.get_reg_by_name(reg_name).get_field_by_name(field_name).set(this.cfg_rp_device[link_idx]);

    field_name = $sformatf("cfg_rp%0d_primary",link_idx);
    env.regacc_noc.get_reg_by_name(reg_name).get_field_by_name(field_name).set(this.cfg_rp_primary[link_idx]);

    field_name = $sformatf("cfg_rp%0d_secondary",link_idx);
    env.regacc_noc.get_reg_by_name(reg_name).get_field_by_name(field_name).set(this.cfg_rp_secondary[link_idx]);

    field_name = $sformatf("cfg_rp%0d_subordinate",link_idx);
    env.regacc_noc.get_reg_by_name(reg_name).get_field_by_name(field_name).set(this.cfg_rp_subordinate[link_idx]);

    env.regacc_noc.get_reg_by_name(reg_name).update(status_tmp);

    reg_name   = $sformatf("RP%0d_ROUTE",link_idx);
    env.regacc_noc.get_reg_by_name(reg_name).read(status_tmp, rdata);
    field_name = $sformatf("cfg_rp%0d_route_hi20",link_idx);
    env.regacc_noc.get_reg_by_name(reg_name).get_field_by_name(field_name).set(this.cfg_rp_route_hi20[link_idx]);
    env.regacc_noc.get_reg_by_name(reg_name).update(status_tmp);


    //set device type for x4_0,x4_1
    //if (link_idx ==2) begin
    //    env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.read(status_tmp, rdata);
    //    `uvm_info("LINK TRAINING",$sformatf("read sub shared SUBSYS_PORT_MODE_CTRL,add:%0h,rdata:%0h,link_idx:%0d",env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.get_address(),rdata,link_idx),UVM_LOW)
    //    rdata[3:0] = device_type[link_idx];
    //    rdata[9:7] = device_type[link_idx];
    //    `uvm_info("LINK TRAINING",$sformatf("start to write sub shared SUBSYS_PORT_MODE_CTRL,add:%0h,rdata:%0h,device_type:%0h,link_idx:%0d",env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.get_address(),rdata,device_type[link_idx],link_idx),UVM_LOW)
    //    env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.write(status_tmp,rdata);
    //    `uvm_info("LINK TRAINING",$sformatf("finish write sub shared SUBSYS_PORT_MODE_CTRL,add:%0h,rdata:%0h,link_idx:%0d",env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.get_address(),rdata,link_idx),UVM_LOW)
    //    env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.read(status_tmp, rdata);
    //    `uvm_info("LINK TRAINING",$sformatf("set device_type[%0d]:%0h SUBSYS_PORT_MODE_CTRL:%0h",link_idx,device_type[link_idx],rdata),UVM_LOW)
    //end
    if (link_idx ==3) begin
        env.regacc_noc.pcie_cus_top.sub_direct.SUBSYS_PORT_MODE_CTRL.read(status_tmp, rdata);
        rdata[3:0] = device_type[link_idx];
        rdata[7:5] = device_type[link_idx];
        env.regacc_noc.pcie_cus_top.sub_direct.SUBSYS_PORT_MODE_CTRL.write(status_tmp,rdata);
	env.regacc_noc.pcie_cus_top.sub_direct.SUBSYS_PORT_MODE_CTRL.read(status_tmp, rdata);
        `uvm_info("LINK TRAINING",$sformatf("set device_type[%0d]:%0h SUBSYS_PORT_MODE_CTRL:%0h",link_idx,device_type[link_idx],rdata),UVM_LOW)
    end

    if (link_idx inside {0,1,2}) begin
	share_rst_sem.get();
	`uvm_info("LINK TRAINING",$sformatf("start to program link mode:%s for link_idx:%0d",link_mode.name(),link_idx),UVM_LOW)
	env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.read(status_tmp, rdata);
        `uvm_info("LINK TRAINING",$sformatf("read sub shared SUBSYS_PORT_MODE_CTRL,add:%0h,rdata:%0h,link_idx:%0d",env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.get_address(),rdata,link_idx),UVM_LOW)
	rdata[11:10] = link_mode;//TODO
	if (link_idx ==2) begin
	    rdata[3:0] = device_type[link_idx];
            rdata[9:7] = device_type[link_idx];
	end
	`uvm_info("LINK TRAINING",$sformatf("start to write sub shared SUBSYS_PORT_MODE_CTRL,add:%0h,rdata:%0h,device_type:%0h,link_idx:%0d",env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.get_address(),rdata,device_type[link_idx],link_idx),UVM_LOW)
	env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.write(status_tmp,rdata);
	`uvm_info("LINK TRAINING",$sformatf("finish write sub shared SUBSYS_PORT_MODE_CTRL,add:%0h,rdata:%0h,link_idx:%0d",env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.get_address(),rdata,link_idx),UVM_LOW)
	env.regacc_noc.pcie_cus_top.sub_shared.SUBSYS_PORT_MODE_CTRL.read(status_tmp, rdata);
        `uvm_info("LINK TRAINING",$sformatf("set device_type[%0d]:%0h SUBSYS_PORT_MODE_CTRL:%0h",link_idx,device_type[link_idx],rdata),UVM_LOW)
	`uvm_info("LINK TRAINING",$sformatf("finish program link mode:%s for link_idx:%0d",link_mode.name(),link_idx),UVM_LOW)
	share_rst_sem.put();
    end

    //step1
    $display("start to release all reset for link_idx:%0d, @t",link_idx,$time);
    if (link_idx inside {0,1,2}) begin
        share_rst_sem.get();
        env.regacc_noc.pcie_cus_top.sub_shared.Reset_control.read(status_tmp,rdata);
	rdata[2+link_idx] = 1'b1;//perst_n
	rdata[5+link_idx] = 1'b1;//sticky_rst_n
	rdata[8+link_idx] = 1'b1;//non_sticky_rst_n
	rdata[11+link_idx] = 1'b1;//buttorn_rst_n
	rdata[14+link_idx] = 1'b1;//core_rst_n
	env.regacc_noc.pcie_cus_top.sub_shared.Reset_control.write(status_tmp,rdata);
        share_rst_sem.put();
    end
    else begin
	env.regacc_noc.pcie_cus_top.sub_direct.Reset_control.read(status_tmp,rdata);
	rdata[2] = 1'b1;//perst_n
	rdata[3] = 1'b1;//sticky_rst_n
	rdata[4] = 1'b1;//non_sticky_rst_n
	rdata[5] = 1'b1;//buttorn_rst_n
	rdata[6] = 1'b1;//core_rst_n
	env.regacc_noc.pcie_cus_top.sub_direct.Reset_control.write(status_tmp,rdata);
    end

    $display("start to toggle phy reset for link_idx:%0d, @t",link_idx,$time);
    //if (link_idx inside {0,1,2}) begin
    //    env.regacc_noc.pcie_cus_top.sub_shared.reset_control_phy.write(status_tmp,32'h0);
    //    #20ns;
    //    env.regacc_noc.pcie_cus_top.sub_shared.reset_control_phy.write(status_tmp,32'h1);
    //end
    //else begin
    //    env.regacc_noc.pcie_cus_top.sub_direct.reset_control_phy.write(status_tmp,32'h0);
    //    #20ns;
    //    env.regacc_noc.pcie_cus_top.sub_direct.reset_control_phy.write(status_tmp,32'h1);
    //end

    #1000ns;
    if (link_idx inside {0,1,2}) begin
        env.regacc_noc.pcie_cus_top.sub_shared.reset_control_phy.write(status_tmp,32'h0);
    end
    else begin
	env.regacc_noc.pcie_cus_top.sub_direct.reset_control_phy.write(status_tmp,32'h0);
    end
    #1000ns;

    //program phy ref clk sel

    //step2
    $display("start to hold ltssm reset for read link_idx:%0d,addr:%0h @%t",link_idx,CFGINFO_LEVEL[link_idx].get_address(),$time);
    CFGINFO_LEVEL[link_idx].read(status_tmp, rdata);
    rdata[0]     = 1'b1;//app_xfer_pending
    rdata[6]     = 1'b0;//app_ltssm_enable
    rdata[11:9]  = 3'h4;//diag ctrl bus,4:fast link mode//TODO
    rdata[19]= 1'b0;//release app_hold_phy_rst.
    $display("start to hold ltssm reset for write link_idx:%0d,addr:%0h wr data:%0h, @%t",link_idx,CFGINFO_LEVEL[link_idx].get_address(),rdata,$time);
    CFGINFO_LEVEL[link_idx].write(status_tmp,rdata);
    CFGINFO_LEVEL[link_idx].read(status_tmp, rdata);
    `uvm_info("LINK TRAINING",$sformatf("after setting ltssm enable to 0, and fast link mode. so CFGINFO_LEVEL[%0d]:%0h",link_idx,rdata),UVM_LOW)

    this.PORT_LINK_CTRL_OFF[link_idx].read(status_tmp,rdata);
    $display("show the expected link width:%0h, act reg val:%0h for link_idx:%0d, addr:%0h @%t",link_width[link_idx],rdata,link_idx,this.PORT_LINK_CTRL_OFF[link_idx].get_address(),$time);
    rdata[21:16]=this.link_width[link_idx];
    this.PORT_LINK_CTRL_OFF[link_idx].write(status_tmp,rdata);

    this.TIMER_CTRL_MAX_FUNC_NUM_OFF[link_idx].read(status_tmp,rdata);
    rdata[30:29]=2'h1;//FAST_LINKS CALINGFACTOR:0:1ms->lus 1:1ms->4us 2:1ms->16us 3:1ms->64us
    this.TIMER_CTRL_MAX_FUNC_NUM_OFF[link_idx].write(status_tmp,rdata);

    //step3. program other core regiser.if need ???
    //if (device_type == 4'h4) begin//dut is rc
        addr_tmp = this.LINK_CONTROL2_LINK_STATUS2_REG[link_idx].get_address();
        $display("show LINK_CONTROL2_LINK_STATUS2_REG[%0d] addr:%0h @%t",link_idx,addr_tmp,$time);
        this.LINK_CONTROL2_LINK_STATUS2_REG[link_idx].read(status_tmp,rdata) ;
        $display("once read value,LINK_CONTROL2_LINK_STATUS2_REG[%0d]:%0h,target_link_speed:%0h @%t" ,link_idx,rdata,target_link_speed,$time);
        rdata[3:0]=target_link_speed;//set target_link_speed
        this.LINK_CONTROL2_LINK_STATUS2_REG[link_idx].write(status_tmp,rdata);
        this.LINK_CONTROL2_LINK_STATUS2_REG[link_idx].read(status_tmp,rdata);
        $display("twice read value,LINK_CONTROL2_LINK_STATUS2_REG[%0d]:%0h,@%t",link_idx,rdata,$time);
    //end

    if(this.bypass_eq[link_idx]==1'b1) begin
	$display("start to cfg noeq para for link_idx:%0d GEN3_RELATED_OFF addr:%0h, @%t",link_idx,this.GEN3_RELATED_OFF[link_idx].get_address(),$time);
        this.GEN3_RELATED_OFF[link_idx].read(status_tmp,rdata);
        rdata[16]=1'b1;//GEN3 EQUALIZATION DISABLE
        this.GEN3_RELATED_OFF[link_idx].write(status_tmp,rdata);

        //if (is_rc(device_type[link_idx]) ==0) begin//dut is EP
	    //$display("start to set app_dbi_ro_wr_disable to 0. APP_DBI_CTRL[%0d] addr:%0h, @%t",link_idx,this.APP_DBI_CTRL[link_idx].get_address(),$time);
	    //APP_DBI_CTRL[link_idx].read(status_tmp, rdata);
	    //rdata[0] = 1'b0;//app_dbi_ro_wr_disable:DBI Read-only Write Disable 0: MISC_CONTROL_1_OFF.DBI_RO_WR_EN register field is read-write. [Controller RM p.1033]
	    //APP_DBI_CTRL[link_idx].write(status_tmp, rdata);

	    $display("start to set DBI_RO_WR_EN to 1, MISC_CONTROL_1_OFF[%0d] addr:%0h, @%t",link_idx,this.MISC_CONTROL_1_OFF[link_idx].get_address(),$time);
            MISC_CONTROL_1_OFF[link_idx].read(status_tmp, rdata);
            rdata[0] = 1'b1;//DBI_RO_WR_EN
            MISC_CONTROL_1_OFF[link_idx].write(status_tmp, rdata);


	    $display("start to set NO_EQ_NEEDED_SUPPORT to 1, PL32G_CAPABILITY_REG[%0d] addr:%0h, @%t",link_idx,this.PL32G_CAPABILITY_REG[link_idx].get_address(),$time);
            this.PL32G_CAPABILITY_REG[link_idx].read(status_tmp,rdata);
            `uvm_info("LINK TRAINING",$sformatf("show PL32G_CAPABILITY_REG[%0d] value:%0h",link_idx,rdata),UVM_LOW)
            rdata[1]=1'b1;//NO_EQ_NEEDED_SUPPORT
            this.PL32G_CAPABILITY_REG[link_idx].write(status_tmp,rdata);

	    //MISC_CONTROL_1_OFF[link_idx].read(status_tmp, rdata);
            //rdata[0] = 1'b0;//DBI_RO_WR_EN
            //MISC_CONTROL_1_OFF[link_idx].write(status_tmp, rdata);

	    //APP_DBI_CTRL[link_idx].read(status_tmp, rdata);
	    //rdata[0] = 1'b1;//app_dbi_ro_rw_disable
	    //APP_DBI_CTRL[link_idx].write(status_tmp, rdata)

	    $display("start to set NO_EQ_NEEDED_DISABLE to 0, PL32G_CONTROL_REG[%0d] addr:%0h, @%t",link_idx,this.PL32G_CONTROL_REG[link_idx].get_address(),$time);
	    PL32G_CONTROL_REG[link_idx].read(status_tmp, rdata);
	    rdata[1] = 1'b0;//NO_EQ_NEEDED_DISABLE
	    PL32G_CONTROL_REG[link_idx].write(status_tmp, rdata);
        //end
    end
    else begin
	$display("start to cfg eq para for link_idx:%0d, @%t",link_idx,$time);
        if (is_rc(device_type[link_idx]) ==0) begin//dut is EP
            this.GEN3_RELATED_OFF[link_idx].read(status_tmp,rdata);
            rdata[11]=1'b1;//EQ_REDO DISABLE
            this.GEN3_RELATED_OFF[link_idx].write(status_tmp,rdata);
        end

        this.GEN3_EQ_CONTROL_OFF[link_idx].read(status_tmp,rdata);
        rdata[4]=1'b1;//GEN3_EQ_PHASE23_EXIT_MODE
        this.GEN3_EQ_CONTROL_OFF[link_idx].write(status_tmp,rdata);

        this.LINK_CONTROL3_REG[link_idx].read(status_tmp,rdata);
        rdata[1]=1'b1;//link equalization request interrupt enable
        this.LINK_CONTROL3_REG[link_idx].write(status_tmp,rdata);
    end

   //enable to trigger cfg_link_auto_bw_*int
   $display("start to cfg cfg_link_auto_bw_ for link_idx:%0d, @%t",link_idx,$time);
   this.LINK_CONTROL_LINK_STATUS_REG[link_idx].read(status_tmp,rdata); 
   rdata[10]= this.link_bw_mgt_int_en[link_idx];//PCIE_CAP_LINK_BW_MAN_INT_EN
   rdata[11]= this.link_auto_bw_int_en[link_idx];//PCIE_CAP_LINK_AUTO_BW_INT_EN
   this.LINK_CONTROL_LINK_STATUS_REG[link_idx].write(status_tmp,rdata);

    //avoid to warning:ACTIVE PL:CONFIGURATION LTSSM:phy unexpected link number
   $display("start to cfg link number for link_idx:%0d, @%t",link_idx,$time);
   this.PORT_FORCE_OFF[link_idx].read(status_tmp,rdata);
   rdata[7:0]=8'h0;//set link number to 0 to match vip. default:4
   this.PORT_FORCE_OFF[link_idx].write(status_tmp,rdata);
 
   //enable msi
   $display("start to cfg msi for link_idx:%0d, @%t",link_idx,$time);
   this.PCI_MSI_CAP_ID_NEXT_CTRL_REG[link_idx].read(status_tmp,rdata);
   rdata[16] =  this.enable_msi[link_idx];//PCIE_MSI_ENABLE
   this.PCI_MSI_CAP_ID_NEXT_CTRL_REG[link_idx].write(status_tmp,rdata);

    //enable dpc,note: x16 dpc reg addr:40_018c, x4,x8 dpc reg //addr:40_017c,DON'T SUPPORT DPC
    //if (is_rc(device_type[link_idx])) begin//dut is rc
    //    $display("start to program dpc reg,addr:%0h for link_idx:%0d,@%t",this.DPC_CAP_CONTROL_OFF[link_idx].get_address(),link_idx,$time);
    //    this.DPC_CAP_CONTROL_OFF[link_idx].read(status_tmp,rdata);
    //    $display("show dpc reg write v:%0h,dpc_int_en[%0d]:%0h, @%t",rdata,link_idx,this.dpc_int_en[link_idx],$time);
    //    rdata[17:16] =  2'b10;//DPC trigger enable
    //    rdata[19]    =  this.dpc_int_en[link_idx];//dpc interrupt enable
    //    this.DPC_CAP_CONTROL_OFF[link_idx].write(status_tmp,rdata);
    //    this.DPC_CAP_CONTROL_OFF[link_idx].read(status_tmp,rdata);
    //    $display("show dpc reg read v:%0h for link_idx:%0d  @%t",rdata,link_idx,$time);
    //end

    //enable l0s:
    if (this.enable_aspm_l0s[link_idx] == 1'b1) begin
        $display("enable l0s for dut for link_idx:%0d @%t",link_idx,$time);
        this.LINK_CAPABILITIES_REG[link_idx].read(status_tmp,rdata);
        rdata[11:10]=2'h1;//enable aspm for l0s,disable l1 PCIE_CAP_ACTIVE_STATE_LINK_PM_SUPPORT
        this.LINK_CAPABILITIES_REG[link_idx].write(status_tmp,rdata);
    end

    if (is_rc(device_type[link_idx])) begin//dut is rc
	`uvm_info("LINK TRAINING",$sformatf("start to set BRIDGE_CTRL_INT_PIN_INT_LINE_REG (addr:%0h) for link_idx:%0d", this.BRIDGE_CTRL_INT_PIN_INT_LINE_REG[link_idx].get_address(),link_idx) ,UVM_LOW)
        //enable SERR# Enable
        $display("start to program bridge ctrl reg,addr:%0h,for link_idx:%0d,@%t",this.BRIDGE_CTRL_INT_PIN_INT_LINE_REG[link_idx].get_address(),link_idx,$time);
        this.BRIDGE_CTRL_INT_PIN_INT_LINE_REG[link_idx].read(status_tmp,rdata);
        rdata[17] = 1'b1;//SERR# ENABLE
        this.BRIDGE_CTRL_INT_PIN_INT_LINE_REG[link_idx].write(status_tmp,rdata);
        $display("finish bridge ctrl reg for link_idx:%0d @%t",link_idx,$time);
    end

   `uvm_info("LINK TRAINING",$sformatf("start to set  RASDP_ERROR_MODE_EN_OFF(addr:%0h) for link_idx:%0d", this.RASDP_ERROR_MODE_EN_OFF[link_idx].get_address(),link_idx) ,UVM_LOW)
   this.RASDP_ERROR_MODE_EN_OFF[link_idx].read(status_tmp,rdata);
   rdata[0] = 1'b0;//ERROR_MODE_EN,disable pcie controler parity checker for request from hnp axi trans(user)
   this.RASDP_ERROR_MODE_EN_OFF[link_idx].write(status_tmp,rdata);
   $display("finish RASDP_ERROR_MODE_EN_OFF for link_idx:%0d @%t",link_idx,$time);

   `uvm_info("LINK TRAINING",$sformatf("start to set  RASDP_ERROR_MODE_CLEAR_OFF(addr:%0h) for link_idx:%0d", this.RASDP_ERROR_MODE_CLEAR_OFF[link_idx].get_address(),link_idx) ,UVM_LOW)
   this.RASDP_ERROR_MODE_CLEAR_OFF[link_idx].read(status_tmp,rdata);
   rdata[0] = 1'b1;//ERROR_MODE_CLEAR,clear errors
   this.RASDP_ERROR_MODE_CLEAR_OFF[link_idx].write(status_tmp,rdata);
   $display("finish RASDP_ERROR_MODE_CLEAR_OFF for link_idx:%0d @%t",link_idx,$time);

   if (link_idx inside{2,3}) begin//disable IDE for x4_0,x4_1
       `uvm_info("LINK TRAINING",$sformatf("start to set  IDE_CTRL_OFF(addr:%0h) for link_idx:%0d", this.IDE_CTRL_OFF[link_idx].get_address(),link_idx) ,UVM_LOW)
       this.IDE_CTRL_OFF[link_idx].read(status_tmp,rdata);
       rdata[0] = 1'b1;//IDE_CTRL_DISABLE E
       this.IDE_CTRL_OFF[link_idx].write(status_tmp,rdata);
       $display("finish IDE_CTRL_OFF for link_idx:%0d @%t",link_idx,$time);
   end

   if (link_idx inside {0,1,2} && (link_mode == LINK_MODE_A)) begin
       `uvm_info("LINK TRAINING",$sformatf("start to set PHY_SHARED_PIPE_LANE_CTRL_00(addr:%0h) for link_idx:%0d", this.PHY_SHARED_PIPE_LANE_CTRL_00.get_address(),link_idx) ,UVM_LOW)
       this.PHY_SHARED_PIPE_LANE_CTRL_00.read(status_tmp,rdata);
       rdata[12:9]  = 4'h0;//pipe_lane0_lanepll_src_sel[3:0]
       rdata[29:26] = 4'h1;//pipe_lane1_lanepll_src_sel[3:0]
       this.PHY_SHARED_PIPE_LANE_CTRL_00.write(status_tmp,rdata);
       $display("finish  PHY_SHARED_PIPE_LANE_CTRL_00 for link_idx:%0d @%t",link_idx,$time);

       `uvm_info("LINK TRAINING",$sformatf("start to set PHY_SHARED_PIPE_LANE_CTRL_01(addr:%0h) for link_idx:%0d", this.PHY_SHARED_PIPE_LANE_CTRL_01.get_address(),link_idx) ,UVM_LOW)
       this.PHY_SHARED_PIPE_LANE_CTRL_01.read(status_tmp,rdata);
       rdata[15:12] = 4'h2;//pipe_lane2_lanepll_src_sel[3:0]
       this.PHY_SHARED_PIPE_LANE_CTRL_01.write(status_tmp,rdata);
       $display("finish  PHY_SHARED_PIPE_LANE_CTRL_01 for link_idx:%0d @%t",link_idx,$time);

       `uvm_info("LINK TRAINING",$sformatf("start to set PHY_SHARED_PIPE_LANE_CTRL_02(addr:%0h) for link_idx:%0d", this.PHY_SHARED_PIPE_LANE_CTRL_02.get_address(),link_idx) ,UVM_LOW)
       this.PHY_SHARED_PIPE_LANE_CTRL_02.read(status_tmp,rdata);
       rdata[3:0] = 4'h2;//pipe_lane3_lanepll_src_sel[3:0]
       this.PHY_SHARED_PIPE_LANE_CTRL_02.write(status_tmp,rdata);
       $display("finish  PHY_SHARED_PIPE_LANE_CTRL_02 for link_idx:%0d @%t",link_idx,$time);
   end

    if(1'b1==enable_phy_sram_init)begin
        //phy_sram_init();
    end

    //step4,release ltssm enable resetting
    fork
        begin
            `uvm_info("LINK_TRAINING",$sformatf("start to read CFGINFO_LEVEL[%0d]",link_idx),UVM_LOW)
            this.CFGINFO_LEVEL[link_idx].read(status_tmp, rdata);
            `uvm_info("LINK_TRAINING",$sformatf("finish read CFGINFO_LEVEL[%0d]:%0h",link_idx,rdata),UVM_LOW)
            rdata[6] = 1'b1;//app_ltssm_enable
            //rdata[19]= 1'b0;//release app_hold_phy_rst.
            this.CFGINFO_LEVEL[link_idx].write(status_tmp,rdata);
            `uvm_info("LINK_TRAINING",$sformatf("start to write CFGINFO_LEVEL[%0d]:%0h",link_idx,rdata),UVM_LOW)
            this.CFGINFO_LEVEL[link_idx].read(status_tmp,rdata) ;
            `uvm_info("LINK_TRAINING",$sformatf("finish read two twice for CFGINFO_LEVEL[%0d]:%0h",link_idx,rdata),UVM_LOW)
        end

        begin
            link_en_seq[link_idx].randomize with {enable == 1'b1;};
            if (is_rc(device_type[link_idx])) begin//dut is rc
                link_en_seq[link_idx].start(env.endpoint[link_idx].virt_seqr.pcie_virt_seqr.dl_seqr);
            end
            else if (is_rc(device_type[link_idx]) == 0) begin//dut is ep
                link_en_seq[link_idx].start(env.root[link_idx-2].virt_seqr.pcie_virt_seqr.dl_seqr);
            end
            else begin
                `uvm_fatal("LINK TRAINING",$sformatf("device_type[%0d]:%0h is illegal",link_idx,device_type[link_idx]))
            end
            `uvm_info("LINK TRAINING",$sformatf("have enabled the pcie vip for link_idx:%0d",link_idx) ,UVM_LOW)
        end
    join
    `uvm_info("LINK TRAINING",$sformatf("have enable rc and ep for link_idx:%0d",link_idx) ,UVM_LOW)

    //step5,wait link up.
    `uvm_info("LINK TRAINING",$sformatf("start to polling LINK_STATUS (addr:%0h) for linkup link_idx:%0d", this.LINK_STATUS[link_idx].get_address(),link_idx) ,UVM_LOW)
    fork
        begin//vip
            wait(dev_status.pcie_status.pl_status.link_up == 1'b1);
            `uvm_info("LINK TRAINING",$sformatf("link is up from pcie vip for link_idx:%0d",link_idx),UVM_LOW)
        end

        begin//dut
            while(1)begin
                LINK_STATUS[link_idx].read(status_tmp,rdata);
                if(rdata[1:0] == 2'h3) begin//smlh_link_up & rdlh_link_up
                    `uvm_info("LINK TRAINING",$sformatf("RC have reach to link up for link_idx:%0d",link_idx),UVM_LOW)
                     break;
                end
                #2000ns;
            end
        end
    join
    `uvm_info("LINK TRAINING",$sformatf("both RC and EP are link up for link_idx:%0d",link_idx),UVM_LOW)

    `uvm_info("LINK TRAINING",$sformatf("start to polling LINK_STATUS (addr:%0h) for ltssm link_idx:%0d", this.LINK_STATUS[link_idx].get_address(),link_idx) ,UVM_LOW)
    //step6,wait for L0
    fork
        begin//EP
            wait(dev_status.pcie_status.pl_status.ltssm_state == svt_pcie_types::L0);
            `uvm_info("LINK TRAINING",$sformatf("link reach to L0 form EP for link_idx:%0d",link_idx),UVM_LOW)
        end

        begin//rc
            while(1)begin
                this.LINK_STATUS[link_idx].read(status_tmp, rdata);
                if(rdata[7:2]==6'h11)begin
                     `uvm_info("LINK TRAINING",$sformatf("RC has reach to L0 for link_idx:%0d",link_idx),UVM_LOW)
                     break;
                end
                #200ns;
            end
        end
    join
    `uvm_info("LINK TRAINING",$sformatf("both RC and EP are in L0 for link_idx:%0d",link_idx) ,UVM_LOW)

    //step7,wait for gen4 speed
    `uvm_info("LINK TRAINING",$sformatf("start to polling LINK_CONTROL_LINK_STATUS_REG(addr:%0h) for link_idx:%0d", this.LINK_CONTROL_LINK_STATUS_REG[link_idx].get_address(),link_idx) ,UVM_LOW)
    while(1)begin
        this.LINK_CONTROL_LINK_STATUS_REG[link_idx].read(status_tmp,rdata) ;
        if(rdata[19:16]==exp_cur_link_speed)begin//speed is 16G, gen4.
            `uvm_info("LINK TRAINING",$sformatf("Rc have reach to gen%0d speed for link_idx:%0d",exp_cur_link_speed,link_idx),UVM_LOW)
            break;
        end
        #200ns;
    end

    while(1) begin
        this.LINK_STATUS[link_idx].read(status_tmp,rdata);
        if(rdata[7:2] == 6'h11)begin
            `uvm_info("LINK TRAINING",$sformatf("Rc have reach to L0 again after geting exp rate for link_idx:%0d",link_idx),UVM_LOW)
            break;
        end
        #200ns;
    end

    `uvm_info("LINK TRAINING",$sformatf("start to set STATUS_COMMAND_REG (addr:%0h) for link_idx:%0d", this.STATUS_COMMAND_REG[link_idx].get_address(),link_idx) ,UVM_LOW)
    //enable io,mse, bme
    this.STATUS_COMMAND_REG[link_idx].read(status_tmp,rdata);
    rdata[0]=1'b1;//I/O space enable
    rdata[1]=1'b1;//mem space enable
    rdata[2]=1'b1;//bus master enable
    this.STATUS_COMMAND_REG[link_idx].write(status_tmp,rdata) ;

    `uvm_info("LINK TRAINING",$sformatf("start to set  DEVICE_CAPABILITIES_REG(addr:%0h) for link_idx:%0d", this.DEVICE_CAPABILITIES_REG[link_idx].get_address(),link_idx) ,UVM_LOW)
    //set maxpayloadsize to 512bytes.
    this.DEVICE_CAPABILITIES_REG[link_idx].read(status_tmp,rdata);
    $display("show PCIE CAP MAX PAYLOAD SIZE:%0h for link_idx:%0d @%t",rdata[2:0],link_idx,$time);
    this.DEVICE_CONTROL_DEVICE_STATUS[link_idx].read(status_tmp,rdata);
    $display("show PCIE CAP MAX PAYLOAD SIZE CS:%0h for link_idx:%0d @%t",rdata[7:5],link_idx,$time);
    //rdata[7:5]=3'h2;//512bytes
    rdata[7:5]=3'h5;//4096byte max payload size
    this.DEVICE_CONTROL_DEVICE_STATUS[link_idx].write(status_tmp,rdata);

    `uvm_info("LINK TRAINING",$sformatf("initial traning is finished for link_idx:%0d",link_idx),UVM_LOW)
endtask:link_training

task pcie_subsys_base_test::set_mem_io_base_limit(int link_idx);
    logic[31:0]   rdata;
    logic[31:0]   wdata;
    uvm_status_e  status_tmp; 

    //cfg mem base and mem limit from cfg space
    if (is_rc(device_type[link_idx])) begin//dut is rc
        $display("start mem base and limit setting for rc MEM_LIMIT_MEM_BASE_REG(addr:%0h) for link_idx:%0d @%t",this.MEM_LIMIT_MEM_BASE_REG[link_idx].get_address(),link_idx,$time);
        this.MEM_LIMIT_MEM_BASE_REG[link_idx].read(status_tmp,rdata);
        rdata[15:4] = 12'h0;//mem base
        rdata[31:20]= 12'hfff;//mem limit,addr range:32'h0-32'hffff_ffff;
        this.MEM_LIMIT_MEM_BASE_REG[link_idx].write(status_tmp,rdata);

	$display("start pre mem base and limit setting for rc PREF_MEM_LIMIT_PREF_MEM_BASE_REG(addr:%0h) for link_idx:%0d @%t",this.PREF_MEM_LIMIT_PREF_MEM_BASE_REG[link_idx].get_address(),link_idx,$time);
        this.PREF_MEM_LIMIT_PREF_MEM_BASE_REG[link_idx].read(status_tmp,rdata);
        rdata[15:4] = 12'h0;//mem base
        rdata[31:20]= 12'h0;//mem limit,addr range:64'h0-64'hffff_ffff_ffff_ffff;
        this.PREF_MEM_LIMIT_PREF_MEM_BASE_REG[link_idx].write(status_tmp,rdata);

	$display("start pre mem upper base and limit setting for rc PREF_BASE_UPPER_REG(addr:%0h),PREF_LIMIT_UPPER_REG(addr:%0h) for link_idx:%0d @%t",this.PREF_BASE_UPPER_REG[link_idx].get_address(),this.PREF_LIMIT_UPPER_REG[link_idx].get_address(),link_idx,$time);
        this.PREF_BASE_UPPER_REG[link_idx].write(status_tmp,32'h0);
        this.PREF_LIMIT_UPPER_REG[link_idx].write(status_tmp,32'hffff_ffff);


        $display("start mem base and limit setting for rc SEC_STAT_IO_LIMIT_IO_BASE_REG(addr:%0h) for link_idx:%0d @%t",this.SEC_STAT_IO_LIMIT_IO_BASE_REG[link_idx].get_address(),link_idx,$time);
        this.SEC_STAT_IO_LIMIT_IO_BASE_REG[link_idx].read(status_tmp,rdata);
        rdata[7:4]  =4'h0;//io base
        rdata[15:12]=4'h0;//io limit,addr range:16'h0-16'hfff;
        this.SEC_STAT_IO_LIMIT_IO_BASE_REG[link_idx].write(status_tmp,rdata);
        $display("finish mem base and limit setting for rc for link_idx:%0d @%t",link_idx,$time);
    end
    else begin
        $display("no mem base and limit setting for ep for link_idx:%0d  @%t",link_idx,$time);
    end
endtask:set_mem_io_base_limit

//the min region size is 64kB
//the addr range:64'h0~64'hffff;
task pcie_subsys_base_test::set_atu_for_mem_req(int link_idx);
    logic[31:0]         rdata;
    logic[31:0]         wdata ;
    uvm_status_e        status_tmp;
    bit[63:0]           addr_tmp;

    addr_tmp = {16'h0,non_ecam_dbi_addr[link_idx][47:24],mem_addr_base[23:0]};
    //set region0  for mem request
    //base_addr is 0
    $display("start to program AUT reg,addr:%0h for link_idx:%0d @%t",this.IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[link_idx].get_address(),link_idx,$time);
    this.IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[link_idx].read(status_tmp,rdata);
    rdata=0;//the min space grant is 64k
    rdata=addr_tmp[31:0];
    this.IATU_LWR_BASE_ADDR_OFF_OUTBOUND_0[link_idx].write(status_tmp,rdata);

    this.IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0[link_idx].read(status_tmp,rdata);
    //rdata =0;
    rdata = addr_tmp[63:32];
    this.IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_0[link_idx].write(status_tmp,rdata);

    //the addr range:64'h-64'hffff;
    this.IATU_LIMIT_ADDR_OFF_OUTBOUND_0[link_idx].read(status_tmp,rdata);
    //rdata =0;
    rdata =mem_addr_limit[31:0];
    this.IATU_LIMIT_ADDR_OFF_OUTBOUND_0[link_idx].write(status_tmp,rdata);

    //set targer address:0
    this.IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0[link_idx].read(status_tmp,rdata);
    //rdata = 0;
    rdata = addr_tmp[31:0];
    this.IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_0[link_idx].write(status_tmp,rdata);

    this.IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0[link_idx].read(status_tmp,rdata);
    //rdata =0;
    rdata =addr_tmp[63:32];
    this.IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_0[link_idx].write(status_tmp,rdata);

    //set region control1
    this.IATU_REGION_CTRL_1_OFF_OUTBOUND_0[link_idx].read(status_tmp,rdata);
    rdata[4:0]=0;
    this.IATU_REGION_CTRL_1_OFF_OUTBOUND_0[link_idx].write(status_tmp,rdata);

    //enable the region
    this.IATU_REGION_CTRL_2_OFF_OUTBOUND_0[link_idx].read(status_tmp,rdata);
    rdata[31]= 1'b1;
    if(1'b1==enable_np_serial)begin
        rdata[20]= 1'b1;
    end
    this.IATU_REGION_CTRL_2_OFF_OUTBOUND_0[link_idx].write(status_tmp,rdata);

    $display("finish iatu region 0 setting for link_idx:%0d  @%t",link_idx,$time);
endtask:set_atu_for_mem_req

//the addr range:64'h10000-64'h1 ffff;
task pcie_subsys_base_test::set_atu_for_io_req(int link_idx);
    logic[31:0]   rdata;
    logic[31:0]   wdata;
    uvm_status_e  status_tmp;
    bit[63:0]           addr_tmp;

    addr_tmp = {16'h0,non_ecam_dbi_addr[link_idx][47:24],io_addr_base[23:0]};

    //set region 1 for io request
    //base_addr is 0
    this.IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1[link_idx].read(status_tmp,rdata);
    //rdata =32'h10000;//the min space grant is 64k
    rdata =addr_tmp[31:0];
    this.IATU_LWR_BASE_ADDR_OFF_OUTBOUND_1[link_idx].write(status_tmp,rdata);

    this.IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1[link_idx].read(status_tmp,rdata);
    //rdata = 0;
    rdata = addr_tmp[63:32];
    this.IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_1[link_idx].write(status_tmp,rdata);

    //the addr range:64'h0-64'hfff;
    this.IATU_LIMIT_ADDR_OFF_OUTBOUND_1[link_idx].read(status_tmp,rdata);
    //rdata = 32'h1_ffff;
    rdata = io_addr_limit[31:0];
    this.IATU_LIMIT_ADDR_OFF_OUTBOUND_1[link_idx].write(status_tmp,rdata);

    //set targer address:0
    this.IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1[link_idx].read(status_tmp,rdata) ;
    //rdata =0;
    rdata =addr_tmp[31:0];
    this.IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_1[link_idx].write(status_tmp,rdata);

    this.IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1[link_idx].read(status_tmp,rdata);
    //rdata =0;
    rdata =addr_tmp[63:32];
    this.IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_1[link_idx].write(status_tmp,rdata);

    //set region control 1
    this.IATU_REGION_CTRL_1_OFF_OUTBOUND_1[link_idx].read(status_tmp,rdata) ;
    rdata[4:0]=5'h2;//I0
    this.IATU_REGION_CTRL_1_OFF_OUTBOUND_1[link_idx].write(status_tmp,rdata);

    //enable the region
    this.IATU_REGION_CTRL_2_OFF_OUTBOUND_1[link_idx].read(status_tmp,rdata);
    rdata[31]= 1'b1;
    this.IATU_REGION_CTRL_2_OFF_OUTBOUND_1[link_idx].write(status_tmp,rdata);

    $display("finish iatu region setting for io req link_idx:%0d ",link_idx,$time);
endtask:set_atu_for_io_req

//addr:64'h2 0000-64'h2 ffff;
task pcie_subsys_base_test::set_atu_for_cfg0_req(int link_idx);
    logic[31:0]   rdata;
    logic[31:0]   wdata;
    uvm_status_e  status_tmp;
    bit[63:0]           addr_tmp;

    addr_tmp = {16'h0,non_ecam_dbi_addr[link_idx][47:24],cfg0_addr_base[23:0]};

    //set region 2 for cfgo request
    //base_addr is 0
    this.IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2[link_idx].read(status_tmp,rdata);
    //rdata=32'h2_0000;//the min space grant is 64k
    rdata=addr_tmp[31:0];
    this.IATU_LWR_BASE_ADDR_OFF_OUTBOUND_2[link_idx].write(status_tmp,rdata);

    this.IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2[link_idx].read(status_tmp,rdata);
    //rdata =0;
    rdata =addr_tmp[63:32];
    this.IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_2[link_idx].write(status_tmp,rdata);

    this.IATU_LIMIT_ADDR_OFF_OUTBOUND_2[link_idx].read(status_tmp,rdata) ;
    //rdata = 32'h2_ffff;
    rdata = cfg0_addr_limit[31:0];
    this.IATU_LIMIT_ADDR_OFF_OUTBOUND_2[link_idx].write(status_tmp,rdata);

    //set targer address:0
    this.IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2[link_idx].read(status_tmp,rdata) ;
    //rdata =0;
    rdata = addr_tmp[31:0];
    this.IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_2[link_idx].write(status_tmp,rdata);

    this.IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2[link_idx].read(status_tmp,rdata);
    //rdata = 0;
    rdata = addr_tmp[63:32];
    this.IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_2[link_idx].write(status_tmp,rdata);

    //set region control 1
    this.IATU_REGION_CTRL_1_OFF_OUTBOUND_2[link_idx].read(status_tmp,rdata);
    rdata[4:0]=5'h4;//cfq0
    this.IATU_REGION_CTRL_1_OFF_OUTBOUND_2[link_idx].write(status_tmp,rdata);

    //enable the region
    this.IATU_REGION_CTRL_2_OFF_OUTBOUND_2[link_idx].read(status_tmp,rdata);
    rdata[31]= 1'b1;
    this.IATU_REGION_CTRL_2_OFF_OUTBOUND_2[link_idx].write(status_tmp,rdata);

    $display("finish iatu region setting for cfg0 req for link_idx:%0d @t",link_idx,$time);
endtask:set_atu_for_cfg0_req

//addr:64'h3 0000-64'h3 ffff:
task pcie_subsys_base_test::set_atu_for_cfg1_req(int link_idx);
    logic[31:0]  rdata;
    logic[31:0]  wdata;
    uvm_status_e status_tmp;
    bit[63:0]           addr_tmp;

    addr_tmp = {16'h0,non_ecam_dbi_addr[link_idx][47:24],cfg1_addr_base[23:0]};

    //set region 3 for cfge request
    //base_addr is @
    this.IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3[link_idx].read(status_tmp,rdata);
    //rdata=32'h3_0000;//the min space grant is 64k
    rdata = addr_tmp[31:0];
    this.IATU_LWR_BASE_ADDR_OFF_OUTBOUND_3[link_idx].write(status_tmp,rdata);

    this.IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3[link_idx].read(status_tmp,rdata) ;
    //rdata = 0;
    rdata = addr_tmp[64:0];
    this.IATU_UPPER_BASE_ADDR_OFF_OUTBOUND_3[link_idx].write(status_tmp,rdata);

    this.IATU_LIMIT_ADDR_OFF_OUTBOUND_3[link_idx].read(status_tmp,rdata);
    //rdata = 32'h3_ffff;
    rdata = cfg1_addr_limit[31:0];
    this.IATU_LIMIT_ADDR_OFF_OUTBOUND_3[link_idx].write(status_tmp,rdata);

    //set targer address:0
    this.IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3[link_idx].read(status_tmp,rdata);
    //rdata = 0;
    rdata = addr_tmp[31:0];
    this.IATU_LWR_TARGET_ADDR_OFF_OUTBOUND_3[link_idx].write(status_tmp,rdata);

    this.IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3[link_idx].read(status_tmp,rdata);
    //rdata =0;
    rdata =addr_tmp[63:32];
    this.IATU_UPPER_TARGET_ADDR_OFF_OUTBOUND_3[link_idx].write(status_tmp,rdata);

    //set region control1
    this.IATU_REGION_CTRL_1_OFF_OUTBOUND_3[link_idx].read(status_tmp,rdata);
    rdata[4:0]=5'h5;//cfq1
    this.IATU_REGION_CTRL_1_OFF_OUTBOUND_3[link_idx].write(status_tmp,rdata);

    //enable the region
    this.IATU_REGION_CTRL_2_OFF_OUTBOUND_3[link_idx].read(status_tmp,rdata);
    rdata[31]= 1'b1;
    this.IATU_REGION_CTRL_2_OFF_OUTBOUND_3[link_idx].write(status_tmp,rdata);

    $display("finish iatu region 3 setting for cfg1 req for link_idx:%0d @%t",link_idx,$time);
endtask:set_atu_for_cfg1_req

task pcie_subsys_base_test::gen_inbound_outboud_trans(int link_idx);
    axi_master_rand_sequence                  axi_dir_seq;
    pcie_driver_transaction_rand_sequence     directed_req_seq;
    bit [47:0]                                mem_addr;
    bit [47:0]                                mem_base;
    bit [47:0]                                mem_limit;
    bit [63:0]                                pcie_mem_addr;
    bit [31:0]                                rdata;

    fork
        begin//axi->pcie x1 or x2 or x4_0 or x4_1
	     mem_base = {non_ecam_dbi_addr[link_idx][47:24],mem_addr_base[23:0]};
	     mem_limit = {non_ecam_dbi_addr[link_idx][47:24],mem_addr_limit[23:0]};
             //std::randomize(mem_addr)with {mem_addr>=hnp_addr_base[link_idx];mem_addr<=(hnp_addr_base[link_idx]+hnp_addr_range[link_idx]);mem_addr[47:28]!=cfg_ecam_base_hi20;};//TODO
             std::randomize(mem_addr)with {mem_addr>=mem_base;mem_addr<=mem_limit;};
             $display("full wstrb mem_addr:%0h,mem_base:%0h,mem_limit:%0h,non_ecam_dbi_addr[47:24]:%0h,mem_addr_base[23:0]:%0h,mem_addr_limit[23:0]:%0h for link_idx:%0d  @%t",mem_addr,mem_base,mem_limit,non_ecam_dbi_addr[link_idx][47:24],mem_addr_base[23:0],mem_addr_limit[23:0],link_idx,$time);
             axi_dir_seq = axi_master_rand_sequence::type_id::create("axi_dir_seq",this);
             axi_dir_seq.local_addr = mem_addr;
             axi_dir_seq.sequence_length=1;
             axi_dir_seq.start(env.axi_system_env.sequencer.master_sequencer[1]);//mater1 for trans
             $display("finish full wstrb mem request test for link_idx:%0d  @%t",link_idx,$time);
        end

        begin
            std::randomize(pcie_mem_addr) with {pcie_mem_addr inside {[64'hffff_ffff_fff0_0000:64'hffff_ffff_ffff_ffff]};};
            pcie_mem_addr[1:0]= 2'h0;
            $display("show pcie_mem_addr:%0h for link_idx:%0d,@%t",pcie_mem_addr,link_idx,$time);
            directed_req_seq = pcie_driver_transaction_rand_sequence::type_id::create("directed_req_seq",this);
            directed_req_seq.local_addr = pcie_mem_addr;
            //directed_req_seq.local_len= 1000;
            //directed_req_seq.local_first_dw_be = 4'b1111:
            //directed_req_seq.local_last_dw_be  = 4'b1111;
            directed_req_seq.is_mem = 1'b1;
            if (is_rc(device_type[link_idx])) begin//dut is rc
                directed_req_seq.start(env.endpoint[link_idx].virt_seqr.driver_transaction_seqr[0]);
            end
            else if (is_rc(device_type[link_idx]) == 0) begin//dut is ep
                $display("start to read all bars value for ep @%t",$time);
                write_cfg_reg(4,32'hffffffff,link_idx);//bar0
                read_cfg_reg(4,rdata,link_idx);
                $display("EP BAR0:%0h for link_idx:%0d @%t",rdata,link_idx,$time);

                write_cfg_reg(5,32'hffffffff,link_idx);//bar1
                read_cfg_reg(5,rdata,link_idx);
                $display("EP BAR1:%0h for link_idx:%0d @%t",rdata,link_idx,$time);

                write_cfg_reg(6,32'hffffffff,link_idx);//bar2
                read_cfg_reg(6,rdata,link_idx);
                $display("EP BAR2:%0h for link_idx:%0d @%t",rdata,link_idx,$time);

                write_cfg_reg(7,32'hffffffff,link_idx);//bar3
                read_cfg_reg(7,rdata,link_idx);
                $display("EP BAR3:%0h for link_idx:%0d @%t",rdata,link_idx,$time);

                write_cfg_reg(8,32'hffffffff,link_idx);//bar4
                read_cfg_reg(8,rdata,link_idx);
                $display("EP BAR4:%0h for link_idx:%0d @%t",rdata,link_idx,$time);

                write_cfg_reg(9,32'hffffffff,link_idx);//bar5
                read_cfg_reg(9,rdata,link_idx);
                $display("EP BAR5:%0h for link_idx:%0d @%t",rdata,link_idx,$time);

               $display("finish to read all bars value for ep for link_idx:%0d @%t",link_idx,$time);
                directed_req_seq.start(env.root[link_idx-2].virt_seqr.driver_transaction_seqr[0]);
            end
            
            $display("finish directed_req_seq for link_idx:%0d @%t",link_idx,$time);
        end
    join
endtask:gen_inbound_outboud_trans

task pcie_subsys_base_test::write_reg(input bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, input bit[31:0] wdata,int aximst_id=0);//0:cust register,1: controler register, other:illegal
    axi_reg_wr_seq wr_seq;

    wr_seq =axi_reg_wr_seq::type_id::create("wr_seq",this);
    wr_seq.reg_addr  = addr;
    wr_seq.reg_wdata = wdata;
    wr_seq.start(env.axi_system_env.master[aximst_id].sequencer);
endtask:write_reg

task pcie_subsys_base_test::read_reg(input bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, output bit[31:0] rdata,int aximst_id=0);
    axi_reg_rd_seq rd_seq;

    rd_seq = axi_reg_rd_seq::type_id::create("rd_seq",this);
    rd_seq.reg_addr = addr;
    rd_seq.start(env.axi_system_env.master[aximst_id].sequencer);
    rdata =rd_seq.reg_rdata;
endtask:read_reg

task pcie_subsys_base_test::write_phy(input bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, input bit[31:0] wdata,int aximst_id=0);//TODO
    bit[31:0]  addr_h;
    bit[31:0]  addr_l;
    bit[31:0]  addr_tmp;

    addr_h =0;
    addr_l =0;

    addr_h[31:20] = addr[31:20];
    addr_l[19:2]  = addr[17:0];
    addr_tmp      = addr_h + addr_l;

    write_reg(addr_tmp,wdata,aximst_id);
endtask:write_phy

task pcie_subsys_base_test::read_phy(input bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, output bit[31:0] rdata,int aximst_id=0);//TODO
    bit[31:0] addr_h;
    bit[31:0] addr_l;
    bit[31:0] addr_tmp;

    addr_h=0;
    addr_l=0;

    addr_h[31:20] = addr[31:20];
    addr_l[19:2]  = addr[17:0];
    addr_tmp      = addr_h + addr_l;

    read_reg(addr_tmp,rdata,aximst_id);
endtask:read_phy

//task pcie_subsys_base_test::phy_sram_init();
//    bit[31:0] rdata;
//    bit[31:0] wdata;
//    uvm_status_e status_tmp;
//    int ind;
//
//    string file_w;
//    integer fw;
//
//    //check pcs bootloader initial sram done
//    while(1)begin
//        #1000ns;
//        env.regmodel.DWC_CUSTOMER_SUB.DWC_SS_X16.sram_status.read(status_tmp, rdata);
//        if(rdata[3:0]== 4'hf)begin
//            `uvm_info("SRAM_TEST",$sformatf("phy0,1,2,3 sram init done,rdata:%0h",rdata),UVM_LOW)
//            break;
//        end
//        else begin
//            `uvm_info("SRAM_TEST",$sformatf("waiting sram init done,rdata:%0h",rdata),UVM_LOW)
//        end
//    end
//    $display("finish sram init done check @%t",$time);
//
//    get_phy_para_from_file();
//
//    //update sram from user
//    for(int i=0;i<32768;i++)begin
//    //for(int i=0;i<16384;i++)begin
//    //for(int i=0;i<21056;i++)begin
//        ind=(i>=16384)?(i-16384):i;
//        if(i==16384)begin//just write once
//            enable_16k_sram_h(`PHY0_ADDR);
//            enable_16k_sram_h(`PHY1_ADDR);
//            enable_16k_sram_h(`PHY2_ADDR);
//            enable_16k_sram_h(`PHY3_ADDR);
//        end
//        write_phy(`PHY0_ADDR + `SRAM_BASE + ind,memory[i]);
//        write_phy(`PHY1_ADDR + `SRAM_BASE + ind,memory[i]);
//        write_phy(`PHY2_ADDR + `SRAM_BASE + ind,memory[i]);
//        write_phy(`PHY3_ADDR + `SRAM_BASE + ind,memory[i]);
//    end
//    $display("finish sram init done check @%t",$time);
//
//    //finish updating done by setting ld done reg and check inner done signal
//    fork
//        begin//setting ld done reg
//            env.regmodel.DWC_CUSTOMER_SUB.DWC_SS_X16.sram_control.read(status_tmp,rdata);
//            rdata[0] = 1'b1;//phy0 ext ld done
//            rdata[2] = 1'b1;//phyl ext ld done
//            rdata[4] = 1'b1;//phy2 ext ld done
//            rdata[6] = 1'b1;//phy3 ext ld done
//            env.regmodel.DWC_CUSTOMER_SUB.DWC_SS_X16.sram_control.write(status_tmp, rdata);
//            $display("finish updating ext ld done cfg @%t",$time);
//        end
//
//        begin //TODO???
//            //@(posedge `DUT_PATH.u_phy.phy0.sram_ext_ld_done);
//            `uvm_info("SRAM_TEST","receive sram_ext_ld_done for phy0",UVM_LOW)
//        end
//
//        begin
//            //@(posedge `DUT_PATH.u_phy.phyl.sram_ext_ld_done);
//            `uvm_info("SRAM_TEST","receive sram_ext_ld_done for phy1",UVM_LOW)
//        end
//
//        begin
//            //@(posedge `DUT_PATH.u_phy.phy2.sram_ext_ld_done);
//            `uvm_info("SRAM_TEST","receive sram_ext_ld_done for phy2" ,UVM_LOW)
//        end
//
//        begin
//            //@(posedge `DUT_PATH.u_phy.phy3.sram_ext_ld_done);
//            `uvm_info("SRAM_TEST","receive sram_ext_ld_done for phy3" ,UVM_LOW)
//        end
//    join//finish updating done by setting ld done reg and check inner done signal
//
//   fw = $fopen("./cpu_init.txt","w");
//    for(int i=0;i<16384;i++)begin//TODO??
//        //$fwrite(fw,"%6h\n",`DUT_PATH.phy0_sram_if_0.u_mem.ram_core[i]);
//    end
//    for (int i=0;i<16384;i++)begin
//        //$fwrite(fw,"%6h\n",`DUT_PATH.phy0_sram_if_1.u_mem.ram_core[i]);
//    end
//    $fclose(fw);
//
//    fw = $fopen("./cpu_init_16bit.txt","w");
//    for (int i=0;i<16384;i++) begin
//        //$fwrite(fw,"%4h\n",`DUT_PATH.phy0_sram_if_0.u_mem.ram_core[i][15:0]);
//    end
//    for(int i=0;i<16384;i++)begin
//        //$fwrite(fw,"%4h\n",`DUT_PATH.phy0_sram_if_1.u_mem.ram_core[i][15:0]);
//    end
//    $fclose(fw);
//
//    $display("finish setting sram_ext_ld_done @%t",$time);
//
//    #100us;
//endtask:phy_sram_init
//
//
//task pcie_subsys_base_test::enable_sram_ld_fl();
//    bit[31:0]    rdata;
//    bit[31:0]    wdata;
//    uvm_status_e status_tmp;
//
//    //enable sram load feature
//    env.regmodel.DWC_CUSTOMER_SUB.DWC_SS_X16.sram_control.read(status_tmp,rdata);
//    rdata[1]=1'b0;//phy0 sram bypass
//    rdata[3]=1'b0;//phy1 sram bypass
//    rdata[5]=1'b0;//phy2 sram bypass
//    rdata[7]=1'b0;//phy3 sram bypass
//    env.regmodel.DWC_CUSTOMER_SUB.DWC_SS_X16.sram_control.write(status_tmp,rdata);
//
//    $display("finish sram cfg @%t",$time);
//endtask:enable_sram_ld_fl
//
//function void pcie_subsys_base_test::get_phy_para_from_file();
//    string file_path;
//    string file_w;
//    integer fw;
//
//    file_path ={getenv("PCIE_PROJ_ROOT"),"/pcie/dv/tests/sram_vaule.txt"};
//    $display("show file_path:%s",file_path);
//    $readmemh(file_path,memory);
//    for(int i=0;i<10;i++)begin
//        $display("show memory[%0d]:%h",i,memory[i]);
//    end
//
//    fw = $fopen("./pcw_raw_init.txt","w");
//    for(int i=0;i<16384;i++) begin//TODO??
//        //$fwrite(fw,"%6h\n",`DUT_PATH.phy0_sram_if_0.u_mem.ram_core[i]);
//    end
//    for(int i=0;i<16384;i++)begin
//        //$fwrite(fw,"%6h\n",`DUT_PATH.phy0_sram_if_1.u_mem.ram_core[i]);
//    end
//    $fclose(fw);
//
//    fw = $fopen("./pcw_raw_init_l6bit.txt","w");
//    for (int i=0;i<16384;i++)begin
//        //$fwrite(fw,"%4h\n",`DUT_PATH.phy0_sram_if_0.u_mem.ram_core[i][15:0]);
//    end
//    for(int i=0;i<16384;i++)begin
//        //$fwrite(fw,"%4h\n",`DUT_PATH.phy0_sram_if_1.u_mem.ram_core[i][15:0]);
//    end
//    $fclose(fw);
//endfunction:get_phy_para_from_file
//
//task pcie_subsys_base_test::enable_16k_sram_h(bit[31:0] base_addr);
//    bit[31:0] reg_addr;
//    bit[31:0] data;
//
//    reg_addr= base_addr + `RAWCMN_DIG_LANE_FSM_OP_XTND;
//    read_phy(reg_addr,data);
//    data[1]=1'b1;//MEM_ADDR_EXT_EN
//    write_phy(reg_addr,data);
//endtask:enable_16k_sram_h
//
//task pcie_subsys_base_test::disable_16k_sram_h(bit[31:0] base_addr);
//    bit[31:0] reg_addr;
//    bit[31:0] data;
//
//    reg_addr=base_addr+`RAWCMN_DIG_LANE_FSM_OP_XTND;
//    read_phy(reg_addr,data);
//    data[1]=1'b0;//MEM ADDR EXT EN
//    write_phy(reg_addr,data);
//endtask:disable_16k_sram_h

task pcie_subsys_base_test::doSpeedChange(bit[3:0] target_link_speed,int link_idx);
    bit[3:0]         exp_cur_link_speed;
    logic[31:0]      rdata;
    logic[31:0]      wdata;
    uvm_status_e     status_tmp;

    exp_cur_link_speed = target_link_speed;//the max speed is gen2.
    this.LINK_CONTROL2_LINK_STATUS2_REG[link_idx].read(status_tmp,rdata);
    $display("once read value,LINK_CONTROL2_LINK_STATUS2_REG:%0h for link_idx:%0d @%t",rdata,link_idx,$time);
    rdata[3:0]=target_link_speed;//set target_link_speed
    this.LINK_CONTROL2_LINK_STATUS2_REG[link_idx].write(status_tmp,rdata);

    this.LINK_CONTROL_LINK_STATUS_REG[link_idx].read(status_tmp,rdata);
    rdata[5]=1'b1;//PCIE_CAP_RETRAIN_LINK
    this.LINK_CONTROL_LINK_STATUS_REG[link_idx].write(status_tmp,rdata);
    #500;

    while(1)  begin
        this.LINK_STATUS[link_idx].read(status_tmp, rdata);
        if(rdata[7:2]==6'h11)begin
            `uvm_info("LINK TRAINING",$sformatf("RC have reach to link up for link_idx:%0d",link_idx),UVM_LOW)
            break;
        end
        #2000ns;
    end

    this.LINK_CONTROL_LINK_STATUS_REG[link_idx].read(status_tmp,rdata);
    if(rdata[19:16]!=exp_cur_link_speed)begin
        `uvm_error("LINK TRAINING",$sformatf("speed is not in expected. act:%0d,exp:%0d for link_idx:%0d",rdata[19:16],exp_cur_link_speed,link_idx))
    end
endtask:doSpeedChange

task pcie_subsys_base_test::write_cfg_reg(input bit[9:0] reg_num, input bit[31:0] wdata,input int link_idx);//link_idx must 2,3,2:x4_0,3:x4_1
    svt_pcie_driver_app_cfg_request_sequence  cfg_seq;

    cfg_seq = svt_pcie_driver_app_cfg_request_sequence::type_id::create("cfg_seq",this);
    cfg_seq.bdf              = 0;
    cfg_seq.register_number  = reg_num;
    cfg_seq.transaction_type = svt_pcie_driver_app_transaction::CFG_WR;
    cfg_seq.first_dw_be      = 4'hf;
    cfg_seq.block            = 1;
    cfg_seq.payload          = wdata;
    $display("start write cfg space reg:0x%0h,wdata:%0h for link_idx:%0d @%t",reg_num,wdata,link_idx,$time);
    cfg_seq.start(env.root[link_idx-2].virt_seqr.driver_transaction_seqr[0]);
    $display("finish write cfg space reg:0x%0h,wdata:%0h for link_idx:%0d @%t",reg_num,wdata,link_idx,$time);
endtask:write_cfg_reg

task pcie_subsys_base_test::read_cfg_reg(input bit[9:0] reg_num, output bit[31:0] rdata,input int link_idx);//link_idx must 2,3,2:x4_0,3:x4_1
    svt_pcie_driver_app_cfg_request_sequence  cfg_seq;

    cfg_seq = svt_pcie_driver_app_cfg_request_sequence::type_id::create("cfg_seq",this);
    cfg_seq.bdf              = 0;
    cfg_seq.register_number  = reg_num;
    cfg_seq.transaction_type = svt_pcie_driver_app_transaction::CFG_RD;
    cfg_seq.first_dw_be      = 4'hf;
    cfg_seq.block            = 1;
    $display("start read cfg space reg:0x%0h for link_idx:%0d @%t",reg_num,link_idx,$time);
    cfg_seq.start(env.root[link_idx-2].virt_seqr.driver_transaction_seqr[0]);
    rdata = cfg_seq.req.payload[0];
    $display("finish read cfg space reg:0x%0h,rdata:%0h for link_idx:%0d @%t",reg_num,rdata,link_idx,$time);
endtask:read_cfg_reg

function bit pcie_subsys_base_test::is_rc(bit[3:0] dev_type);
	//if (dev_type inside {'h0,'h5}) begin//ep
	if (dev_type inside {'h0}) begin//ep
	    return 0;
	end
	//else if (dev_type inside {'h4,'h6}) begin//rc
	else if (dev_type inside {'h4}) begin//rc
	    return 1;
	end
	else begin
            `uvm_fatal(get_full_name,$sformatf("dev_type:%0h is illegal",dev_type))
	end
endfunction:is_rc

task pcie_subsys_base_test::exec_training_and_trans(int link_idx);

    $display("start link training for link_idx:%0d @%t",link_idx,$time);
    link_training(link_idx);
    $display("finish link training for link_idx:%0d @%t",link_idx,$time);
    set_mem_io_base_limit(link_idx);
    $display("finish set_mem_io_base_limit for link_idx:%0d @%t",link_idx,$time);
    set_atu_for_mem_req(link_idx);
    $display("finish set_atu_for_mem_req for link_idx:%0d @%t",link_idx,$time);
    gen_inbound_outboud_trans(link_idx);
    $display("finish test for link_idx:%0d @%t",link_idx,$time);
endtask:exec_training_and_trans

`endif//GUARD_PCIE_SUBSYS_BASE_TEST_SV
