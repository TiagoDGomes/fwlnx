#!/usr/bin/env bash


cd src 

if [ ! -d dropbear ]; then
    git clone --depth 1 https://github.com/mkj/dropbear.git
fi

cd dropbear

./configure --disable-zlib --enable-static
make PROGRAMS="dropbear dbclient dropbearkey scp" MULTI=1

cp dropbearmulti ../../initramfs/usr/sbin/dropbear

cd ../../initramfs/usr/bin
rm ssh
rm scp
rm dropbearkey
ln -s ../sbin/dropbear ssh
ln -s ../sbin/dropbear scp
ln -s ../sbin/dropbear dropbearkey

