#!/bin/sh
# ==============================================================================
# /root/melchior.sh - Soal 7: Setup Magi-Melchior (iptables, netcat-traditional, TCP 5000)
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Magi-Melchior: 192.212.4.60/29 | Gateway: 192.212.4.57 (Fuyutsuki)
#
# Penggunaan:
#   sh /root/melchior.sh               # Install paket + jalankan listener TCP 5000
#   sh /root/melchior.sh --listen-only # Langsung jalankan ulang listener (tanpa apt)
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Magi-Melchior] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

if [ -f /tmp/magi-5000.pid ]; then
    kill "$(cat /tmp/magi-5000.pid)" 2>/dev/null || true
fi
pkill -f "nc -l -p 5000" 2>/dev/null || true

: >> /tmp/magi-5000.log

(
    while true; do
        nc -l -p 5000 >> /tmp/magi-5000.log 2>&1
        sleep 0.1 2>/dev/null || sleep 1
    done
) </dev/null >/dev/null 2>&1 &
echo $! > /tmp/magi-5000.pid

echo "[OK] Magi-Melchior (192.212.4.60) siap melayani TCP port 5000."
echo "     Lihat pesan masuk: cat /tmp/magi-5000.log"
