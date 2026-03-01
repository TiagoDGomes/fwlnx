#!/usr/bin/env bash

cd src/linux
make isoimage FDINITRD=../../build/initramfs.cpio.gz FDARGS="initrd=/initramfs.cpio.gz"

cd ../../

mv src/linux/arch/x86/boot/image.iso build/fwlnx.iso
