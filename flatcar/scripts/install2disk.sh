#!/bin/bash
set -e -x

sudo flatcar-install -d /dev/sda -f ~/flatcar_production_image.bin.bz2 -i ignition.json
#  
# -c cloud-init

# Copy on files
sudo mount /dev/sda9 /mnt
sudo mkdir /mnt/home/core/install
sudo mv ~/powershell.tar.gz /mnt/home/core/install
sudo mv ~/installpowershell.sh /mnt/home/core/install
sudo mv ~/seqcli.tar.gz /mnt/home/core/install
sudo mv ~/installseq.sh /mnt/home/core/install
cd /mnt

# chroot
# /mnt/usr/share 
sudo mkdir /mnt/usr/bin /mnt/usr/sbin /mnt/usr/share /mnt/usr/lib64
sudo mount -o bind /bin /mnt/usr/bin
sudo mount -o bind /sbin /mnt/usr/sbin
sudo mount -o bind /usr/lib64 /mnt/usr/lib64
sudo mount -o bind /usr/share /mnt/usr/share

# Copy over bashrc
sudo rm /mnt/home/core/.bashrc
sudo cp /usr/share/skel/.bashrc /mnt/home/core

sudo chroot /mnt /bin/bash -c "/home/core/install/installpowershell.sh"
sudo chroot /mnt /bin/bash -c "/home/core/install/installseq.sh"

shutdown now -h
