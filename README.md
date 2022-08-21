# bf-cmp

### A very simple and minimalistic Brainfuck compiler built exclusively for Linux in the C programming language.
The compiler is capable of translating Brainfuck source code into optimized x86-64 Assembly language (NASM-compatible in this instance),
which - after being assembled - will run under the Linux operating system (see below for detailed environment specifications).

## Warning
This project is currently in its prototyping phase - there's a lot more to do and improve (eg. user input). Await lots of upcoming updates!

## Testing Conditions
* _Distro_ **Ubuntu 22.04**
* _Kernel_ **5.15.0-46**
* 64-bit Syscalls