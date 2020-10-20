#! /bin/sh

PORT=/dev/ttyUSB0
BAUD=115200

python2 ../../uploader.py -d $PORT -b $BAUD -t 02 $*
python2 ../../miniterm.py $PORT $BAUD --xonxoff
