import uvm_pkg::*;
class pcie_regmodel_noc extends uvm_reg_block;

    rand ral_sys_pcie_cus_top             pcie_cus_top;//M7:core1,2,4 sub share/dir
    rand ral_sys_pcie_ss_reg_top          pcie_ss_reg_top;//M3
    rand ral_sys_host_bridge_top          host_bridge_top;//M2

    function new(string name ="pcie_regmodel_noc");
        super.new(name);
    endfunction: new
   function void build();
        this.default_map = create_map("",0,4,UVM_LITTLE_ENDIAN,0);

	this.pcie_cus_top = ral_sys_pcie_cus_top::type_id::create("pcie_cus_top",,get_full_name());
        this.pcie_cus_top.configure(this,"u_pcie_subsystem");
        this.pcie_cus_top.build();
        this.default_map.add_submap(this.pcie_cus_top.default_map, `UVM_REG_ADDR_WIDTH'h5c00_0000);

	this.pcie_ss_reg_top  = ral_sys_pcie_ss_reg_top::type_id::create("pcie_ss_reg_top",,get_full_name());
        this.pcie_ss_reg_top.configure(this,"u_pcie_ss_reg");
        this.pcie_ss_reg_top.build();
        this.default_map.add_submap(this.pcie_ss_reg_top.default_map, `UVM_REG_ADDR_WIDTH'h5bb5_0000);

	this.host_bridge_top  = ral_sys_host_bridge_top::type_id::create("host_bridge_top",,get_full_name());
        this.host_bridge_top.configure(this,"u_pcie_host_bridge_regs");
        this.host_bridge_top.build();
        this.default_map.add_submap(this.host_bridge_top.default_map, `UVM_REG_ADDR_WIDTH'h5bb6_0000);

    endfunction :build
    `uvm_object_utils(pcie_regmodel_noc)
endclass :pcie_regmodel_noc
