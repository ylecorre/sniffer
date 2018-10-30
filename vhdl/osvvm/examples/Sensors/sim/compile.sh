#! /bin/sh

../../../../ieee_proposed/compile.sh
../../../../osvvm/compile.sh

ghdl -a --std=02 --ieee=synopsys ../src/sensors.vhd
ghdl -e --std=02 --ieee=synopsys sensors
