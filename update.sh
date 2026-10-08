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


# Fungsi untuk menjalankan update jika ada versi terbaru
jalankan_update() {
fun_bar res1  # Menjalankan fungsi update jika versi baru terdeteksi
fun_bar res2  # Menjalankan fungsi tambahan res2
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
    local ZIP_URL="https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/Cfg/menu.zip"
    local ZIP_FILE="/tmp/menu_update.zip"
    local TMP_DIR="/tmp/menu_update_extract"
    local DEST_DIR="/usr/local/sbin"

    echo "Downloading update..."

    # Download ZIP
    if ! wget -q "$ZIP_URL" -O "$ZIP_FILE"; then
        echo "ERROR: Gagal download menu.zip"
        return 1
    fi

    # Bersihkan temporary directory
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    # Extract ZIP
    if ! 7z x -y -pkcepu877 "$ZIP_FILE" -o"$TMP_DIR" >/dev/null 2>&1; then
        echo "ERROR: Gagal extract menu.zip"
        rm -rf "$ZIP_FILE" "$TMP_DIR"
        return 1
    fi

    echo "Update berhasil di-download."
    echo "Mencari semua file di dalam folder menu..."

    # Cari folder bernama "menu", lalu ambil SEMUA FILE di dalamnya
    # Termasuk file yang namanya "menu".
    find "$TMP_DIR" -type f -path "*/menu/*" -print0 |
    while IFS= read -r -d '' file; do
        filename="$(basename "$file")"

        echo "  -> $filename"

        # Pindahkan file ke /usr/local/sbin
        mv -f "$file" "$DEST_DIR/$filename"
    done

    # Berikan permission executable
    chmod +x "$DEST_DIR"/* 2>/dev/null

    # Bersihkan temporary
    rm -rf "$ZIP_FILE" "$TMP_DIR"

    echo " [ UPDATE FILE SELESAI ]"
}

# Fungsi tambahan untuk menjalankan limit.sh
res2() {
wget -q -O limit.sh https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/Fls/limit.sh && chmod +x limit.sh && ./limit.sh
sleep 3
menu
}

# Cek dan jalankan update jika ada
jalankan_update
sleep 3
echo " [ PROSES UPDATE SELESAI ] "
menu

