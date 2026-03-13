#!/bin/zsh --no-rcs
#set -x

#Written by Trevor Sysock (@BigMacAdmin on Slack)

#Example script: How to capture button output and make actions based on the results

/usr/local/bin/dialog \
    --title "Example Button Click" \
    --message "This script will capture the exit code of the Dialog process, which indicates what action the user took.\n\n Dialog disables button 1 for 3 seconds by default when using a timer." \
    --icon "SF=bolt.circle color1=pink color2=blue" \
    --timer 15 \
    --button1text "Button1" \
    --button2text "Button2" \
    --infobutton "Button3(Info)" \

# Capture the exit code of the previous command in a variable
# Very important that this part comes immediately after the dialog command
dialogExitCode=$?

# Print the exit code to standard out:
echo "Dialog exit code is: $dialogExitCode"

# Case statement to determine actions based on the exit code. This could also be an if/elif/else block, but case is more readable.
case $dialogExitCode in
    0)
        echo "User selected button 1"
        # Do button 1 things here
        ;;
    2)
        echo "User selected button 2"
        # Do button 2 things here
        ;;
    3)
        echo "User selected button 3"
        # Do button 3 things here
        ;;
    4)
        echo "User allowed the timer to expire"
        # Do timer expiration things here
        ;;
    10)
        echo "User used the quit key or otherwise closed the window"
        # Do quit key things here
        ;;
    *)
        echo "Undefined exit code. Process quit unexpectedly or something else weird happened"
        # Do error things here
        ;;
esac

