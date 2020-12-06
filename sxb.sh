#! /bin/sh
java -cp "../../Dev65.jar:../../jSerialComm-2.6.2.jar" com.wdc65xx.sxb.Uploader -port ttyUSB0 $*
