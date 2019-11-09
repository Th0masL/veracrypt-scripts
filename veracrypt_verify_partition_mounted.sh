#!/bin/bash

#################################################################################
# Script that verify that an encrypted Veracrypt partition is currently mounted #
#################################################################################

# Detect the folder of this script
script_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the script name
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

# Check if it's mounted or not
if [[ $( lsblk "$encrypted_partition" | grep "veracrypt" | grep "$mounting_point" ) ]]; then
	msg "OK - The encrypted partition $encrypted_partition is currently mounted to the mounting point $mounting_point."
else
	msg "Error - The encrypted partition $encrypted_partition is currently NOT mounted to the mounting point $mounting_point."
	exit 1
fi
