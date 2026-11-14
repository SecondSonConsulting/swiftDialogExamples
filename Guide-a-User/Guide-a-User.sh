#!/bin/zsh --no-rcs
# shellcheck shell=bash
#set -x

scriptName="Guide-a-User"

# Guide-a-User.sh by: Trevor Sysock
# 2026-11-13
# v.0.0

# Copyright (c) 2026 Second Son Consulting
#
# Unauthorized use, distribution, or reproduction of this script 
# is strictly prohibited and may result in legal action.

#############################
#   Dialog Customizations   #
#############################

# Set options for the initial user selection screen:
welcomeOptions=(
    --title "Welcome to Your Mac"
    --message "This app will help you get started. Select the options you'd like help with today:"
    --button2text "Cancel"
    --icon computer
    --checkboxstyle switch
    --checkbox '{"label":"Network/Wifi Setup","checked":true,"disabled":true,"name":"networkSetup"}'
    --checkbox '{"label":"Printer Setup","checked":false,"name":"printerSetup"}'
    --checkbox '{"label":"Menu Bar Setup","checked":false,"name":"menuBarSetup"}'
    --moveable --ontop
    --position center
    --json
)

# Set options for the network testing screen
networkTestOptions=(
    --title "Lets Get Online"
    --message "Select your home Wi-Fi network, and then enter the password when prompted."
    --icon "SF=wifi,color=blue"
    --progress
    --button1disabled
    --button1text "Next"
    --moveable --ontop
    --position bottomleft
    --image "./WifiHelper1.png"
    --image "./WifiHelper2.png"
    --height $(echo "scale=0; $(system_profiler -json SPDisplaysDataType | jq -r '.SPDisplaysDataType.[].spdisplays_ndrvs.[0]._spdisplays_resolution' | cut -d ' ' -f3) * .90 / 1" | bc) --width 950

)

#################
#   Variables   #
#################

dialogPath="/usr/local/bin/dialog"

#################
#   Functions   #
#################
# Log output
function log_message(){
    echo "$(date) - $*"
}

# execute a dialog command
function dialog_command(){
    /bin/echo "$@"  >> "$dialogCommandFile"
    #log_message "$@"
    sleep .1
}

function setup_dialog_temp_files(){
    delete_dialog_temp_files

    dialogCommandFile="$(mktemp /var/tmp/${scriptName}.XXXXX)" ; chmod 644 "$dialogCommandFile"
    log_message "Dialog Command File: $dialogCommandFile"
    dialogJson="$(mktemp /var/tmp/${scriptName}.XXXXX)" ; chmod 644 "$dialogJson"
    log_message "Dialog JSON File: $dialogJson"

}

function delete_dialog_temp_files(){
    if [ -n "$dialogCommandFile" ] && [ -w "$dialogCommandFile" ]; then
        log_message "Deleting dialog temp file: $dialogCommandFile"
    fi

    if [ -n "$dialogJson" ] && [ -w "$dialogJson" ]; then
        log_message "Deleting dialog temp file: $dialogJson"
    fi
    unset dialogCommandFile
    unset dialogJson
}


function network_connectivity_check(){
    # we'll try 10 times and 5 seconds maximum at a failure with 5 seconds wait between attempts
    local maxRetries=10

    local currentRetry=0
    # While we haven't met our max retries
    while [[ "$currentRetry" -lt "$maxRetries" ]]; do
        # Attempt to connect to Apple's cative portal test server. If successful, the function returns 0
        curl --fail --silent --output /dev/null --max-time 5 http://captive.apple.com && return 0
        # Failed to connect. Increase our retry count by 1
        currentRetry=$(( currentRetry + 1 ))
        # If we haven't maxed out yet, wait 5 seconds and try again
        [[ "$currentRetry" -lt "$maxRetries" ]] && sleep 5
    done
    return 1
}

function network_success(){
    dialog_command "progress: disable"
    dialog_command "button1: enable"
    dialog_command "message: Awesome, you got online!\n\nReady to move on when you are."
    dialog_command "title: Success\!"
    dialog_command "height: 380"
    dialog_command "position: center"
    dialog_command "icon: SF=checkmark.circle.dotted,color=green"
}

function network_failed(){
    dialog_command "quit:"
    log_message "Failed to connect to the internet"
    networkFailOptions=(
    --title "Failed to connect"
    --message "Check that you know your Wi-Fi password, and try again.\n\n If you need support, contact us at 800-555-HELP"
    --icon "SF=wifi,color=red"
    )
    "$dialogPath" "${networkFailOptions[@]}" &
    exit 1
}

##########################
#   Script Starts Here   #
##########################

userInput="$("$dialogPath" "${welcomeOptions[@]}" --json)"
dialogExitCode="$?"

if [[ "$dialogExitCode" != 0 ]]; then
    echo "User cancelled or dialog exited unsuccessfully"
    exit "$dialogExitCode"
fi

networkSetup=$(jq -er '.networkSetup' <<< "$userInput") || networkSetup=false
printerSetup=$(jq -er '.printerSetup' <<< "$userInput") || printerSetup=false
menuBarSetup=$(jq -er '.menuBarSetup' <<< "$userInput") || menuBarSetup=false

echo "User selected: $userInput"

if "$networkSetup" ; then
    setup_dialog_temp_files
    "$dialogPath" "${networkTestOptions[@]}" --commandfile "$dialogCommandFile" &
    sleep .2
    open x-apple.systempreferences:com.apple.wifi-settings-extension

    sleep 15
    network_connectivity_check && network_success || network_failed
fi
