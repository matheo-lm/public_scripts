#!/bin/sh

###################################################################################
# Created by Matheo Lord-Martinez on 7/20/20									  #
#																				  #
# This script creates a new user on the local system                              #
# You will be prompted to enter username (login), the person name, and a password #
# The username, password, and host for the account will be displayed              #
#																				  #
###################################################################################


# Make sure the script is being executed with SU privileges
if [[ "${UID}" -ne 0 ]]
then
	echo "Please run with sudo or as root"
	exit
fi

# Get the username (login)
read -p 'Enter the username to create (Login): ' USER_NAME

# Get the real name (Description filed).
read -p 'Enter the name of the person or application: ' COMMENT


# Get the password
read -p 'Enter the password to use on this account: ' PASSWORD

# Create account
useradd -c "${COMMENT}" -m ${USER_NAME}

# Check to see if the useradd command succeeded

if [[ "${?}" -ne 0 ]]
then
	echo 'The account was not created'
	exit 1
fi

# Set password
echo ${PASSWORD} | passwd --stdin ${USER_NAME}

if [[ "${?}" -ne 0 ]]
then 
	echo 'The password for the account could not be set'
	exit 1
fi

#Force password change on first login
passwd -e ${USER_NAME}

# Display the username, password, and host
echo 
echo 'username:'
echo "${USER_NAME}"
echo 'password:'
echo "${PASSWORD}"
echo 'host'
echo "${HOSTNAME}"
exit 0




