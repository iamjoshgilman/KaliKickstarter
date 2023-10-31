#!/bin/bash

# Define colors...
RED=$(tput bold && tput setaf 1)
GREEN=$(tput bold && tput setaf 2)
YELLOW=$(tput bold && tput setaf 3)
BLUE=$(tput bold && tput setaf 4)
NC=$(tput sgr0)

function RED() {
    echo -e "\n${RED}$1${NC}"
}

function GREEN() {
    echo -e "\n${GREEN}$1${NC}"
}

function YELLOW() {
    echo -e "\n${YELLOW}$1${NC}"
}

function BLUE() {
    echo -e "\n${BLUE}$1${NC}"
}

function install_package() {
    apt install -y "$1"
    if [[ $? -ne 0 ]]; then
        RED "Error installing $1."
        exit 1
    fi
}

# Testing if root...
if [[ "$UID" -ne 0 ]]; then
    RED "You must run this script as root!"
    exit 1
fi

echo -e "${GREEN}"
cat << 'EOF'
 _   __      _ _ _   ___      _        _             _            
| | / /     | (_) | / (_)    | |      | |           | |           
| |/ /  __ _| |_| |/ / _  ___| | _____| |_ __ _ _ __| |_ ___ _ __ 
|    \ / _` | | |    \| |/ __| |/ / __| __/ _` | '__| __/ _ \ '__|
| |\  \ (_| | | | |\  \ | (__|   <\__ \ || (_| | |  | ||  __/ |   
\_| \_/\__,_|_|_\_| \_/_|\___|_|\_\___/\__\__,_|_|   \__\___|_|   
EOF
echo -e "${NC}"

# Ensure necessary tools are installed
if ! command -v wget &> /dev/null; then
    BLUE "Installing wget..."
    install_package wget
fi

if ! command -v gpg &> /dev/null; then
    BLUE "Installing gpg..."
    install_package gpg
fi

if ! command -v sed &> /dev/null; then
    BLUE "Installing sed..."
    install_package sed
fi

BLUE "Updating repositories..."
apt update

BLUE "Installing git..."
install_package git

BLUE "Installing Sublime Text..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
install_package apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt update
install_package sublime-text

BLUE "Installing terminator..."
install_package terminator

BLUE "Setting terminator as the default terminal emulator..."
TERMINAL_DESKTOP_PATH=$(find /usr/share/applications/ -name "xfce4-terminal.desktop")
if [[ -f $TERMINAL_DESKTOP_PATH ]]; then
    cp $TERMINAL_DESKTOP_PATH "$TERMINAL_DESKTOP_PATH.bak"  # Backup the original file
    sed -i 's/Exec=xfce4-terminal/Exec=terminator/g' $TERMINAL_DESKTOP_PATH
else
    RED "xfce4-terminal.desktop not found. Skipping terminator default setting."
fi

BLUE "Installing pip..."
install_package python-pip

BLUE "Removing boilerplate home directories..."
rmdir ~/Music ~/Pictures ~/Public ~/Templates ~/Videos

BLUE "Creating useful home directories..."
mkdir ~/CTF ~/Tools ~/Temp

BLUE "Installing exiftool..."
install_package exiftool

BLUE "Installing sqlitebrowser..."
install_package sqlitebrowser

BLUE "Installing idle..."
install_package idle

BLUE "Downloading stegsolve.jar..."
wget -q "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
if [[ $? -ne 0 ]]; then
    RED "Error downloading stegsolve.jar."
    exit 1
fi
chmod +x "stegsolve.jar"

BLUE "Installing fcrackzip..."
install_package fcrackzip

BLUE "Installing unrar..."
install_package unrar

BLUE "Installing steghide..."
install_package steghide

BLUE "Installing ffmpeg..."
install_package ffmpeg

BLUE "Installing xrdp..."
install_package xrdp
systemctl enable xrdp
systemctl restart xrdp
GREEN "To change default port, edit /etc/xrdp/xrdp.ini"

# Define the alias and environment variables
ALIASES=(
"alias nmap=\"grc nmap\""
"alias please=\"sudo !!\""
)

ENV_VARS=(
"export DIRS_LARGE=/usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt"
"export DIRS_SMALL=/usr/share/seclists/Discovery/Web-Content/raft-small-directories.txt"
"export FILES_LARGE=/usr/share/seclists/Discovery/Web-Content/raft-large-files.txt"
"export FILES_SMALL=/usr/share/seclists/Discovery/Web-Content/raft-small-files.txt"
"export BIG=/usr/share/seclists/Discovery/Web-Content/big.txt"
"export ROCK=/usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt"
)

# Ask user if they want to add the aliases and environment variables
read -p "${GREEN}Do you want to add specified aliases and environment variables to ~/.zshrc? (y/n): " response

if [[ "$response" != "y" ]]; then
    echo "Exiting without adding any aliases or environment variables."
    exit 0
fi

# Check if .zshrc exists in the user's home directory
if [[ ! -f ~/.zshrc ]]; then
    RED "~/.zshrc does not exist! Please create one before proceeding."
    exit 1
fi

# Append the alias
for alias_entry in "${ALIASES[@]}"; do
    echo "$alias_entry" >> ~/.zshrc
done

# Append each environment variable
for env_var in "${ENV_VARS[@]}"; do
    echo "$env_var" >> ~/.zshrc
done

echo "${GREEN}Alias and environment variables have been appended to ~/.zshrc."

GREEN "Install complete!"
