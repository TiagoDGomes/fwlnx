#!/usr/bin/env bash
set -euo pipefail


#####################################################
### initramfs
#####################################################

mkdir -p initramfs/{bin,sbin,etc,proc,sys,usr/bin,usr/sbin,dev,tmp,var,mnt}
cd initramfs

cat <<'EOF' > init
#!/bin/sh

exec 0</dev/console 1>/dev/console 2>/dev/console

echo "[INITRAMFS] Bootando..."

# Montar pseudo-filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

echo "[INITRAMFS] Detectando dispositivos..."
sleep 2  # dá tempo para o kernel popular /dev

mkdir -p /newroot

is_valid_root() {
    [ -x /newroot/sbin/init ] && return 0
    [ -x /newroot/init ] && return 0
    return 1
}

try_mount() {
    DEV="$1"
    echo "[INITRAMFS] Testando $DEV..."

    mount -o ro "$DEV" /newroot 2>/dev/null || return 1

    if is_valid_root; then
        echo "[INITRAMFS] Root válido encontrado em $DEV"
        return 0
    fi

    umount /newroot
    return 1
}

ROOTDEV=$(cat /proc/cmdline | sed -n 's/.*root=\([^ ]*\).*/\1/p')

if [ -n "$ROOTDEV" ] && [ -b "$ROOTDEV" ]; then
    try_mount "$ROOTDEV" && FOUND="$ROOTDEV"
fi


FOUND=""

# Busca automática por partições comuns
for DEV in /dev/sd* /dev/vd* /dev/hd* /dev/nvme*n*p*; do
    [ -b "$DEV" ] || continue
    try_mount "$DEV" && { FOUND="$DEV"; break; }
done

if [ -n "$FOUND" ]; then
    echo "[INITRAMFS] Preparando switch_root..."

    mount --move /proc /newroot/proc
    mount --move /sys /newroot/sys
    mount --move /dev /newroot/dev

    echo "[INITRAMFS] Executando switch_root..."
    exec switch_root /newroot /sbin/init
fi

##################################################
# Fallback seguro
##################################################

echo
echo "[INITRAMFS] Nenhuma instalação encontrada."
echo "[INITRAMFS] Entrando em modo básico."
echo

exec /bin/sh
EOF

chmod +x init

[[ -f 'linuxrc' ]] && rm linuxrc

mkdir -p {bin,sbin,etc,proc,sys,usr/bin,usr/sbin,dev,tmp,var,mnt,root}
mkdir -p etc/{dropbear,init.d}

rsync -aHAX ../systemroot/ ./

../make-exec.sh




echo "[BUILD] Gerando initramfs completo..."
fakeroot sh -c 'find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../build/initramfs.cpio.gz'
cd ..
