#!/bin/bash

#################################################################################
# Script that verify that an encrypted Veracrypt partition is currently mounted #
#################################################################################

# Define if we want to send telegram alerts when there are problems
send_telegram_alert=1

# Detect the folder of this script
script_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the script name
script_name=$( basename "$0" )

# Declare the function that print and log a msg
function msg () {
	echo "$1"
	logger "$script_name - $1"
	# In case of error, try to send a Telegram message
	if [[ $( echo "$1" | grep -i "^ERROR" ) && $send_telegram_alert -eq 1 ]]; then
		# Check if the Telegram script exist
		if [[ -f "/scripts/telegram_send_message.sh" && -x "/scripts/telegram_send_message.sh" ]]; then
			# If the script exist, send the message
			/scripts/telegram_send_message.sh --message "$script_name - $1"
		fi
	fi
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

# Check if it's mounted or not
if [[ $( lsblk "$encrypted_partition" 2>/dev/null | grep "veracrypt" | grep "$mounting_point" ) ]]; then
	msg "OK - The encrypted partition $encrypted_partition is currently mounted to the mounting point $mounting_point."
else
	msg "ERROR - The encrypted partition $encrypted_partition is currently NOT mounted to the mounting point $mounting_point."
	exit 1
fi
