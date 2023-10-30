[BITS 64]

mov BYTE[0xb8000], 'P'
mov BYTE[0xb8001], 0xa

hlt
jmp $

times 4096-($-$$) db 0x90