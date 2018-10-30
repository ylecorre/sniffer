#! /usr/bin/python3
################################################################################
##
## test_speed.py
##
################################################################################
##
## Copyright (c) 2014 Yann Le Corre
## All rights reserved. Commercial License Usage
##
################################################################################
##
## Created on:Sat 07 Jun 2014 02:08:00 PM CEST by user: yann
## $Author$
## $Date$
## $Revision$
##
################################################################################

# sudo ifdown eth0
# sudo ifup eth0 -o address=192.168.0.4 -o netmask=255.255.255.0

import sys
import threading
import socket
import random
import time
import subprocess

class Receiver(threading.Thread):

	def __init__(self, name, ip, port):
		threading.Thread.__init__(self, name = name)
		self.ip = ip
		self.port = port
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.sock.bind((self.ip, self.port))
		self.sock.setblocking(False)
		self.stopFlag = False
		self.timeStamp = 0.0
		self.numberOfReceivedBytes = 0

	def end(self):
		self.stopFlag = True

	def run(self):
		self.stopFlag = False
		self.numberOfReceivedBytes = 0
		while True:
			try:
				data = self.sock.recv(4096)
			except BlockingIOError:
				pass
			else:
				if len(data) > 0:
					self.numberOfReceivedBytes += len(data)
			self.timeStamp = time.time()
			if self.stopFlag == True:
				break

	def getTimeStamp(self):
		return self.timeStamp

	def getNumberOfReceivedBytes(self):
		return self.numberOfReceivedBytes


class Itf(object):

	def __init__(self, ip, myIp, port):
		self.ip = ip
		self.myIp = myIp
		self.port = port
		self.freq = 0
		self.cmdSock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.receiver = Receiver("receiver", self.myIp, self.port)
		self.receiver.start()
		self.startTime = time.time()

	def setFreq(self, freq):
		self.freq = freq

	def startStream(self):
		if self.freq == 0:
			print("ERROR: can't start stream if freq is 0")
			return
		else:
			self.cmdSock.sendto(bytes([self.freq | 0x80]), (self.ip, self.port))
			self.startTime = time.time()

	def stopStream(self):
			self.cmdSock.sendto(bytes([self.freq & 0x7f]), (self.ip, self.port))

	def close(self):
		self.stopStream()
		self.receiver.end()

	def getThroughput(self):
		return self.receiver.getNumberOfReceivedBytes()/(self.receiver.getTimeStamp() - self.startTime)



################################################################################
# Main
################################################################################

subprocess.call(['arping', '-b', '-c', '1', '-I', 'eth0', '-s', '192.168.0.4', '192.168.0.44'], stdout = subprocess.DEVNULL)

myIp = '192.168.0.4'
ip = '192.168.0.44'
port = 56789

freq = 20
duration = 4
print('-- Data transfer rate measurement')
print('-- Expected throughput = {0} MB/s'.format(100/freq))
print('-- Throughput measurement duration is {0} s'.format(duration))
itf = Itf(ip, myIp, port)
itf.setFreq(freq)
itf.startStream()
time.sleep(duration)
itf.stopStream()
itf.close()
tpMBps = itf.getThroughput()/1e6
tpMbps = tpMBps*8
print('-- {0} bytes transfered'.format(itf.receiver.getNumberOfReceivedBytes()))
print('-- Throughput is {0} MB/s [{1} Mb/s]'.format(tpMBps, tpMbps))

