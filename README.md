# Debian Packages Installation Script

A comprehensive script to install essential packages and tools for **Security & DevOps Engineers** on Debian-based systems.

## What This Script Installs

### 🛠️ DevOps & Infrastructure Tools
- **Container & Orchestration**: Docker, kubectl, Helm, kubectx/kubens, k9s
- **Infrastructure as Code**: Terraform, Ansible, Packer
- **CI/CD**: GitHub CLI (gh)
- **Cloud CLIs**: AWS CLI v2, Google Cloud SDK, Azure CLI

### 🔒 Security Tools
- **Network Security**: nmap, tcpdump, wireshark, netcat, masscan
- **Vulnerability Scanning**: Trivy, Grype, Nuclei, nikto, sqlmap
- **Security Auditing**: lynis, chkrootkit, rkhunter
- **Secrets Management**: SOPS, Vault
- **Infrastructure Security**: Checkov, tfsec, Terrascan, OPA
- **Firewall & Monitoring**: ufw, fail2ban, auditd

### 💻 Development Tools
- **Languages**: Python 3, Node.js (LTS), Java (JDK), Go, Rust, Ruby
- **Package Managers**: pip, npm
- **Version Control**: Git, lazygit

### 🎯 Utility Tools
- **Shell Enhancements**: Oh My Zsh, fzf (fuzzy finder), zoxide, tmux
- **Text Processing**: jq, yq, bat, ripgrep, fd, exa
- **Git Tools**: lazygit, delta
- **Process Monitoring**: htop, btop

### 🗄️ Database & Web Servers
- **Databases**: MySQL, PostgreSQL
- **Web Servers**: Apache, Nginx
- **PHP**: PHP with common extensions

## Usage

### Prerequisites
- Debian-based Linux distribution
- sudo privileges
- Internet connection

### Installation

```bash
# Make the script executable
chmod +x packages.sh

# Run the script
./packages.sh
```

**Note**: The script will:
- Check if tools are already installed to avoid duplicates
- Install tools from official repositories when possible
- Download and install binaries for tools not in repositories
- Add necessary repositories and GPG keys

### Post-Installation

After running the script, you may need to:

1. **Log out and back in** (for Docker group membership)
2. **Reload your shell configuration**:
   ```bash
   source ~/.zshrc
   ```
3. **Add local bin to PATH** (if needed):
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

## Tool Categories

### Container & Kubernetes
- `docker` - Container runtime
- `kubectl` - Kubernetes CLI
- `helm` - Kubernetes package manager
- `k9s` - Kubernetes TUI
- `kubectx/kubens` - Context/namespace switching

### Infrastructure as Code
- `terraform` - Infrastructure provisioning
- `ansible` - Configuration management
- `packer` - Image building

### Security Scanning
- `trivy` - Container/image vulnerability scanner
- `grype` - Vulnerability scanner
- `nuclei` - Vulnerability scanner
- `checkov` - Infrastructure security scanning
- `tfsec` - Terraform security scanner
- `terrascan` - IaC security scanner

### Cloud Platforms
- `aws` - AWS CLI v2
- `gcloud` - Google Cloud SDK
- `az` - Azure CLI

### Network & Security
- `nmap` - Network scanner
- `tcpdump` - Packet analyzer
- `wireshark` - Protocol analyzer
- `nikto` - Web server scanner
- `sqlmap` - SQL injection testing

## Customization

You can modify the script to:
- Skip certain tool categories
- Add additional tools
- Change installation methods
- Adjust version numbers

## Troubleshooting

### Permission Issues
If you encounter permission errors:
```bash
sudo chmod +x packages.sh
```

### Network Issues
If downloads fail, check your internet connection and proxy settings.

### Tool Not Found After Installation
- Reload your shell: `source ~/.zshrc`
- Check if the tool is in your PATH: `which <tool-name>`
- Some tools may require a new terminal session

## License

This script is provided as-is for convenience. Use at your own risk.

## Contributing

Feel free to submit issues or pull requests to improve this script.
