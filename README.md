# swiftDialogExamples

This repository contains example scripts to show off the various features of [SwiftDialog](https://github.com/bartreardon/swiftDialog)

## checklistJSONexample.sh
An example of how to generate checklists using JSON data and parse the output all in shell.

If you choose Option D, you'll be presented with an additional option set.

## lightOrDark.sh
An example of how you can setup different image files in a dialog window dependent on whether Light Mode or Dark Mode is currently enabled.

Useful if you want to include screenshots of macOS menus in your Dialog windows.

## persistentDialog.sh
An example of how to set a bothersome persistent Dialog window with a simple deferral mechanism.

## captureButtonOutput.sh
An example of how to capture the user input (and exit code) of a Dialog window and then perform different tasks based on the results.

## promptForRestart.sh
An example of a script that prompts the user to restart

## arraysNoEval.sh
An example of how to use bash/zsh arrays to pass arguments that contain your SwiftDialog options. There is probably no need to use `eval`. You can read more here: https://bigmacadmin.wordpress.com/2023/01/03/avoiding-eval-with-swiftdialog/

## progressExample.sh
An zsh example of how to get the length of an array and iterate through each item using a command file to control a progress bar.

## deferralsExample.sh
An example script for doing something with user deferrals. This is a fully functional template script with extensive comments documenting the behavior. You can read more here: https://bigmacadmin.wordpress.com/2023/02/20/scripting-user-deferrals-with-swiftdialog/
