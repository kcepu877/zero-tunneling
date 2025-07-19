#!/bin/bash
# Menghapus file .profile lama
rm -rf /root/.profile

# Membuat file .profile baru menggunakan echo
echo 'if [ "/bin/bash" ]; then' >> /root/.profile
echo '  if [ -f ~/.bashrc ]; then' >> /root/.profile
echo '    . ~/.bashrc' >> /root/.profile  # Mengaktifkan .bashrc jika ada
echo '  fi' >> /root/.profile
echo 'fi' >> /root/.profile
echo 'mesg n || true' >> /root/.profile   # Menonaktifkan pesan 'mesg'

# Fungsi untuk menambahkan pekerjaan cron ke /etc/cron.d/
cron_file="/etc/cron.d/auto_update"
pekerjaan_cron="15 1 * * * root /usr/local/sbin/auto_update"

# Periksa apakah pekerjaan cron sudah ada di file
if ! grep -Fq "$pekerjaan_cron" "$cron_file" 2>/dev/null; then
    echo "$pekerjaan_cron" > "$cron_file"
fi

cron_file="/etc/cron.d/auto_update2"
pekerjaan_cron="15 2 * * * root /usr/local/sbin/auto_update2"

if ! grep -Fq "$pekerjaan_cron" "$cron_file" 2>/dev/null; then
    echo "$pekerjaan_cron" > "$cron_file"
fi

cron_file="/etc/cron.d/backup_otomatis"
pekerjaan_cron="15 23 * * * root /usr/local/sbin/backupfile"

if ! grep -Fq "$pekerjaan_cron" "$cron_file" 2>/dev/null; then
    echo "$pekerjaan_cron" > "$cron_file"
fi

# Fungsi untuk menjalankan update jika ada versi terbaru
jalankan_update() {
    fun_bar res1  # Menjalankan fungsi update jika versi baru terdeteksi
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
    7z x -paiman321 menu.zip
    chmod +x menu/*
    rm -r /usr/local/sbin
    mkdir /usr/local/sbin
    mv menu/* /usr/local/sbin
    chmod +x /usr/local/sbin*
    rm -rf menu menu.zip 
}

# Cek dan jalankan update jika ada
jalankan_update
