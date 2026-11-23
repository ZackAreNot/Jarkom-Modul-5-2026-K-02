#!/bin/sh
# ==============================================================================
# /root/gendo.sh - Konfigurasi Lengkap Router Pusat Gendou (Soal 2, 3, 4, 5)
# Praktikum Jarkom Modul 5 - Kelompok K-02 (Prefix: 192.212.x.x)
#
# Idempoten: aman dijalankan berkali-kali tanpa menduplikasi IP, rute, atau rule.
# Mencakup:
#   - Soal 2: IP interface eth1..eth8, DHCP eth0 (NAT1), IPv4 forwarding
#   - Soal 3: Static routing optimal (21 rute dengan 4 ringkasan CIDR tepat)
#   - Soal 4: NAT MASQUERADE khusus prefix internal 192.212.0.0/16 keluar eth0 + DNS
#   - Soal 5: Firewall Default Deny (INPUT & FORWARD DROP) + 4 izin + loopback + DHCP
# ==============================================================================

set -u

WAN_IF="eth0"
INTERNAL_PREFIX="192.212.0.0/16"

fix_iptables_backend() {
    if ! iptables -L -n >/dev/null 2>&1; then
        if [ -x /usr/sbin/iptables-legacy ]; then
            update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
        fi
    fi
}

echo "=== [Gendou] Memulai konfigurasi lengkap (Soal 2 - 5) ==="

# ------------------------------------------------------------------------------
# 1. Aktifkan IPv4 Forwarding (Soal 2)
# ------------------------------------------------------------------------------
sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || echo 1 > /proc/sys/net/ipv4/ip_forward
mkdir -p /etc/sysctl.d
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ipforward.conf

# ------------------------------------------------------------------------------
# 2. Konfigurasi Interface WAN DHCP (eth0 -> NAT1) & LAN/Link (eth1..eth8)
# ------------------------------------------------------------------------------
ip link set "$WAN_IF" up
if ! ip -4 addr show dev "$WAN_IF" | grep -q "inet "; then
    echo "[+] Meminta alamat DHCP pada $WAN_IF (NAT1)..."
    if ! command -v dhclient >/dev/null 2>&1 && ! command -v udhcpc >/dev/null 2>&1; then
        ip addr replace 192.168.122.100/24 dev "$WAN_IF"
        ip route replace default via 192.168.122.1
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
        apt-get update -qq && apt-get install -y -qq isc-dhcp-client
        ip addr flush dev "$WAN_IF"
    fi
    if command -v dhclient >/dev/null 2>&1; then
        dhclient -1 "$WAN_IF" 2>/dev/null || true
    elif command -v udhcpc >/dev/null 2>&1; then
        udhcpc -i "$WAN_IF" -n -q 2>/dev/null || true
    fi
    # Fallback jika DHCP server NAT1 GNS3 sedang penuh / tidak merespons
    if ! ip -4 addr show dev "$WAN_IF" | grep -q "inet "; then
        echo "[!] DHCP NAT1 tidak merespons, fallback ke 192.168.122.212/24 via 192.168.122.1"
        ip addr replace 192.168.122.212/24 dev "$WAN_IF"
        ip route replace default via 192.168.122.1 dev "$WAN_IF"
    fi
fi

# Pastikan DNS resolver terpasang (Soal 4)
cat << 'EOF' > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

# Konfigurasi IP statis pada eth1..eth8 (idempoten dengan replace)
ip addr replace 192.212.4.105/30 dev eth1 && ip link set eth1 up   # Switch-Cmd
ip addr replace 192.212.4.109/30 dev eth2 && ip link set eth2 up   # Link L1 -> Yui
ip addr replace 192.212.4.113/30 dev eth3 && ip link set eth3 up   # Link L2 -> Hikari
ip addr replace 192.212.4.117/30 dev eth4 && ip link set eth4 up   # Link L3 -> Asuka
ip addr replace 192.212.4.121/30 dev eth5 && ip link set eth5 up   # Link L4 -> Kaji
ip addr replace 192.212.4.125/30 dev eth6 && ip link set eth6 up   # Link L5 -> Misato
ip addr replace 192.212.4.129/30 dev eth7 && ip link set eth7 up   # Link L6 -> Shigeru
ip addr replace 192.212.4.133/30 dev eth8 && ip link set eth8 up   # Link L7 -> Fuyutsuki

