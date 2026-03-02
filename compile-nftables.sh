#!/bin/bash
set -euo pipefail
# Configurações de diretório
WORKING_DIR=$(pwd)/src/nft_build
INSTALL_DIR=$WORKING_DIR/dist
INITRAMFS_DIR=$(pwd)/initramfs
INITRAMFS_BIN_DIR=$INITRAMFS_DIR/usr/bin
INITRAMFS_SBIN_DIR=$INITRAMFS_DIR/usr/sbin
INITRAMFS_LIB_DIR=$INITRAMFS_DIR/usr/lib

mkdir -p $INSTALL_DIR $INITRAMFS_BIN_DIR $INITRAMFS_SBIN_DIR

set -e

echo "--- Iniciando compilação estática do nftables ---"

# 1. Compilar libmnl (Minimalistic Netlink Library)
echo "Compilando libmnl..."
cd $WORKING_DIR
[ ! -d 'libmnl' ] && git clone https://git.netfilter.org/libmnl
cd libmnl
./autogen.sh
./configure --prefix=$INSTALL_DIR --enable-static --disable-shared
make -j$(nproc) && make install

# 2. Compilar libnftnl (Netlink interface to nftables)
echo "Compilando libnftnl..."
cd $WORKING_DIR
[ ! -d 'libnftnl' ] && git clone https://git.netfilter.org/libnftnl
cd libnftnl
./autogen.sh
PKG_CONFIG_PATH=$INSTALL_DIR/lib/pkgconfig ./configure --prefix=$INSTALL_DIR --enable-static --disable-shared
make -j$(nproc) && make install

# 3. Compilar nftables (O binário final)
echo "Compilando nftables (Static)..."
cd $WORKING_DIR
[ ! -d 'nftables' ] && git clone https://git.netfilter.org/nftables
cd nftables
./autogen.sh
# Configuração focada em minimalismo (sem readline para evitar dependências extras de ncurses)
PKG_CONFIG_PATH=$INSTALL_DIR/lib/pkgconfig \
LDFLAGS="-L$INSTALL_DIR/lib -static" \
./configure \
    --prefix=$INSTALL_DIR \
    --sbindir=$INITRAMFS_SBIN_DIR \
    --bindir=$INITRAMFS_BIN_DIR \
    --without-json \
    --disable-debug \
    --disable-man-pages \
    --without-cli \
    --disable-shared \
    --disable-man-doc \
    --enable-static

make -j$(nproc)
make install


file $INITRAMFS_SBIN_DIR/nft



ldd $INITRAMFS_SBIN_DIR/nft | while read -r line; do
    # Extrai caminhos absolutos
    LIB=$(echo "$line" | grep -o '/[^ ]*') || true
    echo $LIB
    if [ -f "$LIB" ]; then
        echo "[*] Copiando $LIB"
        mkdir -p "$INITRAMFS_DIR$(dirname "$LIB")"
        cp -v "$LIB" "$INITRAMFS_DIR$LIB"
    fi
done