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
You can run the sxb program with the option ports to get a list
```
D:\OpenSource\65xx\w65c02sxb-monitor>sxb ports
COM6

D:\OpenSource\65xx\w65c02sxb-monitor>
```


# SXB Memory Usage
The monitor loads into RAM between $7000 upto $7DFF. It uses $F0-$FF on zero page for its private variables and $200-$27F for the command line buffer.

Zero page $00 thru $EF is free for user programs as is RAM from $280 thri $6FFF.