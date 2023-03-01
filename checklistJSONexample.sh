#!/bin/zsh
#set -x

##Written by Trevor Sysock
##aka @BigMacAdmin on Slack

##version 1.0

##This script is meant as an example of how to use <<< Here Doc 
##shell feature to create JSON files that contain Dialog options

##This script requires SwiftDialog v2.1 or newer, due to changes made related to this issue:
# https://github.com/bartreardon/swiftDialog/issues/207

##It also contains an example of how to process output and take action
##based on the users selections without python

##In this example, Option D is selected by default and if it is chosen
##then a second dialog window is presented with additional options
##If the user Cancels or Quits either dialog window then the script exits with the exit code of that dialog window

#Define dialog path for convenience
dialogPath=/usr/local/bin/dialog

#Create a tmp file to hold our dialog options
tmpDialogFile1=$(mktemp /tmp/tmpDialogFile1.XXXXXX)
tmpDialogFile2=$(mktemp /tmp/tmpDialogFile2.XXXXXX)

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

##Create the content of our second JSON file
#https://github.com/bartreardon/swiftDialog/wiki/Using-JSON-to-specify-Dialog-options
cat > "$tmpDialogFile2" <<ADDTEXT
{
	"icon" : "SF=bolt.circle color1=blue color2=pink",
	"title" : "Your Title Here",
	"message" : "How would you like to do it?",
	"button2text" : "Cancel",
	"checkbox" : [
		{"label" : "Option 1" },
		{"label" : "Option 2" },
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

#This processes the response. grep -q makes the command exit 0 for yes or 1 for no if the string is found
#The && means "process the next command only if the previous command exited 0
#You can use || instead to "process the next command only if the previous command exited 1
#You can combine both into an if/then statement (Shown here for Option D)

echo "$dialogResponse1" | grep -q '"Option A" : "true"' && { echo "User chose Option A." ; optionA="Y" ; }
echo "$dialogResponse1" | grep -q '"Option B" : "true"' && { echo "User chose Option B." ; optionB="Y" ; }
echo "$dialogResponse1" | grep -q '"Option C" : "true"' && { echo "User chose Option C." ; optionC="Y" ; }
echo "$dialogResponse1" | grep -q '"Option D" : "true"' && { echo "User chose Option D." ; optionD="Y" ; } || echo "User did not choose Option D."

#If you don't want to echo the result to standard out, you can drop the brackets and semi-colons like this instead:
#echo "$dialogResponse1" | grep -q '"Option A" : "true"' && optionA="Y"
#echo "$dialogResponse1" | grep -q '"Option B" : "true"' && optionB="Y"
#echo "$dialogResponse1" | grep -q '"Option C" : "true"' && optionC="Y"
#echo "$dialogResponse1" | grep -q '"Option D" : "true"' && optionD="Y"

#Sometimes you just want to take a nap
sleep .5

#If option D is selected from the first dialog, present another window for Option 1 and Option 2
if [ "$optionD" = "Y" ]; then
	
	#This calls dialog with the options from the json, and removes filters output based on what was selected.
	dialogResponseFull2=$("$dialogPath" --jsonfile "$tmpDialogFile2")
	
	#Capture the exit code of the dialog command.
	dialogExit=$?

	#If it did not exit with 0, then exit this script with the same exit code.
	if [ "$dialogExit" != 0 ]; then
		cleanup_and_exit "$dialogExit"
	fi

	#Filter output response options that were not selected. This isn't strictly necessary in this example script.
	dialogResponse2=$(echo "$dialogResponseFull2" | grep -v ": false")
	#This processes the response to the second dialog.
	echo "$dialogResponse2" | grep -q '"Option 1" : "true"' && { echo "User chose Option 1." ; option1="Y" ; }
	echo "$dialogResponse2" | grep -q '"Option 2" : "true"' && { echo "User chose Option 2." ; option2="Y" ; }
fi

#Exit the script, deleting any tmp files.
cleanup_and_exit 0
