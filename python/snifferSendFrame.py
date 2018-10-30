#! /usr/bin/python

import sys
import time
import packet
import sniffer

sourcePort = 56789
destinationPort = 56789
sourceAddress = "192.168.0.253"
destinationAddress = "169.254.156.96"
sourceMac = "e8:9d:87:0a:2c:26"
destinationMac = "e8:9d:87:09:2b:24"
message = "Hello!"

# Create ethernet frame
udp = packet.UdpPacket(sourcePort, destinationPort, packet.RawPacket(message))
ip = packet.IpPacket(sourceAddress, destinationAddress, udp)
eth = packet.EthernetPacket(destinationMac, sourceMac, ip)
eth.showHeader()
frame = eth.getContent()

# Send frame to sniffer
s = sniffer.Sniffer()
print '-- Status =', s.getStatus()
print '-- Writing frame'
s.writeFrame(frame)
length = len(frame)
print '-- written {0} bytes'.format(length)
print s.getStatusString()
print '-- Sending frame'
s.sendFrame()
print s.getStatusString()
