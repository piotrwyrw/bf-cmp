[bits 16]
[org 0x7C00]

jmp Start

resb 100	;; Bios Parameter Block

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

BOOT_MSG: db "[ Booting .. ]", 10, 0
ERR_DISK: db "[ Failed to load sectors from disk. ]", 10, 0
LOD_KERN: db "[ Handing control over to the kernel .. ]", 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55

jmp Kernel

EXEC_START: db "Executing program :: ", 0
PROMPT_STR: db 10, "-> ", 0
READY_STRG: db "Ready.", 10, 0
NUMBER_BIG: db "The number is too high (Max. 255 for byte cells). Please reboot the system to try again.", 10, 0

;; Reserve 1000 cells (1 byte /e)
CELLS:
    resb 1000

;; Holds the character to be printed by the Output call below
CHAR:
    db 0

INPUT_BUFFER:
    resb 100

INPUT_VAL:
    db 0

Input:
    push bx

    mov si, PROMPT_STR
    call Print

    mov bx, 0
    .loop:

        ;; Wait for keyboard action
        mov ah, 0x0
        int 0x16

        ;; Check if [Enter] was pressed
        cmp ah, 0x1C
        jne .ascii
        jmp .return

        .ascii:

            ;; Check if a special key (except for Enter) was pressed
            cmp al, 0
            je .loop

            ;; Check if the input is a number
            cmp al, '0'
            jl .loop

            cmp al, '9'
            jg .loop

            ;; Alter the input buffer
            mov [INPUT_BUFFER + bx], al

            ;; Render the new character
            mov [CHAR], al
            call Output

            inc bx

            jmp .loop
    .return:
        call NewLine

        pop bx
        ret

Parse:
    mov al, 0

    mov si, INPUT_BUFFER

    .loop:
        ;; Use LODSB while avoiding overwriting the al register (since it'll be needed later on for the multiplication)
        push ax
        lodsb
        mov dl, al
        pop ax

        ;; Have we reached the null terminator yet?
        cmp dl, 0
        je .return

        ;; Otherwise, perform the calculations
        mov cl, 10
        mul cl
        add al, dl
        sub al, '0'

        jmp .loop

    .return:
        mov [INPUT_VAL], al
        ret

Output:
    push bx
    mov al, [CHAR]
    call CharPrint
    pop bx
    ret

Kernel:

    ;; Print the first part of the program name line
    mov si, EXEC_START
    call Print

    xor bx, bx
