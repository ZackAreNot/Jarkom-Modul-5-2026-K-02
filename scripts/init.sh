#!/bin/sh
# ==============================================================================
# /root/init.sh - Universal Node Initialization, Persistence & Recovery Script
# Praktikum Jarkom Modul 5: "Operation Geofront" - Kelompok K-02
# Prefix IP Kelompok: 192.212.x.x (Root Block: 192.212.0.0/21)
#
# Kompatibel POSIX /bin/sh — dioptimalkan untuk seluruh 42 container ardhptr21/debinet:latest.
# Idempoten & aman:
#   - Menulis /etc/network/interfaces permanen untuk SEMUA 42 node (17 router + 25 host)
#   - Otomatis memasang ifupdown jika belum ada & internet sudah aktif (setelah Soal 4)
#   - Memasang hook auto-restore sekali-per-boot (/run/.geofront_init_done) di
#     /root/.profile dan /root/.bashrc sehingga setelah container RESTART seluruh
#     IP, routing, NAT, firewall (/root/<nama>.rules / gendo.sh), & listener otomatis
#     pulih TANPA mengganggu sesi sabotase (Soal 9, 10, 12) saat container sedang hidup!
#
# Penggunaan:
#   sh /root/init.sh              # Otomatis mendeteksi node dari hostname
#   sh /root/init.sh <nama_node>  # Paksa konfigurasi node tertentu
# ==============================================================================

set -u

NODE_RAW="${1:-$(hostname)}"
NODE=$(printf '%s' "$NODE_RAW" | tr '[:upper:]' '[:lower:]')

set_resolver() {
    printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
}

enable_forwarding() {
    sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || echo 1 > /proc/sys/net/ipv4/ip_forward
    mkdir -p /etc/sysctl.d 2>/dev/null || true
    echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ipforward.conf 2>/dev/null || true
}

