
  wire         gpv_link_m08_to_power_m08_PwrDisc_ConnAck_tmp;
  wire         gpv_link_m08_to_power_m08_PwrDisc_SlvRdy_tmp;
  wire         gpv_link_m08_to_power_m08_PwrDisc_SocketConn_tmp;
  wire [11:0]  gpv_link_m08_to_power_m08_PwrReq_Data_tmp;
  wire [3:0]   gpv_link_m08_to_power_m08_PwrReq_RdCnt_tmp;
  wire [3:0]   gpv_link_m08_to_power_m08_PwrReq_RdPtr_tmp;
  wire [3:0]   gpv_link_m08_to_power_m08_PwrReq_WrCnt_tmp;
  wire [11:0]  gpv_link_m08_to_power_m08_PwrRsp_Data_tmp;
  wire [3:0]   gpv_link_m08_to_power_m08_PwrRsp_RdCnt_tmp;
  wire [3:0]   gpv_link_m08_to_power_m08_PwrRsp_RdPtr_tmp;
  wire [3:0]   gpv_link_m08_to_power_m08_PwrRsp_WrCnt_tmp;

  wire         link_m08_to_m08_pcie_T_PwrDisc_ConnAck_tmp;
  wire         link_m08_to_m08_pcie_T_PwrDisc_SlvRdy_tmp;
  wire         link_m08_to_m08_pcie_T_PwrDisc_SocketConn_tmp;
  wire [282:0] link_m08_to_m08_pcie_T_PwrReq_Data_tmp;
  wire [3:0]   link_m08_to_m08_pcie_T_PwrReq_RdCnt_tmp;
  wire [3:0]   link_m08_to_m08_pcie_T_PwrReq_RdPtr_tmp;
  wire [3:0]   link_m08_to_m08_pcie_T_PwrReq_WrCnt_tmp;
  wire [282:0] link_m08_to_m08_pcie_T_PwrRsp_Data_tmp;
  wire [3:0]   link_m08_to_m08_pcie_T_PwrRsp_RdCnt_tmp;
  wire [3:0]   link_m08_to_m08_pcie_T_PwrRsp_RdPtr_tmp;
  wire [3:0]   link_m08_to_m08_pcie_T_PwrRsp_WrCnt_tmp;

  bit clkreq_n_i[4];

