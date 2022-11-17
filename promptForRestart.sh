#!/bin/zsh

#Call Dialog, and set options. The \ at the end of each line is to escape the carriage return in order to make this readable.
/usr/local/bin/dialog \
--title "Restart Required" \
--titlefont size=22 \
--message "**Your Company IT** \n\nYour computer requires a restart. \n\nPlease save your work and restart as soon as possible." \
--button1text "Restart Now" \
--width 300 --height 400 \
--messagefont size=16 \
--position topright \
--ontop \
--messagealignment centre \
--messageposition centre \
--centericon \
--icon "SF=restart.circle" \
#--button2
#If you wanted to include a Cancel button, uncomment the line above ^^^

#Capture the output of the dialog. If the user used CMD+Q or the Cancel button then the restart won't happen.
dialogResults=$?

#Check if dialog exited with the default exit code (for the primary button)
if [ "$dialogResults" = 0 ]; then
#This is the restart command. Thank you Dan Snelson: https://snelson.us/2022/07/log-out-restart-shut-down/
#This mimics the user using the Apple > Restart menu option, so they will get a confirmation and have a chance to save work or cancel.
osascript -e 'tell app "loginwindow" to «event aevtrrst»'

#If you wanted to be less nice you could instead use:
#shutdown -r now
fi
