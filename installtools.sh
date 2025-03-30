#!/bin/bash

set -e  # Exit on error

echo "[+] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing dependencies..."
sudo apt install -y curl git wget unzip jq build-essential python3-pip

# Install subfinder
echo "[+] Installing subfinder..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Install assetfinder
echo "[+] Installing assetfinder..."
go install github.com/tomnomnom/assetfinder@latest

# Install amass
echo "[+] Installing amass..."
sudo apt install -y amass

# Install httprobe
echo "[+] Installing httprobe..."
go install github.com/tomnomnom/httprobe@latest

# Install aquatone
echo "[+] Installing aquatone..."
wget https://github.com/michenriksen/aquatone/releases/latest/download/aquatone_linux_amd64.zip -O aquatone.zip
unzip aquatone.zip && chmod +x aquatone && sudo mv aquatone /usr/local/bin/
rm aquatone.zip

# Install waybackurls
echo "[+] Installing waybackurls..."
go install github.com/tomnomnom/waybackurls@latest

# Install Nuclei
echo "[+] Installing Nuclei..."
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Verify installations
echo "[+] Verifying installations..."
for tool in subfinder assetfinder amass httprobe aquatone waybackurls nuclei; do
    if ! command -v $tool &> /dev/null; then
        echo "[-] $tool installation failed"
    else
        echo "[+] $tool installed successfully"
    fi
done

echo "[+] Installation complete."
