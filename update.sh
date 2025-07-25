#!/bin/bash

# ==========================================
# SCRIPT INSTALLASI LENGKAP UNTUK VPS
# INCLUDES: LIMIT-IP, MENU, CRON, PROFILE
# ==========================================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fungsi untuk menampilkan header
show_header() {
    clear
    echo -e "${BLUE}"
    echo -e "=========================================="
    echo -e "  AUTO INSTALL VPS MANAGER + LIMIT-IP     "
    echo -e "=========================================="
    echo -e "${NC}"
}

# Fungsi untuk mengecek root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}Error: Script ini harus dijalankan sebagai root!${NC}"
        exit 1
    fi
}

# Fungsi untuk install dependency
install_dependencies() {
    echo -e "${YELLOW}[*] Memeriksa dependencies...${NC}"
    
    if ! command -v wget &> /dev/null; then
        echo -e "${YELLOW}[*] Menginstall wget...${NC}"
        apt-get install -y wget || yum install -y wget
    fi
    
    if ! command -v curl &> /dev/null; then
        echo -e "${YELLOW}[*] Menginstall curl...${NC}"
        apt-get install -y curl || yum install -y curl
    fi
    
    if ! command -v 7z &> /dev/null; then
        echo -e "${YELLOW}[*] Menginstall p7zip...${NC}"
        apt-get install -y p7zip-full || yum install -y p7zip
    fi
}

# Fungsi untuk setup .profile
setup_profile() {
    echo -e "${YELLOW}[*] Setup .profile...${NC}"
    
    # Backup .profile lama jika ada
    [ -f "/root/.profile" ] && cp /root/.profile /root/.profile.bak
    
    # Buat .profile baru
    cat > /root/.profile <<'EOF'
if [ "$SHELL" = "/bin/bash" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
mesg n || true
welcome
EOF

    chmod 644 /root/.profile
}

# Fungsi untuk setup cron job
setup_cron() {
    echo -e "${YELLOW}[*] Setup cron jobs...${NC}"
    
    mkdir -p /etc/cron.d
    
    declare -A cron_jobs=(
        ["auto_update"]="15 1 * * * root /usr/local/sbin/auto_update"
        ["auto_update2"]="15 2 * * * root /usr/local/sbin/auto_update2"
        ["backup_otomatis"]="15 23 * * * root /usr/local/sbin/backupfile"
        ["delete_exp"]="0 3 */2 * * root /usr/local/sbin/xp"
    )
    
    for job in "${!cron_jobs[@]}"; do
        local cron_file="/etc/cron.d/$job"
        local cron_job="${cron_jobs[$job]}"
        
        if ! grep -Fq "$cron_job" "$cron_file" 2>/dev/null; then
            echo "$cron_job" > "$cron_file"
            chmod 644 "$cron_file"
            echo -e "${GREEN}[+] Cron job $job berhasil ditambahkan${NC}"
        fi
    done
}

# Fungsi untuk install limit-ip
install_limit_ip() {
    echo -e "${YELLOW}[*] Menginstall limit-ip...${NC}"
    
    local limit_ip_url="https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/Fls/limit-ip"
    local backup_file="/usr/bin/limit-ip.bak"
    
    [ -f "/usr/bin/limit-ip" ] && mv /usr/bin/limit-ip "$backup_file"
    
    if ! wget --no-check-certificate -q "$limit_ip_url" -O /usr/bin/limit-ip; then
        echo -e "${RED}[-] Gagal mendownload limit-ip${NC}"
        [ -f "$backup_file" ] && mv "$backup_file" /usr/bin/limit-ip
        return 1
    fi
    
    chmod +x /usr/bin/limit-ip
    echo -e "${GREEN}[+] limit-ip berhasil diinstall${NC}"
    return 0
}

# Fungsi res1 untuk download dan extract menu (dipertahankan sesuai permintaan)
res1() {
    echo -e "${YELLOW}[*] Mengupdate menu system...${NC}"
    
    if ! wget -q https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/bot1/menu.zip -O menu.zip; then
        echo -e "${RED}[-] Gagal mendownload menu.zip${NC}"
        return 1
    fi

    if ! 7z x -paiman321 -o menu menu.zip >/dev/null 2>&1; then
        echo -e "${RED}[-] Gagal mengekstrak menu.zip${NC}"
        return 1
    fi

    # Install ke /usr/local/sbin
    rm -rf /usr/local/sbin
    mkdir -p /usr/local/sbin
    mv menu/* /usr/local/sbin/
    chmod +x /usr/local/sbin/*
    rm -rf menu menu.zip
    
    echo -e "${GREEN}[+] Menu system berhasil diupdate${NC}"
    return 0
}

# Fungsi progress bar
fun_bar() {
    local CMD="$1"
    (
        $CMD >/dev/null 2>&1
        touch /tmp/selesai_update
    ) &
    
    tput civis
    echo -ne "  ${YELLOW}Please Wait Loading ${BLUE}- ${YELLOW}["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "${GREEN}#"
            sleep 0.1s
        done
        [ -e /tmp/selesai_update ] && break
        echo -e "${YELLOW}]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  ${YELLOW}Please Wait Loading ${BLUE}- ${YELLOW}["
    done
    rm -f /tmp/selesai_update
    echo -e "${YELLOW}]${BLUE} -${GREEN} OK !${NC}"
    tput cnorm
}

# Fungsi utama
main() {
    show_header
    check_root
    install_dependencies
    setup_profile
    setup_cron
    
    # Install limit-ip
    if install_limit_ip; then
        echo -e "${GREEN}[+] Limit-IP berhasil diinstall${NC}"
    else
        echo -e "${RED}[-] Gagal menginstall Limit-IP${NC}"
    fi
    
    # Update menu system dengan progress bar
    echo -e "${YELLOW}[*] Memulai update menu system...${NC}"
    fun_bar res1
    
    # Verifikasi akhir
    echo -e "\n${GREEN}"
    echo -e "=========================================="
    echo -e "  INSTALLASI BERHASIL DILAKUKAN!"
    echo -e "=========================================="
    echo -e "${NC}"
    
    # Jalankan menu jika tersedia
    if [ -f "/usr/local/sbin/menu" ]; then
        echo -e "${YELLOW}[*] Menjalankan menu...${NC}"
        /usr/local/sbin/menu
    fi
}

# Jalankan script utama
main
