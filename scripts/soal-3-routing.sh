#!/bin/sh
# ==============================================================================
# soal-3-routing.sh - Soal 3: Static Routing Minimal + Ringkasan CIDR
# Praktikum Jarkom Modul 5 - Kelompok K-02 (Prefix: 192.212.x.x)
#
# Juga mendukung IP & gateway sementara pada 4 node uji Soal 3-5:
#   Armisael, Lilith, Sachiel, Comm-Net
#
# Penggunaan:
#   sh /root/soal-3-routing.sh            # Otomatis deteksi hostname
#   sh /root/soal-3-routing.sh <hostname> # Paksa nama node
# ==============================================================================

set -u

NODE_RAW="${1:-$(hostname)}"
NODE=$(printf '%s' "$NODE_RAW" | tr '[:upper:]' '[:lower:]')

echo "=== [Soal 3] Konfigurasi Routing Statis pada: $NODE_RAW ==="

case "$NODE" in
    *gendo*)
        # 21 rute statis optimal (4 ringkasan CIDR tepat)
        # Cabang Yui (via 192.212.4.110)
        ip route replace 192.212.0.0/23   via 192.212.4.110 dev eth2
        ip route replace 192.212.3.0/25   via 192.212.4.110 dev eth2
        ip route replace 192.212.4.0/27   via 192.212.4.110 dev eth2
        ip route replace 192.212.4.32/28  via 192.212.4.110 dev eth2
        ip route replace 192.212.4.136/29 via 192.212.4.110 dev eth2  # Summary Yui-Rei + Yui-Shinji
        ip route replace 192.212.4.144/30 via 192.212.4.110 dev eth2
        # Cabang Hikari (via 192.212.4.114)
        ip route replace 192.212.2.0/24   via 192.212.4.114 dev eth3
        ip route replace 192.212.3.224/27 via 192.212.4.114 dev eth3
        ip route replace 192.212.4.148/30 via 192.212.4.114 dev eth3
        # Cabang Asuka (via 192.212.4.118)
        ip route replace 192.212.3.128/26 via 192.212.4.118 dev eth4
        ip route replace 192.212.4.48/29  via 192.212.4.118 dev eth4
        ip route replace 192.212.4.96/30  via 192.212.4.118 dev eth4
        ip route replace 192.212.4.152/29 via 192.212.4.118 dev eth4  # Summary Asuka-Kensuke + Asuka-Ritsuko
        # Cabang Kaji (via 192.212.4.122)
        ip route replace 192.212.4.100/30 via 192.212.4.122 dev eth5
        # Cabang Misato (via 192.212.4.126)
        ip route replace 192.212.4.64/29  via 192.212.4.126 dev eth6
        # Cabang Shigeru (via 192.212.4.130)
        ip route replace 192.212.4.80/28  via 192.212.4.130 dev eth7  # Summary Monolith + Radar
        ip route replace 192.212.4.168/30 via 192.212.4.130 dev eth7
        # Cabang Fuyutsuki (via 192.212.4.134)
        ip route replace 192.212.3.192/27 via 192.212.4.134 dev eth8
        ip route replace 192.212.4.56/29  via 192.212.4.134 dev eth8
        ip route replace 192.212.4.72/29  via 192.212.4.134 dev eth8
        ip route replace 192.212.4.160/29 via 192.212.4.134 dev eth8  # Summary Fuyutsuki-Maya + Fuyutsuki-Toji
        ;;
    *yui*)
        ip route replace default          via 192.212.4.109 dev eth0
        ip route replace 192.212.0.0/23   via 192.212.4.138 dev eth2
        ip route replace 192.212.4.0/27   via 192.212.4.142 dev eth3
        ip route replace 192.212.4.32/28  via 192.212.4.146 dev eth4
        ;;
    *hikari*)
        ip route replace default          via 192.212.4.113 dev eth0
        ip route replace 192.212.3.224/27 via 192.212.4.150 dev eth2
        ;;
    *asuka*)
        ip route replace default          via 192.212.4.117 dev eth0
        ip route replace 192.212.3.128/26 via 192.212.4.154 dev eth2
        ip route replace 192.212.4.48/29  via 192.212.4.158 dev eth3
        ;;
    *shigeru*)
        ip route replace default          via 192.212.4.129 dev eth0
        ip route replace 192.212.4.88/29  via 192.212.4.170 dev eth2
        ;;
    *fuyutsuki*)
        ip route replace default          via 192.212.4.133 dev eth0
        ip route replace 192.212.3.192/27 via 192.212.4.162 dev eth2
        ip route replace 192.212.4.72/29  via 192.212.4.166 dev eth3
        ;;
    # 11 Leaf Router (cukup 1 default route ke atas)
    *kaji*)      ip route replace default via 192.212.4.121 dev eth0 ;;
    *misato*)    ip route replace default via 192.212.4.125 dev eth0 ;;
    *rei*)       ip route replace default via 192.212.4.137 dev eth0 ;;
    *shinji*)    ip route replace default via 192.212.4.141 dev eth0 ;;
    *mari*)      ip route replace default via 192.212.4.145 dev eth0 ;;
    *kaworu*)    ip route replace default via 192.212.4.149 dev eth0 ;;
    *kensuke*)   ip route replace default via 192.212.4.153 dev eth0 ;;
    *ritsuko*)   ip route replace default via 192.212.4.157 dev eth0 ;;
    *maya*)      ip route replace default via 192.212.4.161 dev eth0 ;;
    *toji*)      ip route replace default via 192.212.4.165 dev eth0 ;;
    *makoto*)    ip route replace default via 192.212.4.169 dev eth0 ;;

    # 4 Node Uji Sementara untuk Soal 3-5 (IP permanen dibuat di Soal 6)
    *armisael*)
        ip addr replace 192.212.4.83/29 dev eth0 && ip link set eth0 up
        ip route replace default via 192.212.4.81 dev eth0
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
        ;;
    *lilith*)
        ip addr replace 192.212.4.74/29 dev eth0 && ip link set eth0 up
        ip route replace default via 192.212.4.73 dev eth0
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
        ;;
    *sachiel*)
        ip addr replace 192.212.3.130/26 dev eth0 && ip link set eth0 up
        ip route replace default via 192.212.3.129 dev eth0
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
        ;;
    *comm-net*|*commnet*)
        ip addr replace 192.212.2.2/24 dev eth0 && ip link set eth0 up
        ip route replace default via 192.212.2.1 dev eth0
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
        ;;
    *)
        echo "[ERROR] Node '$NODE_RAW' tidak dikenali untuk Soal 3."
        exit 1
        ;;
esac

echo "[OK] Tabel routing aktif pada $NODE_RAW:"
ip route show
