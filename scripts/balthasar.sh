#!/bin/sh
# ==============================================================================
# /root/balthasar.sh - Soal 7: Setup Magi-Balthasar (iptables, netcat-traditional, TCP 5000 & 5001)
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Magi-Balthasar: 192.212.4.59/29 | Gateway: 192.212.4.57 (Fuyutsuki)
#
# Penggunaan:
#   sh /root/balthasar.sh               # Install paket + jalankan listener TCP 5000 & 5001
#   sh /root/balthasar.sh --listen-only # Langsung jalankan ulang listener (tanpa apt)
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Magi-Balthasar] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

start_port() {
    p="$1"
    if [ -f "/tmp/magi-${p}.pid" ]; then
        kill "$(cat "/tmp/magi-${p}.pid")" 2>/dev/null || true
    fi
    pkill -f "nc -l -p ${p}" 2>/dev/null || true
    : >> "/tmp/magi-${p}.log"
    (
        while true; do
            nc -l -p "$p" >> "/tmp/magi-${p}.log" 2>&1
            sleep 0.1 2>/dev/null || sleep 1
        done
    ) </dev/null >/dev/null 2>&1 &
    echo $! > "/tmp/magi-${p}.pid"
}

start_port 5000
start_port 5001

echo "[OK] Magi-Balthasar (192.212.4.59) siap melayani TCP port 5000 dan 5001."
echo "     Lihat pesan masuk: cat /tmp/magi-5000.log && cat /tmp/magi-5001.log"
