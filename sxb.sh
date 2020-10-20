#! /bin/sh
python2 ../../uploader.py -d /dev/ttyUSB0 -b 115200 $* && \
python2 ../../minterm.py /dev/ttyUSB0 115200 --rtscts
