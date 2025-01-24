#!/bin/bash
set -e

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

#install common tools and utilities
install_tools() {

    print_yellow "Installing common tools and utilities."
    read -sp 'Please provide sudo password: ' usersudo
    echo
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                echo "$usersudo" | sudo -S apt update
                echo "$usersudo" | sudo -S apt install -y fzf ncdu htop tmux curl
                print_green "Tools installed successfully"
                ;;
            fedora | rhel | centos | rocky)
                echo "$usersudo" | sudo -S dnf install -y fzf ncdu htop tmux curl
                print_green "Tools installed successfully"
                ;;
            arch)
                echo "$usersudo" | sudo -S pacman -Syu --noconfirm fzf ncdu htop tmux curl
                print_green "Tools installed successfully"
                ;;
            *)
                print_red "Distro not supported by set up script: $ID"
                ;;
        esac
    else
        print_red "Cannot detect the distribution."
    fi
}

set_up_alias(){
    print_yellow "Setting up aliases"
    # Backup bashrc
    cp ~/.bashrc ~/.bashrc.bak

    # Function to add alias if it doesn't already exist
    add_alias() {
        local alias_name="$1"
        local alias_command="$2"
        if ! grep -q "alias $alias_name=" ~/.bashrc; then
            echo "alias $alias_name='$alias_command'" >> ~/.bashrc
        fi
    }

    # File management aliases
    echo "# File management aliases" >> ~/.bashrc
    add_alias "rm" "rm -i --preserve-root"
    add_alias "untar" "tar -xvf"
    add_alias "rsyncquick" "rsync -ravzh --progress"
    add_alias "bigfiles" "find . -type f -exec du -h {} + | sort -rh | head -n 10"

    # Network aliases
    echo "# Network aliases" >> ~/.bashrc
    add_alias "ports" "netstat -tuln"
    add_alias "myip" "curl ifconfig.me"
    add_alias "speedtest" "curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -"

    # System aliases
    echo "# System aliases" >> ~/.bashrc
    add_alias "logs" "tail -f /var/log/syslog"
    add_alias "please" "sudo !!"
    add_alias "c" "clear"

    # Docker aliases
    echo "# Docker aliases" >> ~/.bashrc
    add_alias "dockerpsa" "sudo docker ps -a"

    # Backup aliases
    echo "# Backup aliases" >> ~/.bashrc
    add_alias "backuphome" "tar -czvf /tmp/homebackup.tar.gz /home/$USER"

    # Tmux cheatsheet function
    echo "# Tmux cheatsheet function" >> ~/.bashrc
    echo "print_tmux_cheatsheet() {" >> ~/.bashrc
    echo "    echo '=============================='" >> ~/.bashrc
    echo "    echo '        Tmux Cheatsheet       '" >> ~/.bashrc
    echo "    echo '=============================='" >> ~/.bashrc
    echo "    echo 'Pane Management:'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, %  - Split pane vertically'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, \" - Split pane horizontally'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, x  - Close current pane'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, arrow key - Switch pane'" >> ~/.bashrc
    echo "    echo ''" >> ~/.bashrc
    echo "    echo 'Window Management:'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, c  - Create new window'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, n  - Next window'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, p  - Previous window'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, w  - List windows'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, ,  - Rename current window'" >> ~/.bashrc
    echo "    echo ''" >> ~/.bashrc
    echo "    echo 'Session Management:'" >> ~/.bashrc
    echo "    echo 'Ctrl + b, d  - Detach from session'" >> ~/.bashrc
    echo "    echo 'tmux ls      - List sessions'" >> ~/.bashrc
    echo "    echo 'tmux attach  - Attach to a session'" >> ~/.bashrc
    echo "    echo 'tmux new -s <name> - Create a new session with name'" >> ~/.bashrc
    echo "    echo 'tmux kill-session -t <name> - Kill session with name'" >> ~/.bashrc
    echo "    echo '=============================='" >> ~/.bashrc
    echo "}" >> ~/.bashrc

    # Add alias for tmux cheatsheet
    add_alias "tmuxhelp" "print_tmux_cheatsheet"

    # Reload bashrc
    source ~/.bashrc
    print_green "Aliases set up successfully"
}

# Set up nano
setup_nano(){
    print_yellow "Downloading nano syntax highlighting"
    wget -q https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh > /dev/null 2>&1
    touch ~/.nanorc
    echo "set linenumbers" >> ~/.nanorc
    echo "set autoindent" >> ~/.nanorc
    echo "set backup" >> ~/.nanorc
    print_green "Nano setup complete"
}

install_tools
setup_nano
set_up_alias