# ------------------------------------------------------------------------------
# 3. Static Routing Minimal dengan 4 Ringkasan CIDR Tepat (Soal 3)
# ------------------------------------------------------------------------------
# Cabang Yui (via 192.212.4.110) — 6 rute (L8+L9 diringkas -> 192.212.4.136/29)
ip route replace 192.212.0.0/23   via 192.212.4.110 dev eth2  # Switch-Quarters (Rei)
ip route replace 192.212.3.0/25   via 192.212.4.110 dev eth2  # Switch-Hangar (Yui)
ip route replace 192.212.4.0/27   via 192.212.4.110 dev eth2  # Switch-Garden (Shinji)
ip route replace 192.212.4.32/28  via 192.212.4.110 dev eth2  # Switch-Dock (Mari)
ip route replace 192.212.4.136/29 via 192.212.4.110 dev eth2  # CIDR Summary: Yui-Rei + Yui-Shinji
ip route replace 192.212.4.144/30 via 192.212.4.110 dev eth2  # Link L10: Yui-Mari

# Cabang Hikari (via 192.212.4.114) — 3 rute
ip route replace 192.212.2.0/24   via 192.212.4.114 dev eth3  # Switch-Comm (Hikari)
ip route replace 192.212.3.224/27 via 192.212.4.114 dev eth3  # Switch-Relay (Kaworu)
ip route replace 192.212.4.148/30 via 192.212.4.114 dev eth3  # Link L11: Hikari-Kaworu

# Cabang Asuka (via 192.212.4.118) — 4 rute (L12+L13 diringkas -> 192.212.4.152/29)
ip route replace 192.212.3.128/26 via 192.212.4.118 dev eth4  # Switch-Bunker (Kensuke)
ip route replace 192.212.4.48/29  via 192.212.4.118 dev eth4  # Switch-Lab (Ritsuko)
ip route replace 192.212.4.96/30  via 192.212.4.118 dev eth4  # Switch-Archive (Asuka)
ip route replace 192.212.4.152/29 via 192.212.4.118 dev eth4  # CIDR Summary: Asuka-Kensuke + Asuka-Ritsuko

# Cabang Kaji (via 192.212.4.122) — 1 rute
ip route replace 192.212.4.100/30 via 192.212.4.122 dev eth5  # Switch-Intel (Kaji)

# Cabang Misato (via 192.212.4.126) — 1 rute
ip route replace 192.212.4.64/29  via 192.212.4.126 dev eth6  # Switch-Cage (Misato)

# Cabang Shigeru (via 192.212.4.130) — 2 rute (Monolith+Radar diringkas -> 192.212.4.80/28)
ip route replace 192.212.4.80/28  via 192.212.4.130 dev eth7  # CIDR Summary: Switch-Monolith + Switch-Radar
ip route replace 192.212.4.168/30 via 192.212.4.130 dev eth7  # Link L16: Shigeru-Makoto

# Cabang Fuyutsuki (via 192.212.4.134) — 4 rute (L14+L15 diringkas -> 192.212.4.160/29)
ip route replace 192.212.3.192/27 via 192.212.4.134 dev eth8  # Switch-Medic (Maya)
ip route replace 192.212.4.56/29  via 192.212.4.134 dev eth8  # Switch-Terminal (Fuyutsuki)
ip route replace 192.212.4.72/29  via 192.212.4.134 dev eth8  # Switch-Dogma (Toji)
ip route replace 192.212.4.160/29 via 192.212.4.134 dev eth8  # CIDR Summary: Fuyutsuki-Maya + Fuyutsuki-Toji

