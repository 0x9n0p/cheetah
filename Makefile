bootloader:
	nasm -f bin -o build/bootloader.bin bootloader/bootloader.s
	#nasm -f bin -o build/loader.bin bootloader/loader.s

debug: bootloader
	qemu-system-x86_64 -m 1024 build/bootloader.bin -S -s &
	gdb build/bootloader.elf -ex 'source .breakpoints' -ex 'target remote localhost:1234'

run: bootloader
	qemu-system-x86_64 -m 1024 build/bootloader.bin

debug-rm: bootloader
	qemu-system-i386  build/bootloader.bin -s -S &
	gdb -ix gdb_init_real_mode.txt \
            -ex 'set tdesc filename target.xml' \
            -ex 'target remote localhost:1234' \
            -ex 'source .breakpoints'

clean:
	rm -rf build/* | true

.PHONY: bootloader