#!/usr/bin/env bash
set -euo pipefail


mkdir -p initramfs

cd src

if [ ! -d busybox ]; then
    git clone --depth 1 https://git.busybox.net/busybox
fi

cd busybox

make defconfig

KCFG=./scripts/config

# Ativar binário estático
sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config

# Desativar tc
sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config

# Aplicar mudanças
make oldconfig

make -j$(nproc)

make CONFIG_PREFIX=../../initramfs install





cd ../../initramfs

#ln -s bin/busybox init