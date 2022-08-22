## bf-cmp

A minimalistic Brainfuck compiler, capable of converting brainfuck source code into "bootable" i386 assembly.


### Building and Running under Linux
```bash
# Build the compiler
cmake .
make

# Run the compiler and assemble the resulting assembly output
./compiler
nasm -f bin program.asm -o program.bin

# Run the binary under qemu
qemu-system-i386 -fda program.bin

# OR write the binary to a USB drive
dd if=program.bin of=/dev/sdx
```