pciess dut (
  .pcie_phy01_ate0(32'h0),
  .pcie_phy01_ate1(32'h0),
  .pcie_phy2_ate0(32'h0),
  .pcie_test_pins(),//output
  .pcie_mem_bus_clk(pcie_mem_bus_clk),
  .pcie_cfg_bus_clk(pcie_cfg_bus_clk),
  .aux_clk(aux_clk),
  .pcie_por_rst_n(pcie_cfg_bus_reset_n),
  .tzc_bypass(1'b1),//TODO
  //.pss_rst_n(pcie_cfg_bus_reset_n),
  //.pcie_test_clk(1'b0),
  //.pcie_test_rst_n(1'b0),
  .pcie_rxp(),
  .pcie_rxn(),
  .pcie_txp(),
  .pcie_txn(),
  .pcie_phy_resref_0(1'b0),//TODO
  .pcie_phy_resref_1(1'b0),//TODO
  .pcie_phy_resref_2(1'b0),//TODO
  .ref_alt_clk_p(phy_ref_clk_alt),
  .pcie_phy0_ref_pad_clk_m(~phy_ref_clk_wire[0]),
  .pcie_phy0_ref_pad_clk_p(phy_ref_clk_wire[0]),
  .pcie_phy1_ref_pad_clk_m(~phy_ref_clk_wire[1]),
  .pcie_phy1_ref_pad_clk_p(phy_ref_clk_wire[1]),
  .pcie_phy2_ref_pad_clk_m(~phy_ref_clk_wire[2]),
  .pcie_phy2_ref_pad_clk_p(phy_ref_clk_wire[2]),
  .pcie_x1_perst_n(),
  .pcie_x2_perst_n(),
  .pcie_x4_0_perst_n_i(),
  .pcie_x4_0_perst_n_o(),
  .pcie_x4_0_perst_n_oe(),
  .pcie_x4_1_perst_n_i(),
  .pcie_x4_1_perst_n_o(),
  .pcie_x4_1_perst_n_oe(),
  .pcie_x1_clkreq_n_i(clkreq_n[0]),
  .pcie_x1_clkreq_n_o(),
  .pcie_x1_clkreq_n_oe(),
  .pcie_x1_wake_n_i(wake_n[0]),
  .pcie_x1_wake_n_o(),
  .pcie_x1_wake_n_oe(),
  .pcie_x2_clkreq_n_i(clkreq_n[1]),
  .pcie_x2_clkreq_n_o(),
  .pcie_x2_clkreq_n_oe(),
  .pcie_x2_wake_n_i(wake_n[1]),
  .pcie_x2_wake_n_o(),
  .pcie_x2_wake_n_oe(),
  .pcie_x4_0_clkreq_n_i(),
  .pcie_x4_0_clkreq_n_o(),
  .pcie_x4_0_clkreq_n_oe(),
  .pcie_x4_0_wake_n_i(),
  .pcie_x4_0_wake_n_o(),
  .pcie_x4_0_wake_n_oe(),
  .pcie_x4_1_clkreq_n_i(),
  .pcie_x4_1_clkreq_n_o(),
  .pcie_x4_1_clkreq_n_oe(),
  .pcie_x4_1_wake_n_i(),
  .pcie_x4_1_wake_n_o(),
  .pcie_x4_1_wake_n_oe(),

  .pcie_phy0_jtag_tck(1'b0),
  .pcie_phy0_jtag_tdi(1'b0),
  .pcie_phy0_jtag_tdo(),
  .pcie_phy0_jtag_tdo_en(),
  .pcie_phy0_jtag_tms(1'b0),
  .pcie_phy0_jtag_trst_n(1'b0),
  .pcie_phy1_jtag_tck(1'b0),
  .pcie_phy1_jtag_tdi(1'b0),
  .pcie_phy1_jtag_tdo(),
  .pcie_phy1_jtag_tdo_en(),
  .pcie_phy1_jtag_tms(1'b0),
  .pcie_phy1_jtag_trst_n(1'b0),
  .pcie_phy2_jtag_tck(1'b0),
  .pcie_phy2_jtag_tdi(1'b0),
  .pcie_phy2_jtag_tdo(),
  .pcie_phy2_jtag_tdo_en(),
  .pcie_phy2_jtag_tms(1'b0),
  .pcie_phy2_jtag_trst_n(1'b0),

  // CTRL_NOC ingress is terminated by the integrated cnoc_niu_m08_pcie.
  // Both asynchronous NTTP links cross the PCIe subsystem boundary.  The
  // NIU AXI manager bus and its Idle handshake remain internal.
   .gpv_link_m08_to_power_m08_PwrDisc_ConnAck(gpv_link_m08_to_power_m08_PwrDisc_ConnAck_tmp),
   .gpv_link_m08_to_power_m08_PwrDisc_SlvRdy(gpv_link_m08_to_power_m08_PwrDisc_SlvRdy_tmp),
   .gpv_link_m08_to_power_m08_PwrDisc_SocketConn(gpv_link_m08_to_power_m08_PwrDisc_SocketConn_tmp),
   .gpv_link_m08_to_power_m08_PwrReq_Data(gpv_link_m08_to_power_m08_PwrReq_Data_tmp),
   .gpv_link_m08_to_power_m08_PwrReq_RdCnt(gpv_link_m08_to_power_m08_PwrReq_RdCnt_tmp),
   .gpv_link_m08_to_power_m08_PwrReq_RdPtr(gpv_link_m08_to_power_m08_PwrReq_RdPtr_tmp),
   .gpv_link_m08_to_power_m08_PwrReq_WrCnt(gpv_link_m08_to_power_m08_PwrReq_WrCnt_tmp),
   .gpv_link_m08_to_power_m08_PwrRsp_Data(gpv_link_m08_to_power_m08_PwrRsp_Data_tmp),
   .gpv_link_m08_to_power_m08_PwrRsp_RdCnt(gpv_link_m08_to_power_m08_PwrRsp_RdCnt_tmp),
   .gpv_link_m08_to_power_m08_PwrRsp_RdPtr(gpv_link_m08_to_power_m08_PwrRsp_RdPtr_tmp),
   .gpv_link_m08_to_power_m08_PwrRsp_WrCnt(gpv_link_m08_to_power_m08_PwrRsp_WrCnt_tmp),

   .link_m08_to_m08_pcie_T_PwrDisc_ConnAck(link_m08_to_m08_pcie_T_PwrDisc_ConnAck_tmp),
   .link_m08_to_m08_pcie_T_PwrDisc_SlvRdy(link_m08_to_m08_pcie_T_PwrDisc_SlvRdy_tmp),
   .link_m08_to_m08_pcie_T_PwrDisc_SocketConn(link_m08_to_m08_pcie_T_PwrDisc_SocketConn_tmp),
   .link_m08_to_m08_pcie_T_PwrReq_Data(link_m08_to_m08_pcie_T_PwrReq_Data_tmp),
   .link_m08_to_m08_pcie_T_PwrReq_RdCnt(link_m08_to_m08_pcie_T_PwrReq_RdCnt_tmp),
   .link_m08_to_m08_pcie_T_PwrReq_RdPtr(link_m08_to_m08_pcie_T_PwrReq_RdPtr_tmp),
   .link_m08_to_m08_pcie_T_PwrReq_WrCnt(link_m08_to_m08_pcie_T_PwrReq_WrCnt_tmp),
   .link_m08_to_m08_pcie_T_PwrRsp_Data(link_m08_to_m08_pcie_T_PwrRsp_Data_tmp),
   .link_m08_to_m08_pcie_T_PwrRsp_RdCnt(link_m08_to_m08_pcie_T_PwrRsp_RdCnt_tmp),
   .link_m08_to_m08_pcie_T_PwrRsp_RdPtr(link_m08_to_m08_pcie_T_PwrRsp_RdPtr_tmp),
   .link_m08_to_m08_pcie_T_PwrRsp_WrCnt(link_m08_to_m08_pcie_T_PwrRsp_WrCnt_tmp),

  // Host-bridge AXI ingress at the PCIe SS boundary.
  // Flattened pcie_inbound_axi SLAVE signals.
  .pcie_inbound_axi_awid(axi_if.master_if[1].awid),
  .pcie_inbound_axi_awaddr(axi_if.master_if[1].awaddr),
  .pcie_inbound_axi_awlen(axi_if.master_if[1].awlen),
  .pcie_inbound_axi_awsize(axi_if.master_if[1].awsize),
  .pcie_inbound_axi_awburst(axi_if.master_if[1].awburst),
  .pcie_inbound_axi_awlock(axi_if.master_if[1].awlock),
  .pcie_inbound_axi_awcache(axi_if.master_if[1].awcache),
  .pcie_inbound_axi_awprot(axi_if.master_if[1].awprot),
  .pcie_inbound_axi_awqos(axi_if.master_if[1].awqos),
  .pcie_inbound_axi_awuser(axi_if.master_if[1].awuser),
  .pcie_inbound_axi_awbar(axi_if.master_if[1].awbar),
  .pcie_inbound_axi_awsnoop(axi_if.master_if[1].awsnoop),
  .pcie_inbound_axi_awdomain(axi_if.master_if[1].awdomain),
  .pcie_inbound_axi_awvalid(axi_if.master_if[1].awvalid),
  .pcie_inbound_axi_awready(axi_if.master_if[1].awready),
  .pcie_inbound_axi_wdata(axi_if.master_if[1].wdata),
  .pcie_inbound_axi_wstrb(axi_if.master_if[1].wstrb),
  .pcie_inbound_axi_wuser(axi_if.master_if[1].wuser),
  .pcie_inbound_axi_wlast(axi_if.master_if[1].wlast),
  .pcie_inbound_axi_wvalid(axi_if.master_if[1].wvalid),
  .pcie_inbound_axi_wready(axi_if.master_if[1].wready),
  .pcie_inbound_axi_bid(axi_if.master_if[1].bid),
  .pcie_inbound_axi_bresp(axi_if.master_if[1].bresp),
  .pcie_inbound_axi_buser(axi_if.master_if[1].buser),
  .pcie_inbound_axi_bvalid(axi_if.master_if[1].bvalid),
  .pcie_inbound_axi_bready(axi_if.master_if[1].bready),
  .pcie_inbound_axi_arid(axi_if.master_if[1].arid),
  .pcie_inbound_axi_araddr(axi_if.master_if[1].araddr),
  .pcie_inbound_axi_arlen(axi_if.master_if[1].arlen),
  .pcie_inbound_axi_arsize(axi_if.master_if[1].arsize),
  .pcie_inbound_axi_arburst(axi_if.master_if[1].arburst),
  .pcie_inbound_axi_arlock(axi_if.master_if[1].arlock),
  .pcie_inbound_axi_arcache(axi_if.master_if[1].arcache),
  .pcie_inbound_axi_arprot(axi_if.master_if[1].arprot),
  .pcie_inbound_axi_arqos(axi_if.master_if[1].arqos),
  .pcie_inbound_axi_aruser(axi_if.master_if[1].aruser),
  .pcie_inbound_axi_arbar(axi_if.master_if[1].arbar),
  .pcie_inbound_axi_arsnoop(axi_if.master_if[1].arsnoop),
  .pcie_inbound_axi_ardomain(axi_if.master_if[1].ardomain),
  .pcie_inbound_axi_arvalid(axi_if.master_if[1].arvalid),
  .pcie_inbound_axi_arready(axi_if.master_if[1].arready),
  .pcie_inbound_axi_rid(axi_if.master_if[1].rid),
  .pcie_inbound_axi_rdata(axi_if.master_if[1].rdata),
  .pcie_inbound_axi_rresp(axi_if.master_if[1].rresp),
  .pcie_inbound_axi_ruser(axi_if.master_if[1].ruser),
  .pcie_inbound_axi_rlast(axi_if.master_if[1].rlast),
  .pcie_inbound_axi_rvalid(axi_if.master_if[1].rvalid),
  .pcie_inbound_axi_rready(axi_if.master_if[1].rready),
  // Flattened pcie_cmn_rni0_axi MASTER signals.
  .pcie_cmn_rni0_axi_awakeup(axi_if.slave_if[0].awakeup),
  .pcie_cmn_rni0_axi_awid(axi_if.slave_if[0].awid),
  .pcie_cmn_rni0_axi_awaddr(axi_if.slave_if[0].awaddr),
  .pcie_cmn_rni0_axi_awlen(axi_if.slave_if[0].awlen),
  .pcie_cmn_rni0_axi_awsize(axi_if.slave_if[0].awsize),
  .pcie_cmn_rni0_axi_awburst(axi_if.slave_if[0].awburst),
  .pcie_cmn_rni0_axi_awlock(axi_if.slave_if[0].awlock),
  .pcie_cmn_rni0_axi_awcache(axi_if.slave_if[0].awcache),
  .pcie_cmn_rni0_axi_awprot(axi_if.slave_if[0].awprot),
  .pcie_cmn_rni0_axi_awqos(axi_if.slave_if[0].awqos),
  .pcie_cmn_rni0_axi_awuser(axi_if.slave_if[0].awuser),
  .pcie_cmn_rni0_axi_awbar(axi_if.slave_if[0].awbar),
  .pcie_cmn_rni0_axi_awsnoop(axi_if.slave_if[0].awsnoop),
  .pcie_cmn_rni0_axi_awdomain(axi_if.slave_if[0].awdomain),
  .pcie_cmn_rni0_axi_awvalid(axi_if.slave_if[0].awvalid),
  .pcie_cmn_rni0_axi_awready(axi_if.slave_if[0].awready),
  .pcie_cmn_rni0_axi_wdata(axi_if.slave_if[0].wdata),
  .pcie_cmn_rni0_axi_wstrb(axi_if.slave_if[0].wstrb),
  .pcie_cmn_rni0_axi_wuser(axi_if.slave_if[0].wuser),
  .pcie_cmn_rni0_axi_wlast(axi_if.slave_if[0].wlast),
  .pcie_cmn_rni0_axi_wvalid(axi_if.slave_if[0].wvalid),
  .pcie_cmn_rni0_axi_wready(axi_if.slave_if[0].wready),
  .pcie_cmn_rni0_axi_bid(axi_if.slave_if[0].bid),//TODO input z
  .pcie_cmn_rni0_axi_bresp(axi_if.slave_if[0].bresp),//TODO input z
  .pcie_cmn_rni0_axi_buser(axi_if.slave_if[0].buser),//TODO input z
  .pcie_cmn_rni0_axi_bvalid(axi_if.slave_if[0].bvalid),
  .pcie_cmn_rni0_axi_bready(axi_if.slave_if[0].bready),
  .pcie_cmn_rni0_axi_arid(axi_if.slave_if[0].arid),
  .pcie_cmn_rni0_axi_araddr(axi_if.slave_if[0].araddr),
  .pcie_cmn_rni0_axi_arlen(axi_if.slave_if[0].arlen),
  .pcie_cmn_rni0_axi_arsize(axi_if.slave_if[0].arsize),
  .pcie_cmn_rni0_axi_arburst(axi_if.slave_if[0].arburst),
  .pcie_cmn_rni0_axi_arlock(axi_if.slave_if[0].arlock),
  .pcie_cmn_rni0_axi_arcache(axi_if.slave_if[0].arcache),
  .pcie_cmn_rni0_axi_arprot(axi_if.slave_if[0].arprot),
  .pcie_cmn_rni0_axi_arqos(axi_if.slave_if[0].arqos),
  .pcie_cmn_rni0_axi_aruser(axi_if.slave_if[0].aruser),
  .pcie_cmn_rni0_axi_arbar(axi_if.slave_if[0].arbar),
  .pcie_cmn_rni0_axi_arsnoop(axi_if.slave_if[0].arsnoop),
  .pcie_cmn_rni0_axi_ardomain(axi_if.slave_if[0].ardomain),
  .pcie_cmn_rni0_axi_arvalid(axi_if.slave_if[0].arvalid),
  .pcie_cmn_rni0_axi_arready(axi_if.slave_if[0].arready),
  .pcie_cmn_rni0_axi_rid(axi_if.slave_if[0].rid),//TODO input z
  .pcie_cmn_rni0_axi_rdata(axi_if.slave_if[0].rdata),//TODO input z
  .pcie_cmn_rni0_axi_rresp(axi_if.slave_if[0].rresp),//TODO input z
  .pcie_cmn_rni0_axi_ruser(axi_if.slave_if[0].ruser),//TODO input z
  .pcie_cmn_rni0_axi_rlast(axi_if.slave_if[0].rlast),
  .pcie_cmn_rni0_axi_rvalid(axi_if.slave_if[0].rvalid),
  .pcie_cmn_rni0_axi_rready(axi_if.slave_if[0].rready),
  // Flattened pcie_cmn_rni1_axi MASTER signals.
  .pcie_cmn_rni1_axi_awakeup(axi_if.slave_if[1].awakeup),
  .pcie_cmn_rni1_axi_awid(axi_if.slave_if[1].awid),
  .pcie_cmn_rni1_axi_awaddr(axi_if.slave_if[1].awaddr),
  .pcie_cmn_rni1_axi_awlen(axi_if.slave_if[1].awlen),
  .pcie_cmn_rni1_axi_awsize(axi_if.slave_if[1].awsize),
  .pcie_cmn_rni1_axi_awburst(axi_if.slave_if[1].awburst),
  .pcie_cmn_rni1_axi_awlock(axi_if.slave_if[1].awlock),
  .pcie_cmn_rni1_axi_awcache(axi_if.slave_if[1].awcache),
  .pcie_cmn_rni1_axi_awprot(axi_if.slave_if[1].awprot),
  .pcie_cmn_rni1_axi_awqos(axi_if.slave_if[1].awqos),
  .pcie_cmn_rni1_axi_awuser(axi_if.slave_if[1].awuser),
  .pcie_cmn_rni1_axi_awbar(axi_if.slave_if[1].awbar),
  .pcie_cmn_rni1_axi_awsnoop(axi_if.slave_if[1].awsnoop),
  .pcie_cmn_rni1_axi_awdomain(axi_if.slave_if[1].awdomain),
  .pcie_cmn_rni1_axi_awvalid(axi_if.slave_if[1].awvalid),
  .pcie_cmn_rni1_axi_awready(axi_if.slave_if[1].awready),
  .pcie_cmn_rni1_axi_wdata(axi_if.slave_if[1].wdata),
  .pcie_cmn_rni1_axi_wstrb(axi_if.slave_if[1].wstrb),
  .pcie_cmn_rni1_axi_wuser(axi_if.slave_if[1].wuser),
  .pcie_cmn_rni1_axi_wlast(axi_if.slave_if[1].wlast),
  .pcie_cmn_rni1_axi_wvalid(axi_if.slave_if[1].wvalid),
  .pcie_cmn_rni1_axi_wready(axi_if.slave_if[1].wready),
  .pcie_cmn_rni1_axi_bid(axi_if.slave_if[1].bid),
  .pcie_cmn_rni1_axi_bresp(axi_if.slave_if[1].bresp),
  .pcie_cmn_rni1_axi_buser(axi_if.slave_if[1].buser),
  .pcie_cmn_rni1_axi_bvalid(axi_if.slave_if[1].bvalid),
  .pcie_cmn_rni1_axi_bready(axi_if.slave_if[1].bready),
  .pcie_cmn_rni1_axi_arid(axi_if.slave_if[1].arid),
  .pcie_cmn_rni1_axi_araddr(axi_if.slave_if[1].araddr),
  .pcie_cmn_rni1_axi_arlen(axi_if.slave_if[1].arlen),
  .pcie_cmn_rni1_axi_arsize(axi_if.slave_if[1].arsize),
  .pcie_cmn_rni1_axi_arburst(axi_if.slave_if[1].arburst),
  .pcie_cmn_rni1_axi_arlock(axi_if.slave_if[1].arlock),
  .pcie_cmn_rni1_axi_arcache(axi_if.slave_if[1].arcache),
  .pcie_cmn_rni1_axi_arprot(axi_if.slave_if[1].arprot),
  .pcie_cmn_rni1_axi_arqos(axi_if.slave_if[1].arqos),
  .pcie_cmn_rni1_axi_aruser(axi_if.slave_if[1].aruser),
  .pcie_cmn_rni1_axi_arbar(axi_if.slave_if[1].arbar),
  .pcie_cmn_rni1_axi_arsnoop(axi_if.slave_if[1].arsnoop),
  .pcie_cmn_rni1_axi_ardomain(axi_if.slave_if[1].ardomain),
  .pcie_cmn_rni1_axi_arvalid(axi_if.slave_if[1].arvalid),
  .pcie_cmn_rni1_axi_arready(axi_if.slave_if[1].arready),
  .pcie_cmn_rni1_axi_rid(axi_if.slave_if[1].rid),
  .pcie_cmn_rni1_axi_rdata(axi_if.slave_if[1].rdata),
  .pcie_cmn_rni1_axi_rresp(axi_if.slave_if[1].rresp),
  .pcie_cmn_rni1_axi_ruser(axi_if.slave_if[1].ruser),
  .pcie_cmn_rni1_axi_rlast(axi_if.slave_if[1].rlast),
  .pcie_cmn_rni1_axi_rvalid(axi_if.slave_if[1].rvalid),
  .pcie_cmn_rni1_axi_rready(axi_if.slave_if[1].rready),
  // Flattened pcie_cmn_rnd_qtw MASTER signals.
  .pcie_cmn_rnd_qtw_awid(axi_if.slave_if[3].awid[4:0]),
  .pcie_cmn_rnd_qtw_awaddr(axi_if.slave_if[3].awaddr),
  .pcie_cmn_rnd_qtw_awregion(axi_if.slave_if[3].awregion),
  .pcie_cmn_rnd_qtw_awlen(axi_if.slave_if[3].awlen),
  .pcie_cmn_rnd_qtw_awsize(axi_if.slave_if[3].awsize),
  .pcie_cmn_rnd_qtw_awburst(axi_if.slave_if[3].awburst),
  .pcie_cmn_rnd_qtw_awlock(axi_if.slave_if[3].awlock),
  .pcie_cmn_rnd_qtw_awcache(axi_if.slave_if[3].awcache),
  .pcie_cmn_rnd_qtw_awprot(axi_if.slave_if[3].awprot),
  .pcie_cmn_rnd_qtw_awqos(axi_if.slave_if[3].awqos),
  .pcie_cmn_rnd_qtw_awdomain(axi_if.slave_if[3].awdomain),
  .pcie_cmn_rnd_qtw_awsnoop(axi_if.slave_if[3].awsnoop),
  .pcie_cmn_rnd_qtw_awvalid(axi_if.slave_if[3].awvalid),
  .pcie_cmn_rnd_qtw_awready(axi_if.slave_if[3].awready),
  .pcie_cmn_rnd_qtw_wdata(axi_if.slave_if[3].wdata),
  .pcie_cmn_rnd_qtw_wstrb(axi_if.slave_if[3].wstrb),
  .pcie_cmn_rnd_qtw_wlast(axi_if.slave_if[3].wlast),
  .pcie_cmn_rnd_qtw_wvalid(axi_if.slave_if[3].wvalid),
  .pcie_cmn_rnd_qtw_wready(axi_if.slave_if[3].wready),
  .pcie_cmn_rnd_qtw_bid(axi_if.slave_if[3].bid[4:0]),//TODO input z
  .pcie_cmn_rnd_qtw_bresp(axi_if.slave_if[3].bresp),//TODO input z
  .pcie_cmn_rnd_qtw_bvalid(axi_if.slave_if[3].bvalid),
  .pcie_cmn_rnd_qtw_bready(axi_if.slave_if[3].bready),
  .pcie_cmn_rnd_qtw_arid(axi_if.slave_if[3].arid[4:0]),
  .pcie_cmn_rnd_qtw_araddr(axi_if.slave_if[3].araddr),
  .pcie_cmn_rnd_qtw_arregion(axi_if.slave_if[3].arregion),
  .pcie_cmn_rnd_qtw_arlen(axi_if.slave_if[3].arlen),
  .pcie_cmn_rnd_qtw_arsize(axi_if.slave_if[3].arsize),
  .pcie_cmn_rnd_qtw_arburst(axi_if.slave_if[3].arburst),
  .pcie_cmn_rnd_qtw_arlock(axi_if.slave_if[3].arlock),
  .pcie_cmn_rnd_qtw_arcache(axi_if.slave_if[3].arcache),
  .pcie_cmn_rnd_qtw_arprot(axi_if.slave_if[3].arprot),
  .pcie_cmn_rnd_qtw_arqos(axi_if.slave_if[3].arqos),
  .pcie_cmn_rnd_qtw_ardomain(axi_if.slave_if[3].ardomain),
  .pcie_cmn_rnd_qtw_arsnoop(axi_if.slave_if[3].arsnoop),
  .pcie_cmn_rnd_qtw_arvalid(axi_if.slave_if[3].arvalid),
  .pcie_cmn_rnd_qtw_arready(axi_if.slave_if[3].arready),
  .pcie_cmn_rnd_qtw_rid(axi_if.slave_if[3].rid[4:0]),//TODO input z
  .pcie_cmn_rnd_qtw_rdata(axi_if.slave_if[3].rdata),//TODO input z
  .pcie_cmn_rnd_qtw_rresp(axi_if.slave_if[3].rresp),//TODO input z
  .pcie_cmn_rnd_qtw_rlast(axi_if.slave_if[3].rlast),//TODO input z
  .pcie_cmn_rnd_qtw_rvalid(axi_if.slave_if[3].rvalid),
  .pcie_cmn_rnd_qtw_rready(axi_if.slave_if[3].rready),
  .pcie_cmn_rnd_qtw_acvalid(axi_if.slave_if[3].acvalid),
  .pcie_cmn_rnd_qtw_acready(axi_if.slave_if[3].acready),
  .pcie_cmn_rnd_qtw_acaddr(axi_if.slave_if[3].acaddr),
  .pcie_cmn_rnd_qtw_acprot(axi_if.slave_if[3].acprot),
  .pcie_cmn_rnd_qtw_acsnoop(axi_if.slave_if[3].acsnoop),
  .pcie_cmn_rnd_qtw_acvmidext(axi_if.slave_if[3].acvmidext),//TODO input z
  .pcie_cmn_rnd_qtw_crvalid(axi_if.slave_if[3].crvalid),
  .pcie_cmn_rnd_qtw_crready(axi_if.slave_if[3].crready),
  .pcie_cmn_rnd_qtw_crresp(axi_if.slave_if[3].crresp),
  .pcie_cmn_rnd_qtw_awakeup(axi_if.slave_if[3].awakeup),
  .pcie_cmn_rnd_qtw_acwakeup(axi_if.slave_if[3].acwakeup),
  .pcie_cmn_rnd_qtw_syscoreq(axi_if.slave_if[3].syscoreq),
  .pcie_cmn_rnd_qtw_syscoack(axi_if.slave_if[3].syscoack),//TODO input z
  // The two ITS ICIDI links are combined by the internal 2x1 BAS switch.
  // ICIDT carries a one-bit source ID toward CMN; ICIDIT carries a one-bit
  // destination ID back to the selected ITS.
  .pcie_cmn_axi_clk(axi_if.slave_if[2].aclk),//->msi/msix
  .pcie_cmn_axi_reset_n(axi_if.slave_if[2].aresetn),
  .pcie_cmn_its_axis_icidtvalid(axi_if.slave_if[2].tvalid),
  .pcie_cmn_its_axis_icidtready(axi_if.slave_if[2].tready),
  .pcie_cmn_its_axis_icidtwakeup(axi_if.slave_if[2].twakeup),
  .pcie_cmn_its_axis_icidtdata(axi_if.slave_if[2].tdata),
  .pcie_cmn_its_axis_icidtkeep(axi_if.slave_if[2].tkeep),
  .pcie_cmn_its_axis_icidtid(axi_if.slave_if[2].tid),
  .pcie_cmn_its_axis_icidtlast(axi_if.slave_if[2].tlast),
  .pcie_cmn_its_axis_icditvalid(axi_if.master_if[2].tvalid),//<-- cfg its
  .pcie_cmn_its_axis_icditready(axi_if.master_if[2].tready),
  .pcie_cmn_its_axis_icditwakeup(axi_if.master_if[2].twakeup),
  .pcie_cmn_its_axis_icditdata(axi_if.master_if[2].tdata),
  .pcie_cmn_its_axis_icditdest(axi_if.master_if[2].tdest),
  .pcie_cmn_its_axis_icditlast(axi_if.master_if[2].tlast),

  // PMU-facing local low-power controller interface. The internal leaf/root
  // Q-channels stay inside PCIe SS and are not exposed at this boundary.
  .pcie_pmu_rst_ctrl_req(1'h0),
  .pcie_pmu_rst_ctrl_ack(),
  .pcie_pmu_clk_ctrl_req(43'h0),
  .pcie_pmu_clk_ctrl_ack(),
  .pcie_pmu_lpd_q_req(8'h0),
  .pcie_pmu_lpd_q_ack(),

  .pcie_pso_hf(1'h0),
  .pcie_pso_lf(1'h0),
  .pcie_pso_hf_ack(),
  .pcie_pso_lf_ack(),
  .pcie_lowpower_irq(),
  .pcie_qch_clk_ctrl_timeout_irq(),
  .pcie_qch_lpd_q_timeout_irq(),
  .pcie_reset_ctrl_irq(),
  // Per-controller interrupt order: [0]=x1, [1]=x2, [2]=x4_0, [3]=x4_1.
  .pcie_int_core(),
  .pcie_dtim_int(),
  .pcie_dtim_err_tresp_oas_int(),
  .pcie_dtim_err_tresp_uid_int(),
  .pcie_dtim_err_icpl_uc_int(),
  .pcie_dtim_err_ireq_opertn_int(),
  .pcie_dtim_err_ireq_to_int(),
  // IDE interrupt order: global [0]=x4_0, [1]=x4_1.
  .pcie_ide_glb_irq(),
  .pcie_ide_aes_x4_0_irq(),
  .pcie_ide_aes_x4_1_irq(),

  .pcie_gte_tsc_gray_in(64'h0),
  .pcie_gte_cs_irq(),

  // TZC bypass is a secure, lockable PCIE_SS_REG control.  TZC interrupt
  // remains a subsystem output.
  .pcie_tzc_int(),
  // TBU PMU snapshot order: [0]=SMMU0/TBU0, [1]=SMMU1/TBU1.
  .pcie_smmu_tbu_pmusnapshot_req(2'h0),
  .pcie_smmu_tbu_pmusnapshot_ack(),
  .pcie_smmu_tcu_pmusnapshot_req(1'h0),
  .pcie_smmu_tcu_pmusnapshot_ack(),

  // TBU interrupt order: [0]=SMMU0/TBU0, [1]=SMMU1/TBU1.
  .pcie_smmu_tbu_axi_mon_irq(),//output
  .pcie_smmu_tbu_pmu_irq(),
  .pcie_smmu_tbu_pmu_irq_chk(),
  .pcie_smmu_tbu_ras_irq(),
  .pcie_smmu_tbu_ras_irq_chk(),
  .pcie_smmu_tcu_event_q_irq_s(),
  .pcie_smmu_tcu_event_q_irq_ns(),
  .pcie_smmu_tcu_pri_q_irq_ns(),
  .pcie_smmu_tcu_cmd_sync_irq_ns(),
  .pcie_smmu_tcu_cmd_sync_irq_s(),
  .pcie_smmu_tcu_global_irq_ns(),
  .pcie_smmu_tcu_global_irq_s(),
  .pcie_smmu_tcu_ras_irq(),
  .pcie_smmu_tcu_pmu_irq(),
  .pcie_smmu_tcu_fmu_err_int(),
  .pcie_smmu_tcu_fmu_errchk_int(),
  .pcie_smmu_tcu_fmu_fault_int(),
  .pcie_smmu_tcu_fmu_faultchk_int(),

  // TCU F-channel connection to the system FMU/safety manager.
  .pcie_smmu_tcu_freq(4'h0),
  .pcie_smmu_tcu_freq_chk(4'h0),
  .pcie_smmu_tcu_fack(),
  .pcie_smmu_tcu_fack_chk(),

  // ADB fault handshake order: [0]=SMMU0, [1]=SMMU1.
  .pcie_smmu_adb_slv_fault_req(),
  .pcie_smmu_adb_slv_fault_req_chk(),
  .pcie_smmu_adb_slv_fault_ack(2'h0),
  .pcie_smmu_adb_slv_fault_ack_chk(2'h0),
  .pcie_smmu_adb_mst_fault_req(),
  .pcie_smmu_adb_mst_fault_req_chk(),
  .pcie_smmu_adb_mst_fault_ack(2'h0),
  .pcie_smmu_adb_mst_fault_ack_chk(2'h0),

  // Error-collector outputs. The collector itself is programmed through
  // pcie_cfg_bus M16.
  .pcie_error_collector_intr(),
  .pcie_error_collector_rst_req(),
  .pcie_error_collector_parity_alarm()
);

common_niu_gpv#(2) gpv_init_niu(
    // clk & rst
    .clk_gpv(pcie_cfg_bus_clk_cycle)                        ,
    .rstn_gpv(pcie_cfg_bus_reset_n)                       ,

    //axi interface
    .gpv_ar_addr(48'h0)                    ,
    .gpv_ar_burst(2'h0)                   ,
    .gpv_ar_cache(4'h0)                   ,
    .gpv_ar_id(8'h0)                      ,
    .gpv_ar_len(8'h0)                     ,
    .gpv_ar_lock(1'h0)                    ,
    .gpv_ar_prot(3'h0)                    ,
    .gpv_ar_ready()                   ,
    .gpv_ar_size(3'h0)                    ,
    .gpv_ar_user(64'h0)                    ,
    .gpv_ar_valid(1'h0)                   ,
    .gpv_aw_addr(48'h0)                    ,
    .gpv_aw_burst(2'h0)                   ,
    .gpv_aw_cache(4'h0)                   ,
    .gpv_aw_id(8'h0)                      ,
    .gpv_aw_len(8'h0)                     ,
    .gpv_aw_lock(1'h0)                    ,
    .gpv_aw_prot(3'h0)                    ,
    .gpv_aw_ready()                   ,
    .gpv_aw_user(64'h0)                    ,
    .gpv_aw_size(3'h0)                    ,
    .gpv_aw_valid(1'h0)                   ,
    .gpv_b_id()                       ,
    .gpv_b_ready(1'h0)                    ,
    .gpv_b_resp()                     ,
    .gpv_b_valid()                    ,
    .gpv_r_data()                     ,
    .gpv_r_id()                       ,
    .gpv_r_last()                     ,
    .gpv_r_ready(1'h0)                    ,
    .gpv_r_resp()                     ,
    .gpv_r_valid()                    ,
    .gpv_w_data(64'h0)                     ,
    .gpv_w_last(1'h0)                     ,
    .gpv_w_ready()                    ,
    .gpv_w_strb(8'h0)                     ,
    .gpv_w_valid(1'h0)                    ,


    //gpv interface
    .gpv_to_ss_PwrDisc_ConnAck(gpv_link_m08_to_power_m08_PwrDisc_ConnAck_tmp)      ,
    .gpv_to_ss_PwrDisc_SlvRdy(gpv_link_m08_to_power_m08_PwrDisc_SlvRdy_tmp)       ,
    .gpv_to_ss_PwrDisc_SocketConn(gpv_link_m08_to_power_m08_PwrDisc_SocketConn_tmp)   ,
    .gpv_to_ss_PwrReq_Data(gpv_link_m08_to_power_m08_PwrReq_Data_tmp)          ,
    .gpv_to_ss_PwrReq_RdCnt(gpv_link_m08_to_power_m08_PwrReq_RdCnt_tmp)         ,
    .gpv_to_ss_PwrReq_RdPtr(gpv_link_m08_to_power_m08_PwrReq_RdPtr_tmp)         ,
    .gpv_to_ss_PwrReq_WrCnt(gpv_link_m08_to_power_m08_PwrReq_WrCnt_tmp)         ,
    .gpv_to_ss_PwrRsp_Data(gpv_link_m08_to_power_m08_PwrRsp_Data_tmp)          ,
    .gpv_to_ss_PwrRsp_RdCnt(gpv_link_m08_to_power_m08_PwrRsp_RdCnt_tmp)         ,
    .gpv_to_ss_PwrRsp_RdPtr(gpv_link_m08_to_power_m08_PwrRsp_RdPtr_tmp)         ,
    .gpv_to_ss_PwrRsp_WrCnt(gpv_link_m08_to_power_m08_PwrRsp_WrCnt_tmp)         

);

common_niu_init64#(0) link_init_niu(
	.init64_to_Link_PwrDisc_ConnAck(link_m08_to_m08_pcie_T_PwrDisc_ConnAck_tmp)
,	.init64_to_Link_PwrDisc_SlvRdy(link_m08_to_m08_pcie_T_PwrDisc_SlvRdy_tmp)
,	.init64_to_Link_PwrDisc_SocketConn(link_m08_to_m08_pcie_T_PwrDisc_SocketConn_tmp)
,	.init64_to_Link_PwrReq_Data(link_m08_to_m08_pcie_T_PwrReq_Data_tmp)
,	.init64_to_Link_PwrReq_RdCnt(link_m08_to_m08_pcie_T_PwrReq_RdCnt_tmp)
,	.init64_to_Link_PwrReq_RdPtr(link_m08_to_m08_pcie_T_PwrReq_RdPtr_tmp)
,	.init64_to_Link_PwrReq_WrCnt(link_m08_to_m08_pcie_T_PwrReq_WrCnt_tmp)
,	.init64_to_Link_PwrRsp_Data(link_m08_to_m08_pcie_T_PwrRsp_Data_tmp)
,	.init64_to_Link_PwrRsp_RdCnt(link_m08_to_m08_pcie_T_PwrRsp_RdCnt_tmp)
,	.init64_to_Link_PwrRsp_RdPtr(link_m08_to_m08_pcie_T_PwrRsp_RdPtr_tmp)
,	.init64_to_Link_PwrRsp_WrCnt(link_m08_to_m08_pcie_T_PwrRsp_WrCnt_tmp)
,	.clk_init(pcie_cfg_bus_clk) 
,	.init_araddr(axi_if.master_if[0].araddr)
,	.init_arburst(axi_if.master_if[0].arburst)
,	.init_arcache(axi_if.master_if[0].arcache)
,	.init_arid(axi_if.master_if[0].arid)
,	.init_arlen(axi_if.master_if[0].arlen)
,	.init_arlock(axi_if.master_if[0].arlock)
,	.init_arprot(axi_if.master_if[0].arprot)
,	.init_arready(axi_if.master_if[0].arready)
,	.init_arsize(axi_if.master_if[0].arsize)
,	.init_aruser(axi_if.master_if[0].aruser)
,	.init_arvalid(axi_if.master_if[0].arvalid)
,	.init_awaddr(axi_if.master_if[0].awaddr)
,	.init_awburst(axi_if.master_if[0].awburst)
,	.init_awcache(axi_if.master_if[0].awcache)
,	.init_awid(axi_if.master_if[0].awid)
,	.init_awlen(axi_if.master_if[0].awlen)
,	.init_awlock(axi_if.master_if[0].awlock)
,	.init_awprot(axi_if.master_if[0].awprot)
,	.init_awready(axi_if.master_if[0].awready)
,	.init_awsize(axi_if.master_if[0].awsize)
,	.init_awuser(axi_if.master_if[0].awuser)
,	.init_awvalid(axi_if.master_if[0].awvalid)
,	.init_bid(axi_if.master_if[0].bid)
,	.init_bready(axi_if.master_if[0].bready)
,	.init_bresp(axi_if.master_if[0].bresp)
,	.init_bvalid(axi_if.master_if[0].bvalid)
,	.init_rdata(axi_if.master_if[0].rdata)
,	.init_rid(axi_if.master_if[0].rid)
,	.init_rlast(axi_if.master_if[0].rlast)
,	.init_rready(axi_if.master_if[0].rready)
,	.init_rresp(axi_if.master_if[0].rresp)
,	.init_rvalid(axi_if.master_if[0].rvalid)
,	.init_wdata(axi_if.master_if[0].wdata)
,	.init_wlast(axi_if.master_if[0].wlast)
,	.init_wready(axi_if.master_if[0].wready)
,	.init_wstrb(axi_if.master_if[0].wstrb)
,	.init_wvalid(axi_if.master_if[0].wvalid)
,	.power_init64_Idle()
,	.power_init64_IdleAck()
,	.power_init64_IdleReq(1'h0)
,	.rstn_init(pcie_cfg_bus_reset_n) 
,	.test_mode(1'b0)
);

//for x4_0
assign dut.pcie_x4_0_perst_n_i =  dut.pcie_x4_0_perst_n_oe ?  1'bz : pcie_cfg_bus_reset_n;

//for x4_1
assign dut.pcie_x4_1_perst_n_i =  dut.pcie_x4_1_perst_n_oe ?  1'bz : pcie_cfg_bus_reset_n;

//for x1
pullup(clkreq_n[0]);
assign clkreq_n[0] = dut.pcie_x1_clkreq_n_oe ? 1'bz : dut.pcie_x1_clkreq_n_o ;

//for x2
pullup(clkreq_n[1]);
assign clkreq_n[1] = dut.pcie_x2_clkreq_n_oe ? 1'bz : dut.pcie_x2_clkreq_n_o ;

//for x4_0
pullup(clkreq_n[2]);//vip ep
pullup(clkreq_n[3]);//vip rc
assign dut.pcie_x4_0_clkreq_n_i = (device_type_x4_0 == 4'h4) ? clkreq_n[2] : (device_type_x4_0 == 4'h0) ? clkreq_n[3] : 1'bz;
assign clkreq_n[2] = (device_type_x4_0 == 4'h4) ? (dut.pcie_x4_0_clkreq_n_oe ? 1'bz : dut.pcie_x4_0_clkreq_n_o) : 1'bz;
assign clkreq_n[3] = (device_type_x4_0 == 4'h0) ? (dut.pcie_x4_0_clkreq_n_oe ? 1'bz : dut.pcie_x4_0_clkreq_n_o) : 1'bz;

//for x4_1
pullup(clkreq_n[4]);//vip ep
pullup(clkreq_n[5]);//vip rc
assign dut.pcie_x4_1_clkreq_n_i = (device_type_x4_1 == 4'h4) ? clkreq_n[4] : (device_type_x4_1== 4'h0) ? clkreq_n[5] : 1'bz;
assign clkreq_n[4] = (device_type_x4_1 == 4'h4) ? (dut.pcie_x4_1_clkreq_n_oe ? 1'bz : dut.pcie_x4_1_clkreq_n_o) : 1'bz;
assign clkreq_n[5] = (device_type_x4_1 == 4'h0) ? (dut.pcie_x4_1_clkreq_n_oe ? 1'bz : dut.pcie_x4_1_clkreq_n_o) : 1'bz;


pullup(wake_n[0]);
assign  wake_n[0]= dut.pcie_x1_wake_n_oe ? 1'bz : dut.pcie_x1_wake_n_o;//x1 is rc,so pcie_x1_wake_n_oe must be de-asserted all time.

pullup(wake_n[1]);
assign  wake_n[1]= dut.pcie_x2_wake_n_oe ? 1'bz : dut.pcie_x2_wake_n_o;//x2 is rc,so pcie_x1_wake_n_oe must be de-asserted all time.

//for x4_0
pullup(wake_n[2]);//vip ep
pullup(wake_n[3]);//vip rc
assign dut.pcie_x4_0_wake_n_i = (device_type_x4_0 == 4'h4) ? wake_n[2] : (device_type_x4_0 == 4'h0) ?  wake_n[3] : 1'bz;//dut is rc. ep vip drv rc's input sig.
assign wake_n[2] = (device_type_x4_0 == 4'h4) ? (dut.pcie_x4_0_wake_n_oe ? 1'bz : dut.pcie_x4_0_wake_n_o) : 1'bz;  
assign wake_n[3] = (device_type_x4_0 == 4'h0) ? (dut.pcie_x4_0_wake_n_oe ? 1'bz : dut.pcie_x4_0_wake_n_o) : 1'bz;

//for x4_1
pullup(wake_n[4]);//vip ep
pullup(wake_n[5]);//vip rc
assign dut.pcie_x4_1_wake_n_i = (device_type_x4_1 == 4'h4) ? wake_n[4] : (device_type_x4_1 == 4'h0) ? wake_n[5] :1'bz;//dut is rc. ep vip drv rc's input sig.
assign wake_n[4] = (device_type_x4_1 == 4'h4) ? (dut.pcie_x4_1_wake_n_oe ? 1'bz : dut.pcie_x4_1_wake_n_o) : 1'bz;  
assign wake_n[5] = (device_type_x4_1 == 4'h0) ? (dut.pcie_x4_1_wake_n_oe ? 1'bz : dut.pcie_x4_1_wake_n_o) : 1'bz;


//tie some signal to constant value.
//assign axi_if.slave_if[0].awid[15:4]  = 12'h0;
////assign axi_if.slave_if[0].wid  = axi_if.slave_if[0].awid;
//assign axi_if.slave_if[0].wid  = 15'h0;
////assign axi_if.slave_if[0].bid[15:4]   = 12'h0;
//assign axi_if.slave_if[0].arid[15:4]  = 12'h0;
//assign axi_if.slave_if[0].rid[15:4]   = 14'h0;
// qtw id is 5bits width, need set axi width to 5., other is 8. slave_if[3]
// data width is set to 256. but stream data width is 64. for slave_if[2]


initial begin//TODO
    $display("start to force phy inner signal to recove clk of phy @%t",$time);
    force `PHY0_PATH.pma.ana.lane0.tx.tx_rxdet_m_result = 1'b1;
    force `PHY0_PATH.pma.ana.lane0.tx.tx_rxdet_p_result = 1'b1;
    force `PHY0_PATH.pma.ana.lane1.tx.tx_rxdet_m_result = 1'b1;
    force `PHY0_PATH.pma.ana.lane1.tx.tx_rxdet_p_result = 1'b1;
    force `PHY1_PATH.pma.ana.lane0.tx.tx_rxdet_m_result = 1'b1;
    force `PHY1_PATH.pma.ana.lane0.tx.tx_rxdet_p_result = 1'b1;
    force `PHY1_PATH.pma.ana.lane1.tx.tx_rxdet_m_result = 1'b1;
    force `PHY1_PATH.pma.ana.lane1.tx.tx_rxdet_p_result = 1'b1;
    force `PHY2_PATH.pma.ana.lane0.tx.tx_rxdet_m_result = 1'b1;
    force `PHY2_PATH.pma.ana.lane0.tx.tx_rxdet_p_result = 1'b1;
    force `PHY2_PATH.pma.ana.lane1.tx.tx_rxdet_m_result = 1'b1;
    force `PHY2_PATH.pma.ana.lane1.tx.tx_rxdet_p_result = 1'b1;
    force `PHY2_PATH.pma.ana.lane2.tx.tx_rxdet_m_result = 1'b1;
    force `PHY2_PATH.pma.ana.lane2.tx.tx_rxdet_p_result = 1'b1;
    force `PHY2_PATH.pma.ana.lane3.tx.tx_rxdet_m_result = 1'b1;
    force `PHY2_PATH.pma.ana.lane3.tx.tx_rxdet_p_result = 1'b1;
end

initial begin
    force  dut.pcie_cmn_rnd_qtw_syscoack =1'b0;
    @(posedge dut.pcie_cmn_rnd_qtw_syscoreq);
    #20ns;
    force  dut.pcie_cmn_rnd_qtw_syscoack =1'b1;
end

assign clkreq_n_i[0] =  test_top.dut.pcie_x1_clkreq_n_i;
assign clkreq_n_i[1] =  test_top.dut.pcie_x2_clkreq_n_i;
assign clkreq_n_i[2] =  test_top.dut.pcie_x4_0_clkreq_n_i;
assign clkreq_n_i[3] =  test_top.dut.pcie_x4_1_clkreq_n_i;
