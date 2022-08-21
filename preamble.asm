section .bss
    ;; Reserve 1000 cells (1 byte/e)
    mem: resb 1000

section .data
    ;; The character to be printed by the write function
    char: db 0

section .text
    exit:
        mov rax, 60
        mov rdi, 0
        syscall
    write:
        mov rax, 1
        mov rdi, 1
        mov rsi, char
        mov rdx, 1
        syscall
	    ret

	global _start
    _start:
