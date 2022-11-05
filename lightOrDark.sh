#!/bin/zsh
#set -x

#Written by Trevor Sysock (@BigMacAdmin on Slack)

#Example script: How to use a "light mode" or "dark mode" screenshot depending on the user environment.
#Pre-requisite: Your files must be named as follows (or you can modify the first command here to suit your needs)
#Example-Screenshot.png <-- for light mode
#Example-Screenshot_dark.png <-- for dark mode

#This determines whether light or dark mode is active, and sets the variable to empty or to _dark. 
$(defaults read -g AppleInterfaceStyle  > /dev/null 2>&1 | grep -q "Dark" ) && darkMode="_dark" || darkMode=""

#Customize your basic dialog options
dialogIcon="SF=bolt.circle color1=pink color2=blue"
dialogTitle="Automagic Light/Dark Example"
dialogMessage="This message will appear with a screenshot that matches your light or dark mode automatically."

#Define the image to be in the dialog window
dialogImage="Screenshot-Example""$darkMode".png

#Call your dialog command
/usr/local/bin/dialog -t "$dialogTitle" -m "$dialogMessage" -i "$dialogIcon" --image "$dialogImage"