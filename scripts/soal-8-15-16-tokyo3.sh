#!/bin/sh
# ==============================================================================
# /root/tokyo3.sh - Soal 8 + 15 + 16: Layanan & Firewall Tokyo3-Core
#   TCP 80        -> Welcome to {hostname}
#   TCP 8080      -> syifa imutz
#   Soal 15       -> Rate limit ICMP echo-request masuk maks 5/detik (DROP sisanya)
#   Soal 16       -> Dummy-Plug (192.212.4.51) ke port 22,23,3306: LOG "SCAN-NERV:" + REJECT RST
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Tokyo3-Core: 192.212.4.106/30 | Gateway: 192.212.4.105 (Gendou)
# ==============================================================================

set -u

DUMMY_PLUG_IP="192.212.4.51"

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ] && [ "${1:-}" != "--fw-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Tokyo3-Core] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

start_responders() {
    cat << 'EOF' > /root/reply_80.sh
#!/bin/sh
printf "Welcome to %s\n" "$(hostname)"
EOF
    cat << 'EOF' > /root/reply_8080.sh
#!/bin/sh
printf "syifa imutz\n"
EOF
    chmod +x /root/reply_80.sh /root/reply_8080.sh

    for port in 80 8080; do
        handler="/root/reply_${port}.sh"
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
    done
}

apply_firewall() {
    iptables -F
    iptables -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Soal 15: Batasi ICMP echo-request masuk maks 5/detik; ping keluar dari Tokyo3-Core tidak dibatasi
    iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/sec --limit-burst 5 -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

    # Soal 16: Catat percobaan TCP SYN dari Dummy-Plug ke port 22, 23, 3306 lalu tolak seketika
    iptables -A INPUT -s "$DUMMY_PLUG_IP" -p tcp --syn -m multiport --dports 22,23,3306 -j LOG --log-prefix "SCAN-NERV: "
    iptables -A INPUT -s "$DUMMY_PLUG_IP" -p tcp -m multiport --dports 22,23,3306 -j REJECT --reject-with tcp-reset
}

if [ "${1:-}" = "--fw-only" ]; then
    apply_firewall
elif [ "${1:-}" = "--listen-only" ]; then
    start_responders
    apply_firewall
else
    start_responders
    apply_firewall
fi

echo "[OK] Tokyo3-Core (192.212.4.106) aktif (layanan 80/8080 + firewall Soal 15 & 16)."