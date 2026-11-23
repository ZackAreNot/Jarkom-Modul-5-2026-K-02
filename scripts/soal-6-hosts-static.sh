#!/bin/sh
# ==============================================================================
# soal-6-hosts-static.sh - Soal 6: IP Statis & Gateway Permanen Semua 25 Host
# Praktikum Jarkom Modul 5 - Kelompok K-02 (Prefix: 192.212.x.x)
#
# Menyimpan konfigurasi di /etc/network/interfaces agar bertahan setelah restart.
# Semua node menggunakan ardhptr21/debinet:latest, sehingga otomatis memasang
# ifupdown (persistensi interface) dan netcat-traditional (alat uji nc Soal 7-19).
#
# Penggunaan:
#   sh /root/soal-6-hosts-static.sh            # Otomatis deteksi hostname
#   sh /root/soal-6-hosts-static.sh <hostname> # Paksa nama host
# ==============================================================================

set -u

NODE_RAW="${1:-$(hostname)}"
NODE=$(printf '%s' "$NODE_RAW" | tr '[:upper:]' '[:lower:]')

IP=""
PREFIX=""
MASK=""
GW=""

case "$NODE" in
    *quarters*)               IP="192.212.0.2";   PREFIX="23"; MASK="255.255.254.0";   GW="192.212.0.1"   ;;
    *comm-net*|*commnet*)     IP="192.212.2.2";   PREFIX="24"; MASK="255.255.255.0";   GW="192.212.2.1"   ;;
    *hangar-crew*|*hangar*)   IP="192.212.3.2";   PREFIX="25"; MASK="255.255.255.128"; GW="192.212.3.1"   ;;
    *sachiel*)                IP="192.212.3.130"; PREFIX="26"; MASK="255.255.255.192"; GW="192.212.3.129" ;;
    *pen-pen*|*penpen*)       IP="192.212.3.194"; PREFIX="27"; MASK="255.255.255.224"; GW="192.212.3.193" ;;
    *medic-bay*|*medicbay*)   IP="192.212.3.195"; PREFIX="27"; MASK="255.255.255.224"; GW="192.212.3.193" ;;
    *relay-node*|*relay*)     IP="192.212.3.226"; PREFIX="27"; MASK="255.255.255.224"; GW="192.212.3.225" ;;
    *garden-staff*|*garden*)  IP="192.212.4.2";   PREFIX="27"; MASK="255.255.255.224"; GW="192.212.4.1"   ;;
    *dock-crew*|*dock*)       IP="192.212.4.34";  PREFIX="28"; MASK="255.255.255.240"; GW="192.212.4.33"  ;;
    *entry-plug*|*entry*)     IP="192.212.4.50";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.49"  ;;
    *dummy-plug*|*dummy*)     IP="192.212.4.51";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.49"  ;;
    *casper*)                 IP="192.212.4.58";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.57"  ;;
    *balthasar*)              IP="192.212.4.59";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.57"  ;;
    *melchior*)               IP="192.212.4.60";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.57"  ;;
    *unit-01*|*unit01*)       IP="192.212.4.66";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.65"  ;;
    *unit-02*|*unit02*)       IP="192.212.4.67";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.65"  ;;
    *unit-00*|*unit00*)       IP="192.212.4.68";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.65"  ;;
    *lilith*)                 IP="192.212.4.74";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.73"  ;;
    *adam*)                   IP="192.212.4.75";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.73"  ;;
    *zeruel*)                 IP="192.212.4.82";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.81"  ;;
    *armisael*)               IP="192.212.4.83";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.81"  ;;
    *radar-array*|*radar*)    IP="192.212.4.90";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.89"  ;;
    *archive-vault*|*archive*)IP="192.212.4.98";  PREFIX="30"; MASK="255.255.255.252"; GW="192.212.4.97"  ;;
    *spy*)                    IP="192.212.4.102"; PREFIX="30"; MASK="255.255.255.252"; GW="192.212.4.101" ;;
    *tokyo3*)                 IP="192.212.4.106"; PREFIX="30"; MASK="255.255.255.252"; GW="192.212.4.105" ;;
    *)
        echo "[ERROR] Hostname '$NODE_RAW' bukan salah satu dari 25 host non-router Geofront."
        exit 1
        ;;
esac

echo "=== [Soal 6] Konfigurasi IP Statis Permanen: $NODE_RAW ($IP/$PREFIX gw $GW) ==="

# 1. Aktifkan IP & route langsung dulu agar konektivitas langsung hidup (termasuk untuk apt di debinet)
ip addr replace "$IP/$PREFIX" dev eth0
ip link set eth0 up
ip route replace default via "$GW" dev eth0
printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

# 2. Pada debinet, pasang ifupdown & netcat-traditional bila belum tersedia
if command -v apt-get >/dev/null 2>&1; then
    if ! command -v ifup >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1; then
        echo "[+] Memasang ifupdown dan netcat-traditional pada $(hostname) (debinet)..."
        apt-get update -qq && apt-get install -y -qq ifupdown netcat-traditional
    fi
    update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
fi

# 3. Tulis konfigurasi permanen ke /etc/network/interfaces
mkdir -p /etc/network
cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address $IP
    netmask $MASK
    gateway $GW
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
EOF

# 4. Uji pemuatan lewat ifup (sesuai modul implementasifirewall.md)
if command -v ifup >/dev/null 2>&1; then
    ip addr flush dev eth0 2>/dev/null || true
    mkdir -p /run/network
    ifdown eth0 2>/dev/null || true
    ifup eth0 2>/dev/null || {
        ip addr replace "$IP/$PREFIX" dev eth0
        ip link set eth0 up
        ip route replace default via "$GW" dev eth0
    }
fi

echo "[OK] Konfigurasi permanen selesai! Verifikasi:"
ip -br -4 addr show
ip route show
ping -c 2 -W 2 "$GW"
