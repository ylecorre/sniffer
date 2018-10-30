#! /usr/bin/python

import sys
import packet
from sniffer import *

sourceAddress = "169.254.156.197"
sourceMac = "e8:9d:87:0a:2c:26"

destinationAddress = "169.254.156.196"
destinationMac = "e8:9d:87:09:2b:24"

# Create ethernet frame
arp = packet.GratuitousArpPacket(sourceMac, sourceAddress)

# Create pcap file to test it
pcap = packet.Pcap()
pcap.addFrame(arp)
pcap.dump("arpTest.pcap")

# Add ethernet preamble and SFD
arp.showHeader()
print arp

# send frame
s = Sniffer()
print s.getStatusString()
s.writeFrame(arp.getContent())
s.sendFrame()
