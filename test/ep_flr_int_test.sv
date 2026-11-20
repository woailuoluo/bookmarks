class ep_flr_int_test extends pcie_subsys_base_test;

    `uvm_component_utils(ep_flr_int_test)

    extern function new(string name = "ep_flr_int_test", uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    extern virtual task exec_training_and_trans(int link_idx);
endclass //ep_flr_int_test

function ep_flr_int_test::new(string name = "ep_flr_int_test", uvm_component parent=null);
    super.new(name,parent);
endfunction:new

function void ep_flr_int_test::build_phase(uvm_phase phase);
    bit[3:0]  device_type_tmp;
    `uvm_info("build phase","Entered...",UVM_LOW)

    std::randomize(device_type_tmp) with {device_type_tmp inside {0};};//
    $display("show device_type_tmp:%0h for x4_0",device_type_tmp);
    this.device_type[2] = device_type_tmp;
    std::randomize(device_type_tmp) with {device_type_tmp inside {0};};//
    $display("show device_type_tmp:%0h for x4_1",device_type_tmp);
    this.device_type[3] = device_type_tmp;

    for (int i=0;i<4;i++) begin
        this.bypass_eq[i] =1'b1;
        this.my_speed[i]  = GEN1_MY;
    end
    std::randomize(link_mode);
    $display("show link_mode:%s for x4_0",this.link_mode);

    super.build_phase(phase);

    `uvm_info("build_phase","Exiting...",UVM_LOW)
endfunction:build_phase

task ep_flr_int_test::main_phase(uvm_phase phase);

    $display("enter main phase @%t",$time);

    phase.raise_objection(this);

    fork
	begin
	    exec_training_and_trans(2);
	end

	begin
	    exec_training_and_trans(3);
	end
    join

    phase.drop_objection(this);
endtask:main_phase

task ep_flr_int_test::exec_training_and_trans(int link_idx);
    logic[31:0]   rdata;
    logic[31:0]   wdata;
    uvm_status_e  status_tmp;
    bit[9:0]      reg_num;

    $display("start link training for link_idx:%0d @%t",link_idx,$time);
    link_training(link_idx);
    $display("finish link training for link_idx:%0d @%t",link_idx,$time);
    set_mem_io_base_limit(link_idx);
    $display("finish set_mem_io_base_limit for link_idx:%0d @%t",link_idx,$time);
    set_atu_for_mem_req(link_idx);
    $display("finish set_atu_for_mem_req for link_idx:%0d @%t",link_idx,$time);
    gen_inbound_outboud_trans(link_idx);
    $display("finish test trans before flr for link_idx:%0d @%t",link_idx,$time);

    reg_num = 8'h78>>2;
    $display("DEVICE_CONTROL_DEVICE_STATUS[%0d] addr:%0h,reg_num:%0d @%t",link_idx,DEVICE_CONTROL_DEVICE_STATUS[link_idx].get_address(),reg_num,$time);
    read_cfg_reg(reg_num,rdata,link_idx);//bus,dev ==0. fun num=i, reg num =1(status, command)
    rdata[15]=1'b1;//Initiate Function Level Reset
    write_cfg_reg(reg_num,rdata,link_idx);
    $display("finish set flr for link_idx:%0d @%t",link_idx,$time);

    #1000ns;

     `uvm_info("LINK TRAINING",$sformatf("start to set STATUS_COMMAND_REG after flr,(addr:%0h) for link_idx:%0d", this.STATUS_COMMAND_REG[link_idx].get_address(),link_idx) ,UVM_LOW)
    //enable io,mse, bme
    this.STATUS_COMMAND_REG[link_idx].read(status_tmp,rdata);
    rdata[0]=1'b1;//I/O space enable
    rdata[1]=1'b1;//mem space enable
    rdata[2]=1'b1;//bus master enable
    this.STATUS_COMMAND_REG[link_idx].write(status_tmp,rdata) ;

    `uvm_info("LINK TRAINING",$sformatf("start to set DEVICE_CAPABILITIES_REG after flr (addr:%0h) for link_idx:%0d", this.DEVICE_CAPABILITIES_REG[link_idx].get_address(),link_idx) ,UVM_LOW)
    //set maxpayloadsize to 512bytes.
    this.DEVICE_CAPABILITIES_REG[link_idx].read(status_tmp,rdata);
    $display("show PCIE CAP MAX PAYLOAD after flr SIZE:%0h for link_idx:%0d @%t",rdata[2:0],link_idx,$time);
    this.DEVICE_CONTROL_DEVICE_STATUS[link_idx].read(status_tmp,rdata);
    $display("show PCIE CAP MAX PAYLOAD SIZE after flr CS:%0h for link_idx:%0d @%t",rdata[7:5],link_idx,$time);
    //rdata[7:5]=3'h2;//512bytes
    rdata[7:5]=3'h5;//4096byte max payload size
    this.DEVICE_CONTROL_DEVICE_STATUS[link_idx].write(status_tmp,rdata);

    $display("start test trans after flr for link_idx:%0d @%t",link_idx,$time);
    gen_inbound_outboud_trans(link_idx);
    $display("finish test trans after flr for link_idx:%0d @%t",link_idx,$time);
endtask:exec_training_and_trans
