#!/bin/bash

cmake .
cmake
./compiler --source source.bf --output output.asm --preamble boot.asm --name "Bare Metal Test"
nasm -f bin output.asm -o output.bin
qemu-system-i386 -fda output.bin