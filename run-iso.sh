#!/usr/bin/env bash


qemu-system-x86_64 -cdrom boot-partition/fwlnx.iso -m 512 -serial stdio -monitor none 