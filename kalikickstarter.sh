#!/bin/bash

# Define colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NC=$(tput sgr0) # No Color

# Print messages in colors
print_in_color() {
    color=$1
    text=$2
    echo -e "\n${!color}${text}${NC}"
}

# Function to install a package
install_package() {
    apt-get install -y "$1"
    if [[ $? -eq 0 ]]; then
        print_in_color "GREEN" "$1 installed successfully!"
    else
        print_in_color "RED" "Error installing $1."
        return 1
    fi
}

# Check if running as root
if [[ "$EUID" -ne 0 ]]; then
    print_in_color "RED" "You must run this script as root!"
    exit 1
fi

# Display welcome message
print_in_color "GREEN" "Welcome to the setup script!"

# Ensure necessary tools are installed
necessary_tools=("wget" "gpg" "sed" "apt-transport-https")
for tool in "${necessary_tools[@]}"; do
    if ! command -v $tool &> /dev/null; then
        print_in_color "BLUE" "Installing $tool..."
        install_package $tool
    fi
done

print_in_color "BLUE" "Updating repositories..."
apt-get update

# List of packages to install
packages_to_install=("git" "terminator" "python-pip" "exiftool" "sqlitebrowser" "idle" "fcrackzip" "unrar" "steghide" "ffmpeg")
for package in "${packages_to_install[@]}"; do
    print_in_color "BLUE" "Installing $package..."
    install_package $package
done

# Install IDA Free
print_in_color "BLUE" "Installing IDA Free..."
ida_url="https://out7.hex-rays.com/files/idafree83_linux.run"
ida_dest="$HOME/Downloads/idafree.run"
wget -q $ida_url -O $ida_dest && chmod +x $ida_dest && $ida_dest
if [[ $? -eq 0 ]]; then
    echo 'export PATH=$PATH:/opt/idafree' >> $HOME/.zshrc
else
    print_in_color "RED" "Error downloading or installing IDA Free."
fi

# Install xrdp
print_in_color "BLUE" "Installing xrdp..."
if install_package xrdp; then
    systemctl enable xrdp
    systemctl restart xrdp
    print_in_color "GREEN" "xrdp enabled successfully. To change default port, edit /etc/xrdp/xrdp.ini"
fi

# Install Sublime Text
print_in_color "BLUE" "Installing Sublime Text..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt-get update
install_package sublime-text

# Set terminator as default terminal emulator
print_in_color "BLUE" "Setting terminator as the default terminal emulator..."
TERMINAL_DESKTOP_PATH=$(find /usr/share/applications/ -name "xfce4-terminal.desktop")
if [[ -f $TERMINAL_DESKTOP_PATH ]]; then
    cp $TERMINAL_DESKTOP_PATH "${TERMINAL_DESKTOP_PATH}.bak"
    sed -i 's/Exec=xfce4-terminal/Exec=terminator/g' $TERMINAL_DESKTOP_PATH
else
    print_in_color "RED" "xfce4-terminal.desktop not found. Skipping terminator default setting."
fi

# Download stegsolve.jar
print_in_color "BLUE" "Downloading stegsolve.jar..."
stegsolve_url="http://www.caesum.com/handbook/Stegsolve.jar"
stegsolve_dest="stegsolve.jar"
wget -q $stegsolve_url -O $stegsolve_dest && chmod +x $stegsolve_dest
if [[ $? -ne 0 ]]; then
    print_in_color "RED" "Error downloading stegsolve.jar."
    exit 1
fi

# Directory changes
read -p "${GREEN}Do you want to remove default directories and create new ones? (y/n): ${NC}" response_dir
if [[ "$response_dir" == "y" ]]; then
    print_in_color "BLUE" "Removing boilerplate home directories..."
    for dir in Music Pictures Public Templates Videos; do
        rmdir "$HOME/$dir"
    done

    print_in_color "BLUE" "Creating useful home directories..."
    mkdir -p "$HOME/CTF" "$HOME/Tools" "$HOME/Temp"
fi

# Alias and environment variables setup
setup_aliases_and_env_vars() {
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

    # Backup .zshrc
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"

    # Append the aliases
    for alias_entry in "${ALIASES[@]}"; do
        grep -qF "$alias_entry" "$HOME/.zshrc" || echo "$alias_entry" >> "$HOME/.zshrc"
    done

    # Append each environment variable
    for env_var in "${ENV_VARS[@]}"; do
        grep -qF "$env_var" "$HOME/.zshrc" || echo "$env_var" >> "$HOME/.zshrc"
    done

    print_in_color "GREEN" "Alias and environment variables have been appended to ~/.zshrc."
}

read -p "${GREEN}Do you want to add specified aliases and environment variables to ~/.zshrc? (y/n): ${NC}" response
if [[ "$response" == "y" ]]; then
    setup_aliases_and_env_vars
else
    print_in_color "YELLOW" "Exiting without adding any aliases or environment variables."
    exit 0
fi

print_in_color "GREEN" "Install complete! Please restart your terminal or source ~/.zshrc to apply changes."
