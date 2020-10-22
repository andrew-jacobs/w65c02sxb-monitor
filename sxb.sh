#! /bin/sh
java -cp "../../Dev65.jar:../../jSerialComm-2.6.2.jar" uk.me.obelisk.sxb.Uploader -port ttyUSB0 $*
