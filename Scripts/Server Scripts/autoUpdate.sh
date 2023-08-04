#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# Function to update and upgrade the system
update_upgrade() {
    echo "Updating package lists..."
    apt-get update

    echo "Upgrading packages..."
    apt-get -y upgrade

    echo "Removing unused packages..."
    apt-get -y autoremove

    echo "Cleaning up package cache..."
    apt-get clean

    echo "System update and upgrade completed successfully."
}

# Check if the script is being run with the automatic flag
if [[ $1 == "--auto" ]]; then
    update_upgrade
else
    echo "Auto-update and upgrade script for Linux servers"
    read -p "Do you want to proceed with the update and upgrade? (y/n): " choice

    case "$choice" in
      [yY]|[yY][eE][sS])
        update_upgrade
        ;;
      [nN]|[nN][oO])
        echo "Update and upgrade skipped."
        ;;
      *)
        echo "Invalid choice, please enter 'y' or 'n'."
        ;;
    esac
fi
