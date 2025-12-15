#!/bin/bash

# Quick script to install only the missing packages from check_installed.sh

echo "Installing missing packages..."
echo ""

# Update package lists
sudo apt update

# Install apt packages
echo "Installing apt packages..."
sudo apt install -y golang-go packer nikto exa dnsutils mysql-server mysql-client

# Install Trivy (if repository is available)
if apt-cache show trivy >/dev/null 2>&1; then
    echo "Installing Trivy..."
    sudo apt install -y trivy
else
    echo "⚠ Trivy repository not available for this Debian version, skipping..."
fi

# Install Grype
if ! command -v grype &> /dev/null; then
    echo "Installing Grype..."
    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
fi

# Install Nuclei (requires Go)
if ! command -v nuclei &> /dev/null; then
    if command -v go &> /dev/null; then
        echo "Installing Nuclei..."
        go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    else
        echo "⚠ Go is not installed, skipping Nuclei (install golang-go first)"
    fi
fi

# Install Checkov
if ! command -v checkov &> /dev/null; then
    echo "Installing Checkov..."
    pip3 install --user checkov
fi

# Install Rust (if not installed)
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env" 2>/dev/null || true
fi

echo ""
echo "✅ Installation complete!"
echo "Run ./check_installed.sh to verify installation."

