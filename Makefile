CFLAGS = -Wall -fpic -ffreestanding -fno-stack-protector -nostdinc -nostdlib -Ibootboot/dist/
LDFLAGS =  -nostdlib -n -T link.ld
STRIPFLAGS =  -s -K mmio -K fb -K bootboot -K environment -K initstack

all: kernel.elf

kernel.elf:
	mkdir -p boot
	x86_64-elf-gcc $(CFLAGS) -mno-red-zone -c src/kernel.c -o kernel.o
	x86_64-elf-ld -r -b binary -o font.o font.psf
	x86_64-elf-ld $(LDFLAGS) kernel.o font.o -o boot/kernel.elf
	x86_64-elf-strip $(STRIPFLAGS) boot/kernel.elf
	x86_64-elf-readelf -hls boot/kernel.elf > kernel.txt

image: kernel.elf
	bootboot/mkbootimg/mkbootimg mkbootimg.json cheetah.img

run: image
	qemu-system-x86_64 -hda cheetah.img

clean:
	rm -rf *.o *.txt boot cheetah.img || true
