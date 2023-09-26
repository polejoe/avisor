#############################################################
# SPDX-License-Identifier: GPL-2.0-or-later
#
#  aVisor Hypervisor
#
#  A Tiny Hypervisor for IoT Development
#
#  Copyright (c) 2022 Deng Jie (mr.dengjie@gmail.com).
#############################################################

#!/bin/bash

CC=aarch64-elf


build_visor()
{
    # build the aVisor hpervisor
    make clean
    make GNU_TOOLS=${CC} qemu   || return $?
}

build_vm()
{
    # build the lrtos
    cd guests/lrtos
    make clean
    make ARMGNU=${CC} || return $?
    cd -

    # build the echo
    cd guests/echo
    make clean
    make ARMGNU=${CC} || return $?
    cd -
    return $?
}

build_img()
{
# build the Qemu boot img
cp guests/lrtos/lrtos.bin ./bin
cp guests/echo/echo.bin ./bin
cp guests/uboot/uboot.bin ./bin
cp guests/freertos/freertos.bin ./bin
echo linux | sudo modprobe nbd max_part=8
    ./scripts/create_sd.sh ./bin/avisor.img ./bin/lrtos.bin ./bin/echo.bin ./bin/uboot.bin ./bin/freertos.bin
    return $?
}

run()
{
    # Run the Demo
    qemu-system-aarch64 -M raspi3b -nographic -serial null -serial mon:stdio -m 1024 -kernel ./bin/kernel8.img -drive file=./bin/avisor.img,if=sd,format=raw
    return $?
}


arg="$1"

if [ "$arg" = "build" ]; then
    build_visor && build_vm
elif [ "$arg" = "img"  ]; then
    build_img
elif [ "$arg" = "run"  ]; then
    run
else
    build_visor
    build_vm
    build_img
    run
fi




