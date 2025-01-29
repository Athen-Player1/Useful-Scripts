#!/bin/bash
foundrypath= "/home/jumble/foundry"
backuppath= "/home/jumble/foundrybackup"
remotepath= "/mnt/gdrive/foundrybackup"
discordurl= "https://discord.com/api/webhooks/1234567890/abcdefghijklmnopqrstuvwxyz"

tar -czvf $backuppath-$(date +%Y%m%d).tar.gz $foundrypath
mv $backuppath-$(date +%Y%m%d).tar.gz $remotepath-$(date +%Y%m%d).tar.gz

#send discord message
curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Backup Complete"}' https://discord.com/api/webhooks/1234567890/abcdefghijklmnopqrstuvwxyz

#send discord message on failure
if [ $? -ne 0 ]; then
  curl -H "Content-Type: application/json" -X POST -d '{"content":"Foundry Backup Failed"}' https://discord.com/api/webhooks/1234567890/abcdefghijklmnopqrstuvwxyz
fi