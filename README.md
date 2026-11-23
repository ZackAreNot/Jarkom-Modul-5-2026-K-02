# Laporan Resmi Praktikum Modul 5
### Komunikasi Data & Jaringan Komputer 2026

**Kelompok:** K-02  
**Prefix IP Kelompok:** `192.212.x.x` (Root Block: `192.212.0.0/21`)  
**Tema:** *Operation Geofront* (VLSM, Static Routing, NAT, dan Firewall `iptables`)  
**Spreadsheet VLSM:** [`Spreadsheet Modul 5 Komdat Jarkom 2026 K02.xlsx`](./Spreadsheet%20Modul%205%20Komdat%20Jarkom%202026%20K02.xlsx)  
**Direktori Skrip (`/root`):** [`scripts/`](./scripts/)

| Nama | NRP | Pembagian Pengerjaan |
| :--- | :--- | :--- |
| Maulana Zaki Putra Zakaria | 5027251009 | Bagian 1: Soal 1 – 12 (VLSM, Topologi, Routing, NAT, Layanan, Sabotase, Hardening Casper) |
| Naila Anggun Eka Rizqy | 5027251122 | Bagian 2: Soal 13 – 20 (Brankas Balthasar, Pen-Pen, Tokyo3-Core, DNAT, Zona Sensitif, Isolasi, Uji Kebakaran) |

---

