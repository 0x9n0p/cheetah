[BITS 16]
[ORG 0x7c00]

jmp init

init:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7c00

end:
    hlt
    jmp $

times 510-($-$$) db 0
dw 0xaa55