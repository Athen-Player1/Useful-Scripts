#!/bin/bash

# Script to backup Foundry VTT on linux to a remote location and post a discord notification
# This script will tar the foundry directory, move it to a remote location and post a discord notification
# It will also prune backups older than a set number of days
# This script is intended to be run as a cron job   

FOUNDRY_PATH="YOUR/FOUNDRY/FOLDER/"
BACKUP_PATH="/WHERE/THE/BACKUP/SHOULD/BE/PATH/"
REMOTE_PATH="/YOUR/REMOTE/PATH/"
DISCORD_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
RETENTION_DAYS="14" # Number of days to keep backups NOTE  all files older than this will be deleted at remote path
PRUNE=0 # Set to true to PRUNE backups

# Colors
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
    echo "  -p, --PRUNE          Script will auto PRUNE backups at the remote path"
    echo ""
    exit 0
fi


# Check whether user had supplied -p or --prune
if [[ ($@ == "--prune") || $@ == "-p" ]]; then
    PRUNE=1
fi


# Fail, send message and exit script function
backupfailed(){
print_red "-----Backup failed-----"
curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Backup Failed, Log has been created"}' $DISCORD_URL
curl -s -F "Content-Type: application/json" -X POST -d -F "backuplog@${./foundrybackup_$(date +%Y%m%d).log}"  $DISCORD_URL
print_red "Exiting script due to failure"
exit 1
}

# Tar foundry directory and post to discord
tarfoundry(){
    tar -czvf ${BACKUP_PATH}backup_$(date +%Y%m%d).tar.gz $FOUNDRY_PATH
    chown $USER:$USER ${BACKUP_PATH}backup_$(date +%Y%m%d).tar.gz
    if [ $? -ne 0 ]; then
        print_red "tar failed"
        backupfailed
    else 
        print_green "-----Tar complete-----"
        curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Tar Complete"}' $DISCORD_URL
    fi
}

movefoundry(){
# Rsync tar to remote path and post to discord using rsync
rsync -avhd --progress --info=progress2 ${BACKUP_PATH}backup_$(date +%Y%m%d).tar.gz ${REMOTE_PATH}
if [ $? -ne 0 ]; then
   print_red "move failed"
   backupfailed
   exit 1
else 
    print_green "-----Move complete-----"
    curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Move Complete"}' $DISCORD_URL
fi
}
# PRUNE backups
prunebackups(){
if [ "$PRUNE" -eq 0 ]; then
    print_yellow "-----PRUNE disabled-----"
    exit 0
elif [ "$PRUNE" -eq 1 ]; then
    find "${REMOTE_PATH}" -type f -mtime +$RETENTION_DAYS -delete
    if [ $? -ne 0 ]; then
    backupfailed
    exit 1
    else 
    print_green "-----PRUNE complete-----"
    curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Move Complete"}' $DISCORD_URL
    fi
else
    print_red "PRUNE value not set correctly"
    backupfailed
    exit 1
fi

}

# Run functions
exec > "foundrybackup_$(date +%Y%m%d).log" 2>&1
chown $USER:$USER "foundrybackup_$(date +%Y%m%d).log"
print_green "-----Starting foundry backup-----"
curl -H "Content-Type: application/json" -X POST -d '{"content":"Backup Starting..."}' $DISCORD_URL
tarfoundry
movefoundry
prunebackups
print_green "-----Foundry backup complete-----"

# Send discord message
curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Backup Complete"}' $DISCORD_URL