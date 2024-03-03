set arch riscv:rv64
target remote  127.0.0.1:15234
symbol-file build/kernel
set riscv use-compressed-breakpoints yes
b *0x1000l
