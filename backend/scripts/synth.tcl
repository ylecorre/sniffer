# NOTE:  typical usage would be "vivado -mode tcl -source create_bft_batch.tcl" 
#
# STEP#0: define output directory area.
set outputDir .

# STEP#1: setup design sources and constraints
read_vhdl [ glob ../../vhdl/src/*.vhd ]         
read_xdc ../xdc/constraints.xdc

# STEP#2: run synthesis, report utilization and timing estimates, write checkpoint design
# XC7A100T-1CSG324C
synth_design -top netitf_test -part xc7a100tcsg324-1
write_checkpoint -force $outputDir/post_synth
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt

# STEP#3: run placement and logic optimzation, report utilization and timing estimates, write checkpoint design
opt_design
place_design
phys_opt_design
write_checkpoint -force $outputDir/post_place
report_timing_summary -file $outputDir/post_place_timing_summary.rpt

# STEP#4: run router, report actual utilization and timing, write checkpoint design, run drc, write verilog and xdc out
route_design
write_checkpoint -force $outputDir/post_route
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_route_timing.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_utilization -file $outputDir/post_route_util.rpt
report_drc -file $outputDir/post_imp_drc.rpt
write_xdc -no_fixed_only -force $outputDir/netitf_test_impl.xdc

# STEP#5: generate a bitstream
write_bitstream -force $outputDir/netitf_test.bit

# TODO: resetn, rx, tx to be constrained (and mapped!)
