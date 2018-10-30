#! /bin/sh

../../../../ieee_proposed/compile.sh
../../../../osvvm/compile.sh

ghdl -a --std=02 --ieee=synopsys ../src/fifo.vhd
ghdl -a --std=02 --ieee=synopsys ../src/tb_top.vhd
ghdl -e --std=02 --ieee=synopsys tb_top
