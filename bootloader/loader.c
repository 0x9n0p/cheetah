#include "multiboot.h"

void main(const void *multiboot) {
    *((int *) 0xb8000) = 0x07690748;

    const multiboot_info_t *mb_info = multiboot;
    multiboot_uint32_t mb_flags = mb_info->flags;

    // bsp_main
    void *kentry;

    if (mb_flags & MULTIBOOT_INFO_MODS) {
        multiboot_uint32_t mods_count = mb_info->mods_count;   /* Get the amount of modules available */
        multiboot_uint32_t mods_addr = mb_info->mods_addr;     /* And the starting address of the modules */

        for (int mod = 0; mod < mods_count; mod++) {
            multiboot_module_t *module = (multiboot_module_t *) (
                    mods_addr + (mod * sizeof(multiboot_module_t)));
        }
    }
}
