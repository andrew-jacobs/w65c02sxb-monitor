# A basic implimentation of the Terbium IDE interface protocol
# used with the WDC W65C816SXB evalutation board, so that Unix
# users don't have to be anywhere near that Windows crapware.
# --
# Chris Baird,, <cjb@brushtail.apana.org.au> July 2019
# Licensed as per the GPL-3, for what it's worth.

import time
import serial
import sys

ser = serial.Serial(
    port='/dev/ttyU0',
    baudrate=57600,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS )

######################################################################

def startcmd (cmd):
    ser.write(chr(85)+chr(170))
    r = ord(ser.read(1))
    if r != 204:
        print "Response error = ", r
        sys.exit(1)
    ser.write(chr(cmd))

###

def readmem (addr, length):
    startcmd(3)
    addrba = (addr >> 16) & 255
    addrhi = (addr >> 8) & 255
    addrlo = addr & 255
    lenlo = length & 255
    lenhi = (length >> 8) & 255
    ser.write(chr(addrlo)+chr(addrhi)+chr(addrba)+chr(lenlo)+chr(lenhi))

    result=[]
    for i in range(length):
        result.append(ord(ser.read(1)))

    return result

###

def pokemem (addr, val):
    startcmd(2)
    addrba = addr >> 16
    addrlo = addr & 255
    addrhi = (addr & 65280) >> 8
    ser.write(chr(addrlo)+chr(addrhi)+chr(addrba)+chr(1)+chr(0))
    ser.write(chr(val))

###

def writemem (addr, vallist):
    startcmd(2)
    addrba = (addr >> 16) & 255
    addrhi = (addr >> 8) & 255
    addrlo = addr & 255
    lenlo = len(vallist) & 255
    lenhi = (len(vallist) >> 8) & 255

    ser.write(chr(addrlo)+chr(addrhi)+chr(addrba)+chr(lenlo)+chr(lenhi))

    for i in range(len(vallist)):
        # NetBSD has non-existant userspace delays, hence this kludge
        if len(vallist) > 128:
            for t in range(10000):
                a = t
        ser.write(chr(vallist[i]))

###

def getargvals (argstr):
    if len(argstr)==1:
        return int(argstr)

    if (argstr[0] == '$') or (argstr[0] == 'x') or (argstr[0] == '0'):
        result=int(argstr[1:],16)
    else:
        result=int(argstr)
    return result


######################################################################

sys.argv.pop(0)
dumpstart = -1
dumpend = -1
s = sys.argv[0]
DUMPSIZE=16

if s == "-r":
    dumpstart = getargvals(sys.argv[1])
    dumpend = getargvals(sys.argv[2])
    if (dumpstart > -1) and (dumpstart < dumpend):
        dump = readmem(dumpstart,dumpend-dumpstart+1)
        while len(dump):
            l = "%04x: " % (dumpstart & 65535)
            s = ""
            a = dump[:DUMPSIZE]
            dumpstart += len(a)
            for i in a:
                l += "%02x " % i
                c = i & 127
                if c < 32:
                    c += 64
                s += chr(c)
            print l.ljust(54), s
            dump = dump[DUMPSIZE:]

#

if s == "-b":
    dumpstart = getargvals(sys.argv[1])
    dumpend = getargvals(sys.argv[2])
    if (dumpstart > -1) and (dumpstart < dumpend):
        dump = readmem(dumpstart,dumpend-dumpstart+1)
        for i in range(dumpend-dumpstart+1):
            sys.stdout.write(chr(dump[i]))

#

if s == "-s":
    l=[]
    br = open(sys.argv[1], "rb").read()
    for b in br:
        l.append(ord(b))
    writemem (getargvals(sys.argv[2]), l)

#

BLK=128
if s == "-S":
    a=getargvals(sys.argv[2])
    l=[]
    br = open(sys.argv[1], "rb").read()
    for b in br:
        l.append(ord(b))

    for ad in range(a, a+len(l), BLK):
        co=l[:BLK]
        print hex(ad),chr(13),
        sys.stdout.flush()
        l=l[BLK:]
        p=0
        while True:
            writemem (ad, co)
            mem = readmem (ad, len(co))
            if mem == co:
                break
            print hex(ad), "retry=",p
            p = p + 1
            if p == 10:
                print hex(ad), "giving up"
            print "addr=",hex(ad)," redoing"

#

if (s == "-e") or (s == "-E"):
    if s == "-E":
        cpumode = 0             # 65816 mode
    else:
        cpumode = 1             # 6502 mode

    execaddr = getargvals(sys.argv[1])-1 # "RTI trick", hence the -1
    execlo = execaddr & 255
    exechi = (execaddr >> 8) & 255

    procstate = [0, 0,           # 0,1 .A
                 0, 0,           # 2,3 .X
                 0, 0,           # 4,5 .Y
                 execlo, exechi, # 6,7 exec addr
                 0,              # 8 direct page register
                 0,              # 9 ?processor status bits
                 255,            # A stack pointer
                 0,              # B ?processor status bits
                 0,              # C
                 cpumode,        # D CPU mode (0=65816, 1=6502)
                 0,              # E ?.B
                 0]              # F
    writemem (32256, procstate)
    startcmd(5)

###
