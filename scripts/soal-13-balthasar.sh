#!/bin/sh
# Soal 13 - Brankas Balthasar (Magi-Balthasar: 192.212.4.59)
# Hanya Magi-Casper (192.212.4.58) dan seluruh Pilot yang boleh akses TCP 5000 & 5001.
# Node lain ditolak seketika (TCP RST) agar tidak menggantung sampai timeout.

iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Pastikan listener TCP 5000 dan 5001 aktif
pkill -f "nc -l -p 500" 2>/dev/null
while true; do nc -l -p 5000 >> /tmp/magi-5000.log 2>&1; done &
while true; do nc -l -p 5001 >> /tmp/magi-5001.log 2>&1; done &

# Aturan dasar & balasan koneksi keluar (termasuk ping ke 8.8.8.8)
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Izinkan TCP 5000 dan 5001 dari Magi-Casper dan seluruh Pilot
# (Unit-01: 192.212.4.66, Unit-02: 192.212.4.67, Unit-00: 192.212.4.68, Sachiel: 192.212.3.130)
for SRC in 192.212.4.58 192.212.4.66 192.212.4.67 192.212.4.68 192.212.3.130; do
    iptables -A INPUT -p tcp -s "$SRC" -m multiport --dports 5000,5001 -j ACCEPT
done

# Tolak seketika koneksi lain ke TCP 5000 & 5001 dengan TCP RST
iptables -A INPUT -p tcp -m multiport --dports 5000,5001 -j REJECT --reject-with tcp-reset