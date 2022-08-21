#!/bin/bash

if [ ! -f /bin/nasm ]; then
	echo "NASM has to be installed for this to work."
	exit
fi

if [ ! -f /bin/ld ]; then
	echo "The GNU Linker (ld) has to be installed for this to work."
	exit
fi

# Assemble
nasm -f elf64 program.asm -o program.elf64

# Link with the standsrd libraries
ld program.elf64 -o program
