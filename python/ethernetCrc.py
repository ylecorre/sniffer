#! /usr/bin/python

import zlib
import sys

################################################################################
# Read dump file
################################################################################
def readDumpFile(dumpFileName):
	try:
		dumpFile = open(dumpFileName, "r")
	except IOError:
		print "Can't open file {0}. Exiting ...".format(dumpFileName)
		sys.exit(-1)
	packet = ''
	for line in dumpFile:
		fields = line.split()
		byte = fields[0]
		if byte[1] == 'x':
			packet = packet + ' ' + byte[2:]
		else:
			packet = packet + ' ' + byte
	dumpFile.close()
	packet = packet.split()
	return packet


################################################################################
# Calculate CRC
################################################################################
def crcRef(packet):
	data = ''
	for byte in packet:
		data = data + chr(int(byte, 16))
	crc = zlib.crc32(data) & 0xffffffff
	res = ''
	for i in range(4):
		b = (crc >> (8*i)) & 0xFF
		res += '{0:02x} '.format(b)
	return res


# Message: 0x00
# Reversed: 0x00
# Padded: 0x00 00 00 00 00
# XOR'd: 0xFF FF FF FF 00
# Remainder when divided by 0x104C11DB7: 0x4E 08 BF B4
# XOR'd: 0xB1 F7 40 4B
# Reversed: 0xD2 02 EF 8D
# Residue: 0xC704DD7B

POLY     = 0x04c11db7


def revertByte(byte):
	res = 0
	for i in range(8):
		bit = (byte >> i) & 0x01
		res = 2*res + bit
	return res

def revertWord(word):
	res = 0
	for i in range(32):
		bit = (word >> i) & 0x01
		res = 2*res + bit
	return res

def crcBit(state, bit):
	msb = (state >> 31) & 0x01
	b = msb ^ bit
	newState = (state << 1) & 0xffffffff
	if b == 1:
		newState = newState ^ POLY
	return newState

def crcByte(state, byte):
	newState = state
	for i in range(7, -1, -1):
		bit = (byte >> i) & 0x01
		newState = crcBit(newState, bit)
	return newState

def crcPkt(packet):
	pkt = [revertByte(int(p, 16)) for p in packet]
	state = 0xffffffff
	for byte in pkt:
		state = crcByte(state, byte)
	state = state ^ 0xffffffff
	crc = revertWord(state)
	return crc
	

packet = readDumpFile("./frame.dump")
ref = crcRef(packet)
print 'ref = {0}'.format(ref)
crc = crcPkt(packet)
print 'crc = 0x{0:08x}'.format(crc)
# Residue should be 0xc704dd7b
