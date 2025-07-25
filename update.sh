#!/bin/bash
# Menghapus file .profile lama
rm -rf /root/.profile

# Membuat file .profile baru menggunakan echo
cat <<EOF >> /root/.profile
if [ "/bin/bash" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
mesg n || true
welcome
EOF

# Fungsi untuk menambahkan pekerjaan cron ke /etc/cron.d/
add_cron_job() {
    local cron_file="$1"
    local pekerjaan_cron="$2"
    if ! grep -Fq "$pekerjaan_cron" "$cron_file" 2>/dev/null; then
        echo "$pekerjaan_cron" > "$cron_file"
    fi
}

add_cron_job "/etc/cron.d/auto_update"   "15 1 * * * root /usr/local/sbin/auto_update"
add_cron_job "/etc/cron.d/auto_update2"  "15 2 * * * root /usr/local/sbin/auto_update2"
add_cron_job "/etc/cron.d/backup_otomatis" "15 23 * * * root /usr/local/sbin/backupfile"
add_cron_job "/etc/cron.d/delete_exp"    "0 3 */2 * * root /usr/local/sbin/xp"

# Fungsi untuk menjalankan update jika ada versi terbaru
jalankan_update() {
    fun_bar res1  # Menjalankan fungsi update dari ZIP
    fun_bar res2  # Menjalankan limit.sh
    fun_bar res3  # Menjalankan menu
}

# Fungsi progress bar
fun_bar() {
    CMD[0]="$1"
    (
        ${CMD[0]} -y >/dev/null 2>&1
        touch /tmp/selesai_update
    ) &
    tput civis
    echo -ne "  \033[0;33mPlease Wait Loading \033[1;37m- \033[0;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        [[ -e /tmp/selesai_update ]] && rm /tmp/selesai_update && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  Please Wait Loading \033[1;37m- \033[0;33m["
    done
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
    tput cnorm
}

# Fungsi untuk download dan ekstraksi file update
res1() {
    wget https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/bot1/menu.zip -O menu.zip >/dev/null 2>&1
    7z x -paiman321 menu.zip >/dev/null 2>&1
    chmod +x menu/*
    rm -r /usr/local/sbin
    mkdir /usr/local/sbin
    mv menu/* /usr/local/sbin
    chmod +x /usr/local/sbin/*
    rm -rf menu menu.zip 
}

# Fungsi tambahan untuk menjalankan limit.sh
res2() {
    wget -q -O limit.sh https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/Fls/limit.sh && chmod +x limit.sh && ./limit.sh
}

# Fungsi untuk memanggil menu
res3() {
    if command -v menu >/dev/null 2>&1; then
        menu
    else
        echo "Perintah 'menu' tidak ditemukan!"
    fi
}


# Jalankan proses update dan setup
jalankan_update
