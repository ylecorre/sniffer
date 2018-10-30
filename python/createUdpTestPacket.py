#! /usr/bin/python

import sys
import packet

sourcePort = 56789
destinationPort = 56789
sourceAddress = "169.254.156.197"
destinationAddress = "169.254.156.196"
sourceMac = "e8:9d:87:0a:2c:26"
destinationMac = "e8:9d:87:09:2b:24"
message = "Hello!"

# Create ethernet frame
udp = packet.UdpPacket(sourcePort, destinationPort, packet.RawPacket(message))
ip = packet.IpPacket(sourceAddress, destinationAddress, udp)
eth = packet.EthernetPacket(destinationMac, sourceMac, ip)

# Create pcap file to test it
pcap = packet.Pcap()
pcap.addFrame(eth)
pcap.dump("udpTest.pcap")

# Add ethernet preamble and SFD
eth.showHeader()
print eth
