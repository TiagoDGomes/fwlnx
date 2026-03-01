#!/usr/bin/env bash
set -euo pipefail

KERNEL_VERSION="v6.18.15"

mkdir -p src build initramfs

cd src

if [ ! -d linux ]; then
    git clone --depth 1 --branch ${KERNEL_VERSION} https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
fi

cd linux

make defconfig

KCFG=./scripts/config

# ===============================
# BASE DE REDE
# ===============================

$KCFG --enable CONFIG_NET
$KCFG --enable CONFIG_PACKET
$KCFG --enable CONFIG_UNIX
$KCFG --enable CONFIG_INET
$KCFG --enable CONFIG_IPV6


# ===============================
# ADVANCED ROUTING
# ===============================

$KCFG --enable CONFIG_IP_ADVANCED_ROUTER
$KCFG --enable CONFIG_IP_MULTIPLE_TABLES
$KCFG --enable CONFIG_IPV6_MULTIPLE_TABLES

# ===============================
# NAT IPv4/IPv6
# ===============================

$KCFG --enable CONFIG_NF_NAT_IPV4
$KCFG --enable CONFIG_NF_NAT_IPV6
$KCFG --enable CONFIG_NFT_CHAIN_NAT

# ===============================
# NFTABLES (SEM IPTABLES LEGACY)
# ===============================

$KCFG --enable CONFIG_NETFILTER
$KCFG --enable CONFIG_NF_CONNTRACK
$KCFG --enable CONFIG_NF_NAT
$KCFG --enable CONFIG_NF_TABLES
$KCFG --enable CONFIG_NF_TABLES_INET
$KCFG --enable CONFIG_NF_TABLES_IPV4
$KCFG --enable CONFIG_NF_TABLES_IPV6
$KCFG --enable CONFIG_NFT_CT
$KCFG --enable CONFIG_NFT_NAT
$KCFG --enable CONFIG_NFT_REJECT
$KCFG --enable CONFIG_NFT_MASQ
$KCFG --enable CONFIG_NFT_LOG
$KCFG --enable CONFIG_NF_DEFRAG_IPV6

$KCFG --enable CONFIG_NF_CONNTRACK_BRIDGE

$KCFG --enable CONFIG_IP_NF_IPTABLES
$KCFG --enable CONFIG_IP6_NF_IPTABLES
$KCFG --enable CONFIG_NETFILTER_XTABLES

# ===============================
# PPP
# ===============================
$KCFG --enable CONFIG_PPP_MULTILINK

# ===============================
# VLAN
# ===============================

$KCFG --enable CONFIG_VLAN_8021Q

# ===============================
# BRIDGE
# ===============================

$KCFG --enable CONFIG_BRIDGE
$KCFG --enable CONFIG_BRIDGE_VLAN_FILTERING
$KCFG --enable CONFIG_BRIDGE_NETFILTER
$KCFG --enable CONFIG_NETFILTER_FAMILY_BRIDGE

# ===============================
# PPP
# ===============================

$KCFG --enable CONFIG_PPP
$KCFG --enable CONFIG_PPP_ASYNC
$KCFG --enable CONFIG_PPP_SYNC_TTY
$KCFG --enable CONFIG_PPP_DEFLATE
$KCFG --enable CONFIG_PPP_BSDCOMP
$KCFG --enable CONFIG_PPPOE

# ===============================
# TUNELAMENTO
# ===============================

$KCFG --enable CONFIG_NET_IPIP
$KCFG --enable CONFIG_NET_IPGRE
$KCFG --enable CONFIG_NET_IPVTI
$KCFG --enable CONFIG_IPV6_SIT
$KCFG --enable CONFIG_IPV6_GRE
$KCFG --enable CONFIG_IPV6_VTI

# ===============================
# PERFORMANCE
# ===============================

$KCFG --enable CONFIG_NET_SCH_FQ
$KCFG --enable CONFIG_NET_SCH_HTB
$KCFG --enable CONFIG_BQL
$KCFG --enable CONFIG_RPS
$KCFG --enable CONFIG_RFS_ACCEL
$KCFG --enable CONFIG_XPS
$KCFG --enable CONFIG_SMP
$KCFG --set-val CONFIG_HZ 250
$KCFG --enable CONFIG_NO_HZ_IDLE

# Performance de rede (GRO/GSO/TSO):
$KCFG --enable CONFIG_INET_DIAG
$KCFG --enable CONFIG_NETFILTER_ADVANCED
$KCFG --enable CONFIG_NET_RX_BUSY_POLL

