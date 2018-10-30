#! /usr/bin/python

import sys
import time
import serial

### Definitions of opcodes
CMD_CAPTURE = 0xfd	# Capture an ethernet frame
CMD_STATUS  = 0xfe	# Get status flags
CMD_TEST    = 0xf0	# Returns 0xa9 (very quick and easy test to check uart connections)
CMD_READ    = 0xf2  # Reads one byte from RX fifo
CMD_WRITE   = 0xf4  # Write frame in TX fifo
CMD_SEND    = 0xf8  # Send TX frame stored in TX fifo

### Definitions of registers (LAN8720A)
BCR_ADDR = 0x00
BCR_SOFT_RESET = 0x8000
BCR_LOOPBACK   = 0x4000
BCR_100MBPS    = 0x2000
BCR_10MBPS     = 0x0000
BCR_AN_ENABLE  = 0x1000
BCR_AN_DISABLE = 0x0000
BCR_POWER_DWN  = 0x0800
BCR_ISOLATE    = 0x0400
BCR_RESTART_AN = 0x0200
BCR_FD         = 0x0100
BCR_HD         = 0x0000

MSR_ADDR = 0x11
MSR_EDPWRDOWN   = 0x8000
MSR_FARLOOPBACL = 0x0200
MSR_ALTINT      = 0x0040
MSR_ENERGYON    = 0x0002

### Sniffer definition
class Sniffer(object):
	def __init__(self):
		self.port = serial.Serial(4, 115200, timeout = 1)

	def writeReg(self, addr, data):
		dataMsB = (data >> 8) & 0xff
		dataLsB = (data & 0xff)
		self.port.write([0x7f & addr, dataMsB, dataLsB])

	def readReg(self, addr):
		self.port.write([0x80 | addr])
		s = self.port.read(2)
		msb, lsb = [ord(c) for c in s]
		return (msb << 8) | lsb

	def close(self):
		self.port.close()

	def getStatus(self):
		self.port.write([CMD_STATUS])
		b = ord(self.port.read())
		captureRdy = b & 0x01
		captureRunning = (b >> 1) & 0x01
		txRunning = (b >> 2) & 0x01
		loaded = (b >> 3) & 0x01
		captureTriggered = (b >> 4) & 0x01
		crcStatus = (b >> 7) & 0x01
		return crcStatus, captureTriggered, loaded, txRunning, captureRunning, captureRdy

	def capture(self, async = False):
		self.port.write([CMD_CAPTURE])
		if async == True:
			return
		while True:
			crcStatus, captureTriggered, loaded, txRunning, captureRunning, captureRdy = self.getStatus()
			if captureRdy == 1:
					break

	def getStatusString(self):
			crcStatus, captureTriggered, loaded, txRunning, captureRunning, captureRdy = self.getStatus()
			s = 'crcStatus = {0}, captureTriggered = {1}, loaded = {2}, txRunning = {3}, captureRunning = {4}, captureRdy = {5}'.format(crcStatus, captureTriggered, loaded, txRunning, captureRunning, captureRdy)
			return s

	def getFrame(self):
		buf = []
		self.port.write([CMD_READ])
		lengthBytes = self.port.read(2)
		length = ord(lengthBytes[0])*256 + ord(lengthBytes[1])
		if length > 1500:
				print '>> length of captured frame is too large ({0})'.format(length)
				return []
		else:
			buf = []
			for i in range(length):
				buf.append(ord(self.port.read(1)))
			return buf

	def writeFrame(self, frame):
		length = len(frame)
		if length > 255:
			print "TX frame is limited to 255 bytes. Aborting..."
			return
		msg = [CMD_WRITE, length] + frame
		self.port.write(msg)

	def sendFrame(self):
		self.port.write([CMD_SEND])

	def manualConfig100BaseTX(self):
		self.writeReg(BCR_ADDR, BCR_100MBPS | BCR_AN_DISABLE | BCR_FD)

	def loopback(self, value):
		bcrReg = self.readReg(BCR_ADDR)
		if value:
			bcrReg = bcrReg | BCR_LOOPBACK
		else:
			bcrReg = bcrReg & ~BCR_LOOPBACK
		self.writeReg(BCR_ADDR, bcrReg)

	def dumpRegs(self):
		for addr in [0, 1, 2, 3, 4, 5, 6, 17, 18, 26, 27, 29, 30, 31]:
			reg = self.readReg(addr)
			print 'reg{0:02} = 0x{1:04x}'.format(addr, reg)


def dump(fileName, frame):
	try:
		dumpFile = open(fileName, 'w')
	except IOError:
		print "Can't open file {0}. Exiting ...".format(fileName)
		sys.exit(-1)
	for b in frame:
		dumpFile.write('0x{0:02x}\n'.format(b))
	dumpFile.close()
