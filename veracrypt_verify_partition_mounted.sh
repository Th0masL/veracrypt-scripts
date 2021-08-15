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

# Get the hostname of this machine
server_name=$( hostname )

# Function that returns the primary IP Address of this server
function what_is_my_ip() {
	# Use OpenDNS resolver to get my public IP
	public=$( dig +short myip.opendns.com @resolver1.opendns.com | grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" | head -1 )

	# Do a basic 'ip route get' query against Google DNS to detect what is the default outgoing IP
	default=$( ip route get 8.8.8.8 2>/dev/null | grep -E " src [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sed -e "s|.* src ||g" | awk '{print $1}' | head -1 )

	# Return only what we want
	if [[ "$1" == "public" ]]; then
		echo "$public"
	elif [[ "$1" == "default" ]]; then
		echo "$default"
	else
		# If both IPs are th same, return only one
		if [[ "$public" == "$default" ]]; then
			echo "$default"
		else
			echo "$public - $default"
		fi
	fi
}

# Declare the function that print and log a msg
function msg () {
	echo "$*"
	logger "$script_name - $*"
	# In case of error, try to send a Telegram message
	if [[ $( echo "$1" | grep -E "^ERROR" ) && $send_telegram_alert -eq 1 ]]; then
		# Check if the Telegram script exist
		if [[ -f "/scripts/telegram_send_message.sh" && -x "/scripts/telegram_send_message.sh" ]]; then
			# Get the server's IPs
			server_all_ips=$( what_is_my_ip "all" )

			# If the script exist, send the message
			/scripts/telegram_send_message.sh --message "$server_name ($server_all_ips) - $script_name - $*"
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

# First, make sure that we can see the encrypted partition (for some reason, requires sudo when running in cronjob)
if [[ -z $( sudo fdisk -l | grep "^/dev" | grep "$encrypted_partition" ) ]]; then
	msg "ERROR - Unable to find the partition $encrypted_partition. If this parition is on an external disk, please verify that the disk is connected."
	exit 1
fi

# If the partition exist, check if it's already mounted or not
if [[ $( lsblk "$encrypted_partition" 2>/dev/null | grep "veracrypt" | grep "$mounting_point" ) ]]; then
	msg "OK - The encrypted partition $encrypted_partition is currently mounted to the mounting point $mounting_point."
else
	msg "ERROR - The encrypted partition $encrypted_partition is currently NOT mounted to the mounting point $mounting_point."
	exit 1
fi
