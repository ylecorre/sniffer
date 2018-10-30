#! /usr/bin/python

import socket

UDP_IP = '10.91.0.70'
UDP_PORT = 50005

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(('169.254.156.196', 0))
s.sendto('hello you!', (UDP_IP, UDP_PORT))
