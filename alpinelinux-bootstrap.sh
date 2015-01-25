#!/bin/sh
 
set -e
 
KEYMAP="${KEYMAP:-'us us'}"
HOST=${HOST:-alpine-linux}
INTERFACES="auto lo
iface lo inet loopback
 
auto eth0
iface eth0 inet dhcp
  hostname $HOST
"
BOOT_FS=${ROOT_FS:-ext4}
ROOT_FS=${ROOT_FS:-ext4}

FEATURES="ata ide base $ROOT_FS"
MODULES="$ROOT_FS"

REL=${REL:-3.1}
MIRROR=${MIRROR:-http://nl.alpinelinux.org/alpine}
REPO=$MIRROR/v$REL/main
APKV=${APKV:-2.5.0_rc1-r0}
BOOT_DEV=${ROOT_DEV:-/dev/xvda}
ROOT_DEV=${ROOT_DEV:-/dev/xvdb}
ROOT=${ROOT:-/mnt}
ARCH=$(uname -m)
 
mkfs.$BOOT_FS -L boot $BOOT_DEV
mkfs.$ROOT_FS -L root $ROOT_DEV
mount $ROOT_DEV $ROOT
mkdir $ROOT/boot
mount $BOOT_DEV $ROOT/boot
 
curl -s $MIRROR/v$REL/main/$ARCH/apk-tools-static-${APKV}.apk | tar xz
./sbin/apk.static --repository $REPO --update-cache --allow-untrusted \
  --root $ROOT --initdb add alpine-base
 
cat <<EOF > $ROOT/etc/fstab
$ROOT_DEV / $ROOT_FS defaults,noatime 0 0
$BOOT_DEV /boot $BOOT_FS defaults,noatime 0 1
EOF
echo $REPO > $ROOT/etc/apk/repositories
 
sed -i '/^tty[0-9]:/d' $ROOT/etc/inittab
echo 'hvc0::respawn:/sbin/getty 38400 hvc0' >> $ROOT/etc/inittab
 
mkdir -p $ROOT/boot/grub
cat << EOF > $ROOT/boot/grub/menu.lst
timeout 0
default 0
hiddenmenu
 
title Alpine Linux
root (hd0)
kernel /boot/vmlinuz-grsec root=/dev/xvdb modules=sd-mod,usb-storage,ext4 console=hvc0 quiet
initrd /boot/initramfs-grsec
EOF
 
cp /etc/resolv.conf $ROOT/etc
 
mount --bind /proc $ROOT/proc
 
chroot $ROOT /bin/sh<<CHROOT
apk update --quiet 
 
setup-hostname -n $HOST
printf "$INTERFACES" | setup-interfaces -i
 
rc-update -q add urandom boot
rc-update -q add cron
 
apk add --quiet openssh
rc-update -q add sshd default

mkdir /etc/mkinitfs
echo features=\""$FEATURES"\" > /etc/mkinitfs/mkinitfs.conf

apk add --quiet linux-grsec
 
CHROOT
 
umount $ROOT/proc
umount $ROOT/boot
umount $ROOT

