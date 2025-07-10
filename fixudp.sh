#!/bin/bash

echo "🔧 Memperbaiki UDP-Custom..."

# Stop dan hapus service lama
systemctl stop udp-custom 2>/dev/null
systemctl disable udp-custom 2>/dev/null
rm -f /etc/systemd/system/udp-custom.service

# Hapus file lama
rm -rf /root/udp
mkdir -p /root/udp

# Unduh ulang binary udp-custom
echo "⬇️ Mengunduh ulang udp-custom..."
wget -q --show-progress --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt \
--keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1_VyhL5BILtoZZTW4rhnUiYzc4zHOsXQ8' -O- \
| sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1_VyhL5BILtoZZTW4rhnUiYzc4zHOsXQ8" \
-O /root/udp/udp-custom && rm -rf /tmp/cookies.txt

chmod +x /root/udp/udp-custom

# Unduh config default
echo "⬇️ Mengunduh config.json..."
wget -q --show-progress --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt \
--keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1_XNXsufQXzcTUVVKQoBeX5Ig0J7GngGM' -O- \
| sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1_XNXsufQXzcTUVVKQoBeX5Ig0J7GngGM" \
-O /root/udp/config.json && rm -rf /tmp/cookies.txt

chmod 644 /root/udp/config.json

# Buat ulang service systemd
echo "🛠️ Membuat ulang service udp-custom..."
cat > /etc/systemd/system/udp-custom.service << EOF
[Unit]
Description=UDP Custom by Tunneling Official
After=network.target

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan jalankan
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable udp-custom
systemctl restart udp-custom

# Cek status
if systemctl is-active --quiet udp-custom; then
    echo "✅ UDP-Custom berhasil diperbaiki dan dijalankan!"
else
    echo "❌ Gagal menjalankan UDP-Custom. Periksa log atau config.json."
fi
