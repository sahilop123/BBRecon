#!/bin/bash

set -e  # Exit on error

# Prompt for target domain
echo -n "Enter target domain: "
read TARGET

# Create a directory for the target
mkdir -p "$TARGET/screenshots"
cd "$TARGET"

echo "[+] Gathering subdomains..."
subfinder -d "$TARGET" -o subfinder.txt || echo "[-] Subfinder failed"
assetfinder --subs-only "$TARGET" > assetfinder.txt || echo "[-] Assetfinder failed"
amass enum -passive -d "$TARGET" -o amass.txt || echo "[-] Amass failed"

# Merge and sort unique subdomains
cat subfinder.txt assetfinder.txt amass.txt | sort -u > all_subdomains.txt

echo "[+] Probing for live domains..."
cat all_subdomains.txt | httprobe > live.txt || echo "[-] Httprobe failed"

# Capture screenshots
echo "[+] Taking screenshots of live domains..."
cat live.txt | aquatone -out "screenshots" || echo "[-] Aquatone failed"

# Fetch Wayback Machine URLs
echo "[+] Fetching Wayback Machine URLs..."
cat live.txt | waybackurls > wayback_urls.txt || echo "[-] Waybackurls failed"

# Filter sensitive file extensions
echo "[+] Filtering sensitive file extensions..."
grep -E '\.pdf|\.xls|\.xlsx|\.csv|\.doc|\.docx|\.json|\.xml|\.sql|\.zip|\.tar|\.gz' wayback_urls.txt > sensitive_urls.txt || echo "[-] Filtering failed"

# Run Nuclei on live URLs
echo "[+] Do you want to choose specific Nuclei templates? (yes/no)"
read CHOICE

if [ "$CHOICE" == "yes" ]; then
    echo "Enter the path to your custom Nuclei templates: "
    read TEMPLATE_PATH
    nuclei -l live.txt -t "$TEMPLATE_PATH" -o nuclei_results.txt || echo "[-] Nuclei failed"
else
    echo "[+] Running Nuclei with default templates..."
    nuclei -l live.txt -o nuclei_results.txt || echo "[-] Nuclei failed"
fi

echo "[+] Recon complete. Results saved in $TARGET/"
