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

confirm() {
	# call with a prompt string or use a default
	read -r -p "${1:-[y/N]} " response
	case "$response" in
		[yY][eE][sS]|[yY])
			echo "y"
			return 1
			;;
		*)
			echo "n"
			return 0
			;;
	esac
}

clean_aws(){
 rm ~/.aws/credentials
    print_green "----------AWS creds removed----------"
}

clean_chrome(){
     # Double check its okay to remove contents of downloads
    if confirm "Remove chrome logins, history and cookies"; then
        rm -rf ~/.cache/google-chrome/*
        rm -f ~/.config/google-chrome/Default/*
        print_green "----------Chrome data Cleared----------"
    else 
         print_red "----------Chrome Skipped----------"
    fi
}

clean_downloads(){
     # Double check its okay to remove contents of downloads
    
    if confirm "Remove contents of downloads folder (Y/N)" ; then
        rm -r ~/Downloads/*
        print_green "----------Downloads Cleared----------"
    else 
         print_red "----------Downloads Skipped----------"
    fi
}

clean_history(){
    history -c
    history -w
    print_green "----------Bash History Cleared----------"

}

clean_git(){
    sudo apt clean
    sudo apt autoremove
    print_green "----------Cleaning Complete----------"
}

clean_ssh(){
    # Double check its okay to remove all ssh keys
    if confirm "Remove all ssh keys from ~/.ssh (Y/N) "; then
        rm -r ~/.ssh/*
        print_green "----------SSH Keys Cleared----------"
    else 
         print_red "----------SSH Skipped----------"
    fi
}


# Prompt for script to run
if confirm "This script will clean the machine. It will remove the AWS CLI and creds, the bash history, any logged-in GitHub accounts, and perform apt autoremove. 
are you sure you would like to continue (Y/N) " ; then
    # Run the clean up for AWS and github Creds
   
    clean_aws
    clean_git
    clean_chrome
    clean_downloads
    clean_history
    clean_ssh
    print_green "----------Cleaning Compelte----------"

    # Kill the script if no is selected
else    print_red "----------Program Terminated----------" exit 1
fi