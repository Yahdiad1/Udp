#!/bin/bash

# ===== UPDATE & INSTALL TOOLS =====
apt update -y
apt upgrade -y
apt install lolcat figlet neofetch screenfetch unzip wget -y

# ===== SIAPKAN FOLDER UDP =====
cd
rm -rf /root/udp
mkdir -p /root/udp

# ===== SET TIMEZONE =====
echo "Changing timezone to Asia/Jakarta"
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# ===== INSTALL UDP-CUSTOM =====
echo "Downloading udp-custom..."
wget -q "https://github.com/scriswan/udp/raw/main/udp-custom-linux-amd64" -O /root/udp/udp-custom
chmod +x /root/udp/udp-custom

# ===== DOWNLOAD DEFAULT CONFIG =====
echo "Downloading default config..."
wget -q "https://raw.githubusercontent.com/scriswan/udp/main/config.json" -O /root/udp/config.json
chmod 644 /root/udp/config.json

# ===== BUAT SYSTEMD SERVICE =====
if [ -z "$1" ]; then
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team (modified by sslablk)

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
else
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team (modified by sslablk)

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server -exclude $1
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
fi

# ===== INSTALL MENU & SCRIPT TAMBAHAN =====
echo "Installing additional scripts..."
mkdir -p /etc/Sslablk
cd /etc/Sslablk
wget -q https://github.com/scriswan/udp/raw/main/system.zip
unzip -o -q system.zip   # otomatis ekstrak tanpa menekan Y
cd /etc/Sslablk/system

# Pindahkan menu ke /usr/local/bin
mv menu /usr/local/bin
chmod +x /usr/local/bin/menu

# Set executable untuk script lain
chmod +x ChangeUser.sh Adduser.sh DelUser.sh Userlist.sh RemoveScript.sh torrent.sh

# Bersihkan file zip
cd /etc/Sslablk
rm system.zip

# ===== START & ENABLE SERVICE =====
echo "Starting UDP service..."
systemctl daemon-reload
systemctl enable --now udp-custom

# ===== SETUP MENU AUTO-RUN =====
echo "Setting up menu auto-run..."
if ! grep -q "/usr/local/bin/menu" /root/.bashrc; then
    echo "/usr/local/bin/menu" >> /root/.bashrc
fi

# ===== SELESAI =====
echo "Installation complete. Launching menu..."
/usr/local/bin/menu