source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

set ad_project_name ldpc_ber_tester_zcu111

adi_project $ad_project_name 0 [list ]

adi_project_files $ad_project_name [list \
  "system_top.v" \
  "system_constr.xdc"\
  "timing_constr.xdc"\
  "$ad_hdl_dir/projects/common/zcu111/zcu111_system_constr.xdc" ]

# set_property strategy Performance_Explore [get_runs impl_1]
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]

foreach run [get_runs -filter {NAME=~*ldpc_ber_tester_*synth*}] {
    set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true $run
}

adi_project_run $ad_project_name


