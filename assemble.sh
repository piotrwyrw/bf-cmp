#!/bin/bash

if [ ! -f /bin/nasm ]; then
	echo "NASM has to be installed for this to work."
	exit
fi

if [ ! -f /bin/qemu-system-i386 ]; then
	echo "qemu-system-i386 has to be installed for this to work."
	exit
fi

if [ -d build ]; then
	rm -rf build
fi

mkdir build

# Assemble
nasm -f bin program.asm -o build/program.bin

if [ ! -f build/program.bin ]; then
	echo "Binary file not found. Assembly process has most likely failed."
fi

# Link with the standsrd libraries
qemu-system-i386 -fda build/program.bin
