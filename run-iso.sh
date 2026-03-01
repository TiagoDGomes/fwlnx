#!/usr/bin/env bash


qemu-system-x86_64 -cdrom build/fwlnx.iso -m 512 -serial stdio -monitor none 