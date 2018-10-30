#! /bin/sh

GHDL="ghdl"
GHDL_OPT="--std=02 --ieee=synopsys"
WORK_DIR="unisim"

DIR=`dirname $0`

$GHDL --remove --work=$WORK_DIR

$GHDL -a $GHDL_OPT --work=$WORK_DIR $DIR/unisim_VPKG.vhd
$GHDL -a $GHDL_OPT --work=$WORK_DIR $DIR/unisim_VCOMP.vhd

for FILE in `ls $DIR/primitive/*.vhd`
do
	$GHDL -a -fexplicit $GHDL_OPT --work=$WORK_DIR $FILE
done
