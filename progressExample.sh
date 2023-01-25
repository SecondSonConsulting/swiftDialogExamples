#!/bin/zsh
#set -x 

# An array containing the list of items to progress through
itemsToProgress=(
    "Bribing a tank..."
    "Begging for a healer..."
    "Conjuring water..."
    "Summoning party..."
    "Wiping on trash..."
    "Rage quitting..."
    "Uninstall Complete!"
)

# Path to our dialog binary
dialogPath='/usr/local/bin/dialog'
# Path to our dialog command file
dialogCommandFile=$(mktemp /var/tmp/exampleDialog.XXXXX)

# This function sends a command to our command file, and sleeps briefly to avoid race conditions
function dialog_command()
{
    echo "$@" >> "$dialogCommandFile"
    sleep 0.1
}

# Calling our initial dialog window. The & is crucial so that our script progresses.
# ${#itemsToProgress[@]} is equal to the number of items in our array
$dialogPath \
--title "Looking for Group" \
--message " "  \
--mini \
--commandfile "$dialogCommandFile" \
--progress ${#itemsToProgress[@]} \
--icon "SF=bolt.circle color1=pink color2=blue" \
&

# Display the bouncy bounce for 2 seconds
sleep 2

# Iterate through our array
# For each item we've outlined
for i in "${itemsToProgress[@]}"; do
    dialog_command "progress: increment"
    dialog_command "progresstext: $i"
    sleep 3
done

# Close our dialog window
dialog_command "quit:"

# Delete our command file
rm "$dialogCommandFile"
