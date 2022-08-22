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

	PROGRAM: db "Bare metal test, bf-cmp logo", 10, 0

Execute:
	mov si, PROGRAM
	call Print

	;; Project name: Bare metal test, bf-cmp logo
	;; Source code:
	;; ++++[->++++++++<]>.[->+++<]>-..+[->+++<]>.........[->+++<]>-......+[->+++<]>...........................................>++++++++++.>--[-->+++<]>-.[---->+<]>+..-[->+++<]>-.+[--->+<]>+.......[-->+++<]>-.+[--->++<]>......-[->+++<]>-.+[--->+<]>+..........................................>++++++++++.>--[-->+++<]>-.[---->+<]>+.++++..-[--->+<]>--....+[->+++<]>..-[->++++<]>.[---->+<]>+..++++......[++++>---<]>+.+[--->+<]>+.........[->+++<]>-.......+[->+++<]>..[->+++<]>-......+[->+++<]>.[->+++<]>-....+[->+++<]>....[->+++<]>-......+[->+++<]>..>++++++++++.>--[-->+++<]>-.[---->+<]>+.++++..----....-[->+++<]>-.+[--->+<]>+.-[->++++<]>.[---->+<]>+.++++..-[--->+<]>--.+[->+++<]>..-[->+++<]>-.-[--->++++<]>..-[--->+<]>--......+[->+++<]>..[-->+++<]>-.+[--->++<]>.......-[->+++<]>-.+[--->++++<]>.[---->+<]>+......-[->+++<]>-.+[--->+<]>+....-[->+++<]>-.+[--->+<]>+..[-->+++<]>-.+[--->++<]>......-[->+++<]>-.+[--->+<]>+.>++++++++++.>--[-->+++<]>-.[---->+<]>+.++++.......[++++>---<]>+.+[--->++++<]>.[---->+<]>+.++++..----.-[->+++<]>-.+[--->+<]>+...-[->++++<]>.[---->+<]>+......-[->+++<]>-.+[--->++++<]>.[---->+<]>+..++++.......[----->+++<]>.[---->+<]>+.++++......[++++>---<]>+.-[--->++++<]>....[++++>---<]>+.+[--->++++<]>.[---->+<]>+..++++......[++++>---<]>+.[++>---<]>.>--[-->+++<]>-.[---->+<]>+.++++..----..-[->++++<]>.[---->+<]>+.++++..[----->+++<]>.[---->+<]>+.++++....----....-[->+++<]>-.-[--->++++<]>......[----->+++<]>.[---->+<]>+.++++..----......-[->++++<]>.[---->+<]>+.++++..----.-[->++++<]>.[---->+<]>+.++++..----.-[->++++<]>.[---->+<]>+.++++..[----->+++<]>.[---->+<]>+.++++..----..-[->++++<]>.[---->+<]>+.++++..>++++++++++.>--[-->+++<]>-.[---->+<]>+.++++..-[--->+<]>--..-[-->+<]>.+[--->++<]>.++++..[----->+++<]>.[---->+<]>+.++++..----.............-[->++++<]>.[---->+<]>+.++++..-[--->+<]>--.....+[->+++<]>.-[->++++<]>.[---->+<]>+.++++..----.-[->++++<]>.[---->+<]>+.++++..----.-[->++++<]>.[---->+<]>+.++++..[----->+++<]>.[---->+<]>+.++++..-[--->+<]>--..-[-->+<]>.+[--->++<]>.++++..>++++++++++.>--[-->+++<]>-.[---->+<]>+.++++..----....++++..[----->+++<]>.[---->+<]>+.++++..----..............-[->+++<]>-.-[--->++++<]>..----.....-[->+++<]>-.+[--->++++<]>.[---->+<]>+.++++..----.-[->++++<]>.[---->+<]>+.++++..----.-[->++++<]>.[---->+<]>+.++++..[----->+++<]>.[---->+<]>+.++++..----....++++..>++++++++++.[->+++<]>++.-[->+++<]>-.-[--->++++<]>.......----..-[->+++<]>-.-[--->++++<]>..----...............-[->+++<]>-.-[--->++++<]>.......----.-[->+++<]>-.-[--->++++<]>..----..-[->+++<]>-.-[--->++++<]>..----..-[->+++<]>-.-[--->++++<]>..[----->+++<]>.[---->+<]>+.++++.......----.>++++++++++.[->+++<]>++...................................................-[->++++<]>.[---->+<]>+.++++..----......>++++++++++.[->+++<]>++...................................................-[->++++<]>.[---->+<]>+.++++..----......>++++++++++.[->+++<]>++....................................................-[->+++<]>-.-[--->++++<]>..----......
	;; Code gen output starts here

	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
