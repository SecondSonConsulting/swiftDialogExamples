#!/bin/zsh
#set -x

##Written by Trevor Sysock
##aka @BigMacAdmin on Slack

##version 1.1

##This script is meant as an example of how to use <<< Here Doc 
##shell feature to create JSON files that contain Dialog options

## ATTENTION: This script requires SwiftDialog v2.1 or newer, due to changes made related to this issue:
# https://github.com/bartreardon/swiftDialog/issues/207

##It also contains an example of how to process output and take action
##based on the users selections without python

#Define dialog path for convenience
dialogPath=/usr/local/bin/dialog

#Create a tmp file to hold our dialog options
tmpDialogFile1=$(mktemp /tmp/tmpDialogFile1.XXXXXX)

#Set permissions on temp files. 
#This is necessary if the script is running as root, since dialog always runs "asuser" if using /usr/local/bin/dialog
chmod 644 "$tmpDialogFile1"
chmod 644 "$tmpDialogFile2"

#Function to delete our tmp files and exit with a given exit code
cleanup_and_exit ()
{
rm /tmp/tmpDialogFile*
exit "$@"
}

##Create the content of our first JSON file
#https://github.com/bartreardon/swiftDialog/wiki/Using-JSON-to-specify-Dialog-options
cat > "$tmpDialogFile1" <<ADDTEXT
{
	"icon" : "SF=bolt.circle color1=pink color2=blue",
	"title" : "Your Title Here",
	"message" : "What would you like to do?",
	"button2text" : "Cancel",
	"checkbox" : [
		{"label" : "Option A" },
		{"label" : "Option B" },
		{"label" : "Option C" },
		{"label" : "Option D", "checked" : true }
		]
}
ADDTEXT

#This calls dialog with the options from the json
dialogResponseFull1=$("$dialogPath" --jsonfile "$tmpDialogFile1")

#Capture the exit code of the dialog command.
dialogExit=$?

#If it did not exit with 0, then exit this script with the same exit code.
if [ "$dialogExit" != 0 ]; then
	cleanup_and_exit "$dialogExit"
fi

#Filter output response options that were not selected. This isn't strictly necessary in this example script.
dialogResponse1=$(echo "$dialogResponseFull1" | grep -v ": false")

#Now we check if our dialog output contains each of our options. We will need one "if/then" statement for each checkbox option you
#provided the user.
#grep -q exits with success (0) if the string is found, and failure (1) if it is not.
#We will use an if/then statement to determine whether a response was included.

#The output of SwiftDialog checkbox command requires specific quoting for the following to work properly. The
#entire string needs to be included in single quotes, since SwiftDialog outputs values in double quotes.

if $(echo "$dialogResponse1" | grep -q '"Option A" : "true"'); then
	#Do the things you want to do for Option A
	echo "User chose Option A"
fi
if $(echo "$dialogResponse1" | grep -q '"Option B" : "true"'); then
	#Do the things you want to do for Option B
	echo "User chose Option B"
fi
if $(echo "$dialogResponse1" | grep -q '"Option C" : "true"'); then
	#Do the things you want to do for Option C
	echo "User chose Option C"
fi
if $(echo "$dialogResponse1" | grep -q '"Option D" : "true"'); then
	#Do the things you want to do for Option D
	echo "User chose Option D"
fi

#Exit the script, deleting any tmp files.
cleanup_and_exit 0
