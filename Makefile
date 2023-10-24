bootloader:
	as -o build/boot.o bootloader/boot.s
	ld -Ttext 0x7C00 -o build/boot.elf build/boot.o
	objcopy -O binary build/boot.elf build/boot.bin

debug: bootloader
	qemu-system-x86_64 -m 1024 build/boot.bin -S -s &
	gdb build/boot.elf -ex 'source .breakpoints' -ex 'target remote localhost:1234'

run: bootloader
	qemu-system-x86_64 -m 1024 build/boot.bin

clean:
	rm -rf build/* | true

.PHONY: bootloader