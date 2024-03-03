.section .text
.global _entry

_entry:
    la sp, kernel_stack
    li a0, 8192
    csrr a1, mhartid
    addi a1, a1, 1
    mul a0, a1, a0
    add sp, a0, sp

    call start

spin:
    j spin
