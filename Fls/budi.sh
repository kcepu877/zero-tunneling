#!/bin/bash

echo "[🔍] Mengecek user dengan UID 0 selain 'root'..."
UID0_USERS=$(awk -F: '($3 == 0) { print $1 }' /etc/passwd | grep -v '^root$')

if [[ -z "$UID0_USERS" ]]; then
    echo "[✅] Tidak ditemukan user backdoor dengan UID 0 selain root."
    exit 0
fi

echo "[⚠️] Ditemukan user backdoor: $UID0_USERS"
for user in $UID0_USERS; do
    echo "[🔒] Mengunci akun $user..."
    usermod -L "$user"
    usermod -s /usr/sbin/nologin "$user"

    echo "[✏️] Mengubah UID dan GID user $user ke 1001..."
    sed -i "s/^$user:x:0:0:/$user:x:1001:1001:/" /etc/passwd

    echo "[🧹] Menghapus user $user beserta home dir..."
    deluser --remove-home "$user"
done

echo "[✅ SELESAI] Semua user backdoor UID 0 telah dinonaktifkan dan dihapus."
