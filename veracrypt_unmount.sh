#!/bin/bash

###############################################################
# Script that try to unmount an encrypted Veracrypt partition #
###############################################################

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
	msg "Error - Unable to find the file $script_folder/veracrypt_config"
	exit 1
fi

# Make sure that we have found the variables that veracrypt will need
if [[ "$encrypted_partition" == "" || "$mounting_point" == "" ]]; then
	msg "Error - The values of encrypted_partition ($encrypted_partition) and/or mounting_point ($mounting_point) does not seems to be valid"
	exit 1
fi

# Check if the mounting point is mounted or not
if [[ ! $( lsblk "$encrypted_partition" | grep "veracrypt" | grep "$mounting_point" ) ]]; then
	msg "OK - The encrypted partition $encrypted_partition is already unmounted from the mounting point $mounting_point"
	exit 0
fi

# Check if there are some open files in use
if [[ $( lsof | grep "$mounting_point" ) != "" ]]; then
	msg "Warning - It seems that some files are still in use in the folder $mounting_point. Please close them before unmounting."
	exit 1
fi

# Try to unmount the encrypted partition from the mounting point
veracrypt -d "$mounting_point"
errorlevel=$?

# Verify the result
if [[ $errorlevel -ne 0 ]]; then
	msg "Error - Unable to properly unmount the encrypted partition $encrypted_partition from the mounting point $mounting_point (errorlevel: $errorlevel)"
	exit 1
else
	msg "OK - Successfully unmounted the encrypted partition $encrypted_partition from the mounting point $mounting_point"
fi
