# Cheetah
The simplest way to implement a 64-bit kernel.
#### Build & Run
Install [x86_64-elf-gcc](https://aur.archlinux.org/packages/x86_64-elf-gcc) and [qemu-system-x86_64](https://archlinux.org/packages/extra/x86_64/qemu-system-x86/), then run ```make run```

## Initialization Process

### Bootloader

We use a simple assembly-written bootloader, but you can customize Cheetah to support other bootloaders, such as [GRUB2](https://www.gnu.org/software/grub).

1. During the boot process, the Basic Input/Output System (BIOS) loads the first sector of the bootable disk into the memory address 0x7C00.
2. This sector loads the following eight sectors (The loader) into 0x7E00 and jumps to the starting address.
3. The loader (Bootstrap) sets up a basic protected mode environment. Once in protected mode, we use ATA to load the 64-bit kernel, consisting of eight sectors. The bootstrap is responsible for setting up paging and other requirements to enable long mode, allowing us to jump to the kernel's 64-bit entry point.

## Memory Management
### Global Descriptor Table (GDT)
The Global Descriptor Table (GDT) is a binary data structure specific to the IA-32 and x86-64 architectures. It contains entries telling the CPU about memory segments. [Source](https://wiki.osdev.org/Global_Descriptor_Table) <br>
[We previously defined the GDT in the context of bootstrap and protected mode](https://github.com/0x9n0p/cheetah/blob/dev/src/bootloader.s#L144). The GDT has three entries. The first entry must be left empty. The second entry specifies a code segment that has the base address of 0x00 and a limit of 0xffff. Similarly, the third entry specifies a data segment that is defined in the same way as the code segment.

## Resources
https://stackoverflow.com/questions/381244/purpose-of-memory-alignment
