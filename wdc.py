#!/usr/bin/python

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Author: ECNX Developments
# Description: This Code uploads assembled files to the WDC65CXX series
#              microprocessor and Controllers
#
#
# MIT License

# Copyright (c) 2017 ECNX Development

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


import sys
import binascii
import re
import glob
from time import sleep
import codecs
import os.path
import threading

import serial
from serial.tools.list_ports import comports
from serial.tools import hexlify_codec

__author__ = "ECNX Developments"
__copyright__ = "Copyright 2017, ECNX Development"
__license__ = "MIT"
__version__ = "1.0.0"
__maintainer__ = "ECNX Developments"
__email__ = "info@ecnxdev.co.uk"
__status__ = "Production"

print "#=#=#=#=#=#=# EMC Uploader #=#=#=#=#=#=#=#=#=#=#"

# EMC board commands
# EMC_SYNC_COMMAND = '00'
# EMC_ECHO_COMMAND = '01'
# EMC_HARDWARE_INFO = '01'
# EMC_WRITE_MEM_COMMAND = '02'
# EMC_READ_MEM_COMMAND = '03'
# EMC_EXECUTE_MEM_COMMAND = '04'
# EMC_WRITE_FLASH_COMMAND = '05'
# EMC_READ_FLASH_COMMAND = '06'
# EMC_CLEAR_FLASH_COMMAND = '07'
# EMC_CHECK_FLASH_COMMAND = '08'
# EMC_EXECUTE_FLASH_COMMAND = '09'


EMC_SYNC_COMMAND = '00'
EMC_ECHO_COMMAND = '01'
EMC_WRITE_MEM_COMMAND = '02'
EMC_READ_MEM_COMMAND = '03'
EMC_GET_INFO_COMMAND = '04'
EMC_EXECUTE_DEBUG_COMMAND = '05'
EMC_EXECUTE_MEM_COMMAND = '06'
EMC_WRITE_FLASH_COMMAND = '07'
EMC_READ_FLASH_COMMAND = '08'
EMC_CLEAR_FLASH_COMMAND = '09'
EMC_CHECK_FLASH_COMMAND = '0A'
EMC_EXECUTE_FLASH_COMMAND = '0B'

# pylint: disable=wrong-import-order,wrong-import-position

codecs.register(lambda c: hexlify_codec.getregentry()
                if c == 'hexlify' else None)

try:
    raw_input
except NameError:
    # pylint: disable=redefined-builtin,invalid-name
    raw_input = input   # in python3 it's "raw"
    unichr = chr


def key_description(character):
    """generate a readable description for a key"""
    ascii_code = ord(character)
    if ascii_code < 32:
        return 'Ctrl+{:c}'.format(ord('@') + ascii_code)
    else:
        return repr(character)


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
class ConsoleBase(object):
    """OS abstraction for console (input/output codec, no echo)"""

    def __init__(self):
        if sys.version_info >= (3, 0):
            self.byte_output = sys.stdout.buffer
        else:
            self.byte_output = sys.stdout
        self.output = sys.stdout

    def setup(self):
        """Set console to read single characters, no echo"""

    def cleanup(self):
        """Restore default console settings"""

    def getkey(self):
        """Read a single key from the console"""
        return None

    def write_bytes(self, byte_string):
        """Write bytes (already encoded)"""
        self.byte_output.write(byte_string)
        self.byte_output.flush()

    def write(self, text):
        """Write string"""
        self.output.write(text)
        self.output.flush()

    def cancel(self):
        """Cancel getkey operation"""

    #  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    # context manager:
    # switch terminal temporary to normal mode (e.g. to get user input)

    def __enter__(self):
        self.cleanup()
        return self

    def __exit__(self, *args, **kwargs):
        self.setup()


if os.name == 'nt':  # noqa
    import msvcrt
    import ctypes

    class Out(object):
        """file-like wrapper that uses os.write"""

        def __init__(self, fd):
            self.fd = fd

        def flush(self):
            pass

        def write(self, s):
            os.write(self.fd, s)

    class Console(ConsoleBase):
        def __init__(self):
            super(Console, self).__init__()
            self._saved_ocp = ctypes.windll.kernel32.GetConsoleOutputCP()
            self._saved_icp = ctypes.windll.kernel32.GetConsoleCP()
            ctypes.windll.kernel32.SetConsoleOutputCP(65001)
            ctypes.windll.kernel32.SetConsoleCP(65001)
            self.output = codecs.getwriter(
                'UTF-8')(Out(sys.stdout.fileno()), 'replace')
            # the change of the code page is not propagated to Python, manually fix it
            sys.stderr = codecs.getwriter(
                'UTF-8')(Out(sys.stderr.fileno()), 'replace')
            sys.stdout = self.output
            self.output.encoding = 'UTF-8'  # needed for input

        def __del__(self):
            ctypes.windll.kernel32.SetConsoleOutputCP(self._saved_ocp)
            ctypes.windll.kernel32.SetConsoleCP(self._saved_icp)

        def getkey(self):
            while True:
                z = msvcrt.getwch()
                if z == unichr(13):
                    return unichr(10)
                elif z in (unichr(0), unichr(0x0e)):    # functions keys, ignore
                    msvcrt.getwch()
                else:
                    return z

        def cancel(self):
            # CancelIo, CancelSynchronousIo do not seem to work when using
            # getwch, so instead, send a key to the window with the console
            hwnd = ctypes.windll.kernel32.GetConsoleWindow()
            ctypes.windll.user32.PostMessageA(hwnd, 0x100, 0x0d, 0)

