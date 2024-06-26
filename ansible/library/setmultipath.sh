#!/usr/bin/env bash

# Created by Chris

#firstwwid=$(multipath -ll | grep PURE | head -n 2 | tail -n 1 | cut -d " " -f 1)
#secondwwid=$(multipath -ll | grep PURE | head -n 1 | cut -d " " -f 1)

firstwwid=$(multipath -ll | grep -B1 250G | grep PURE | head -n 1 | awk '{print $1}')
secondwwid=$(multipath -ll | grep -B1 200G | grep PURE | head -n 1 | awk '{print $1}')

sed -i "s/firstwwid/${firstwwid}/g" /etc/multipath.conf
sed -i "s/secondwwid/${secondwwid}/g" /etc/multipath.conf
sed -i "s/uname-n/`uname -n | cut -d . -f 1`/g" /etc/multipath.conf

systemctl reload multipathd.service

#fdisk /dev/mapper/`uname -n | cut -d . -f 1`_vg01_mpath_pur01_2
echo "n
p
1


w
"|fdisk /dev/mapper/`uname -n | cut -d . -f 1`_vg01_mpath_pur01_2

sleep 2
mkfs.xfs /dev/mapper/`uname -n | cut -d . -f 1`_vg01_mpath_pur01_2p1

sleep 2
partprobe
vgcreate vg01 /dev/mapper/`uname -n | cut -d . -f 1`_vg01_mpath_pur01_2p1

lvcreate -l +100%FREE -n lvappdata vg01
mkfs.xfs /dev/mapper/vg01-lvappdata

echo "/dev/mapper/vg01-lvappdata /appdata xfs defaults 0 0" >> /etc/fstab
echo "/appdata/liquidnet /liquidnet none bind 0 0" >> /etc/fstab

mkdir /appdata
mount /appdata

mkdir /appdata/liquidnet

echo "Don't forget to add and run the iquidnet Ansible role to Complete the buiild"