## Daftar Isi
- [Topologi Jaringan Geofront](#topologi-jaringan-geofront)
- [Babak 1: Membangun Geofront (Soal 1 – 8)](#babak-1-membangun-geofront-soal-1--8)
  - [Soal 1 — Markas Tanpa Peta (VLSM & Pohon IP)](#soal-1--markas-tanpa-peta-vlsm--pohon-ip)
  - [Soal 2 — Geofront Gelap Gulita](#soal-2--geofront-gelap-gulita)
  - [Soal 3 — Pulau-Pulau yang Terpisah](#soal-3--pulau-pulau-yang-terpisah)
  - [Soal 4 — Haus Kabar dari Dunia Luar](#soal-4--haus-kabar-dari-dunia-luar)
  - [Soal 5 — Pintu Depan Dikunci Rapat](#soal-5--pintu-depan-dikunci-rapat)
  - [Soal 6 — Alamat Para Pilot](#soal-6--alamat-para-pilot)
  - [Soal 7 — Membangunkan MAGI](#soal-7--membangunkan-magi)
  - [Soal 8 — Mengenali Kondisi Normal](#soal-8--mengenali-kondisi-normal)
- [Babak 2: Sabotase dan Hantu MAGI (Soal 9 – 12)](#babak-2-sabotase-dan-hantu-magi-soal-9--12)
  - [Soal 9 — Jalur Belakang Diutak-Atik](#soal-9--jalur-belakang-diutak-atik)
  - [Soal 10 — Para Pilot Terkunci di Dalam](#soal-10--para-pilot-terkunci-di-dalam)
  - [Soal 11 — Casper Harus Jadi Hantu](#soal-11--casper-harus-jadi-hantu)
  - [Soal 12 — Teknisi yang Kelewat Semangat](#soal-12--teknisi-yang-kelewat-semangat)
- [Babak 3 & Final: Mengamankan MAGI, Zona Sensitif & Uji Kebakaran (Soal 13 – 20)](#babak-3--final-mengamankan-magi-zona-sensitif--uji-kebakaran-soal-13--20)

---

## Topologi Jaringan Geofront

Jaringan **Operation Geofront** terdiri dari **17 router** (router pusat **`Gendou`** sebagai satu-satunya pintu keluar ke `NAT1` beserta 16 router di bawahnya), **17 LAN switch**, dan **25 host container** (total 42 container menggunakan `ardhptr21/debinet:latest`).

![Topologi Operation Geofront](assets/topo_5.png)

---

# Babak 1: Membangun Geofront (Soal 1 – 8)

## Soal 1 — Markas Tanpa Peta (VLSM & Pohon IP)

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Deskripsi Soal
> Bagi prefix IP kelompok (`192.212.x.x`) dengan VLSM untuk **17 LAN dan 16 link antar-router**, urut dari kebutuhan terbesar (tie-break: ukuran sama → LAN dulu daripada link → urutan tabel). Tunjukkan tabel berisi network, prefix, gateway, broadcast, IP terpakai, dan sisa, serta gambar pohon IP dengan subnet jalur `Dummy-Plug` ke `Armisael` dilingkari. Jelaskan hitungan satu subnet.

### Tabel Pembagian VLSM Lengkap (33 Subnet — Prefix `192.212.x.x`)

Seluruh 33 subnet (17 LAN + 16 link point-to-point `/30`) dialokasikan secara berurutan tanpa overlap mulai dari **`192.212.0.0`** hingga **`192.212.4.171`** (total **1.196 IP** di dalam Root Block `192.212.0.0/21`). Baris bertanda **`🔴`** merupakan 5 subnet pada jalur **`Dummy-Plug` → `Armisael`**.

| No | Kode | Subnet / Link | Gateway / Ujung | Network | Prefix | Gateway / IP #1 | Broadcast | Usable | IP Terpakai | Sisa |
| :---: | :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | S1 | Switch-Quarters | Rei | `192.212.0.0` | `/23` | `192.212.0.1` | `192.212.1.255` | 510 | 501 | 9 |
| 2 | S2 | Switch-Comm | Hikari | `192.212.2.0` | `/24` | `192.212.2.1` | `192.212.2.255` | 254 | 201 | 53 |
| 3 | S3 | Switch-Hangar | Yui | `192.212.3.0` | `/25` | `192.212.3.1` | `192.212.3.127` | 126 | 101 | 25 |
| 4 | S4 | Switch-Bunker | Kensuke | `192.212.3.128` | `/26` | `192.212.3.129` | `192.212.3.191` | 62 | 56 | 6 |
| 5 | S5 | Switch-Medic | Maya | `192.212.3.192` | `/27` | `192.212.3.193` | `192.212.3.223` | 30 | 27 | 3 |
| 6 | S6 | Switch-Relay | Kaworu | `192.212.3.224` | `/27` | `192.212.3.225` | `192.212.3.255` | 30 | 26 | 4 |
| 7 | S7 | Switch-Garden | Shinji | `192.212.4.0` | `/27` | `192.212.4.1` | `192.212.4.31` | 30 | 15 | 15 |
| 8 | S8 | Switch-Dock | Mari | `192.212.4.32` | `/28` | `192.212.4.33` | `192.212.4.47` | 14 | 13 | 1 |
| 9 | **S9** 🔴 | **Switch-Lab (Hop 1)** | **Ritsuko** | **`192.212.4.48`** | **`/29`** | **`192.212.4.49`** | **`192.212.4.55`** | **6** | **6** | **0** |
| 10 | S10 | Switch-Terminal | Fuyutsuki | `192.212.4.56` | `/29` | `192.212.4.57` | `192.212.4.63` | 6 | 4 | 2 |
| 11 | S11 | Switch-Cage | Misato | `192.212.4.64` | `/29` | `192.212.4.65` | `192.212.4.71` | 6 | 4 | 2 |
| 12 | S12 | Switch-Dogma | Toji | `192.212.4.72` | `/29` | `192.212.4.73` | `192.212.4.79` | 6 | 3 | 3 |
| 13 | **S13** 🔴 | **Switch-Monolith (Hop 5)** | **Shigeru** | **`192.212.4.80`** | **`/29`** | **`192.212.4.81`** | **`192.212.4.87`** | **6** | **3** | **3** |
| 14 | S14 | Switch-Radar | Makoto | `192.212.4.88` | `/29` | `192.212.4.89` | `192.212.4.95` | 6 | 5 | 1 |
| 15 | S15 | Switch-Archive | Asuka | `192.212.4.96` | `/30` | `192.212.4.97` | `192.212.4.99` | 2 | 2 | 0 |
| 16 | S16 | Switch-Intel | Kaji | `192.212.4.100` | `/30` | `192.212.4.101` | `192.212.4.103` | 2 | 2 | 0 |
| 17 | S17 | Switch-Cmd | Gendou | `192.212.4.104` | `/30` | `192.212.4.105` | `192.212.4.107` | 2 | 2 | 0 |
| 18 | L1 | Link Gendou–Yui | Gendou ↔ Yui | `192.212.4.108` | `/30` | `192.212.4.109` | `192.212.4.111` | 2 | 2 | 0 |
| 19 | L2 | Link Gendou–Hikari | Gendou ↔ Hikari | `192.212.4.112` | `/30` | `192.212.4.113` | `192.212.4.115` | 2 | 2 | 0 |
| 20 | **L3** 🔴 | **Link Gendou–Asuka (Hop 3)** | **Gendou ↔ Asuka** | **`192.212.4.116`** | **`/30`** | **`192.212.4.117`** | **`192.212.4.119`** | **2** | **2** | **0** |
| 21 | L4 | Link Gendou–Kaji | Gendou ↔ Kaji | `192.212.4.120` | `/30` | `192.212.4.121` | `192.212.4.123` | 2 | 2 | 0 |
| 22 | L5 | Link Gendou–Misato | Gendou ↔ Misato | `192.212.4.124` | `/30` | `192.212.4.125` | `192.212.4.127` | 2 | 2 | 0 |
| 23 | **L6** 🔴 | **Link Gendou–Shigeru (Hop 4)** | **Gendou ↔ Shigeru** | **`192.212.4.128`** | **`/30`** | **`192.212.4.129`** | **`192.212.4.131`** | **2** | **2** | **0** |
| 24 | L7 | Link Gendou–Fuyutsuki | Gendou ↔ Fuyutsuki | `192.212.4.132` | `/30` | `192.212.4.133` | `192.212.4.135` | 2 | 2 | 0 |
| 25 | L8 | Link Yui–Rei | Yui ↔ Rei | `192.212.4.136` | `/30` | `192.212.4.137` | `192.212.4.139` | 2 | 2 | 0 |
| 26 | L9 | Link Yui–Shinji | Yui ↔ Shinji | `192.212.4.140` | `/30` | `192.212.4.141` | `192.212.4.143` | 2 | 2 | 0 |
| 27 | L10 | Link Yui–Mari | Yui ↔ Mari | `192.212.4.144` | `/30` | `192.212.4.145` | `192.212.4.147` | 2 | 2 | 0 |
| 28 | L11 | Link Hikari–Kaworu | Hikari ↔ Kaworu | `192.212.4.148` | `/30` | `192.212.4.149` | `192.212.4.151` | 2 | 2 | 0 |
| 29 | L12 | Link Asuka–Kensuke | Asuka ↔ Kensuke | `192.212.4.152` | `/30` | `192.212.4.153` | `192.212.4.155` | 2 | 2 | 0 |
| 30 | **L13** 🔴 | **Link Asuka–Ritsuko (Hop 2)** | **Asuka ↔ Ritsuko** | **`192.212.4.156`** | **`/30`** | **`192.212.4.157`** | **`192.212.4.159`** | **2** | **2** | **0** |
| 31 | L14 | Link Fuyutsuki–Maya | Fuyutsuki ↔ Maya | `192.212.4.160` | `/30` | `192.212.4.161` | `192.212.4.163` | 2 | 2 | 0 |
| 32 | L15 | Link Fuyutsuki–Toji | Fuyutsuki ↔ Toji | `192.212.4.164` | `/30` | `192.212.4.165` | `192.212.4.167` | 2 | 2 | 0 |
| 33 | L16 | Link Shigeru–Makoto | Shigeru ↔ Makoto | `192.212.4.168` | `/30` | `192.212.4.169` | `192.212.4.171` | 2 | 2 | 0 |

### Penjelasan Hitungan Satu Subnet (`Switch-Garden` — S7)
1. **Kebutuhan Alamat:** `Switch-Garden` (di bawah router `Shinji`) melayani `Garden-Staff = 14` host ditambah `1` alamat untuk gateway router `Shinji`, sehingga total kebutuhan alamat usable adalah $14 + 1 = 15\text{ IP}$.
2. **Menentukan Jumlah Bit Host ($h$) & Prefix:** Kita mencari nilai $h$ terkecil yang memenuhi $2^h - 2 \ge 15$:
   - Jika $h = 4$ (`/28`): $2^4 - 2 = 14$ usable IP (tidak cukup karena kurang 1 IP).
   - Jika $h = 5$ (`/27`): $2^5 - 2 = 30$ usable IP (cukup dan merupakan prefix terkecil yang muat).
   - Maka dipilih prefix **`/27`** ($32 - 5 = 27$), netmask desimal **`255.255.255.224`**, dengan ukuran blok $2^5 = 32$ alamat.
3. **Menentukan Alamat Network, Gateway, Broadcast, dan Sisa:**
   - Subnet sebelumnya (`S6: Switch-Relay`) adalah `192.212.3.224/27` yang berakhir di `192.212.3.255`.
   - Maka `S7: Switch-Garden` dimulai pada alamat kelipatan 32 berikutnya: **`192.212.4.0/27`**.
   - **Gateway (`Shinji eth1`):** IP usable pertama = **`192.212.4.1`**.
   - **Host (`Garden-Staff`):** IP usable kedua = **`192.212.4.2`**.
   - **Broadcast:** $192.212.4.0 + 32 - 1 =$ **`192.212.4.31`**.
   - **Sisa IP Usable:** $30 - 15 =$ **`15` IP**.

### Pohon Pembagian IP VLSM (Jalur `Dummy-Plug` → `Armisael` Dilingkari)

![Pohon Pembagian IP VLSM Kelompok K-02](assets/pohon_ip_vlsm.png)

*Lima subnet pada jalur `Dummy-Plug` (`192.212.4.51`) → `Ritsuko` → `Asuka` → `Gendou` → `Shigeru` → `Armisael` (`192.212.4.83`) dilingkari merah: `192.212.4.48/29` (Hop 1), `192.212.4.156/30` (Hop 2), `192.212.4.116/30` (Hop 3), `192.212.4.128/30` (Hop 4), dan `192.212.4.80/29` (Hop 5).*

### Bukti Topologi GNS3
![Topologi GNS3 Operation Geofront](Screenshot/soal-1/topologi-gns3.png)
*Topologi jaringan Operation Geofront pada GNS3 kelompok K-02: 1 NAT (`NAT1`), 17 router (`Gendou` dan 16 router di bawahnya), 17 Ethernet switch, serta 25 host container (`ardhptr21/debinet:latest`) terpasang sesuai rancangan soal.*

---

## Soal 2 — Geofront Gelap Gulita

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Implementasi
- Seluruh 17 router dikonfigurasi menggunakan [`scripts/soal-2-router-ip.sh`](./scripts/soal-2-router-ip.sh) dengan konvensi seragam: `eth0` sebagai uplink (DHCP `NAT1` pada `Gendou`, parent router pada 16 router lainnya), `eth1` sebagai gateway LAN switch, dan `eth2+` menuju child router.
- IPv4 forwarding diaktifkan di seluruh 17 router (`sysctl -w net.ipv4.ip_forward=1`).

### Bukti dan Hasil
Pengujian dilakukan pada router pusat (`Gendou`), seluruh 5 router cabang Level 1 (`Yui`, `Fuyutsuki`, `Asuka`, `Shigeru`, `Hikari`), dan perwakilan leaf router Level 2 (`Ritsuko`) sehingga **seluruh 16 link router-ke-router teruji dua arah dengan 0% packet loss** dan `net.ipv4.ip_forward = 1` aktif.

1. **Router Pusat `Gendou` (`ip -br -4 a`, `ip_forward=1`, & Ping ke 7 Router Level 1):**
   ![Verifikasi Soal 2 Gendou](Screenshot/soal-2/gendou.png)
   *Seluruh 7 link Level 1 (`Yui`, `Hikari`, `Asuka`, `Kaji`, `Misato`, `Shigeru`, `Fuyutsuki`) berhasil di-ping dengan 0% packet loss.*

2. **Router Cabang `Yui` (5 Interface & Ping ke `Gendou`, `Rei`, `Shinji`, `Mari`):**
   ![Verifikasi Soal 2 Yui](Screenshot/soal-2/yui.png)

3. **Router Cabang `Fuyutsuki` (4 Interface & Ping ke `Gendou`, `Maya`, `Toji`):**
   ![Verifikasi Soal 2 Fuyutsuki](Screenshot/soal-2/fuyutsuki.png)

4. **Router Cabang `Asuka` (4 Interface & Ping ke `Gendou`, `Kensuke`, `Ritsuko`):**
   ![Verifikasi Soal 2 Asuka](Screenshot/soal-2/asuka.png)

5. **Router Cabang `Shigeru` (3 Interface & Ping ke `Gendou`, `Makoto`):**
   ![Verifikasi Soal 2 Shigeru](Screenshot/soal-2/shigeru.png)

6. **Router Cabang `Hikari` (3 Interface & Ping ke `Gendou`, `Kaworu`):**
   ![Verifikasi Soal 2 Hikari](Screenshot/soal-2/hikari.png)

7. **Perwakilan Leaf Router Level 2 `Ritsuko` (2 Interface & Ping Balik ke `Asuka`):**
   ![Verifikasi Soal 2 Ritsuko](Screenshot/soal-2/ritsuko.png)

---

## Soal 3 — Pulau-Pulau yang Terpisah

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Implementasi & Ringkasan CIDR
Seluruh 17 router dikonfigurasi menggunakan [`scripts/soal-3-routing.sh`](./scripts/soal-3-routing.sh):
- **11 Leaf Router** (`Kaji`, `Misato`, `Rei`, `Shinji`, `Mari`, `Kaworu`, `Kensuke`, `Ritsuko`, `Maya`, `Toji`, `Makoto`) masing-masing hanya memerlukan **1 default route ke atas**.
- **5 Branch Router Level 1** (`Yui`, `Hikari`, `Asuka`, `Shigeru`, `Fuyutsuki`) memiliki **1 default route ke Gendou** + rute spesifik subnet di bawahnya.
- **Gendou** memiliki default route ke `NAT1` + **21 static route** (diringkas dari 25 rute mentah melalui **4 penggabungan CIDR tepat**):

| Cabang (Next-Hop) | Subnet Asal 1 | Subnet Asal 2 | Hasil Ringkasan CIDR |
| :--- | :--- | :--- | :---: |
| **Shigeru** (`192.212.4.130`) | `192.212.4.80/29` (Switch-Monolith) | `192.212.4.88/29` (Switch-Radar) | **`192.212.4.80/28`** |
| **Yui** (`192.212.4.110`) | `192.212.4.136/30` (Link Yui–Rei) | `192.212.4.140/30` (Link Yui–Shinji) | **`192.212.4.136/29`** |
| **Asuka** (`192.212.4.118`) | `192.212.4.152/30` (Link Asuka–Kensuke) | `192.212.4.156/30` (Link Asuka–Ritsuko) | **`192.212.4.152/29`** |
| **Fuyutsuki** (`192.212.4.134`) | `192.212.4.160/30` (Link Fuyutsuki–Maya) | `192.212.4.164/30` (Link Fuyutsuki–Toji) | **`192.212.4.160/29`** |

### Bukti dan Hasil
1. **Tabel Routing `Gendou` (`default` ke `NAT1` + 21 static route termasuk 4 ringkasan CIDR tepat):**
   ![Tabel Routing Gendou](Screenshot/soal-3/ip-route-gendou.png)
   *Terlihat default route ke `192.168.122.1` (`eth0`) serta keempat rute ringkasan CIDR tepat: `192.212.4.80/28` (Shigeru), `192.212.4.136/29` (Yui), `192.212.4.152/29` (Asuka), dan `192.212.4.160/29` (Fuyutsuki).*

2. **Tabel Routing Perwakilan Router Cabang (`Yui`, `Shigeru`) dan Leaf Router (`Ritsuko`):**
   ![Tabel Routing Yui](Screenshot/soal-3/ip-route-yui.png)
   ![Tabel Routing Shigeru](Screenshot/soal-3/ip-route-shigeru.png)
   ![Tabel Routing Ritsuko](Screenshot/soal-3/ip-route-ritsuko.png)
   *Router cabang hanya memiliki 1 default route ke `Gendou` ditambah rute subnet di bawahnya, sedangkan leaf router (`Ritsuko`) cukup memiliki 1 default route ke `Asuka`.*

3. **Uji Ping Lintas Cabang dari `Armisael` (`192.212.4.83`) ke `Lilith`, `Sachiel`, dan `Comm-Net`:**
   ![Ping Armisael Lintas Cabang](Screenshot/soal-3/ping-armisael-antar-lan.png)
   *`Armisael` berhasil melakukan ping ke `Lilith` (`192.212.4.74`, 4 hop router `ttl=60`), `Sachiel` (`192.212.3.130`, 4 hop router `ttl=60`), dan `Comm-Net` (`192.212.2.2`, 3 hop router `ttl=61`) dengan 0% packet loss.*

---

## Soal 4 — Haus Kabar dari Dunia Luar

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Implementasi
Konfigurasi diterapkan melalui [`scripts/soal-4-nat.sh`](./scripts/soal-4-nat.sh) di `Gendou`:
```sh
iptables -t nat -A POSTROUTING -s 192.212.0.0/16 -o eth0 -j MASQUERADE
```
- Target **`MASQUERADE`** dipakai agar translasi otomatis mengikuti IP `eth0` dari DHCP `NAT1` meski IP berubah.
- Kriteria **`-s 192.212.0.0/16 -o eth0`** memastikan hanya trafik dari prefix internal menuju internet (`eth0`) yang diterjemahkan, sedangkan trafik antar-LAN (keluar lewat `eth1`–`eth8`) tetap membawa alamat asli pengirim.
- DNS resolver disetel ke `8.8.8.8` dan `1.1.1.1` pada `/etc/resolv.conf`.

### Bukti dan Hasil
1. **Uji Ping `8.8.8.8` & `deb.debian.org` dari `Armisael` dan `Lilith`:**
   ![Ping Internet Armisael](Screenshot/soal-4/ping-internet-armisael.png)
   ![Ping Internet Lilith](Screenshot/soal-4/ping-internet-lilith.png)
   *Baik `Armisael` maupun `Lilith` berhasil melakukan ping ke `8.8.8.8` dan me-resolve serta ping domain `deb.debian.org` (`debian.map.fastlydns.net`) dengan 0% packet loss.*

2. **Counter Rule NAT `POSTROUTING` di `Gendou`:**
   ![Counter NAT Gendou](Screenshot/soal-4/nat-counter-gendou.png)
   *Rule #1 `MASQUERADE` dengan sumber `192.212.0.0/16` keluar `eth0` mencatat counter aktif (`8 pkts`, `602 bytes`), membuktikan translasi hanya terjadi pada trafik internal keluar menuju `NAT1`.*

---

## Soal 5 — Pintu Depan Dikunci Rapat

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Implementasi (`/root/gendo.sh`)
Seluruh konfigurasi `Gendou` (Soal 2–5) disatukan secara idempoten pada [`scripts/gendo.sh`](./scripts/gendo.sh) (`/root/gendo.sh`):
```sh
# Chain INPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i eth0 -p udp --sport 67 --dport 68 -j ACCEPT
iptables -A INPUT ! -i eth0 -s 192.212.0.0/16 -j ACCEPT

# Chain FORWARD
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD ! -i eth0 -o eth0 -s 192.212.0.0/16 -j ACCEPT
iptables -A FORWARD ! -i eth0 ! -o eth0 -s 192.212.0.0/16 -d 192.212.0.0/16 -j ACCEPT

# Default Policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```
Koneksi baru dari sisi `NAT1` (`eth0`) otomatis ditolak oleh default policy `DROP`, sementara loopback, balasan DHCP (`udp 67->68`), koneksi `ESTABLISHED,RELATED`, akses internal ke internet, trafik antar-LAN, dan trafik internal ke `Gendou` tetap berjalan normal.

### Bukti dan Hasil
1. **Daftar Rule `iptables -S` & `iptables -t nat -S` di `Gendou`:**
   ![iptables -S Gendou](Screenshot/soal-5/iptables-s-gendou.png)
   *Default policy `INPUT` dan `FORWARD` telah dikunci menjadi `DROP`, dengan pengecualian loopback, DHCP `NAT1` (`udp 67->68`), stateful `RELATED,ESTABLISHED`, akses internal ke `Gendou`, internal ke internet (`eth0`), trafik antar-LAN, serta NAT `MASQUERADE`.*

2. **Bukti `Armisael` Tetap Bisa Ping `8.8.8.8`, Antar-LAN, dan ke `Gendou` Setelah Firewall Aktif:**
   ![Ping Armisael Setelah Firewall](Screenshot/soal-5/ping-armisael-after-fw.png)
   *Ping dari `Armisael` menuju internet (`8.8.8.8`), `Lilith` (`192.212.4.74`), dan `Gendou` (`192.212.4.129`) seluruhnya tetap berjalan normal dengan 0% packet loss.*

---

## Soal 6 — Alamat Para Pilot

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Implementasi
Seluruh **25 node non-router** (seluruh 42 container menggunakan `ardhptr21/debinet:latest`) dikonfigurasi IP statis dan default gateway permanen di `/etc/network/interfaces` menggunakan [`scripts/soal-6-hosts-static.sh`](./scripts/soal-6-hosts-static.sh) (otomatis memasang `ifupdown` & `netcat-traditional`) serta mekanisme auto-recovery [`scripts/init.sh`](./scripts/init.sh).

### Bukti dan Hasil
- Verifikasi `ip -br -4 a`, `/etc/network/interfaces`, dan `ping` ke gateway `192.212.4.65` (`Misato`) pada **`Unit-01`** (`192.212.4.66/29`) setelah container di-restart:
  ![Unit-01 IP dan Ping Gateway](Screenshot/soal-6/unit01-ip-ping-gw.png)
  *Setelah container `Unit-01` direstart, alamat IP `192.212.4.66/29`, subnet mask `255.255.255.248`, default gateway `192.212.4.65`, dan DNS resolver otomatis termuat kembali serta berhasil melakukan ping ke gateway `Misato` dengan 0% packet loss.*

---

## Soal 7 — Membangunkan MAGI

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Implementasi
Ketiga perangkat MAGI di `Switch-Terminal` dikonfigurasi melalui skrip masing-masing di `/root/`:
- [`scripts/casper.sh`](./scripts/casper.sh) (`/root/casper.sh`) → `Magi-Casper` (`192.212.4.58`), listener TCP **5000**
- [`scripts/balthasar.sh`](./scripts/balthasar.sh) (`/root/balthasar.sh`) → `Magi-Balthasar` (`192.212.4.59`), listener TCP **5000** & **5001**
- [`scripts/melchior.sh`](./scripts/melchior.sh) (`/root/melchior.sh`) → `Magi-Melchior` (`192.212.4.60`), listener TCP **5000**

### Bukti dan Hasil
1. **Pengiriman Pesan via `nc` dari `Lilith` ke 4 Port MAGI:**
   ![Lilith Kirim Pesan ke MAGI](Screenshot/soal-7/lilith-send-magi.png)
   *Pengiriman pesan dari `Lilith` (`192.212.4.74`) ke `Magi-Casper` (port `5000`), `Magi-Balthasar` (port `5000` & `5001`), dan `Magi-Melchior` (port `5000`) seluruhnya sukses dengan `exit=0`.*

2. **Pesan Masuk di `Magi-Casper` (`192.212.4.58`, TCP `5000`):**
   ![Log Pesan Masuk Magi-Casper](Screenshot/soal-7/magi-casper-log.png)

3. **Pesan Masuk di `Magi-Balthasar` (`192.212.4.59`, TCP `5000` & `5001`):**
   ![Log Pesan Masuk Magi-Balthasar](Screenshot/soal-7/magi-balthasar-log.png)

4. **Pesan Masuk di `Magi-Melchior` (`192.212.4.60`, TCP `5000`):**
   ![Log Pesan Masuk Magi-Melchior](Screenshot/soal-7/magi-melchior-log.png)
   *Seluruh pesan dari `Lilith` diterima secara persisten pada log listener masing-masing node MAGI (`/tmp/magi-5000.log` dan `/tmp/magi-5001.log`).*

---

## Soal 8 — Mengenali Kondisi Normal

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Implementasi
Layanan responder dikonfigurasi melalui [`scripts/penpen.sh`](./scripts/penpen.sh) dan [`scripts/tokyo3.sh`](./scripts/tokyo3.sh) menggunakan `netcat-traditional` (`nc -l -p <port> -e <handler>`):
- **`Pen-Pen` (`192.212.3.194`) port 80** → menjawab `Welcome to Pen-Pen`
- **`Tokyo3-Core` (`192.212.4.106`) port 80** → menjawab `Welcome to Tokyo3-Core`
- **`Tokyo3-Core` (`192.212.4.106`) port 8080** → menjawab `syifa imutz`

### Bukti dan Hasil
- Pengujian `nc` dari `Lilith` ke ketiga port layanan (berhasil semua dengan `exit=0`) serta pengujian port `22` yang tidak dilayani (`time nc -v -w 3 ... 22` langsung mengembalikan `Connection refused` dalam `0.34s–0.67s` dengan `exit=1` karena kernel tujuan membalas TCP `RST`, bukan menggantung hingga timeout 3 detik):
  ![Uji Layanan Pen-Pen dan Tokyo3-Core](Screenshot/soal-8/lilith-nc-services.png)
  *`Pen-Pen:80` menjawab `Welcome to Pen-Pen`, `Tokyo3-Core:80` menjawab `Welcome to Tokyo3-Core`, `Tokyo3-Core:8080` menjawab `syifa imutz` (semuanya `exit=0`), sedangkan port `22` pada kedua host langsung ditolak dengan `Connection refused` (`exit=1`).*

---

# Babak 2: Sabotase dan Hantu MAGI (Soal 9 – 12)

## Soal 9 — Jalur Belakang Diutak-Atik

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Analisis 4 Penyebab Sabotase (`break_routing.sh` di `Shigeru`)
Setelah menjalankan `break_routing.sh` di `Shigeru`, `Lilith` (`192.212.4.74`) tidak mendapat balasan ping dari `Armisael` (`192.212.4.83`), namun `Armisael` masih bisa ping gateway-nya (`192.212.4.81`). Hasil investigasi menemukan **4 penyebab sekaligus**:

1. **IPv4 Forwarding Dimatikan (`net.ipv4.ip_forward = 0`):** Shigeru berhenti meneruskan paket antar-interface. Ping dari `Armisael` ke gateway `192.212.4.81` tetap berhasil karena trafik lokal menuju router sendiri masuk chain `INPUT` dan tidak membutuhkan `ip_forward`.
2. **Default Route Dibelokkan ke `Makoto` (`default via 192.212.4.170 dev eth2`):** Seharusnya mengarah ke atas ke `Gendou` (`192.212.4.129 dev eth0`). Karena default route `Makoto` juga mengarah balik ke `Shigeru`, terjadi **routing loop** sampai TTL habis.
3. **Blackhole Route ke `Switch-Dogma` (`blackhole 192.212.4.72/29`):** Karena `/29` lebih spesifik (*longest-prefix match*) daripada default route, paket balasan menuju subnet `Lilith` langsung dibuang diam-diam oleh Shigeru.
4. **Policy-Based Routing (PBR) `ip rule` + Table `100`:** Rule `priority 90: from all iif eth1 lookup 100` dievaluasi sebelum tabel `main` (`priority 32766`), dan isi table `100` adalah `unreachable default`. Akibatnya, semua trafik dari LAN `Switch-Monolith` (`eth1`) yang hendak keluar subnet langsung dinyatakan *unreachable*, sementara ping ke gateway sendiri tetap sukses karena `priority 0: lookup local` tetap dieksekusi lebih dulu.

### Perbaikan
Dilakukan melalui [`scripts/soal-9-fix-shigeru.sh`](./scripts/soal-9-fix-shigeru.sh):
```sh
sysctl -w net.ipv4.ip_forward=1
ip route replace default via 192.212.4.129 dev eth0
ip route del blackhole 192.212.4.72/29
ip rule del iif eth1 lookup 100 priority 90
ip route flush table 100
```

### Bukti dan Hasil
1. **Gejala Sabotase (`Lilith` Gagal Ping `Armisael`, Namun `Armisael` Tetap Bisa Ping Gateway `Shigeru`):**
   ![Lilith Gagal Ping Armisael](Screenshot/soal-9/lilith-ping-armisael-gagal.png)
   ![Armisael Ping Gateway Shigeru](Screenshot/soal-9/armisael-ping-gw-sabotase.png)
   *Saat sabotase aktif, ping dari `Lilith` ke `Armisael` (`192.212.4.83`) mengalami 100% packet loss, sementara `Armisael` masih dapat melakukan ping ke gateway-nya (`192.212.4.81`) dengan 0% packet loss.*

2. **Diagnosis 4 Penyebab & Perbaikan di `Shigeru` (`diagnose` dan `fix`):**
   ![Diagnosis dan Fix Shigeru](Screenshot/soal-9/shigeru-diagnose-dan-fix.png)
   *Terlihat jelas seluruh 4 kerusakan (`net.ipv4.ip_forward = 0`, `default via 192.212.4.170 dev eth2`, `blackhole 192.212.4.72/29`, serta `ip rule` priority `90` ke `table 100` berisi `unreachable default`) dan seluruhnya berhasil dipulihkan.*

3. **Setelah Perbaikan (`Lilith` Kembali Berhasil Ping `Armisael`):**
   ![Lilith Ping Armisael Berhasil](Screenshot/soal-9/lilith-ping-armisael-berhasil.png)
   *Perbandingan sebelum dan sesudah perbaikan: ping `Lilith` ke `192.212.4.83` (`Armisael`) pulih menjadi 0% packet loss (`ttl=60`, RTT `1.59–1.83 ms`).*

---

## Soal 10 — Para Pilot Terkunci di Dalam

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Analisis 2 Penyebab Sabotase (`break_nat.sh` di `Misato` & `Gendou`)
1. **Di `Misato` (SNAT Palsu):** Terdapat rule `iptables -t nat -A POSTROUTING -s 192.212.4.64/29 ! -d 192.212.0.0/16 -o eth0 -j SNAT --to-source 172.31.99.1`.
   - Saat host di `Switch-Cage` (`Unit-01/02/00`) melakukan ping ke `8.8.8.8` (di luar `192.212.0.0/16`), `Misato` mengganti IP sumbernya menjadi `172.31.99.1`. Ketika tiba di `Gendou`, paket langsung dibuang oleh firewall `FORWARD DROP` (yang hanya mengizinkan `-s 192.212.0.0/16`) sekaligus tidak cocok dengan rule `MASQUERADE`.
   - Ping dari `Cage` ke `Lilith` (`192.212.4.74`) **tetap normal** karena tujuan berada di dalam `192.212.0.0/16` (tidak memenuhi `! -d 192.212.0.0/16`).
   - `Spy` di `Switch-Intel` (`192.212.4.102`, subnet `192.212.4.100/30`) **tidak terdampak** karena melewati router `Kaji` (bukan `Misato`) dan tidak cocok dengan `-s 192.212.4.64/29`.
2. **Di `Gendou` (Rule `RETURN` Posisi #1):** Terdapat rule `iptables -t nat -I POSTROUTING 1 -s 192.212.4.64/29 -o eth0 -j RETURN` tepat di atas rule `MASQUERADE`.
   - Meskipun SNAT palsu di `Misato` sudah dihapus, paket dari `Switch-Cage` yang keluar lewat `eth0` di `Gendou` langsung keluar dari chain `POSTROUTING` (bypass `MASQUERADE`) sehingga meluncur ke `NAT1` dengan IP privat `192.212.4.66` tanpa diterjemahkan.

### Jawaban Lokasi Translasi Alamat Sumber
- **Saat sabotase:** Alamat sumber `Switch-Cage` diterjemahkan secara keliru di router **`Misato`** menjadi `172.31.99.1`, dan gagal diterjemahkan di **`Gendou`** akibat rule `RETURN`.
- **Setelah perbaikan (kondisi benar):** Alamat sumber diterjemahkan **hanya di router `Gendou`** (`table nat`, chain `POSTROUTING`, keluar `eth0` dengan `MASQUERADE`). Router `Misato` tidak melakukan NAT sama sekali.

### Perbaikan
Dilakukan pada `Misato` dan `Gendou` menggunakan [`scripts/soal-10-fix-nat.sh`](./scripts/soal-10-fix-nat.sh).

### Bukti dan Hasil
1. **Gejala Sabotase (`Unit-01` Gagal ke `8.8.8.8` Namun Sukses ke `Lilith`, Sedangkan `Spy` Tetap Sukses ke `8.8.8.8`):**
   ![Gejala Sabotase Unit-01](Screenshot/soal-10/unit01-sabotase-gejala.png)
   ![Spy Ping Internet Saat Sabotase](Screenshot/soal-10/spy-ping-internet-sabotase.png)
   *Saat sabotase aktif, `Unit-01` (`Switch-Cage`) mengalami 100% packet loss ke `8.8.8.8`, tetapi ping antar-LAN ke `Lilith` (`192.212.4.74`) dan ping internet dari `Spy` (`Switch-Intel`) sama-sama tetap 0% packet loss.*

2. **Diagnosis & Perbaikan Tabel NAT di `Misato` dan `Gendou`:**
   ![Diagnosis dan Fix NAT Misato](Screenshot/soal-10/misato-diagnose-dan-fix.png)
   ![Diagnosis dan Fix NAT Gendou](Screenshot/soal-10/gendou-diagnose-dan-fix.png)
   *Terbukti pada `Misato` terdapat rule SNAT palsu `to:172.31.99.1` (tercatat `1 pkt, 84 bytes` yang mencegat paket internet `Unit-01`) dan pada `Gendou` terdapat rule #1 `RETURN` untuk `192.212.4.64/29` tepat di atas `MASQUERADE`. Setelah diperbaiki, chain `POSTROUTING` di `Misato` kosong total dan di `Gendou` kembali hanya berisi rule `MASQUERADE` `192.212.0.0/16` keluar `eth0`.*

3. **Setelah Perbaikan (`Unit-01` Kembali Berhasil Ping `8.8.8.8`):**
   ![Unit-01 Ping Internet Berhasil](Screenshot/soal-10/unit01-ping-internet-berhasil.png)
   *Setelah kedua rule sabotase dihapus, `Unit-01` kembali dapat mengakses internet (`8.8.8.8`) dengan 0% packet loss (`ttl=110`, RTT `22.2–22.6 ms`).*

---

## Soal 11 — Casper Harus Jadi Hantu

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Implementasi
Karena perangkat satu switch (`Magi-Balthasar` dan `Magi-Melchior` di `Switch-Terminal`) berkomunikasi langsung pada Layer 2 tanpa melewati router `Fuyutsuki`, aturan wajib dipasang sebagai **host-based firewall** di `Magi-Casper` sendiri melalui [`scripts/soal-11-casper-ghost.sh`](./scripts/soal-11-casper-ghost.sh):
```sh
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
```
- Dengan menyaring khusus `--icmp-type echo-request`, semua ping **masuk** ke Casper dibuang diam-diam, tetapi `echo-reply` untuk ping yang **dimulai Casper sendiri** tetap lolos. Layanan TCP `5000` tetap berjalan normal.

### Bukti dan Hasil
1. **Ping dari `Magi-Balthasar` (Satu Switch) & `Lilith` ke `Magi-Casper` Gagal, Namun TCP `5000` Tetap Hidup:**
   ![Balthasar Gagal Ping Casper](Screenshot/soal-11/balthasar-ping-casper-gagal.png)
   ![Lilith Gagal Ping Casper Tapi TCP 5000 Sukses](Screenshot/soal-11/lilith-ping-gagal-nc-sukses.png)
   *Baik `Magi-Balthasar` (satu switch `Switch-Terminal`) maupun `Lilith` mengalami 100% packet loss saat mem-ping `192.212.4.58`, sementara pengiriman pesan TCP port `5000` dari `Lilith` ke `Magi-Casper` tetap berhasil (`exit=0`).*

2. **Ping dari `Magi-Casper` ke `Magi-Balthasar` & `Lilith` Berhasil + Counter `iptables`:**
   ![Casper Ping Keluar Berhasil](Screenshot/soal-11/casper-ping-keluar-berhasil.png)
   *`Magi-Casper` tetap bisa mem-ping `Magi-Balthasar` (`0% loss`, `ttl=64`) dan `Lilith` (`0% loss`, `ttl=62`), sementara rule `DROP icmp icmptype 8` mencatat tepat `6 pkts` (`504 bytes`) yang dibuang (3 dari `Balthasar` + 3 dari `Lilith`).*

---

## Soal 12 — Teknisi yang Kelewat Semangat

> Dikerjakan oleh Maulana Zaki Putra Zakaria

### Analisis 4 Kesalahan Hardening (`break_fw.sh` di `Magi-Casper`)
1. **Tidak ada rule stateful `ESTABLISHED,RELATED` di `INPUT` dengan policy `INPUT DROP`:** Semua paket balasan untuk koneksi keluar Casper (balasan `ping 8.8.8.8`, balasan query DNS, dan paket HTTP repositori `apt-get update`) jatuh ke policy `DROP`.
2. **Rule `INPUT -p icmp -j DROP` terlalu luas:** Memblokir seluruh tipe ICMP termasuk `echo-reply`.
3. **Rule `OUTPUT -p udp --dport 53 -j DROP`:** Memblokir pengiriman query DNS keluar sehingga `apt-get update` gagal me-resolve `deb.debian.org`.
4. **TCP port `5000` belum dibuka di `INPUT`:** Koneksi `nc` dari `Unit-00` ke layanan MAGI port 5000 dibuang oleh policy `INPUT DROP`.

### Perbaikan Tanpa Membatalkan Tujuan Hardening
Diterapkan melalui [`scripts/soal-12-fix-casper-fw.sh`](./scripts/soal-12-fix-casper-fw.sh) dengan **tetap mempertahankan `policy INPUT DROP`**:
```sh
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT
iptables -P INPUT DROP
```
Rule `OUTPUT -p udp --dport 53 -j DROP` dihapus sehingga DNS keluar kembali berfungsi, sementara seluruh trafik masuk yang tidak diizinkan tetap diblokir dan ping masuk ke Casper tetap ditolak.

### Bukti dan Hasil
1. **Gejala Sabotase (`Magi-Casper` Gagal `ping 8.8.8.8` & `apt-get update`, `Unit-00` Gagal `nc` Port `5000`):**
   ![Casper Gagal Ping dan apt-get update](Screenshot/soal-12/casper-ping-apt-gagal.png)
   ![Unit-00 Gagal nc Port 5000](Screenshot/soal-12/unit00-nc-gagal-sabotase.png)
   *Akibat `break_fw.sh`, `ping 8.8.8.8` di `Magi-Casper` mengalami 100% packet loss, `apt-get update` gagal me-resolve `deb.debian.org`, dan `nc` dari `Unit-00` ke `192.212.4.58:5000` berakhir `Connection timed out` (`exit=1`).*

2. **Diagnosis 4 Kesalahan Hardening & Perbaikan di `Magi-Casper` (`diagnose` dan `fix`, Policy `INPUT DROP` Tetap Terjaga):**
   ![Diagnosis dan Fix Firewall Magi-Casper](Screenshot/soal-12/casper-diagnose-dan-fix.png)
   *Counter `diagnose` membuktikan secara langsung penyebab tiap gejala: `INPUT policy DROP` membuang `9 pkts` (`Unit-00:5000`), `INPUT -p icmp -j DROP` membuang `2 pkts` (`echo-reply 8.8.8.8`), dan `OUTPUT -p udp --dport 53 -j DROP` membuang `96 pkts` (query DNS `apt-get update`). Setelah `fix`, policy `-P INPUT DROP` tetap dipertahankan bersama aturan loopback, `RELATED,ESTABLISHED`, `icmp-type 8 DROP`, dan TCP `5000 ACCEPT`.*

3. **Bukti Setelah Perbaikan (`Unit-00` Sukses `nc` Port `5000` Namun Ping Tetap Ditolak; `Magi-Casper` Sukses `ping 8.8.8.8`, `apt-get update`, & Menerima Pesan):**
   ![Unit-00 Verifikasi Setelah Fix](Screenshot/soal-12/unit00-verifikasi-setelah-fix.png)
   ![Casper Ping apt-get update dan Log TCP 5000 Berhasil](Screenshot/soal-12/casper-apt-dan-log-berhasil.png)
   *`Magi-Casper` kembali berhasil melakukan `ping 8.8.8.8` (`0% loss`), `apt-get update` (`Fetched 90.7 kB in 0s`), dan menerima pesan `Halo Casper dari Unit-00 setelah fix` di `/tmp/magi-5000.log` (`exit=0`), sementara ping masuk dari `Unit-00` tetap 100% ditolak sesuai hardening & Soal 11.*

---

# Babak 3 & Final: Mengamankan MAGI, Zona Sensitif & Uji Kebakaran (Soal 13 – 20)

> Bagian ini dikerjakan oleh **Naila Anggun Eka Rizqy** (5027251122).

*(Placeholder untuk Soal 13 – 20 — akan digabungkan setelah bagian Babak 3 & Final selesai.)*
