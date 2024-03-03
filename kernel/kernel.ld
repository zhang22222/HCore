OUTPUT_ARCH(riscv)
ENTRY(_entry)
BASE_ADDRESS = 0x80200000;

SECTIONS
{
    . = BASE_ADDRESS;
    skernel = .;

    stext = .;
    .text : {
        *(.text.entry)
        *(.text .text.*)
    }
    etext = .;

    . = ALIGN(4k);
    srodata = .;
    .rodata : {
        *(.rodata .rodata.*)
    }
    erodata = .;

    . = ALIGN(4k);
    sdata = .;
    .data : {
        *(.data .data.*)
    }

    edata = .;

    . = ALIGN(4k);
    sbss = .;
    .bss : {
        *(.bss .bss.*)
    }
    ebss = .;

    ekernel = .;
}