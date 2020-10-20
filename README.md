# A Simple Monitor for the WDC W65C02SXB SBC
This repository contains the code for a simple monitor for the WDC W65C02SXB development board that can be assembled, downloaded and run on Windows, Linux and MacOS.

## Requirements
The monitor is writen in structured 65C02 code uses my [Dev65 Java based development](https://github.com/andrew-jacobs/dev65) suite to build. You need to Java 1.8 or later runtime installed (run 'java -version' in a command terminal to check what you have).

The tool used to download and execute code on the SXB board is operating system dependent.
- On Windows my .Net based SXB utility is used.
- On UNIX a WDC python2 script is used. 

The python script needs the pySerial library installed to work correctly.

# Building
Clone or download the repository to your machine then perform the following steps:

1. On a Windows machine edit the batch file 'sxb.bat' and change the COM port in the command shown below to match the port connected to your SXB. On my machine it was COM6.
```
..\..\sxb -port COM6 %*
```
You can run the sxb program with the option ports to get a list.
```
D:\OpenSource\65xx\w65c02sxb-monitor>sxb ports
COM6

D:\OpenSource\65xx\w65c02sxb-monitor>
```
2. Move the monitor source folder (src/monitor) and open a terminal.
- In Windows type 'make' to run the batch file that assembles and links the code.
- In Linux/MacOs type 'sh -f make.sh' to run the shell script.

The assembler will complain about BRK being used as a label but the linker will produce a 'monitor.bin' file. The console transcript should look like this ...
```
D:\OpenSource\65xx\w65c02sxb-monitor\src\monitor>make

D:\OpenSource\65xx\w65c02sxb-monitor\src\monitor>java -cp ..\..\Dev65.jar uk.co.demon.obelisk.w65xx.As65 -include ..\..\include monitor.asm
Warning: monitor.asm (356) This label is a reserved word (BRK)

D:\OpenSource\65xx\w65c02sxb-monitor\src\monitor>if errorlevel 1 goto done

D:\OpenSource\65xx\w65c02sxb-monitor\src\monitor>java -cp ..\..\Dev65.jar uk.co.demon.obelisk.w65xx.Lk65 -code 7000-7eff -bss 0200-27ff -wdc -output monitor.bin monitor.obj

D:\OpenSource\65xx\w65c02sxb-monitor\src\monitor>if errorlevel 1 pause

D:\OpenSource\65xx\w65c02sxb-monitor\src\monitor>
```
or ...
```
andrew@virtual-ubuntu:~/Code/w65c02sxb-monitor/src/monitor$ sh -f make.sh
Warning: monitor.asm (356) This label is a reserved word (BRK)
andrew@virtual-ubuntu:~/Code/w65c02sxb-monitor/src/monitor$ 
```
3. Press the reset button on your SXB to make sure its boot firmware is running then:
- On Windows run the 'run.bat' file to download and start the monitor.
- On Linux/MacOS type 'sh -f run.sh' to start the process. The downloader may ask you to pick a serial port if your system has more than one.
The command transcript for this should be similar to ...
```
D:\OpenSource\65xx\w65c02sxb-monitor\src\monitor>run

D:\OpenSource\65xx\w65c02sxb-monitor\src\monitor>call ..\..\sxb.bat loadbin monitor.bin exec $7000 term

D:\OpenSource\65xx\w65c02sxb-monitor\src\monitor>..\..\sxb -port COM6 loadbin monitor.bin exec $7000 term
Loaded 3840 ($0F00) bytes
Terminal (ALT-X to exit):



W65C02SXB [20.10]

PC=70AC A=0A X=13 Y=00 P=.V11.I.C SP=FF
.
```
or ...
```
Lunix/MacOS transcript
```




# SXB Memory Usage
The monitor loads into RAM between $7000 upto $7DFF. It uses $F0-$FF on zero page for its private variables and $200-$27F for the command line buffer.

Zero page $00 thru $EF is free for user programs as is RAM from $280 thri $6FFF.