java -cp ..\..\Dev65.jar uk.co.demon.obelisk.w65xx.As65 -include ..\..\include monitor.asm
if errorlevel 1 goto done
java -cp ..\..\Dev65.jar uk.co.demon.obelisk.w65xx.Lk65 -code 7000-7eff -bss 0200-27ff -wdc -output monitor.bin monitor.obj

:done
if errorlevel 1 pause