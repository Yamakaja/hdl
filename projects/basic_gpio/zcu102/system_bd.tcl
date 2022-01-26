source $ad_hdl_dir/projects/common/zcu102/zcu102_system_bd.tcl

source $ad_hdl_dir/projects/basic_gpio/common/basic_gpio_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

source $ad_hdl_dir/projects/common/xilinx/adi_xilinx_ila.tcl

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

sysid_gen_sys_init_file

setup_xvc 0x44A00000

ad_ila_setup_intf sys_cpu_clk sys_cpu_resetn 2048
ad_ila_connect_intf sys_cpu_clk axi_cpu_interconnect/S00_AXI
ad_ila_connect_intf sys_cpu_clk axi_cpu_interconnect/M00_AXI
ad_ila_connect_intf sys_cpu_clk axi_cpu_interconnect/M01_AXI
ad_ila_connect_intf sys_cpu_clk sys_ps8/GPIO_0
ad_ila_connect_intf sys_cpu_clk sys_ps8/SPI_0
ad_ila_connect_intf sys_cpu_clk sys_ps8/SPI_1

ad_ila_setup sys_cpu_clk 2048
ad_ila_connect sys_cpu_clk sys_ps8/emio_gpio_t
