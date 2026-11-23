#!/bin/sh
# ==============================================================================
# soal-2-router-ip.sh - Soal 2: IP Interface & IPv4 Forwarding Semua 17 Router
# Praktikum Jarkom Modul 5 - Kelompok K-02 (Prefix: 192.212.x.x)
#
# Penggunaan:
#   sh /root/soal-2-router-ip.sh              # Otomatis deteksi hostname
#   sh /root/soal-2-router-ip.sh Gendou       # Paksa nama router tertentu
#   sh /root/soal-2-router-ip.sh --ping-links # Uji ping ke semua peer link router
# ==============================================================================

set -u

MODE="setup"
NODE_ARG=""
if [ "${1:-}" = "--ping-links" ]; then
    MODE="ping"
    NODE_ARG="${2:-}"
else
    NODE_ARG="${1:-}"
fi

NODE_RAW="${NODE_ARG:-$(hostname)}"
NODE=$(printf '%s' "$NODE_RAW" | tr '[:upper:]' '[:lower:]')

enable_fwd() {
    sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || echo 1 > /proc/sys/net/ipv4/ip_forward
    mkdir -p /etc/sysctl.d 2>/dev/null || true
    echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ipforward.conf 2>/dev/null || true
}

set_if() {
    ip addr replace "$2" dev "$1"
    ip link set "$1" up
}

ping_peer() {
    printf "  -> Ping %-14s (%s): " "$1" "$2"
    if ping -c 2 -W 2 "$2" >/dev/null 2>&1; then
        echo "OK"
    else
        echo "GAGAL"
    fi
}

if [ "$MODE" = "ping" ]; then
    echo "=== [Soal 2] Uji Ping Link Router-ke-Router dari $NODE_RAW ==="
    case "$NODE" in
        *gendo*)
            ping_peer "Yui"       192.212.4.110
            ping_peer "Hikari"    192.212.4.114
            ping_peer "Asuka"     192.212.4.118
            ping_peer "Kaji"      192.212.4.122
            ping_peer "Misato"    192.212.4.126
            ping_peer "Shigeru"   192.212.4.130
            ping_peer "Fuyutsuki" 192.212.4.134
            ;;
        *yui*)
            ping_peer "Gendou" 192.212.4.109
            ping_peer "Rei"    192.212.4.138
            ping_peer "Shinji" 192.212.4.142
            ping_peer "Mari"   192.212.4.146
            ;;
        *hikari*)
            ping_peer "Gendou" 192.212.4.113
            ping_peer "Kaworu" 192.212.4.150
            ;;
        *asuka*)
            ping_peer "Gendou"  192.212.4.117
            ping_peer "Kensuke" 192.212.4.154
            ping_peer "Ritsuko" 192.212.4.158
            ;;
        *kaji*)      ping_peer "Gendou"    192.212.4.121 ;;
        *misato*)    ping_peer "Gendou"    192.212.4.125 ;;
        *shigeru*)
            ping_peer "Gendou" 192.212.4.129
            ping_peer "Makoto" 192.212.4.170
            ;;
        *fuyutsuki*)
            ping_peer "Gendou" 192.212.4.133
            ping_peer "Maya"   192.212.4.162
            ping_peer "Toji"   192.212.4.166
            ;;
        *rei*)       ping_peer "Yui"       192.212.4.137 ;;
        *shinji*)    ping_peer "Yui"       192.212.4.141 ;;
        *mari*)      ping_peer "Yui"       192.212.4.145 ;;
        *kaworu*)    ping_peer "Hikari"    192.212.4.149 ;;
        *kensuke*)   ping_peer "Asuka"     192.212.4.153 ;;
        *ritsuko*)   ping_peer "Asuka"     192.212.4.157 ;;
        *maya*)      ping_peer "Fuyutsuki" 192.212.4.161 ;;
        *toji*)      ping_peer "Fuyutsuki" 192.212.4.165 ;;
        *makoto*)    ping_peer "Shigeru"   192.212.4.169 ;;
        *) echo "Router '$NODE_RAW' tidak dikenali."; exit 1 ;;
    esac
    exit 0
fi

echo "=== [Soal 2] Setup IP Interface & IPv4 Forwarding pada Router: $NODE_RAW ==="
enable_fwd

