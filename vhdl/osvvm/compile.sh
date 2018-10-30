#! /bin/sh

GHDL="ghdl"
GHDL_OPT="--std=02 --ieee=synopsys"

SRC=`dirname $0`/src

$GHDL --remove

### OSVVM (manually patched)
$GHDL -a $GHDL_OPT $SRC/SortListPkg_int.vhd
$GHDL -a $GHDL_OPT $SRC/RandomBasePkg.vhd
$GHDL -a $GHDL_OPT $SRC/RandomPkg.vhd
$GHDL -a $GHDL_OPT $SRC/MessagePkg.vhd
$GHDL -a $GHDL_OPT $SRC/CoveragePkg.vhd
