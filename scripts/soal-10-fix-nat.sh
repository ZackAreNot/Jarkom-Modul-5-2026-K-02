#!/bin/sh
# ==============================================================================
# soal-10-fix-nat.sh - Soal 10: Diagnosis & Perbaikan Sabotase break_nat.sh
# Praktikum Jarkom Modul 5 - Kelompok K-02
# Jalankan di: Misato DAN Gendou (otomatis mendeteksi hostname)
#
# 2 Penyebab Sabotase break_nat.sh:
#   1. Di Misato: SNAT palsu (-s 192.212.4.64/29 ! -d 192.212.0.0/16 -o eth0 -j SNAT --to-source 172.31.99.1)
#   2. Di Gendou: Rule #1 RETURN (-s 192.212.4.64/29 -o eth0 -j RETURN) di atas MASQUERADE
#
# Penggunaan:
#   sh /root/soal-10-fix-nat.sh diagnose  # Tampilkan rule NAT yang rusak
#   sh /root/soal-10-fix-nat.sh fix       # Hapus rule sabotase (default)
# ==============================================================================

set -u

ACTION="${1:-fix}"
NODE=$(hostname | tr '[:upper:]' '[:lower:]')

if ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

if [ "$ACTION" = "diagnose" ]; then
    echo "=== [Soal 10] DIAGNOSIS TABEL NAT PADA $(hostname) ==="
    iptables -t nat -L POSTROUTING -n -v --line-numbers
    echo "--- iptables -t nat -S POSTROUTING ---"
    iptables -t nat -S POSTROUTING
    exit 0
fi

case "$NODE" in
    *misato*)
        echo "=== [Soal 10] Memperbaiki Sabotase NAT di Misato ==="
        # Hapus rule SNAT palsu ke 172.31.99.1 (Misato tidak boleh melakukan NAT!)
        while iptables -t nat -D POSTROUTING -s 192.212.4.64/29 ! -d 192.212.0.0/16 -o eth0 -j SNAT --to-source 172.31.99.1 2>/dev/null; do
            echo "[+] Menghapus rule SNAT palsu (172.31.99.1) di Misato..."
        done
        echo "[OK] Tabel NAT POSTROUTING di Misato sekarang bersih:"
        iptables -t nat -L POSTROUTING -n -v --line-numbers
        ;;
    *gendo*)
        echo "=== [Soal 10] Memperbaiki Sabotase NAT di Gendou ==="
        # Hapus rule RETURN yang mem-bypass MASQUERADE untuk Switch-Cage (192.212.4.64/29)
        while iptables -t nat -D POSTROUTING -s 192.212.4.64/29 -o eth0 -j RETURN 2>/dev/null; do
            echo "[+] Menghapus rule RETURN bypass untuk 192.212.4.64/29 di Gendou..."
        done
        # Pastikan rule MASQUERADE yang benar tetap ada
        iptables -t nat -C POSTROUTING -s 192.212.0.0/16 -o eth0 -j MASQUERADE 2>/dev/null || \
            iptables -t nat -A POSTROUTING -s 192.212.0.0/16 -o eth0 -j MASQUERADE
        iptables-save > /root/gendo.rules 2>/dev/null || true
        echo "[OK] Tabel NAT POSTROUTING di Gendou sudah normal (hanya MASQUERADE internal):"
        iptables -t nat -L POSTROUTING -n -v --line-numbers
        ;;
    *)
        echo "[ERROR] Jalankan script ini di Misato dan di Gendou (bukan di $(hostname))."
        exit 1
        ;;
esac
