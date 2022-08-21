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
		;; Code gen output starts here
		inc rbx
		mov cl, [mem + rbx]
		add cl, 8
		mov [mem + rbx], cl
	L0:
		dec rbx
		mov cl, [mem + rbx]
		add cl, 9
		mov [mem + rbx], cl
		inc rbx
		mov cl, [mem + rbx]
		dec cl
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		cmp cl, 0
		jnz L0
		dec rbx
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		inc rbx
		mov cl, [mem + rbx]
		add cl, 4
		mov [mem + rbx], cl
	L1:
		dec rbx
		mov cl, [mem + rbx]
		add cl, 7
		mov [mem + rbx], cl
		inc rbx
		mov cl, [mem + rbx]
		dec cl
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		cmp cl, 0
		jnz L1
		dec rbx
		mov cl, [mem + rbx]
		inc cl
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		mov cl, [mem + rbx]
		add cl, 7
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		call write
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		mov cl, [mem + rbx]
		add cl, 3
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		add rbx, 2
		mov cl, [mem + rbx]
		add cl, 6
		mov [mem + rbx], cl
	L2:
		dec rbx
		mov cl, [mem + rbx]
		add cl, 7
		mov [mem + rbx], cl
		inc rbx
		mov cl, [mem + rbx]
		dec cl
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		cmp cl, 0
		jnz L2
		dec rbx
		mov cl, [mem + rbx]
		add cl, 2
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		mov cl, [mem + rbx]
		sub cl, 12
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		inc rbx
		mov cl, [mem + rbx]
		add cl, 6
		mov [mem + rbx], cl
	L3:
		dec rbx
		mov cl, [mem + rbx]
		add cl, 9
		mov [mem + rbx], cl
		inc rbx
		mov cl, [mem + rbx]
		dec cl
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		cmp cl, 0
		jnz L3
		dec rbx
		mov cl, [mem + rbx]
		inc cl
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		dec rbx
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		mov cl, [mem + rbx]
		add cl, 3
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		mov cl, [mem + rbx]
		sub cl, 6
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		mov cl, [mem + rbx]
		sub cl, 8
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		add rbx, 3
		mov cl, [mem + rbx]
		add cl, 4
		mov [mem + rbx], cl
	L4:
		dec rbx
		mov cl, [mem + rbx]
		add cl, 8
		mov [mem + rbx], cl
		inc rbx
		mov cl, [mem + rbx]
		dec cl
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		cmp cl, 0
		jnz L4
		dec rbx
		mov cl, [mem + rbx]
		inc cl
		mov [mem + rbx], cl
		mov cl, [mem + rbx]
		mov [char], cl
		call write
		jmp exit