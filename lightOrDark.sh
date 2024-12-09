#!/bin/zsh
#set -x

#Written by Trevor Sysock (@BigMacAdmin on Slack)
# v2.0 adds support for running as root

#Example script: How to use a "light mode" or "dark mode" screenshot depending on the user environment.
#Pre-requisite: Your files must be named as follows (or you can modify the first command here to suit your needs)
#Example-Screenshot.png <-- for light mode
#Example-Screenshot_dark.png <-- for dark mode

# Get the currently logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser")

# Run a command as the currently logged in user
RunAsUser() {  
	if [ "$currentUser" != "loginwindow" ]; then
		launchctl asuser "$uid" sudo -u "$currentUser" "$@"
	else
		SendToLog "No user logged in, cannot proceed"
		# uncomment the exit command
		# to make the function exit with an error when no user is logged in
		exit 1
	fi
}	

#This determines whether light or dark mode is active, and sets the variable to empty or to _dark. 
#We have to run this command as the logged in user to get the value
#If the script is running as root (like from a management agent) they will have a uid of 0
if [ $(id -u) = 0 ]; then
    #Use the "RunAsUser" function
    $(RunAsUser defaults read -g AppleInterfaceStyle  > /dev/null 2>&1 | grep -q "Dark" ) && darkMode="_dark" || darkMode=""
else
    #Script is running in a user context, do not use RunAsUser
    $(defaults read -g AppleInterfaceStyle  > /dev/null 2>&1 | grep -q "Dark" ) && darkMode="_dark" || darkMode=""
fi

#Customize your basic dialog options
dialogIcon="SF=bolt.circle color1=pink color2=blue"
dialogTitle="Automagic Light/Dark Example"
dialogMessage="This message will appear with a screenshot that matches your light or dark mode automatically."

#Define the image to be in the dialog window
dialogImage="Screenshot-Example""$darkMode".png

#Call your dialog command
/usr/local/bin/dialog -t "$dialogTitle" -m "$dialogMessage" -i "$dialogIcon" --image "$dialogImage"
