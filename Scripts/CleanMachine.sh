#!/bin/bash

# Define color escape codes
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

# Print green text function
print_green() {
    echo -e "${GREEN}$1${RESET}"
}

# Print red text function
print_red() {
    echo -e "${RED}$1${RESET}"
}

# Prompt the user
read -p "This script will clean the machine. It will remove the AWS CLI and creds, the bash history, any logged-in GitHub accounts, and perform apt autoremove. 
are you sure you would like to continue" response 
# Check the response
if [[ $response =~ ^[Yy]$ ]]; then
    # Run the clean up for AWS and github Creds
    rm ~/.aws/credentials
    print_green "----------AWS creds removed----------"

    rm ~/.git-credentials
    print_green "----------GitHub creds removed----------"

    # Double check its okay to remove chrome data
    read -p "Remove chrome logins, history and cookies?" response2
    if [[ $response2 =~ ^[Yy]$ ]]; then
        rm -rf ~/.cache/google-chrome/*
        rm -f ~/.config/google-chrome/Default/*
        print_green "----------Chrome data Cleared----------"
    else 
         print_red "----------Chrome Skipped----------"
    fi

    print_green "----------Clearing Bash History----------"
    history -c
    history -w
    print_green "----------Bash History Cleared----------"

    sudo apt clean
    sudo apt autoremove
    print_green "----------Cleaning Complete----------"

    # Kill the script if no is selected
elif [[ $response =~ ^[Nn]$ ]]; then
    print_red "----------Program Terminated----------"
    exit 1
else
    print_red "----------Invalid response. Please enter Y or N.---------"
fi

