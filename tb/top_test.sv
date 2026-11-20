
`ifndef GUARD_PCIE_MULTI_LINK_TOPOLOGY
 `define GUARD_PCIE_MULTI_LINK_TOPOLOGY

// Serial Link Creation Begin

  //`SVT_PCIE_ICM_CREATE_PORT_INST(0,0)
  `SVT_PCIE_ICM_CREATE_PORT_INST(0,1)
  `SVT_PCIE_ICM_CREATE_LINK(0,spd_1) // Create link 3 using ports spd_6,spd_7
  `SVT_PCIE_ICM_SER_SER_LINK(0,`DUT_PATH,spd_1) //cross connect relevant (SERIAL) interface of link created in above step
  //`SVT_PCIE_ICM_DO_CONDITIONAL_INTERCONNECT(6,spd_6,7,spd_7) // Certain signal inter-connections are dependent on VIP parameter settings. This macro handles those connections and simplified the topology file 

  //RC
  //defparam SVT_PCIE_UI_PHY_INTERFACE_TYPE_P0 = `SVT_PCIE_UI_PHY_INTERFACE_TYPE_SERDES;
  //defparam SVT_PCIE_UI_DEVICE_IS_ROOT_P0 = 1;
  //defparam SVT_PCIE_UI_NUM_PHYSICAL_LANES_P0   = 16;
  //defparam SVT_PCIE_UI_HIERARCHY_NUMBER_P0 = 3;

  //EP
  defparam SVT_PCIE_UI_PHY_INTERFACE_TYPE_P1 = `SVT_PCIE_UI_PHY_INTERFACE_TYPE_SERDES;
  defparam SVT_PCIE_UI_DEVICE_IS_ROOT_P1 = 0;
  defparam SVT_PCIE_UI_NUM_PHYSICAL_LANES_P1   = 16;
  defparam SVT_PCIE_UI_HIERARCHY_NUMBER_P1 = 3;
  defparam SVT_PCIE_UI_PCIE_SPEC_VER_P1 = `SVT_PCIE_UI_PCIE_SPEC_VER_4_0;
  defparam SVT_PCIE_UI_PIPE_SPEC_VER_P1 = `SVT_PCIE_UI_PIPE_SPEC_VER_4_4;

// Serial Link Creation End

`endif //  `ifndef GUARD_PCIE_MULTI_LINK_TOPOLOGY
