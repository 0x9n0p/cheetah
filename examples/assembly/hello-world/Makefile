build:
	nasm -f bin -o ../../../build/hello_world.asm.bin main.s
	dd if=../../../build/hello_world.asm.bin of=../../../build/cheetah.img bs=512 seek=17