fix_iptables_backend() {
    if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
        [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
    fi
}

ensure_ifupdown() {
    if command -v apt-get >/dev/null 2>&1 && ! command -v ifup >/dev/null 2>&1; then
        if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
            echo "[+] Memasang ifupdown pada $(hostname) agar /etc/network/interfaces aktif saat boot..."
            apt-get update -qq && apt-get install -y -qq ifupdown >/dev/null 2>&1 || true
        fi
    fi
}

# Hook sekali per boot menggunakan marker di /run (RAM tmpfs — otomatis terhapus saat restart)
ensure_boot_hook() {
    mkdir -p /run 2>/dev/null || true
    touch /run/.geofront_init_done 2>/dev/null || true
    HOOK='[ ! -f /run/.geofront_init_done ] && [ -f /root/init.sh ] && sh /root/init.sh >/dev/null 2>&1'
    for rc in /root/.profile /root/.bashrc; do
        [ -f "$rc" ] || touch "$rc"
        if ! grep -q "geofront_init_done" "$rc" 2>/dev/null; then
            printf '\n# Auto-recovery Geofront Modul 5 K-02 (sekali per restart container)\n%s\n' "$HOOK" >> "$rc"
        fi
    done
}

# Helper konfigurasi 1 host non-router (statis permanen + restore firewall/listener jika ada)
setup_host() {
    ip="$1"; prefix="$2"; mask="$3"; gw="$4"; rname="$5"; svc="$6"
    ip addr replace "$ip/$prefix" dev eth0
    ip link set eth0 up
    ip route replace default via "$gw" dev eth0
    set_resolver

    mkdir -p /etc/network
    cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address $ip
    netmask $mask
    gateway $gw
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
EOF
    if [ -n "$rname" ]; then
        echo "    post-up [ -f /root/${rname}.rules ] && iptables-restore < /root/${rname}.rules || true" >> /etc/network/interfaces
    fi
    if [ -n "$svc" ]; then
        echo "    post-up [ -f /root/${svc} ] && sh /root/${svc} --listen-only >/dev/null 2>&1 || true" >> /etc/network/interfaces
    fi

    # Restore saved iptables rules & listener jika ada
    fix_iptables_backend
    if [ -n "$rname" ] && [ -f "/root/${rname}.rules" ] && command -v iptables-restore >/dev/null 2>&1; then
        iptables-restore < "/root/${rname}.rules" 2>/dev/null || true
    fi
    if [ -n "$svc" ] && [ -f "/root/${svc}" ]; then
        sh "/root/${svc}" --listen-only >/dev/null 2>&1 || true
    fi
}

# Helper konfigurasi leaf router (2 interface: eth0 uplink /30, eth1 LAN)
setup_leaf_router() {
    up_ip="$1"; up_gw="$2"; lan_ip="$3"; lan_prefix="$4"; lan_mask="$5"; rname="$6"
    enable_forwarding
    ip addr replace "$up_ip/30" dev eth0 && ip link set eth0 up
    ip addr replace "$lan_ip/$lan_prefix" dev eth1 && ip link set eth1 up
    ip route replace default via "$up_gw" dev eth0
    set_resolver

    mkdir -p /etc/network
    cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address $up_ip
    netmask 255.255.255.252
    gateway $up_gw
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

auto eth1
iface eth1 inet static
    address $lan_ip
    netmask $lan_mask
EOF
    if [ -n "$rname" ] && [ -f "/root/${rname}.rules" ] && command -v iptables-restore >/dev/null 2>&1; then
        echo "    post-up [ -f /root/${rname}.rules ] && iptables-restore < /root/${rname}.rules || true" >> /etc/network/interfaces
        fix_iptables_backend
        iptables-restore < "/root/${rname}.rules" 2>/dev/null || true
    fi
}

echo "=== [init.sh] Memulihkan / Mengonfigurasi Node: $NODE_RAW ==="

case "$NODE" in
    # ==========================================================================
    # ROUTER PUSAT: GENDOU
    # ==========================================================================
    *gendo*)
        if [ -f /root/gendo.sh ]; then
            sh /root/gendo.sh
        else
            enable_forwarding
            ip link set eth0 up
            if ! ip -4 addr show dev eth0 | grep -q "inet "; then
                if ! command -v dhclient >/dev/null 2>&1 && ! command -v udhcpc >/dev/null 2>&1; then
                    ip addr replace 192.168.122.100/24 dev eth0
                    ip route replace default via 192.168.122.1
                    set_resolver
                    apt-get update -qq && apt-get install -y -qq isc-dhcp-client
                    ip addr flush dev eth0
                fi
                dhclient -1 eth0 2>/dev/null || udhcpc -i eth0 -n -q 2>/dev/null || true
                if ! ip -4 addr show dev eth0 | grep -q "inet "; then
                    ip addr replace 192.168.122.212/24 dev eth0
                    ip route replace default via 192.168.122.1 dev eth0
                fi
            fi
            set_resolver
            ip addr replace 192.212.4.105/30 dev eth1 && ip link set eth1 up
            ip addr replace 192.212.4.109/30 dev eth2 && ip link set eth2 up
            ip addr replace 192.212.4.113/30 dev eth3 && ip link set eth3 up
            ip addr replace 192.212.4.117/30 dev eth4 && ip link set eth4 up
            ip addr replace 192.212.4.121/30 dev eth5 && ip link set eth5 up
            ip addr replace 192.212.4.125/30 dev eth6 && ip link set eth6 up
            ip addr replace 192.212.4.129/30 dev eth7 && ip link set eth7 up
            ip addr replace 192.212.4.133/30 dev eth8 && ip link set eth8 up

            # 21 static routes optimal (4 ringkasan CIDR)
            ip route replace 192.212.0.0/23   via 192.212.4.110 dev eth2
            ip route replace 192.212.3.0/25   via 192.212.4.110 dev eth2
            ip route replace 192.212.4.0/27   via 192.212.4.110 dev eth2
            ip route replace 192.212.4.32/28  via 192.212.4.110 dev eth2
            ip route replace 192.212.4.136/29 via 192.212.4.110 dev eth2
            ip route replace 192.212.4.144/30 via 192.212.4.110 dev eth2
            ip route replace 192.212.2.0/24   via 192.212.4.114 dev eth3
            ip route replace 192.212.3.224/27 via 192.212.4.114 dev eth3
            ip route replace 192.212.4.148/30 via 192.212.4.114 dev eth3
            ip route replace 192.212.3.128/26 via 192.212.4.118 dev eth4
            ip route replace 192.212.4.48/29  via 192.212.4.118 dev eth4
            ip route replace 192.212.4.96/30  via 192.212.4.118 dev eth4
            ip route replace 192.212.4.152/29 via 192.212.4.118 dev eth4
            ip route replace 192.212.4.100/30 via 192.212.4.122 dev eth5
            ip route replace 192.212.4.64/29  via 192.212.4.126 dev eth6
            ip route replace 192.212.4.80/28  via 192.212.4.130 dev eth7
            ip route replace 192.212.4.168/30 via 192.212.4.130 dev eth7
            ip route replace 192.212.3.192/27 via 192.212.4.134 dev eth8
            ip route replace 192.212.4.56/29  via 192.212.4.134 dev eth8
            ip route replace 192.212.4.72/29  via 192.212.4.134 dev eth8
            ip route replace 192.212.4.160/29 via 192.212.4.134 dev eth8

            if command -v iptables >/dev/null 2>&1; then
                fix_iptables_backend
                if [ -f /root/gendo.rules ] && command -v iptables-restore >/dev/null 2>&1; then
                    iptables-restore < /root/gendo.rules 2>/dev/null || true
                else
                    iptables -t nat -C POSTROUTING -s 192.212.0.0/16 -o eth0 -j MASQUERADE 2>/dev/null || \
                        iptables -t nat -A POSTROUTING -s 192.212.0.0/16 -o eth0 -j MASQUERADE
                fi
            fi
        fi
        ;;

    # ==========================================================================
    # 5 BRANCH ROUTERS LEVEL 1 (Yui, Hikari, Asuka, Shigeru, Fuyutsuki)
    # ==========================================================================
    *yui*)
        enable_forwarding
        ip addr replace 192.212.4.110/30 dev eth0 && ip link set eth0 up
        ip addr replace 192.212.3.1/25   dev eth1 && ip link set eth1 up
        ip addr replace 192.212.4.137/30 dev eth2 && ip link set eth2 up
        ip addr replace 192.212.4.141/30 dev eth3 && ip link set eth3 up
        ip addr replace 192.212.4.145/30 dev eth4 && ip link set eth4 up
        ip route replace default          via 192.212.4.109 dev eth0
        ip route replace 192.212.0.0/23   via 192.212.4.138 dev eth2
        ip route replace 192.212.4.0/27   via 192.212.4.142 dev eth3
        ip route replace 192.212.4.32/28  via 192.212.4.146 dev eth4
        set_resolver
        mkdir -p /etc/network
        cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.212.4.110
    netmask 255.255.255.252
    gateway 192.212.4.109
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

