#!/bin/bash

# Function to create new .profile
create_profile() {
    # Remove old .profile
    rm -f /root/.profile

    # Create new .profile with heredoc for better readability
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

# Function to add cron job
add_cron_job() {
    local cron_file="/etc/cron.d/$1"
    local job="$2"
    
    # Create cron.d directory if not exists
    mkdir -p /etc/cron.d
    
    # Add job if not already exists
    if ! grep -Fq "$job" "$cron_file" 2>/dev/null; then
        echo "$job" >> "$cron_file"
        chmod 644 "$cron_file"
    fi
}

# Function to show progress bar
fun_bar() {
    local CMD="$1"
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
        [ -e /tmp/selesai_update ] && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  Please Wait Loading \033[1;37m- \033[0;33m["
    done
    rm -f /tmp/selesai_update
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
    tput cnorm
    echo -e ""
}

# Function to download and extract updates
res1() {
    # Download and extract menu
    if ! wget -q https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/bot1/menu.zip -O menu.zip; then
        echo "Failed to download menu.zip"
        return 1
    fi

    if ! 7z x -paiman321 -o menu menu.zip >/dev/null 2>&1; then
        echo "Failed to extract menu.zip"
        return 1
    fi

    # Install to /usr/local/sbin
    rm -rf /usr/local/sbin
    mkdir -p /usr/local/sbin
    mv menu/* /usr/local/sbin/
    chmod +x /usr/local/sbin/*
    rm -rf menu menu.zip
}

# Function to install limit-ip
install_limit_ip() {
    clear
    if wget -q https://raw.githubusercontent.com/kcepu877/zero-tunneling/main/Fls/limit.sh && chmod +x limit.sh && ./limit.sh
        clear
        echo -e ""
        echo -e "\033[96m==========================\033[0m"
        echo -e "\033[92m   INSTALL UPDATE SUCCESS  \033[0m"
        echo -e "\033[96m==========================\033[0m"
        echo -e ""
        sleep 1
        return 0
    else
        echo "Failed to download limit-ip"
        return 1
    fi
}

# Main execution
main() {
    # Check if running as root
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root"
        exit 1
    fi

    # Create profile
    create_profile

    # Add cron jobs
    add_cron_job "auto_update" "15 1 * * * root /usr/local/sbin/auto_update"
    add_cron_job "auto_update2" "15 2 * * * root /usr/local/sbin/auto_update2"
    add_cron_job "backup_otomatis" "15 23 * * * root /usr/local/sbin/backupfile"
    add_cron_job "delete_exp" "0 3 */2 * * root /usr/local/sbin/xp"

    # Install limit-ip
    if install_limit_ip; then
        # Run updates if available
        fun_bar res1
    fi

    # Return to menu if exists
    if command -v menu &>/dev/null; then
        menu
    fi
}

# Start script execution
main
