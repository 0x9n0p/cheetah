# Cheetah

## Initialization Process

### Bootloader
Cheetah uses [GRUB2](https://en.wikipedia.org/wiki/GNU_GRUB) as its main bootloader.

The GRUB configuration file located on build/iso/boot/grub/grub.cfg has two entries:
1. 32-bit Loader to configure modes and jump to kernel entry
2. 64-bit Kernel

#### Parse Kernel ELF
A physical pointer is stored in EBX that points to the multiboot_info structure.
This structure is 8-byte aligned, and contains tags. These tags may contain useful information about the system, for example: the memory map, ELF sections of the image and information about the framebuffer. 
<br>
**TODO: Find loaded kernel ELF by this structure.**
