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
