#!/bin/sh
# ==============================================================================
# /root/penpen.sh - Soal 8: Setup Layanan Pen-Pen (TCP 80 -> Welcome to {hostname})
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Pen-Pen: 192.212.3.194/27 | Gateway: 192.212.3.193 (Maya)
#
# Penggunaan:
#   sh /root/penpen.sh               # Install paket + jalankan listener TCP 80
#   sh /root/penpen.sh --listen-only # Jalankan ulang listener saja (tanpa apt)
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Pen-Pen] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

# Buat responder port 80
cat << 'EOF' > /root/reply_80.sh
#!/bin/sh
printf "Welcome to %s\n" "$(hostname)"
EOF
chmod +x /root/reply_80.sh

# Hentikan listener lama jika ada
if [ -f /tmp/srv-80.pid ]; then
    kill "$(cat /tmp/srv-80.pid)" 2>/dev/null || true
fi
pkill -f "nc -l -p 80" 2>/dev/null || true

# Jalankan listener TCP 80 persisten (menjawab langsung lalu tutup koneksi)
(
    while true; do
        nc -l -p 80 -e /root/reply_80.sh >/dev/null 2>&1
        sleep 0.1 2>/dev/null || sleep 1
    done
) </dev/null >/dev/null 2>&1 &
echo $! > /tmp/srv-80.pid

echo "[OK] Pen-Pen (192.212.3.194) aktif di TCP 80 -> menjawab: Welcome to $(hostname)"
