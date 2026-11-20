logic[7:0]  rxn;
logic[7:0]  rxp;

logic[7:0]  txn;
logic[7:0]  txp;


assign   `DUT_PATH.pcie_rxn[0]  = rxn[0];
assign   `DUT_PATH.pcie_rxn[1]  = rxn[1];
assign   `DUT_PATH.pcie_rxn[2]  = rxn[2];
assign   `DUT_PATH.pcie_rxn[3]  = rxn[3];
assign   `DUT_PATH.pcie_rxn[4]  = rxn[4];
assign   `DUT_PATH.pcie_rxn[5]  = rxn[5];
assign   `DUT_PATH.pcie_rxn[6]  = rxn[6];
assign   `DUT_PATH.pcie_rxn[7]  = rxn[7];

assign   `DUT_PATH.pcie_rxp[0]  = rxp[0];
assign   `DUT_PATH.pcie_rxp[1]  = rxp[1];
assign   `DUT_PATH.pcie_rxp[2]  = rxp[2];
assign   `DUT_PATH.pcie_rxp[3]  = rxp[3];
assign   `DUT_PATH.pcie_rxp[4]  = rxp[4];
assign   `DUT_PATH.pcie_rxp[5]  = rxp[5];
assign   `DUT_PATH.pcie_rxp[6]  = rxp[6];
assign   `DUT_PATH.pcie_rxp[7]  = rxp[7];

assign   txn[0]  = `DUT_PATH.pcie_txn[0]  ;
assign   txn[1]  = `DUT_PATH.pcie_txn[1]  ;
assign   txn[2]  = `DUT_PATH.pcie_txn[2]  ;
assign   txn[3]  = `DUT_PATH.pcie_txn[3]  ;
assign   txn[4]  = `DUT_PATH.pcie_txn[4]  ;
assign   txn[5]  = `DUT_PATH.pcie_txn[5]  ;
assign   txn[6]  = `DUT_PATH.pcie_txn[6]  ;
assign   txn[7]  = `DUT_PATH.pcie_txn[7]  ;

assign   txp[0]  = `DUT_PATH.pcie_txp[0]  ;
assign   txp[1]  = `DUT_PATH.pcie_txp[1]  ;
assign   txp[2]  = `DUT_PATH.pcie_txp[2]  ;
assign   txp[3]  = `DUT_PATH.pcie_txp[3]  ;
assign   txp[4]  = `DUT_PATH.pcie_txp[4]  ;
assign   txp[5]  = `DUT_PATH.pcie_txp[5]  ;
assign   txp[6]  = `DUT_PATH.pcie_txp[6]  ;
assign   txp[7]  = `DUT_PATH.pcie_txp[7]  ;

//ep vip spd_0-->connect x1 port_num,is_root,link_width
`SIM_PCIE_INTF_DEF(0,0,1)

//ep vip spd_1-->connect x2
`SIM_PCIE_INTF_DEF(1,0,2)

//ep vip spd_2-->connect x4_0(RC)
`SIM_PCIE_INTF_DEF(2,0,4)

//rc vip spd_3-->connect x4_0(EP)
`SIM_PCIE_INTF_DEF(3,1,4)

//ep vip spd_4-->connect x4_1(RC)
`SIM_PCIE_INTF_DEF(4,0,4)

//rc vip spd_5-->connect x4_1(EP)
`SIM_PCIE_INTF_DEF(5,1,4)


assign link_mode        = test_top.dut.u_pcie_subsystem.u_pcie_wrap0.u_pcie_customer_reg_sub_shared.link_mode;
assign device_type_x4_0 = test_top.dut.u_pcie_subsystem.u_pcie_wrap0.u_pcie_customer_reg_sub_shared.x4_0_device_type;
assign device_type_x4_1 = test_top.dut.u_pcie_subsystem.u_pcie_wrap1.u_pcie_customer_reg_sub_direct.x4_1_device_type;

//for x1,x2,x4_0
always @(*) begin
    case (link_mode)
        2'h0:begin//mode A
		 `SIM_1LANE_CONNECTION(spd_0,0)
		 `SIM_1LANE_CONNECTION(spd_1,1)
		 case(device_type_x4_0)
                     4'h0,4'h5: begin//connect to vip RC
                               `SIM_2LANE_CONNECTION(spd_3,2)
                           end
                     4'h4,4'h6: begin//connect to vip EP
                               `SIM_2LANE_CONNECTION(spd_2,2)
                           end
                 endcase
	     end	
	2'h1:begin//mode B
		 `SIM_2LANE_CONNECTION(spd_1,0)
		 case(device_type_x4_0)
                     4'h0,4'h5: begin//connect to vip RC
                               `SIM_2LANE_CONNECTION(spd_3,2)
                           end
                     4'h4,4'h6: begin//connect to vip EP
                               `SIM_2LANE_CONNECTION(spd_2,2)
                           end
                 endcase
	     end
	2'h2:begin//mode C
		 case(device_type_x4_0)
                     4'h0,4'h5: begin//connect to vip RC
                               `SIM_4LANE_CONNECTION(spd_3,0)
                           end
                     4'h4,4'h6: begin//connect to vip EP
                               `SIM_4LANE_CONNECTION(spd_2,0)
                           end
                 endcase
	     end
    endcase

    
end

//for x4_1
always @(*) begin
    case(device_type_x4_1)
        4'h0,4'h5: begin//connect to vip RC
                  `SIM_4LANE_CONNECTION(spd_5,4)
              end
        4'h4,4'h6: begin//connect to vip EP
                  `SIM_4LANE_CONNECTION(spd_4,4)
              end
    endcase
end

