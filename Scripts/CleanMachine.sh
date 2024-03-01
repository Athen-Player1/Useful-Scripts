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
read -p "This script will clean the machine. It will remove the AWS CLI and creds, the bash history, any logged-in GitHub accounts, and perform apt autoremove. Are you >
# Check the response
if [[ $response =~ ^[Yy]$ ]]; then
    # Run the clean up
    sudo apt remove awscli
    print_green "-----------AWS CLI removed----------"

    rm ~/.aws/credentials
    print_green "----------AWS creds removed----------"

    rm ~/.git-credentials
    print_green "----------GitHub creds removed----------"

    print_green "----------Clearing Bash History----------"
    history -c
    history -w
    print_green "----------Bash History Cleared----------"

    sudo apt clean
    sudo apt autoremove
    print_green "----------Cleaned system cache and performed apt autoremove----------"
elif [[ $response =~ ^[Nn]$ ]]; then
    print_red "----------Program Terminated----------"
    exit 1
else
    print_red "----------Invalid response. Please enter Y or N.---------"
fi

