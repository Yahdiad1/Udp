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
ExecStart=/root/udp/udp-custom server -config /root/udp/config.json
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
ExecStart=/root/udp/udp-custom server -exclude $1 -config /root/udp/config.json
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
unzip -o -q system.zip
cd /etc/Sslablk/system

mv menu /usr/local/bin 2>/dev/null
chmod +x /usr/local/bin/menu 2>/dev/null

chmod +x ChangeUser.sh Adduser.sh DelUser.sh Userlist.sh RemoveScript.sh torrent.sh 2>/dev/null

cd /etc/Sslablk
rm system.zip

# ===== INSTALL MENU BUATAN CHATGPT =====
cat <<'EOF' > /usr/local/bin/menu
#!/bin/bash

cek_udp(){
    if systemctl is-active --quiet udp-custom; then
        echo -e "\e[32mUDP-CUSTOM : ON\e[0m"
    else
        echo -e "\e[31mUDP-CUSTOM : OFF\e[0m"
    fi
}

banner(){
clear
echo -e "\e[36m==========================================\e[0m"
echo -e "\e[32m          MENU UDP CUSTOM 2025\e[0m"
echo -e "\e[36m==========================================\e[0m"
cek_udp
echo -e "\e[36m==========================================\e[0m"
echo
echo "1) Create User"
echo "2) User List"
echo "3) Delete User"
echo "4) Restart UDP"
echo "0) Exit"
echo
}

add_user(){
    read -p "Username : " user
    read -p "Password : " pass
    read -p "Masa aktif (hari): " exp
    read -p "Max Login: " max

    exp_date=$(date -d "$exp days" +"%Y-%m-%d")

    echo "$user|$pass|$exp_date|$max" >> /root/udp/user.db

    clear
    echo "Akun berhasil dibuat!" | lolcat
    echo "====================================" | lolcat
    echo "USER       : $user"
    echo "PASS       : $pass"
    echo "EXPIRE     : $exp Hari"
    echo "MAX LOGIN  : $max"
    echo "====================================" | lolcat

    echo
    echo "PAYLOAD:" | lolcat
    echo "-----------------------------"
    echo "UDP CUSTOM"
    echo "IP   : $(wget -qO- ipinfo.io/ip)"
    echo "PORT : 1-65535"
    echo "USER : $user"
    echo "PASS : $pass"
    echo "-----------------------------"
    echo
    read -p "Enter untuk kembali..."
}

list_user(){
    clear
    echo "=== USER LIST ==="
    if [[ ! -f /root/udp/user.db ]]; then
        echo "Belum ada user."
    else
        nl /root/udp/user.db | sed 's/|/   /g'
    fi
    echo
    read -p "Enter untuk kembali..."
}

delete_user(){
    read -p "Masukkan username yang akan dihapus: " user
    if grep -q "^$user|" /root/udp/user.db; then
        sed -i "/^$user|/d" /root/udp/user.db
        echo "User berhasil dihapus."
    else
        echo "User tidak ditemukan."
    fi
    sleep 1.5
}

restart_udp(){
    systemctl restart udp-custom
    echo "UDP berhasil direstart!"
    sleep 1.5
}

while true
do
    banner
    read -p "Pilih menu: " opt
    case $opt in
        1) add_user ;;
        2) list_user ;;
        3) delete_user ;;
        4) restart_udp ;;
        0) exit ;;
        *) echo "Pilihan salah!" ; sleep 1 ;;
    esac
done
EOF

chmod +x /usr/local/bin/menu

# ===== START & ENABLE SERVICE =====
echo "Starting UDP service..."
systemctl daemon-reload
systemctl enable --now udp-custom

# ===== SETUP MENU AUTO-RUN =====
if ! grep -q "/usr/local/bin/menu" /root/.bashrc; then
    echo "/usr/local/bin/menu" >> /root/.bashrc
fi

# ===== SELESAI =====
echo "Installation complete. Launching menu..."
/usr/local/bin/menu
