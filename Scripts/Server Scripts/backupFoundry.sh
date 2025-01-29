#!/bin/bash
foundrypath="/home/jumble/foundry/"
backuppath="/home/jumble/foundrybackup/"
remotepath="/mnt/gdrive/foundrybackup/"
discordurl="https://discord.com/api/webhooks/99999/wbc123"

#tar foundry directory and post to discord
tarfoundry(){
tar -czvf ${backuppath}backup_$(date +%Y%m%d).tar.gz $foundrypath
if [ $? -ne 0 ]; then
    curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Backup Failed"}' $discordurl
    exit 1
else 
    curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Tar Complete"}' $discordurl
fi
}

movefoundry(){
#move tar to remote path and post to discord
mv ${backuppath}backup_$(date +%Y%m%d).tar.gz ${remotepath}backup_$(date +%Y%m%d).tar.gz
if [ $? -ne 0 ]; then
    curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Backup Failed"}' $discordurl
    exit 1
else 
    curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Move Complete"}' $discordurl
fi
}
#prune backups
prunebackups(){
find ${remotepath} -type f -mtime +30 -exec rm {} \;
}

#run functions
tarfoundry
movefoundry
prunebackups

#send discord message
curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Backup Complete"}' $discordurl