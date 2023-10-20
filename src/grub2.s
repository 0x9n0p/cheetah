extern main

MAGIC_NUMBER equ 0x1BADB002
FLAGS        equ 0x0
CHECKSUM     equ -MAGIC_NUMBER

KERNEL_STACK_SIZE equ 4096

section .text:
align 4
    dd MAGIC_NUMBER
    dd FLAGS
    dd CHECKSUM

global loader
loader:
    mov esp, kernel_stack + KERNEL_STACK_SIZE
    mov ebp, esp

    ; The multiboot header from GRUB
    ; https://wiki.osdev.org/Creating_a_64-bit_kernel_using_a_separate_loader

    ; On x86, a physical pointer is stored in EBX, while the magic number is stored in EAX.
    ; It's a well-known practice to check the magic number to verify the bootloader passed the correct information.
    ; https://wiki.osdev.org/Multiboot

    push ebx
    call main

    jmp loop

global far_jump_to_bootstrap
far_jump_to_bootstrap:

loop:
    jmp loop

section .bss
align 4
kernel_stack:
    resb KERNEL_STACK_SIZE

global pml4_root
align 8
pml4_root: