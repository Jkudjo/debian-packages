#!/bin/bash

# Script to verify all packages from packages.sh are installed

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
INSTALLED=0
MISSING=0

# Arrays to store results
INSTALLED_LIST=()
MISSING_LIST=()

# Helper functions
check_command() {
    local cmd=$1
    TOTAL=$((TOTAL + 1))
    if command -v "$cmd" >/dev/null 2>&1; then
        INSTALLED=$((INSTALLED + 1))
        INSTALLED_LIST+=("$cmd")
        return 0
    else
        MISSING=$((MISSING + 1))
        MISSING_LIST+=("$cmd")
        return 1
    fi
}

check_package() {
    local pkg=$1
    TOTAL=$((TOTAL + 1))
    if dpkg -l | grep -q "^ii  $pkg " 2>/dev/null; then
        INSTALLED=$((INSTALLED + 1))
        INSTALLED_LIST+=("$pkg")
        return 0
    else
        MISSING=$((MISSING + 1))
        MISSING_LIST+=("$pkg")
        return 1
    fi
}

check_directory() {
    local dir=$1
    local name=$2
    TOTAL=$((TOTAL + 1))
    if [ -d "$dir" ]; then
        INSTALLED=$((INSTALLED + 1))
        INSTALLED_LIST+=("$name")
        return 0
    else
        MISSING=$((MISSING + 1))
        MISSING_LIST+=("$name")
        return 1
    fi
}

print_status() {
    local name=$1
    local status=$2
    if [ "$status" = "installed" ]; then
        echo -e "  ${GREEN}✓${NC} $name"
    else
        echo -e "  ${RED}✗${NC} $name"
    fi
}

echo "=========================================="
echo "Checking Installed Packages & Tools"
echo "=========================================="
echo ""

# ============================================
# STEP 1: Essentials
# ============================================
echo -e "${BLUE}[1/9] Checking Essentials...${NC}"
check_package "build-essential" && print_status "build-essential" "installed" || print_status "build-essential" "missing"
check_package "curl" && print_status "curl" "installed" || print_status "curl" "missing"
check_package "wget" && print_status "wget" "installed" || print_status "wget" "missing"
check_package "git" && print_status "git" "installed" || print_status "git" "missing"
check_package "gnupg" && print_status "gnupg" "installed" || print_status "gnupg" "missing"
check_package "lsb-release" && print_status "lsb-release" "installed" || print_status "lsb-release" "missing"
check_package "ca-certificates" && print_status "ca-certificates" "installed" || print_status "ca-certificates" "missing"
check_package "apt-transport-https" && print_status "apt-transport-https" "installed" || print_status "apt-transport-https" "missing"
echo ""

# ============================================
# STEP 2: Shell & Terminal Tools
# ============================================
echo -e "${BLUE}[2/9] Checking Shell & Terminal Tools...${NC}"
check_directory "$HOME/.oh-my-zsh" "Oh My Zsh" && print_status "Oh My Zsh" "installed" || print_status "Oh My Zsh" "missing"
check_directory "$HOME/.fzf" "fzf" && print_status "fzf" "installed" || print_status "fzf" "missing"
check_command "tmux" && print_status "tmux" "installed" || print_status "tmux" "missing"
check_command "zoxide" && print_status "zoxide" "installed" || print_status "zoxide" "missing"
echo ""

# ============================================
# STEP 3: Development Languages
# ============================================
echo -e "${BLUE}[3/9] Checking Development Languages...${NC}"
check_package "python3" && print_status "python3" "installed" || print_status "python3" "missing"
check_command "pip3" && print_status "python3-pip" "installed" || print_status "python3-pip" "missing"
check_package "python3-dev" && print_status "python3-dev" "installed" || print_status "python3-dev" "missing"
check_package "python3-venv" && print_status "python3-venv" "installed" || print_status "python3-venv" "missing"
check_command "node" && print_status "nodejs" "installed" || print_status "nodejs" "missing"
check_package "default-jdk" && print_status "default-jdk" "installed" || print_status "default-jdk" "missing"
check_package "golang-go" && print_status "golang-go" "installed" || print_status "golang-go" "missing"
check_command "rustc" && print_status "rust" "installed" || print_status "rust" "missing"
check_package "ruby-full" && print_status "ruby-full" "installed" || print_status "ruby-full" "missing"
echo ""

