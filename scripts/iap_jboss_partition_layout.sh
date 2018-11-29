#!/bin/bash
DEVICE=$1
DEVICE_PARTITION="$DEVICE""1"

echo -e "\nMaking device partitions\n"
parted $DEVICE mklabel msdos
parted $DEVICE mkpart primary 0% 100%
parted $DEVICE toggle 1 lvm
echo -e "\nPartitions created on $DEVICE \n"

echo -e "\nDoing LVM layout\n"
pvcreate $DEVICE_PARTITION
vgcreate app $DEVICE_PARTITION
echo -e "\nLVM Layout craeted\n"

echo -e "\nCreating Logical Volumes\n"
lvcreate -L 6G -n "log" app
mkfs.ext4 /dev/mapper/app-log
lvcreate -L 3G -n "standalone" app
mkfs.ext4 /dev/mapper/app-standalone
lvcreate -l 100%FREE -n "app" app
mkfs.ext4 /dev/mapper/app-app
echo -e "\nLogical Volumes Created\n"

echo "Mounting Partitions"
mkdir -p /opt/jboss
mount /dev/mapper/app-app /opt/jboss

mkdir -p /opt/jboss/standalone
mount /dev/mapper/app-standalone /opt/jboss/standalone

mkdir -p /opt/jboss/standalone/log
mount /dev/mapper/app-log /opt/jboss/standalone/log
echo -e "\nPartitions mounted\n"

cat <<EOF >> /etc/fstab
#IAP JBoss Partitions
/dev/mapper/app-app /opt/jboss ext4 defaults 0 0
/dev/mapper/app-bin /opt/jboss/bin ext4 defaults 0 0
/dev/mapper/app-standalone /opt/jboss/standalone ext4 defaults 0 0
/dev/mapper/app-log /opt/jboss/standalone/log ext4 defaults 0 0
EOF


