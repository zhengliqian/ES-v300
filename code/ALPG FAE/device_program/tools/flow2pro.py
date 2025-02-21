#!/usr/bin/env python
#coding: utf-8


import inspect
import datetime
import re
import sys
import os
import io
import struct

class Part ():
	def __init__ (self, _number, _name, _seq_name):
		self.__part_numbler = _number
		self.__part_name = _name
		self.__part_sequence_name = _seq_name


	def get_number (self):
		return int(self.__part_numbler)

	def get_name (self):
		return self.__part_name

	def get_sequence_name (self):
		return self.__part_sequence_name

	def dump (self):
		print 'number:[%s] name:[%s] sequence_name:[%s]' % (self.__part_numbler, self.__part_name, self.__part_sequence_name)

class Profile ():
	def __init__ (self, _program, _parts, _sml_ver):
		splpath, ext = os.path.splitext (os.path.basename(_program))
		self.__pro_name = splpath + '.PRO'

		# PNG (Portable Network Graphics) Specification (RFC-2083)
		# (decimal)              137  80  82  79  13  10  26  10
		# (hexadecimal)           89  50  52  4F  0d  0a  1a  0a
		# (ASCII C notation)    \211   P   R   O  \r  \n \032 \n
		self.__signature = [0x89, 0x50, 0x52, 0x4F, 0x0d, 0x0a, 0x1a, 0x0a]

		self.__pro_ver = 'Ver1.0'

		self.__sml_ver = _sml_ver

		self.__pro_mode = 0
		self.__source_path = ''
		self.__source_timestamp = 0
		self.__compile_option = ''
		self.__compile_time = 0
		self.__exe_signature = ''
		self.__local_mem_size = 262144 + 8192
		self.__log_path = ''
		self.__parts = _parts
		self.__sequences = None
		self.__debug_sequences = None
		self.__debug_line_no = 0
		self.__source_data = None


	def __pack_bytes (self, _bytes, writer):
		if writer is None:
			put_log ('writer is null')
			return

		if _bytes is None or len (_bytes) == 0:
			put_log ('invalid args')
			return

		for x in _bytes:
			writer.write (struct.pack('B', x))

	def __pack_int (self, _val, writer):
		if writer is None:
			put_log ('writer is null')
			return

		writer.write (struct.pack('I', _val))

	def __pack_long (self, _val, writer):
		if writer is None:
			put_log ('writer is null')
			return

		writer.write (struct.pack('Q', _val))

	def __pack_strings (self, _str, writer):
		if writer is None:
			put_log ('writer is null')
			return

		if _str is None:
			put_log ('invalid args')
			return

		self.__pack_int (len(_str), writer)
#		put_log ('__pack_int ' + str(len(_str)));

		if (len(_str) > 0):
			sig = '%ds' % len(_str)
#			put_log (sig + ' '+ _str);
			writer.write (struct.pack (sig, _str))

	def serialize (self):
		with open(self.__pro_name, 'wb') as fout:
			self.__pack_bytes (self.__signature, fout)
			self.__pack_strings (self.__pro_ver, fout)
			self.__pack_strings (self.__sml_ver, fout)
			self.__pack_int (self.__pro_mode, fout)
			self.__pack_strings (self.__source_path, fout)
			self.__pack_long (self.__source_timestamp, fout)
			self.__pack_strings (self.__compile_option, fout)
			self.__pack_long (self.__compile_time, fout)
			self.__pack_strings (self.__exe_signature, fout)
			self.__pack_long (self.__local_mem_size, fout)
			self.__pack_strings (self.__log_path, fout)

			# part
			if (self.__parts is None):
				self.__pack_int (0, fout)
			else:
				self.__pack_int (len(self.__parts), fout)
				for it in iter (self.__parts):
					self.__pack_int (it.get_number(), fout)
					self.__pack_strings (it.get_name(), fout)
					self.__pack_strings (it.get_sequence_name(), fout)

			# sequesnce
			self.__pack_int (0, fout)
			# source_data
			self.__pack_int (0, fout)


