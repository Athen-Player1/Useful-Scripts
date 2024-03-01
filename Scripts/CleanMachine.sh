#!/bin/bash
set -e

# Define color escape codes
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'
YELLOW='\033[1;33m'

# Print green text function
print_green() {
    echo -e "${GREEN}$1${RESET}"
}

# Print red text function
print_red() {
    echo -e "${RED}$1${RESET}"
}

# Print yellow text function
print_yellow() {
    echo -e "${YELLOW}$1${RESET}"
}

# check whether user had supplied -h or --help
if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then 
	echo "Please run with SUDO to ensure sanitisation"
	exit 0
fi 

confirm() {
	# call with a prompt string or use a default
	read -r -p "${1:-[y/N]} " response
	case "$response" in
		[yY][eE][sS]|[yY])
			echo "y"
			return 0
			;;
		*)
			echo "n"
			return 1
			;;
	esac
}

clean_aws(){
    # Double check its okay to remove AWS creds
    if confirm "Remove AWS Creds (Y/N) "; then
        rm ~/.aws/credentials
        print_green "----------AWS creds removed----------"
       else 
         print_red "----------AWS Skipped----------"
    fi
}

clean_chrome(){
     # Double check its okay to remove contents of chrome
    if confirm "Remove chrome logins, history and cookies, this will kill the chrome process (Y/N) "; then
        kill $(pgrep chrome)
        rm -rf ~/.cache/google-chrome/*
        rm -f ~/.config/google-chrome/Default/*
        print_green "----------Chrome data Cleared----------"
    else 
         print_red "----------Chrome Skipped----------"
    fi
}

clean_downloads(){
     # Double check its okay to remove contents of downloads  
    if confirm "Remove contents of downloads folder (Y/N) " ; then
        rm -r ~/Downloads/*
        print_green "----------Downloads Cleared----------"
    else 
         print_red "----------Downloads Skipped----------"
    fi
}

clean_history(){
    # Double check its okay to remove bash history
    if confirm "Clear Bash History (Y/N) "; then
        history -c
        history -w
        print_green "----------Bash History Cleared----------"
    else 
         print_red "----------Bash History Skipped----------"
    fi
}

clean_git(){
    # Double check its okay to remove all git creds
    if confirm "Clear GitHub creds (Y/N) "; then
        git config --global --unset credential.helper
        git credential-cache exit
        rm ~/.git-credentials
        print_green "----------Git creds cleared----------"
    else 
         print_red "----------Git Creds Skipped----------"
    fi
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

clean_cache(){
    if confirm "Would you like to remove the system cache? /tmp /var/tmp /var/lib/apt/lists/ ~/.cache (Y/N) "; then
        sudo apt clean
        sudo apt autoremove
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache
        print_green "-----------Cleared Cache-----------"
    else
        print_red "-----------Cache Skipped----------"
    fi

}

# Prompt for script to run
print_yellow "----------Delievery NUC Cleaner----------"
if confirm "This script will clean the machine. It will remove the AWS CLI and creds, the bash history, any logged-in GitHub accounts, and perform apt autoremove. 
are you sure you would like to continue (Y/N) " ; then
    # Run the clean up the process print the current step
    print_yellow "Step 1/7"
    clean_aws
    print_yellow "Step 2/7"
    clean_chrome
    print_yellow "Step 3/7"
    clean_downloads
    print_yellow "Step 4/7"
    clean_history
    print_yellow "Step 5/7"
    clean_git
    print_yellow "Step 6/7"
    clean_ssh
    print_yellow "Step 7/7"
    print_yellow "----------Cleaning Complete----------"

    # Kill the script if no is selected
else    
    print_red "----------Program Terminated----------" exit 1
fi