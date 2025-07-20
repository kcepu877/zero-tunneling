#!/bin/bash
echo "[INFO] Menutup semua koneksi UDP dari user 'budi'..."

for pid in $(sudo lsof -nP -iUDP | grep budi | awk '{print $2}' | sort -u); do
    echo "[INFO] Membunuh PID $pid"
    sudo kill -9 $pid
done

echo "[SELESAI] Semua koneksi UDP dari user 'budi' telah dihentikan."
