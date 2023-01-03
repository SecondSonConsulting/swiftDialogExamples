#!/bin/zsh

##Written by Trevor Sysock
##aka @BigMacAdmin on Slack

#set -x gives us very verbose output about what the script is doing
set -x 

#Path to the dialog command
dialogPath="/usr/local/bin/dialog"
dialogTitle="Listing Applications"
dialogMessage="This is the contents of your /Applications folder."

#Set our swiftdialog message options. Remember to use an array=()
dialogOptions=(
    --messagefont "name=Impact"
    --titlefont "name=Impact"
    --icon none
    --messagealignment center
)

#Set our swiftdialog message content. Remember to use an array=()
dialogContent=(
    --title "$dialogTitle"
    --message "$dialogMessage"
)

#Loop through the contents of the /Applications folder
for app in /Applications/*; do
    #Append the name of this item to our dialog list
    dialogContent+=(
        --listitem "$(basename "$app")"
    )
done

#Call our dialog command
#Anywhere we're calling an array containing instructions for swiftDialog, be sure to use the format: "${array[@]}"
"$dialogPath" "${dialogOptions[@]}" "${dialogContent[@]}"
