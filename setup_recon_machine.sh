#!/bin/bash
set -euo pipefail
exec > >(tee -i setup_recon_machine.log)
echo "[*] Starting full recon machine setup..."

# ---- Config ----
GO_VERSION=1.24.5
USER_NAME=$(whoami)

# ---- Validate sudoers entry ----
echo "[*] Ensuring correct sudoers entry..."
SUDO_FILE="/etc/sudoers.d/reconFTW"
echo "${USER_NAME} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee ${SUDO_FILE} >/dev/null
sudo visudo -cf ${SUDO_FILE} || { echo "[-] Sudoers file syntax error!"; exit 1; }

# ---- Update System ----
echo "[*] Updating system..."
sudo apt update && sudo apt full-upgrade -y

# ---- Install Core Packages ----
echo "[*] Installing core dependencies..."
sudo apt install -y git wget curl unzip python3-pip jq build-essential pipx nikto

# ---- Install Go ----
echo "[*] Installing Go $GO_VERSION..."
cd /tmp
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' | sudo tee -a /etc/profile
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# ---- Setup Go Env ----
echo "[*] Configuring Go environment..."
mkdir -p ~/go/bin
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# ---- Install Go-based Tools ----
echo "[*] Installing Go recon tools..."
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/ffuf/ffuf/v2@latest
go install github.com/lc/gau/v2/cmd/gau@latest

# ---- Move Go Binaries ----
echo "[*] Moving Go binaries to /usr/local/bin..."
sudo mv ~/go/bin/* /usr/local/bin/ || true

# ---- Install ReconFTW ----
echo "[*] Installing ReconFTW..."
if [ -d "/opt/reconftw" ]; then
  echo "[*] ReconFTW already exists. Skipping clone."
else
  sudo git clone https://github.com/six2dez/reconftw.git /opt/reconftw
  cd /opt/reconftw
  sudo ./install.sh
  sudo ln -s /opt/reconftw/reconftw.sh /usr/local/bin/reconftw
fi

# ---- Install Shodan CLI ----
echo "[*] Installing Shodan CLI via pipx..."

# Install only if not already installed
if ! command -v shodan &>/dev/null; then
    pipx install shodan
else
    echo "[+] Shodan CLI already installed. Skipping."
fi

# Ensure PATH includes pipx binaries for current and root user
if ! grep -q 'PATH=.*.local/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
fi
export PATH=$PATH:~/.local/bin

if ! sudo grep -q 'PATH=.*.local/bin' /root/.bashrc; then
    echo 'export PATH=$PATH:/root/.local/bin' | sudo tee -a /root/.bashrc >/dev/null
fi


# ---- Install TruffleHog ----
echo "[*] Installing TruffleHog with pipx..."
pipx ensurepath
pipx install trufflehog

# ---- Global Binary Exposure ----
echo "[*] Copying missing binaries to /usr/local/bin..."
sudo cp ~/.local/bin/* /usr/local/bin/ 2>/dev/null || true
sudo find /opt/reconftw/tools/ -type f -executable -exec sudo cp {} /usr/local/bin/ \;
echo 'export PATH=$PATH:/usr/local/bin' | sudo tee -a /root/.bashrc

# ---- Validation ----
echo "[*] Validating installations..."
tools=("subfinder" "httpx" "nuclei" "waybackurls" "ffuf" "gau" "shodan" "trufflehog" "nikto" "reconftw")
for tool in "${tools[@]}"; do
    echo -n "  - $tool: "
    if command -v $tool >/dev/null 2>&1; then
        echo "✅ Installed"
    else
        echo "❌ Missing"
    fi
done

echo "[+] Recon machine setup complete!"
echo "[*] Run 'source ~/.bashrc' or restart terminal to apply env changes."
