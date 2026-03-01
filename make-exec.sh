#!/bin/sh
cd initramfs
chmod +x usr/sbin/*
chmod +x usr/share/udhcpc/*

cd ../systemroot
chmod +x init
chmod +x etc/init.d/*
