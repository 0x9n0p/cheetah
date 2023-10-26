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

CODE_SEG equ CODE32 - GDT32
DATA_SEG equ DATA32 - GDT32

loader:
    cli
    lgdt [GDT32_PTR]
    lidt [IDT32_PTR]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; 8 = 00001 (Index) 0 (TI) 00 (RPL)
    jmp CODE_SEG:protected_mode

[BITS 32]
protected_mode:
    mov eax, DATA_SEG ; 16 -> Data segment is third entry
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7C00

    ; Load kernel at 0x100000
    mov eax, 9 ; From sector n
    mov ecx, 1 ; Sectors to read
    mov edi, 0x100000
    call ata_lba_read

    jmp 0x100000

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

ata_lba_read:
    mov ebx, eax
    shr eax, 24
    or eax, 0xE0
    mov dx, 0x1F6
    out dx, al

    mov eax, ecx
    mov dx, 0x1F2
    out dx, al

    mov eax, ebx
    mov dx, 0x1F3
    out dx, al

    mov dx, 0x1F4
    mov eax, ebx
    shr eax, 8
    out dx, al

    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.ata_next_sector:
    push ecx

.ata_try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .ata_try_again

    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .ata_next_sector
    ret

times 4096-($-loader) db 0

%include "src/bootstrap.s"