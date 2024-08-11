#!/bin/bash

## This script is a launcher to build a lineageos 19.1 kernel using the Droidian releng tools
#
## Version: 0.0.2
#
# Guide URL: https://github.com/droidian/porting-guide/blob/master/kernel-compilation.md#kernel-adaptation
#
# REFERENCES: To do this script, the next link was consulted:
# https://thedoc.eu.org/blog/lineage-os-20-kernel-wireguard-module/
#
# Upstream-Name: compile-droidian-kernel-los19.1-x86-arm6
# Source: https://github.com/berbascum/compile-droidian-kernel-los19.1-x86-arm6
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
#
## Enable ccache
apt-get update
apt-get install ccache -y
# Use ccache tu speedup the build
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 10G
ccache -o compression=true

## Install prereqs
#apt-get update
apt-get install linux-packaging-snippets -y

## Patch releng kernel-snippet.mk
## To use the lineage toolchain, the FULL_PATH var needs to be defined with the PATH var at the beguin
#sed -i 's|FULL_PATH = $(BUILD_PATH):$(CURDIR)/debian/path-override:${PATH}|FULL_PATH = ${PATH}:$(BUILD_PATH):$(CURDIR)/debian/path-override|g' /usr/share/linux-packaging-snippets/kernel-snippet.mk

## Recreate debian/control
chmod +x /buildd/sources/debian/rules
cd /buildd/sources
rm -f debian/control
debian/rules debian/control

## Build package
RELENG_HOST_ARCH=arm64 releng-build-package
