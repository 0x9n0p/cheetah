LOADER_TMP=build/grub2.o build/os.iso build/iso/boot/loader.elf

loader:
	nasm -f elf32 grub2.s -o build/grub2.o
	ld -T loader.ld -melf_i386 build/grub2.o -o build/iso/boot/loader.elf

iso: loader
	grub-mkrescue -o build/os.iso build/iso/

run: iso
	qemu-system-x86_64 -cdrom build/os.iso -monitor stdio

clean:
	rm -rf $(LOADER_TMP)
