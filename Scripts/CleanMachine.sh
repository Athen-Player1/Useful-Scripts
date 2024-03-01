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

cleanAWS(){
 rm ~/.aws/credentials
    print_green "----------AWS creds removed----------"
}

cleanChrome(){
     # Double check its okay to remove contents of downloads
     read -p "Remove chrome logins, history and cookies (Y/N)" response2
    if [[ $response2 =~ ^[Yy]$ ]]; then
        rm -rf ~/.cache/google-chrome/*
        rm -f ~/.config/google-chrome/Default/*
        print_green "----------Chrome data Cleared----------"
    else 
         print_red "----------Chrome Skipped----------"
    fi
}

cleanDownloads(){
     # Double check its okay to remove contents of downloads
    read -p "Remove contents of downloads folder (Y/N)" response3
    if [[ $response3 =~ ^[Yy]$ ]]; then
        rm -r ~/Downloads/*
        print_green "----------Downloads Cleared----------"
    else 
         print_red "----------Downloads Skipped----------"
    fi
}

cleanHistory(){
    history -c
    history -w
    print_green "----------Bash History Cleared----------"

}

cleanGit(){
    sudo apt clean
    sudo apt autoremove
    print_green "----------Cleaning Complete----------"
}

cleanSSH(){
    # Double check its okay to remove all ssh keys
    read -p "Remove all ssh keys from ~/.ssh (Y/N)" response4
    if [[ $response4 =~ ^[Yy]$ ]]; then
        rm -r ~/.ssh/*
        print_green "----------SSH Keys Cleared----------"
    else 
         print_red "----------SSH Skipped----------"
    fi
}

# Prompt the user
read -p "This script will clean the machine. It will remove the AWS CLI and creds, the bash history, any logged-in GitHub accounts, and perform apt autoremove. 
are you sure you would like to continue" response 
# Check the response
if [[ $response =~ ^[Yy]$ ]]; then
    # Run the clean up for AWS and github Creds
   
    cleanAWS
    cleanGit
    cleanChrome
    cleanDownloads
    cleanHistory
    cleanSSH


    # Kill the script if no is selected
elif [[ $response =~ ^[Nn]$ ]]; then
    print_red "----------Program Terminated----------"
    exit 1
else
    print_red "----------Invalid response. Please enter Y or N.---------"
fi