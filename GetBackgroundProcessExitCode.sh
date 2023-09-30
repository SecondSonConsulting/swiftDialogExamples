#!/bin/zsh
#set -x 

# An example of how to get the exit code of a swiftDialog window which you've sent to the background.

# Written by Trevor Sysock, aka BigMacAdmin
# Kudos to Nicolás Jorge Dato for the key component

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Path to swiftDialog
dialogPath="/usr/local/bin/dialog"

# Generate a command file
dialogCommandFile=$(mktemp /var/tmp/dialogBackgroun.XXXXXX)

wait_for_dialog() {
    # Found this function here: https://www.baeldung.com/linux/background-process-get-exit-code
    # Pass a PID as argument 1 to this function and it will spit out the exit code once that process completes.
    # Also works if the process was already closed before this funciton runs.
    # The script pauses when this function is called and will not continue until a button is pressed.
    waitPID=$1
    echo Waiting for PID $waitPID to terminate
    wait $waitPID
    dialogSelection=$?
    echo "Dialog command with PID: $waitPID terminated with exit code $dialogSelection"
    return $dialogSelection
}

# Call our Dialog window and use & to send it to the background so that our script keeps running
"$dialogPath" --title "Something Important" \
    --icon "SF=bolt.circle color1=pink color2=blue" \
    --message "You need to do this thing.\n\nPick an option." \
    --button1text "5" \
    --button1disabled \
    --button2text "Exit Code 2" \
    --infobuttontext "Exit Code 3" \
    --ontop \
    --moveable \
    --commandfile ${dialogCommandFile} &

# Capture the PID of the dialog that we sent to the background with the & above
dialogPID=$!

# We will enable button 1 after $counter seconds
counter=5

# Do our countdown. The button itself is the timer display
while [[ $counter -gt 0 ]]; do
	echo "button1text: $counter" >> ${dialogCommandFile}
	sleep 1
	counter=$(( counter - 1 ))
done

# Enable button 1
echo "button1text: Exit Code 0" >> ${dialogCommandFile}
echo "button1: enable" >> ${dialogCommandFile}

# Report the exit code
wait_for_dialog $dialogPID

# Use a case statement to take different actions depending on what the user clicked
case "$dialogSelection" in
    0)
        echo "User chose Button 1"
        # Do button 1 things
        ;;
    2)
        echo "User chose Button 2"
        # Do button 2 things
        ;;
    3)
        echo "User chose Button 3"
        # Do button 3 things
        ;;
    *)
        echo "Dialog exited with unexpected code: $dialogSelection"
        # Do unexpected exit things
        ;;
esac
    
# Cleanliness is next to dogliness
rm "$dialogCommandFile"
