# Alpine Linux on Linode

It's easy and very awesome to run Alpine Linux on Linode.

## Scripts

### alpinelinux-bootstrap.sh

This script is taken from http://uggedal.com/journal/alpine-linux-on-linode/ and updated to work with Alpine Linux 3.1.

It bootstraps an Alpine Linux installation on your Linode. You need to create a Linode with two disks. One for boot (128 MB is way enough) and one for the root filesystem (all remaining space). Create a new configuration profile using the new disk images, pv-grub-x86_64 kernel and no Filesystem/Boot helpers.

Boot into rescue mode and execute the script. Reboot into normal mode, set a root password and have fun.

