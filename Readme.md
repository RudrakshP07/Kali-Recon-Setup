# 🛠️ Kali Recon Setup — One-Click Recon & Bug Bounty Toolkit for 2025

A one-click shell script to fully configure a **Kali Linux machine for bug bounty hunting, recon, and offensive security testing**.  
It sets up all essential tools system-wide — globally accessible by both root and non-root users.

---

## 🚀 What It Installs

✅ **Recon & Enumeration**
- `subfinder` (subdomain enumeration)
- `httpx` (host probing)
- `nuclei` (vulnerability scanning)
- `ffuf` (directory & endpoint fuzzing)
- `waybackurls` + `gau` (archive URL scraping)
- `nikto` (server vulnerability scanning)

✅ **Secrets Detection**
- `trufflehog` (repo & code secret scanner)

✅ **Automated Recon Framework**
- `ReconFTW` (passive & active recon automation)

✅ **OSINT/Infra**
- `shodan` CLI

---

## 📦 Requirements

- Fresh **Kali Linux 2023+** install (or any modern Debian-based distro)
- `sudo` privileges

---

## 🧩 How to Use

1. **Clone this repository**

```bash
git clone https://github.com/your-username/kali-recon-setup.git
cd kali-recon-setup


## 📖 Read the Full Guide
➡️ Build the Ultimate Bug Bounty & Recon Machine on Kali (2025)
Read the full breakdown of each tool, its purpose, and advanced usage.

📌 Post-Install Tips
Add your Shodan API key:

shodan init <YOUR_API_KEY>
Update Nuclei templates:

nuclei -update-templates
Add API keys to ~/.config/subfinder/config.yaml

Configure /opt/reconftw/reconftw.cfg if needed

🧠 Author
Rudra Potghan
Cybersecurity Enthusiast | Bug Bounty Hunter
🔗 LinkedIn: [rudra-potghan](https://www.linkedin.com/in/rudra-potghan/)
📜 Medium: [@rudrapotghan.07](https://medium.com/@rudrapotghan.07)

🛡️ Disclaimer
This script is intended for educational and authorized security testing only.
Use responsibly and within the legal scope of your engagements.
