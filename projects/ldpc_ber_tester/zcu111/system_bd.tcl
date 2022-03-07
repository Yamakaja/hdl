source $ad_hdl_dir/projects/common/zcu111/zcu111_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

global ad_hdl_dir

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

sysid_gen_sys_init_file

# Clocking Wizard
ad_ip_instance clk_wiz clock_gen [list \
    USE_PHASE_ALIGNMENT {true} \
    OPTIMIZE_CLOCKING_STRUCTURE_EN {true} \
    JITTER_SEL {Min_O_Jitter} \
    CLK_IN1_BOARD_INTERFACE {default_sysclk1_300mhz} \
    JITTER_OPTIONS {UI} \
    CLKIN1_UI_JITTER {0.01} \
    CLKOUT2_USED {true} \
    CLK_OUT1_PORT {core_clk} \
    CLK_OUT2_PORT {intf_clk} \
    CLKOUT1_REQUESTED_OUT_FREQ {666} \
    CLKOUT2_REQUESTED_OUT_FREQ {400.000} \
    USE_SAFE_CLOCK_STARTUP {false} \
    RESET_TYPE {ACTIVE_LOW} \
    PRIM_SOURCE {Differential_clock_capable_pin} \
    SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
    CLKIN2_UI_JITTER {0.010} \
    CLKIN1_JITTER_PS {33.330000000000005} \
    CLKIN2_JITTER_PS {100.0} \
    CLKOUT1_DRIVES {Buffer} \
    CLKOUT2_DRIVES {Buffer} \
    CLKOUT3_DRIVES {Buffer} \
    CLKOUT4_DRIVES {Buffer} \
    CLKOUT5_DRIVES {Buffer} \
    CLKOUT6_DRIVES {Buffer} \
    CLKOUT7_DRIVES {Buffer} \
    FEEDBACK_SOURCE {FDBK_AUTO} \
    MMCM_DIVCLK_DIVIDE {11} \
    MMCM_BANDWIDTH {HIGH} \
    MMCM_CLKFBOUT_MULT_F {58.000} \
    MMCM_CLKIN1_PERIOD {3.333} \
    MMCM_CLKIN2_PERIOD {10.0} \
    MMCM_REF_JITTER1 {0.010} \
    MMCM_REF_JITTER2 {0.010} \
    MMCM_CLKOUT0_DIVIDE_F {2.375} \
    MMCM_CLKOUT1_DIVIDE {4} \
    NUM_OUT_CLKS {2} \
    RESET_PORT {resetn} \
    CLKOUT1_JITTER {94.358} \
    CLKOUT1_PHASE_ERROR {194.551} \
    CLKOUT2_JITTER {101.204} \
    CLKOUT2_PHASE_ERROR {194.551}]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {default_sysclk1_300mhz ( 300 MHZ sysclk ) } Manual_Source {Auto}}  [get_bd_intf_pins clock_gen/CLK_IN1_D]

ad_connect sys_ps8/pl_resetn0 clock_gen/resetn

# Core clock
ad_ip_instance proc_sys_reset sys_core_rstgen
ad_ip_parameter sys_core_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_connect clock_gen/core_clk                   sys_core_clk
ad_connect sys_ps8/pl_resetn0                   sys_core_rstgen/ext_reset_in
ad_connect sys_core_clk                         sys_core_rstgen/slowest_sync_clk
ad_connect sys_core_rstgen/peripheral_aresetn   sys_core_resetn

set sys_core_clk    [get_bd_nets sys_core_clk]
set sys_core_resetn [get_bd_nets sys_core_resetn]

# Intf clock
ad_ip_instance proc_sys_reset sys_intf_rstgen
ad_ip_parameter sys_intf_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_connect clock_gen/intf_clk                   sys_intf_clk
ad_connect sys_ps8/pl_resetn0                   sys_intf_rstgen/ext_reset_in
ad_connect sys_intf_clk                         sys_intf_rstgen/slowest_sync_clk
ad_connect sys_intf_rstgen/peripheral_aresetn   sys_intf_resetn

set sys_intf_clk    [get_bd_nets sys_intf_clk]
set sys_intf_resetn [get_bd_nets sys_intf_resetn]