elif os.name == 'posix':
    import atexit
    import termios
    import fcntl

    class Console(ConsoleBase):
        def __init__(self):
            super(Console, self).__init__()
            self.fd = sys.stdin.fileno()
            self.old = termios.tcgetattr(self.fd)
            atexit.register(self.cleanup)
            if sys.version_info < (3, 0):
                self.enc_stdin = codecs.getreader(
                    sys.stdin.encoding)(sys.stdin)
            else:
                self.enc_stdin = sys.stdin

        def setup(self):
            new = termios.tcgetattr(self.fd)
            new[3] = new[3] & ~termios.ICANON & ~termios.ECHO & ~termios.ISIG
            new[6][termios.VMIN] = 1
            new[6][termios.VTIME] = 0
            termios.tcsetattr(self.fd, termios.TCSANOW, new)

        def getkey(self):
            c = self.enc_stdin.read(1)
            if c == unichr(0x7f):
                # map the BS key (which yields DEL) to backspace
                c = unichr(8)
            return c

        def cancel(self):
            fcntl.ioctl(self.fd, termios.TIOCSTI, b'\0')

        def cleanup(self):
            termios.tcsetattr(self.fd, termios.TCSAFLUSH, self.old)

else:
    raise NotImplementedError(
        'Sorry no implementation for your platform ({}) available.'.format(sys.platform))

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


class Transform(object):
    """do-nothing: forward all data unchanged"""

    def rx(self, text):
        """text received from serial port"""
        return text

    def tx(self, text):
        """text to be sent to serial port"""
        return text

    def echo(self, text):
        """text to be sent but displayed on console"""
        return text


class CRLF(Transform):
    """ENTER sends CR+LF"""

    def tx(self, text):
        return text.replace('\n', '\r\n')


class CR(Transform):
    """ENTER sends CR"""

    def rx(self, text):
        return text.replace('\r', '\n')

    def tx(self, text):
        return text.replace('\n', '\r')


class LF(Transform):
    """ENTER sends LF"""


class NoTerminal(Transform):
    """remove typical terminal control codes from input"""

    REPLACEMENT_MAP = dict((x, 0x2400 + x)
                           for x in range(32) if unichr(x) not in '\r\n\b\t')
    REPLACEMENT_MAP.update(
        {
            0x7F: 0x2421,  # DEL
            0x9B: 0x2425,  # CSI
        })

    def rx(self, text):
        return text.translate(self.REPLACEMENT_MAP)

    echo = rx


class NoControls(NoTerminal):
    """Remove all control codes, incl. CR+LF"""

    REPLACEMENT_MAP = dict((x, 0x2400 + x) for x in range(32))
    REPLACEMENT_MAP.update(
        {
            0x20: 0x2423,  # visual space
            0x7F: 0x2421,  # DEL
            0x9B: 0x2425,  # CSI
        })


class Printable(Transform):
    """Show decimal code for all non-ASCII characters and replace most control codes"""

    def rx(self, text):
        r = []
        for c in text:
            if ' ' <= c < '\x7f' or c in '\r\n\b\t':
                r.append(c)
            elif c < ' ':
                r.append(unichr(0x2400 + ord(c)))
            else:
                r.extend(unichr(0x2080 + ord(d) - 48)
                         for d in '{:d}'.format(ord(c)))
                r.append(' ')
        return ''.join(r)

    echo = rx


class Colorize(Transform):
    """Apply different colors for received and echo"""

    def __init__(self):
        # XXX make it configurable, use colorama?
        self.input_color = '\x1b[37m'
        self.echo_color = '\x1b[31m'

    def rx(self, text):
        return self.input_color + text

    def echo(self, text):
        return self.echo_color + text


class DebugIO(Transform):
    """Print what is sent and received"""

    def rx(self, text):
        sys.stderr.write(' [RX:{}] '.format(repr(text)))
        sys.stderr.flush()
        return text

    def tx(self, text):
        sys.stderr.write(' [TX:{}] '.format(repr(text)))
        sys.stderr.flush()
        return text


# other ideas:
# - add date/time for each newline
# - insert newline after: a) timeout b) packet end character

EOL_TRANSFORMATIONS = {
    'crlf': CRLF,
    'cr': CR,
    'lf': LF,
}

TRANSFORMATIONS = {
    'direct': Transform,    # no transformation
    'default': NoTerminal,
    'nocontrol': NoControls,
    'printable': Printable,
    'colorize': Colorize,
    'debug': DebugIO,
}


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


