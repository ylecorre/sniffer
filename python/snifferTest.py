#! /usr/bin/python

import sniffer

sniffer = sniffer.Sniffer()
while True:
	print '-- status =', sniffer.getStatus()

print '-- Dumping registers'
for i in range(7) + [17, 18, 26, 27, 29, 30, 31]:
	print 'reg{0:02} = 0x{1:04x}'.format(i, sniffer.readReg(i))
print '-- status =', sniffer.getStatus()
print '-- capturing...'
sniffer.capture()
print  '-- done'
print '-- status =', sniffer.getStatus()
print '-- Downloading frame'
frame = sniffer.getFrame()
frameX = ['0x{0:02x}'.format(b) for b in frame]
print frameX
print '-- status =', sniffer.getStatus()
sniffer.close()
