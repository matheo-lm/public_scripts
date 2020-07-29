#!/bin/sh

################################################################################
# Created by Matheo Lord-Martinez on 7/29/20								   #
# 																			   #	
# This script will create a new user account on the local system.              #
# You need to provide a username as an argument to this program.               #
# In addition, you might add a comment as an argument.						   #
# This program will automatically generate a password.    					   #
# Once the program has executed, it will display username, password and host   #
#																			   #
################################################################################


#Enforce the execution as root, if not exit 1.
if [[ "${UID}" -ne 0 ]]
then
	echo "Please run with sudo or as root." >&2
	exit 1
fi


# If the user did not provide at least one argument, show help.
if [[ "${#}" -lt 1 ]]
then
	echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
	echo "Create the account on the local system using USER_NAME and a COMMENT" >&2
	exit 1
fi


# The first parament is the user name
USER_NAME="${1}"


# Everything else is interpreted as account comments
shift
COMMENT="${@}"


# Generate a password
PASSWORD=$(date +%s%N | sha256sum | head -c15)


# Create the user account with password
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null


# Check if password command succeedd
if [[ "${?}" -ne 0  ]]
then
	echo "The account could not be created :(" >&2
	exit 1
fi


# Set the password
echo ${PASSWORD} | passwd --stdin ${USER_NAME} &> /dev/null


# Check if password command succeedd
if [[ "${?}" -ne 0  ]]
then
	echo "The password for the account could not be set" >&2
	exit 1
fi

# Force password change on first login
passwd -e {USER_NAME} &> /dev/null


# Display the username, password, and host
echo
echo 'Username: '
echo "${USER_NAME}"
echo
echo 'Password: '
echo "${PASSWORD}"
echo
echo 'Host: '
echo "${HOSTNAME}"
exit 0