L0:
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 8
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
L1:
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
	jnz L1
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L2:
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
	jnz L2
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
L3:
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
	jnz L3
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L4:
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
	jnz L4
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L5:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
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
L6:
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
	jnz L6
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L7:
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
	inc cl
	mov [CELLS + bx], cl
L8:
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
	jnz L8
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
L9:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L9
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
L10:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
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
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L11:
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
	jnz L11
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
L12:
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
	jnz L12
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L13:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
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
L14:
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
	jnz L14
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L15:
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
	jnz L15
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L16:
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
	jnz L16
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L17:
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
	jnz L17
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L18:
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
	jnz L18
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
L19:
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 3
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
	inc cl
	mov [CELLS + bx], cl
L20:
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
	jnz L20
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
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
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L22:
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
	jnz L22
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
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
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L24:
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
	jnz L24
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L25:
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
	jnz L25
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L26:
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
	jnz L26
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
L27:
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
	jnz L27
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L28:
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
	jnz L28
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L29:
	mov cl, [CELLS + bx]
	sub cl, 2
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
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L30:
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
	jnz L30
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L31:
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
	jnz L31
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
L32:
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
	jnz L32
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
	dec cl
	mov [CELLS + bx], cl
L33:
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
	jnz L33
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L34:
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
	jnz L34
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L35:
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
	jnz L35
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
L36:
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
	jnz L36
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L37:
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
	jnz L37
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
	dec cl
	mov [CELLS + bx], cl
L38:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L38
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L39:
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
	jnz L39
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L40:
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
	jnz L40
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L41:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L41
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
L42:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L42
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L43:
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
	jnz L43
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
L44:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L44
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L45:
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
	jnz L45
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L46:
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
	jnz L46
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
L47:
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
	jnz L47
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L48:
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
	jnz L48
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
L49:
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
	jnz L49
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L50:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L50
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
L51:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L51
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L52:
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
	jnz L52
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
L53:
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
	jnz L53
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L54:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L54
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L55:
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
	jnz L55
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
L56:
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L56
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
L57:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L57
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L58:
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
	jnz L58
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L59:
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
	jnz L59
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
L60:
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
	jnz L60
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L61:
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
	jnz L61
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L62:
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
	jnz L62
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L63:
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
	jnz L63
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
L64:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L64
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L65:
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
	jnz L65
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
L66:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L66
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L67:
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
	jnz L67
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
L68:
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L68
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
	dec cl
	mov [CELLS + bx], cl
L69:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L69
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
L70:
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L70
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
L71:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L71
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L72:
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
	jnz L72
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
L73:
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L73
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L74:
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
	jnz L74
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
L75:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L75
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L76:
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
	jnz L76
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
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
	dec cl
	mov [CELLS + bx], cl
L77:
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
	jnz L77
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L78:
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
	jnz L78
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L79:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L79
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L80:
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
	jnz L80
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L81:
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
	jnz L81
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
	dec cl
	mov [CELLS + bx], cl
