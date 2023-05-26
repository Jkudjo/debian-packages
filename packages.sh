#!/bin/bash


# Install Curl
sudo apt install -y curl

#install gh cli for github
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y


#For Oh-my-zsh shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Update package lists
sudo apt update

# Install essential packages
sudo apt install -y build-essential curl wget git

# Install fuzzy finder
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install common utilities
sudo apt install -y zip unzip tar gzip

# Install network tools
sudo apt install -y net-tools dnsutils

# Install text editors
sudo apt install -y vim nano

# Install development tools
sudo apt install -y gcc g++ make

# Install Python and related packages
sudo apt install -y python3 python3-pip python3-dev

# Install Java Development Kit (JDK)
sudo apt install -y default-jdk

# Install Node.js and npm
sudo apt install -y nodejs npm

# Install Docker
sudo apt install -y docker.io

# Install MySQL
sudo apt install -y mysql-server mysql-client

# Install PostgreSQL
sudo apt install -y postgresql postgresql-client

# Install Apache web server
sudo apt install -y apache2

# Install Nginx web server
sudo apt install -y nginx

# Install PHP and related packages
sudo apt install -y php php-cli php-mysql

# Install Ruby
sudo apt install -y ruby-full

# Install Go programming language
sudo apt install -y golang-go

# Install Rust programming language
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install AWS CLI
sudo apt install -y awscli

# Install GIMP (image editor)
sudo apt install -y gimp

# Install VLC media player
sudo apt install -y vlc

# Install LibreOffice
sudo apt install -y libreoffice

# Install GNOME Tweak Tool (for GNOME desktop)
sudo apt install -y gnome-tweak-tool

# Clean up package cache
sudo apt autoremove -y
sudo apt autoclean

echo "Packages installation completed."
