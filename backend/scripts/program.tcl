# NOTE:  typical usage would be "vivado -mode tcl -source create_bft_batch.tcl" 
#
#
#
#
connect_hw_server -host localhost -port 60001
current_hw_target [get_hw_target *]
open_hw_target
set_property PROGRAM.FILE {./netitf_test.bit} [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
quit
