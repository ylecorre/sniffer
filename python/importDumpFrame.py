#!  /usr/bin/python

import sys
import packet

pcap = packet.Pcap()

data = packet.loadTrace("./frame.dump")
pcap.addFrame(packet.RawPacket(data))
pcap.dump("./frame.pcap")
