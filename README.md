```
 __         ______                                           
|  \       /      \                                          
| $$____  |  $$$$$$\         _______  ______ ____    ______  
| $$    \ | $$_  \$$______  /       \|      \    \  /      \ 
| $$$$$$$\| $$ \   |      \|  $$$$$$$| $$$$$$\$$$$\|  $$$$$$\
| $$  | $$| $$$$    \$$$$$$| $$      | $$ | $$ | $$| $$  | $$
| $$__/ $$| $$     bare-   | $$_____ | $$ | $$ | $$| $$__/ $$
| $$    $$| $$      metal   \$$     \| $$ | $$ | $$| $$    $$
 \$$$$$$$  \$$               \$$$$$$$ \$$  \$$  \$$| $$$$$$$ 
                                                   | $$      
                                                   | $$      
                                                    \$$      
```

A minimalistic Brainfuck compiler, capable of converting brainfuck source code into "bootable" x86 assembly.

### CLI Usage
```bash
./compiler
  --source    | -s source_file
  --output    | -o output_file
  --preamble  | -p preamble_file
  --name      | -n project_name
```

### Building and Running under Linux
```bash
# Build the compiler
cmake .
make

# Run the compiler and assemble the resulting assembly output
./compiler --source brianfuck_file --output assembly_file --preamble boot.asm --name my_project
nasm -f bin assembly_file -o binary_file

# Run the binary under qemu
qemu-system-i386 -fda binary_file

# Write the binary to a USB drive (optional)
dd if=binary_file of=/dev/sdx
```

### Screenshot of Qemu running the program

![qemu](https://github.com/piotrwyrw/bf-cmp/blob/master/repo/qemu.png?raw=true)
