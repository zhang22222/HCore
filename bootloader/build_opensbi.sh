export CROSS_COMPILE=riscv64-linux-gnu-
export PLATFORM_RISCV_XLEN=64
OPENSBI_PATH=$(dirname $(realpath $0))/../thirdparty/opensbi 

cd $OPENSBI_PATH  && make PLATFORM=generic && cd ../../
cp $OPENSBI_PATH/build/platform/generic/firmware/fw_jump.bin ./bootloader/

unset CROSS_COMPILE
unset PLATFORM_RISCV_XLEN

cd $OPENSBI_PATH && make clean && rm -rf build