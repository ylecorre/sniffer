#! /usr/bin/python

import socket

UDP_IP = "192.168.0.4"
UDP_PORT = 56789

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

while True:
	data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
	print "received message:", data
