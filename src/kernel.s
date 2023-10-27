[BITS 64]
kernel:
    mov BYTE[0xb8000], 'K'
    mov BYTE[0xb8001], 0xa

    hlt
    jmp $

times 4096-($-kernel) db 0x90