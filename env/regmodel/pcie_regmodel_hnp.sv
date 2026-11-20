import uvm_pkg::*;
class pcie_regmodel_hnp extends uvm_reg_block;

    rand ral_sys_x1_DWC_pcie_ctl          x1_rc_cfg;
    rand ral_sys_x2_DWC_pcie_ctl          x2_rc_cfg;
    rand ral_sys_x4_DWC_pcie_ctl_dsp      x4_0_rc_cfg;
    rand ral_sys_x4_DWC_pcie_ctl_usp      x4_0_ep_cfg;
    rand ral_sys_x4_DWC_pcie_ctl_dsp      x4_1_rc_cfg;
    rand ral_sys_x4_DWC_pcie_ctl_usp      x4_1_ep_cfg;

    //atu,hdma
    rand ral_sys_x1_DWC_DSP_ATU           x1_rc_atu;
    rand ral_sys_x2_DWC_DSP_ATU           x2_rc_atu;
    rand ral_sys_x4_DWC_DSP_ATU           x4_0_rc_atu;
    rand ral_sys_x4_DWC_USP_ATU           x4_0_ep_atu;
    rand ral_sys_x4_DWC_DSP_HDMA          x4_0_rc_hdma;
    rand ral_sys_x4_DWC_USP_HDMA          x4_0_ep_hdma;
    rand ral_sys_x4_DWC_DSP_ATU           x4_1_rc_atu;
    rand ral_sys_x4_DWC_USP_ATU           x4_1_ep_atu;
    rand ral_sys_x4_DWC_DSP_HDMA          x4_1_rc_hdma;
    rand ral_sys_x4_DWC_USP_HDMA          x4_1_ep_hdma;


    bit[3:0] device_type[4] =  {4'h4,4'h4,4'h4,4'h4};//4:rc(dut),0,1:ep(dut) for x1,x2 link, not used.

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
    //HNP RAW 地址:
    //RAW BASE(cfg_raw_dbi_base_hi24<<24)
    //+(controller id<<22)  :x1=2'h0,x2=2'h1,x4_0=2'h2,x4_1=2'h3
    //+(DWC ADDR[32:31]<<20) :iatu,hdma:2'b11
    //+ DWC ADDR19:0]
    bit         cfg_raw_dbi_enable;
    bit[23:0]   cfg_raw_dbi_base_hi24;

    function new(string name ="pcie_regmodel_hnp");
        super.new(name);
    endfunction: new
   function void build();

	$display("show ecam cfg info in hnp regmodel:@%t",$time);
        $display("cfg_ecam_base_hi20:%0h",cfg_ecam_base_hi20);
        $display("cfg_raw_dbi_base_hi24:%0h",cfg_raw_dbi_base_hi24);
        for (int i=0;i<4;i++) begin
            $display("cfg_rp_device[%0d]:%0h",i,cfg_rp_device[i]);
            $display("cfg_rp_route_hi20[%0d]:%0h",i,cfg_rp_route_hi20[i]);
            $display("cfg_rp_primary[%0d]:%0h",i,cfg_rp_primary[i]);
            $display("cfg_rp_secondary[%0d]:%0h",i,cfg_rp_secondary[i]);
            $display("cfg_rp_subordinate[%0d]:%0h",i,cfg_rp_subordinate[i]);
        end
        this.default_map = create_map("",0,4,UVM_LITTLE_ENDIAN,0);

	this.x1_rc_cfg = ral_sys_x1_DWC_pcie_ctl::type_id::create("x1_rc_cfg",,get_full_name());
        this.x1_rc_cfg.configure(this,"");
        this.x1_rc_cfg.build();
        //this.default_map.add_submap(this.x1_rc_cfg.default_map, `UVM_REG_ADDR_WIDTH'h40_0000);
        this.default_map.add_submap(this.x1_rc_cfg.default_map, {cfg_ecam_base_hi20,cfg_rp_primary[0],cfg_rp_device[0],3'h0,12'h0});

	this.x1_rc_atu = ral_sys_x1_DWC_DSP_ATU::type_id::create("x1_rc_atu",,get_full_name());
        this.x1_rc_atu.configure(this,"");
        this.x1_rc_atu.build();
        this.default_map.add_submap(this.x1_rc_atu.default_map, {cfg_raw_dbi_base_hi24,2'h0,2'h3,20'h0});

	this.x2_rc_cfg = ral_sys_x2_DWC_pcie_ctl::type_id::create("x2_rc_cfg",,get_full_name());
        this.x2_rc_cfg.configure(this,"");
        this.x2_rc_cfg.build();
        //this.default_map.add_submap(this.x2_rc_cfg.default_map, `UVM_REG_ADDR_WIDTH'h40_0000);
        this.default_map.add_submap(this.x2_rc_cfg.default_map, {cfg_ecam_base_hi20,cfg_rp_primary[1],cfg_rp_device[1],3'h0,12'h0});

	this.x2_rc_atu = ral_sys_x2_DWC_DSP_ATU::type_id::create("x2_rc_atu",,get_full_name());
        this.x2_rc_atu.configure(this,"");
        this.x2_rc_atu.build();
        this.default_map.add_submap(this.x2_rc_atu.default_map, {cfg_raw_dbi_base_hi24,2'h1,2'h3,20'h0});

	`uvm_info(get_full_name,$sformatf("show device_type[%0d]:%0h in hnp regmodel",2,device_type[2]),UVM_LOW)
        if (device_type[2] inside {4'h4,4'h6}) begin//rc
            this.x4_0_rc_cfg = ral_sys_x4_DWC_pcie_ctl_dsp::type_id::create("x4_0_rc_cfg",,get_full_name());
            this.x4_0_rc_cfg.configure(this,"");
            this.x4_0_rc_cfg.build();
            //this.default_map.add_submap(this.x4_0_rc_cfg.default_map, `UVM_REG_ADDR_WIDTH'h40_0000);
            this.default_map.add_submap(this.x4_0_rc_cfg.default_map, {cfg_ecam_base_hi20,cfg_rp_primary[2],cfg_rp_device[2],3'h0,12'h0});

	    this.x4_0_rc_atu = ral_sys_x4_DWC_DSP_ATU::type_id::create("x4_0_rc_atu",,get_full_name());
            this.x4_0_rc_atu.configure(this,"");
            this.x4_0_rc_atu.build();
            this.default_map.add_submap(this.x4_0_rc_atu.default_map, {cfg_raw_dbi_base_hi24,2'h2,2'h3,20'h0});

	    this.x4_0_rc_hdma = ral_sys_x4_DWC_DSP_HDMA::type_id::create("x4_0_rc_hdma",,get_full_name());
            this.x4_0_rc_hdma.configure(this,"");
            this.x4_0_rc_hdma.build();
            this.default_map.add_submap(this.x4_0_rc_hdma.default_map, {cfg_raw_dbi_base_hi24,2'h2,2'h3,20'h0});
        end
        else if (device_type[2] inside {4'h0,4'h5}) begin//ep
            this.x4_0_ep_cfg = ral_sys_x4_DWC_pcie_ctl_usp::type_id::create("x4_0_ep_cfg",,get_full_name());
            this.x4_0_ep_cfg.configure(this,"");
            this.x4_0_ep_cfg.build();
            //this.default_map.add_submap(this.x4_0_ep_cfg.default_map, `UVM_REG_ADDR_WIDTH'h40_0000);
            this.default_map.add_submap(this.x4_0_ep_cfg.default_map, {cfg_ecam_base_hi20,cfg_rp_primary[2],cfg_rp_device[2],3'h0,12'h0});

	    this.x4_0_ep_atu = ral_sys_x4_DWC_USP_ATU::type_id::create("x4_0_ep_atu",,get_full_name());
            this.x4_0_ep_atu.configure(this,"");
            this.x4_0_ep_atu.build();
            this.default_map.add_submap(this.x4_0_ep_atu.default_map, {cfg_raw_dbi_base_hi24,2'h2,2'h3,20'h0});

	    this.x4_0_ep_hdma = ral_sys_x4_DWC_USP_HDMA::type_id::create("x4_0_ep_hdma",,get_full_name());
            this.x4_0_ep_hdma.configure(this,"");
            this.x4_0_ep_hdma.build();
            this.default_map.add_submap(this.x4_0_ep_hdma.default_map, {cfg_raw_dbi_base_hi24,2'h2,2'h3,20'h0});
        end
        else begin
            `uvm_fatal("pcie_regmodel_hnp",$sformatf("device_type[2]:%0h is illegal",device_type[2]))
        end

	`uvm_info(get_full_name,$sformatf("show device_type[%0d]:%0h in hnp regmodel",3,device_type[3]),UVM_LOW)
	if (device_type[3] inside {4'h4,4'h6}) begin//rc
            this.x4_1_rc_cfg = ral_sys_x4_DWC_pcie_ctl_dsp::type_id::create("x4_1_rc_cfg",,get_full_name());
            this.x4_1_rc_cfg.configure(this,"");
            this.x4_1_rc_cfg.build();
            //this.default_map.add_submap(this.x4_1_rc_cfg.default_map, `UVM_REG_ADDR_WIDTH'h40_0000);
            this.default_map.add_submap(this.x4_1_rc_cfg.default_map, {cfg_ecam_base_hi20,cfg_rp_primary[3],cfg_rp_device[3],3'h0,12'h0});

            this.x4_1_rc_atu = ral_sys_x4_DWC_DSP_ATU::type_id::create("x4_1_rc_atu",,get_full_name());
            this.x4_1_rc_atu.configure(this,"");
            this.x4_1_rc_atu.build();
            this.default_map.add_submap(this.x4_1_rc_atu.default_map, {cfg_raw_dbi_base_hi24,2'h3,2'h3,20'h0});

	    this.x4_1_rc_hdma = ral_sys_x4_DWC_DSP_HDMA::type_id::create("x4_1_rc_hdma",,get_full_name());
            this.x4_1_rc_hdma.configure(this,"");
            this.x4_1_rc_hdma.build();
            this.default_map.add_submap(this.x4_1_rc_hdma.default_map, {cfg_raw_dbi_base_hi24,2'h3,2'h3,20'h0});
        end
        else if (device_type[3] inside {4'h0,4'h5}) begin//ep
            this.x4_1_ep_cfg = ral_sys_x4_DWC_pcie_ctl_usp::type_id::create("x4_1_ep_cfg",,get_full_name());
            this.x4_1_ep_cfg.configure(this,"");
            this.x4_1_ep_cfg.build();
            //this.default_map.add_submap(this.x4_1_ep_cfg.default_map, `UVM_REG_ADDR_WIDTH'h40_0000);
            this.default_map.add_submap(this.x4_1_ep_cfg.default_map, {cfg_ecam_base_hi20,cfg_rp_primary[3],cfg_rp_device[3],3'h0,12'h0});

	    this.x4_1_ep_atu = ral_sys_x4_DWC_USP_ATU::type_id::create("x4_1_ep_atu",,get_full_name());
            this.x4_1_ep_atu.configure(this,"");
            this.x4_1_ep_atu.build();
            this.default_map.add_submap(this.x4_1_ep_atu.default_map, {cfg_raw_dbi_base_hi24,2'h3,2'h3,20'h0});

	    this.x4_1_ep_hdma = ral_sys_x4_DWC_USP_HDMA::type_id::create("x4_1_ep_hdma",,get_full_name());
            this.x4_1_ep_hdma.configure(this,"");
            this.x4_1_ep_hdma.build();
            this.default_map.add_submap(this.x4_1_ep_hdma.default_map, {cfg_raw_dbi_base_hi24,2'h3,2'h3,20'h0});
        end
        else begin
            `uvm_fatal("pcie_regmodel_hnp",$sformatf("device_type[3]:%0h is illegal",device_type[3]))
        end
        
    endfunction :build
    `uvm_object_utils(pcie_regmodel_hnp)
endclass :pcie_regmodel_hnp