class Miniterm(object):
    """\
    Terminal application. Copy data from serial port to console and vice versa.
    Handle special keys from the console to show menu etc.
    """

    def __init__(self, serial_instance, echo=False, eol='crlf', filters=()):
        self.console = Console()
        self.serial = serial_instance
        self.echo = echo
        self.raw = False
        self.input_encoding = 'UTF-8'
        self.output_encoding = 'UTF-8'
        self.eol = eol
        self.filters = filters
        self.update_transformations()
        self.exit_character = 0x1d  # GS/CTRL+]
        self.menu_character = 0x14  # Menu: CTRL+T
        self.alive = None
        self._reader_alive = None
        self.receiver_thread = None
        self.rx_decoder = None
        self.tx_decoder = None

    def _start_reader(self):
        """Start reader thread"""
        self._reader_alive = True
        # start serial->console thread
        self.receiver_thread = threading.Thread(target=self.reader, name='rx')
        self.receiver_thread.daemon = True
        self.receiver_thread.start()

    def _stop_reader(self):
        """Stop reader thread only, wait for clean exit of thread"""
        self._reader_alive = False
        if hasattr(self.serial, 'cancel_read'):
            self.serial.cancel_read()
        self.receiver_thread.join()

    def start(self):
        """start worker threads"""
        self.alive = True
        self._start_reader()
        # enter console->serial loop
        self.transmitter_thread = threading.Thread(
            target=self.writer, name='tx')
        self.transmitter_thread.daemon = True
        self.transmitter_thread.start()
        self.console.setup()

    def stop(self):
        """set flag to stop worker threads"""
        self.alive = False

    def join(self, transmit_only=False):
        """wait for worker threads to terminate"""
        self.transmitter_thread.join()
        if not transmit_only:
            if hasattr(self.serial, 'cancel_read'):
                self.serial.cancel_read()
            self.receiver_thread.join()

    def close(self):
        self.serial.close()

    def update_transformations(self):
        """take list of transformation classes and instantiate them for rx and tx"""
        transformations = [EOL_TRANSFORMATIONS[self.eol]] + [TRANSFORMATIONS[f]
                                                             for f in self.filters]
        self.tx_transformations = [t() for t in transformations]
        self.rx_transformations = list(reversed(self.tx_transformations))

    def set_rx_encoding(self, encoding, errors='replace'):
        """set encoding for received data"""
        self.input_encoding = encoding
        self.rx_decoder = codecs.getincrementaldecoder(encoding)(errors)

    def set_tx_encoding(self, encoding, errors='replace'):
        """set encoding for transmitted data"""
        self.output_encoding = encoding
        self.tx_encoder = codecs.getincrementalencoder(encoding)(errors)

    def dump_port_settings(self):
        """Write current settings to sys.stderr"""
        sys.stderr.write("\n--- Settings: {p.name}  {p.baudrate},{p.bytesize},{p.parity},{p.stopbits}\n".format(
            p=self.serial))
        sys.stderr.write('--- RTS: {:8}  DTR: {:8}  BREAK: {:8}\n'.format(
            ('active' if self.serial.rts else 'inactive'),
            ('active' if self.serial.dtr else 'inactive'),
            ('active' if self.serial.break_condition else 'inactive')))
        try:
            sys.stderr.write('--- CTS: {:8}  DSR: {:8}  RI: {:8}  CD: {:8}\n'.format(
                ('active' if self.serial.cts else 'inactive'),
                ('active' if self.serial.dsr else 'inactive'),
                ('active' if self.serial.ri else 'inactive'),
                ('active' if self.serial.cd else 'inactive')))
        except serial.SerialException:
            # on RFC 2217 ports, it can happen if no modem state notification was
            # yet received. ignore this error.
            pass
        sys.stderr.write(
            '--- software flow control: {}\n'.format('active' if self.serial.xonxoff else 'inactive'))
        sys.stderr.write(
            '--- hardware flow control: {}\n'.format('active' if self.serial.rtscts else 'inactive'))
        sys.stderr.write(
            '--- serial input encoding: {}\n'.format(self.input_encoding))
        sys.stderr.write(
            '--- serial output encoding: {}\n'.format(self.output_encoding))
        sys.stderr.write('--- EOL: {}\n'.format(self.eol.upper()))
        sys.stderr.write('--- filters: {}\n'.format(' '.join(self.filters)))

    def reader(self):
        """loop and copy serial->console"""
        try:
            while self.alive and self._reader_alive:
                # read all that is there or wait for one byte
                data = self.serial.read(self.serial.in_waiting or 1)
                if data:
                    if self.raw:
                        self.console.write_bytes(data)
                    else:
                        text = self.rx_decoder.decode(data)
                        for transformation in self.rx_transformations:
                            text = transformation.rx(text)
                        self.console.write(text)
        except serial.SerialException:
            self.alive = False
            self.console.cancel()
            raise       # XXX handle instead of re-raise?

    def writer(self):
        """\
        Loop and copy console->serial until self.exit_character character is
        found. When self.menu_character is found, interpret the next key
        locally.
        """
        menu_active = False
        try:
            while self.alive:
                try:
                    c = self.console.getkey()
                except KeyboardInterrupt:
                    c = '\x03'
                if not self.alive:
                    break
                if menu_active:
                    self.handle_menu_key(c)
                    menu_active = False
                elif c == self.menu_character:
                    menu_active = True      # next char will be for menu
                elif c == self.exit_character:
                    self.stop()             # exit app
                    break
                else:
                    # ~ if self.raw:
                    text = c
                    for transformation in self.tx_transformations:
                        text = transformation.tx(text)
                    self.serial.write(self.tx_encoder.encode(text))
                    if self.echo:
                        echo_text = c
                        for transformation in self.tx_transformations:
                            echo_text = transformation.echo(echo_text)
                        self.console.write(echo_text)
        except:
            self.alive = False
            raise

    def handle_menu_key(self, c):
        """Implement a simple menu / settings"""
        if c == self.menu_character or c == self.exit_character:
            # Menu/exit character again -> send itself
            self.serial.write(self.tx_encoder.encode(c))
            if self.echo:
                self.console.write(c)
        elif c == '\x15':                       # CTRL+U -> upload file
            sys.stderr.write('\n--- File to upload: ')
            sys.stderr.flush()
            with self.console:
                filename = sys.stdin.readline().rstrip('\r\n')
                if filename:
                    try:
                        with open(filename, 'rb') as f:
                            sys.stderr.write(
                                '--- Sending file {} ---\n'.format(filename))
                            while True:
                                block = f.read(1024)
                                if not block:
                                    break
                                self.serial.write(block)
                                # Wait for output buffer to drain.
                                self.serial.flush()
                                sys.stderr.write('.')   # Progress indicator.
                        sys.stderr.write(
                            '\n--- File {} sent ---\n'.format(filename))
                    except IOError as e:
                        sys.stderr.write(
                            '--- ERROR opening file {}: {} ---\n'.format(filename, e))
        elif c in '\x08hH?':                    # CTRL+H, h, H, ? -> Show help
            sys.stderr.write(self.get_help_text())
        elif c == '\x02':                       # CTRL+B -> toggle BREAK condition
            self.serial.break_condition = not self.serial.break_condition
            sys.stderr.write(
                '--- BREAK {} ---\n'.format('active' if self.serial.break_condition else 'inactive'))
        elif c == '\x05':                       # CTRL+E -> toggle local echo
            self.echo = not self.echo
            sys.stderr.write(
                '--- local echo {} ---\n'.format('active' if self.echo else 'inactive'))
        elif c == '\x06':                       # CTRL+F -> edit filters
            sys.stderr.write('\n--- Available Filters:\n')
            sys.stderr.write('\n'.join(
                '---   {:<10} = {.__doc__}'.format(k, v)
                for k, v in sorted(TRANSFORMATIONS.items())))
            sys.stderr.write(
                '\n--- Enter new filter name(s) [{}]: '.format(' '.join(self.filters)))
            with self.console:
                new_filters = sys.stdin.readline().lower().split()
            if new_filters:
                for f in new_filters:
                    if f not in TRANSFORMATIONS:
                        sys.stderr.write(
                            '--- unknown filter: {}\n'.format(repr(f)))
                        break
                else:
                    self.filters = new_filters
                    self.update_transformations()
            sys.stderr.write(
                '--- filters: {}\n'.format(' '.join(self.filters)))
        elif c == '\x0c':                       # CTRL+L -> EOL mode
            modes = list(EOL_TRANSFORMATIONS)  # keys
            eol = modes.index(self.eol) + 1
            if eol >= len(modes):
                eol = 0
            self.eol = modes[eol]
            sys.stderr.write('--- EOL: {} ---\n'.format(self.eol.upper()))
            self.update_transformations()
        elif c == '\x01':                       # CTRL+A -> set encoding
            sys.stderr.write(
                '\n--- Enter new encoding name [{}]: '.format(self.input_encoding))
            with self.console:
                new_encoding = sys.stdin.readline().strip()
            if new_encoding:
                try:
                    codecs.lookup(new_encoding)
                except LookupError:
                    sys.stderr.write(
                        '--- invalid encoding name: {}\n'.format(new_encoding))
                else:
                    self.set_rx_encoding(new_encoding)
                    self.set_tx_encoding(new_encoding)
            sys.stderr.write(
                '--- serial input encoding: {}\n'.format(self.input_encoding))
            sys.stderr.write(
                '--- serial output encoding: {}\n'.format(self.output_encoding))
        elif c == '\x09':                       # CTRL+I -> info
            self.dump_port_settings()
        # ~ elif c == '\x01':                       # CTRL+A -> cycle escape mode
        # ~ elif c == '\x0c':                       # CTRL+L -> cycle linefeed mode
        else:
            sys.stderr.write(
                '--- unknown menu character {} --\n'.format(key_description(c)))

    def get_help_text(self):
        """return the help text"""
        # help text, starts with blank line!
        return """
--- pySerial ({version}) - miniterm - help
---
--- {exit:8} Exit program
--- {menu:8} Menu escape key, followed by:
--- Menu keys:
---    {menu:7} Send the menu character itself to remote
---    {exit:7} Send the exit character itself to remote
---    {info:7} Show info
---    {upload:7} Upload file (prompt will be shown)
---    {repr:7} encoding
---    {filter:7} edit filters
--- Toggles:
---    {brk:7} BREAK
---    {echo:7} echo  {eol:7} EOL
---
""".format(version=getattr(serial, 'VERSION', 'unknown version'),
           exit=key_description(self.exit_character),
           menu=key_description(self.menu_character),
           brk=key_description('\x02'),
           echo=key_description('\x05'),
           info=key_description('\x09'),
           upload=key_description('\x15'),
           repr=key_description('\x01'),
           filter=key_description('\x06'),
           eol=key_description('\x0c'))


