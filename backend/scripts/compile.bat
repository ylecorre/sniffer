call xvhdl ^
 ../../vhdl/src/types_pkg.vhd ^
 ../../vhdl/src/fifoXilinx.vhd ^
 ../../vhdl/src/rxCtl.vhd ^
 ../../vhdl/src/rmiiRx.vhd ^
 ../../vhdl/src/rx.vhd ^
 ../../vhdl/src/crc32.vhd ^
 ../../vhdl/src/ipChecksum.vhd ^
 ../../vhdl/src/txCtl.vhd ^
 ../../vhdl/src/rmiiTx.vhd ^
 ../../vhdl/src/txArbitrator.vhd ^
 ../../vhdl/src/tx.vhd ^
 ../../vhdl/src/rmiiClk.vhd ^
 ../../vhdl/src/netItf.vhd ^
 ../../vhdl/src/controller.vhd ^
 ../../vhdl/src/stream.vhd ^
 ../../vhdl/src/netitf_test.vhd

call xelab netitf_test -s netitf_test_snapshot --debug typical
