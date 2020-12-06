java -cp ..\..\Dev65.jar uk.co.demon.obelisk.w65xx.As65 -include ..\..\include example.asm
if errorlevel 1 goto done
java -cp ..\..\Dev65.jar uk.co.demon.obelisk.w65xx.Lk65 -code 0300-6fff -bss 0200-2ff -s19 -output example.s19 example.obj
if errorlevel 1 goto done
java -cp ..\..\Dev65.jar uk.co.demon.obelisk.w65xx.Lk65 -code 0300-6fff -bss 0200-2ff -s28 -output example.s28 example.obj

:done
if errorlevel 1 pause