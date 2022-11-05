#!/bin/zsh
#set -x

##Written by Trevor Sysock
##aka @BigMacAdmin on Slack

##version 1.0

##This script is meant as an example of how to keep a persistent dialog box open, giving the user an opportunity to defer for 5 minutes, 4 minutes, 3 minutes, 2 minutes, then 1 minute. 
##In its final form it cannot be defeated! (except by sudo).

#Define dialog path for convenience
dialogPath=/usr/local/bin/dialog

#Create a tmp file to hold our dialog options
tmpDialogFile1=$(mktemp /tmp/tmpDialogFile1.XXXXXX)

#Set the options we'll use for the dialog window
dialogTitle="Mandatory Action Required"
dialogMessage="This is something you must do."
dialogIcon="SF=bolt.circle color1=pink color2=blue"
dialogButton1="Ok fine, I am ready..."

#Define the initial deferral (in seconds)
currentDeferralTime="300"

#Define how much the deferral should increment each time it is clicked - For testing, I suggest the value be 2
reduceDeferralBy="60"

#Setting default consent to "No". Until the user actually clicks the button, we want to keep looping.
userConsent=1

#These options are used before the deferral timer reaches zero. Once it reaches zero, these variables are set to empty further down.
#Since we want 
nonaggressiveOption1="--button2text"
nonaggressiveButtonText="Not Now"
nonaggressiveDialogMessage="\n\n If you choose \"Not Now\" you will be bothered again in $(((currentDeferralTime-reduceDeferralBy)/60)) minutes."

#Start a loop, and continue looping until the user has consented.
while [[ userConsent -gt 0 ]]; do

#Call our dialog window. Use \ and new lines to make it readable. (See my other examples if JSON is easier for you to read)
#BE AWARE - If you dont set a custom quit key, the command exits on 0 when the user presses CMD+Q. This can result in a false consent! (You also cant set --quitkey to "q" to get around this limitation
"$dialogPath" \
--title "$dialogTitle" \
--message "$dialogMessage $nonaggressiveDialogMessage" \
--icon "$dialogIcon" \
--button1text "$dialogButton1" \
"$nonaggressiveOption1" "$nonaggressiveButtonText" \
--centericon \
--alignment center \
--ontop \
--quitkey [ \

#Capture the exit code of the previous dialog command. This informs us of what the user did.
dialogResult=$?

#If the user found our custom quit key, add a snarky message (they also don't get their deferral timer on this loop)
if [ "$dialogResult" = 10 ]; then
	nonaggressiveDialogMessage+="\n\n Clever clever, look at you, figuring out the quit key... Not gonna work!...\n\n You still need to do the thing."
	
#If the user chose button 1, they have consented to the action and the loop ends
elif [ "$dialogResult" = 0 ]; then
	userConsent=0
	
#If the user did ANYTHING else (killed dialog somehow, dialog errored, chose to defer, whatever)
else
	#Check if deferral timer is greater than 0. If it is, then sleep for that long.
	if [[ "$currentDeferralTime" -gt 0 ]]; then
		sleep "$currentDeferralTime"
	else
	#If we make it to this logic, the deferral timer is exhausted. Remove the "Not Now" button and the message about deferrals.
		nonaggressiveOption1=""
		nonaggressiveButtonText=""
		nonaggressiveDialogMessage=""
	fi
fi
#This is the last step of the loop. Do the math to make our deferral timer reduced incrementally by the value chosen above.
currentDeferralTime=$((currentDeferralTime-reduceDeferralBy))
done

#Congratulations! Your user consented. Here is where you put the rest of your script.
echo "All the cool kids hang out in the Mac Admins Slack. Go buy some merch."

#Final dialog for user. I always present my closing dialog with an & so my script closes 
"$dialogPath" --title "Thank you for doing your part!" \
--message  "" \
--icon "$dialogIcon" \
--centericon \
--alignment center
