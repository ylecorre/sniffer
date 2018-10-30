#! /bin/sh

GHDL="ghdl"
GHDL_OPT="--std=02 --ieee=synopsys"

SRC=`dirname $0`/src

$GHDL --remove --work=ieee_proposed

$GHDL -a $GHDL_OPT --work=ieee_proposed $SRC/standard_additions_c.vhd
$GHDL -a $GHDL_OPT --work=ieee_proposed $SRC/standard_textio_additions_c.vhd
$GHDL -a $GHDL_OPT --work=ieee_proposed $SRC/numeric_std_additions.vhd
$GHDL -a $GHDL_OPT --work=ieee_proposed $SRC/numeric_std_unsigned_c.vhdl
$GHDL -a $GHDL_OPT --work=ieee_proposed $SRC/env_c.vhd

