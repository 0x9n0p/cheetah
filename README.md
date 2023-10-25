# Cheetah

## Initialization Process

### Bootloader

We use our simple bootloader written in pure assembly, but you can easily customize Cheetah to support other bootloaders, such as GRUB2.

1. BIOS loads the first sector of the bootable disk into 0x7C00.
2. This sector loads the following two sectors (The loader) into 0x7E00 and jumps to the starting address.
3. This loader is responsible for loading the kernel.