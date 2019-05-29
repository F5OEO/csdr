#!/bin/sh
# This software is part of libcsdr, a set of simple DSP routines for 
# Software Defined Radio.
#
# Copyright (c) 2014, Andras Retzler <randras@sdr.hu>
# Copyright (c) 2019, MeFisto94
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the copyright holder nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This file will try to detect the correct GCC optimization parameters, especially when running on ARM Platforms such as the Raspberry Pi

# Desktop Processors
if grep -q sse /proc/cpuinfo; then
    if grep -q sse /proc/cpuinfo; then 
        PARAMS_SSE="$PARAMS_SSE-msse"
    fi
    if grep -q sse2 /proc/cpuinfo; then 
        PARAMS_SSE="$PARAMS_SSE -msse2"
    fi
    if grep -q sse3 /proc/cpuinfo; then 
        PARAMS_SSE="$PARAMS_SSE -msse3"
    fi
    if grep -q sse4a /proc/cpuinfo; then 
        PARAMS_SSE="$PARAMS_SSE -msse4a"
    fi
    if grep -q sse4_1 /proc/cpuinfo; then 
        PARAMS_SSE="$PARAMS_SSE -msse4.1"
    fi
    # TODO: Is this "-msse4" only for sse4_2 intended?
    if grep -q sse4_2 /proc/cpuinfo; then
        PARAMS_SSE="$PARAMS_SSE -msse4.2 -msse4"
    fi
    echo "$PARAMS_SSE -mfpmath=sse"
    return 0
else
    ARCH=$(uname -m)
    # Detect Raspberry Pi
    if grep -q 'Raspberry' /proc/device-tree/model; then
        if [ "$ARCH" = "aarch64" ]; then # Probably RPi 3+ on 64bit
            # Float ABI is always hard on AARCH64. TODO: Does RPi 1 or 2 also have aarch64?
            PARAMS_PI="-mcpu=cortex-a53 -mtune=cortex-a53"
        else # note -mcpu replaces -march
        # See https://gist.github.com/fm4dd/c663217935dc17f0fc73c9c81b0aa845
            if grep -q 3 /proc/device-tree/model; then
                PARAMS_PI="-mcpu=cortex-a53 -mfloat-abi=hard -mfpu=neon-fp-armv8 -mneon-for-64bits"
            elif grep -q 2 /proc/device-tree/model; then
                PARAMS_PI="-mcpu=cortex-a7 -mfloat-abi=hard -mfpu=neon-vfpv4"
            elif grep -q 1 /proc/device-tree/model; then
                PARAMS_PI="-mcpu=arm1176jzf-s -mfloat-abi=hard -mfpu=vfp"
            fi
        fi
        PARAMS_ARM="$PARAMS_PI -funsafe-math-optimizations -Wformat=0"
    else # Generic ARM Device
        # Most likely mtune is incorrect here
        PARAMS_ARM = "-mfloat-abi=hard -march=`uname -m` -mtune=cortex-a8 -mfpu=neon -mvectorize-with-neon-quad -funsafe-math-optimizations -Wformat=0 -DNEON_OPTS"
    fi
    echo $PARAMS_ARM
    return 0
fi
