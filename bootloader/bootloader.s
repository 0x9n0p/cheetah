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
    mov al, 2 ; n sector to read
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
    hlt
    jmp $

times 2048 db 0