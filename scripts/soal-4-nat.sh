#!/bin/sh
# ==============================================================================
# soal-4-nat.sh - Soal 4: Akses Internet via NAT MASQUERADE di Gendou + DNS
# Praktikum Jarkom Modul 5 - Kelompok K-02 (Prefix: 192.212.x.x)
#
# Jalankan di: Gendou (dan opsional di node uji dengan argumen --dns)
#   sh /root/soal-4-nat.sh        # di Gendou
#   sh /root/soal-4-nat.sh --dns  # di Armisael / Lilith / node lain
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" = "--dns" ]; then
    echo "[OK] /etc/resolv.conf diperbarui pada $(hostname):"
    cat /etc/resolv.conf
    exit 0
fi

echo "=== [Soal 4] Konfigurasi NAT MASQUERADE pada Gendou ==="

# Pastikan iptables, ifupdown, isc-dhcp-client, dan netcat-traditional terpasang pada Gendou (debinet)
if ! command -v iptables >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v dhclient >/dev/null 2>&1; then
    echo "[+] Memasang iptables, ifupdown, isc-dhcp-client, dan netcat-traditional..."
    apt-get update -qq && apt-get install -y -qq iptables ifupdown isc-dhcp-client netcat-traditional
fi
update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true

if ! iptables -L -n >/dev/null 2>&1; then
    if [ -x /usr/sbin/iptables-legacy ]; then
        update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
    fi
fi

# Hanya terjemahkan traffic dari prefix internal 192.212.0.0/16 yang keluar lewat eth0 (NAT1).
# Traffic antar-LAN keluar lewat eth1..eth8 sehingga alamat sumber aslinya tidak diubah.
# Memakai MASQUERADE agar otomatis menyesuaikan jika IP DHCP NAT1 berubah.
iptables -t nat -C POSTROUTING -s 192.212.0.0/16 -o eth0 -j MASQUERADE 2>/dev/null || \
    iptables -t nat -A POSTROUTING -s 192.212.0.0/16 -o eth0 -j MASQUERADE

echo "[OK] NAT MASQUERADE aktif! Counter rule NAT:"
iptables -t nat -L POSTROUTING -n -v --line-numbers