class EMCSerial:

    def __init__(self, serial, verbose=0):
        self.serial = serial
        self.verbose = verbose

    def __call__(self):
        return self

    def write_serial(self, data, hexify=True):
        try:
            if hexify:
                self.serial.write(data.decode('hex'))
                if self.verbose > 1:
                    print '%s ' % data,
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
        except Exception, e:
            print "Error reading from serial port %s, %s" % (
                self.serial.name, str(e))
        return info

    def write_bin_command(self, cmd):
        self.write_serial('55')
        self.write_serial('AA')
        try:
            i = self.serial.read()
            if hex(ord(i)) != '0xcc':
                print "Error initializing write response. Expected 0xcc but got %s" % hex(
                    ord(i))
                sys.exit(1)
                return
        except Exception, e:
            print "Error reading from serial port %s, %s" % (
                self.serial.name, str(e))
            return

        self.write_serial(cmd)

    def write_bin_block(self, cmd, address, length=None, data=None):
        self.write_bin_command(cmd)
        for d in address:
            self.write_serial(d)
        if length is not None:
            for d in length:
                self.write_serial(d)
        if data is not None:
            for d in data:
                self.write_serial(d)

    def write_bin_execute(self):
        self.write_bin_command(EMC_WRITE_FLASH_COMMAND)

    def write_block_execute(self, address, data):
        self.write_bin_command(EMC_READ_FLASH_COMMAND)
        for d in address:
            self.write_serial(d)
        for d in data:
            self.write_serial(d)

    def separate_hex(self, data):
        bytes = binascii.hexlify(data)
        byte_array = [bytes[i:i+2] for i in range(0, len(bytes), 2)]
        inf = ' '.join(byte_array)
        inf = inf.upper()
        return inf


