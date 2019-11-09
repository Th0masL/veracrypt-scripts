# veracrypt-scripts

This repository contains couple of CLI scripts to make the usage of Veracrypt more easy.

The main idea is to use Veracrypt to secure our data by encrypting a partition on a cloud-hosted server that does not provide full disk encryption.

Those scripts require veracrypt to be installed (see below to install it and create/encrypt the partition).

## To install veracrypt using the command line

### 1) Go to https://www.veracrypt.fr/en/Downloads.html and copy the link of the Linux Generic Installer
i.e.: https://launchpad.net/veracrypt/trunk/1.24-hotfix1/+download/veracrypt-1.24-Hotfix1-setup.tar.bz2

### 2) Download this file to the /tmp folder
`wget <URL> -P /tmp`

### 3) Decompress this file
```
mkdir /tmp/veracrypt
cd /tmp/veracrypt
tar xjpf ../veracrypt-1.24-Hotfix1-setup.tar.bz2
```

### 4) Make the extracted files executable
`chmod +x /tmp/veracrypt/*`

### 5) Run the console installer and follow the instructions to install it
`/tmp/veracrypt/veracrypt-1.24-setup-console-x64`

### 6) Copy/download the files/scripts from this GIT repository to a local folder on your server
```
mkdir /veracrypt-scripts
cd /veracrypt-scripts
git clone git@github.com:Th0masL/veracrypt-scripts.git
chmod +x /veracrypt-scripts/*.sh
```

## Create a new partition on one of the disks and encrypt it with Veracrypt
**WARNING : Only do that on an empty partition! This step will erase the data of the partition that you plan to use.**

### 1) Use fdisk to create the new partition
In this example, I have some empty space on the disk /dev/sda, so I'll use this disk to create a new ext4 partition that will be used by Veracrypt.

```
fdisk /dev/sda
  -> type 'n' to create the new partition (And then answers the questions. In my case, I've created an ext4 partition.)
  -> type 'w' to write the changes to the partition table and create the partition
  -> type 'q' to exit fdisk
```

### 2) Use mfs to format the partition to ext4
In this example, the new partition that I have created earlier has the number 3, so it's going to be /dev/sda3.

`mkfs -t ext4 /dev/sda3`

### Encrypt this new partition with veracrypt
`veracrypt -t --quick -c /dev/sda3`
The options I'm using here are to tell Veracrypt that I only want to use a password to protect the encrypted partition.
There are other ways to protect the partition, but a password is enough for what I need.

## Useful links
- [Install Veracrypt on Ubuntu 18.04](https://www.osradar.com/install-veracrypt-on-ubuntu-18-04/)
- [Encrypt Device with Veracrypt](https://relentlesscoding.com/2019/01/06/encrypt-device-with-veracrypt-from-the-command-line/)


