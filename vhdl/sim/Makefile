################################################################################
#
# Copyright (c) 2014 Yann Le Corre
# All rights reserved. Commercial License Usage
# 
# $Author$
# $Date$
# $Revision$
#
################################################################################

### Definitions
vpath %.vhd ../src
vpath %.vhd ../tb

GHDL := /usr/bin/ghdl
GHDL_OPT := --ieee=synopsys --std=02

### Rules
%.o : %.vhd
	$(GHDL) -a $(GHDL_OPT) --work=netitf_lib $<

%.sim : %.o
	$(GHDL) -e $(GHDL_OPT) --work=netitf_lib $(basename $@)
	/bin/mv $(basename $@) $(addsuffix .sim, $(basename $@))

%.ghw : %.sim
	./$< --wave=$@

%.rpt : %.ghw
	tcpdump -r dump.pcap -n -e -X -vvv -tt | tee $@

### Targets
.PHONY: compile
compile: netitf_test_tb.sim

.PHONY: run
run: netitf_test_tb.rpt

.PHONY: tidy
tidy:
	/bin/rm -f *.o

.PHONY: clean
clean:
	ghdl --remove; ghdl --remove --work=unisim; ghdl --remove --work=netitf_lib; /bin/rm -f *.ghw *.rpt *.o *.pcap *.s *.sim

.PRECIOUS: %.ghw %.sim

### Dependencies
pcap_pkg.o : packet_pkg.o
rmii_pkg.o : packet_pkg.o

fifo.o : types_pkg.o
fifoXilinx.o : types_pkg.o unisim
txCtl.o: crc32.o types_pkg.o ipChecksum.o
tx.o : txCtl.o rmiiTx.o types_pkg.o fifoXilinx.o txArbitrator.o
rxCtl.o : types_pkg.o
rx.o : rxCtl.o rmiiRx.o types_pkg.o fifoXilinx.o
netItf.o : rx.o tx.o rmiiClk.o
netitf_test.o : netItf.o controller.o stream.o

lan8720.o : pcap_pkg.o packet_pkg.o rmii_pkg.o
netitf_test_tb.o : netitf_test.o lan8720.o unisim

unisim: unisim-obj93.cf
unisim-obj93.cf:
	../unisims/compile.sh

###### Deliverables
.PHONY: deliverable
deliverable:
	./makeDeliverable.sh

###### Oldies
rmii.o : rmiiClk.o rmiiRx.o rmiiTx.o
netitf_tb.o : netItf.o lan8720.o
packet_tb.o : packet_pkg.o pcap_pkg.o
smi_tb : smi.o
uart_tb : uart.o
fifo_tb : fifo.o fifoXilinx.o
rx_tb.o : rx.o rmiiClk.o lan8720.o
