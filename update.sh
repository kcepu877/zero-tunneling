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
  echo 'welcome' >> /root/.profile          # Menjalankan perintah 'welcome'

# Fungsi untuk menambahkan pekerjaan cron ke /etc/cron.d/
    cron_file="/etc/cron.d/auto_update"
    pekerjaan_cron="15 1 * * * root /usr/local/sbin/auto_update"

    # Periksa apakah pekerjaan cron sudah ada di file
    if ! grep -Fq "$pekerjaan_cron" "$cron_file" 2>/dev/null; then
        echo "$pekerjaan_cron" > "$cron_file"
    fi

# Fungsi untuk menambahkan pekerjaan cron ke /etc/cron.d/
    cron_file="/etc/cron.d/auto_update2"
    pekerjaan_cron="15 2 * * * root /usr/local/sbin/auto_update2"

    # Periksa apakah pekerjaan cron sudah ada di file
    if ! grep -Fq "$pekerjaan_cron" "$cron_file" 2>/dev/null; then
        echo "$pekerjaan_cron" > "$cron_file"
    fi

# Fungsi untuk menambahkan pekerjaan cron ke /etc/cron.d/
    cron_file="/etc/cron.d/backup_otomatis"
    pekerjaan_cron="15 23 * * * root /usr/local/sbin/backupfile"

    # Periksa apakah pekerjaan cron sudah ada di file
    if ! grep -Fq "$pekerjaan_cron" "$cron_file" 2>/dev/null; then
        echo "$pekerjaan_cron" > "$cron_file"
    fi

# Fungsi untuk menambahkan pekerjaan cron ke /etc/cron.d/
    cron_file="/etc/cron.d/delete_exp"
    pekerjaan_cron="0 3 */2 * * root /usr/local/sbin/xp"

    # Periksa apakah pekerjaan cron sudah ada di file
    if ! grep -Fq "$pekerjaan_cron" "$cron_file" 2>/dev/null; then
        echo "$pekerjaan_cron" > "$cron_file"
    fi


jalankan_update() {
    fun_bar res1 "loading"     # res1 tampilkan loading progress bar sebenarnya
}



# Fungsi progress bar
fun_bar() {
    CMD="$1"
    MODE="$2"  # mode opsional: "loading" (default) atau "instant"

    if [[ "$MODE" == "instant" ]]; then
        # Jalankan perintah tanpa progress bar
        $CMD -y >/dev/null 2>&1
        echo -e "\033[0;32m✔ SELESAI Semua user backdoor UID 0 telah dinonaktifkan dan dihapus.\033[0m"
        echo -e "\033[96m==========================\033[0m"
        echo -e "\033[92m      INSTALL SUCCESS     \033[0m"
        echo -e "\033[96m==========================\033[0m"
        echo
        return
    fi

    # Mode loading (default)
    (
        $CMD -y >/dev/null 2>&1
        touch /tmp/selesai_update
    ) &

    tput civis
    echo -ne "  \033[0;33mPlease Wait Loading \033[1;37m- \033[0;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        if [[ -e /tmp/selesai_update ]]; then
            rm -f /tmp/selesai_update
            break
        fi
        echo -e "\033[0;33m]"
        sleep 0.2
        tput cuu1
        tput dl1
        echo -ne "  Please Wait Loading \033[1;37m- \033[0;33m["
    done
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m OK !\033[0m"
    tput cnorm
    echo
}


# Fungsi untuk download dan ekstraksi file update
res1() {
# Clear and recreate /usr/local/sbin
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

if [[ -x "$(command -v menu)" ]]; then
    sleep 3
    menu
else
    echo "Perintah 'menu' tidak ditemukan. Apakah file 'menu' sudah diinstal ke /usr/local/sbin/?"
fi
