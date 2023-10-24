.code16

.section .text
.global _start
_start:
   xor %eax, %eax
   cli
   hlt

. = _start + 510
.byte 0x55
.byte 0xAA
