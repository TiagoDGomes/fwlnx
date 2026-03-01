#!/usr/bin/env bash


qemu-system-x86_64 -kernel boot-partition/bzImage -initrd boot-partition/initramfs.cpio.gz -append "loglevel=1 console=ttyS0"  -serial stdio -monitor none 