# SD-FEC
proc create_sd_fec_with_ber {id sd_addr ber_addr} {
    upvar sys_cpu_clk sys_cpu_clk
    upvar sys_cpu_resetn sys_cpu_resetn
    upvar sys_core_clk sys_core_clk
    upvar sys_core_resetn sys_core_resetn
    upvar sys_intf_clk sys_intf_clk
    upvar sys_intf_resetn sys_intf_resetn
    set ber_name ldpc_ber_tester_$id
    set sd_fec_name sd_fec_$id

    ad_ip_instance ldpc_ber_tester $ber_name [list \
        SEED_ID $id \
    ]

    ad_ip_instance sd_fec $sd_fec_name [list \
        Standard {Custom} \
        Turbo_Decode {false} \
        LDPC_Decode {true} \
        LDPC_Decode_Code_Definition "../../../../../../../common/test.txt" \
        Parameter_Interface {Runtime-Configured} \
        Enable_IFs {false} \
        Interrupts {false} \
        DRV_INITIALIZATION_PARAMS {{ 0x00000014,0x00000001,0x0000000C,0x00000000 }} \
        DRV_TURBO_PARAMS {undefined} \
        DRV_LDPC_PARAMS {test {dec_OK 1 enc_OK 1 n 5940 k 5040 p 180 nlayers 5 nqc 131 nmqc 132 nm 66 norm_type 1 no_packing 0 special_qc 0 no_final_parity 0 max_schedule 0 sc_table {52428 12} la_table {3353 4378 4377 5401 3865} qc_table {167424 171521 160002 162819 154628 142341 154886 148999 175112 131849 137482 142347 167180 172045 143886 142607 161296 152593 147475 147988 155925 131350 160535 133144 158745 398876 13824 44033 37122 7171 14084 4869 40710 5639 24584 3081 21770 32780 1293 40462 30735 13072 43793 147730 36115 10773 21270 1815 10009 162074 152603 288028 437021 16128 2817 28674 29187 15620 31493 18438 14087 29192 5129 13578 29195 10764 8461 1038 16911 41744 12817 11794 4371 44820 23576 10522 35355 270877 405278 7168 40961 26114 11267 2052 21509 32262 2311 43272 44553 37642 6155 37132 6670 17170 21011 1044 45333 38678 33559 35608 29977 9242 4635 268062 395295 13312 40705 19202 18947 11780 18181 10758 2823 27656 39177 18443 41741 2319 528 43025 40466 276 12565 22806 16151 45848 2585 19226 41243 307487 398112}}} \
        HDL_INITIALIZATION {{8192 330307380 {K, N}} {8196 135348 {NM, NO_PACKING, PSIZE}} {8200 1116165 {MAX_SCHEDULE, NO_FINAL_PARITY_CHECK, NORM_TYPE, NMQC, NLAYERS}} {8204 0 {QC_OFF, LA_OFF, SC_OFF}} {65536 52428 SC_TABLE} {65540 12 {}} {98304 3353 LA_TABLE} {98308 4378 {}} {98312 4377 {}} {98316 5401 {}} {98320 3865 {}} {131072 167424 QC_TABLE} {131076 171521 {}} {131080 160002 {}} {131084 162819 {}} {131088 154628 {}} {131092 142341 {}} {131096 154886 {}} {131100 148999 {}} {131104 175112 {}} {131108 131849 {}} {131112 137482 {}} {131116 142347 {}} {131120 167180 {}} {131124 172045 {}} {131128 143886 {}} {131132 142607 {}} {131136 161296 {}} {131140 152593 {}} {131144 147475 {}} {131148 147988 {}} {131152 155925 {}} {131156 131350 {}} {131160 160535 {}} {131164 133144 {}} {131168 158745 {}} {131172 398876 {}} {131176 13824 {}} {131180 44033 {}} {131184 37122 {}} {131188 7171 {}} {131192 14084 {}} {131196 4869 {}} {131200 40710 {}} {131204 5639 {}} {131208 24584 {}} {131212 3081 {}} {131216 21770 {}} {131220 32780 {}} {131224 1293 {}} {131228 40462 {}} {131232 30735 {}} {131236 13072 {}} {131240 43793 {}} {131244 147730 {}} {131248 36115 {}} {131252 10773 {}} {131256 21270 {}} {131260 1815 {}} {131264 10009 {}} {131268 162074 {}} {131272 152603 {}} {131276 288028 {}} {131280 437021 {}} {131284 16128 {}} {131288 2817 {}} {131292 28674 {}} {131296 29187 {}} {131300 15620 {}} {131304 31493 {}} {131308 18438 {}} {131312 14087 {}} {131316 29192 {}} {131320 5129 {}} {131324 13578 {}} {131328 29195 {}} {131332 10764 {}} {131336 8461 {}} {131340 1038 {}} {131344 16911 {}} {131348 41744 {}} {131352 12817 {}} {131356 11794 {}} {131360 4371 {}} {131364 44820 {}} {131368 23576 {}} {131372 10522 {}} {131376 35355 {}} {131380 270877 {}} {131384 405278 {}} {131388 7168 {}} {131392 40961 {}} {131396 26114 {}} {131400 11267 {}} {131404 2052 {}} {131408 21509 {}} {131412 32262 {}} {131416 2311 {}} {131420 43272 {}} {131424 44553 {}} {131428 37642 {}} {131432 6155 {}} {131436 37132 {}} {131440 6670 {}} {131444 17170 {}} {131448 21011 {}} {131452 1044 {}} {131456 45333 {}} {131460 38678 {}} {131464 33559 {}} {131468 35608 {}} {131472 29977 {}} {131476 9242 {}} {131480 4635 {}} {131484 268062 {}} {131488 395295 {}} {131492 13312 {}} {131496 40705 {}} {131500 19202 {}} {131504 18947 {}} {131508 11780 {}} {131512 18181 {}} {131516 10758 {}} {131520 2823 {}} {131524 27656 {}} {131528 39177 {}} {131532 18443 {}} {131536 41741 {}} {131540 2319 {}} {131544 528 {}} {131548 43025 {}} {131552 40466 {}} {131556 276 {}} {131560 12565 {}} {131564 22806 {}} {131568 16151 {}} {131572 45848 {}} {131576 2585 {}} {131580 19226 {}} {131584 41243 {}} {131588 307487 {}} {131592 398112 {}} {20 1 FEC_CODE} {12 0 AXIS_WIDTH}} \
    ]

    ad_connect $sys_intf_clk    $ber_name/data_clk
    ad_connect $sys_intf_resetn $ber_name/data_resetn
    ad_connect $sys_cpu_clk     $ber_name/s_axi_aclk
    ad_connect $sys_cpu_resetn  $ber_name/s_axi_aresetn

    ad_connect $sys_cpu_clk     $sd_fec_name/s_axi_aclk
    ad_connect $sys_core_clk    $sd_fec_name/core_clk
    ad_connect $sys_core_resetn $sd_fec_name/reset_n

    ad_connect $sys_intf_clk $sd_fec_name/s_axis_ctrl_aclk
    ad_connect $sys_intf_clk $sd_fec_name/s_axis_din_aclk
    ad_connect $sys_intf_clk $sd_fec_name/m_axis_status_aclk
    ad_connect $sys_intf_clk $sd_fec_name/m_axis_dout_aclk

    ad_connect $ber_name/m_axis_ctrl        $sd_fec_name/S_AXIS_CTRL
    ad_connect $ber_name/m_axis_din         $sd_fec_name/S_AXIS_DIN
    ad_connect $sd_fec_name/m_axis_status   $ber_name/s_axis_status
    ad_connect $sd_fec_name/m_axis_dout     $ber_name/s_axis_dout

    ad_cpu_interconnect $sd_addr $sd_fec_name
    ad_cpu_interconnect $ber_addr $ber_name

    ad_cpu_interrupt "ps-$id" "mb-$id" $ber_name/interrupt
    set sd_intr_id [expr {$id + 8}]
    ad_cpu_interrupt "ps-$sd_intr_id" "mb-$sd_intr_id" $sd_fec_name/interrupt
}

create_sd_fec_with_ber 0 0x44000000 0x44800000
create_sd_fec_with_ber 1 0x44100000 0x44900000
create_sd_fec_with_ber 2 0x44200000 0x44a00000
create_sd_fec_with_ber 3 0x44300000 0x44b00000
create_sd_fec_with_ber 4 0x44400000 0x44c00000
create_sd_fec_with_ber 5 0x44500000 0x44d00000

