#!/bin/bash

#############################################################
# Script that try to mount an encrypted Veracrypt partition #
#############################################################

# Detect the folder of this script
script_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the name of this script
script_name=$( basename "$0" )

# Declare the function that print and log a msg
function msg () {
	echo "$1"
	logger "$script_name - $1"
}

# Load the variables that we will use for Veracrypt
if [[ -f "$script_folder/veracrypt_config" ]]; then
	source "$script_folder/veracrypt_config"
else
	msg "ERROR - Unable to find the file $script_folder/veracrypt_config"
	exit 1
fi

# Make sure that we have found the variables that veracrypt will need
if [[ "$encrypted_partition" == "" || "$mounting_point" == "" ]]; then
	msg "ERROR - The values of encrypted_partition ($encrypted_partition) and/or mounting_point ($mounting_point) does not seems to be valid"
	exit 1
fi

# First, make sure that we can see the encrypted partition
if [[ ! $( fdisk -l | grep "$encrypted_partition" ) ]]; then
	msg "ERROR - Unable to find the partition $encrypted_partition. If this parition is on an external disk, please verify that the disk is connected."
	exit 1
fi

# Then check if the partition is already mounted or not
# And it's not yet mounted in Veracrypt, run Veracrypt to mount it
if [[ $( lsblk "$encrypted_partition" | grep "veracrypt" | grep "$mounting_point" ) ]]; then
	msg "INFO - The encrypted partition $encrypted_partition is already mounted to $mounting_point"
else
	# Make sure that if the mounting point folder exists, it's empty
	if [[ -d "$mounting_point" && $( ls "$mounting_point" ) != "" ]]; then
		msg "ERROR - The mounting point $mounting_point does not seems to be empty. Please verify the content of this folder."
		exit 1
	fi

	# If the mounting point does not exist, create it
	if [[ ! -d "$mounting_point" ]]; then
		msg "INFO - Creating the mounting point folder $mounting_point ..."
		mkdir "$mounting_point"
	fi

	# Try to mount the partition
	msg "INFO - Mounting the encrypted partition $encrypted_partition to the mounting point $mounting_point ..."
	veracrypt -t -k "" --pim=0 --protect-hidden=no "$encrypted_partition" "$mounting_point"
	errorlevel=$?

	# Verify the exit value of the veracrypt command
	if [[ $errorlevel -ne 0 ]]; then
		msg "ERROR - The veracrypt command returned an error (errorlevel: $errorlevel)"
		exit 1
	fi

	# Check if the encrypted partition has been successfully mounted or not
	if [[ $( lsblk "$encrypted_partition" | grep "veracrypt" | grep "$mounting_point" ) ]]; then
		msg "OK - The encrypted partition $encrypted_partition has been mounted to the mounting point $mounting_point"
	else
		msg "ERROR - Unable to mount the encrypted partition $encrypted_partition to the mounting point $mouting_point"
		exit 1
	fi
fi