case "$NODE" in
    *gendo*)
        ip link set eth0 up
        if ! ip -4 addr show dev eth0 | grep -q "inet "; then
            if ! command -v dhclient >/dev/null 2>&1 && ! command -v udhcpc >/dev/null 2>&1; then
                echo "[+] dhclient belum ada di debinet, pasang isc-dhcp-client lewat NAT1..."
                ip addr replace 192.168.122.100/24 dev eth0
                ip route replace default via 192.168.122.1
                printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
                apt-get update -qq && apt-get install -y -qq isc-dhcp-client
                ip addr flush dev eth0
            fi
            dhclient -1 eth0 2>/dev/null || udhcpc -i eth0 -n -q 2>/dev/null || true
            if ! ip -4 addr show dev eth0 | grep -q "inet "; then
                echo "[!] DHCP NAT1 tidak merespons, fallback ke 192.168.122.212/24 via 192.168.122.1"
                ip addr replace 192.168.122.212/24 dev eth0
                ip route replace default via 192.168.122.1 dev eth0
            fi
        fi
        set_if eth1 192.212.4.105/30
        set_if eth2 192.212.4.109/30
        set_if eth3 192.212.4.113/30
        set_if eth4 192.212.4.117/30
        set_if eth5 192.212.4.121/30
        set_if eth6 192.212.4.125/30
        set_if eth7 192.212.4.129/30
        set_if eth8 192.212.4.133/30
        ;;
    *yui*)
        set_if eth0 192.212.4.110/30
        set_if eth1 192.212.3.1/25
        set_if eth2 192.212.4.137/30
        set_if eth3 192.212.4.141/30
        set_if eth4 192.212.4.145/30
        ;;
    *hikari*)
        set_if eth0 192.212.4.114/30
        set_if eth1 192.212.2.1/24
        set_if eth2 192.212.4.149/30
        ;;
    *asuka*)
        set_if eth0 192.212.4.118/30
        set_if eth1 192.212.4.97/30
        set_if eth2 192.212.4.153/30
        set_if eth3 192.212.4.157/30
        ;;
    *kaji*)
        set_if eth0 192.212.4.122/30
        set_if eth1 192.212.4.101/30
        ;;
    *misato*)
        set_if eth0 192.212.4.126/30
        set_if eth1 192.212.4.65/29
        ;;
    *shigeru*)
        set_if eth0 192.212.4.130/30
        set_if eth1 192.212.4.81/29
        set_if eth2 192.212.4.169/30
        ;;
    *fuyutsuki*)
        set_if eth0 192.212.4.134/30
        set_if eth1 192.212.4.57/29
        set_if eth2 192.212.4.161/30
        set_if eth3 192.212.4.165/30
        ;;
    *rei*)
        set_if eth0 192.212.4.138/30
        set_if eth1 192.212.0.1/23
        ;;
    *shinji*)
        set_if eth0 192.212.4.142/30
        set_if eth1 192.212.4.1/27
        ;;
    *mari*)
        set_if eth0 192.212.4.146/30
        set_if eth1 192.212.4.33/28
        ;;
    *kaworu*)
        set_if eth0 192.212.4.150/30
        set_if eth1 192.212.3.225/27
        ;;
    *kensuke*)
        set_if eth0 192.212.4.154/30
        set_if eth1 192.212.3.129/26
        ;;
    *ritsuko*)
        set_if eth0 192.212.4.158/30
        set_if eth1 192.212.4.49/29
        ;;
    *maya*)
        set_if eth0 192.212.4.162/30
        set_if eth1 192.212.3.193/27
        ;;
    *toji*)
        set_if eth0 192.212.4.166/30
        set_if eth1 192.212.4.73/29
        ;;
    *makoto*)
        set_if eth0 192.212.4.170/30
        set_if eth1 192.212.4.89/29
        ;;
    *)
        echo "[ERROR] Hostname '$NODE_RAW' bukan salah satu dari 17 router Geofront."
        exit 1
        ;;
esac

echo "[OK] Selesai! Status ip_forward & interface:"
sysctl net.ipv4.ip_forward 2>/dev/null || cat /proc/sys/net/ipv4/ip_forward
ip -br -4 addr show
