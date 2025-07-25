#!/bin/bash

# Membuat ulang /root/.profile
create_profile() {
    rm -f /root/.profile
    cat > /root/.profile <<'EOF'
if [ "$SHELL" = "/bin/bash" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
mesg n || true
welcome
EOF
}

# Menambahkan cron job
add_cron_job() {
    local cron_file="/etc/cron.d/$1"
    local job="$2"
    mkdir -p /etc/cron.d
    if ! grep -Fq "$job" "$cron_file" 2>/dev/null; then
        echo "$job" >> "$cron_file"
        chmod 644 "$cron_file"
    fi
}

# Menampilkan progress bar selama proses berjalan
fun_bar() {
    local FUNC="$1"
    (
        $FUNC >/dev/null 2>&1
        touch /tmp/selesai_update
    ) &
    tput civis
    echo -ne "  \033[0;33mPlease Wait Loading \033[1;37m- \033[0;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        [ -e /tmp/selesai_update ] && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  \033[0;33mPlease Wait Loading \033[1;37m- \033[0;33m["
    done
    rm -f /tmp/selesai_update
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
    tput cnorm
    echo -e ""
}

# Mengunduh dan memasang menu
res1() {
    wget -q https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/bot1/menu.zip -O menu.zip
    if [ ! -f menu.zip ]; then
        echo "❌ Gagal mengunduh menu.zip"
        return 1
    fi

    if ! 7z x -paiman321 -omenu menu.zip >/dev/null 2>&1; then
        echo "❌ Gagal mengekstrak menu.zip"
        rm -f menu.zip
        return 1
    fi

    rm -rf /usr/local/sbin
    mkdir -p /usr/local/sbin
    mv menu/* /usr/local/sbin/
    chmod +x /usr/local/sbin/*
    rm -rf menu menu.zip
}

# Mengunduh dan menjalankan script limit-ip
install_limit_ip() {
    clear
    if wget -q -O limit.sh https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/Fls/limit.sh && chmod +x limit.sh && ./limit.sh; then
        echo -e "\n\033[96m==========================\033[0m"
        echo -e "\033[92m   INSTALL UPDATE SUCCESS  \033[0m"
        echo -e "\033[96m==========================\033[0m\n"
        sleep 1
        return 0
    else
        echo "❌ Gagal memasang limit-ip"
        return 1
    fi
}

# Main script
main() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Script ini harus dijalankan sebagai root"
        exit 1
    fi

    create_profile

    # Tambahkan cron jobs
    add_cron_job "auto_update"     "15 1 * * * root /usr/local/sbin/auto_update"
    add_cron_job "auto_update2"    "15 2 * * * root /usr/local/sbin/auto_update2"
    add_cron_job "backup_otomatis" "15 23 * * * root /usr/local/sbin/backupfile"
    add_cron_job "delete_exp"      "0 3 */2 * * root /usr/local/sbin/xp"

    if install_limit_ip; then
        fun_bar res1
    fi

    # Jalankan menu jika tersedia
    if command -v menu &>/dev/null; then
        menu
    fi
}

main