auto eth1
iface eth1 inet static
    address 192.212.3.1
    netmask 255.255.255.128

auto eth2
iface eth2 inet static
    address 192.212.4.137
    netmask 255.255.255.252
    post-up ip route replace 192.212.0.0/23 via 192.212.4.138 dev eth2

auto eth3
iface eth3 inet static
    address 192.212.4.141
    netmask 255.255.255.252
    post-up ip route replace 192.212.4.0/27 via 192.212.4.142 dev eth3

auto eth4
iface eth4 inet static
    address 192.212.4.145
    netmask 255.255.255.252
    post-up ip route replace 192.212.4.32/28 via 192.212.4.146 dev eth4
EOF
        ;;

    *hikari*)
        enable_forwarding
        ip addr replace 192.212.4.114/30 dev eth0 && ip link set eth0 up
        ip addr replace 192.212.2.1/24   dev eth1 && ip link set eth1 up
        ip addr replace 192.212.4.149/30 dev eth2 && ip link set eth2 up
        ip route replace default          via 192.212.4.113 dev eth0
        ip route replace 192.212.3.224/27 via 192.212.4.150 dev eth2
        set_resolver
        mkdir -p /etc/network
        cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.212.4.114
    netmask 255.255.255.252
    gateway 192.212.4.113
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

auto eth1
iface eth1 inet static
    address 192.212.2.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.212.4.149
    netmask 255.255.255.252
    post-up ip route replace 192.212.3.224/27 via 192.212.4.150 dev eth2
EOF
        ;;

    *asuka*)
        enable_forwarding
        ip addr replace 192.212.4.118/30 dev eth0 && ip link set eth0 up
        ip addr replace 192.212.4.97/30  dev eth1 && ip link set eth1 up
        ip addr replace 192.212.4.153/30 dev eth2 && ip link set eth2 up
        ip addr replace 192.212.4.157/30 dev eth3 && ip link set eth3 up
        ip route replace default          via 192.212.4.117 dev eth0
        ip route replace 192.212.3.128/26 via 192.212.4.154 dev eth2
        ip route replace 192.212.4.48/29  via 192.212.4.158 dev eth3
        set_resolver
        mkdir -p /etc/network
        cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.212.4.118
    netmask 255.255.255.252
    gateway 192.212.4.117
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

auto eth1
iface eth1 inet static
    address 192.212.4.97
    netmask 255.255.255.252

