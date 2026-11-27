cat << 'EOF' > /root/penpen.sh
#!/bin/sh
PILOT_START="17:00"
PILOT_STOP="18:00"
PILOT_DAYS="Mon,Tue,Wed,Thu,Fri,Sat,Sun"
STAF_START="17:00"
STAF_STOP="18:00"

iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

pkill -f "nc -l -p 80" 2>/dev/null
while true; do printf "Welcome to Pen-Pen\n" | nc -l -p 80 -q 1 >/dev/null 2>&1; done &

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
EOF
cat << 'EOF' >> /root/penpen.sh
for SRC in 192.212.4.50 192.212.4.51 192.212.4.102; do
    iptables -A INPUT -s "$SRC" -p icmp --icmp-type echo-request -j DROP
    iptables -A INPUT -s "$SRC" -p tcp --dport 80 -j DROP
done

for SRC in 192.212.4.66 192.212.4.67 192.212.4.68 192.212.3.130; do
    iptables -A INPUT -s "$SRC" -p icmp --icmp-type echo-request -m time --timestart "$PILOT_START" --timestop "$PILOT_STOP" --weekdays "$PILOT_DAYS" -j ACCEPT
    iptables -A INPUT -s "$SRC" -p tcp --dport 80 -m time --timestart "$PILOT_START" --timestop "$PILOT_STOP" --weekdays "$PILOT_DAYS" -j ACCEPT
    iptables -A INPUT -s "$SRC" -p icmp --icmp-type echo-request -j DROP
    iptables -A INPUT -s "$SRC" -p tcp --dport 80 -j DROP
done

for SRC in 192.212.4.74 192.212.4.75; do
    iptables -A INPUT -s "$SRC" -p icmp --icmp-type echo-request -m time --timestart "$STAF_START" --timestop "$STAF_STOP" -j ACCEPT
    iptables -A INPUT -s "$SRC" -p tcp --dport 80 -m time --timestart "$STAF_START" --timestop "$STAF_STOP" -j ACCEPT
    iptables -A INPUT -s "$SRC" -p icmp --icmp-type echo-request -j DROP
    iptables -A INPUT -s "$SRC" -p tcp --dport 80 -j DROP
done
EOF
chmod +x /root/penpen.sh && /root/penpen.sh