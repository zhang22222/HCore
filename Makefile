.PHONY: build run debug clean

TOOLPREFIX = riscv64-linux-gnu-

CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gcc
LD = $(TOOLPREFIX)ld
GDB = gdb-multiarch

BUILD_DIR=build

ASM_SRCS=$(wildcard kernel/src/*.S)
ASM_OBJS=$(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(basename $(notdir $(ASM_SRCS)))))


C_SRCS_DIR = kernel/src


C_SRCS=$(wildcard kernel/src/*.c)

C_OBJS=$(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(basename $(notdir $(C_SRCS)))))

C_HEADERS=kernel/include/

OBJS=$(C_OBJS) $(ASM_OBJS) 

HEADER_DEP = $(addsuffix .d, $(basename $(C_OBJS)))

CFLAGS = -ffreestanding -nostdlib
CFLAGS += -Wall -Werror -O -fno-omit-frame-pointer -ggdb
# CFLAGS += -MD
# CFLAGS = -std=c17
CFLAGS += -mcmodel=medany
CFLAGS += -ffreestanding -fno-common -nostdlib -mno-relax
CFLAGS += -I $(C_HEADERS)
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)


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


$(C_OBJS):$(BUILD_DIR)/%.o:$(C_SRCS_DIR)/%.c
	@echo $<
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@
# build/sbi.o:
# 	@mkdir -p $(BUILD_DIR)
# 	$(CC) $(CFLAGS) -c kernel/arch/riscv64/io/sbi.c   -o $@

# build/start.o:
# 	@mkdir -p $(BUILD_DIR)
# 	$(CC) $(CFLAGS) -c kernel/arch/riscv64/boot/start.c   -o $@

$(ASM_OBJS) : $(ASM_SRCS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $^ -o $@

# $(HEADER_DEP): $(BUILDDIR)/%.d : $(C_SRCS)
# 	@mkdir -p $(@D)
# 	@set -e; rm -f $@; $(CC) -MM $< $(INCLUDEFLAGS) > $@.$$$$; \
#         sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
#         rm -f $@.$$$$


build/kernel:$(OBJS) 
	@echo $(OBJS)
	$(LD) $(LD_FLAGS) -T kernel/kernel.ld -o $(BUILD_DIR)/kernel $(OBJS)
	

# 
# build:$(OBJS)
# @echo $^
build:build/kernel

run:build
	$(QEMU) $(QEMUOPTS)


debug:build .gdbinit
	$(QEMU) $(QEMUOPTS) -S $(QEMUGDB) &
	sleep 1
	$(GDB)

clean:
	@rm -rf $(BUILD_DIR)