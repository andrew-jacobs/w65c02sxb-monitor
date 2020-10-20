#!/usr/bin/python

# This program is Licensed to ECNX Development
# This Code uploads assembled files to the WDC65CXX series microprocessor and Controllers
#
# Copyright (C) 2017 ECNX Development.


import serial
import sys
import binascii
import re
import glob
import os.path


def serial_ports():
    """ Lists serial port names

        :raises EnvironmentError:
            On unsupported or unknown platforms
        :returns:
            A list of the serial ports available on the system
    """
    if sys.platform.startswith('win'):
        ports = ['COM%s' % (i + 1) for i in range(256)]
    elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
        # this excludes your current terminal "/dev/tty"
        ports = glob.glob('/dev/tty[A-Za-z]*')
    elif sys.platform.startswith('darwin'):
        ports = glob.glob('/dev/tty.*')
    else:
        raise EnvironmentError('Unsupported platform')

    result = []
    for port in ports:
        try:
            s = serial.Serial(port)
            s.close()
            result.append(port)
        except (OSError, serial.SerialException):
            pass
    return result


class WDCSerial:

	def __init__(self, serial, board=None, file_type=None):
		self.serial = serial
		if board == None:
			self.__detect_board(file_type)
		else:
			self.board = board

	def __call__(self):
		return self

	def __detect_board(self, file_type):
		error_message = "Error: Unable to detect board type (Please press the reset button and retry)"
		if file_type is not None:
			if file_type == 'S' or file_type == ':':
				self.write_serial('g', False)
				info = self.read_serial()
				if info == '':
					print error_message
					sys.exit(1)
				self.write_serial(b'\r', False)
				self.read_serial()
				if re.search(r"BB\:AAAA", info):
					 self.board = "265"
				else:
					self.board = "134"
				print "Detected W65C%s" % self.board
				return
			if file_type == 'Z':
				self.write_bin_command('03')
				for d in ['08','F8','00']:
					self.write_serial(d)
				for d in ['0B','00']:
					self.write_serial(d)
				info = self.read_serial()
				if re.search(r"WDC65c02", info):
					self.board = "02"
				elif re.search(r"WDC65c816", info):
					self.board = "816"
				else:
					print error_message
					sys.exit(1)
				print "Detected W65C%s" % self.board
				return
			print error_message
			sys.exit(1)

	def write_serial(self, data, hexify=True):
		try:
			if hexify:
				self.serial.write(data.decode('hex'))
			else:
				self.serial.write(data)
		except:
			print "Error writing to serial port %s" % self.serial.name

	def read_serial(self):
		info = ""
		try:
			i = self.serial.read()
			while i:
				info += chr(ord(i))
				i = self.serial.read()
		except:
			print "Error reading from serial port %s" % self.serial.name
		return info

	def write_bin_command(self, cmd):
		self.write_serial('55')
		self.write_serial('AA')
		try:
			i = self.serial.read()
			if hex(ord(i)) != '0xcc':
				print "Error initializing write response %s" % hex(ord(i));
				return
		except:
			print "Error reading from serial port %s" % self.serial.name
			return

		self.write_serial(cmd)

	def write_bin_block(self, address, length, data):
		self.write_bin_command('02')
		for d in address:
			self.write_serial(d)
		for d in length:
			self.write_serial(d)
		for d in data:
			self.write_serial(d)

	def write_bin_execute(self):
		self.write_bin_command('05')


note="""NOTE: This uploads compiled code to all the W65CO2, W65C134, W65C265 and W65816, 8 and 16 bit processors
		\n	Example: uploader.py -d /dev/ttyUSB0 -x 1000 filename.s28\n
		"""