L82:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L82
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
L83:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L83
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L84:
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
	jnz L84
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L85:
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
	jnz L85
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L86:
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
	jnz L86
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L87:
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
	jnz L87
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L88:
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
	jnz L88
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L89:
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
	jnz L89
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L90:
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
	jnz L90
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L91:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L91
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L92:
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
	jnz L92
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
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
	dec cl
	mov [CELLS + bx], cl
L93:
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
	jnz L93
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L94:
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
	jnz L94
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L95:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L95
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L96:
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
	jnz L96
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L97:
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
	jnz L97
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L98:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L98
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L99:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L99
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L100:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L100
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L101:
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
	jnz L101
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L102:
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
	jnz L102
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L103:
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
	jnz L103
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L104:
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
	jnz L104
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L105:
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
	jnz L105
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L106:
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
	jnz L106
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L107:
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
	jnz L107
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L108:
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
	jnz L108
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L109:
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
	jnz L109
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L110:
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
	jnz L110
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L111:
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
	jnz L111
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L112:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L112
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L113:
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
	jnz L113
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L114:
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
	jnz L114
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L115:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L115
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	inc cl
	mov [CELLS + bx], cl
L116:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L116
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
L117:
	mov cl, [CELLS + bx]
	sub cl, 2
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L117
	inc bx
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L118:
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
	jnz L118
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L119:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L119
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L120:
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
	jnz L120
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L121:
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
	jnz L121
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
	dec cl
	mov [CELLS + bx], cl
L122:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L122
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L123:
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
	jnz L123
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
L124:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L124
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L125:
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
	jnz L125
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L126:
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
	jnz L126
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L127:
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
	jnz L127
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L128:
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
	jnz L128
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L129:
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
	jnz L129
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L130:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L130
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L131:
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
	jnz L131
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L132:
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
	jnz L132
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
	dec cl
	mov [CELLS + bx], cl
L133:
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
	jnz L133
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
	dec cl
	mov [CELLS + bx], cl
L134:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L134
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
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
	dec cl
	mov [CELLS + bx], cl
L135:
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
	jnz L135
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
	dec cl
	mov [CELLS + bx], cl
L136:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L136
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L137:
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
	jnz L137
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
	dec cl
	mov [CELLS + bx], cl
L138:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L138
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L139:
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
	jnz L139
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
	dec cl
	mov [CELLS + bx], cl
L140:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L140
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
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
	dec cl
	mov [CELLS + bx], cl
L141:
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
	jnz L141
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
	dec cl
	mov [CELLS + bx], cl
L142:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L142
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
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
	dec cl
	mov [CELLS + bx], cl
L143:
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
	jnz L143
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
	dec cl
	mov [CELLS + bx], cl
L144:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L144
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
L145:
	mov cl, [CELLS + bx]
	sub cl, 5
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 3
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L145
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L146:
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
	jnz L146
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L147:
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
	jnz L147
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L148:
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
	jnz L148
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L149:
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
	jnz L149
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L150:
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
	jnz L150
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L151:
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
	jnz L151
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L152:
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
	jnz L152
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
	add cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	inc bx
	mov cl, [CELLS + bx]
	add cl, 10
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	popa
L153:
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
	jnz L153
	inc bx
	mov cl, [CELLS + bx]
	add cl, 2
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	dec cl
	mov [CELLS + bx], cl
L154:
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
	jnz L154
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
	dec cl
	mov [CELLS + bx], cl
L155:
	mov cl, [CELLS + bx]
	sub cl, 3
	mov [CELLS + bx], cl
	inc bx
	mov cl, [CELLS + bx]
	add cl, 4
	mov [CELLS + bx], cl
	dec bx
	mov cl, [CELLS + bx]
	cmp cl, 0
	jnz L155
	inc bx
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	popa
	mov cl, [CELLS + bx]
	sub cl, 4
	mov [CELLS + bx], cl
	mov cl, [CELLS + bx]
	mov [CHAR], cl
	pusha
	call Output
	call Output
	call Output
	call Output
	call Output
	call Output
	popa

	;; End of generated assembly
	jmp $