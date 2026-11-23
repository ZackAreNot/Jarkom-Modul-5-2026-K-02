#!/bin/sh
# ==============================================================================
# soal-11-casper-ghost.sh - Soal 11: Casper Jadi Hantu (Blokir Ping Masuk)
# Praktikum Jarkom Modul 5 - Kelompok K-02
# Jalankan di: Magi-Casper (192.212.4.58)
#
# Tujuan:
#   - Tidak ada perangkat lain yang boleh mem-ping Casper (termasuk satu switch: Balthasar)
#   - Casper sendiri tetap boleh mem-ping siapa saja (echo-reply tetap lolos)
#   - Layanan TCP 5000 Casper tetap hidup
# ==============================================================================

set -u

NODE=$(hostname | tr '[:upper:]' '[:lower:]')
case "$NODE" in
    *casper*) ;;
    *) echo "[WARNING] Hostname saat ini '$(hostname)'. Pastikan dijalankan di Magi-Casper." ;;
esac

if ! command -v iptables >/dev/null 2>&1; then
    echo "[ERROR] iptables belum terpasang. Jalankan /root/casper.sh (Soal 7) dulu."
    exit 1
fi
if ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

echo "=== [Soal 11] Memasang Host-Based ICMP Echo-Request DROP di Magi-Casper ==="

# Pasang di INPUT pada Magi-Casper sendiri agar host satu switch (Balthasar & Melchior)
# juga terblokir, namun echo-reply dari ping yang dimulai Casper tetap diterima!
iptables -C INPUT -p icmp --icmp-type echo-request -j DROP 2>/dev/null || \
    iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# Simpan rules untuk persistensi
iptables-save > /root/casper.rules 2>/dev/null || true

# Pastikan listener TCP 5000 tetap hidup
[ -f /root/casper.sh ] && sh /root/casper.sh --listen-only

echo "[OK] Aturan Soal 11 aktif pada Magi-Casper:"
iptables -L INPUT -n -v --line-numbers