if __name__ == '__main__':
	import argparse
	from argparse import RawTextHelpFormatter

	parser = argparse.ArgumentParser(description='Upload file to WDC board.',epilog=note,formatter_class=RawTextHelpFormatter)

	parser.add_argument(
        'FILENAME',
        help="file name to upload to board")

	parser.add_argument(
        '-b', '--baudrate',
        type=int,
        action='store',
        help='set baud rate, default: %(default)s',
        default=9600)

	parser.add_argument(
        '-d','--device',
        action='store',
        help='set the serial port device',
        default=None)

	parser.add_argument(
        '-x','--execute',
        action='store',
        help='set the address where the code will execute from',
        default=None)

	parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Switch on verbose to get debug messages',
        default=False)

	parser.add_argument(
        '-t', "--type",
        choices=['02', '134', '816', '265'],
        type=lambda c: c.upper(),
        help="set board type, one of {02, 134, 816, 265}, Will try to auto detect if not provided",
        default=None)

	args = parser.parse_args()

	if args.device is None:
		available_ports = serial_ports();
		if len(available_ports) > 0:
			print "\nChoose the number from the list of serial ports below"
			for i in range(0, len(available_ports)):
				print "\t-- %d\t-\t%s" % (i+1,available_ports[i])
			user_input = raw_input("Please choose the port number: ")
			try:
				num = int(user_input, 10)
				args.device = available_ports[num-1]
			except:
				print "Error: Input does not correspond to any port number"
				sys.exit(1)
		else:
			print "Sorry, No available serial port found"
			sys.exit(0)

	if args.execute is not None:
		if len(args.execute) == 4:
			if int('0x'+args.execute, 16) > int('0xFFFF', 16):
				print "Error: Address must be in the format XXXX and must be less than 0xFFFF"
				sys.exit(1)
		elif len(args.execute) == 6:
			if int('0x'+args.execute[2:], 16) > int('0xFFFF', 16):
				print "Error: Address must be in the format XXXX and must be less than 0xFFFF"
				sys.exit(1)
		else:
			print "Error: Invalid value. The execute address must be either 6 hexadecimal characters in the form BBAAAA or 4 hexadecimal characters in the form AAAA"
			sys.exit(1)

    # connect to serial port
	ser = serial.serial_for_url(args.device, do_not_open=True)
	ser.baudrate = args.baudrate
	ser.parity = 'N'
	ser.rtscts = True
	ser.timeout = 0.05

	if args.verbose:
		print "Opening serial port %s, with baudrate - %d, rtscts - %s " % (ser.name, args.baudrate, ser.rtscts)         # verbose port message

	try:
		ser.open()
	except serial.SerialException as e:
		sys.stderr.write('Could not open serial port {}\n'.format(ser.name))
		sys.exit(1)

	if args.verbose:
		print "Serial %s port opened" % (ser.name)

	if args.verbose:
		print "Opening and reading file - %s" % (args.FILENAME)

	bytes = ''
	content = ''
	first_char = ''
	if os.path.isfile(args.FILENAME):
		with open(args.FILENAME, 'rb') as f:
			content = f.read()
			first_char = content[0]
	else:
		print "Error: File %s does not exist" % args.FILENAME
		sys.exit(1)

	if first_char == ':':
		content_lines = content.split('\r')
		print "\nConverting the hex file to s28 format"
		if args.verbose:
			print "HEX FORMAT: \n%s" % content
		content = ''
		for index, var in enumerate(content_lines):
			if index == len(content_lines)-2:
				content += "S804000000FB\r\n"
			elif index != len(content_lines)-1:
				var = var.strip('\n')
				byte_array = [var[i:i+2] for i in range(1, len(var), 2)]
				length = int("0x"+byte_array[0], 16) + 4
				length = hex(length)[2:]
				if len(length) == 1:
					length = "0"+length
				content_string = "S2"+length+"00"+"".join(byte_array[1:3])+"".join(byte_array[4:len(byte_array)-1])
				content_array = [content_string[i:i+2] for i in range(2, len(content_string), 2)]
				sum = 0
				for val in content_array:
					sum += int("0x"+val, 16)
				sum &= int("0xFF", 16)
				sum ^= int("0xFF", 16)
				checksum = hex(sum)[2:]
				if len(checksum) == 1:
					checksum = "0"+checksum
				content_string += checksum+"\r\n"
				content_string = content_string.upper()
				content += content_string

	wdcserial = None
	#sys.exit(0);
	if args.type is None:
		wdcserial = WDCSerial(ser, file_type=first_char)
		args.type = wdcserial.board
	else:
		wdcserial = WDCSerial(ser, args.type)

	if args.type == "134" or args.type == "265":
		bytes = content;
	else:
		bytes = binascii.hexlify(content)

	if args.type == "134" or args.type == "265":
		byte_array = bytes
	else:
		byte_array = [bytes[i:i+2] for i in range(0, len(bytes), 2)]
		byte_array = byte_array[1:]

	print "\nWriting contents of %s to W65C%s...\n" % (args.FILENAME, args.type) 

	if args.type == "134" or args.type == "265":
		info = ""
		if args.verbose:
			print "Writing characters"
		for byte in byte_array:
			wdcserial.write_serial(byte, False)
			if args.verbose:
				sys.stdout.write(byte)
			if byte == '\n':
				info += wdcserial.read_serial()
		sys.stdout.flush()
		info = re.sub(r'>|R|E|A|D|Y', '', info)
		print "Information Written \n %s" % info
		if args.execute is not None:
			exec_lst = []
			if args.type == "265":
				if len(args.execute) == 4:
					exec_lst = 'G00'+args.execute
				else:
					exec_lst = 'G'+args.execute
			else:
				exec_lst = 'G'+args.execute

			if args.verbose:
				print "\nWriting characters \n%s" % exec_lst
			for byte in exec_lst:
				wdcserial.write_serial(byte, False)
				wdcserial.read_serial()
			print "Executed at %s" % (exec_lst)
		ser.close()
		sys.exit(0)

	blocks = {}
	i = 0
	while byte_array:
		key = 'block'+str(i)
		blocks[key] = {}
		blocks[key]['Address'] = byte_array[:3]
		byte_array = byte_array[3:]
		blocks[key]['Length'] = byte_array[:2]
		length = "0x"+byte_array[:2][1]+byte_array[:2][0]
		length = int(length, 16)
		byte_array = byte_array[3:]
		blocks[key]['Data'] = byte_array[:length]
		byte_array = byte_array[length:]
		if length == 0:
			blocks.pop(key, None)
			break
		i += 1

		addr = blocks[key]['Address'][1]+blocks[key]['Address'][0]
		leng = blocks[key]['Length'][1]+blocks[key]['Length'][0]
		if args.type == "816":
			addr = blocks[key]['Address'][2]+addr
		print "Writing 0x%s (%s) bytes to address 0x%s" % (leng.upper(), int("0x"+leng, 16), addr.upper())
		if args.verbose:
			print "Data => "
			s = ' '.join(blocks[key]['Data'])
			s = s.upper()
			address = int("0x"+blocks[key]['Address'][1]+blocks[key]['Address'][0], 16)
			for i in range(0, len(s), 48):
				print "%s:\t%s"%(hex(address)[2:].upper(), s[i:i+48])
				address += 16
			print "\n"
		wdcserial.write_bin_block(blocks[key]['Address'], blocks[key]['Length'], blocks[key]['Data'])

	if args.execute is not None:
		key = 'execute'
		blocks[key] = {}
		blocks[key]['Address'] = ['00','3F','00']
		blocks[key]['Length'] = ['10','00']
		if len(args.execute) == 4:
			blocks[key]['Data'] = ['00','00','00','00','00','00', args.execute[2:],args.execute[:2],'00','00','00','00','34','FF','00','00']
		else:
			blocks[key]['Data'] = ['00','00','00','00','00','00', args.execute[4:],args.execute[2:4],'00','00','00','00','34','FF',args.execute[:2],'00']

		addr = blocks[key]['Address'][1]+blocks[key]['Address'][0]
		leng = blocks[key]['Length'][1]+blocks[key]['Length'][0]
		if args.type == "816":
			addr = blocks[key]['Address'][2]+addr
		print "Writing 0x%s (%s) bytes to address 0x%s" % (leng, int("0x"+leng, 16), addr.upper())
		if args.verbose:
			print "Data => "
			s = ' '.join(blocks[key]['Data'])
			s = s.upper()
			address = int("0x"+blocks[key]['Address'][1]+blocks[key]['Address'][0], 16)
			for i in range(0, len(s), 48):
				print "%s:\t%s"%(hex(address)[2:].upper(), s[i:i+48])
				address += 16
			print "\n"
		wdcserial.write_bin_block(blocks[key]['Address'], blocks[key]['Length'], blocks[key]['Data'])
		print "Executing program at address %s" % args.execute
		wdcserial.write_bin_execute()

	ser.close()

	sys.exit(0)
