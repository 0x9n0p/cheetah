[BITS 32]
bootstrap:
    nop
    mov BYTE[0xb8000], 'B'
    mov BYTE[0xb8001], 0xa

    cli
    hlt

times 4096 nop