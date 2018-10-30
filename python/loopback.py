#! /usr/bin/python

import sys
import time
import packet
from sniffer import *

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

# Configure digital loopback
s = Sniffer()
print '-- {0}'.format(s.getStatusString())

s.manualConfig100BaseTX()
s.loopback(True)

# Prepare TX frame
print '-- Writing frame'
s.writeFrame(frame)
length = len(frame)
print '-- written {0} bytes'.format(length)

# Prepare Capture
print '-- {0}'.format(s.getStatusString())
print '-- Triggering capture'
s.capture(async = True)

# Send TX frame
print '-- Sending frame'
s.sendFrame()

# Wait for capture to finish
print '-- Waiting for capture'
while True:
	crcStatus, captureTriggered, loaded, txRunning, captureRunning, captureRdy = s.getStatus()
	print  'crcStatus = {0}, captureTriggered = {1}, loaded = {2}, txRunning = {3}, captureRunning = {4}, captureRdy = {5}'.format(crcStatus, captureTriggered, loaded, txRunning, captureRunning, captureRdy)
	if captureRdy == 1:
		break

if crcStatus == 0:
	print '-- CRC ERROR'
else:
	print '-- CRC ok'

# Download captured frame
print '-- Downloading captured frame'
capturedFrame = s.getFrame()
rxFrame = packet.RawPacket(capturedFrame)
print 'frame =', rxFrame
eth.showHeader(False)
print 'expected = ', eth
pcap = packet.Pcap()
pcap.addFrame(rxFrame)
pcap.dump("loopback.pcap")

# cleanup
s.close()
