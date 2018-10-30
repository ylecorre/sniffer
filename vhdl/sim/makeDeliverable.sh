#! /bin/sh
################################################################################
#
# Copyright (c) 2014 Yann Le Corre
# All rights reserved. Commercial License Usage
#
# Extract only meaningfull files for design database for customer export
#
# $Author: ylecorre $
# $Date: 2014-06-12 17:30:57 +0200 (Thu, 12 Jun 2014) $
# $Revision: 168 $
#
################################################################################

DATE=`date -I`
TAR_FILE="netitf_${DATE}.tgz"
COMPILE_FILE="compile.sh"

cat << EOF > $COMPILE_FILE
#! /bin/sh

vlib netitf_lib
EOF

SRC_FILES="\
types_pkg.vhd \
fifoXilinx.vhd  \
rmiiClk.vhd \
rmiiTx.vhd \
crc32.vhd \
ipChecksum.vhd \
rxCtl.vhd \
txArbitrator.vhd \
tx.vhd \
rmiiRx.vhd \
txCtl.vhd \
rx.vhd \
netItf.vhd \
"

TB_FILES="\
packet_pkg.vhd \
pcap_pkg.vhd \
rmii_pkg.vhd \
lan8720.vhd \
controller.vhd \
stream.vhd \
netitf_test_tb.vhd \
"

ALL_FILES="$SRC_FILES $TB_FILES"

FILE_LIST="compile.sh"
FORMAT="%s\x00"
for f in $SRC_FILES
do
	FILE_LIST="${FILE_LIST} ../src/$f"
	FORMAT="%s\x00${FORMAT}"
	echo "vcom -work netitf_lib ./src/$f" >> $COMPILE_FILE
	
done
for f in $TB_FILES
do
	FILE_LIST="${FILE_LIST} ../tb/$f"
	FORMAT="%s\x00${FORMAT}"
	echo "vcom -work netitf_lib ./tb/$f" >> $COMPILE_FILE
done

printf $FORMAT $FILE_LIST | tar cvzf $TAR_FILE -T -
/bin/rm -f $COMPILE_FILE
