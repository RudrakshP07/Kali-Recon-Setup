#!/bin/bash
set -e

# ---- Config ----
GO_VERSION=1.22.3

# ---- Update System ----
echo "[+] Updating system..."
sudo apt update && sudo apt full-upgrade -y

# ---- Install Core Packages ----
echo "[+] Installing dependencies..."
sudo apt install -y git wget curl unzip python3-pip jq build-essential pipx nikto

# ---- Install Go ----
echo "[+] Installing Go $GO_VERSION..."
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' | sudo tee -a /etc/profile
source /etc/profile

# ---- Setup Go Env ----
echo "[+] Setting up Go environment..."
mkdir -p ~/go/bin
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc

# ---- Install Go-based Tools ----
echo "[+] Installing recon tools via Go..."
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/ffuf/ffuf/v2@latest
go install github.com/lc/gau/v2/cmd/gau@latest

# ---- Move Binaries to Global PATH ----
echo "[+] Moving tools to /usr/local/bin..."
sudo mv ~/go/bin/* /usr/local/bin/

# ---- Install ReconFTW ----
echo "[+] Installing ReconFTW..."
cd /opt
sudo git clone https://github.com/six2dez/reconftw.git
cd reconftw
sudo ./install.sh
sudo ln -s /opt/reconftw/reconftw.sh /usr/local/bin/reconftw

# ---- Install Shodan CLI ----
echo "[+] Installing Shodan CLI..."
pip install --upgrade shodan
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
echo 'export PATH=$PATH:/root/.local/bin' | sudo tee -a /root/.bashrc
source ~/.bashrc

# ---- Install TruffleHog ----
echo "[+] Installing TruffleHog..."
pipx ensurepath
pipx install trufflehog

# ---- Final Binary Exposure ----
echo "[+] Making sure all binaries are globally accessible..."
sudo cp ~/.local/bin/* /usr/local/bin/ 2>/dev/null || true
sudo find /opt/reconftw/tools/ -type f -executable -exec sudo cp {} /usr/local/bin/ \;
echo 'export PATH=$PATH:/usr/local/bin' | sudo tee -a /root/.bashrc

# ---- Done ----
echo "[+] Recon machine setup complete!"
echo "Run 'source ~/.bashrc' or restart the terminal to finalize environment variables."