note = """Example: script.py -d /dev/ttyUSB0 -x 1000 filename.bin\n
		"""

if __name__ == '__main__':
    import argparse
    from argparse import RawTextHelpFormatter

    parser = argparse.ArgumentParser(
        description='Upload file to board or execute some other command', epilog=note, formatter_class=RawTextHelpFormatter)

    parser.add_argument(
        'FILENAME',
        nargs='?',
        help='set the file name/path for the .bin file',
        default=None)

    parser.add_argument(
        '-b', '--baudrate',
        type=int,
        action='store',
        help='set baud rate, default: %(default)s',
        default=115200)

    parser.add_argument(
        '-k', '--flash',
        action='store_true',
        help='set for executing a read, write or execute command on flash default is memory',
        default=-False)

    parser.add_argument(
        '-d', '--device',
        action='store',
        help='set the serial port device',
        default=None)

    parser.add_argument(
        '-a', '--address',
        action='store',
        help='set the address for operation',
        default=None)

    parser.add_argument(
        '-l', '--length',
        type=int,
        action='store',
        help='set the length for operation',
        default=0)

    parser.add_argument(
        '--hex-string',
        action='store',
        help='send raw hex string to the device by setting the mode to raw',
        default=None)

    parser.add_argument(
        '-m', '--mode',
        action='store',
        required=True,
        help='set the mode of operation (read, write, clear, check, execute and raw)')

    parser.add_argument(
        '-x', '--execute',
        action='store_true',
        help='Execute at the address provided by the address switch or in uploaded file if in write mode',
        default=False)

    parser.add_argument(
        '-r', '--no-reset',
        action='store_true',
        help='Do not reset the device',
        default=False)

    parser.add_argument(
        '-s', '--sync',
        type=int,
        nargs='?',
        action='store',
        help='Manually sync the device by giving a delay to press the reset button ',
        const=4)

    parser.add_argument(
        '-v', '--verbose',
        action='count',
        help='Switch on verbose to get debug messages',
        default=0)

    group = parser.add_argument_group("terminal settings")

    group.add_argument(
        '-t', '--terminal',
        action='store_true',
        help='Enter into terminal mode on completion',
        default=False)

    group.add_argument(
        "-q", "--quiet",
        action="store_true",
        help="suppress non-error messages - Terminal Mode configuration option",
        default=False)

    group.add_argument(
        "--raw",
        action="store_true",
        help="Do no apply any encodings/transformations - Terminal Mode configuration option",
        default=False)

    group.add_argument(
        "--encoding",
        dest="serial_port_encoding",
        metavar="CODEC",
        help="set the encoding for the serial port (e.g. hexlify, Latin1, UTF-8), default: %(default)s - Terminal Mode configuration option",
        default='UTF-8')

    group.add_argument(
        "-e", "--echo",
        action="store_true",
        help="enable local echo (default off) - Terminal Mode configuration option",
        default=False)

    group.add_argument(
        "-f", "--filter",
        action="append",
        metavar="NAME",
        help="add text transformation - Terminal Mode configuration option",
        default=[])

    group.add_argument(
        "--eol",
        choices=['CR', 'LF', 'CRLF'],
        type=lambda c: c.upper(),
        help="end of line mode - Terminal Mode configuration option",
        default='CRLF')

    group.add_argument(
        "--exit-char",
        type=int,
        metavar='NUM',
        help="Unicode of special character that is used to exit the application, default: %(default)s - Terminal Mode configuration option",
        default=0x1d)  # GS/CTRL+]

    group.add_argument(
        "--menu-char",
        type=int,
        metavar='NUM',
        help="Unicode code of special character that is used to control miniterm (menu), default: %(default)s - Terminal Mode configuration option",
        default=0x14)  # Menu: CTRL+T

    args = parser.parse_args()

    if args.menu_char == args.exit_char:
        parser.error('--exit-char can not be thesame as --menu-char')
    if args.filter:
        if 'help' in args.filter:
            sys.stderr.write('Available filters:\n')
            sys.stderr.write('\n'.join(
                '{:<10} = {.__doc__}'.format(k, v)
                for k, v in sorted(TRANSFORMATIONS.items())))
            sys.stderr.write('\n')
            sys.stderr.write('''# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #\n 
                                # Author: ECNX Developments\n
                                # Email: info@ecnxdev.co.uk\n
                                # Description: This Code uploads assembled files to the WDC65CXX series\n 
                                #              microprocessor and Controllers\n
                                # \n
                                # \n
                                # MIT License\n\n
                                # Copyright (c) 2017 ECNX Development\n\n

                                # Permission is hereby granted, free of charge, to any person obtaining a copy\n
                                # of this software and associated documentation files (the "Software"), to deal\n
                                # in the Software without restriction, including without limitation the rights\n
                                # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n
                                # copies of the Software, and to permit persons to whom the Software is\n
                                # furnished to do so, subject to the following conditions:\n\n

                                # The above copyright notice and this permission notice shall be included in all\n
                                # copies or substantial portions of the Software.\n\n
                                # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ''')
            sys.exit(1)
        filters = args.filter
    else:
        filters = ['default']

    if args.device is None:
        available_ports = serial_ports()
        if len(available_ports) > 0:
            print "\nChoose the number from the list of serial ports below"
            for i in range(0, len(available_ports)):
                print "\t-- %d\t-\t%s" % (i+1, available_ports[i])
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

    if args.address is not None:
        if len(args.address) == 6:
            if int('0x'+args.address[2:], 16) > int('0xFFFF', 16):
                print "Error: Address must be less than 0xFFFF"
                sys.exit(1)
            else:
                args.address = args.address[4:] + \
                    args.address[2:4]+args.address[:2]
        else:
            print "Error: Invalid value. The address must be 6 hexadecimal characters in the form BBAAAA"
            sys.exit(1)

    # connect to serial port
    ser = serial.serial_for_url(args.device, do_not_open=True)
    ser.baudrate = args.baudrate
    ser.parity = 'N'
    ser.rtscts = True
    ser.timeout = 0.8
    ser.interCharTimeout = 0.5

    if args.verbose > 0:
        # verbose port message
        print "Opening serial port %s, with baudrate - %d, rtscts - %s " % (
            ser.name, args.baudrate, ser.rtscts)
    try:
        ser.open()
    except serial.SerialException as e:
        sys.stderr.write('Could not open serial port {}\n'.format(ser.name))
        sys.exit(1)

    if args.verbose > 0:
        print "Serial %s port opened" % (ser.name)

    if not args.no_reset:
        if args.verbose > 0:
            print "Resetting the device"
        ser.dtr = 0  # DTR pin Low
        sleep(0.3)
        ser.dtr = 1  # DTR pin High
        sleep(0.3)
        ser.dtr = 0  # DTR pin Low
        sleep(0.3)
        if args.verbose > 0:
            print "Device has been reset"

    emcSerial = EMCSerial(ser, args.verbose)

    bytes = ''
    content = ''
    first_char = ''
    address = 0

    if args.sync:
        print "Press the RESET Button"
        sleep(args.sync)
        print "Syncing..."
        emcSerial.write_bin_command(EMC_SYNC_COMMAND)
        data = emcSerial.read_serial()
        if emcSerial.separate_hex(data) == '00':
            print "Synced Successfully"

    if args.FILENAME is not None:
        if os.path.isfile(args.FILENAME):
            with open(args.FILENAME, 'rb') as f:
                content = f.read()
                first_char = content[0]
                if first_char != 'Z':
                    print "Error: File is not a Z-bin file"
                    sys.exit(1)
        else:
            print "Error: File %s does not exist" % args.FILENAME
            sys.exit(1)

        bytes = binascii.hexlify(content)
        byte_array = [bytes[i:i+2] for i in range(0, len(bytes), 2)]
        byte_array = byte_array[1:]

    if args.mode == "raw":
        if args.hex_string is not None:
            raw_data = args.hex_string.split(' ')
            for i in range(0, len(raw_data)):
                var_var = emcSerial.write_serial(raw_data[i])
                print emcSerial.separate_hex(emcSerial.read_serial())
        else:
            print "Error: you must provide the hex string e.g 55 aa 00 20 ...."
            sys.exit(1)

    emcSerial.write_bin_command(EMC_GET_INFO_COMMAND)
    data = emcSerial.read_serial()
    if data is not None and data != '':
        if data[16:19] == 'EMC':
            print "Running EMC Bootloader"
            if binascii.hexlify(data[4]) == '02':
                print "CPU Type: W65C02 - ",
            elif binascii.hexlify(data[4]) == '01':
                print "CPU Type: W65C816 - ",
            else:
                print "Unknown CPU Type - ",
                
            if data[0:3] == 'MYM':
                print "Board Type: MyMENSCH {}".format(data[3])
            elif data[0:3] == 'SXB':
                print "Board Type: SXB"
            else:
                print "Unkown Board Type"
        else:
            print "Running WDC Bootloader"
            if binascii.hexlify(data[3]) == '02':
                print "CPU Type: W65C02 - ",
            elif binascii.hexlify(data[3]) == '01':
                print "CPU Type: W65C816 - ",
            else:
                print "Unknown CPU Type - ",

            if data[4] == 'X':
                print "Board Type: SXB"
            elif data[4] == 'A' or data[4] == 'B' or data[4] == 'C':
                print "Board Type: MyMENSCH {}".format(data[4])
            else:
                print "Unkown Board Type"
    else:
        print "Error: Unable to get Board Info"

    if args.mode == "clear":
        print "Clearing flash..."
        emcSerial.write_bin_command(EMC_CLEAR_FLASH_COMMAND)
        data = emcSerial.read_serial()
        if binascii.hexlify(data) == "00":
            print "Cleared Successfully"
        elif binascii.hexlify(data) == "ff":
            print "Clear Failed"
        else:
            print emcSerial.separate_hex(data)

    elif args.mode == "check":
        if args.address is None or args.length < 1:
            print "Error: you must provide the address and the length with which to read from"
            sys.exit(1)

        print "Checking flash..."
        leng = hex(args.length)[2:]
        if len(leng) < 6:
            for i in range(len(leng), 6):
                leng = '0'+leng
        leng = [leng[2:4], leng[4:], leng[:2]]
        addr = [args.address[i:i+2] for i in range(0, len(args.address), 2)]
        emcSerial.write_bin_block(EMC_CHECK_FLASH_COMMAND, addr, leng)
        data = emcSerial.read_serial()
        if binascii.hexlify(data) == "00":
            print "OK"
        else:
            print "Failed"

    elif args.mode == "execute":
        if args.flash:
            print "Executing program at address 0x00 in flash"
            emcSerial.write_bin_command(EMC_EXECUTE_FLASH_COMMAND)
        elif args.address is not None:
            addr = [args.address[i:i+2]
                    for i in range(0, len(args.address), 2)]
            print "Executing program at address %s in memory" % args.address
            emcSerial.write_bin_block(EMC_EXECUTE_MEM_COMMAND, addr)
        else:
            print "Error: you must provide the address where the code will be executed from in memory or -f for flash"
            sys.exit(1)

    elif args.mode == "read":
        address = 0
        if not args.flash:
            if args.address is None or args.length < 1:
                print "Error: you must provide the address and the length with which to read from"
                sys.exit(1)
            print "Reading from memory..."
            addr = args.address
            leng = hex(args.length)[2:]
            if len(addr) < 6:
                for i in range(len(addr), 6):
                    addr = '0'+addr
            if len(leng) < 4:
                for i in range(len(leng), 4):
                    leng = '0'+leng
            addr = [addr[4:], addr[2:4], addr[:2]]
            leng = [leng[2:], leng[:2]]
            emcSerial.write_bin_block(EMC_READ_MEM_COMMAND, addr, leng)
            address = int("0x"+addr[2]+addr[1]+addr[0], 16)
        else:
            if args.length < 1:
                print "Error: you must provide the length of data to read"
                sys.exit(1)
            print "Reading from flash... \nStarting at address 0x0000"
            addr = "000000"
            leng = hex(args.length)[2:]
            if len(addr) < 6:
                for i in range(len(addr), 6):
                    addr = '0'+addr
            if len(leng) < 6:
                for i in range(len(leng), 6):
                    leng = '0'+leng
            addr = [addr[4:], addr[2:4], addr[:2]]
            leng = [leng[4:], leng[2:4], leng[:2]]
            emcSerial.write_bin_block(EMC_READ_FLASH_COMMAND, addr, leng)
            address = int("0x"+addr[2]+addr[1]+addr[0], 16)
        data = emcSerial.read_serial()
        inf = emcSerial.separate_hex(data)
        for i in range(0, len(inf), 48):
            print "%s:\t%s" % (hex(address)[2:].upper(), inf[i:i+48])
            address += 16

    elif args.mode == "write":
        if args.FILENAME is None:
            print "Error: you must provide the path for the .bin file if you want to write data to board"
            sys.exit(1)

        if not args.flash:
            print "Writing contents of %s to memory..." % (args.FILENAME)
            blocks = {}
            i = 0
            addrs = byte_array[:3]
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

                addr = blocks[key]['Address'][2] + \
                    blocks[key]['Address'][1]+blocks[key]['Address'][0]
                leng = blocks[key]['Length'][1]+blocks[key]['Length'][0]
                print "Writing 0x%s (%s) bytes to address 0x%s" % (
                    leng.upper(), int("0x"+leng, 16), addr.upper())
                if args.verbose > 0:
                    print "Data => "
                    s = ' '.join(blocks[key]['Data'])
                    s = s.upper()
                    address = int(
                        "0x"+blocks[key]['Address'][1]+blocks[key]['Address'][0], 16)
                    for i in range(0, len(s), 48):
                        print "%s:\t%s" % (hex(address)[2:].upper(), s[i:i+48])
                        address += 16
                    print "\n"
                emcSerial.write_bin_block(
                    EMC_WRITE_MEM_COMMAND, blocks[key]['Address'], blocks[key]['Length'], blocks[key]['Data'])

            if args.execute:
                adrs = addrs[2]+addrs[1]+addrs[0]
                print "\nExecuting program at address 0x%s in memory" % adrs
                emcSerial.write_bin_block(EMC_EXECUTE_MEM_COMMAND, addrs)

        else:
            if byte_array[1].upper() != '80' or byte_array[0].upper() != '00':
                print "Error: the start address in the bin file does not match 0x8000"
                sys.exit(1)

            addr = ['00', '00', '00']

            print "Clearing flash..."
            emcSerial.write_bin_command(EMC_CLEAR_FLASH_COMMAND)
            data = emcSerial.read_serial()
            if binascii.hexlify(data) == "00":
                print "\nCleared Successfully"
            else:
                print "\nClear Failed"
                sys.exit(1)

            print "Writing contents of %s to flash..." % (args.FILENAME)

            blocks = {}
            block_data = ['00'] * 30000
            prev_add = None
            address = 0
            length = 0
            while byte_array:
                # print byte_array;

                if int("0x" + byte_array[:3][2] + byte_array[:3][1] + byte_array[:3][0], 16) < int("0x8000", 16):
                    break
                address = byte_array[:3]
                byte_array = byte_array[3:]
                length = "0x"+byte_array[:3][2] + \
                    byte_array[:3][1]+byte_array[:3][0]
                byte_array = byte_array[3:]
                length = int(length, 16)
                data = byte_array[:length]
                byte_array = byte_array[length:]
                current_pos = int(
                    "0x" + address[2] + address[1] + address[0], 16) - int("0x8000", 16)
                for i in range(current_pos, (current_pos+length)):
                    block_data[i] = data[i-current_pos]

            if address == 0 and length == 0:
                print "Error occured"
                sys.exit(1)

            final_length = int(
                "0x" + address[2] + address[1] + address[0], 16) - int("0x8000", 16) + length
            block_data = block_data[:final_length]
            fhex = hex(final_length)[2:]

            if len(fhex) < 6:
                for i in range(len(fhex), 6):
                    fhex = '0'+fhex

            if args.verbose > 0:
                print "Data => "
                s = ' '.join(block_data)
                s = s.upper()
                addr = int("0x8000", 16)
                for i in range(0, len(s), 48):
                    print "%s:\t%s" % (hex(addr)[2:].upper(), s[i:i+48])
                    addr += 16
                print "\n"

            emcSerial.write_bin_block(EMC_WRITE_FLASH_COMMAND, ["00", "80", "00"], [
                                      fhex[4:], fhex[2:4], fhex[:2]], block_data)

            sleep(2)

            data = emcSerial.read_serial()
            if binascii.hexlify(data) == "00":
                print "Written Successfully"
            else:
                print "\nWrite Failed"
                sys.exit(1)

            if args.execute:
                print "Executing program at address 0x00 in flash"
                emcSerial.write_bin_command(EMC_EXECUTE_FLASH_COMMAND)

    if args.terminal:
        miniterm = Miniterm(
            ser,
            echo=args.echo,
            eol=args.eol.lower(),
            filters=filters)
        miniterm.exit_character = unichr(args.exit_char)
        miniterm.menu_character = unichr(args.menu_char)
        miniterm.raw = args.raw
        miniterm.set_rx_encoding(args.serial_port_encoding)
        miniterm.set_tx_encoding(args.serial_port_encoding)

        if not args.quiet:
            sys.stderr.write('--- Miniterm on {p.name}  {p.baudrate},{p.bytesize},{p.parity},{p.stopbits} ---\n'.format(
                p=miniterm.serial))
            sys.stderr.write('--- Quit: {} | Menu: {} | Help: {} followed by {} ---\n'.format(
                key_description(miniterm.exit_character),
                key_description(miniterm.menu_character),
                key_description(miniterm.menu_character),
                key_description('\x08')))

        miniterm.start()
        try:
            miniterm.join(True)
        except KeyboardInterrupt:
            pass
        if not args.quiet:
            sys.stderr.write("\n--- exit ---\n")
        miniterm.join()
        miniterm.close()

    ser.close()
    sys.exit(0)
