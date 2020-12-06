#! /bin/sh
java -cp ../../Dev65.jar uk.co.demon.obelisk.w65xx.As65 -include ../../include example.asm && \
java -cp ../../Dev65.jar uk.co.demon.obelisk.w65xx.Lk65 -code 0300-6fff -bss 0200-02ff -s19 -output monitor.s19 monitor.obj
java -cp ../../Dev65.jar uk.co.demon.obelisk.w65xx.Lk65 -code 0300-6fff -bss 0200-02ff -s28 -output monitor.s28 monitor.obj