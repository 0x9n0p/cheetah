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

[BITS 16]
loader:
    xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
    mov sp, 0x7c00

    lgdt [GDT32_PTR]
    lidt [IDT32_PTR]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp CODE_SEG:protected_mode

[BITS 32]
protected_mode:
      cli

      mov ax, DATA_SEG
      mov ds, ax
      mov es, ax
      mov ss, ax
      mov esp, 0x7c00

      ; Load kernel at 0x9000
      mov eax, 9 ; From sector n
      mov ecx, 8 ; n Sectors to read
      mov edi, 0x9000 ; The address
      call ata_lba_read

      ; Enable the A20 line
      in al, 0x92
      or al, 2
      out 0x92, al

      ; Use 0x70000 to 0x80000 for paging
      cld
      mov edi, 0x70000
      xor eax, eax
      mov ecx, 0x10000/4
      rep stosd

      ; PML4 Entry
      mov dword[0x70000], 0x71003 ; U=0 W=1 P=1
      ; PDP Entry
      ; 1G physical page, Base Address = 0
      mov dword[0x71000], 10000111b

      lgdt [GDT64_PTR]

      ; Physical address extension
      mov eax, cr4
      or eax, (1<<5)
      mov cr4, eax

      mov eax, 0x70000
      mov cr3, eax

      mov ecx, 0xc0000080
      rdmsr
      or eax, (1<<8)
      wrmsr

      mov eax, cr0
      or eax, (1<<31)
      mov cr0, eax

      ; Segment Selector (00001 (Index) 000 (Attributes)) + Offset
      jmp 8:long_mode

GDT32:
      dq 0
CODE32:
      dw 0xffff
      dw 0
      db 0
      db 0x9a
      db 0xcf
      db 0
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

.next_sector:
    push ecx

.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again

    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ret

[BITS 64]
long_mode:
      xor ax, ax
      mov ss, ax
      ; mov rsp, 0x7c00

      jmp 0x9000

GDT64:
      dq 0
      ; D=0  L=1  P=1  DPL=0  1  1  C=0
      dq 0x0020980000000000

GDT64_LEN: equ $-GDT64

GDT64_PTR:
      dw GDT64_LEN - 1
      dd GDT64

times 4096-($-loader) db 0x90