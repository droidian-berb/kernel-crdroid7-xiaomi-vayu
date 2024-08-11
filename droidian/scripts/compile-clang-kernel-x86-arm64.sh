#!/bin/bash

## Script to compile a kernel with clang
#
# Version: 0.0.1
#
# Upstream-Name: compile-clang-kernel-xb6-arm64
# Source: https://github.com/berbascum/compile-clang-kernel-xb6-arm64
#
# Copyright (C) 2024 Berbascum <berbascum@ticv.cat>
# All rights reserved.
#
# BSD 3-Clause License
#
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the <organization> nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


## Use ccache tu speedup the build
# export USE_CCACHE=1
# export CCACHE_EXEC=/usr/bin/ccache
# ccache -M 10G
# ccache -o compression=true  

# CLANG_VER="9.0-r353983c"
# CLANG_VER="10.0-r370808"
#CLANG_VER="12.0-r416183b"
CLANG_VER="14.0-r450784d"

# CROSS_TYPE="android"
CROSS_TYPE="gnu" 
#COMPILER="aarch64-linux-android-gcc-4.9"
COMPILER=clang

CLANG_PATH="/usr/lib/llvm-android-${CLANG_VER}/bin"
export PATH=${CLANG_PATH}:$PATH
export AS=aarch64-linux-${CROSS_TYPE}-as
export LD=aarch64-linux-${CROSS_TYPE}-ld
export AR=aarch64-linux-${CROSS_TYPE}-ar
export NM=aarch64-linux-${CROSS_TYPE}-nm
# export OBJCOPY=aarch64-linux-${CROSS_TYPE}-objcopy
# export OBJDUMP=aarch64-linux-${CROSS_TYPE}-objdump
# export STRIP=aarch64-linux-${CROSS_TYPE}-strip

## create python link
#if [ ! -e "/usr/bin/python" ]; then
#    [ -e "/usr/bin/python3" ] && ln -s /usr/bin/python3 /usr/bin/python
#fi


#export CLANG=$CLANG_PATH/clang

#update-alternatives --install /usr/bin/as as $CLANG_PATH/aarch64-linux-android-as 100
#update-alternatives --config as
#exit

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-${CROSS_TYPE}-
export CROSS_COMPILE_ARM32=aarch64-linux-${CROSS_TYPE}-
export CLANG_TRIPLE=aarch64-linux-gnu-

fn_mrproper() {
    make -C /buildd/sources ARCH=arm64 \
	O=/buildd/sources/out/KERNEL_OBJ \
	CC=$COMPILER \
	mrproper
}

fn_gen_main_defconfig() {
    ## Load android kernel original main defconfig
    make -C /buildd/sources ARCH=arm64 \
	O=/buildd/sources/out/KERNEL_OBJ \
	CC=$COMPILER \
        vendor/sm8150_defconfig
    ## Merge original device fragments into main defconfig
    ## to create the droidian main defconfig
    /buildd/sources/scripts/kconfig/merge_config.sh \
	-O /buildd/sources/out/KERNEL_OBJ \
	-m /buildd/sources/out/KERNEL_OBJ/.config \
	/buildd/sources/arch/arm64/configs/vendor/xiaomi/sm8150-common.config
    /buildd/sources/scripts/kconfig/merge_config.sh \
	-O /buildd/sources/out/KERNEL_OBJ \
	-m /buildd/sources/out/KERNEL_OBJ/.config \
	/buildd/sources/arch/arm64/configs/vendor/xiaomi/vayu.config
    ## copy .config to arch configs base dir
    cp -av  out/KERNEL_OBJ/.config \
	    /buildd/sources/arch/arm64/configs/vayu_user_defconfig
}

fn_set_defconfig() {
    make -C /buildd/sources ARCH=arm64 \
	O=/buildd/sources/out/KERNEL_OBJ \
	CC=$COMPILER \
	vayu_user_defconfig
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
    make -C /buildd/sources ARCH=arm64 \
	O=/buildd/sources/out/KERNEL_OBJ \
	CC=$COMPILER \
	menuconfig
}

fn_olddefconfig() {
    make -C /buildd/sources ARCH=arm64 \
	O=/buildd/sources/out/KERNEL_OBJ \
	CC=$COMPILER \
	KCONFIG_CONFIG=/buildd/sources/out/KERNEL_OBJ/.config olddefconfig
}

fn_compile_kernel() {
    make -C /buildd/sources ARCH=arm64 \
     KERNELRELEASE=4.14-180-xiaomi-vayu \
     LLVM=1 LLVM_IAS=1 \
     -j8 \
     O=/buildd/sources/out/KERNEL_OBJ \
     CC=$COMPILER
     # CXX=clang++ \
}

fn_menuconfig

# bash
###fn_mrproper
#fn_gen_main_defconfig
###fn_set_defconfig
#fn_merge_fragments
#fn_olddefconfig
###fn_compile_kernel


