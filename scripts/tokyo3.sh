#!/bin/sh
# ==============================================================================
# /root/tokyo3.sh - Soal 8: Setup Layanan Tokyo3-Core
#   TCP 80   -> Welcome to {hostname}
#   TCP 8080 -> syifa imutz
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Tokyo3-Core: 192.212.4.106/30 | Gateway: 192.212.4.105 (Gendou)
#
# Penggunaan:
#   sh /root/tokyo3.sh               # Install paket + jalankan listener 80 & 8080
#   sh /root/tokyo3.sh --listen-only # Jalankan ulang listener saja (tanpa apt)
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Tokyo3-Core] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

# Buat responder port 80 & port 8080
cat << 'EOF' > /root/reply_80.sh
#!/bin/sh
printf "Welcome to %s\n" "$(hostname)"
EOF
cat << 'EOF' > /root/reply_8080.sh
#!/bin/sh
printf "syifa imutz\n"
EOF
chmod +x /root/reply_80.sh /root/reply_8080.sh

start_responder() {
    port="$1"
    handler="$2"
    if [ -f "/tmp/srv-${port}.pid" ]; then
        kill "$(cat "/tmp/srv-${port}.pid")" 2>/dev/null || true
    fi
    pkill -f "nc -l -p ${port}" 2>/dev/null || true
    (
        while true; do
            nc -l -p "$port" -e "$handler" >/dev/null 2>&1
            sleep 0.1 2>/dev/null || sleep 1
        done
    ) </dev/null >/dev/null 2>&1 &
    echo $! > "/tmp/srv-${port}.pid"
}

start_responder 80 /root/reply_80.sh
start_responder 8080 /root/reply_8080.sh

echo "[OK] Tokyo3-Core (192.212.4.106) aktif:"
echo "     - TCP 80   -> Welcome to $(hostname)"
echo "     - TCP 8080 -> syifa imutz"
