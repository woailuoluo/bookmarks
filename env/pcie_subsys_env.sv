`ifndef GUARD_PCIE_SUBSYS_ENV_SV
    `define GUARD_PCIE_SUBSYS_ENV_SV
class pcie_subsys_env extends uvm_env;

    svt_pcie_device_agent root[2];//0:spd_3 x4_0,1:spd_5  x4_1
    svt_pcie_device_agent endpoint[4];//0:spd_0 x1,1:spd_1 x2,2:spd_2 x4_0,3:spd_4 x4_1

    svt_pcie_device_system_virtual_sequencer sys_virt_seqr;


    svt_pcie_device_status root_status[2];
    svt_pcie_device_status endpoint_status[4];

    pcie_err_catcher err_catcher;

    svt_pcie_device_configuration root_cfg[2];
    svt_pcie_device_configuration endpoint_cfg[4];

    bit enable_passive_monitor = 1'b0;
    bit enable_pcie_scb        = 1'b0;

    bit bypass_eq[4]              = {1'b1,1'b1,1'b1,1'b1};//0:x1,1:x2,2:x4_1,3:x4_2
    MY_PCIE_SPEED_e my_speed[4]   = {GEN2_MY,GEN2_MY,GEN2_MY,GEN2_MY};

    bit enable_aspm_l0s[4]        = {1'b0,1'b0,1'b0,1'b0};
    bit enable_aspm_l1[4]         = {1'b0,1'b0,1'b0,1'b0};
    bit enable_aspm_l1sub[4]      = {1'b0,1'b0,1'b0,1'b0};

   //for axi
    svt_axi_system_env         axi_system_env;
    axi_virtual_sequencer      sequencer;
    cust_svt_axi_system_configuration cfg;

    pcie_regmodel_noc regacc_noc;
    pcie_regmodel_hnp regacc_hnp;

    bit[3:0] device_type[4] =  {4'h4,4'h4,4'h4,4'h4};//4:rc(dut),0,1:ep(dut)
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

    extern function new(string name="pcie_subsys_env",uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

    `uvm_component_utils(pcie_subsys_env)

endclass:pcie_subsys_env

function pcie_subsys_env::new(string name="pcie_subsys_env",uvm_component parent=null);
    super.new(name,parent);
endfunction

function void pcie_subsys_env::build_phase(uvm_phase phase);
    bit[31:0] all_supported_speeds[4];//0:x1,1:x2,2:x4_1,3:x4_1
    `uvm_info("build_phase", "Entered...",UVM_LOW)

    $display("show link_mode:%s in env @%t",link_mode.name(),$time);
    for (int i=0;i<4;i++) begin//0:x1,1:x2,2:x4_0,3:x4_1
        $display("AAAAA pcie env for  %s,bypass_eq[%0d]:%0h, @%t",this.my_speed[i].name(),i,this.bypass_eq[i],$time);
        all_supported_speeds[i] = `SVT_PCIE_SPEED_32_0G | `SVT_PCIE_SPEED_16_0G |`SVT_PCIE_SPEED_8_0G | `SVT_PCIE_SPEED_5_0G | `SVT_PCIE_SPEED_2_5G;
        if(my_speed[i]==GEN5_MY)begin
            all_supported_speeds[i] = `SVT_PCIE_SPEED_32_0G | `SVT_PCIE_SPEED_16_0G |`SVT_PCIE_SPEED_8_0G | `SVT_PCIE_SPEED_5_0G | `SVT_PCIE_SPEED_2_5G;
        end
        else if(my_speed[i]==GEN4_MY)begin
            all_supported_speeds[i] = `SVT_PCIE_SPEED_16_0G |`SVT_PCIE_SPEED_8_0G | `SVT_PCIE_SPEED_5_0G | `SVT_PCIE_SPEED_2_5G;
        end
        else if(my_speed[i] == GEN3_MY)begin
            all_supported_speeds[i] = `SVT_PCIE_SPEED_8_0G | `SVT_PCIE_SPEED_5_0G | `SVT_PCIE_SPEED_2_5G;
        end
        else if(my_speed[i] == GEN2_MY)begin
            all_supported_speeds[i] = `SVT_PCIE_SPEED_5_0G | `SVT_PCIE_SPEED_2_5G;
        end
        else begin
            all_supported_speeds[i] = `SVT_PCIE_SPEED_2_5G;
        end
    end

    super.build_phase( phase );

    regacc_noc =  pcie_regmodel_noc::type_id::create("regacc_noc",this);
    regacc_noc.build();
    regacc_noc.set_hdl_path_root("test_top.dut");
    regacc_noc.lock_model();
    uvm_config_db#(uvm_reg_block)::set(this,"axi_system_env.master[0]", "axi_regmodel", regacc_noc);

    regacc_hnp =  pcie_regmodel_hnp::type_id::create("regacc_hnp",this);
    regacc_hnp.device_type           = this.device_type;
    regacc_hnp.cfg_enable            = this.cfg_enable;
    regacc_hnp.cfg_ecam_base_hi20    = this.cfg_ecam_base_hi20;
    regacc_hnp.cfg_raw_dbi_enable    = this.cfg_raw_dbi_enable;
    regacc_hnp.cfg_raw_dbi_base_hi24 = this.cfg_raw_dbi_base_hi24;
    for (int ii=0;ii<4;ii++) begin
        regacc_hnp.cfg_rp_valid[ii]       = this.cfg_rp_valid[ii];
        regacc_hnp.cfg_rp_device[ii]      = this.cfg_rp_device[ii];
        regacc_hnp.cfg_rp_primary[ii]     = this.cfg_rp_primary[ii];
        regacc_hnp.cfg_rp_secondary[ii]   = this.cfg_rp_secondary[ii];
        regacc_hnp.cfg_rp_subordinate[ii] = this.cfg_rp_subordinate[ii];
        regacc_hnp.cfg_rp_route_hi20[ii]  = this.cfg_rp_route_hi20[ii];
    end
    regacc_hnp.build();
    regacc_hnp.lock_model();
    uvm_config_db#(uvm_reg_block)::set(this,"axi_system_env.master[1]", "axi_regmodel", regacc_hnp);

    for (int i=0;i<2;i++) begin
        if(uvm_config_db#(svt_pcie_device_configuration)::get(get_parent(), get_name(), $sformatf("root_cfg[%0d]",i), root_cfg[i])) begin
            `uvm_info("build_phase",$sformatf("Using test case provided root_cfg[%0d]",i), UVM_LOW)
        end
        else `uvm_fatal("build_phase", $sformatf("Expecting test case provided root_cfg[%0d]",i))
    end

    for (int i=0;i<4;i++) begin
        if(uvm_config_db#(svt_pcie_device_configuration)::get(get_parent(), get_name(), $sformatf("endpoint_cfg[%0d]",i), endpoint_cfg[i])) begin
            `uvm_info("build_phase",$sformatf("Using test case provided endpoint_cfg[%0d]",i), UVM_LOW)
        end
        else `uvm_fatal("build_phase",$sformatf("Expecting test case provided endpoint_cfg[%0d]",i))
    end

    /** Enable Protocol Analyzer i.e. PA XML file generation */
    for (int i=0;i<2;i++) begin//for rc vip
        root_cfg[i].pcie_cfg.enable_tl_xml_gen          = 1'b1;
        root_cfg[i].pcie_cfg.enable_dl_xml_gen          = 1'b1;
        root_cfg[i].pcie_cfg.enable_pl_xml_gen          = 1'b1;
        root_cfg[i].pcie_cfg.pa_format_type             = svt_xml_writer::FSDB;
        root_cfg[i].pcie_cfg.enable_transaction_logging = 1'b1;
        root_cfg[i].pcie_cfg.transaction_log_filename   = $sformatf("rc_x4_%0d_trans.log",i);
        root_cfg[i].pcie_cfg.enable_symbol_logging      = 1'b1;
        root_cfg[i].pcie_cfg.symbol_log_filename        = $sformatf("rc_x4_%0d_sym.log",i);

	root_cfg[i].pcie_cfg.pl_cfg.enable_auto_directed_speed_change = 1;
        root_cfg[i].pcie_cfg.pl_cfg.enable_auto_set_autonomous_change = 1;
        root_cfg[i].pcie_cfg.pl_cfg.skip_polling_active =1;//todo??
        root_cfg[i].pcie_cfg.tl_cfg.init_cpl_data_tx_credits[0]= 0;
        root_cfg[i].pcie_cfg.tl_cfg.init_cpl_hdr_tx_credits[0]= 0;
        root_cfg[i].pcie_cfg.tl_cfg.remote_extended_tag_field_enabled = 1;
        root_cfg[i].requester_cfg.percentage_use_tlp_digest = 0;
        root_cfg[i].pcie_cfg.pl_cfg.enable_gen5_using_pipe_4_4 = 1;

	root_cfg[i].pcie_cfg.pl_cfg.set_link_speed_values(all_supported_speeds[i+2]);
	if (LINK_MODE_A == link_mode) begin
	    if (i==0) begin//x4_0 controler
	        root_cfg[i].pcie_cfg.pl_cfg.set_link_width_values(2);//set to x2
	    end
        end
	if (LINK_MODE_B == link_mode) begin
	    if (i==0) begin//x4_0 controler
	        root_cfg[i].pcie_cfg.pl_cfg.set_link_width_values(2);//set to x2
	    end
        end

	//root_cfg[i].pcie_cfg.pl_cfg.polling_configuration_timeout_ns = 1440000; //todo??
        root_cfg[i].target_cfg[0].max_payload_size_in_bytes = 4096;//todo???
        root_cfg[i].target_cfg[0].max_read_cpl_data_size_in_bytes = 128;//todo???
        root_cfg[i].target_cfg[0].flag_uninitialized_mem_read = 1'b0;
        root_cfg[i].target_cfg[0].uninit_mem_read_resp = svt_pcie_target_app_configuration::UNINIT_MEM_READ_RESP_BAAD;
        foreach (root_cfg[i].target_cfg[j])
            root_cfg[i].target_cfg[j].percentage_use_tlp_digest = 0;
        foreach (root_cfg[i].driver_cfg[j])
            root_cfg[i].driver_cfg[j].percentage_use_tlp_digest = 0;

        //Enable Coverage for all layers
        root_cfg[i].pcie_cfg.enable_cov     =4'b1111;      //[3]TL[2]DL[1]PL[]PIPE

	//Disable external clockS when TRANSMIT BIT CLOCK MODE ==1
        root_cfg[i].pcie_cfg.pl_cfg.disable_ext_bit_clock_mode     = 1'b1;

	if(this.bypass_eq[i+2] == 1'b0) begin
             if (my_speed[i+2] == GEN5_MY) begin
                 root_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(svt_pcie_pl_configuration::LINK_EQ_MODE_EQ_BYPASS_TO_HIGHEST_RATE);
             end
             else if (my_speed[i+2] == GEN4_MY) begin
                 root_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(,1);
             end
             else if (my_speed[i+2] == GEN3_MY) begin
                 root_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values();
             end
         end
         else begin
             if (my_speed[i+2] == GEN5_MY) begin
                 root_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(svt_pcie_pl_configuration::LINK_EQ_MODE_NO_EQUALIZATION_NEEDED);
             end
             else if (my_speed[i+2] == GEN4_MY) begin
                 root_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(,1,0);
             end
             else if (my_speed[i+2] == GEN3_MY) begin
                 root_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(,,0);
             end
         end

	root_cfg[i].pcie_cfg.pl_cfg.pipe_width[0] = svt_pcie_pl_configuration::PIPE_32_BITS;
        root_cfg[i].pcie_cfg.pl_cfg.pipe_width[1] = svt_pcie_pl_configuration::PIPE_32_BITS;
        root_cfg[i].pcie_cfg.pl_cfg.pipe_width[2] = svt_pcie_pl_configuration::PIPE_32_BITS;
        root_cfg[i].pcie_cfg.pl_cfg.pipe_width[3] = svt_pcie_pl_configuration::PIPE_32_BITS;

        root_cfg[i].pcie_cfg.pl_cfg.pclk_rate[0]= svt_pcie_pl_configuration::PCLK_62_5_MHZ;
        root_cfg[i].pcie_cfg.pl_cfg.pclk_rate[1]= svt_pcie_pl_configuration::PCLK_125_MHZ;
        root_cfg[i].pcie_cfg.pl_cfg.pclk_rate[2]= svt_pcie_pl_configuration::PCLK_250_MHZ;
        root_cfg[i].pcie_cfg.pl_cfg.pclk_rate[3]= svt_pcie_pl_configuration::PCLK_500_MHZ;

        root_cfg[i].pcie_cfg.pl_cfg.downstream_lanes_recovery_eq_phase1_timeout_ns = 12000*50;
        root_cfg[i].pcie_cfg.pl_cfg.downstream_lanes_recovery_eq_phase2_timeout_ns = 24000*50;
        root_cfg[i].pcie_cfg.pl_cfg.downstream_lanes_recovery_eq_phase3_timeout_ns = 32000*50;
        root_cfg[i].pcie_cfg.pl_cfg.recovery_speed_electrical_idle_time_ns = 26000;
        root_cfg[i].pcie_cfg.dl_cfg.initfc_timeout_ns        = 1000000;

	//avoid warning:ACTIVE_PL:SKP_OS:phy too many skp sets
        root_cfg[i].pcie_cfg.pl_cfg.min_rx_skp_interval_in_symbol_times     = 80;

	if(enable_aspm_l0s[i+2] == 1'b1)begin
            root_cfg[i].pcie_cfg.dl_cfg.l0s_idle_timer_limit_ns    = 1000;
            root_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l0s_entry      = 1;
            root_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_entry       = 1;
            root_cfg[i].pcie_cfg.dl_cfg.updatefc_timeout_ns        = 50000;
            $display("enable_aspm_l0s for vip rc[%0d] @t",i,$time);
        end

        if(enable_aspm_l1[i+2] == 1'b1) begin
            root_cfg[i].pcie_cfg.dl_cfg.l0s_idle_timer_limit_ns = 0;
            root_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l0s_entry   = 0;
            root_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_entry    = 1;

            $display("enable aspm ll for vip rc[%0d] @%t",i,$time);
        end

        if(enable_aspm_l1sub[i+2] == 1'b1) begin
            root_cfg[i].pcie_cfg.dl_cfg.l0s_idle_timer_limit_ns = 0;
            root_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l0s_entry   = 0;
            root_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_entry    = 1;
            root_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_1_entry  = 1;
            root_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_2_entry  = 1;

            $display("enable aspm l1 substate for vip rc[%0d] @%t",i,$time);
        end

	root_cfg[i].pcie_cfg.dl_cfg.max_attached_ack_nak_latency = 1000;
        $display("set max_attached_ack_nak_latency to 1000. for vip rc[%0d] @%t",i,$time);

	//**create status objects for root and endpoint devices */
        root_status[i]     = svt_pcie_device_status::type_id::create($sformatf("root_status[%0d]",i));

        uvm_config_db#(svt_pcie_device_configuration)::set(this, $sformatf("root[%0d]",i), "cfg",this.root_cfg[i]);

        uvm_config_db#(svt_pcie_device_status)::set(this, $sformatf("root[%0d]",i), "shared_status", this.root_status[i]);
        
        root[i] =svt_pcie_device_agent::type_id::create( $sformatf("root[%0d]",i),this );
    end//for rc vip

    for (int i=0;i<4;i++) begin//for ep vip
        endpoint_cfg[i].pcie_cfg.enable_tl_xml_gen          = 1'b1;
        endpoint_cfg[i].pcie_cfg.enable_dl_xml_gen          = 1'b1;
        endpoint_cfg[i].pcie_cfg.enable_pl_xml_gen          = 1'b1;
        endpoint_cfg[i].pcie_cfg.pa_format_type             = svt_xml_writer::FSDB;
        endpoint_cfg[i].pcie_cfg.enable_transaction_logging = 1'b1;
        endpoint_cfg[i].pcie_cfg.transaction_log_filename   = $sformatf("ep_trans_%0d.log",i);
        endpoint_cfg[i].pcie_cfg.enable_symbol_logging      = 1'b1;
        endpoint_cfg[i].pcie_cfg.symbol_log_filename        = $sformatf("ep_sym_%0d.log",i);

        endpoint_cfg[i].pcie_cfg.pl_cfg.enable_auto_directed_speed_change = 0;
        endpoint_cfg[i].pcie_cfg.pl_cfg.enable_auto_set_autonomous_change = 0;
        endpoint_cfg[i].pcie_cfg.pl_cfg.skip_polling_active = 1;
        endpoint_cfg[i].pcie_cfg.tl_cfg.init_cpl_data_tx_credits[0]= 0;
        endpoint_cfg[i].pcie_cfg.tl_cfg.init_cpl_hdr_tx_credits[0]= 0;
        endpoint_cfg[i].pcie_cfg.tl_cfg.remote_extended_tag_field_enabled = 1;
        endpoint_cfg[i].requester_cfg.percentage_use_tlp_digest = 0;
        endpoint_cfg[i].pcie_cfg.pl_cfg.enable_gen5_using_pipe_4_4 = 1;

        endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_speed_values(all_supported_speeds[i]);
        if (LINK_MODE_A == link_mode) begin
	    if (i==1) begin//x2 controler
	        endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_width_values(1);//set to x1
	    end
	    if (i==2) begin//x4_0 controler
	        endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_width_values(2);//set to x2
	    end
        end
	if (LINK_MODE_B == link_mode) begin
	    if (i==2) begin//x4_0 controler
	        endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_width_values(2);//set to x2
	    end
        end

        //endpoint_cfg[i].pcie_cfg.pl_cfg.polling_configuration_timeout_ns = 1440000; //todo??
        endpoint_cfg[i].target_cfg[0].max_payload_size_in_bytes = 4096;//todo???
        endpoint_cfg[i].target_cfg[0].max_read_cpl_data_size_in_bytes = 128;//todo???
        endpoint_cfg[i].target_cfg[0].flag_uninitialized_mem_read = 1'b0;
        endpoint_cfg[i].target_cfg[0].uninit_mem_read_resp = svt_pcie_target_app_configuration::UNINIT_MEM_READ_RESP_BAAD;
        foreach (endpoint_cfg[i].target_cfg[j])
            endpoint_cfg[i].target_cfg[j].percentage_use_tlp_digest = 0;
        foreach (endpoint_cfg[i].driver_cfg[j])
            endpoint_cfg[i].driver_cfg[j].percentage_use_tlp_digest = 0;

        //Enable Coverage for all layers
        endpoint_cfg[i].pcie_cfg.enable_cov = 4'b1111;  //[3]TL[2]DL[1PL[]PIPE
        
        //Disable external clockS when TRANSMIT BIT CLOCK MODE ==1
        endpoint_cfg[i].pcie_cfg.pl_cfg.disable_ext_bit_clock_mode = 1'b1;

        if(this.bypass_eq[i] == 1'b0) begin
            if (my_speed[i] == GEN5_MY) begin
                endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(svt_pcie_pl_configuration::LINK_EQ_MODE_EQ_BYPASS_TO_HIGHEST_RATE);
            end
            else if (my_speed[i] == GEN4_MY) begin
                endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(,1);
            end
            else if (my_speed[i] == GEN3_MY) begin
                endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values();
            end
        end
        else begin
            if (my_speed[i] == GEN5_MY) begin
                endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(svt_pcie_pl_configuration::LINK_EQ_MODE_NO_EQUALIZATION_NEEDED);
            end
            else if (my_speed[i] == GEN4_MY) begin
                endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(,1,0);
            end
            else if (my_speed[i] == GEN3_MY) begin
                endpoint_cfg[i].pcie_cfg.pl_cfg.set_link_eq_attribute_values(,,0);
            end
        end

        //ep
        endpoint_cfg[i].pcie_cfg.pl_cfg.pipe_width[0] = svt_pcie_pl_configuration::PIPE_32_BITS;
        endpoint_cfg[i].pcie_cfg.pl_cfg.pipe_width[1] = svt_pcie_pl_configuration::PIPE_32_BITS;
        endpoint_cfg[i].pcie_cfg.pl_cfg.pipe_width[2] = svt_pcie_pl_configuration::PIPE_32_BITS;
        endpoint_cfg[i].pcie_cfg.pl_cfg.pipe_width[3] = svt_pcie_pl_configuration::PIPE_32_BITS;

        endpoint_cfg[i].pcie_cfg.pl_cfg.pclk_rate[0]= svt_pcie_pl_configuration::PCLK_62_5_MHZ;
        endpoint_cfg[i].pcie_cfg.pl_cfg.pclk_rate[1]= svt_pcie_pl_configuration::PCLK_125_MHZ;
        endpoint_cfg[i].pcie_cfg.pl_cfg.pclk_rate[2]= svt_pcie_pl_configuration::PCLK_250_MHZ;
        endpoint_cfg[i].pcie_cfg.pl_cfg.pclk_rate[3]= svt_pcie_pl_configuration::PCLK_500_MHZ;

        endpoint_cfg[i].pcie_cfg.pl_cfg.upstream_lanes_recovery_eq_phase0_timeout_ns = 12000*50;
        endpoint_cfg[i].pcie_cfg.pl_cfg.upstream_lanes_recovery_eq_phase1_timeout_ns = 12000*50;
        endpoint_cfg[i].pcie_cfg.pl_cfg.upstream_lanes_recovery_eq_phase2_timeout_ns = 24000*50;
        endpoint_cfg[i].pcie_cfg.pl_cfg.upstream_lanes_recovery_eq_phase3_timeout_ns = 32000*50;
        endpoint_cfg[i].pcie_cfg.pl_cfg.recovery_speed_electrical_idle_time_ns = 26000;

        //avoid warning:ACTIVE_PL:SKP_OS:phy too many skp sets
        endpoint_cfg[i].pcie_cfg.pl_cfg.min_rx_skp_interval_in_symbol_times = 80;

        if(enable_aspm_l0s[i] == 1'b1)begin
            endpoint_cfg[i].pcie_cfg.dl_cfg.l0s_idle_timer_limit_ns    = 1000;
            endpoint_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l0s_entry      = 1;
            endpoint_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_entry       = 1;
            endpoint_cfg[i].pcie_cfg.dl_cfg.updatefc_timeout_ns        = 50000;
            //endpoint_cfg[i].pcie_cfg.dl_cfg.vc0_updatefc_interval_ns = 0;//disable fc scheduling
            $display("enable_aspm_l0s for ep @t",$time);
        end
        if(enable_aspm_l1[i] == 1'b1) begin
            endpoint_cfg[i].pcie_cfg.dl_cfg.l0s_idle_timer_limit_ns = 0;
            endpoint_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l0s_entry   = 0;
            endpoint_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_entry    = 1;
            $display("enable aspm ll for ep @%t",$time);
        end

        if(enable_aspm_l1sub[i] == 1'b1) begin
            endpoint_cfg[i].pcie_cfg.dl_cfg.l0s_idle_timer_limit_ns = 0;
            endpoint_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l0s_entry   = 0;
            endpoint_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_entry    = 1;
            endpoint_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_1_entry  = 1;
            endpoint_cfg[i].pcie_cfg.dl_cfg.enable_aspm_l1_2_entry  = 1;
            $display("enable aspm l1 substateforep @%t",$time);
        end

        endpoint_cfg[i].pcie_cfg.dl_cfg.max_attached_ack_nak_latency = 1000;
        $display("set max_attached_ack_nak_latency to 1000. @%t",$time);


        //**create status objects for root and endpoint devices */
        endpoint_status[i] = svt_pcie_device_status::type_id::create($sformatf("endpoint_status[%0d]",i));

        uvm_config_db#(svt_pcie_device_configuration)::set(this, $sformatf("endpoint[%0d]",i), "cfg", this.endpoint_cfg[i]);

        uvm_config_db#(svt_pcie_device_status)::set(this,$sformatf("endpoint[%0d]",i), "shared_status", this.endpoint_status[i]);
        
        endpoint[i] =svt_pcie_device_agent::type_id::create( $sformatf("endpoint[%0d]",i),this);
    end//for ep vip

    this.sys_virt_seqr = svt_pcie_device_system_virtual_sequencer::type_id::create("sys_virt_seqr", this);

    /** Create report catcher to suppress error injected by active component as a result of randomization */
    err_catcher=new({get_name(),".err_catcher"});
    uvm_report_cb::add(null,err_catcher);

    //for axi
    if (!uvm_config_db#(cust_svt_axi_system_configuration)::get(this, "","cfg", cfg)) begin
        cfg =cust_svt_axi_system_configuration::type_id::create("cfg");
    end
    uvm_config_db#(svt_axi_system_configuration)::set(this, "axi_system_env", "cfg", cfg);

    axi_system_env = svt_axi_system_env::type_id::create("axi_system_env",this);
    sequencer      = axi_virtual_sequencer::type_id::create("sequencer",this);
    
    `uvm_info("build_phase","Exiting...",UVM_LOW)
endfunction

function void pcie_subsys_env::connect_phase(uvm_phase phase);
begin
    `uvm_info("connect_phase","Entered...",UVM_LOW)
    super.connect_phase(phase);

    //this.sys_virt_seqr.root_virt_seqr     = root.virt_seqr;
    //this.sys_virt_seqr.endpoint_virt_seqr = endpoint.virt_seqr;

    //if(this.bypass_eq == 1'b1) begin
    //    //disable protocol checker
    //    root.err_check.set_default_fail_effects("ACTIVE_PL","",svt_err_check_stats::NOTE,"phy_rx_packet_before_equalization_complete");
    //    endpoint.err_check.set_default_fail_effects("ACTIVE_PL","",svt_err_check_stats::NOTE,"phy_rx_packet_before_equalization_complete");
    //end

    //if (device_type == 4'h4) begin//rc
    //     `uvm_info("show vip(EP) cfg:\n%s",endpoint_cfg.sprint(),UVM_LOW)
    //end
    //else begin//ep
    //     `uvm_info("show vip(RC) cfg:\n%s",root_cfg.sprint(),UVM_LOW)
    //end

    `uvm_info("connect_phase","Exiting...",UVM_LOW)

end
endfunction

`endif // GUARD_PCIE_SUBSYS_ENV_SV
