#!/bin/bash

foundrypath="/home/$USER/foundry/"
backuppath="/home/$USER/foundrybackup/"
remotepath="/remotepath/"
discordurl="https://discord.com/api/webhooks/123/123"
retention_days=14


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

# Fail send message and exit script function
backupfailed(){
print_red "-----backup failed-----"
curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Backup Failed, Log has been created"}' $discordurl
curl -s -F "Content-Type: application/json" -X POST -d -F "backuplog@${./foundrybackup_$(date +%Y%m%d).log}"  $discordurl
print_red "Exiting script due to failure"
exit 1
}

# Tar foundry directory and post to discord
tarfoundry(){
    tar -czvf ${backuppath}backup_$(date +%Y%m%d).tar.gz $foundrypath
    if [ $? -ne 0 ]; then
        print_red "tar failed"
        backupfailed
    else 
        print_green "-----tar complete-----"
        curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Tar Complete"}' $discordurl
    fi
}

movefoundry(){
# Rsync tar to remote path and post to discord using rsync
rsync -avhd --progress --info=progress2 ${backuppath}backup_$(date +%Y%m%d).tar.gz ${remotepath}
if [ $? -ne 0 ]; then
   print_red "move failed"
   backupfailed
   exit 1
else 
    print_green "-----move complete-----"
    curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Move Complete"}' $discordurl
fi
}
# Prune backups
prunebackups(){
find ${remotepath} -type f -mtime +$retention_days -exec rm {} \;
if [ $? -ne 0 ]; then
   print_red "prune failed"
   backupfailed
   exit 1
else 
   print_green "-----prune complete-----"
   curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Move Complete"}' $discordurl
fi
}

# Run functions
exec > "foundrybackup_$(date +%Y%m%d).log" 2>&1
print_green "-----starting foundry backup-----"
curl -H "Content-Type: application/json" -X POST -d '{"content":"Backup Starting..."}' $discordurl
tarfoundry
movefoundry
prunebackups
print_green "-----foundry backup complete-----"

# Send discord message
curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Backup Complete"}' $discordurl