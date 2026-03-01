#!/usr/bin/env bash

cd src/linux
make isoimage FDINITRD=../../boot-partition/initramfs.cpio.gz FDARGS="initrd=/initramfs.cpio.gz"

cd ../../

mv src/linux/arch/x86/boot/image.iso boot-partition/fwlnx.iso
