void puts(char *s);

typedef short int int16_t;
typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long int uint64_t;

#include <bootboot.h>

extern BOOTBOOT bootboot;               // see bootboot.h
extern unsigned char environment[4096]; // configuration, UTF-8 text key=value pairs
extern uint8_t fb;                      // linear framebuffer mapped

void _start() {
    puts("Cheetah Kernel");
    while (1);
}

typedef struct {
    uint32_t magic;
    uint32_t version;
    uint32_t headersize;
    uint32_t flags;
    uint32_t numglyph;
    uint32_t bytesperglyph;
    uint32_t height;
    uint32_t width;
    uint8_t glyphs;
} __attribute__((packed)) psf2_t;
extern volatile unsigned char _binary_font_psf_start;

void puts(char *s) {
    psf2_t *font = (psf2_t *) &_binary_font_psf_start;
    int x, y, kx = 0, line, mask, offs;
    int bpl = (font->width + 7) / 8;
    while (*s) {
        unsigned char *glyph = (unsigned char *) &_binary_font_psf_start + font->headersize +
                               (*s > 0 && *s < font->numglyph ? *s : 0) * font->bytesperglyph;
        offs = (kx * (font->width + 1) * 4);
        for (y = 0; y < font->height; y++) {
            line = offs;
            mask = 1 << (font->width - 1);
            for (x = 0; x < font->width; x++) {
                *((uint32_t *) ((uint64_t) &fb + line)) = ((int) *glyph) & (mask) ? 0xFFFFFF : 0;
                mask >>= 1;
                line += 4;
            }
            *((uint32_t *) ((uint64_t) &fb + line)) = 0;
            glyph += bpl;
            offs += bootboot.fb_scanline;
        }
        s++;
        kx++;
    }
}
