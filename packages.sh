#!/bin/bash

# Don't use set -e as we want to handle missing packages gracefully
# set -e  # Exit on error

# ============================================
# Helper Functions
# ============================================

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a package is installed via apt
package_installed() {
    dpkg -l | grep -q "^ii  $1 " 2>/dev/null
}

# Install apt package only if not already installed
apt_install_if_missing() {
    local packages_to_install=()
    for pkg in "$@"; do
        if ! package_installed "$pkg"; then
            packages_to_install+=("$pkg")
        else
            echo "  ✓ $pkg is already installed, skipping..."
        fi
    done
    if [ ${#packages_to_install[@]} -gt 0 ]; then
        sudo apt install -y "${packages_to_install[@]}"
    fi
}

# Install apt packages (checking each individually for better feedback)
# Handles packages that may not be available in all Debian versions
apt_install_safe() {
    for pkg in "$@"; do
        if package_installed "$pkg"; then
            echo "  ✓ $pkg is already installed, skipping..."
        else
            echo "  → Installing $pkg..."
            if sudo apt install -y "$pkg" 2>&1 | tee /tmp/apt_install.log | grep -q "Unable to locate package"; then
                echo "  ⚠ $pkg is not available in this Debian version, skipping..."
            fi
            rm -f /tmp/apt_install.log
        fi
    done
}

echo "=========================================="
echo "Installing packages for Security & DevOps"
echo "=========================================="
echo ""

# ============================================
# STEP 1: Update package lists and install essentials
# ============================================
echo "[1/9] Updating package lists and installing essentials..."
sudo apt update
apt_install_safe build-essential curl wget git gnupg lsb-release ca-certificates apt-transport-https

# software-properties-common is Ubuntu-specific, skip if not available
if ! package_installed "software-properties-common"; then
    echo "  → Attempting to install software-properties-common..."
    if sudo apt install -y software-properties-common 2>&1 | grep -q "Unable to locate package"; then
        echo "  ⚠ software-properties-common not available (Ubuntu-only package), skipping..."
    else
        echo "  ✓ software-properties-common installed"
    fi
else
    echo "  ✓ software-properties-common is already installed, skipping..."
fi

# ============================================
# STEP 2: Shell & Terminal Tools
# ============================================
echo ""
echo "[2/9] Installing shell and terminal tools..."

# Install Oh My Zsh (non-interactive)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "  → Installing Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "  ✓ Oh My Zsh is already installed, skipping..."
fi

# Install fzf (fuzzy finder) - only if not already installed
if [ ! -d "$HOME/.fzf" ]; then
    echo "  → Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-update-rc
else
    echo "  ✓ fzf is already installed, skipping..."
fi

# Install tmux (terminal multiplexer)
apt_install_safe tmux

# Install zoxide (smarter cd)
if command_exists zoxide; then
    echo "  ✓ zoxide is already installed, skipping..."
else
    echo "  → Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# ============================================
# STEP 3: Development Languages & Tools
# ============================================
echo ""
echo "[3/9] Installing development languages and tools..."

# Python
apt_install_safe python3 python3-pip python3-dev python3-venv

# Node.js (using NodeSource repository for latest LTS)
if command_exists node; then
    echo "  ✓ Node.js is already installed ($(node --version)), skipping..."
else
    echo "  → Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# Java Development Kit
apt_install_safe default-jdk

# Go programming language
apt_install_safe golang-go

# Rust programming language
if command_exists rustc; then
    echo "  ✓ Rust is already installed ($(rustc --version)), skipping..."
else
    echo "  → Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env" 2>/dev/null || true
fi

# Ruby
apt_install_safe ruby-full

# ============================================
# STEP 4: DevOps & Infrastructure Tools
# ============================================
echo ""
echo "[4/9] Installing DevOps and infrastructure tools..."

# GitHub CLI
if command_exists gh; then
    echo "  ✓ GitHub CLI is already installed ($(gh --version | head -1)), skipping..."
else
    echo "  → Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
fi

# Docker
if command_exists docker; then
    echo "  ✓ Docker is already installed ($(docker --version)), skipping..."
else
    echo "  → Installing Docker..."
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
fi

# Kubernetes tools
if command_exists kubectl; then
    echo "  ✓ kubectl is already installed ($(kubectl version --client --short 2>/dev/null || echo 'installed')), skipping..."
else
    echo "  → Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Helm
if command_exists helm; then
    echo "  ✓ Helm is already installed ($(helm version --short)), skipping..."
else
    echo "  → Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# kubectx and kubens
if command_exists kubectx; then
    echo "  ✓ kubectx/kubens is already installed, skipping..."
else
    echo "  → Installing kubectx/kubens..."
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx 2>/dev/null || true
    sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
fi

# Terraform
if command_exists terraform; then
    echo "  ✓ Terraform is already installed ($(terraform version | head -1)), skipping..."
else
    echo "  → Installing Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    sudo apt update
    sudo apt install -y terraform
fi

# Ansible
apt_install_safe ansible

# Packer
if command_exists packer; then
    echo "  ✓ Packer is already installed ($(packer version | head -1)), skipping..."
else
    echo "  → Installing Packer..."
    sudo apt install -y packer
fi

# ============================================
# STEP 5: Cloud CLI Tools
# ============================================
echo ""
echo "[5/9] Installing cloud CLI tools..."

# AWS CLI v2 (if not already installed)
if command_exists aws; then
    AWS_VERSION=$(aws --version 2>/dev/null || echo "unknown")
    if echo "$AWS_VERSION" | grep -q "aws-cli/1"; then
        echo "  → Upgrading AWS CLI v1 to v2..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    else
        echo "  ✓ AWS CLI is already installed ($AWS_VERSION), skipping..."
    fi
else
    echo "  → Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

# Google Cloud SDK
if command_exists gcloud; then
    echo "  ✓ Google Cloud SDK is already installed ($(gcloud --version | head -1)), skipping..."
else
    echo "  → Installing Google Cloud SDK..."
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt update
    sudo apt install -y google-cloud-sdk
fi

# Azure CLI
if command_exists az; then
    echo "  ✓ Azure CLI is already installed ($(az --version | head -1)), skipping..."
else
    echo "  → Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# ============================================
# STEP 6: Security Tools
# ============================================
echo ""
echo "[6/9] Installing security tools..."

# Network security tools
apt_install_safe nmap tcpdump wireshark-common wireshark netcat-openbsd masscan

# Security scanning tools
apt_install_safe nikto sqlmap john hashcat

# Security auditing
apt_install_safe lynis chkrootkit rkhunter

# Firewall and security
apt_install_safe ufw fail2ban auditd

# Install Trivy (container security scanner)
if command_exists trivy; then
    echo "  ✓ Trivy is already installed ($(trivy --version | head -1)), skipping..."
else
    echo "  → Installing Trivy..."
    sudo apt install -y wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list > /dev/null
    sudo apt update
    sudo apt install -y trivy
fi

# Install Grype (vulnerability scanner)
if command_exists grype; then
    echo "  ✓ Grype is already installed ($(grype version | head -1)), skipping..."
else
    echo "  → Installing Grype..."
    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
fi

# Install Nuclei (vulnerability scanner)
if command_exists nuclei; then
    echo "  ✓ Nuclei is already installed ($(nuclei -version | head -1)), skipping..."
else
    echo "  → Installing Nuclei..."
    if command_exists go; then
        go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    else
        echo "  ⚠ Go is not installed, skipping Nuclei (requires Go)"
    fi
fi

# Install SOPS (secrets encryption)
if command_exists sops; then
    echo "  ✓ SOPS is already installed ($(sops --version)), skipping..."
else
    echo "  → Installing SOPS..."
    curl -LO https://github.com/getsops/sops/releases/latest/download/sops-v3.8.1.linux
    sudo mv sops-v3.8.1.linux /usr/local/bin/sops
    sudo chmod +x /usr/local/bin/sops
fi

# Install Vault (secrets management)
if command_exists vault; then
    echo "  ✓ Vault is already installed ($(vault version | head -1)), skipping..."
else
    echo "  → Installing Vault..."
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    sudo apt update
    sudo apt install -y vault
fi

# ============================================
# STEP 7: Utility & Productivity Tools
# ============================================
echo ""
echo "[7/9] Installing utility and productivity tools..."

# Text processing
apt_install_safe jq yq

# Modern alternatives to classic tools
# bat (cat with syntax highlighting)
if command_exists bat; then
    echo "  ✓ bat is already installed, skipping..."
else
    echo "  → Installing bat..."
    sudo apt install -y bat
    # Create batcat -> bat alias
    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true
fi

# ripgrep (fast grep)
apt_install_safe ripgrep

# fd (find alternative)
if command_exists fd; then
    echo "  ✓ fd is already installed, skipping..."
else
    echo "  → Installing fd..."
    sudo apt install -y fd-find
    sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd 2>/dev/null || true
fi

# exa (ls alternative)
apt_install_safe exa

# htop and btop (process monitors)
apt_install_safe htop btop

# lazygit (git TUI)
if command_exists lazygit; then
    echo "  ✓ lazygit is already installed ($(lazygit --version)), skipping..."
else
    echo "  → Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit
fi

# delta (git diff viewer)
apt_install_safe git-delta

# k9s (Kubernetes TUI)
if command_exists k9s; then
    echo "  ✓ k9s is already installed ($(k9s version | head -1)), skipping..."
else
    echo "  → Installing k9s..."
    K9S_VERSION=$(curl -s "https://api.github.com/repos/derailed/k9s/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    wget "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"
    tar -xzf k9s_Linux_amd64.tar.gz
    sudo install k9s /usr/local/bin
    rm k9s_Linux_amd64.tar.gz k9s
fi

# Common utilities
apt_install_safe zip unzip tar gzip bzip2 xz-utils

# Network utilities
apt_install_safe net-tools dnsutils iputils-ping traceroute

# Text editors
apt_install_safe vim nano neovim

# ============================================
# STEP 8: Database & Web Servers
# ============================================
echo ""
echo "[8/9] Installing database and web servers..."

# MySQL
apt_install_safe mysql-server mysql-client

# PostgreSQL
apt_install_safe postgresql postgresql-client

# Apache
apt_install_safe apache2

# Nginx
apt_install_safe nginx

# PHP
apt_install_safe php php-cli php-mysql php-pgsql php-curl php-json php-mbstring php-xml

# ============================================
# STEP 9: Infrastructure Security Scanning
# ============================================
echo ""
echo "[9/9] Installing infrastructure security scanning tools..."

# Checkov (infrastructure security scanning)
if command_exists checkov; then
    echo "  ✓ Checkov is already installed ($(checkov --version | head -1)), skipping..."
else
    echo "  → Installing Checkov..."
    pip3 install --user checkov
fi

# tfsec (Terraform security scanner)
if command_exists tfsec; then
    echo "  ✓ tfsec is already installed ($(tfsec --version)), skipping..."
else
    echo "  → Installing tfsec..."
    curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
fi

# Terrascan (IaC security scanner)
if command_exists terrascan; then
    echo "  ✓ Terrascan is already installed ($(terrascan version | head -1)), skipping..."
else
    echo "  → Installing Terrascan..."
    curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" -o terrascan.tar.gz
    tar -xzf terrascan.tar.gz terrascan
    sudo install terrascan /usr/local/bin
    rm terrascan.tar.gz terrascan
fi

# OPA (Open Policy Agent)
if command_exists opa; then
    echo "  ✓ OPA is already installed ($(opa version | head -1)), skipping..."
else
    echo "  → Installing OPA..."
    curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
    sudo install opa /usr/local/bin
    rm opa
fi

# ============================================
# Cleanup
# ============================================
echo ""
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo ""
echo "=========================================="
echo "✅ Package installation completed!"
echo "=========================================="
echo ""
echo "Note: Some tools may require you to:"
echo "  - Log out and back in (for Docker group)"
echo "  - Source your shell config: source ~/.zshrc"
echo "  - Add ~/.local/bin to PATH if needed"
echo ""
echo "Installed tools summary:"
echo "  - DevOps: kubectl, helm, terraform, ansible, docker, packer"
echo "  - Cloud: aws, gcloud, az"
echo "  - Security: nmap, trivy, grype, nuclei, sops, vault"
echo "  - Utilities: fzf, bat, ripgrep, fd, exa, lazygit, k9s"
echo "  - Languages: python3, nodejs, go, rust, ruby, java"
echo ""