# Performance de rede (XDP):
$KCFG --enable CONFIG_BPF
$KCFG --enable CONFIG_XDP_SOCKETS
$KCFG --enable CONFIG_NET_CLS_BPF


# ===============================
# HARDENING
# ===============================

$KCFG --enable CONFIG_STACKPROTECTOR_STRONG
$KCFG --enable CONFIG_RANDOMIZE_BASE
$KCFG --enable CONFIG_GCC_PLUGIN_LATENT_ENTROPY
$KCFG --enable CONFIG_FORTIFY_SOURCE
$KCFG --enable CONFIG_INIT_ON_ALLOC_DEFAULT_ON
$KCFG --enable CONFIG_INIT_ON_FREE_DEFAULT_ON
$KCFG --enable CONFIG_SECURITY
$KCFG --enable CONFIG_SECURITY_YAMA

# Desativar debug desnecessário
$KCFG --disable CONFIG_DEBUG_KERNEL
$KCFG --disable CONFIG_KGDB
$KCFG --disable CONFIG_KPROBES

# ===============================
# VIRTUALIZAÇÃO
# ===============================

$KCFG --enable CONFIG_VIRTIO
$KCFG --enable CONFIG_VIRTIO_NET
$KCFG --enable CONFIG_KVM_GUEST
$KCFG --enable CONFIG_PARAVIRT
$KCFG --enable CONFIG_HYPERV_NET

# ===============================
# DRIVERS DE REDE GENÉRICOS
# ===============================

$KCFG --enable CONFIG_NETDEVICES
$KCFG --enable CONFIG_ETHERNET

# Intel
$KCFG --enable CONFIG_E1000
$KCFG --enable CONFIG_E1000E
$KCFG --enable CONFIG_IGB
$KCFG --enable CONFIG_IXGBE

# Realtek
$KCFG --enable CONFIG_R8169

# VirtIO já habilitado acima

# ===============================
# SERIAL CONSOLE
# ===============================

$KCFG --enable CONFIG_SERIAL_8250
$KCFG --enable CONFIG_SERIAL_8250_CONSOLE
$KCFG --enable CONFIG_SERIAL_CORE
$KCFG --enable CONFIG_SERIAL_CORE_CONSOLE
$KCFG --enable CONFIG_EARLY_PRINTK




# ===============================
# REDUÇÃO DE SUPERFÍCIE DE ATAQUE
# ===============================

$KCFG --disable CONFIG_BT
$KCFG --disable CONFIG_WIRELESS
$KCFG --disable CONFIG_MAC80211
$KCFG --disable CONFIG_CFG80211
$KCFG --disable CONFIG_USB_STORAGE
$KCFG --disable CONFIG_FIREWIRE
$KCFG --disable CONFIG_MEDIA_SUPPORT
$KCFG --disable CONFIG_SOUND
$KCFG --disable CONFIG_INPUT_MOUSE

# kernel read-only após boot

$KCFG --enable CONFIG_STRICT_KERNEL_RWX
$KCFG --enable CONFIG_STRICT_MODULE_RWX



$KCFG --disable CONFIG_DRM
$KCFG --enable CONFIG_VT
$KCFG --enable CONFIG_VT_CONSOLE
$KCFG --enable CONFIG_TTY
$KCFG --enable CONFIG_VGA_CONSOLE
$KCFG --enable CONFIG_FRAMEBUFFER_CONSOLE
$KCFG --enable CONFIG_INPUT
$KCFG --enable CONFIG_KEYBOARD_ATKBD
$KCFG --enable CONFIG_SERIO
$KCFG --enable CONFIG_SERIO_I8042


$KCFG --enable CONFIG_SWITCH_ROOT
$KCFG --enable CONFIG_MOUNT
$KCFG --enable CONFIG_UMOUNT
$KCFG --enable CONFIG_ASH
$KCFG --enable CONFIG_FEATURE_SH_MATH
$KCFG --enable CONFIG_BLKID


$KCFG --enable CONFIG_DEVTMPFS
$KCFG --enable CONFIG_DEVTMPFS_MOUNT

############################################
# Finalização
############################################

make olddefconfig
make -j$(nproc)

cp arch/x86/boot/bzImage ../../build/

make modules_install INSTALL_MOD_PATH=../../initramfs
KREL=$(make kernelrelease)
depmod -b ../../initramfs $KREL

echo "Kernel Enterprise Firewall (sem Suricata) build concluído."