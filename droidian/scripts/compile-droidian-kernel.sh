#!/bin/bash

START_DIR="/buildd/sources"
ROOTDIR="/opt"

fn_install_prereqs() {
 apt-get install linux-packaging-snippets bc bison build-essential ccache curl flex git git-lfs gnupg gperf imagemagick libelf-dev  libncurses5-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python3 python-is-python3
# libsdl1.2-dev
}

fn_enable_ccache() {
    ## Use ccache tu speedup the build
    export USE_CCACHE=1
    export CCACHE_EXEC=/usr/bin/ccache
    ccache -M 10G
    ccache -o compression=false
}

fn_install_toolchains() {
    cd /opt

    ## If kernel is not previously downloaded.
    # git clone https://github.com/LineageOS/android_kernel_device
    #
    # gcc
    git clone -b lineage-18.1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git
    #
    # clang
#    git clone https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b.git
    #
    # wireguard kernel module
    # git clone https://github.com/WireGuard/wireguard-linux-compat.git
    #
    # built-tools

# android-11.0.0_r0.100
# android-13.0.0_r0.117
    git clone -b android-11.0.0_r0.100 https://android.googlesource.com/kernel/prebuilts/build-tools
    git clone -b lineage-18.1 https://github.com/LineageOS/android_prebuilts_tools-lineage.git
}

fn_invert_PATH_kernel_snippet() {
    ## Patch releng kernel-snippet.mk
    ## To use the lineage toolchain, the FULL_PATH var needs to be defined with the PATH var at the beguin
    sed -i 's|FULL_PATH = $(BUILD_PATH):$(CURDIR)/debian/path-override:${PATH}|FULL_PATH = ${PATH}:$(BUILD_PATH):$(CURDIR)/debian/path-override|g' /usr/share/linux-packaging-snippets/kernel-snippet.mk
}

fn_install_prereqs
fn_enable_ccache

## CUSTOM TOOLCHAIN
fn_invert_PATH_kernel_snippet
fn_install_toolchains
## Paths defined in kernel-info.mk

chmod +x /buildd/sources/debian/rules
cd /buildd/sources
rm -f debian/control
debian/rules debian/control

RELENG_HOST_ARCH=arm64 releng-build-package
