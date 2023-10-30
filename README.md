# Cheetah
Cheetah is a simple 64-bit kernel that supports C, Go and Rust languages.

### Build & Run
Install [x86_64-elf-gcc](https://aur.archlinux.org/packages/x86_64-elf-gcc) and [qemu-system-x86_64](https://archlinux.org/packages/extra/x86_64/qemu-system-x86/), then run ```make clean image run```

### How to run programs?
Cheetah can load and execute one program. This program must be located in sector 17. [It will be loaded at memory address 0x100000](https://github.com/0x9n0p/cheetah/blob/dev/src/bootloader.s#L98) during the boot process and [executed](https://github.com/0x9n0p/cheetah/blob/dev/src/kernel.c#L8) if [the PROGRAM macro](https://github.com/0x9n0p/cheetah/blob/dev/Makefile#L1) is 1.

#### For example, to run [assembly hello-world](https://github.com/0x9n0p/cheetah/tree/dev/examples/assembly/hello-world):
1. Build Cheetah ```make clean image```
2. Build program and insert it to sector 17 ```(cd examples/assembly/hello-world && make)```
3. Run the image ```make run```

## Initialization Process

### Bootloader

We use a simple assembly-written bootloader, but you can customize Cheetah to support other bootloaders, such as [GRUB2](https://www.gnu.org/software/grub).

1. During the boot process, the Basic Input/Output System (BIOS) loads the first sector of the bootable disk into the memory address 0x7C00.
2. This sector loads the following eight sectors (The loader) into 0x7E00 and jumps to the starting address.
3. The loader (Bootstrap) sets up a basic protected mode environment. Once in protected mode, we use ATA to load the 64-bit kernel, consisting of eight sectors. The bootstrap is responsible for setting up paging and other requirements to enable long mode, allowing us to jump to the kernel's 64-bit entry point.

### Higher Half Kernel
It is traditional and generally good to have your kernel mapped in every user process. Linux and many other Unices, for instance, reside at virtual addresses 0xC0000000 – 0xFFFFFFFF of every address space, leaving the range 0x00000000 – 0xBFFFFFFF for user code, data, stacks, libraries, etc. Kernels that have such design are said to be "in the higher half" by opposition to kernels that use lowest virtual addresses for themselves, and leave higher addresses for the applications. [Source](https://wiki.osdev.org/Higher_Half_Kernel) <br>
[We removed the higher half kernel mapping](https://github.com/0x9n0p/cheetah/commit/649db4806b85dcd5a5f95b8e8e34c13e6e8fdc48) on Cheetah since we only have one program running.

## Memory Management

### Global Descriptor Table (GDT)
The Global Descriptor Table (GDT) is a binary data structure specific to the IA-32 and x86-64 architectures. It contains entries telling the CPU about memory segments. [Source](https://wiki.osdev.org/Global_Descriptor_Table) <br>
[We previously defined the GDT in the context of bootstrap and protected mode](https://github.com/0x9n0p/cheetah/blob/dev/src/bootloader.s#L144). The GDT has three entries. The first entry must be left empty. The second entry specifies a code segment that has the base address of 0x00 and a limit of 0xffff. Similarly, the third entry specifies a data segment that is defined in the same way as the code segment.

### Paging
Paging is a system which allows each process to see a full virtual address space, without actually requiring the full amount of physical memory to be available or present. 32-bit x86 processors support 32-bit virtual addresses and 4-GiB virtual address spaces, and current 64-bit processors support 48-bit virtual addressing and 256-TiB virtual address spaces. [Source](https://wiki.osdev.org/Paging) <br>
During the boot process, [1GB paging has been implemented](https://github.com/0x9n0p/cheetah/blob/dev/src/bootloader.s#L111) on address 0x70000.

## Resources
https://stackoverflow.com/questions/381244/purpose-of-memory-alignment
