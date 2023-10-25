[BITS 16]
[ORG 0x7c00]

boot_sector:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7c00

    call clear_screen

    mov ah, 2 ; Read sector command
    mov al, 8 ; n sector to read
    mov ch, 0 ; Cylinder low eight bits
    mov cl, 2 ; Read sector n
    mov dh, 0 ; Head number
    mov bx, 0x7e00
    int 0x13
    jc err_load_loader

    jmp 0x7e00

err_load_loader:
    mov si, MSG_FAILED_LOAD_LOADER
    call print
    cli
    hlt

MSG_FAILED_LOAD_LOADER: db "* Failed to load loader", 0ah, 0dh, 0

print:
      pusha
      mov bx, 0
.loop:
      lodsb
      cmp al, 0
      je .done
      call print_char
      jmp .loop
.done:
      popa
      ret

print_char:
      mov ah, 0eh
      int 0x10
      ret

clear_screen:
      mov al, 02h
      mov ah, 00h
      int 10h
      ret

times 510-($-$$) db 0
dw 0xAA55

loader:
    cli
    lgdt [GDT32_PTR]
    lidt [IDT32_PTR]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; 8 = 00001 (Index) 0 (TI) 00 (RPL)
    jmp 8:protected_mode

[BITS 32]
protected_mode:
    mov ax, 0x10 ; Data segment is third entry
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7C00

    mov BYTE[0xb8000], 'P'
    mov BYTE[0xb8001], 0xa

    hlt
    jmp $

GDT32:
    ; The first entry must be null
    dq 0 ; each entry is 8 bytes, dq to allocate 8 bytes space

CODE32:
      dw 0xffff ; Limit
      dw 0      ; Base address
      db 0      ; Base address
      db 0x9a   ; 1 (P) 00 (DPL) 1 (System descriptor) 1010 (Non-confirming code segment)
      db 0xcf   ; 1 (G) 1 (D) 0 0 (A)  1111 (Limit)
      db 0      ; Base address

DATA32:
      dw 0xffff
      dw 0
      db 0
      db 0x92
      db 0xcf
      db 0

GDT32_LEN: equ $ - GDT32

GDT32_PTR:
      dw GDT32_LEN - 1
      dd GDT32

IDT32_PTR:
      dw 0
      dw 0

times 4096 db 0