# ============================================
# STEP 4: DevOps & Infrastructure Tools
# ============================================
echo -e "${BLUE}[4/9] Checking DevOps & Infrastructure Tools...${NC}"
check_command "gh" && print_status "GitHub CLI (gh)" "installed" || print_status "GitHub CLI (gh)" "missing"
check_command "docker" && print_status "Docker" "installed" || print_status "Docker" "missing"
check_command "kubectl" && print_status "kubectl" "installed" || print_status "kubectl" "missing"
check_command "helm" && print_status "Helm" "installed" || print_status "Helm" "missing"
check_command "kubectx" && print_status "kubectx" "installed" || print_status "kubectx" "missing"
check_command "kubens" && print_status "kubens" "installed" || print_status "kubens" "missing"
check_command "terraform" && print_status "Terraform" "installed" || print_status "Terraform" "missing"
check_package "ansible" && print_status "Ansible" "installed" || print_status "Ansible" "missing"
check_command "packer" && print_status "Packer" "installed" || print_status "Packer" "missing"
echo ""

# ============================================
# STEP 5: Cloud CLI Tools
# ============================================
echo -e "${BLUE}[5/9] Checking Cloud CLI Tools...${NC}"
check_command "aws" && print_status "AWS CLI" "installed" || print_status "AWS CLI" "missing"
check_command "gcloud" && print_status "Google Cloud SDK" "installed" || print_status "Google Cloud SDK" "missing"
check_command "az" && print_status "Azure CLI" "installed" || print_status "Azure CLI" "missing"
echo ""

# ============================================
# STEP 6: Security Tools
# ============================================
echo -e "${BLUE}[6/9] Checking Security Tools...${NC}"
check_package "nmap" && print_status "nmap" "installed" || print_status "nmap" "missing"
check_package "tcpdump" && print_status "tcpdump" "installed" || print_status "tcpdump" "missing"
check_package "wireshark" && print_status "wireshark" "installed" || print_status "wireshark" "missing"
check_package "netcat-openbsd" && print_status "netcat" "installed" || print_status "netcat" "missing"
check_package "masscan" && print_status "masscan" "installed" || print_status "masscan" "missing"
check_package "nikto" && print_status "nikto" "installed" || print_status "nikto" "missing"
check_package "sqlmap" && print_status "sqlmap" "installed" || print_status "sqlmap" "missing"
check_package "john" && print_status "john" "installed" || print_status "john" "missing"
check_package "hashcat" && print_status "hashcat" "installed" || print_status "hashcat" "missing"
check_package "lynis" && print_status "lynis" "installed" || print_status "lynis" "missing"
check_package "chkrootkit" && print_status "chkrootkit" "installed" || print_status "chkrootkit" "missing"
check_package "rkhunter" && print_status "rkhunter" "installed" || print_status "rkhunter" "missing"
check_package "ufw" && print_status "ufw" "installed" || print_status "ufw" "missing"
check_package "fail2ban" && print_status "fail2ban" "installed" || print_status "fail2ban" "missing"
check_package "auditd" && print_status "auditd" "installed" || print_status "auditd" "missing"
check_command "trivy" && print_status "Trivy" "installed" || print_status "Trivy" "missing"
check_command "grype" && print_status "Grype" "installed" || print_status "Grype" "missing"
check_command "nuclei" && print_status "Nuclei" "installed" || print_status "Nuclei" "missing"
check_command "sops" && print_status "SOPS" "installed" || print_status "SOPS" "missing"
check_command "vault" && print_status "Vault" "installed" || print_status "Vault" "missing"
echo ""

