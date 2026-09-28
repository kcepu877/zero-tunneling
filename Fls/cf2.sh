#!/bin/bash
apt install jq curl -y
sub=$(cat /root/domain)
sub2=$(tr </dev/urandom -dc a-z0-9 | head -c4)
DOMAIN="vpn-premium.web.id"

if [ -z "$sub" ]; then
    sub="${sub2}"
fi

CF_ID="epan.k877@gmail.com"
CF_KEY="f394f21465c5bbef544d56d9bea8041a15194"
IP=$(wget -qO- icanhazip.com);

set -euo pipefail

echo "Memperbarui DNS untuk ${sub}.${DOMAIN}..."

ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r .result[0].id)

if [ -z "$ZONE" ]; then
    echo "Error: Zone ID tidak ditemukan"
    exit 1
fi

RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${sub}.${DOMAIN}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r .result[0].id)

if [[ "${#RECORD}" -le 10 ]]; then
    RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"'${sub}.${DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
fi

if [ -z "$RECORD" ]; then
    echo "Error: Pembuatan catatan DNS gagal"
    exit 1
fi

RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${sub}.${DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}')

if [ "$(echo $RESULT | jq -r .success)" != "true" ]; then
    echo "Error: Pembaruan catatan DNS gagal"
    exit 1
fi

echo "Host: ${sub}.${DOMAIN}"
rm -rf /etc/xray/domain
rm -rf /root/domain
rm -rf /var/lib/kyt/ipvps.conf
echo "${sub}.${DOMAIN}" > /etc/xray/domain
echo ${sub}.${DOMAIN} > /root/domain
echo "IP=${sub}.${DOMAIN}" > /var/lib/kyt/ipvps.conf
#rm -f /root/cf.sh # Opsional: Dihapus untuk keamanan