auto eth2
iface eth2 inet static
    address 192.212.4.153
    netmask 255.255.255.252
    post-up ip route replace 192.212.3.128/26 via 192.212.4.154 dev eth2

auto eth3
iface eth3 inet static
    address 192.212.4.157
    netmask 255.255.255.252
    post-up ip route replace 192.212.4.48/29 via 192.212.4.158 dev eth3
EOF
        ;;

    *shigeru*)
        enable_forwarding
        ip addr replace 192.212.4.130/30 dev eth0 && ip link set eth0 up
        ip addr replace 192.212.4.81/29  dev eth1 && ip link set eth1 up
        ip addr replace 192.212.4.169/30 dev eth2 && ip link set eth2 up
        ip route replace default          via 192.212.4.129 dev eth0
        ip route replace 192.212.4.88/29  via 192.212.4.170 dev eth2
        set_resolver
        mkdir -p /etc/network
        cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.212.4.130
    netmask 255.255.255.252
    gateway 192.212.4.129
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

auto eth1
iface eth1 inet static
    address 192.212.4.81
    netmask 255.255.255.248

auto eth2
iface eth2 inet static
    address 192.212.4.169
    netmask 255.255.255.252
    post-up ip route replace 192.212.4.88/29 via 192.212.4.170 dev eth2
    post-up [ -f /root/shigeru.rules ] && iptables-restore < /root/shigeru.rules || true
EOF
        if [ -f /root/shigeru.rules ] && command -v iptables-restore >/dev/null 2>&1; then
            fix_iptables_backend
            iptables-restore < /root/shigeru.rules 2>/dev/null || true
        fi
        ;;

    *fuyutsuki*)
        enable_forwarding
        ip addr replace 192.212.4.134/30 dev eth0 && ip link set eth0 up
        ip addr replace 192.212.4.57/29  dev eth1 && ip link set eth1 up
        ip addr replace 192.212.4.161/30 dev eth2 && ip link set eth2 up
        ip addr replace 192.212.4.165/30 dev eth3 && ip link set eth3 up
        ip route replace default          via 192.212.4.133 dev eth0
        ip route replace 192.212.3.192/27 via 192.212.4.162 dev eth2
        ip route replace 192.212.4.72/29  via 192.212.4.166 dev eth3
        set_resolver
        mkdir -p /etc/network
        cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.212.4.134
    netmask 255.255.255.252
    gateway 192.212.4.133
    post-up sysctl -w net.ipv4.ip_forward=1
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

auto eth1
iface eth1 inet static
    address 192.212.4.57
    netmask 255.255.255.248

auto eth2
iface eth2 inet static
    address 192.212.4.161
    netmask 255.255.255.252
    post-up ip route replace 192.212.3.192/27 via 192.212.4.162 dev eth2

auto eth3
iface eth3 inet static
    address 192.212.4.165
    netmask 255.255.255.252
    post-up ip route replace 192.212.4.72/29 via 192.212.4.166 dev eth3
    post-up [ -f /root/fuyutsuki.rules ] && iptables-restore < /root/fuyutsuki.rules || true
