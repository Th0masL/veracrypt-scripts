# veracrypt-scripts

This repository contains couple of CLI scripts to make the usage of Veracrypt more easy.

The main idea is to use Veracrypt to secure our data on server that cannot use full disk encryption.

The goal is to use some empty space on one of the disks to create a encrypted partition, and mount it on a specific mounting point (i.e: /data).

All the data that is saved in the folder /data will only be accessible once an user that can login on the Linux server has mounted the partition with Veracrypt.

It's also possible to put your websites and other services' data on this encrypted partition.

I my case, I was facing a problem if I would be using full-disk encryption, because my server would not be able to boot, and would require me to physically type the password before loading the operating system.

But with the method provided with this encrypted Veracrypt partition, my server can restart by itself. The only thing I have to do is to SSH to my server after it has booted, and mount the encrypted partition.

Those scripts require veracrypt to be installed (see below to install it and create/encrypt the partition).

## Install Veracrypt using the command line

### 1) Get the latest Linux Generic Installer file
Go to [Veracrypt Download Page](https://www.veracrypt.fr/en/Downloads.html) and copy the link of the **Linux Generic Installer**

Example: https://launchpad.net/veracrypt/trunk/1.24-hotfix1/+download/veracrypt-1.24-Hotfix1-setup.tar.bz2

### 2) Download and decompress this file
```
wget <INSTALLER_URL> -P /tmp # Download the file
mkdir /tmp/veracrypt # Create a folder that will contain the decompressed files
cd /tmp/veracrypt # Go to this new folder
tar xjpf ../veracrypt-1.24-Hotfix1-setup.tar.bz2 # Decompress the files in this folder
chmod +x /tmp/veracrypt/* # Make the extracted files executable
```

### 3) Run the console installer and follow the instructions to install it
`/tmp/veracrypt/veracrypt-1.24-setup-console-x64`

### 4) Copy/download the files/scripts from this GIT repository to a local folder on your server
```
mkdir /veracrypt-scripts
cd /veracrypt-scripts
git clone git@github.com:Th0masL/veracrypt-scripts.git .
chmod +x /veracrypt-scripts/*.sh
```

## Create a new partition and encrypt it with Veracrypt
**WARNING : Only do that on an empty partition! This step will erase the data of the partition that you plan to use.**

### 1) Use fdisk to create the new partition
In this example, I have some empty space on the disk /dev/sda, so I'll use this disk to create a new ext4 partition that will be used by Veracrypt.

```
fdisk /dev/sda
  -> type 'n' to create the new partition (And then answers the questions. In my case, I've created an ext4 partition.)
  -> type 'w' to write the changes to the partition table and create the partition
  -> type 'q' to exit fdisk
```

### 2) Use mkfs to format the partition to ext4
In this example, the new partition that I have created earlier has the number 3, so it's going to be /dev/sda3.

`mkfs -t ext4 /dev/sda3`

### Encrypt this new partition with veracrypt
`veracrypt -t --quick -c /dev/sda3`

The options I'm using here are telling Veracrypt that I only want to use a password to protect the encrypted partition.

There are other ways to protect the partition, but a password is enough for what I need.

Note: For some reasons there's currently a bug with Veracrypt, where it cannot create an ext4 encrypted partitions on big disks (I tried with a 2TB disk). To bypass this bug, if possible, you can either connect your disk on Windows/MacOS and create there using Veracrypt (it will then be compatible on Linux), or use ext3 instead of ext4.

## How to protect some services' data

One thing I wanted to do, is to protect the data of the services I'm using (nginx/docker/nextcloud/...), so here is the method to be able to do it.

In my case, my encrypted partion is mounted in the path `/data`

### 1) Create a folder for your application's data on your encrypted partition
```
mkdir /data/nginx # For my websites served by nginx
mkdir /data/docker # For Docker
mkdir /data/nextcloud # For Nextcloud
```
### 2) Configure those data path in your services

In each service, configure this path as the path where to store the data.

### 3) Prevent the services to start if their data folders are not reachable
One thing you want to do is to prevent the services to be able to start if the encrypted partition has not been mounted first.

Let's assume you are using SYSTEMD as service manager.

Edit your service's systemd file, and add the directive `ConditionPathExists=<path>` to the section `[Unit]`.

Overview of the nginx SYSTEMD file after edit `/lib/systemd/system/nginx.service` :
```
[Unit]
<... other lines ...>
ConditionPathExists=/data/nginx

[Service]
<... other lines ...>
```

Then you reload systemd daemon `systemctl daemon-reload`.

From now on, NGINX will only start if you have mounted the encrypted partition first.

If you try to start NGINX without having mounted the encrypted partition first, you will get a nice error message.

```
root@server:/scripts# service nginx start
root@server:/scripts# service nginx status
● nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: inactive (dead) since Sat 2019-11-09 20:40:29 UTC; 20s ago
Condition: start condition failed at Sat 2019-11-09 20:40:47 UTC; 1s ago
           └─ ConditionPathExists=/data/nginx was not met
```

Another solution would be to use the option `ExecStartPre` under `[Service]`, with the value `/usr/bin/test -d /data/myfolder` or `/usr/bin/test -f /data/myfile`.

Example :

```
# /lib/systemd/system/docker.service

[Service]
ExecStartPre=/usr/bin/test -f /data/mounted
```

## Useful links
- [Install Veracrypt on Ubuntu 18.04](https://www.osradar.com/install-veracrypt-on-ubuntu-18-04/)
- [Encrypt Device with Veracrypt](https://relentlesscoding.com/2019/01/06/encrypt-device-with-veracrypt-from-the-command-line/)


