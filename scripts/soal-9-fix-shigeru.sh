#!/bin/sh
# ==============================================================================
# soal-9-fix-shigeru.sh - Soal 9: Diagnosis & Perbaikan Sabotase break_routing.sh
# Praktikum Jarkom Modul 5 - Kelompok K-02
# Jalankan di: Shigeru
#
# 4 Penyebab Sabotase break_routing.sh yang diperbaiki:
#   1. net.ipv4.ip_forward = 0 (IP forwarding dimatikan)
#   2. default route diarahkan ke Makoto (192.212.4.170 / eth2) -> routing loop
#   3. blackhole route ke Switch-Dogma (192.212.4.72/29)
#   4. Policy-Based Routing: ip rule priority 90 iif eth1 lookup 100 (unreachable default)
#
# Penggunaan:
#   sh /root/soal-9-fix-shigeru.sh diagnose   # Hanya tampilkan bukti 4 kerusakan
#   sh /root/soal-9-fix-shigeru.sh fix        # Perbaiki semua 4 penyebab (default)
# ==============================================================================

set -u

ACTION="${1:-fix}"

if [ "$ACTION" = "diagnose" ]; then
    echo "=== [Soal 9] DIAGNOSIS SABOTASE DI SHIGERU ==="
    echo ""
    echo "[1] Cek IP Forwarding (seharusnya 1):"
    sysctl net.ipv4.ip_forward 2>/dev/null || cat /proc/sys/net/ipv4/ip_forward
    echo ""
    echo "[2 & 3] Cek Tabel Routing Main (cek default route & blackhole 192.212.4.72/29):"
    ip route show
    echo ""
    echo "[4] Cek Policy Routing (ip rule & table 100):"
    ip rule show
    echo "--- Isi table 100 ---"
    ip route show table 100
    exit 0
fi

echo "=== [Soal 9] MEMPERBAIKI 4 SABOTASE ROUTING DI SHIGERU ==="

# 1. Aktifkan kembali IPv4 forwarding
echo "[1/4] Mengaktifkan net.ipv4.ip_forward = 1..."
sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || echo 1 > /proc/sys/net/ipv4/ip_forward

# 2. Kembalikan default route ke Gendou (192.212.4.129 via eth0), bukan Makoto
echo "[2/4] Mengembalikan default route ke Gendou (192.212.4.129 dev eth0)..."
ip route replace default via 192.212.4.129 dev eth0
ip route replace 192.212.4.88/29 via 192.212.4.170 dev eth2

# 3. Hapus blackhole route menuju Switch-Dogma (192.212.4.72/29)
echo "[3/4] Menghapus blackhole route 192.212.4.72/29 (Switch-Dogma)..."
ip route del blackhole 192.212.4.72/29 2>/dev/null || true

# 4. Hapus Policy-Based Routing rule priority 90 (lookup 100) & bersihkan table 100
echo "[4/4] Menghapus ip rule lookup 100 & mengosongkan table 100..."
ip rule del iif eth1 lookup 100 priority 90 2>/dev/null || true
while ip rule show | grep -q "lookup 100"; do
    ip rule del lookup 100 2>/dev/null || break
done
ip route flush table 100 2>/dev/null || true

echo ""
echo "=== [OK] Semua 4 penyebab sabotase di Shigeru berhasil diperbaiki! ==="
echo "--- Verifikasi ip_forward ---"
sysctl net.ipv4.ip_forward 2>/dev/null || cat /proc/sys/net/ipv4/ip_forward
echo "--- Verifikasi ip route ---"
ip route show
echo "--- Verifikasi ip rule ---"
ip rule show