# ------------------------------------------------------------------------------
# 4. Pasang iptables, ifupdown, dan netcat-traditional jika belum ada (debinet)
# ------------------------------------------------------------------------------
if ! command -v iptables >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v dhclient >/dev/null 2>&1; then
    echo "[+] Memasang paket iptables, ifupdown, isc-dhcp-client, dan netcat-traditional..."
    apt-get update -qq && apt-get install -y -qq iptables ifupdown isc-dhcp-client netcat-traditional
fi
update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
fix_iptables_backend

# ------------------------------------------------------------------------------
# 5. NAT MASQUERADE Khusus Prefix Internal ke NAT1 (Soal 4)
# ------------------------------------------------------------------------------
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -s "$INTERNAL_PREFIX" -o "$WAN_IF" -j MASQUERADE

# ------------------------------------------------------------------------------
# 6. Firewall Default Deny Pintu Depan NAT1 (Soal 5)
#    Urutan aman: reset policy ACCEPT -> flush -> pasang rule izin -> set DROP
# ------------------------------------------------------------------------------
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F INPUT
iptables -F FORWARD
iptables -F OUTPUT

# --- Chain INPUT ---
# Loopback
iptables -A INPUT -i lo -j ACCEPT
# (a) Balasan koneksi yang sudah ada
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# DHCP dari NAT1 (balasan DHCP server UDP 67 -> 68 di eth0)
iptables -A INPUT -i "$WAN_IF" -p udp --sport 67 --dport 68 -j ACCEPT
# (d) Traffic dari jaringan internal ke Gendou sendiri
iptables -A INPUT ! -i "$WAN_IF" -s "$INTERNAL_PREFIX" -j ACCEPT

# --- Chain FORWARD ---
# (a) Balasan koneksi yang sudah ada
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# (b) Traffic dari jaringan internal ke internet (via NAT1)
iptables -A FORWARD ! -i "$WAN_IF" -o "$WAN_IF" -s "$INTERNAL_PREFIX" -j ACCEPT
# (c) Traffic antar-LAN di dalam Geofront
iptables -A FORWARD ! -i "$WAN_IF" ! -o "$WAN_IF" -s "$INTERNAL_PREFIX" -d "$INTERNAL_PREFIX" -j ACCEPT

# Kunci pintu depan: ubah policy INPUT & FORWARD menjadi DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Simpan snapshot rule iptables (berguna untuk persistensi & Soal 20)
iptables-save > /root/gendo.rules 2>/dev/null || true

# ------------------------------------------------------------------------------
# 7. Simpan Konfigurasi Persistensi /etc/network/interfaces
# ------------------------------------------------------------------------------
cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

auto eth1
iface eth1 inet static
    address 192.212.4.105
    netmask 255.255.255.252

auto eth2
iface eth2 inet static
    address 192.212.4.109
    netmask 255.255.255.252

auto eth3
iface eth3 inet static
    address 192.212.4.113
    netmask 255.255.255.252

auto eth4
iface eth4 inet static
    address 192.212.4.117
    netmask 255.255.255.252

auto eth5
iface eth5 inet static
    address 192.212.4.121
    netmask 255.255.255.252

auto eth6
iface eth6 inet static
    address 192.212.4.125
    netmask 255.255.255.252

auto eth7
iface eth7 inet static
    address 192.212.4.129
    netmask 255.255.255.252

auto eth8
iface eth8 inet static
    address 192.212.4.133
    netmask 255.255.255.252
    post-up [ -f /root/gendo.sh ] && sh /root/gendo.sh >/dev/null 2>&1 || true
EOF

echo "=== [OK] Gendou selesai dikonfigurasi! ==="
echo "--- Ringkasan Interface ---"
ip -br -4 addr show
echo "--- Ringkasan iptables (filter) ---"
iptables -S
echo "--- Ringkasan iptables (nat) ---"
iptables -t nat -S
