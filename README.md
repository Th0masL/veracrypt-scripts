# veracrypt-scripts

This repository contains couple of CLI scripts to make the usage of Veracrypt more easy.

The main idea is to use Veracrypt to secure our data by encrypting a partition on a cloud-hosted server that does not provide full disk encryption.

Those scripts require veracrypt to be installed.

## To install veracrypt using the command line

### 1) Go to https://www.veracrypt.fr/en/Downloads.html and copy the link of the Linux Generic Installer
 i.e.: https://launchpad.net/veracrypt/trunk/1.24-hotfix1/+download/veracrypt-1.24-Hotfix1-setup.tar.bz2

### 2) Download this file to the /tmp folder
 wget <URL> -P /tmp

### 3) Decompress this file
 mkdir /tmp/veracrypt
 cd /tmp/veracrypt
 tar xjpf ../veracrypt-1.24-Hotfix1-setup.tar.bz2

### 4) Make the extracted files executable
 chmod +x /tmp/veracrypt/*

### 5) Run the console installer
 /tmp/veracrypt/veracrypt-1.24-setup-console-x64

### 6) Follow the instructions to install it


## To initialize/create the encrypted partition
WARNING : Only do that on an empty partition! This erase the data of the partition that you plan to use.

### Use fdisk to create the partition (in this example, we want to add a partition on the disk /dev/sda)
fdisk /dev/sda
  > type 'n' to create the new partition (answers the questions)
  > type 'w' to write the changes to the partition table and create the partition

### To format the partition to ext4 (in this example, my new partition has the number 3)
mkfs -t ext4 /dev/sda3

### Tell veracrypt to convert this new partition to an encrypted partition
veracrypt -t --quick -c /dev/sda3

## Useful links
https://www.osradar.com/install-veracrypt-on-ubuntu-18-04/
https://relentlesscoding.com/2019/01/06/encrypt-device-with-veracrypt-from-the-command-line/


