LOADER_TMP= build/grub2.o build/loader.o build/os.iso build/iso/boot/loader.elf

loader:
	nasm -f elf32 src/grub2.s -o build/grub2.o
	gcc -std=c99 -m32 -ffreestanding -fno-stack-protector -mno-red-zone -c src/loader.c -o build/loader.o
	ld -T src/loader.ld -melf_i386 build/grub2.o build/loader.o -o build/iso/boot/loader.elf

iso: loader
	grub-mkrescue -o build/os.iso build/iso/

run: iso
	qemu-system-x86_64 -cdrom build/os.iso

debug: iso
	qemu-system-x86_64 -cdrom build/os.iso -monitor stdio -s -S

clean:
	rm -rf $(LOADER_TMP)
