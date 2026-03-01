#!/usr/bin/env bash


qemu-system-x86_64 -kernel build/bzImage -initrd build/initramfs.cpio.gz -append "loglevel=1 console=ttyS0"  -serial stdio -monitor none 