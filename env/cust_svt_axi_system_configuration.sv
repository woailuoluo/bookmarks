/**
 * Abstract:
 * Class cust_svt_axi_system_configuration is basically used to encapsulate all
 * the configuration information.  It extends system configuration and set the
 * appropriate fields like number of master/slaves, create master/slave
 * configurations etc..., which are required by System Env.
 */

`ifndef GUARD_CUST_SVT_AXI_SYSTEM_CONFIGURATION_SV
`define GUARD_CUST_SVT_AXI_SYSTEM_CONFIGURATION_SV

class cust_svt_axi_system_configuration extends svt_axi_system_configuration;

    //Utility macro
    `uvm_object_utils (cust_svt_axi_system_configuration)

    function new (string str="cust_svt_axi_system_configuration");
        super.new(str);

        /** Assign the necessary configuration parameters. This example uses single
          * master and single slave configuration.
        */
        this.num_masters = 3;//0:program register, 1: trans
        this.num_slaves  = 4;//0:acelite slv0, for x4_0 its,1:acelite slv1, for x4_1 its,2:axi stream slv, for x4_0/x4_1 msix table,3:acelite slv-qtw, for x4_0/x4_1 table walk

        /** Create port configurations */
        this.create_sub_cfgs(3, 4);

	this.display_perf_summary_report = 1;
	this.common_clock_mode           = 0;//use different mode between ports.
        //for master
        for (int i=0;i<3;i++) begin
            this.master_cfg[i].transaction_coverage_enable = 1;

            /** Enable protocol file generation for Protocol Analyzer */
            this.master_cfg[i].enable_xml_gen = 1;

            // Set performance constraints
            // All intervals, latencies are in terms of timescale unit
            this.master_cfg[i].perf_recording_interval = -1;
            this.master_cfg[i].perf_avg_max_read_xact_latency= 100000;
            `ifdef AXI_PERF_API_USAGE //using this macro will result in constraint failure errors. This is to demonstrate the usage of the APIs of class svt_axi_port_perf_status
            this.master_cfg[i].perf_max_read_xact_latency= 100;
            `else     
            this.master_cfg[i].perf_max_read_xact_latency= 100000;
            `endif
            this.master_cfg[i].perf_max_write_throughput = 20;
            this.master_cfg[i].perf_min_write_throughput = 0.0001;

            // Unit is bytes/timescale
            this.master_cfg[i].perf_max_read_throughput = 20;
            this.master_cfg[i].perf_min_read_throughput = 0.0001;
            this.master_cfg[i].perf_avg_max_write_xact_latency = 100000; 
            this.master_cfg[i].perf_avg_min_read_xact_latency = 0.000001; 
            this.master_cfg[i].perf_avg_min_write_xact_latency = 0.000001; 
            this.master_cfg[i].perf_exclude_inactive_periods_for_throughput = 1; 
            this.master_cfg[i].perf_inactivity_algorithm_type = svt_axi_port_configuration::EXCLUDE_BEGIN_END;  
            `ifdef AXI_PERF_API_USAGE 
            this.master_cfg[i].perf_max_write_xact_latency = 100; 
            this.master_cfg[i].perf_min_read_xact_latency = 100000; 
            this.master_cfg[i].perf_min_write_xact_latency = 100000; 
            `else     
            this.master_cfg[i].perf_max_write_xact_latency = 10000000; 
            this.master_cfg[i].perf_min_read_xact_latency = 10; 
            this.master_cfg[i].perf_min_write_xact_latency = 10; 
            `endif
            //`ifdef _EEESTART_SIM_USE_AXI_SYSTEM_VIP_
            //this.master_cfg[i].id_width = 8;
            //`else     
            //    this.master_cfg[i].id_width = 9;
            //`endif

	    if (2==i) begin
                this.master_cfg[i].axi_interface_type = svt_axi_port_configuration::AXI4_STREAM;
                this.master_cfg[i].stream_twakeup_signal  = svt_axi_port_configuration::STREAM_TWAKEUP_TRUE;
            end
	    else begin
                this.master_cfg[i].axi_interface_type = svt_axi_port_configuration::AXI4;
	    end
	    if (2 !=i) begin
	        this.master_cfg[i].uvm_reg_enable= 1;
            end
	    this.master_cfg[i].aruser_enable= 1;
	    this.master_cfg[i].awuser_enable= 1;
	    if (2==i) begin
	        this.master_cfg[i].data_width= 64;
	    end
	    if (0==i) begin
	        this.master_cfg[i].data_width= 64;//TODO:avoid axi vip issue
	    end
        end//for master

	//for slave
        for (int i=0;i<4;i++) begin
            /** Enable transaction level coverage */
            this.slave_cfg[i].transaction_coverage_enable = 1;

            /** Enable protocol file generation for Protocol Analyzer */
            this.slave_cfg[i].enable_xml_gen = 1;

            // Unit is bytes/timescale
            //`ifdef _EEESTART_SIM_USE_AXI_SYSTEM_VIP_
            //this.slave_cfg[i].id_width  = 8;
            //`else     
            //    this.slave_cfg[i].id_width  = 7;
            //`endif
	    if (3==i) begin
		this.slave_cfg[i].id_width  = 5;//qtw
	    end
	    else begin
		this.slave_cfg[i].id_width  = 8;
	    end

	    if (2==i) begin
		this.slave_cfg[i].data_width  = 64;//stream
	    end
	    else begin
		this.slave_cfg[i].data_width  = 256;
	    end

	    if (2 == i) begin
                this.slave_cfg[i].axi_interface_type  = svt_axi_port_configuration::AXI4_STREAM;
	    end
	    else begin
                this.slave_cfg[i].axi_interface_type  = svt_axi_port_configuration::ACE_LITE;
	    end

	    if (2==i) begin
		this.slave_cfg[i].tstrb_enable   = 0;//stream
		this.slave_cfg[i].tuser_enable   = 0;
		this.slave_cfg[i].tdest_enable   = 0;
	    end

	    //if (3==i) begin
	    //    this.slave_cfg[i].sysco_interface_enable = 1;//qtw
	    //end
        end//for slave
    endfunction

endclass
`endif // GUARD_CUST_SVT_AXI_SYSTEM_CONFIGURATION_SV