# ============================================
# STEP 7: Utility & Productivity Tools
# ============================================
echo -e "${BLUE}[7/9] Checking Utility & Productivity Tools...${NC}"
check_package "jq" && print_status "jq" "installed" || print_status "jq" "missing"
check_package "yq" && print_status "yq" "installed" || print_status "yq" "missing"
check_command "bat" && print_status "bat" "installed" || print_status "bat" "missing"
check_package "ripgrep" && print_status "ripgrep" "installed" || print_status "ripgrep" "missing"
check_command "fd" && print_status "fd" "installed" || print_status "fd" "missing"
check_package "exa" && print_status "exa" "installed" || print_status "exa" "missing"
check_package "htop" && print_status "htop" "installed" || print_status "htop" "missing"
check_package "btop" && print_status "btop" "installed" || print_status "btop" "missing"
check_command "lazygit" && print_status "lazygit" "installed" || print_status "lazygit" "missing"
check_command "delta" && print_status "delta" "installed" || print_status "delta" "missing"
check_command "k9s" && print_status "k9s" "installed" || print_status "k9s" "missing"
check_package "zip" && print_status "zip" "installed" || print_status "zip" "missing"
check_package "unzip" && print_status "unzip" "installed" || print_status "unzip" "missing"
check_package "tar" && print_status "tar" "installed" || print_status "tar" "missing"
check_package "gzip" && print_status "gzip" "installed" || print_status "gzip" "missing"
check_package "net-tools" && print_status "net-tools" "installed" || print_status "net-tools" "missing"
check_package "dnsutils" && print_status "dnsutils" "installed" || print_status "dnsutils" "missing"
check_package "vim" && print_status "vim" "installed" || print_status "vim" "missing"
check_package "nano" && print_status "nano" "installed" || print_status "nano" "missing"
check_package "neovim" && print_status "neovim" "installed" || print_status "neovim" "missing"
echo ""

# ============================================
# STEP 8: Database & Web Servers
# ============================================
echo -e "${BLUE}[8/9] Checking Database & Web Servers...${NC}"
check_package "mysql-server" && print_status "MySQL Server" "installed" || print_status "MySQL Server" "missing"
check_package "mysql-client" && print_status "MySQL Client" "installed" || print_status "MySQL Client" "missing"
check_package "postgresql" && print_status "PostgreSQL" "installed" || print_status "PostgreSQL" "missing"
check_package "postgresql-client" && print_status "PostgreSQL Client" "installed" || print_status "PostgreSQL Client" "missing"
check_package "apache2" && print_status "Apache" "installed" || print_status "Apache" "missing"
check_package "nginx" && print_status "Nginx" "installed" || print_status "Nginx" "missing"
check_package "php" && print_status "PHP" "installed" || print_status "PHP" "missing"
echo ""

# ============================================
# STEP 9: Infrastructure Security Scanning
# ============================================
echo -e "${BLUE}[9/9] Checking Infrastructure Security Scanning Tools...${NC}"
check_command "checkov" && print_status "Checkov" "installed" || print_status "Checkov" "missing"
check_command "tfsec" && print_status "tfsec" "installed" || print_status "tfsec" "missing"
check_command "terrascan" && print_status "Terrascan" "installed" || print_status "Terrascan" "missing"
check_command "opa" && print_status "OPA" "installed" || print_status "OPA" "missing"
echo ""

# ============================================
# Summary Report
# ============================================
echo "=========================================="
echo "Summary Report"
echo "=========================================="
echo ""
echo -e "Total packages/tools checked: ${BLUE}$TOTAL${NC}"
echo -e "Installed: ${GREEN}$INSTALLED${NC}"
echo -e "Missing: ${RED}$MISSING${NC}"

# Calculate percentage
if [ $TOTAL -gt 0 ]; then
    PERCENTAGE=$((INSTALLED * 100 / TOTAL))
    echo -e "Installation status: ${BLUE}${PERCENTAGE}%${NC}"
    echo ""
    
    # Progress bar
    BAR_LENGTH=50
    FILLED=$((INSTALLED * BAR_LENGTH / TOTAL))
    BAR=""
    for ((i=0; i<BAR_LENGTH; i++)); do
        if [ $i -lt $FILLED ]; then
            BAR="${BAR}█"
        else
            BAR="${BAR}░"
        fi
    done
    echo -e "Progress: [${GREEN}${BAR}${NC}] ${PERCENTAGE}%"
fi

echo ""

# Show missing items if any
if [ $MISSING -gt 0 ]; then
    echo -e "${YELLOW}Missing packages/tools:${NC}"
    for item in "${MISSING_LIST[@]}"; do
        echo -e "  ${RED}✗${NC} $item"
    done
    echo ""
    echo "Run ./packages.sh to install missing packages."
else
    echo -e "${GREEN}✅ All packages and tools are installed!${NC}"
fi

echo ""

# Exit with appropriate code
if [ $MISSING -eq 0 ]; then
    exit 0
else
    exit 1
fi

