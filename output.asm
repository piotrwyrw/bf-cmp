[bits 16]
[org 0x7C00]

Start:
    ;; Save the boot drive
    mov [BOOT_DRV], dl

    xor ax, ax

    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov es, ax
    mov ss, ax
    mov bp, ss
    mov sp, bp

    jmp 0:Main ;; set cs

NewLine:
    mov ah, 0x3
    mov bh, 0
    int 0x10

    inc dh
    mov dl, 0

    mov ah, 0x2
    mov bh, 0
    int 0x10

    ret

CharPrint:
    cmp al, 10
    je .endl

    mov ah, 0xE
    mov bh, 0
    mov bl, 0x7
    int 0x10
    ret

    .endl:
        call NewLine
        ret

Print:
    jmp .loop
    .endl:
        call NewLine
    .loop:
        lodsb

        cmp al, 0
        je .exit

        call CharPrint
        jmp .loop
    .exit:
        ret

Main:

    ;; Set video mode
    mov ah, 0x0
    mov al, 0x7
    int 0x10

    ;; Display the boot message
    mov si, BOOT_MSG
    call Print

    ;; Load the remaining sectors from disk
    mov ah, 0x2
    mov al, SECT_CT
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [BOOT_DRV]

    xor bx, bx
    mov es, bx

    mov bx, KERNEL_OFFSET

    int 0x13

    jc .err

    mov si, LOD_KERN
    call Print

    cld

    jmp KERNEL_OFFSET

    .err:
        mov si, ERR_DISK
        call Print
        jmp $

;; Store the boot drive
BOOT_DRV: db 0

;; The kernel starts directly after the bootloader
KERNEL_OFFSET equ 0x7E00

;; Read 40 sectors (Kernel has to be max. 20 KB)
SECT_CT equ 40

;; Boot msg
BOOT_MSG: db "[ Booting .. ]", 10, 0

;; Error message
ERR_DISK: db "[ Failed to load sectors from disk. ]", 10, 0

;; Success message
LOD_KERN: db "[ Handing control over to the kernel .. ]", 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55

jmp Kernel

EXEC_START: db "Executing program :: ", 0

;; Reserve 1000 cells (1 byte /e)
CELLS:
    times 1000 db 0

;; Holds the character to be printed by the Output call below
CHAR:
    db 0

Output:

    mov al, [CHAR]
    call CharPrint
    ret

Kernel:

    ;; Print the first part of the program name line
    mov si, EXEC_START
    call Print
	jmp Execute

	PROGRAM: db "Gruszka", 10, 0

Execute:
	mov si, PROGRAM
	call Print

	;; Project name: Gruszka
	;; Source code:
	;; -[------->+<]>.>--[----->+<]>.[--->+<]>--.--[->++++<]>+.----------.++++++.-[---->+<]>+++.---[->++++<]>-.++++[->+++<]>..--[--->+<]>-.---[->++++<]>.------------.+.++++++++++.+[---->+<]>+++.+[----->+<]>.--------.[--->+<]>----..++[->+++<]>++.++++++.--.--[--->+<]>-.--[->++++<]>-.+[->+++<]>+.+++++++++++.------------.--[--->+<]>--.+[----->+<]>+.+.[--->+<]>-----.+[->+++<]>+.+++++.++++++++++.+.-----.+++.++.-----------.++++++.-.[----->++<]>.------------.[->+++<]>+.+++++++++++..[++>---<]>--.+[->+++<]>.++++++++++++.--.+++.-.-.---------.+++++++++.++++++.-.+[---->+<]>+++.---[->++++<]>-.-----------.+++++++.++++++.---------.--------.-[--->+<]>-.--[->++++<]>-.--------.+++.-------.-[++>---<]>+.++[->+++<]>.+++.+++++.---------.[->+++<]>-.
	;; Code gen output starts here

	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L0:
	mov cl, [CELLS + bx]
	sub cl, 7
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L0
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L1:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L1
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L2:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L2
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L3:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L3
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 6
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L4:
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L4
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
L5:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L5
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
L6:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L6
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L7:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L7
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
L8:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L8
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 12
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L9:
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L9
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L10:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L10
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 8
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L11:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L11
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
L12:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L12
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 6
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L13:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L13
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L14:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L14
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L15:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L15
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 11
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 12
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L16:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L16
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L17:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L17
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L18:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L18
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L19:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L19
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 5
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 11
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 6
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L20:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L20
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 12
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L21:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L21
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 11
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L22:
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L22
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L23:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L23
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 12
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 9
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 9
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 6
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L24:
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L24
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
L25:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L25
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 11
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 7
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 6
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 9
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 8
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L26:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L26
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L27:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L27
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 8
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 7
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L28:
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L28
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
L29:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L29
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 5
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 9
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L30:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L30
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa

	;; End of generated assembly
	jmp $