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

    print_yellow "Installing common tools and utilities. Please provide sudo password:"
    read -sp 'sudo pass: ' usersudo
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

#Learning a lesson the hard way and other aliases
set_up_alias(){
echo "alias rm='rm -i --preserve-root'" >> ~/.bashrc
echo "alias untar=tar -xvf'" >> ~/.bashrc
echo "alias ports='netstat -tuln'" >> ~/.bashrc
echo "alias myip='curl ifconfig.me'" >> ~/.bashrc
echo "alias rsyncquick='rsync -avz --progress'" >> ~/.bashrc
echo "alias rsyncincremental='rsync -avh --progress'" >> ~/.bashrc
echo "alias logs='tail -f /var/log/syslog'" >> ~/.bashrc
echo "alias please='sudo !!'" >> ~/.bashrc
echo "alias c = 'clear'" >> ~/.bashrc
echo "alias speedtest = 'curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'" >> ~/.bashrc
echo "alias bigfiles = 'find . -type f -exec du -h {} + | sort -rh | head -n 10'" >> ~/.bashrc

}

#Set up nano
setup_nano(){
    print_yellow "Downloading nano syntax highlighting"
    wget -q https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh >dev/null 2>&1
    touch ~/.nanorc
    print_yellow "set linenumbers" >> ~/.nanorc
    print_yellow "set autoindent" >> ~/.nanorc
    print_yellow "set backup" >> ~/.nanorc
    print_green "Nano setup complete"
}

install_tools
setup_nano
set_up_alias
