#!/bin/sh

# Created by Matheo Lord-Martinez on 9/2/20
# matheo.cc
# This script deletes/disable/archive one or multiple user accounts in the system
# To debug -xfv at the top
# To unzip use tar -ztvf /archive/username


ARCHIVE_DIR='/archive'

usage(){
	#Display usage and exit
	echo "Usage: ${0} [-dra] USER [USERN]..." >&2
	echo "Disable a local Linux account." >&2
	echo "-d Deletes accounts instead of disabling them." >&2
	echo "-r Removes the home directory associated with the account(s)." >&2
	echo "-a Creates an archive of the home directory associated with the account(s)." >&2
	exit 1
}

# Make sure the script is being run with SU privileges
if [[ "${UID}" -ne 0 ]]
then
	echo "Permission denied. Please run as root" >&2
	exit 1
fi

# Parse the options
while getopts dra OPTION
do
	case ${OPTION} in
		d) DELETE_USER='true' ;;
		r) REMOVE_OPTION='-r' ;;
		a) ARCHIVE='true' ;;
		?) usage ;;
	esac
done

# Removes the options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

# If the user doesn't supply at least one argument, provide help
if [[ "${#}" -lt 1 ]]
then
	usage
fi

# Loop through all the usernames supplied as arguments
for USERNAME in "${@}"
do
	echo "Processing user: ${USERNAME}"

	# Make sure the UID of the account is greater than 1000
	USERID=$(id -u ${USERNAME})
	if [[ "$USERID" -lt 1000 ]]
	then
		echo "Permission denied. Cannot remove the ${USERNAME} account with UID ${USERID} or the account does not exist." >&2
		exit 1
	fi

	# Create an archive if required
	if [[ "${ARCHIVE}" = 'true' ]]
	then
		#Make sure the ARCHIVE_DIR exists
		if [[ ! -d "${ARCHIVE_DIR}" ]]
		then
			echo "Creating ${ARCHIVE_DIR} directory"
			mkdir -p ${ARCHIVE_DIR}
			if [[ "${?}" -ne 0 ]]
			then
				echo "The archive directory ${ARCHIVE_DIR} could not be created." >&2
				exit 1
			fi
		fi

		# Archive the user's home into the ARCHIVE_DIR
		HOME_DIR="/home/${USERNAME}"
		ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
		if [[ -d "${HOME_DIR}" ]]
		then
			echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
			tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
			if [[ "${?}" -ne 0 ]]
			then
				echo "Could not create ${ARCHIVE_FILE}" >&2
				exit 1
			fi
		else
			echo "${HOME_DIR} does not exist or is not a directory." >&2
			exit 1
		fi
	fi

	if [[ "${DELETE_USER}" = 'true' ]]
	then
		# Delete user
		userdel ${REMOVE_OPTION} ${USERNAME}
		#Check if the userdel command succeeded
		if [[ "${?}" -ne 0 ]]
		then
			echo "The account ${USERNAME} was NOT deleted." >&2
			exit 1
		fi
		echo "The account ${USERNAME} was deleted."
	else
		chage -E 0 ${USERNAME}
		# Check to see if the chage (disable) command succeeded
		if [[ "${?}" -ne 0 ]]
		then
			echo "The account ${USERNAME} was NOT disabled." >&2
			exit 1
		fi
		echo "The account ${USERNAME} was disabled."
	fi
done

exit 0
