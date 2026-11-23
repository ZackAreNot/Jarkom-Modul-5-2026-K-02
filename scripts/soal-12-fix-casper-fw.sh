#!/bin/sh
# ==============================================================================
# soal-12-fix-casper-fw.sh - Soal 12: Diagnosis & Perbaikan Hardening break_fw.sh
# Praktikum Jarkom Modul 5 - Kelompok K-02
# Jalankan di: Magi-Casper (192.212.4.58)
#
# 4 Masalah dari break_fw.sh:
#   1. Policy INPUT DROP tanpa rule ESTABLISHED,RELATED -> balasan ping & apt dibuang
#   2. Rule INPUT -p icmp -j DROP memblokir SEMUA ICMP (termasuk echo-reply)
#   3. Rule OUTPUT -p udp --dport 53 -j DROP memblokir DNS keluar -> apt-get update gagal
#   4. Tidak ada rule ACCEPT untuk TCP port 5000 -> Unit-00 gagal nc ke port 5000
#
# Perbaikan TETAP mempertahankan tujuan hardening:
#   - Policy INPUT tetap DROP (default deny untuk semua trafik masuk yang tidak diizinkan)
#   - Ping masuk ke Casper tetap ditolak (Soal 11 tetap terpenuhi)
#   - Loopback, ESTABLISHED/RELATED, dan TCP 5000 diizinkan
#   - OUTPUT DNS (UDP 53) tidak lagi diblokir
#
# Penggunaan:
#   sh /root/soal-12-fix-casper-fw.sh diagnose  # Tampilkan bukti 4 kesalahan hardening
#   sh /root/soal-12-fix-casper-fw.sh fix       # Perbaiki tanpa batal hardening (default)
# ==============================================================================

set -u

ACTION="${1:-fix}"

if ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

if [ "$ACTION" = "diagnose" ]; then
    echo "=== [Soal 12] DIAGNOSIS HARDENING RUSAK DI MAGI-CASPER ==="
    echo "--- iptables -S ---"
    iptables -S
    echo "--- iptables -L -n -v --line-numbers ---"
    iptables -L -n -v --line-numbers
    exit 0
fi

echo "=== [Soal 12] MEMPERBAIKI FIREWALL MAGI-CASPER (HARDENING TETAP AKTIF) ==="

# 1. Reset sementara ke ACCEPT agar tidak memutus sesi saat membangun ulang rule
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F INPUT
iptables -F OUTPUT

# 2. Susun ulang chain INPUT secara rapi, stateful, dan default-deny:
#    - Izinkan loopback
iptables -A INPUT -i lo -j ACCEPT
#    - Izinkan balasan koneksi keluar (ping echo-reply, DNS reply, HTTP apt-get update, dll.)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#    - Tetap blokir ping masuk secara eksplisit (menjaga Soal 11 + counter terpantau)
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
#    - Izinkan layanan resmi Magi-Casper: TCP port 5000
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT

# 3. Pertahankan default policy INPUT = DROP (tujuan hardening tidak dibatalkan!)
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT

# 4. Pastikan DNS resolver terisi & listener TCP 5000 hidup
printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
[ -f /root/casper.sh ] && sh /root/casper.sh --listen-only

# 5. Simpan rules ke /root/casper.rules untuk persistensi & Soal 20
iptables-save > /root/casper.rules 2>/dev/null || true

# Tambahkan pemuatan otomatis iptables-restore pada /etc/network/interfaces jika belum ada
if [ -f /etc/network/interfaces ] && ! grep -q "casper.rules" /etc/network/interfaces; then
    echo "    post-up [ -f /root/casper.rules ] && iptables-restore < /root/casper.rules || true" >> /etc/network/interfaces
fi

echo ""
echo "=== [OK] Perbaikan Soal 12 selesai! Policy INPUT tetap DROP ==="
iptables -S
echo "--- Detail Counter ---"
iptables -L -n -v --line-numbers
