#!/bin/bash


#export CLANG_VER="9.0-r353983c"
#export CLANG_VER="10.0-r370808"
export CLANG_VER="12.0-r416183b"
#export CLANG_VER="14.0-r450784d"

#export CLANG_PATH=/usr/lib/llvm-android-${CLANG_VER}/bin
export CLANG_PATH=/opt/clang-r445002/bin

#xport PATH=/usr/lib/llvm-android-${CLANG_VER}/bin:$PATH
#export ARCH=arm64
#export CROSS_COMPILE=aarch64-linux-gnu-
#export CLANG_TRIPLE=aarch64-linux-gnu-
export CLANG=$CLANG_PATH/clang
#CROSS_TYPE="android" 
CROSS_TYPE="gnu" 
## create python link
#if [ ! -e "/usr/bin/python" ]; then
#    [ -e "/usr/bin/python3" ] && ln -s /usr/bin/python3 /usr/bin/python
#fi


fn_mrproper() {
    PATH=${CLANG_PATH}:$PATH \
    make -C /buildd/sources ARCH=arm64 \
	CROSS_COMPILE=aarch64-linux-${CROSS_TYPE}- \
	CROSS_COMPILE_ARM32=aarch64-linux-${CROSS_TYPE}- \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	-j8 \
	 O=/buildd/sources/out/KERNEL_OBJ CC=clang \
	 mrproper
}

fn_gen_defconfig() {
    PATH=${CLANG_PATH}:$PATH \
    make -C /buildd/sources ARCH=arm64 \
	CROSS_COMPILE=aarch64-linux-${CROSS_TYPE}- \
	CROSS_COMPILE_ARM32=aarch64-linux-${CROSS_TYPE}- \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	-j8 \
	 O=/buildd/sources/out/KERNEL_OBJ CC=clang \
	 vayu2_user_defconfig
}

fn_merge_fragments() {
    /buildd/sources/scripts/kconfig/merge_config.sh \
	-O /buildd/sources/out/KERNEL_OBJ \
	-m /buildd/sources/out/KERNEL_OBJ/.config \
	/buildd/sources/droidian/vayu.config \
	/buildd/sources/droidian/common_fragments/droidian.config \
	/buildd/sources/droidian/common_fragments/halium.config
}

fn_menuconfig() {
    PATH=${CLANG_PATH}:$PATH \
    make -C /buildd/sources ARCH=arm64 \
	CROSS_COMPILE=aarch64-linux-${CROSS_TYPE}- \
	CROSS_COMPILE_ARM32=aarch64-linux-${CROSS_TYPE}- \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	-j8 \
	 O=/buildd/sources/out/KERNEL_OBJ CC=clang \
	 menuconfig
}

fn_olddefconfig() {
    PATH=${CLANG_PATH}:$PATH \
    make -C /buildd/sources ARCH=arm64 \
	CROSS_COMPILE=aarch64-linux-${CROSS_TYPE}- \
	CROSS_COMPILE_ARM32=aarch64-linux-${CROSS_TYPE}- \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	-j8 \
	 O=/buildd/sources/out/KERNEL_OBJ CC=clang \
	 KCONFIG_CONFIG=/buildd/sources/out/KERNEL_OBJ/.config olddefconfig
}

fn_compile_kernel() {
    PATH=${CLANG_PATH}:$PATH \
    make -C /buildd/sources \
	KERNELRELEASE=4.14-290-xiaomi-vayu \
	ARCH=arm64 \
	CROSS_COMPILE=aarch64-linux-${CROSS_TYPE}- \
	CROSS_COMPILE_ARM32=aarch64-linux-${CROSS_TYPE}- \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	-j8 \
	LLVM=1 LLVM_IAS=1 \
	O=/buildd/sources/out/KERNEL_OBJ \
	CC=clang 
}

#fn_menuconfig

fn_mrproper
fn_gen_defconfig
fn_merge_fragments
#fn_olddefconfig
fn_compile_kernel

	#HOSTLDFLAGS="-fuse-ld=gold --rtlib=compiler-rt" \
	#LDFLAGS="" CFLAGS="" \
