
void print(const char *str, int n);

void _start(void) {
    char str[] = "Cheetah Kernel";
    print(str, sizeof(str));

#if PROGRAM
    __asm__ (
        "push $0x8\n"
        "push $0x100000\n"
        "lretq\n"
    );
#endif

    __asm__ __volatile__ ("hlt");
}

// TODO: Move the cursor
void print(const char *str, int n) {
    char *vga = (char *) 0xb8000;
    int char_counter = 0;
    for (int i = 0; i < n * 2; i = i + 2) {
        vga[i] = str[char_counter];
        vga[i + 1] = 0x07;
        char_counter++;
    }
}
