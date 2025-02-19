#!/bin/bash
set -e

# Set the script to run in auto mode
AUTO_RUN=false

# Define color escape codes
GREEN='\e[0;32m'
RED='\e[0;31m'
RESET='\e[0m'
YELLOW='\e[1;33m'

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

# Check whether user had supplied -h or --help
if [[ ($@ == "--help") || $@ == "-h" ]]; then
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message and exit"
    echo "  -a, --auto          Run the script in automatic mode without prompts"
    echo ""
    echo "Warning: Running in automatic mode will execute all cleaning operations without confirmation prompts. This may delete important directories and files!"
    exit 0
fi

# Check whether user had supplied -a or --auto
if [[ ($@ == "--auto") || $@ == "-a" ]]; then
    AUTO_RUN=true
fi

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-[y/N]} " response
    case "$response" in
    [yY][eE][sS] | [yY])
        echo "y"
        return 0
        ;;
    *)
        echo "n"
        return 1
        ;;
    esac
}

clean_aws() {
    print_yellow "Step 1/8"
    # Double check its okay to remove AWS creds
    if $AUTO_RUN || confirm "Remove AWS Creds (Y/N) "; then
        if [ -f "$HOME/.aws/credentials" ]; then
            rm "$HOME/.aws/credentials"
            print_green "----------AWS creds removed----------"
        else
            print_yellow "----------AWS Creds not found---------"
        fi
    else
        print_red "----------AWS Skipped----------"
    fi
}

clean_chrome() {
    print_yellow "Step 2/8"
    # Double check its okay to remove contents of chrome
    if $AUTO_RUN || confirm "Remove chrome logins, history and cookies, this will kill the chrome process (Y/N) "; then
        if [ -d "$HOME/.cache/google-chrome/" ]; then
            rm -rf "$HOME/.cache/google-chrome/*"
        else
            print_yellow "----------Chrome Cache not found skipping----------"
        fi
        if [ -d "$HOME/.config/google-chrome/Default" ]; then
            rm -rf "$HOME/.config/google-chrome/Default"
        else
            print_yellow "----------Chrome Config not found skipping----------"
        fi
        print_green "----------Chrome data Cleared----------"
    else
        print_red "----------Chrome Skipped----------"
    fi
}

clean_firefox() {
    print_yellow "Step 3/8"
    # Double check its okay to remove contents of chrome
    if $AUTO_RUN || confirm "Remove chrome logins, history and cookies, this will kill the chrome process (Y/N) "; then
        if [ -d "$HOME/.mozilla/firefox" ]; then
            rm -rf "$HOME/.mozilla/firefox/*"
        else
            print_yellow "----------Firefox Cache not found skipping----------"
        fi
        if [ -d "$HOME/.mozilla/firefox" ]; then
            rm -rf "$HOME/.mozilla/firefox"
        else
            print_yellow "----------Firefox Config not found skipping----------"
        fi
        print_green "----------Firefox data Cleared----------"
    else
        print_red "----------Firefox Skipped----------"
    fi
}

clean_downloads() {
    print_yellow "Step 4/8"
    # Double check its okay to remove contents of downloads
    if $AUTO_RUN || confirm "Remove contents of downloads folder (Y/N) "; then
        if [ -d "$HOME/.ssh/" ]; then
            rm -rf "$HOME/Downloads/*"
        else
            print_yellow "----------Downloads not found skipping----------"
        fi
        print_green "----------Downloads Cleared----------"
    else
        print_red "----------Downloads Skipped----------"
    fi
}

clean_history() {
    print_yellow "Step 5/8"
    # Double check its okay to remove bash history
    if $AUTO_RUN || confirm "Clear Bash History (Y/N) "; then
        history -c
        history -w
        print_green "----------Bash History Cleared----------"
    else
        print_red "----------Bash History Skipped----------"
    fi
}

clean_git(){
    print_yellow "Step 6/8"
    if $AUTO_RUN || confirm "Clear GitHub creds (Y/N) "; then
        
        # Remove GitHub credentials from the credential store
        git credential-cache exit
        git credential-cache --timeout=1 exit
        
        # Remove any stored GitHub credentials from the .git-credentials file
        if [ -f ~/.git-credentials ]; then
            rm ~/.git-credentials
            echo "Removed ~/.git-credentials"
        fi
        echo "----------GitHub Creds Cleared---------"
    fi
}

clean_ssh() {
    print_yellow "Step 7/8"
    # Double check its okay to remove all ssh keys
    if $AUTO_RUN || confirm"Remove all ssh keys from $HOME/.ssh (Y/N) "; then
        if [ -d "$HOME/Downloads/" ]; then
            rm -rf "$HOME/.ssh/"
        else
            print_yellow "----------ssh not found skipping----------"
        fi
        print_green "----------SSH Keys Cleared----------"
    else
        print_red "----------SSH Skipped----------"
    fi
}

clean_cache() {
    print_yellow "Step 8/8"
    if $AUTO_RUN || confirm "Would you like to remove the system cache? /tmp /var/tmp /var/lib/apt/lists/ $HOME/.cache (Y/N) "; then
        sudo apt clean
        sudo rm -rf /tmp/*
        sudo rm -rf /var/tmp/*
        sudo rm -rf /var/lib/apt/lists/*
        rm -rf "$HOME/.cache/*"
        print_green "-----------Cleared Cache-----------"
    else
        print_red "-----------Cache Skipped----------"
    fi
}

# Prompt for script to run
print_green "----------Delivery Cleaner----------"
if $AUTO_RUN || confirm "This script will clean the machine. It will remove the AWS CLI and creds, the bash history, any logged-in GitHub accounts, and perform apt autoremove. 
are you sure you would like to continue (Y/N) "; then
    # Run the clean up the process step by step
    clean_aws
    clean_chrome
    clean_firefox
    clean_downloads
    clean_history
    clean_git
    clean_ssh
    clean_cache
    print_green "----------Cleaning Complete----------"

    # Kill the script if no is selected
else
    print_red "----------Program Terminated----------"
    exit 1
fi