EOF
        if [ -f /root/fuyutsuki.rules ] && command -v iptables-restore >/dev/null 2>&1; then
            fix_iptables_backend
            iptables-restore < /root/fuyutsuki.rules 2>/dev/null || true
        fi
        ;;

    # ==========================================================================
    # 11 LEAF ROUTERS (Kaji, Misato, Rei, Shinji, Mari, Kaworu, Kensuke, Ritsuko, Maya, Toji, Makoto)
    # ==========================================================================
    *kaji*)    setup_leaf_router 192.212.4.122 192.212.4.121 192.212.4.101 30 255.255.255.252 "" ;;
    *misato*)  setup_leaf_router 192.212.4.126 192.212.4.125 192.212.4.65  29 255.255.255.248 "misato" ;;
    *rei*)     setup_leaf_router 192.212.4.138 192.212.4.137 192.212.0.1   23 255.255.254.0   "" ;;
    *shinji*)  setup_leaf_router 192.212.4.142 192.212.4.141 192.212.4.1   27 255.255.255.224 "" ;;
    *mari*)    setup_leaf_router 192.212.4.146 192.212.4.145 192.212.4.33  28 255.255.255.240 "" ;;
    *kaworu*)  setup_leaf_router 192.212.4.150 192.212.4.149 192.212.3.225 27 255.255.255.224 "" ;;
    *kensuke*) setup_leaf_router 192.212.4.154 192.212.4.153 192.212.3.129 26 255.255.255.192 "" ;;
    *ritsuko*) setup_leaf_router 192.212.4.158 192.212.4.157 192.212.4.49  29 255.255.255.248 "" ;;
    *maya*)    setup_leaf_router 192.212.4.162 192.212.4.161 192.212.3.193 27 255.255.255.224 "" ;;
    *toji*)    setup_leaf_router 192.212.4.166 192.212.4.165 192.212.4.73  29 255.255.255.248 "" ;;
    *makoto*)  setup_leaf_router 192.212.4.170 192.212.4.169 192.212.4.89  29 255.255.255.248 "" ;;

    # ==========================================================================
    # 25 NON-ROUTER HOSTS
    # ==========================================================================
    *quarters*)                setup_host 192.212.0.2   23 255.255.254.0   192.212.0.1   "" "" ;;
    *comm-net*|*commnet*)      setup_host 192.212.2.2   24 255.255.255.0   192.212.2.1   "" "" ;;
    *hangar-crew*|*hangar*)    setup_host 192.212.3.2   25 255.255.255.128 192.212.3.1   "" "" ;;
    *sachiel*)                 setup_host 192.212.3.130 26 255.255.255.192 192.212.3.129 "" "" ;;
    *pen-pen*|*penpen*)        setup_host 192.212.3.194 27 255.255.255.224 192.212.3.193 "penpen" "penpen.sh" ;;
    *medic-bay*|*medicbay*)    setup_host 192.212.3.195 27 255.255.255.224 192.212.3.193 "" "" ;;
    *relay-node*|*relay*)      setup_host 192.212.3.226 27 255.255.255.224 192.212.3.225 "" "" ;;
    *garden-staff*|*garden*)   setup_host 192.212.4.2   27 255.255.255.224 192.212.4.1   "" "" ;;
    *dock-crew*|*dock*)        setup_host 192.212.4.34  28 255.255.255.240 192.212.4.33  "" "" ;;
    *entry-plug*|*entry*)      setup_host 192.212.4.50  29 255.255.255.248 192.212.4.49  "" "" ;;
    *dummy-plug*|*dummy*)      setup_host 192.212.4.51  29 255.255.255.248 192.212.4.49  "" "" ;;
    *casper*)                  setup_host 192.212.4.58  29 255.255.255.248 192.212.4.57  "casper" "casper.sh" ;;
    *balthasar*)               setup_host 192.212.4.59  29 255.255.255.248 192.212.4.57  "balthasar" "balthasar.sh" ;;
    *melchior*)                setup_host 192.212.4.60  29 255.255.255.248 192.212.4.57  "melchior" "melchior.sh" ;;
    *unit-01*|*unit01*)        setup_host 192.212.4.66  29 255.255.255.248 192.212.4.65  "" "" ;;
    *unit-02*|*unit02*)        setup_host 192.212.4.67  29 255.255.255.248 192.212.4.65  "" "" ;;
    *unit-00*|*unit00*)        setup_host 192.212.4.68  29 255.255.255.248 192.212.4.65  "" "" ;;
    *lilith*)                  setup_host 192.212.4.74  29 255.255.255.248 192.212.4.73  "" "" ;;
    *adam*)                    setup_host 192.212.4.75  29 255.255.255.248 192.212.4.73  "" "" ;;
    *zeruel*)                  setup_host 192.212.4.82  29 255.255.255.248 192.212.4.81  "zeruel" "" ;;
    *armisael*)                setup_host 192.212.4.83  29 255.255.255.248 192.212.4.81  "" "" ;;
    *radar-array*|*radar*)     setup_host 192.212.4.90  29 255.255.255.248 192.212.4.89  "" "" ;;
    *archive-vault*|*archive*) setup_host 192.212.4.98  30 255.255.255.252 192.212.4.97  "" "" ;;
    *spy*)                     setup_host 192.212.4.102 30 255.255.255.252 192.212.4.101 "" "" ;;
    *tokyo3*)                  setup_host 192.212.4.106 30 255.255.255.252 192.212.4.105 "tokyo3" "tokyo3.sh" ;;

    *)
        echo "[ERROR] Node '$NODE_RAW' tidak ditemukan di peta Geofront K-02!"
        exit 1
        ;;
esac

ensure_ifupdown
ensure_boot_hook

echo "[OK] Node $NODE_RAW siap! Ringkasan:"
ip -br -4 addr show
ip route show
