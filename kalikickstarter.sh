#!/bin/bash

# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`

function RED(){
	echo -e "\n${RED}${1}${NC}"
}
function GREEN(){
	echo -e "\n${GREEN}${1}${NC}"
}
function YELLOW(){
	echo -e "\n${YELLOW}${1}${NC}"
}
function BLUE(){
	echo -e "\n${BLUE}${1}${NC}"
}

# Testing if root...
if [ $UID -ne 0 ]
then
	RED "You must run this script as root!" && echo
	exit
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

BLUE "Updating repositories..."
sudo apt update

BLUE "Installing git..."
sudo apt install -y git

BLUE "Installing Sublime Text..." # according to https://www.sublimetext.com/docs/3/linux_repositories.html-
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install -y apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install -y sublime-text

BLUE "Installing terminator..."
sudo apt install -y terminator

BLUE "Setting terminator as the default terminal emulator..."
sed -i s/Exec=xfce4-terminal/Exec=terminator/g /usr/share/applications/xfce4-terminal.desktop

BLUE "Installing pip..."
sudo apt-get install -y python-pip

BLUE "Removing boilerplate home directories..."
rmdir ~/Music ~/Pictures ~/Public ~/Templates ~/Videos

BLUE "Creating useful home directories..."
mkdir ~/CTF ~/Tools ~/Temp

BLUE "Installing exiftool..."
sudo apt-get install -y exiftool

BLUE "Installing sqlitebrowser..."
sudo apt-get install -y sqlitebrowser

BLUE "Installing idle..."
sudo apt install -y idle

BLUE "Downloading stegsolve.jar..."
wget "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
chmod +x "stegsolve.jar"

BLUE "Installing fcrackzip..."
sudo apt install -y fcrackzip

BLUE "Installing unrar..."
sudo apt install -y unrar

BLUE "Installing steghide..."
sudo apt install -y steghide

BLUE "Installing ffmpeg..."
sudo apt install -y ffmpeg

BLUE "Installing xrdp..."
sudo apt install -y xrdp
sudo systemctl enable xrdp
sudo systemctl restart xrdp
