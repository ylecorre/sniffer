#! /usr/bin/python3

import sys
import threading
import socket
import time

class Client(threading.Thread):

	def __init__(self, name, ip, port):
		threading.Thread.__init__(self, name = name)
		self.ip = ip
		self.port = port
		self.sock = socket.socket(AF_INET, socket.SOCK_DGRAM)

	def run(self):
		self.sock.sendto(bytes("thread_{0}".format(self.name), "utf-8"), (self.ip, self.port))


class Server(threading.Thread):

	def __init__(self, name, ip, port):
		threading.Thread.__init__(self, name = name)
		self.ip = ip
		self.port = port
		self.sock = socket.socket(AF_INET, socket.SOCK_DGRAM)
		self.sock.bind((self.ip, self.port))

	def run(self):
		while True:
			data, addr = self.sock.recvfrom(1024)
			print("Received:", data)

threads = []
server = Server("server", "10.91.0.70", 56789)
server.start()
threads.append(server)
