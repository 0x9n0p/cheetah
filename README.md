# Cheetah

## Initialization Process

### Bootloader

We use our simple bootloader written in pure assembly, but you can easily customize Cheetah to support other
bootloaders, such as GRUB2.

1. BIOS loads the first sector of the bootable disk into 0x7C00.
2. This sector loads the following 8 sectors (The loader) into 0x7E00 and jumps to the starting address.
3. This loader is responsible for loading the kernel.
   <br>
   &emsp; 1. **TODO** Test A20 line and make sure the processor supports 64-bit mode using cpuid instruction.
   <br>
   &emsp; 2. Setup text mode because we cannot use BIOS functionalities on protected mode.
   <br>
   &emsp; 3. Setups GDT and LDT and enables protected mode.
   <br>
   &emsp; 4. Loads kernel using the ATA into 1MB address.
<br>
