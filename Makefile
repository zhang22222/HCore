.PHONY: run

TOOLPREFIX = riscv64-linux-gnu-

CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gcc
LD = $(TOOLPREFIX)ld

# qemu paras
QEMU = qemu-system-riscv64
NCPU ?= 1
BOOTLOADER:=./bootloader/fw_jump.bin
QEMUOPTS=-nographic \
	 -machine virt \
	 -bios $(BOOTLOADER) \
	 -smp $(NCPU) \

run:
	$(QEMU) $(QEMUOPTS)