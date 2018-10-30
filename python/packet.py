#! /usr/bin/python
################################################################################
#
# Create ethernet frame of an UDP packet
#
################################################################################
import sys
import zlib

def getByte(word, byteIdx):
	""" ByteIdx is 0 for LSB, 1 for next one, ... """
	byte = (word >> (8*byteIdx)) & 0xff
	return byte

################################################################################
# Base packet object
################################################################################
class Packet(object):
	def getContent(self):
		return self.packet
	def getLength(self):
		return len(self.packet)
	def __repr__(self):
		buf = ''
		for i, b in enumerate(self.getContent()):
			buf += '{0:02x}'.format(b)
			if i != len(self.getContent()) - 1:
				buf += ' '
		return buf
	def dump(self, fileName):
		try:
			fh = open(fileName, 'wb')
		except IOError:
			print "Can't open file {0}. Exiting...".format(fileName)
			sys.exit(-1)
		for b in self.getContent():
			fh.write(chr(b))
		fh.close()
	def addressToBytes(self, address):
		""" address is a string like '192.168.0.3' """
		strBytes = address.split('.')
		bytes = [int(b) for b in strBytes]
		return bytes
	def macToBytes(self, mac):
		macBytes = mac.split(':')
		bytes = [int(b, 16) for b in macBytes]
		return bytes


################################################################################
# Raw packet: encapsulate lists
################################################################################
class RawPacket(Packet):
	def __init__(self, payload):
		if isinstance(payload, str) == True:
			self.packet = [ord(c) for c in payload]
		else:
			self.packet = payload

################################################################################
# Ethernet packet
################################################################################
class EthernetPacket(Packet):
	def __init__(self, destinationMac, sourceMac, payload):
		self.showHeaderFlag = False
		self.header = []
		self.header += self.macToBytes(destinationMac)
		self.header += self.macToBytes(sourceMac)
		self.header += [0x08, 0x00] # IP ethertype
		self.packet = self.header + payload.getContent()
		if payload.getLength() < 46:
			self.packet += [0x00] * (46 - payload.getLength())
		self.calcCrc()
	def calcCrc(self):
		crc = ''
		for byte in self.packet:
			crc = crc + chr(byte)
		crc = zlib.crc32(crc) & 0xffffffff
		res = ''
		for i in range(4):
			b = (crc >> (8*i)) & 0xFF
			self.packet.append(int(b))
	def showHeader(self, flag = True):
		if flag == True:
			if self.showHeaderFlag == False:
				self.showHeaderFlag = True
				self.packet = [0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xD5] + self.packet
		else:
			if self.showHeaderFlag == True:
				self.showHeaderFlag = False
				self.packet = self.packet[8:]


################################################################################
# ARP packet
################################################################################
<<<<<<< .mine
class GratuitousArpPacket(EthernetPacket):
	def __init__(self, senderHardwareAddress, senderProtocolAddress):
=======
class GratuitousArpPacket(EthernetPacket):
	def __init__(self, senderHardwareAddress, senderProtocolAddress)
>>>>>>> .r137
		_payload = [0x00, 0x01, 0x08, 0x00, 0x06, 0x04]
		_payload += [0x00, 0x02] # reply
		_payload += self.macToBytes(senderHardwareAddress)
		_payload += self.addressToBytes(senderProtocolAddress)
		_payload += self.macToBytes(senderHardwareAddress)
		_payload += self.addressToBytes(senderProtocolAddress)
		super(GratuitousArpPacket, self).__init__("ff:ff:ff:ff:ff:ff", senderHardwareAddress, RawPacket(_payload))
		self.header[13] = 0x06
		self.packet[13] = 0x06
		self.packet[-2:] = [0x00, 0x00]
		self.calcCrc()


################################################################################
# IP packet
################################################################################
class IpPacket(Packet):
	def __init__(self, sourceAddress, destinationAddress, payload):
		self.header = [0x45, 0x00] # version/IHL/DSCP/ECN
		length = 20 + payload.getLength()
		self.header.append(getByte(length, 1))
		self.header.append(getByte(length, 0))
		self.header.append(0x00) # Identification ...
		self.header.append(0x00) # ... set to constant 0
		self.header.append(0x00) # unfragmented packet MSB
		self.header.append(0x00) # unfragmented packet LSB
		self.header.append(0x80) # TTL
		self.header.append(0x11) # UDP protocol
		self.header.append(0x00) # checksum MSB (to be calculated later)
		self.header.append(0x00) # checksum LSB (to be calculated later)
		self.header += self.addressToBytes(sourceAddress)
		self.header += self.addressToBytes(destinationAddress)
		self.packet = self.header + payload.getContent()
		checksum = self.calcChecksum()
	def calcChecksum(self):
		checksum = 0
		idx = 0
		while True:
			word = self.header[idx]*256 + self.header[idx + 1]
			checksum += word
			idx += 2
			if idx >= len(self.header):
				break
		checksum += (checksum >> 16)
		checksum = (checksum & 0xffff) ^ 0xffff
		self.packet[10] = getByte(checksum, 1)
		self.packet[11] = getByte(checksum, 0)


################################################################################
# UDP packet
################################################################################
class UdpPacket(Packet):
	def __init__(self, sourcePort, destinationPort, payload):
		self.header = []
		self.header.append(getByte(sourcePort, 1))
		self.header.append(getByte(sourcePort, 0))
		self.header.append(getByte(destinationPort, 1))
		self.header.append(getByte(destinationPort, 0))
		length = 8 + payload.getLength()
		self.header.append(getByte(length, 1))
		self.header.append(getByte(length, 0))
		self.header.append(0x00) # checksum MSB (optional)
		self.header.append(0x00) # checksum LSB (optional)
		self.packet = self.header + payload.getContent()

class PcapPacket(Packet):
	def __init__(self, frame):
		self.header = [0xaa, 0x77, 0x9f, 0x47, 0x90, 0xa2, 0x04, 0x00]
		length = frame.getLength()
		# frame length
		self.header.append(getByte(length, 0))
		self.header.append(getByte(length, 1))
		self.header.append(getByte(length, 2))
		self.header.append(getByte(length, 3))
		# frame length (repeated)
		self.header.append(getByte(length, 0))
		self.header.append(getByte(length, 1))
		self.header.append(getByte(length, 2))
		self.header.append(getByte(length, 3))
		self.packet = self.header + frame.getContent()

class Pcap(Packet):
	def __init__(self):
		self.header = [
			0xD4, 0xC3, 0xB2, 0xA1, 0x02, 0x00, 0x04, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0xFF, 0xFF, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
		]
		self.packet = self.header
	def addFrame(self, frame):
		self.packet += PcapPacket(frame).getContent()

def loadTrace(fileName):
	try:
		fh = open(fileName, 'r')
	except IOError:
		print "Can't open file {0}. Exiting...".format(fileName)
		sys.exit(-1)
	data = []
	for line in fh:
		fields = line.split()
		byte = fields[0]
		data.append(int(byte, 16))
	return data

if __name__ == '__main__':
	udpPacket = UdpPacket(54000, 54000, RawPacket([0x01, 0x02, 0x03, 0x04]))
	print 'UDP:', udpPacket
	ipPacket = IpPacket("192.168.0.2", "192.168.10.5", udpPacket)
	print 'IP :', ipPacket
	ethernetPacket = EthernetPacket("00:23:ae:73:91:ef", "00:23:ae:73:91:ef", ipPacket)
	print 'Ether:', ethernetPacket
	pcap = Pcap()
	pcap.addFrame(ethernetPacket)
	pcap.dump("toto.pcap")