class FlowElement ():
	def __init__ (self, label, function, rej, pre_exec, post_exec, p_branch, f_branch, _bin, test_name):
		self.__label = label
		self.__function = function
		self.__rej = rej
		self.__pre_exec = pre_exec
		self.__post_exec = post_exec
		self.__p_branch = p_branch
		self.__f_branch = f_branch
		self.__bin = _bin
		self.__test_name = test_name

	def get_label (self):
		return self.__label

	def get_function  (self):
		return self.__function 

	def get_rej (self):
		return self.__rej

	def get_pre_exec (self):
		return self.__pre_exec

	def get_post_exec (self):
		return self.__post_exec

	def get_p_branch (self):
		return self.__p_branch

	def get_f_branch (self):
		return self.__f_branch

	def get_bin (self):
		return self.__bin

	def get_test_name (self):
		return self.__test_name

	def to_string (self):
		return '%s,%s,%s,%s,%s,%s,%s,%s,%s' % (
					self.__label,
					self.__function,
					self.__rej,
					self.__pre_exec,
					self.__post_exec,
					self.__p_branch,
					self.__f_branch,
					self.__bin,
					self.__test_name
				)

	def dump (self):
		print '%s,%s,%s,%s,%s,%s,%s,%s,%s' % (
					self.__label,
					self.__function,
					self.__rej,
					self.__pre_exec,
					self.__post_exec,
					self.__p_branch,
					self.__f_branch,
					self.__bin,
					self.__test_name
				)

class FlowLoader ():
	def __init__ (self, flow_file_path):
		self.__flow_file_path = flow_file_path

	def load (self):
		flows = []
		
		if self.__flow_file_path is None:
			put_log ('error  self.__flow_file_path is None')
			return flows
			
		f = open (self.__flow_file_path, 'rb')

		line = f.readline()
		while line:
			line = f.readline()
			if re.search ('^ *\/\/', line, re.IGNORECASE):
				continue

			if not re.search ('RUN_TEST', line, re.IGNORECASE):
				continue

			o_str = line.strip()
			o_str = re.sub('\(|\)', ',', o_str)
			o_str = re.sub('"', '', o_str)
#			print o_str

			o_strs = o_str.split (',')
			flw = FlowElement (
				o_strs[1].strip(),
				o_strs[2].strip(),
				o_strs[3].strip(),
				o_strs[4].strip(),
				o_strs[5].strip(),
				o_strs[6].strip(),
				o_strs[7].strip(),
				o_strs[8].strip(),
				o_strs[9].strip()
			)

#			flw.dump ()
			flows.append (flw)

		return flows
		
	def get_flow_file_name (self):
		return self.__flow_file_path


def proccess (program, flow, sml_version):
	put_log ('program: ' + program)
	put_log ('flow: ' + flow)
	put_log ('sml_version: ' + sml_version)

	fl = FlowLoader (flow)
	flows = fl.load ()
	if flows is None or len (flows) == 0:
		put_log ('flows is invalid...')
		return 1
	
	put_log ('load: ' + str(len (flows)) + ' lines')
	
	# debug
#	for it in iter (flows):
#		put_log (it.to_string ())

	# create parts
	parts = []
	for it in iter (flows):
		pt = Part (it.get_bin(), it.get_test_name(), it.get_function())
#		pt.dump()
		parts.append (pt)

	put_log ('parts: ' + str(len (parts)) + ' items')

	pro = Profile (program, parts, sml_version)
	pro.serialize ()


def put_log (msg):
	d = datetime.datetime.now()

	isLFin = False
	term = ""
	if re.search("\n", msg) is not None:
		isLFin = True

	if not isLFin :
		compMsg = "[%s.%03d](%s(),%d) " % (d.strftime("%Y-%m-%d %H:%M:%S"), d.microsecond/1000, inspect.stack()[1][3], inspect.stack()[1][2])
		compMsg += msg
		print compMsg
	else:
		spMsg = re.split("\r\n|\n", msg)
		for i in spMsg:
			compMsg = "[%s.%03d](%s(),%d) " % (d.strftime("%Y-%m-%d %H:%M:%S"), d.microsecond/1000, inspect.stack()[1][3], inspect.stack()[1][2])
			compMsg += i
			print compMsg

def usage (arg):
	print "Usage: %s program_name_path flow_file_name_path sml_version" % arg

if __name__ == "__main__":
	put_log (sys.argv[0] + ' start')

	if len (sys.argv) == 4:
		proccess (sys.argv[1], sys.argv[2], sys.argv[3])
	else:
		usage (sys.argv[0])

	put_log (sys.argv[0] + ' end')

