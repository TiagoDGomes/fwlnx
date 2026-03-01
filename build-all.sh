#!/usr/bin/env bash

./compile-linux.sh
./compile-busybox.sh
./compile-ssh.sh
./generate-initramfs.sh
./build-iso.sh
