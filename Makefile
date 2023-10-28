CFLAGS = -Wall -fpic -ffreestanding -fno-stack-protector -nostdinc
LDFLAGS = -nostdlib -n -T src/kernel.ld

bootloader:
	mkdir -p build
	nasm -f bin -o build/bootloader.bin src/bootloader.s

kernel:
	nasm -f elf64 -o build/kernel.asm.o src/kernel.s
	x86_64-elf-gcc $(CFLAGS) -mno-red-zone -c src/kernel.c -o build/kernel.c.o
	x86_64-elf-ld $(LDFLAGS) build/kernel.asm.o build/kernel.c.o -o build/kernel.bin

image: bootloader kernel
	dd if=build/bootloader.bin bs=512 >> build/cheetah.img
	dd if=/dev/zero of=build/cheetah.img bs=512 count=8 seek=9 conv=notrunc
	dd if=build/kernel.bin of=build/cheetah.img bs=512 seek=9 conv=notrunc

debug: image
	qemu-system-x86_64 -m 2048 build/cheetah.img -S -s &
	gdb build/bootloader.elf -ex 'source .breakpoints' -ex 'target remote localhost:1234'

run: image
	qemu-system-x86_64 -m 2048 build/cheetah.img

debug-rm: image
	qemu-system-i386  build/cheetah.img -s -S &
	gdb -ix gdb_init_real_mode.txt \
            -ex 'set tdesc filename target.xml' \
            -ex 'target remote localhost:1234' \
            -ex 'source .breakpoints'

clean:
	rm -rf build | true

.PHONY: bootloader kernel image