.PHONY: build run debug clean

TOOLPREFIX = riscv64-linux-gnu-

CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gcc
LD = $(TOOLPREFIX)ld
GDB = gdb-multiarch

CFLAGS = -ffreestanding
LD_FLAGS = -z max-page-size=4096
# qemu paras
QEMU = qemu-system-riscv64

# QEMU's gdb stub command line changed in 0.11
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::15234"; \
	else echo "-s -p 15234"; fi)

NCPU ?= 1
BOOTLOADER:=./bootloader/fw_jump.bin
QEMUOPTS=-nographic \
	 -machine virt \
	 -bios $(BOOTLOADER) \
	 -smp $(NCPU) \
	 -kernel $(BUILD_DIR)/kernel \
	#  -s -S 

BUILD_DIR=build

ASM_SRCS=$(wildcard kernel/arch/riscv64/boot/*.S)
ASM_OBJS=$(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(basename $(notdir $(ASM_SRCS)))))

OBJS=$(ASM_OBJS)

$(ASM_OBJS):$(ASM_SRCS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@



build/kernel:$(OBJS) 
	@echo $<
	$(LD) $(LD_FLAGS) -T kernel/kernel.ld -o $(BUILD_DIR)/kernel $<
	

build:build/kernel

run:build
	$(QEMU) $(QEMUOPTS)


debug:build .gdbinit
	$(QEMU) $(QEMUOPTS) -S $(QEMUGDB) &
	sleep 1
	$(GDB)

clean:
	@rm -rf $(BUILD_DIR)