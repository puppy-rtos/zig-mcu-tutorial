@echo off
"D:\env-windows\tools\qemu\qemu64\qemu-system-arm.exe" ^
    -machine olimex-stm32-h405 ^
    -cpu cortex-m4 ^
    -kernel stm32f407 ^
    -serial stdio