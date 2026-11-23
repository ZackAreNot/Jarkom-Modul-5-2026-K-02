# Panduan Pengerjaan Lengkap & Checklist Screenshot — Modul 5 (Soal 1–12)
**Kelompok K-02** | **Prefix IP:** `192.212.x.x` | **Tema:** *Operation Geofront*  
**Dikerjakan oleh:** Maulana Zaki Putra Zakaria (Bagian Soal 1 – 12)

> **Catatan Penting Sebelum Mulai:**
> - Seluruh **42 container** menggunakan **`ardhptr21/debinet:latest`** (semua skrip di folder `scripts/` memakai POSIX `/bin/sh` yang jalan mulus dengan `sh /root/<nama>.sh` maupun `bash /root/<nama>.sh`).
> - Semua skrip di bawah sudah saya tulis dalam format **`cat << 'SCRIPT_EOF' > /root/<nama>.sh ... SCRIPT_EOF`** (versi multi-baris dari `echo "..." > file`, aman dari karakter `$` dan tanda kutip). Kamu tinggal **blok satu kotak kode → Copy → Paste ke console GNS3 node yang disebut → Enter**!
> - Simpan screenshot ke folder **`Screenshot/soal-X/`** dengan **nama file persis seperti tabel checklist**, agar nanti saya langsung masukkan ke `README.md`.
> - Pastikan **nama node (`hostname`) di GNS3 persis sama** dengan topologi (terutama `Gendou`, `Shigeru`, `Misato`, `Magi-Casper`, `Magi-Balthasar`, `Magi-Melchior`, `Pen-Pen`, `Tokyo3-Core`).

---

## Daftar Isi
- [Tahap 0: Persiapan Topologi & Pengkabelan GNS3](#tahap-0-persiapan-topologi--pengkabelan-gns3)
- [Peta Masukkin Script: Node Mana, File Apa, di Soal Berapa?](#peta-masukkin-script-node-mana-file-apa-di-soal-berapa)
- [Cara Memasukkan File `.sh` ke Node GNS3 (Format `cat`/`echo`)](#cara-memasukkan-file-sh-ke-node-gns3-format-catecho)
- [Soal 1 — Markas Tanpa Peta (VLSM & Pohon IP)](#soal-1--markas-tanpa-peta-vlsm--pohon-ip)
- [Soal 2 — Geofront Gelap Gulita (IP Interface Router & IP Forwarding)](#soal-2--geofront-gelap-gulita-ip-interface-router--ip-forwarding)
- [Soal 3 — Pulau-Pulau yang Terpisah (Static Routing & Ringkasan CIDR)](#soal-3--pulau-pulau-yang-terpisah-static-routing--ringkasan-cidr)
- [Soal 4 — Haus Kabar dari Dunia Luar (NAT MASQUERADE & DNS)](#soal-4--haus-kabar-dari-dunia-luar-nat-masquerade--dns)
- [Soal 5 — Pintu Depan Dikunci Rapat (`gendo.sh` Default Deny)](#soal-5--pintu-depan-dikunci-rapat-gendosh-default-deny)
- [Soal 6 — Alamat Para Pilot (IP Statis Permanen 25 Host + `init.sh`)](#soal-6--alamat-para-pilot-ip-statis-permanen-25-host--initsh)
- [Soal 7 — Membangunkan MAGI (Casper, Balthasar, Melchior)](#soal-7--membangunkan-magi-casper-balthasar-melchior)
- [Soal 8 — Mengenali Kondisi Normal (Pen-Pen & Tokyo3-Core)](#soal-8--mengenali-kondisi-normal-pen-pen--tokyo3-core)
- [Soal 9 — Sabotase: Jalur Belakang Diutak-Atik (`break_routing.sh`)](#soal-9--sabotase-jalur-belakang-diutak-atik-break_routingsh)
- [Soal 10 — Sabotase: Para Pilot Terkunci di Dalam (`break_nat.sh`)](#soal-10--sabotase-para-pilot-terkunci-di-dalam-break_natsh)
- [Soal 11 — Casper Harus Jadi Hantu (Blokir Ping Masuk)](#soal-11--casper-harus-jadi-hantu-blokir-ping-masuk)
- [Soal 12 — Sabotase: Teknisi yang Kelewat Semangat (`break_fw.sh`)](#soal-12--sabotase-teknisi-yang-kelewat-semangat-break_fwsh)
- [Troubleshooting Cepat](#troubleshooting-cepat)

---

## Tahap 0: Persiapan Topologi & Pengkabelan GNS3

Total perangkat pada canvas GNS3: **1 NAT1 + 17 Router + 17 Ethernet Switch + 25 Host Container = 60 objek**.

### 0.1 Daftar Image & Jumlah Adapter (Set di GNS3 *Configure → Network → Adapters* SEBELUM Tarik Kabel!)

#### A. 17 Router (Semua pakai `ardhptr21/debinet:latest`)
| No | Nama Node | Image Docker | Jumlah Adapter | Catatan Peran |
| :---: | :--- | :---: | :---: | :--- |
| 1 | **`Gendou`** | `ardhptr21/debinet:latest` | **9** (`eth0`–`eth8`) | Router pusat + NAT1 + Firewall (Soal 2–5, 10) |
| 2 | **`Yui`** | `ardhptr21/debinet:latest` | **5** (`eth0`–`eth4`) | Branch router (Rei, Shinji, Mari) |
| 3 | **`Asuka`** | `ardhptr21/debinet:latest` | **4** (`eth0`–`eth3`) | Branch router (Kensuke, Ritsuko) |
| 4 | **`Fuyutsuki`** | `ardhptr21/debinet:latest` | **4** (`eth0`–`eth3`) | Branch router + DNAT/`conntrack` (Soal 17 — Naila) |
| 5 | **`Hikari`** | `ardhptr21/debinet:latest` | **3** (`eth0`–`eth2`) | Branch router (Kaworu) |
| 6 | **`Shigeru`** | `ardhptr21/debinet:latest` | **3** (`eth0`–`eth2`) | Branch router + Zona Sensitif (Soal 9, 18, 19) |
| 7 | **`Misato`** | `ardhptr21/debinet:latest` | **2** (`eth0`–`eth1`) | Leaf router Switch-Cage (Soal 10 `break_nat.sh`) |
| 8–17 | **`Kaji`, `Rei`, `Shinji`, `Mari`, `Kaworu`, `Kensuke`, `Ritsuko`, `Maya`, `Toji`, `Makoto`** | `ardhptr21/debinet:latest` | **2** (`eth0`–`eth1`) | Leaf router (1 uplink `eth0` + 1 LAN `eth1`) |

#### B. 25 Host Non-Router (Semua pakai `ardhptr21/debinet:latest` — 1 Adapter: `eth0`)
- **Perangkat MAGI & Server:** `Magi-Casper`, `Magi-Balthasar`, `Magi-Melchior`, `Pen-Pen`, `Tokyo3-Core`
- **Pilot:** `Unit-01`, `Unit-02`, `Unit-00`, `Sachiel`
- **Staf Geofront:** `Lilith`, `Adam`
- **Terduga Dummy System:** `Entry-Plug`, `Dummy-Plug`, `Spy`
- **Zona Sensitif:** `Zeruel`, `Armisael`, `Radar-Array`
- **Lainnya:** `Quarters`, `Comm-Net`, `Hangar-Crew`, `Medic-Bay`, `Relay-Node`, `Garden-Staff`, `Dock-Crew`, `Archive-Vault`

> **Info Paket `debinet`:** Image `ardhptr21/debinet:latest` belum memiliki `ifupdown` & `netcat-traditional` secara bawaan. Jangan khawatir — skrip kita di Soal 4 (`Gendou`), Soal 6 (25 host), Soal 7 (MAGI), Soal 8 (`Pen-Pen`/`Tokyo3-Core`), dan `init.sh` (semua 42 node) sudah **otomatis memasang `ifupdown` dan `netcat-traditional`**!

### 0.2 Aturan Emas Pengkabelan (WAJIB IKUTI AGAR SCRIPT LANGSUNG JALAN!)

> **Pola seragam di SEMUA 17 Router:**
> - **`eth0`** = SELALU **Uplink** (`NAT1` pada Gendou, atau **Parent Router** pada 16 router lainnya)
> - **`eth1`** = SELALU **LAN Switch** milik router tersebut
> - **`eth2`, `eth3`, ...** = SELALU **Child Router** sesuai tabel di bawah!

| Router | `eth0` (Uplink) | `eth1` (LAN Switch) | `eth2` | `eth3` | `eth4` | `eth5` | `eth6` | `eth7` | `eth8` |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Gendou** | `NAT1` (`nat0`) | `Switch-Cmd` | `Yui` (`eth0`) | `Hikari` (`eth0`) | `Asuka` (`eth0`) | `Kaji` (`eth0`) | `Misato` (`eth0`) | `Shigeru` (`eth0`) | `Fuyutsuki` (`eth0`) |
| **Yui** | `Gendou` (`eth2`) | `Switch-Hangar` | `Rei` (`eth0`) | `Shinji` (`eth0`) | `Mari` (`eth0`) | — | — | — | — |
| **Hikari** | `Gendou` (`eth3`) | `Switch-Comm` | `Kaworu` (`eth0`) | — | — | — | — | — | — |
| **Asuka** | `Gendou` (`eth4`) | `Switch-Archive` | `Kensuke` (`eth0`) | `Ritsuko` (`eth0`) | — | — | — | — | — |
| **Kaji** | `Gendou` (`eth5`) | `Switch-Intel` | — | — | — | — | — | — | — |
| **Misato** | `Gendou` (`eth6`) | `Switch-Cage` | — | — | — | — | — | — | — |
| **Shigeru** | `Gendou` (`eth7`) | `Switch-Monolith` | `Makoto` (`eth0`) | — | — | — | — | — | — |
| **Fuyutsuki** | `Gendou` (`eth8`) | `Switch-Terminal` | `Maya` (`eth0`) | `Toji` (`eth0`) | — | — | — | — | — |
| **Rei** | `Yui` (`eth2`) | `Switch-Quarters` | — | — | — | — | — | — | — |
| **Shinji** | `Yui` (`eth3`) | `Switch-Garden` | — | — | — | — | — | — | — |
| **Mari** | `Yui` (`eth4`) | `Switch-Dock` | — | — | — | — | — | — | — |
| **Kaworu** | `Hikari` (`eth2`) | `Switch-Relay` | — | — | — | — | — | — | — |
| **Kensuke** | `Asuka` (`eth2`) | `Switch-Bunker` | — | — | — | — | — | — | — |
| **Ritsuko** | `Asuka` (`eth3`) | `Switch-Lab` | — | — | — | — | — | — | — |
| **Maya** | `Fuyutsuki` (`eth2`) | `Switch-Medic` | — | — | — | — | — | — | — |
| **Toji** | `Fuyutsuki` (`eth3`) | `Switch-Dogma` | — | — | — | — | — | — | — |
| **Makoto** | `Shigeru` (`eth2`) | `Switch-Radar` | — | — | — | — | — | — | — |

**Hubungkan 25 Host ke Switch masing-masing (port `eth0` di host → port bebas di switch):**
- `Switch-Quarters`: `Quarters`
- `Switch-Comm`: `Comm-Net`
- `Switch-Hangar`: `Hangar-Crew`
- `Switch-Bunker`: `Sachiel`
- `Switch-Medic`: `Pen-Pen`, `Medic-Bay`
- `Switch-Relay`: `Relay-Node`
- `Switch-Garden`: `Garden-Staff`
- `Switch-Dock`: `Dock-Crew`
- `Switch-Lab`: `Entry-Plug`, `Dummy-Plug`
- `Switch-Terminal`: `Magi-Casper`, `Magi-Balthasar`, `Magi-Melchior`
- `Switch-Cage`: `Unit-01`, `Unit-02`, `Unit-00`
- `Switch-Dogma`: `Lilith`, `Adam`
- `Switch-Monolith`: `Zeruel`, `Armisael`
- `Switch-Radar`: `Radar-Array`
- `Switch-Archive`: `Archive-Vault`
- `Switch-Intel`: `Spy`
- `Switch-Cmd`: `Tokyo3-Core`

---

## Peta Masukkin Script: Node Mana, File Apa, di Soal Berapa?

Ikuti tabel alur ini dari atas ke bawah — tiap soal sudah jelas **node mana** yang dibuka console-nya dan **file apa** yang dimasukkan ke `/root/`:

| Tahap / Soal | Buka Console Node Ini | File yang Dimasukkan ke `/root/` | Fungsi |
| :---: | :--- | :--- | :--- |
| **Soal 2** | Semua **17 Router** | `/root/soal-2-router-ip.sh` *(atau copas perintah singkat per router)* | Pasang IP tiap interface router + `ip_forward=1` |
| **Soal 3** | Semua **17 Router** + 4 Host Uji (`Armisael`, `Lilith`, `Sachiel`, `Comm-Net`) | `/root/soal-3-routing.sh` *(atau copas perintah singkat per node)* | Static routing + 4 ringkasan CIDR + IP sementara 4 node uji |
| **Soal 4** | **`Gendou`** saja | `/root/soal-4-nat.sh` | Install `iptables` + NAT `MASQUERADE` + DNS |
| **Soal 5** | **`Gendou`** saja | **`/root/gendo.sh`** *(wajib nama ini sesuai soal!)* | Gabungan Soal 2–4 + Firewall Default Deny `INPUT`/`FORWARD DROP` |
| **Soal 6** | Semua **25 Host Non-Router** (+ pasang **`/root/init.sh`** di semua 42 node agar tahan restart!) | `/root/soal-6-hosts-static.sh` dan **`/root/init.sh`** | IP statis permanen di `/etc/network/interfaces` + auto-recovery saat restart |
| **Soal 7** | **`Magi-Casper`**, **`Magi-Balthasar`**, **`Magi-Melchior`** | `/root/casper.sh`, `/root/balthasar.sh`, `/root/melchior.sh` | Install `iptables` & `netcat-traditional` + listener TCP 5000 (& 5001) |
| **Soal 8** | **`Pen-Pen`**, **`Tokyo3-Core`** | `/root/penpen.sh`, `/root/tokyo3.sh` | Responder TCP 80 (`Welcome to {hostname}`) & TCP 8080 (`syifa imutz`) |
| **Soal 9** | **`Shigeru`** | `/root/break_routing.sh` lalu `/root/soal-9-fix-shigeru.sh` | Jalankan sabotase → diagnosis 4 penyebab → perbaiki |
| **Soal 10** | **`Misato`** DAN **`Gendou`** | `/root/break_nat.sh` lalu `/root/soal-10-fix-nat.sh` | Jalankan sabotase di 2 router → diagnosis 2 penyebab → perbaiki |
| **Soal 11** | **`Magi-Casper`** | `/root/soal-11-casper-ghost.sh` | Blokir ping masuk di Casper (host-based `INPUT echo-request DROP`) |
| **Soal 12** | **`Magi-Casper`** | `/root/break_fw.sh` lalu `/root/soal-12-fix-casper-fw.sh` | Jalankan sabotase → diagnosis 4 masalah → perbaiki (policy `INPUT` tetap `DROP`!) |

---

## Cara Memasukkan File `.sh` ke Node GNS3 (Format `cat`/`echo`)

Di console container GNS3 (`debinet`), ada **3 cara** menulis & menyebar file ke `/root/`:

1. **Untuk file 1 baris (pakai `echo`):**
   ```sh
   echo "nameserver 8.8.8.8" > /etc/resolv.conf
   ```
2. **Untuk file script `.sh` banyak baris (pakai `cat << 'SCRIPT_EOF' > /root/<nama>.sh`):**
   Ini sama persis fungsinya dengan `echo "..." > /root/<nama>.sh`, tapi bisa menulis **banyak baris sekaligus** tanpa merusak tanda kutip (`"`, `'`) maupun variabel (`$NODE`, `$?`, `$(hostname)`):
   ```sh
   cat << 'SCRIPT_EOF' > /root/nama.sh
   #!/bin/sh
   ... isi script ...
   SCRIPT_EOF
   chmod +x /root/nama.sh
   sh /root/nama.sh
   ```
   > **Kenapa pakai `'SCRIPT_EOF'` (dengan tanda kutip tunggal)?**
   > 1. Tanda kutip tunggal `'SCRIPT_EOF'` mencegah shell mengubah `$variabel` saat file ditulis.
   > 2. Nama `SCRIPT_EOF` unik sehingga tidak bentrok dengan `EOF` milik `/etc/network/interfaces` di dalam skrip!

3. **Trik Super Cepat untuk 42 Node `debinet` (Distribusi `/root/init.sh` via `bash /dev/tcp` dari `Gendou` — Tanpa Perlu `nc` di Penerima!):**
   Karena seluruh 42 node memakai `debinet` yang sudah punya **`bash` bawaan**, kamu **tidak perlu copas `init.sh` 42 kali** dan penerima bahkan **belum perlu install `nc`**:
   - Cukup copas blok `cat << 'SCRIPT_EOF' > /root/init.sh` **SEKALI saja di `Gendou`** (`Gendou` sudah punya `nc` sejak Soal 4/5).
   - Di **`Gendou`**, jalankan server pengirim 1 baris:
     ```sh
     (while true; do nc -l -p 9999 -q 1 < /root/init.sh; done) </dev/null >/dev/null 2>&1 &
     ```
   - Lalu di **41 node lain** (router maupun host yang sudah punya IP & rute ke Gendou), cukup ketik **1 baris pendek ini**:
     ```sh
     bash -c 'cat < /dev/tcp/192.212.4.105/9999 > /root/init.sh' && chmod +x /root/init.sh && sh /root/init.sh
     ```
   - Setelah selesai semua node, matikan server port 9999 di `Gendou`: `pkill -f "nc -l -p 9999"`.

---

## Soal 1 — Markas Tanpa Peta (VLSM & Pohon IP)

### Yang Sudah Disiapkan di Repo (Tidak Perlu Dikerjakan Ulang!)
1. **Spreadsheet VLSM berformula lengkap:** `Spreadsheet Modul 5 Komdat Jarkom 2026 K02.xlsx` (4 sheet: *Perhitungan VLSM*, *Alokasi IP & Interface*, *Routing & Ringkasan CIDR*, *Jalur Dummy-Plug - Armisael*).
2. **Gambar Pohon IP VLSM** (dengan 5 subnet jalur `Dummy-Plug -> Armisael` dilingkari merah): `assets/pohon_ip_vlsm.png`.
3. **Verifikasi 5 Subnet Jalur `Dummy-Plug` (`192.212.4.51`) → `Armisael` (`192.212.4.83`):**
   - Hop 1: `192.212.4.48/29` (*Switch-Lab*)
   - Hop 2: `192.212.4.156/30` (*Link Asuka–Ritsuko*)
   - Hop 3: `192.212.4.116/30` (*Link Gendou–Asuka*)
   - Hop 4: `192.212.4.128/30` (*Link Gendou–Shigeru*)
   - Hop 5: `192.212.4.80/29` (*Switch-Monolith*)

### Screenshot yang Diperlukan untuk Soal 1
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-1/spreadsheet-vlsm.png` | Tampilan tabel VLSM 33 subnet di `Spreadsheet Modul 5 Komdat Jarkom 2026 K02.xlsx` (opsional) |
| `Screenshot/soal-1/topologi-gns3.png` | Tangkapan layar canvas GNS3 topologi lengkap *Operation Geofront* buatan kelompok K-02 setelah seluruh 60 objek terpasang & menyala (hijau) |

---

## Soal 2 — Geofront Gelap Gulita (IP Interface Router & IP Forwarding)

### Tujuan
Beri IP ke setiap interface pada **17 router** sesuai VLSM Soal 1, aktifkan `net.ipv4.ip_forward=1` di semua router, dan pastikan hanya **Gendou** (`eth0`) yang terhubung ke `NAT1` via DHCP.

### Cara Cepat — Copas Per-Router Langsung ke Console Masing-Masing (Paling Singkat!)
Buka console tiap router di GNS3, lalu copas blok masing-masing:

- **1. Di `Gendou`:**
  ```sh
  sysctl -w net.ipv4.ip_forward=1
  ip link set eth0 up
  if ! ip -4 addr show dev eth0 | grep -q "inet "; then
    if ! command -v dhclient >/dev/null 2>&1; then
      ip addr replace 192.168.122.100/24 dev eth0 && ip route replace default via 192.168.122.1
      echo "nameserver 8.8.8.8" > /etc/resolv.conf
      apt-get update -qq && apt-get install -y -qq isc-dhcp-client && ip addr flush dev eth0
    fi
    dhclient -1 eth0
  fi
  ip addr replace 192.212.4.105/30 dev eth1 && ip link set eth1 up
  ip addr replace 192.212.4.109/30 dev eth2 && ip link set eth2 up
  ip addr replace 192.212.4.113/30 dev eth3 && ip link set eth3 up
  ip addr replace 192.212.4.117/30 dev eth4 && ip link set eth4 up
  ip addr replace 192.212.4.121/30 dev eth5 && ip link set eth5 up
  ip addr replace 192.212.4.125/30 dev eth6 && ip link set eth6 up
  ip addr replace 192.212.4.129/30 dev eth7 && ip link set eth7 up
  ip addr replace 192.212.4.133/30 dev eth8 && ip link set eth8 up
  ```
- **2. Di `Yui`:**
  ```sh
  sysctl -w net.ipv4.ip_forward=1
  ip addr replace 192.212.4.110/30 dev eth0 && ip link set eth0 up
  ip addr replace 192.212.3.1/25   dev eth1 && ip link set eth1 up
  ip addr replace 192.212.4.137/30 dev eth2 && ip link set eth2 up
  ip addr replace 192.212.4.141/30 dev eth3 && ip link set eth3 up
  ip addr replace 192.212.4.145/30 dev eth4 && ip link set eth4 up
  ```
- **3. Di `Hikari`:**
  ```sh
  sysctl -w net.ipv4.ip_forward=1
  ip addr replace 192.212.4.114/30 dev eth0 && ip link set eth0 up
  ip addr replace 192.212.2.1/24   dev eth1 && ip link set eth1 up
  ip addr replace 192.212.4.149/30 dev eth2 && ip link set eth2 up
  ```
- **4. Di `Asuka`:**
  ```sh
  sysctl -w net.ipv4.ip_forward=1
  ip addr replace 192.212.4.118/30 dev eth0 && ip link set eth0 up
  ip addr replace 192.212.4.97/30  dev eth1 && ip link set eth1 up
  ip addr replace 192.212.4.153/30 dev eth2 && ip link set eth2 up
  ip addr replace 192.212.4.157/30 dev eth3 && ip link set eth3 up
  ```
- **5. Di `Shigeru`:**
  ```sh
  sysctl -w net.ipv4.ip_forward=1
  ip addr replace 192.212.4.130/30 dev eth0 && ip link set eth0 up
  ip addr replace 192.212.4.81/29  dev eth1 && ip link set eth1 up
  ip addr replace 192.212.4.169/30 dev eth2 && ip link set eth2 up
  ```
- **6. Di `Fuyutsuki`:**
  ```sh
  sysctl -w net.ipv4.ip_forward=1
  ip addr replace 192.212.4.134/30 dev eth0 && ip link set eth0 up
  ip addr replace 192.212.4.57/29  dev eth1 && ip link set eth1 up
  ip addr replace 192.212.4.161/30 dev eth2 && ip link set eth2 up
  ip addr replace 192.212.4.165/30 dev eth3 && ip link set eth3 up
  ```
- **7–17. Di 11 Leaf Router (copas 1 baris ke masing-masing router):**
  - **`Kaji`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.122/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.4.101/30 dev eth1; ip link set eth1 up`
  - **`Misato`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.126/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.4.65/29 dev eth1; ip link set eth1 up`
  - **`Rei`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.138/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.0.1/23 dev eth1; ip link set eth1 up`
  - **`Shinji`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.142/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.4.1/27 dev eth1; ip link set eth1 up`
  - **`Mari`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.146/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.4.33/28 dev eth1; ip link set eth1 up`
  - **`Kaworu`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.150/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.3.225/27 dev eth1; ip link set eth1 up`
  - **`Kensuke`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.154/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.3.129/26 dev eth1; ip link set eth1 up`
  - **`Ritsuko`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.158/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.4.49/29 dev eth1; ip link set eth1 up`
  - **`Maya`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.162/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.3.193/27 dev eth1; ip link set eth1 up`
  - **`Toji`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.166/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.4.73/29 dev eth1; ip link set eth1 up`
  - **`Makoto`**: `sysctl -w net.ipv4.ip_forward=1; ip addr replace 192.212.4.170/30 dev eth0; ip link set eth0 up; ip addr replace 192.212.4.89/29 dev eth1; ip link set eth1 up`

### Alternatif: Simpan File `/root/soal-2-router-ip.sh` (Universal 17 Router)
Jika ingin menyimpan sebagai file script di `/root/soal-2-router-ip.sh` (termasuk fitur `--ping-links`), copas blok ini ke router:
```sh
cat << 'SCRIPT_EOF' > /root/soal-2-router-ip.sh
#!/bin/sh
# ==============================================================================
# soal-2-router-ip.sh - Soal 2: IP Interface & IPv4 Forwarding Semua 17 Router
# Praktikum Jarkom Modul 5 - Kelompok K-02 (Prefix: 192.212.x.x)
#
# Penggunaan:
#   sh /root/soal-2-router-ip.sh              # Otomatis deteksi hostname
#   sh /root/soal-2-router-ip.sh Gendou       # Paksa nama router tertentu
#   sh /root/soal-2-router-ip.sh --ping-links # Uji ping ke semua peer link router
# ==============================================================================

set -u

MODE="setup"
NODE_ARG=""
if [ "${1:-}" = "--ping-links" ]; then
    MODE="ping"
    NODE_ARG="${2:-}"
else
    NODE_ARG="${1:-}"
fi

NODE_RAW="${NODE_ARG:-$(hostname)}"
NODE=$(printf '%s' "$NODE_RAW" | tr '[:upper:]' '[:lower:]')

enable_fwd() {
    sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || echo 1 > /proc/sys/net/ipv4/ip_forward
    mkdir -p /etc/sysctl.d 2>/dev/null || true
    echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ipforward.conf 2>/dev/null || true
}

set_if() {
    ip addr replace "$2" dev "$1"
    ip link set "$1" up
}

ping_peer() {
    printf "  -> Ping %-14s (%s): " "$1" "$2"
    if ping -c 2 -W 2 "$2" >/dev/null 2>&1; then
        echo "OK"
    else
        echo "GAGAL"
    fi
}

if [ "$MODE" = "ping" ]; then
    echo "=== [Soal 2] Uji Ping Link Router-ke-Router dari $NODE_RAW ==="
    case "$NODE" in
        *gendo*)
            ping_peer "Yui"       192.212.4.110
            ping_peer "Hikari"    192.212.4.114
            ping_peer "Asuka"     192.212.4.118
            ping_peer "Kaji"      192.212.4.122
            ping_peer "Misato"    192.212.4.126
            ping_peer "Shigeru"   192.212.4.130
            ping_peer "Fuyutsuki" 192.212.4.134
            ;;
        *yui*)
            ping_peer "Gendou" 192.212.4.109
            ping_peer "Rei"    192.212.4.138
            ping_peer "Shinji" 192.212.4.142
            ping_peer "Mari"   192.212.4.146
            ;;
        *hikari*)
            ping_peer "Gendou" 192.212.4.113
            ping_peer "Kaworu" 192.212.4.150
            ;;
        *asuka*)
            ping_peer "Gendou"  192.212.4.117
            ping_peer "Kensuke" 192.212.4.154
            ping_peer "Ritsuko" 192.212.4.158
            ;;
        *kaji*)      ping_peer "Gendou"    192.212.4.121 ;;
        *misato*)    ping_peer "Gendou"    192.212.4.125 ;;
        *shigeru*)
            ping_peer "Gendou" 192.212.4.129
            ping_peer "Makoto" 192.212.4.170
            ;;
        *fuyutsuki*)
            ping_peer "Gendou" 192.212.4.133
            ping_peer "Maya"   192.212.4.162
            ping_peer "Toji"   192.212.4.166
            ;;
        *rei*)       ping_peer "Yui"       192.212.4.137 ;;
        *shinji*)    ping_peer "Yui"       192.212.4.141 ;;
        *mari*)      ping_peer "Yui"       192.212.4.145 ;;
        *kaworu*)    ping_peer "Hikari"    192.212.4.149 ;;
        *kensuke*)   ping_peer "Asuka"     192.212.4.153 ;;
        *ritsuko*)   ping_peer "Asuka"     192.212.4.157 ;;
        *maya*)      ping_peer "Fuyutsuki" 192.212.4.161 ;;
        *toji*)      ping_peer "Fuyutsuki" 192.212.4.165 ;;
        *makoto*)    ping_peer "Shigeru"   192.212.4.169 ;;
        *) echo "Router '$NODE_RAW' tidak dikenali."; exit 1 ;;
    esac
    exit 0
fi

echo "=== [Soal 2] Setup IP Interface & IPv4 Forwarding pada Router: $NODE_RAW ==="
enable_fwd

case "$NODE" in
    *gendo*)
        ip link set eth0 up
        if ! ip -4 addr show dev eth0 | grep -q "inet "; then
            if ! command -v dhclient >/dev/null 2>&1 && ! command -v udhcpc >/dev/null 2>&1; then
                echo "[+] dhclient belum ada di debinet, pasang isc-dhcp-client lewat NAT1..."
                ip addr replace 192.168.122.100/24 dev eth0
                ip route replace default via 192.168.122.1
                printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
                apt-get update -qq && apt-get install -y -qq isc-dhcp-client
                ip addr flush dev eth0
            fi
            dhclient -1 eth0 2>/dev/null || udhcpc -i eth0 -n -q 2>/dev/null || true
            if ! ip -4 addr show dev eth0 | grep -q "inet "; then
                echo "[!] DHCP NAT1 tidak merespons, fallback ke 192.168.122.212/24 via 192.168.122.1"
                ip addr replace 192.168.122.212/24 dev eth0
                ip route replace default via 192.168.122.1 dev eth0
            fi
        fi
        set_if eth1 192.212.4.105/30
        set_if eth2 192.212.4.109/30
        set_if eth3 192.212.4.113/30
        set_if eth4 192.212.4.117/30
        set_if eth5 192.212.4.121/30
        set_if eth6 192.212.4.125/30
        set_if eth7 192.212.4.129/30
        set_if eth8 192.212.4.133/30
        ;;
    *yui*)
        set_if eth0 192.212.4.110/30
        set_if eth1 192.212.3.1/25
        set_if eth2 192.212.4.137/30
        set_if eth3 192.212.4.141/30
        set_if eth4 192.212.4.145/30
        ;;
    *hikari*)
        set_if eth0 192.212.4.114/30
        set_if eth1 192.212.2.1/24
        set_if eth2 192.212.4.149/30
        ;;
    *asuka*)
        set_if eth0 192.212.4.118/30
        set_if eth1 192.212.4.97/30
        set_if eth2 192.212.4.153/30
        set_if eth3 192.212.4.157/30
        ;;
    *kaji*)
        set_if eth0 192.212.4.122/30
        set_if eth1 192.212.4.101/30
        ;;
    *misato*)
        set_if eth0 192.212.4.126/30
        set_if eth1 192.212.4.65/29
        ;;
    *shigeru*)
        set_if eth0 192.212.4.130/30
        set_if eth1 192.212.4.81/29
        set_if eth2 192.212.4.169/30
        ;;
    *fuyutsuki*)
        set_if eth0 192.212.4.134/30
        set_if eth1 192.212.4.57/29
        set_if eth2 192.212.4.161/30
        set_if eth3 192.212.4.165/30
        ;;
    *rei*)
        set_if eth0 192.212.4.138/30
        set_if eth1 192.212.0.1/23
        ;;
    *shinji*)
        set_if eth0 192.212.4.142/30
        set_if eth1 192.212.4.1/27
        ;;
    *mari*)
        set_if eth0 192.212.4.146/30
        set_if eth1 192.212.4.33/28
        ;;
    *kaworu*)
        set_if eth0 192.212.4.150/30
        set_if eth1 192.212.3.225/27
        ;;
    *kensuke*)
        set_if eth0 192.212.4.154/30
        set_if eth1 192.212.3.129/26
        ;;
    *ritsuko*)
        set_if eth0 192.212.4.158/30
        set_if eth1 192.212.4.49/29
        ;;
    *maya*)
        set_if eth0 192.212.4.162/30
        set_if eth1 192.212.3.193/27
        ;;
    *toji*)
        set_if eth0 192.212.4.166/30
        set_if eth1 192.212.4.73/29
        ;;
    *makoto*)
        set_if eth0 192.212.4.170/30
        set_if eth1 192.212.4.89/29
        ;;
    *)
        echo "[ERROR] Hostname '$NODE_RAW' bukan salah satu dari 17 router Geofront."
        exit 1
        ;;
esac

echo "[OK] Selesai! Status ip_forward & interface:"
sysctl net.ipv4.ip_forward 2>/dev/null || cat /proc/sys/net/ipv4/ip_forward
ip -br -4 addr show
SCRIPT_EOF
chmod +x /root/soal-2-router-ip.sh
sh /root/soal-2-router-ip.sh
```

### Test Case & Bukti Verifikasi (Soal 2)
1. Di **setiap router**:
   ```sh
   ip -br a && sysctl net.ipv4.ip_forward
   ```
2. **Ping dua ujung tiap 16 link router-ke-router:**
   - Dari **`Gendou`** (menguji 7 link L1):
     ```sh
     for ip in 192.212.4.110 192.212.4.114 192.212.4.118 192.212.4.122 192.212.4.126 192.212.4.130 192.212.4.134; do ping -c 2 -W 1 $ip; done
     ```
   - Dari **`Yui`** (L8, L9, L10 + Gendou):
     ```sh
     for ip in 192.212.4.109 192.212.4.138 192.212.4.142 192.212.4.146; do ping -c 2 -W 1 $ip; done
     ```
   - Dari **`Hikari`** (L11 + Gendou): `ping -c 2 192.212.4.113 && ping -c 2 192.212.4.150`
   - Dari **`Asuka`** (L12, L13 + Gendou): `ping -c 2 192.212.4.117 && ping -c 2 192.212.4.154 && ping -c 2 192.212.4.158`
   - Dari **`Fuyutsuki`** (L14, L15 + Gendou): `ping -c 2 192.212.4.133 && ping -c 2 192.212.4.162 && ping -c 2 192.212.4.166`
   - Dari **`Shigeru`** (L16 + Gendou): `ping -c 2 192.212.4.129 && ping -c 2 192.212.4.170`

### Checklist Screenshot Soal 2
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-2/ip-br-gendou-level1.png` | Output `ip -br a` + `ip_forward=1` di `Gendou` & 7 router Level 1 |
| `Screenshot/soal-2/ip-br-level2.png` | Output `ip -br a` + `ip_forward=1` di 9 router Level 2 |
| `Screenshot/soal-2/ping-links-level1.png` | Bukti ping 7 link Gendou ↔ Level 1 (0% loss) |
| `Screenshot/soal-2/ping-links-level2.png` | Bukti ping 9 link Level 1 ↔ Level 2 (0% loss) |

---

## Soal 3 — Pulau-Pulau yang Terpisah (Static Routing & Ringkasan CIDR)

### Tujuan
Pasang static routing minimal di semua 17 router dengan **4 ringkasan CIDR tepat di `Gendou`** (`192.212.4.80/28`, `192.212.4.136/29`, `192.212.4.152/29`, `192.212.4.160/29`), serta IP & gateway **sementara** di 4 node uji: `Armisael`, `Lilith`, `Sachiel`, `Comm-Net`.

### Cara Cepat — Copas Per-Node Langsung ke Console GNS3
- **Di `Gendou` (21 rute dengan 4 ringkasan CIDR):**
  ```sh
  # Cabang Yui (via 192.212.4.110)
  ip route replace 192.212.0.0/23   via 192.212.4.110 dev eth2
  ip route replace 192.212.3.0/25   via 192.212.4.110 dev eth2
  ip route replace 192.212.4.0/27   via 192.212.4.110 dev eth2
  ip route replace 192.212.4.32/28  via 192.212.4.110 dev eth2
  ip route replace 192.212.4.136/29 via 192.212.4.110 dev eth2
  ip route replace 192.212.4.144/30 via 192.212.4.110 dev eth2
  # Cabang Hikari (via 192.212.4.114)
  ip route replace 192.212.2.0/24   via 192.212.4.114 dev eth3
  ip route replace 192.212.3.224/27 via 192.212.4.114 dev eth3
  ip route replace 192.212.4.148/30 via 192.212.4.114 dev eth3
  # Cabang Asuka (via 192.212.4.118)
  ip route replace 192.212.3.128/26 via 192.212.4.118 dev eth4
  ip route replace 192.212.4.48/29  via 192.212.4.118 dev eth4
  ip route replace 192.212.4.96/30  via 192.212.4.118 dev eth4
  ip route replace 192.212.4.152/29 via 192.212.4.118 dev eth4
  # Cabang Kaji & Misato
  ip route replace 192.212.4.100/30 via 192.212.4.122 dev eth5
  ip route replace 192.212.4.64/29  via 192.212.4.126 dev eth6
  # Cabang Shigeru (via 192.212.4.130)
  ip route replace 192.212.4.80/28  via 192.212.4.130 dev eth7
  ip route replace 192.212.4.168/30 via 192.212.4.130 dev eth7
  # Cabang Fuyutsuki (via 192.212.4.134)
  ip route replace 192.212.3.192/27 via 192.212.4.134 dev eth8
  ip route replace 192.212.4.56/29  via 192.212.4.134 dev eth8
  ip route replace 192.212.4.72/29  via 192.212.4.134 dev eth8
  ip route replace 192.212.4.160/29 via 192.212.4.134 dev eth8
  ```
- **Di 5 Branch Router Level 1:**
  - **`Yui`**: `ip route replace default via 192.212.4.109; ip route replace 192.212.0.0/23 via 192.212.4.138; ip route replace 192.212.4.0/27 via 192.212.4.142; ip route replace 192.212.4.32/28 via 192.212.4.146`
  - **`Hikari`**: `ip route replace default via 192.212.4.113; ip route replace 192.212.3.224/27 via 192.212.4.150`
  - **`Asuka`**: `ip route replace default via 192.212.4.117; ip route replace 192.212.3.128/26 via 192.212.4.154; ip route replace 192.212.4.48/29 via 192.212.4.158`
  - **`Shigeru`**: `ip route replace default via 192.212.4.129; ip route replace 192.212.4.88/29 via 192.212.4.170`
  - **`Fuyutsuki`**: `ip route replace default via 192.212.4.133; ip route replace 192.212.3.192/27 via 192.212.4.162; ip route replace 192.212.4.72/29 via 192.212.4.166`
- **Di 11 Leaf Router (cukup 1 default route):**
  - **`Kaji`**: `ip route replace default via 192.212.4.121`
  - **`Misato`**: `ip route replace default via 192.212.4.125`
  - **`Rei`**: `ip route replace default via 192.212.4.137`
  - **`Shinji`**: `ip route replace default via 192.212.4.141`
  - **`Mari`**: `ip route replace default via 192.212.4.145`
  - **`Kaworu`**: `ip route replace default via 192.212.4.149`
  - **`Kensuke`**: `ip route replace default via 192.212.4.153`
  - **`Ritsuko`**: `ip route replace default via 192.212.4.157`
  - **`Maya`**: `ip route replace default via 192.212.4.161`
  - **`Toji`**: `ip route replace default via 192.212.4.165`
  - **`Makoto`**: `ip route replace default via 192.212.4.169`
- **Di 4 Node Uji Sementara (Soal 3–5):**
  - **`Armisael`**: `ip addr replace 192.212.4.83/29 dev eth0 && ip link set eth0 up && ip route replace default via 192.212.4.81 && echo "nameserver 8.8.8.8" > /etc/resolv.conf`
  - **`Lilith`**: `ip addr replace 192.212.4.74/29 dev eth0 && ip link set eth0 up && ip route replace default via 192.212.4.73 && echo "nameserver 8.8.8.8" > /etc/resolv.conf`
  - **`Sachiel`**: `ip addr replace 192.212.3.130/26 dev eth0 && ip link set eth0 up && ip route replace default via 192.212.3.129 && echo "nameserver 8.8.8.8" > /etc/resolv.conf`
  - **`Comm-Net`**: `ip addr replace 192.212.2.2/24 dev eth0 && ip link set eth0 up && ip route replace default via 192.212.2.1 && echo "nameserver 8.8.8.8" > /etc/resolv.conf`

### Alternatif: Simpan File `/root/soal-3-routing.sh` (Universal 17 Router + 4 Host Uji)
Jika ingin menyimpan sebagai file script di `/root/soal-3-routing.sh`, copas blok ini:
```sh
cat << 'SCRIPT_EOF' > /root/soal-3-routing.sh
#!/bin/sh
# ==============================================================================
# soal-3-routing.sh - Soal 3: Static Routing Minimal + Ringkasan CIDR
# Praktikum Jarkom Modul 5 - Kelompok K-02 (Prefix: 192.212.x.x)
#
# Juga mendukung IP & gateway sementara pada 4 node uji Soal 3-5:
#   Armisael, Lilith, Sachiel, Comm-Net
#
# Penggunaan:
#   sh /root/soal-3-routing.sh            # Otomatis deteksi hostname
#   sh /root/soal-3-routing.sh <hostname> # Paksa nama node
# ==============================================================================

set -u

NODE_RAW="${1:-$(hostname)}"
NODE=$(printf '%s' "$NODE_RAW" | tr '[:upper:]' '[:lower:]')

echo "=== [Soal 3] Konfigurasi Routing Statis pada: $NODE_RAW ==="

case "$NODE" in
    *gendo*)
        # 21 rute statis optimal (4 ringkasan CIDR tepat)
        # Cabang Yui (via 192.212.4.110)
        ip route replace 192.212.0.0/23   via 192.212.4.110 dev eth2
        ip route replace 192.212.3.0/25   via 192.212.4.110 dev eth2
        ip route replace 192.212.4.0/27   via 192.212.4.110 dev eth2
        ip route replace 192.212.4.32/28  via 192.212.4.110 dev eth2
        ip route replace 192.212.4.136/29 via 192.212.4.110 dev eth2  # Summary Yui-Rei + Yui-Shinji
        ip route replace 192.212.4.144/30 via 192.212.4.110 dev eth2
        # Cabang Hikari (via 192.212.4.114)
        ip route replace 192.212.2.0/24   via 192.212.4.114 dev eth3
        ip route replace 192.212.3.224/27 via 192.212.4.114 dev eth3
        ip route replace 192.212.4.148/30 via 192.212.4.114 dev eth3
        # Cabang Asuka (via 192.212.4.118)
        ip route replace 192.212.3.128/26 via 192.212.4.118 dev eth4
        ip route replace 192.212.4.48/29  via 192.212.4.118 dev eth4
        ip route replace 192.212.4.96/30  via 192.212.4.118 dev eth4
        ip route replace 192.212.4.152/29 via 192.212.4.118 dev eth4  # Summary Asuka-Kensuke + Asuka-Ritsuko
        # Cabang Kaji (via 192.212.4.122)
        ip route replace 192.212.4.100/30 via 192.212.4.122 dev eth5
        # Cabang Misato (via 192.212.4.126)
        ip route replace 192.212.4.64/29  via 192.212.4.126 dev eth6
        # Cabang Shigeru (via 192.212.4.130)
        ip route replace 192.212.4.80/28  via 192.212.4.130 dev eth7  # Summary Monolith + Radar
        ip route replace 192.212.4.168/30 via 192.212.4.130 dev eth7
        # Cabang Fuyutsuki (via 192.212.4.134)
        ip route replace 192.212.3.192/27 via 192.212.4.134 dev eth8
        ip route replace 192.212.4.56/29  via 192.212.4.134 dev eth8
        ip route replace 192.212.4.72/29  via 192.212.4.134 dev eth8
        ip route replace 192.212.4.160/29 via 192.212.4.134 dev eth8  # Summary Fuyutsuki-Maya + Fuyutsuki-Toji
        ;;
    *yui*)
        ip route replace default          via 192.212.4.109 dev eth0
        ip route replace 192.212.0.0/23   via 192.212.4.138 dev eth2
        ip route replace 192.212.4.0/27   via 192.212.4.142 dev eth3
        ip route replace 192.212.4.32/28  via 192.212.4.146 dev eth4
        ;;
    *hikari*)
        ip route replace default          via 192.212.4.113 dev eth0
        ip route replace 192.212.3.224/27 via 192.212.4.150 dev eth2
        ;;
    *asuka*)
        ip route replace default          via 192.212.4.117 dev eth0
        ip route replace 192.212.3.128/26 via 192.212.4.154 dev eth2
        ip route replace 192.212.4.48/29  via 192.212.4.158 dev eth3
        ;;
    *shigeru*)
        ip route replace default          via 192.212.4.129 dev eth0
        ip route replace 192.212.4.88/29  via 192.212.4.170 dev eth2
        ;;
    *fuyutsuki*)
        ip route replace default          via 192.212.4.133 dev eth0
        ip route replace 192.212.3.192/27 via 192.212.4.162 dev eth2
        ip route replace 192.212.4.72/29  via 192.212.4.166 dev eth3
        ;;
    # 11 Leaf Router (cukup 1 default route ke atas)
    *kaji*)      ip route replace default via 192.212.4.121 dev eth0 ;;
    *misato*)    ip route replace default via 192.212.4.125 dev eth0 ;;
    *rei*)       ip route replace default via 192.212.4.137 dev eth0 ;;
    *shinji*)    ip route replace default via 192.212.4.141 dev eth0 ;;
    *mari*)      ip route replace default via 192.212.4.145 dev eth0 ;;
    *kaworu*)    ip route replace default via 192.212.4.149 dev eth0 ;;
    *kensuke*)   ip route replace default via 192.212.4.153 dev eth0 ;;
    *ritsuko*)   ip route replace default via 192.212.4.157 dev eth0 ;;
    *maya*)      ip route replace default via 192.212.4.161 dev eth0 ;;
    *toji*)      ip route replace default via 192.212.4.165 dev eth0 ;;
    *makoto*)    ip route replace default via 192.212.4.169 dev eth0 ;;

    # 4 Node Uji Sementara untuk Soal 3-5 (IP permanen dibuat di Soal 6)
    *armisael*)
        ip addr replace 192.212.4.83/29 dev eth0 && ip link set eth0 up
        ip route replace default via 192.212.4.81 dev eth0
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
        ;;
    *lilith*)
        ip addr replace 192.212.4.74/29 dev eth0 && ip link set eth0 up
        ip route replace default via 192.212.4.73 dev eth0
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
        ;;
    *sachiel*)
        ip addr replace 192.212.3.130/26 dev eth0 && ip link set eth0 up
        ip route replace default via 192.212.3.129 dev eth0
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
        ;;
    *comm-net*|*commnet*)
        ip addr replace 192.212.2.2/24 dev eth0 && ip link set eth0 up
        ip route replace default via 192.212.2.1 dev eth0
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
        ;;
    *)
        echo "[ERROR] Node '$NODE_RAW' tidak dikenali untuk Soal 3."
        exit 1
        ;;
esac

echo "[OK] Tabel routing aktif pada $NODE_RAW:"
ip route show
SCRIPT_EOF
chmod +x /root/soal-3-routing.sh
sh /root/soal-3-routing.sh
```

### Test Case & Bukti Verifikasi (Soal 3)
1. Di **`Gendou`**: `ip route show`
2. Di **`Armisael`** (`192.212.4.83`):
   ```sh
   ping -c 3 192.212.4.74    # Lilith
   ping -c 3 192.212.3.130   # Sachiel
   ping -c 3 192.212.2.2     # Comm-Net
   ```
   **Expected:** Ketiganya **0% packet loss (berhasil)**!

### Checklist Screenshot Soal 3
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-3/ip-route-gendou.png` | Output `ip route show` di `Gendou` (terlihat 4 ringkasan CIDR) |
| `Screenshot/soal-3/ip-route-branches.png` | Output `ip route show` di router cabang (`Yui`, `Asuka`, `Shigeru`, `Fuyutsuki`, `Hikari`) |
| `Screenshot/soal-3/ping-armisael-antar-lan.png` | Bukti `Armisael` ping ke `Lilith`, `Sachiel`, dan `Comm-Net` berhasil semua |

---

## Soal 4 — Haus Kabar dari Dunia Luar (NAT MASQUERADE & DNS)

### Tujuan
Berikan akses internet lewat `Gendou` dengan `MASQUERADE` khusus `-s 192.212.0.0/16 -o eth0` dan pastikan DNS bisa me-resolve `deb.debian.org`.

### Masukkan Script & Jalankan di Console `Gendou`
Buka console **`Gendou`**, copas blok di bawah untuk membuat `/root/soal-4-nat.sh` lalu langsung menjalankannya:
```sh
cat << 'SCRIPT_EOF' > /root/soal-4-nat.sh
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
SCRIPT_EOF
chmod +x /root/soal-4-nat.sh
sh /root/soal-4-nat.sh
```

### Test Case & Bukti Verifikasi (Soal 4)
1. Di **`Armisael`**:
   ```sh
   ping -c 3 8.8.8.8
   ping -c 3 deb.debian.org
   ```
2. Di **`Lilith`**:
   ```sh
   ping -c 3 8.8.8.8
   ping -c 3 deb.debian.org
   ```
3. Di **`Gendou`** (tunjukkan counter NAT naik!):
   ```sh
   iptables -t nat -L POSTROUTING -n -v --line-numbers
   ```

### Checklist Screenshot Soal 4
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-4/ping-internet-armisael.png` | `ping -c 3 8.8.8.8` & `ping -c 3 deb.debian.org` berhasil dari `Armisael` |
| `Screenshot/soal-4/ping-internet-lilith.png` | `ping -c 3 8.8.8.8` & `ping -c 3 deb.debian.org` berhasil dari `Lilith` |
| `Screenshot/soal-4/nat-counter-gendou.png` | Output `iptables -t nat -L POSTROUTING -n -v --line-numbers` di `Gendou` (counter `pkts` naik) |

---

## Soal 5 — Pintu Depan Dikunci Rapat (`gendo.sh` Default Deny)

### Tujuan
Kunci `Gendou` dengan policy `INPUT DROP` & `FORWARD DROP`, izinkan loopback, DHCP `NAT1`, koneksi `ESTABLISHED,RELATED`, internal→internet, antar-LAN, dan internal→Gendou. **Semua (Soal 2–5) ditulis di `/root/gendo.sh`.**

### Masukkan `/root/gendo.sh` & Jalankan di Console `Gendou`
Buka console **`Gendou`**, copas seluruh blok ini:
```sh
cat << 'SCRIPT_EOF' > /root/gendo.sh
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
SCRIPT_EOF
chmod +x /root/gendo.sh
sh /root/gendo.sh
```

### Test Case & Bukti Verifikasi (Soal 5)
1. Di **`Gendou`**:
   ```sh
   iptables -S
   iptables -t nat -S
   ```
2. Di **`Armisael`**:
   ```sh
   ping -c 3 8.8.8.8
   ping -c 2 192.212.4.74
   ping -c 2 192.212.4.129
   ```

### Checklist Screenshot Soal 5
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-5/iptables-s-gendou.png` | Output `iptables -S` dan `iptables -t nat -S` di `Gendou` (`-P INPUT DROP`, `-P FORWARD DROP`) |
| `Screenshot/soal-5/ping-armisael-after-fw.png` | Bukti `Armisael` tetap berhasil `ping -c 3 8.8.8.8` setelah firewall aktif |

---

## Soal 6 — Alamat Para Pilot (IP Statis Permanen 25 Host + `init.sh`)

### Tujuan
Beri IP statis & gateway permanen (`/etc/network/interfaces`) ke semua **25 node non-router** agar bertahan setelah restart, dan sekalian pasang **`/root/init.sh`** di seluruh 42 node agar seluruh project GNS3 tahan restart!

### Langkah 6A — Pasang `/root/soal-6-hosts-static.sh` pada 25 Host Non-Router
Copas blok ini ke console **masing-masing 25 host non-router** (otomatis mendeteksi hostname, memasang `ifupdown` pada `debinet`, menulis `/etc/network/interfaces`, dan menguji ping ke gateway!):
```sh
cat << 'SCRIPT_EOF' > /root/soal-6-hosts-static.sh
#!/bin/sh
# ==============================================================================
# soal-6-hosts-static.sh - Soal 6: IP Statis & Gateway Permanen Semua 25 Host
# Praktikum Jarkom Modul 5 - Kelompok K-02 (Prefix: 192.212.x.x)
#
# Menyimpan konfigurasi di /etc/network/interfaces agar bertahan setelah restart.
# Semua node menggunakan ardhptr21/debinet:latest, sehingga otomatis memasang
# ifupdown (persistensi interface) dan netcat-traditional (alat uji nc Soal 7-19).
#
# Penggunaan:
#   sh /root/soal-6-hosts-static.sh            # Otomatis deteksi hostname
#   sh /root/soal-6-hosts-static.sh <hostname> # Paksa nama host
# ==============================================================================

set -u

NODE_RAW="${1:-$(hostname)}"
NODE=$(printf '%s' "$NODE_RAW" | tr '[:upper:]' '[:lower:]')

IP=""
PREFIX=""
MASK=""
GW=""

case "$NODE" in
    *quarters*)               IP="192.212.0.2";   PREFIX="23"; MASK="255.255.254.0";   GW="192.212.0.1"   ;;
    *comm-net*|*commnet*)     IP="192.212.2.2";   PREFIX="24"; MASK="255.255.255.0";   GW="192.212.2.1"   ;;
    *hangar-crew*|*hangar*)   IP="192.212.3.2";   PREFIX="25"; MASK="255.255.255.128"; GW="192.212.3.1"   ;;
    *sachiel*)                IP="192.212.3.130"; PREFIX="26"; MASK="255.255.255.192"; GW="192.212.3.129" ;;
    *pen-pen*|*penpen*)       IP="192.212.3.194"; PREFIX="27"; MASK="255.255.255.224"; GW="192.212.3.193" ;;
    *medic-bay*|*medicbay*)   IP="192.212.3.195"; PREFIX="27"; MASK="255.255.255.224"; GW="192.212.3.193" ;;
    *relay-node*|*relay*)     IP="192.212.3.226"; PREFIX="27"; MASK="255.255.255.224"; GW="192.212.3.225" ;;
    *garden-staff*|*garden*)  IP="192.212.4.2";   PREFIX="27"; MASK="255.255.255.224"; GW="192.212.4.1"   ;;
    *dock-crew*|*dock*)       IP="192.212.4.34";  PREFIX="28"; MASK="255.255.255.240"; GW="192.212.4.33"  ;;
    *entry-plug*|*entry*)     IP="192.212.4.50";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.49"  ;;
    *dummy-plug*|*dummy*)     IP="192.212.4.51";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.49"  ;;
    *casper*)                 IP="192.212.4.58";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.57"  ;;
    *balthasar*)              IP="192.212.4.59";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.57"  ;;
    *melchior*)               IP="192.212.4.60";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.57"  ;;
    *unit-01*|*unit01*)       IP="192.212.4.66";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.65"  ;;
    *unit-02*|*unit02*)       IP="192.212.4.67";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.65"  ;;
    *unit-00*|*unit00*)       IP="192.212.4.68";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.65"  ;;
    *lilith*)                 IP="192.212.4.74";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.73"  ;;
    *adam*)                   IP="192.212.4.75";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.73"  ;;
    *zeruel*)                 IP="192.212.4.82";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.81"  ;;
    *armisael*)               IP="192.212.4.83";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.81"  ;;
    *radar-array*|*radar*)    IP="192.212.4.90";  PREFIX="29"; MASK="255.255.255.248"; GW="192.212.4.89"  ;;
    *archive-vault*|*archive*)IP="192.212.4.98";  PREFIX="30"; MASK="255.255.255.252"; GW="192.212.4.97"  ;;
    *spy*)                    IP="192.212.4.102"; PREFIX="30"; MASK="255.255.255.252"; GW="192.212.4.101" ;;
    *tokyo3*)                 IP="192.212.4.106"; PREFIX="30"; MASK="255.255.255.252"; GW="192.212.4.105" ;;
    *)
        echo "[ERROR] Hostname '$NODE_RAW' bukan salah satu dari 25 host non-router Geofront."
        exit 1
        ;;
esac

echo "=== [Soal 6] Konfigurasi IP Statis Permanen: $NODE_RAW ($IP/$PREFIX gw $GW) ==="

# 1. Aktifkan IP & route langsung dulu agar konektivitas langsung hidup (termasuk untuk apt di debinet)
ip addr replace "$IP/$PREFIX" dev eth0
ip link set eth0 up
ip route replace default via "$GW" dev eth0
printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

# 2. Pada debinet, pasang ifupdown & netcat-traditional bila belum tersedia
if command -v apt-get >/dev/null 2>&1; then
    if ! command -v ifup >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1; then
        echo "[+] Memasang ifupdown dan netcat-traditional pada $(hostname) (debinet)..."
        apt-get update -qq && apt-get install -y -qq ifupdown netcat-traditional
    fi
    update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
fi

# 3. Tulis konfigurasi permanen ke /etc/network/interfaces
mkdir -p /etc/network
cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address $IP
    netmask $MASK
    gateway $GW
    post-up printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
EOF

# 4. Uji pemuatan lewat ifup (sesuai modul implementasifirewall.md)
if command -v ifup >/dev/null 2>&1; then
    ip addr flush dev eth0 2>/dev/null || true
    mkdir -p /run/network
    ifdown eth0 2>/dev/null || true
    ifup eth0 2>/dev/null || {
        ip addr replace "$IP/$PREFIX" dev eth0
        ip link set eth0 up
        ip route replace default via "$GW" dev eth0
    }
fi

echo "[OK] Konfigurasi permanen selesai! Verifikasi:"
ip -br -4 addr show
ip route show
ping -c 2 -W 2 "$GW"
SCRIPT_EOF
chmod +x /root/soal-6-hosts-static.sh
sh /root/soal-6-hosts-static.sh
```

### Langkah 6B — Pasang `/root/init.sh` (Anti-Hilang Setelah Restart!)
> **Kapan masukkin `init.sh`?** SEKARANG (tepat setelah Soal 6 selesai)! Sekali kamu pasang `/root/init.sh` di node, setiap kali container/GNS3 di-restart, seluruh IP, routing, firewall (`/root/<nama>.rules` & `/root/gendo.sh`), dan listener layanan otomatis pulih!

1. **Copas blok `init.sh` ini SEKALI saja di console `Gendou`** (atau langsung ke node mana saja yang ingin kamu lindungi):
```sh
cat << 'SCRIPT_EOF' > /root/init.sh
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
SCRIPT_EOF
chmod +x /root/init.sh
sh /root/init.sh
```
2. **Bagikan `/root/init.sh` ke 41 node lain dengan 1 baris per node (super cepat!):**
   - Di **`Gendou`**, jalankan pengirim sementara:
     ```sh
     (while true; do nc -l -p 9999 -q 1 < /root/init.sh; done) </dev/null >/dev/null 2>&1 &
     ```
   - Di **16 router lainnya & 25 host** (cukup 1 baris per console — pakai `bash /dev/tcp`, jalan meski `nc` belum terpasang di router!):
     ```sh
     bash -c 'cat < /dev/tcp/192.212.4.105/9999 > /root/init.sh' && chmod +x /root/init.sh && sh /root/init.sh
     ```
   - Setelah semua selesai, hentikan port 9999 di **`Gendou`**:
     ```sh
     pkill -f "nc -l -p 9999"
     ```

### Test Case & Bukti Verifikasi (Soal 6)
1. Restart container **`Unit-01`** di GNS3 (klik kanan → *Reload* / *Stop* lalu *Start*).
2. Buka console **`Unit-01`** dan jalankan:
   ```sh
   ip -br a
   cat /etc/network/interfaces
   ping -c 3 192.212.4.65
   ```
   **Expected:** Setelah restart, `Unit-01` tetap punya IP `192.212.4.66/29` dan berhasil ping ke gateway `192.212.4.65`!

### Checklist Screenshot Soal 6
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-6/unit01-ip-ping-gw.png` | Output `ip -br a`, `cat /etc/network/interfaces`, dan `ping -c 3 192.212.4.65` di `Unit-01` setelah restart |

---

## Soal 7 — Membangunkan MAGI (Casper, Balthasar, Melchior)

### Tujuan
Pasang `iptables` & `netcat-traditional` lewat `/root/<nama>.sh` di 3 node MAGI, lalu nyalakan listener TCP (`5000` di Casper & Melchior; `5000` & `5001` di Balthasar).

### 1. Masukkan `/root/casper.sh` di Console `Magi-Casper`
```sh
cat << 'SCRIPT_EOF' > /root/casper.sh
#!/bin/sh
# ==============================================================================
# /root/casper.sh - Soal 7: Setup Magi-Casper (iptables, netcat-traditional, TCP 5000)
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Magi-Casper: 192.212.4.58/29 | Gateway: 192.212.4.57 (Fuyutsuki)
#
# Penggunaan:
#   sh /root/casper.sh               # Install paket + jalankan listener TCP 5000
#   sh /root/casper.sh --listen-only # Langsung jalankan ulang listener (tanpa apt)
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Magi-Casper] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

# Pastikan menggunakan varian netcat-traditional dan iptables yang kompatibel
update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

# Hentikan listener lama jika ada agar tidak duplikat
if [ -f /tmp/magi-5000.pid ]; then
    kill "$(cat /tmp/magi-5000.pid)" 2>/dev/null || true
fi
pkill -f "nc -l -p 5000" 2>/dev/null || true

: >> /tmp/magi-5000.log

# Jalankan listener persisten TCP 5000
(
    while true; do
        nc -l -p 5000 >> /tmp/magi-5000.log 2>&1
        sleep 0.1 2>/dev/null || sleep 1
    done
) </dev/null >/dev/null 2>&1 &
echo $! > /tmp/magi-5000.pid

echo "[OK] Magi-Casper (192.212.4.58) siap melayani TCP port 5000."
echo "     Lihat pesan masuk: cat /tmp/magi-5000.log"
SCRIPT_EOF
chmod +x /root/casper.sh
sh /root/casper.sh
```

### 2. Masukkan `/root/balthasar.sh` di Console `Magi-Balthasar`
```sh
cat << 'SCRIPT_EOF' > /root/balthasar.sh
#!/bin/sh
# ==============================================================================
# /root/balthasar.sh - Soal 7: Setup Magi-Balthasar (iptables, netcat-traditional, TCP 5000 & 5001)
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Magi-Balthasar: 192.212.4.59/29 | Gateway: 192.212.4.57 (Fuyutsuki)
#
# Penggunaan:
#   sh /root/balthasar.sh               # Install paket + jalankan listener TCP 5000 & 5001
#   sh /root/balthasar.sh --listen-only # Langsung jalankan ulang listener (tanpa apt)
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Magi-Balthasar] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

start_port() {
    p="$1"
    if [ -f "/tmp/magi-${p}.pid" ]; then
        kill "$(cat "/tmp/magi-${p}.pid")" 2>/dev/null || true
    fi
    pkill -f "nc -l -p ${p}" 2>/dev/null || true
    : >> "/tmp/magi-${p}.log"
    (
        while true; do
            nc -l -p "$p" >> "/tmp/magi-${p}.log" 2>&1
            sleep 0.1 2>/dev/null || sleep 1
        done
    ) </dev/null >/dev/null 2>&1 &
    echo $! > "/tmp/magi-${p}.pid"
}

start_port 5000
start_port 5001

echo "[OK] Magi-Balthasar (192.212.4.59) siap melayani TCP port 5000 dan 5001."
echo "     Lihat pesan masuk: cat /tmp/magi-5000.log && cat /tmp/magi-5001.log"
SCRIPT_EOF
chmod +x /root/balthasar.sh
sh /root/balthasar.sh
```

### 3. Masukkan `/root/melchior.sh` di Console `Magi-Melchior`
```sh
cat << 'SCRIPT_EOF' > /root/melchior.sh
#!/bin/sh
# ==============================================================================
# /root/melchior.sh - Soal 7: Setup Magi-Melchior (iptables, netcat-traditional, TCP 5000)
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Magi-Melchior: 192.212.4.60/29 | Gateway: 192.212.4.57 (Fuyutsuki)
#
# Penggunaan:
#   sh /root/melchior.sh               # Install paket + jalankan listener TCP 5000
#   sh /root/melchior.sh --listen-only # Langsung jalankan ulang listener (tanpa apt)
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Magi-Melchior] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

if [ -f /tmp/magi-5000.pid ]; then
    kill "$(cat /tmp/magi-5000.pid)" 2>/dev/null || true
fi
pkill -f "nc -l -p 5000" 2>/dev/null || true

: >> /tmp/magi-5000.log

(
    while true; do
        nc -l -p 5000 >> /tmp/magi-5000.log 2>&1
        sleep 0.1 2>/dev/null || sleep 1
    done
) </dev/null >/dev/null 2>&1 &
echo $! > /tmp/magi-5000.pid

echo "[OK] Magi-Melchior (192.212.4.60) siap melayani TCP port 5000."
echo "     Lihat pesan masuk: cat /tmp/magi-5000.log"
SCRIPT_EOF
chmod +x /root/melchior.sh
sh /root/melchior.sh
```

### Test Case & Bukti Verifikasi (Soal 7)
1. Dari **`Lilith`** (`192.212.4.74`):
   ```sh
   echo "Halo Casper-5000 dari Lilith"    | nc -w 3 -q 1 192.212.4.58 5000; echo "exit=$?"
   echo "Halo Balthasar-5000 dari Lilith" | nc -w 3 -q 1 192.212.4.59 5000; echo "exit=$?"
   echo "Halo Balthasar-5001 dari Lilith" | nc -w 3 -q 1 192.212.4.59 5001; echo "exit=$?"
   echo "Halo Melchior-5000 dari Lilith"  | nc -w 3 -q 1 192.212.4.60 5000; echo "exit=$?"
   ```
2. Tampilkan pesan masuk di tiap node MAGI:
   - Di **`Magi-Casper`**: `cat /tmp/magi-5000.log`
   - Di **`Magi-Balthasar`**: `cat /tmp/magi-5000.log && echo "---5001---" && cat /tmp/magi-5001.log`
   - Di **`Magi-Melchior`**: `cat /tmp/magi-5000.log`

### Checklist Screenshot Soal 7
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-7/lilith-send-magi.png` | Output pengiriman 4 pesan `nc` dari `Lilith` (semua `exit=0`) |
| `Screenshot/soal-7/magi-received-logs.png` | Pesan diterima di `Magi-Casper` (5000), `Magi-Balthasar` (5000 & 5001), dan `Magi-Melchior` (5000) |

---

## Soal 8 — Mengenali Kondisi Normal (Pen-Pen & Tokyo3-Core)

### Tujuan
Aktifkan responder TCP 80 (`Welcome to {hostname}`) di `Pen-Pen` & `Tokyo3-Core`, dan TCP 8080 (`syifa imutz`) di `Tokyo3-Core`. Buktikan port tidak dilayani (port 22) langsung gagal tanpa menggantung.

### 1. Masukkan `/root/penpen.sh` di Console `Pen-Pen`
```sh
cat << 'SCRIPT_EOF' > /root/penpen.sh
#!/bin/sh
# ==============================================================================
# /root/penpen.sh - Soal 8: Setup Layanan Pen-Pen (TCP 80 -> Welcome to {hostname})
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Pen-Pen: 192.212.3.194/27 | Gateway: 192.212.3.193 (Maya)
#
# Penggunaan:
#   sh /root/penpen.sh               # Install paket + jalankan listener TCP 80
#   sh /root/penpen.sh --listen-only # Jalankan ulang listener saja (tanpa apt)
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Pen-Pen] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

# Buat responder port 80
cat << 'EOF' > /root/reply_80.sh
#!/bin/sh
printf "Welcome to %s\n" "$(hostname)"
EOF
chmod +x /root/reply_80.sh

# Hentikan listener lama jika ada
if [ -f /tmp/srv-80.pid ]; then
    kill "$(cat /tmp/srv-80.pid)" 2>/dev/null || true
fi
pkill -f "nc -l -p 80" 2>/dev/null || true

# Jalankan listener TCP 80 persisten (menjawab langsung lalu tutup koneksi)
(
    while true; do
        nc -l -p 80 -e /root/reply_80.sh >/dev/null 2>&1
        sleep 0.1 2>/dev/null || sleep 1
    done
) </dev/null >/dev/null 2>&1 &
echo $! > /tmp/srv-80.pid

echo "[OK] Pen-Pen (192.212.3.194) aktif di TCP 80 -> menjawab: Welcome to $(hostname)"
SCRIPT_EOF
chmod +x /root/penpen.sh
sh /root/penpen.sh
```

### 2. Masukkan `/root/tokyo3.sh` di Console `Tokyo3-Core`
```sh
cat << 'SCRIPT_EOF' > /root/tokyo3.sh
#!/bin/sh
# ==============================================================================
# /root/tokyo3.sh - Soal 8: Setup Layanan Tokyo3-Core
#   TCP 80   -> Welcome to {hostname}
#   TCP 8080 -> syifa imutz
# Praktikum Jarkom Modul 5 - Kelompok K-02
# IP Tokyo3-Core: 192.212.4.106/30 | Gateway: 192.212.4.105 (Gendou)
#
# Penggunaan:
#   sh /root/tokyo3.sh               # Install paket + jalankan listener 80 & 8080
#   sh /root/tokyo3.sh --listen-only # Jalankan ulang listener saja (tanpa apt)
# ==============================================================================

set -u

printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf

if [ "${1:-}" != "--listen-only" ]; then
    if ! command -v iptables >/dev/null 2>&1 || ! command -v nc.traditional >/dev/null 2>&1 || ! command -v ifup >/dev/null 2>&1; then
        echo "[+] [Tokyo3-Core] Memasang iptables, netcat-traditional, ifupdown..."
        apt-get update -qq && apt-get install -y -qq iptables netcat-traditional ifupdown
    fi
fi

update-alternatives --set nc /bin/nc.traditional >/dev/null 2>&1 || true
if command -v iptables >/dev/null 2>&1 && ! iptables -L -n >/dev/null 2>&1; then
    [ -x /usr/sbin/iptables-legacy ] && update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1 || true
fi

# Buat responder port 80 & port 8080
cat << 'EOF' > /root/reply_80.sh
#!/bin/sh
printf "Welcome to %s\n" "$(hostname)"
EOF
cat << 'EOF' > /root/reply_8080.sh
#!/bin/sh
printf "syifa imutz\n"
EOF
chmod +x /root/reply_80.sh /root/reply_8080.sh

start_responder() {
    port="$1"
    handler="$2"
    if [ -f "/tmp/srv-${port}.pid" ]; then
        kill "$(cat "/tmp/srv-${port}.pid")" 2>/dev/null || true
    fi
    pkill -f "nc -l -p ${port}" 2>/dev/null || true
    (
        while true; do
            nc -l -p "$port" -e "$handler" >/dev/null 2>&1
            sleep 0.1 2>/dev/null || sleep 1
        done
    ) </dev/null >/dev/null 2>&1 &
    echo $! > "/tmp/srv-${port}.pid"
}

start_responder 80 /root/reply_80.sh
start_responder 8080 /root/reply_8080.sh

echo "[OK] Tokyo3-Core (192.212.4.106) aktif:"
echo "     - TCP 80   -> Welcome to $(hostname)"
echo "     - TCP 8080 -> syifa imutz"
SCRIPT_EOF
chmod +x /root/tokyo3.sh
sh /root/tokyo3.sh
```

### Test Case & Bukti Verifikasi (Soal 8)
Dari **`Lilith`** (`192.212.4.74`):
```sh
nc -w 3 192.212.3.194 80 < /dev/null; echo "exit=$?"
nc -w 3 192.212.4.106 80 < /dev/null; echo "exit=$?"
nc -w 3 192.212.4.106 8080 < /dev/null; echo "exit=$?"
time nc -v -w 3 192.212.4.106 22 < /dev/null; echo "exit=$?"
time nc -v -w 3 192.212.3.194 22 < /dev/null; echo "exit=$?"
```
**Expected:** `Welcome to Pen-Pen`, `Welcome to Tokyo3-Core`, `syifa imutz` (`exit=0`, langsung selesai tanpa tunggu timeout berkat `< /dev/null`), sedangkan port `22` langsung tampil **`Connection refused`** dalam ~`0.00s` (`exit=1`)!

### Checklist Screenshot Soal 8
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-8/lilith-nc-services.png` | Output `nc` dari `Lilith` ke Pen-Pen:80, Tokyo3-Core:80, Tokyo3-Core:8080, dan `time nc -w 3 ... 22` gagal seketika |

---

## Soal 9 — Sabotase: Jalur Belakang Diutak-Atik (`break_routing.sh`)

### Langkah 1 — Masukkan & Jalankan Sabotase `break_routing.sh` di Console `Shigeru`
```sh
cat << 'SCRIPT_EOF' > /root/break_routing.sh
#!/bin/sh
if [ "$FORCE" != 1 ]; then case "$(hostname)" in *[Ss]higeru*) ;; *) echo "Script ini hanya untuk Shigeru."; exit 1;; esac; fi
ip2int(){ _o=$IFS; IFS=.; set -- $1; IFS=$_o; echo $(( ($1<<24)+($2<<16)+($3<<8)+$4 )); }
int2ip(){ echo "$(( ($1>>24)&255 )).$(( ($1>>16)&255 )).$(( ($1>>8)&255 )).$(( $1&255 ))"; }
[ "$(id -u)" = 0 ] || { echo "Harus dijalankan sebagai root"; exit 1; }
ADDRS=$(ip -4 -o addr show | while read _ dev fam addr _; do [ "$dev" = lo ] && continue; echo "$dev $addr"; done)
DEFDEV=$(ip route show default | sed -n "s/.* dev \([^ ]*\).*/\1/p" | head -1)
if ip rule show | grep -q "iif .* lookup 100"; then echo "Script sudah dijalankan sebelumnya"; exit 1; fi
LANIF=; L30=; LANIP=
while read dev addr; do
  [ -z "$dev" ] && continue
  if [ "${addr#*/}" = 30 ]; then L30="$L30 $dev:${addr%/*}"; else LANIF=$dev; LANIP=${addr%/*}; fi
done <<EOT
$ADDRS
EOT
UPIF=$DEFDEV; UPIP=; MKIF=; MKIP=
for e in $L30; do d=${e%%:*}; i=${e#*:}; if [ "$d" = "$UPIF" ]; then UPIP=$i; else MKIF=$d; MKIP=$i; fi; done
if [ -z "$LANIF" ] || [ -z "$UPIP" ] || [ -z "$MKIF" ]; then
  echo "Topologi Shigeru belum terdeteksi. Selesaikan soal 2 dan 3 dulu (IP semua interface dan default route ke Gendo)."; exit 1; fi
MKGW=$(int2ip $(( $(ip2int $MKIP) ^ 3 )))
P=${P:-${LANIP%.*.*}}
DOGMA=${DOGMA:-$P.4.72/29}
echo 0 > /proc/sys/net/ipv4/ip_forward
ip route replace default via $MKGW dev $MKIF
ip route del blackhole $DOGMA 2>/dev/null
ip route add blackhole $DOGMA
ip route flush table 100 2>/dev/null
ip route add unreachable default table 100
ip rule del iif $LANIF lookup 100 priority 90 2>/dev/null
ip rule add iif $LANIF lookup 100 priority 90
echo "Script sudah dirusak"
SCRIPT_EOF
chmod +x /root/break_routing.sh
sh /root/break_routing.sh
```

### Langkah 2 — Buktikan Gejala Sabotase
- Dari **`Lilith`**: `ping -c 3 -W 2 192.212.4.83` (Armisael) → **GAGAL (100% loss)**
- Dari **`Armisael`**: `ping -c 2 192.212.4.81` (gateway Shigeru) → **BERHASIL!**

### Langkah 3 — Masukkan `/root/soal-9-fix-shigeru.sh` & Diagnosis 4 Penyebab di Console `Shigeru`
```sh
cat << 'SCRIPT_EOF' > /root/soal-9-fix-shigeru.sh
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
SCRIPT_EOF
chmod +x /root/soal-9-fix-shigeru.sh
sh /root/soal-9-fix-shigeru.sh diagnose
```
*(Screenshot hasil diagnosis di sini dulu untuk `diagnosis-shigeru.png`! Terlihat 4 kerusakan: `ip_forward=0`, default route via Makoto, `blackhole 192.212.4.72/29`, dan `ip rule` priority 90 table 100 `unreachable default`.)*

### Langkah 4 — Jalankan Perbaikan di Console `Shigeru` & Verifikasi dari `Lilith`
- Di **`Shigeru`**:
  ```sh
  sh /root/soal-9-fix-shigeru.sh fix
  ```
- Dari **`Lilith`**:
  ```sh
  ping -c 3 192.212.4.83
  ```
  **Expected:** **BERHASIL (0% loss)**!

### Checklist Screenshot Soal 9
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-9/sabotase-gejala.png` | `break_routing.sh` di Shigeru + Lilith gagal ping Armisael + Armisael sukses ping gateway `192.212.4.81` |
| `Screenshot/soal-9/diagnosis-shigeru.png` | Output `sh /root/soal-9-fix-shigeru.sh diagnose` menampilkan ke-4 penyebab |
| `Screenshot/soal-9/fix-dan-ping-berhasil.png` | Output perbaikan di Shigeru + bukti `Lilith` berhasil ping `192.212.4.83` (Armisael) |

---

## Soal 10 — Sabotase: Para Pilot Terkunci di Dalam (`break_nat.sh`)

### Langkah 1 — Masukkan & Jalankan Sabotase `break_nat.sh` di Console `Misato` DAN `Gendou`
Copas blok yang **sama** ke console **`Misato`** lalu ke console **`Gendou`**:
```sh
cat << 'SCRIPT_EOF' > /root/break_nat.sh
#!/bin/sh
ip2int(){ _o=$IFS; IFS=.; set -- $1; IFS=$_o; echo $(( ($1<<24)+($2<<16)+($3<<8)+$4 )); }
int2ip(){ echo "$(( ($1>>24)&255 )).$(( ($1>>16)&255 )).$(( ($1>>8)&255 )).$(( $1&255 ))"; }
[ "$(id -u)" = 0 ] || { echo "Harus dijalankan sebagai root"; exit 1; }
command -v iptables >/dev/null 2>&1 || { echo "iptables belum ada, mencoba memasang..."; (apt-get update -qq && apt-get install -y -qq iptables) >/dev/null 2>&1 || apk add -q iptables >/dev/null 2>&1; }
command -v iptables >/dev/null 2>&1 || { echo "iptables gagal dipasang. Pasang manual dulu."; exit 1; }
ADDRS=$(ip -4 -o addr show | while read _ dev fam addr _; do [ "$dev" = lo ] && continue; echo "$dev $addr"; done)
DEFDEV=$(ip route show default | sed -n "s/.* dev \([^ ]*\).*/\1/p" | head -1)
[ -n "$DEFDEV" ] || { echo "Default route belum ada. Selesaikan soal 2 sampai 4 dulu."; exit 1; }
INTIP=$(echo "$ADDRS" | while read dev addr; do [ "$dev" != "$DEFDEV" ] && { echo "${addr%/*}"; break; }; done)
P=${P:-${INTIP%.*.*}}
case "$(hostname)" in
  *[Mm]isato*) NODE=misato ;;
  *[Gg]endo*)  NODE=gendo ;;
  *) [ "$FORCE" = misato ] && NODE=misato; [ "$FORCE" = gendo ] && NODE=gendo
     [ -n "$NODE" ] || { echo "Jalankan di Misato dan di Gendo."; exit 1; } ;;
esac
if [ "$NODE" = misato ]; then
  CAGEIF=; while read dev addr; do [ "$dev" != "$DEFDEV" ] && { CAGEIF=$dev; CADDR=$addr; break; }; done <<EOT
$ADDRS
EOT
  [ -n "$CAGEIF" ] || { echo "Interface Cage tidak terdeteksi."; exit 1; }
  len=${CADDR#*/}; ipn=$(ip2int ${CADDR%/*}); mask=$(( (0xFFFFFFFF << (32-len)) & 0xFFFFFFFF ))
  CAGE=$(int2ip $(( ipn & mask )))/$len
  UPIF=$DEFDEV
else
  WAN=$DEFDEV
  CAGE=${CAGE:-$P.4.64/29}
  ip route show | grep -q "^$CAGE " || echo "Subnet tidak terdeteksi"
fi
if [ "$NODE" = misato ]; then
  iptables -t nat -D POSTROUTING -s $CAGE ! -d $P.0.0/16 -o $UPIF -j SNAT --to-source 172.31.99.1 2>/dev/null
  iptables -t nat -A POSTROUTING -s $CAGE ! -d $P.0.0/16 -o $UPIF -j SNAT --to-source 172.31.99.1
else
  iptables -t nat -D POSTROUTING -s $CAGE -o $WAN -j RETURN 2>/dev/null
  iptables -t nat -I POSTROUTING 1 -s $CAGE -o $WAN -j RETURN
fi
echo "Script sudah dirusak"
SCRIPT_EOF
chmod +x /root/break_nat.sh
sh /root/break_nat.sh
```

### Langkah 2 — Buktikan Gejala Sabotase
- Dari **`Unit-01`**:
  ```sh
  ping -c 2 -W 2 8.8.8.8        # GAGAL (100% loss)
  ping -c 2 -W 2 192.212.4.74   # Lilith -> BERHASIL!
  ```
- Dari **`Spy`** (`192.212.4.102`):
  ```sh
  ping -c 2 -W 2 8.8.8.8        # BERHASIL!
  ```

### Langkah 3 — Masukkan `/root/soal-10-fix-nat.sh` & Diagnosis di Console `Misato` DAN `Gendou`
Copas ke **`Misato`** dan ke **`Gendou`**:
```sh
cat << 'SCRIPT_EOF' > /root/soal-10-fix-nat.sh
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
SCRIPT_EOF
chmod +x /root/soal-10-fix-nat.sh
sh /root/soal-10-fix-nat.sh diagnose
```
*(Screenshot hasil diagnosis di kedua router untuk `diagnosis-nat.png`! Terlihat SNAT palsu `172.31.99.1` di Misato dan rule #1 `RETURN` di Gendou.)*

### Langkah 4 — Jalankan Perbaikan di `Misato` & `Gendou`, lalu Verifikasi dari `Unit-01`
- Di **`Misato`** dan di **`Gendou`**:
  ```sh
  sh /root/soal-10-fix-nat.sh fix
  ```
- Dari **`Unit-01`**:
  ```sh
  ping -c 3 8.8.8.8
  ```
- Di **`Gendou`**: `iptables -t nat -L POSTROUTING -n -v --line-numbers`

### Checklist Screenshot Soal 10
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-10/sabotase-gejala.png` | `break_nat.sh` di Misato & Gendou + `Unit-01` gagal `8.8.8.8`, sukses `Lilith`, `Spy` sukses `8.8.8.8` |
| `Screenshot/soal-10/diagnosis-nat.png` | Output `iptables -t nat -L POSTROUTING -n -v --line-numbers` di `Misato` & `Gendou` |
| `Screenshot/soal-10/fix-dan-ping-unit01.png` | Output perbaikan di Misato & Gendou + `Unit-01` sukses `ping -c 3 8.8.8.8` |

---

## Soal 11 — Casper Harus Jadi Hantu (Blokir Ping Masuk)

### Tujuan
Pasang host-based firewall di `Magi-Casper` (`INPUT -p icmp --icmp-type echo-request -j DROP`) agar tidak ada host lain (termasuk `Magi-Balthasar` satu switch) yang bisa mem-ping Casper, sementara Casper tetap bisa mem-ping siapa saja dan TCP 5000 tetap hidup.

### Masukkan `/root/soal-11-casper-ghost.sh` & Jalankan di Console `Magi-Casper`
```sh
cat << 'SCRIPT_EOF' > /root/soal-11-casper-ghost.sh
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
SCRIPT_EOF
chmod +x /root/soal-11-casper-ghost.sh
sh /root/soal-11-casper-ghost.sh
```

### Test Case & Bukti Verifikasi (Soal 11)
1. Dari **`Magi-Balthasar`** (satu switch!):
   ```sh
   ping -c 3 -W 2 192.212.4.58    # GAGAL (100% loss)
   ```
2. Dari **`Lilith`**:
   ```sh
   ping -c 3 -W 2 192.212.4.58    # GAGAL (100% loss)
   echo "Cek TCP 5000 Casper" | nc -w 3 -q 1 192.212.4.58 5000; echo "exit=$?"  # exit=0!
   ```
3. Dari **`Magi-Casper`**:
   ```sh
   ping -c 3 192.212.4.59         # Balthasar -> BERHASIL!
   ping -c 3 192.212.4.74         # Lilith -> BERHASIL!
   iptables -L INPUT -n -v --line-numbers
   ```

### Checklist Screenshot Soal 11
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-11/ping-ke-casper-gagal.png` | `Magi-Balthasar` & `Lilith` gagal ping Casper (`192.212.4.58`) + `nc` port 5000 tetap `exit=0` |
| `Screenshot/soal-11/casper-ping-keluar-berhasil.png` | `Magi-Casper` berhasil ping Balthasar & Lilith + counter `iptables -L INPUT -n -v --line-numbers` |

---

## Soal 12 — Sabotase: Teknisi yang Kelewat Semangat (`break_fw.sh`)

### Langkah 1 — Masukkan & Jalankan Sabotase `break_fw.sh` di Console `Magi-Casper`
```sh
cat << 'SCRIPT_EOF' > /root/break_fw.sh
#!/bin/sh
if [ "$FORCE" != 1 ]; then case "$(hostname)" in *[Cc]asper*) ;; *) echo "Script ini hanya untuk Magi-Casper."; exit 1;; esac; fi
[ "$(id -u)" = 0 ] || { echo "Harus root"; exit 1; }
command -v iptables >/dev/null 2>&1 || { echo "iptables belum terpasang (soal 7)."; exit 1; }
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F INPUT
iptables -F OUTPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp -j DROP
iptables -A OUTPUT -p udp --dport 53 -j DROP
iptables -P INPUT DROP
echo "Script sudah dirusak"
SCRIPT_EOF
chmod +x /root/break_fw.sh
sh /root/break_fw.sh
```

### Langkah 2 — Buktikan Gejala Sabotase
- Di **`Magi-Casper`**:
  ```sh
  ping -c 2 -W 2 8.8.8.8   # GAGAL
  apt-get update           # GAGAL
  ```
- Dari **`Unit-00`** (`192.212.4.68`):
  ```sh
  echo "Tes sebelum fix" | nc -w 3 -q 1 192.212.4.58 5000; echo "exit=$?"  # GAGAL (timeout, exit=1)
  ```

### Langkah 3 — Masukkan `/root/soal-12-fix-casper-fw.sh` & Diagnosis di Console `Magi-Casper`
```sh
cat << 'SCRIPT_EOF' > /root/soal-12-fix-casper-fw.sh
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
SCRIPT_EOF
chmod +x /root/soal-12-fix-casper-fw.sh
sh /root/soal-12-fix-casper-fw.sh diagnose
```
*(Screenshot dulu di sini untuk `sabotase-dan-diagnosis.png`! Terlihat 4 masalah: `INPUT DROP` tanpa `ESTABLISHED,RELATED`, `INPUT -p icmp -j DROP` memblokir `echo-reply`, `OUTPUT -p udp --dport 53 -j DROP` memblokir DNS, dan TCP 5000 belum dibuka.)*

### Langkah 4 — Jalankan Perbaikan di `Magi-Casper` (Policy `INPUT` TETAP `DROP`!) & Verifikasi
- Di **`Magi-Casper`**:
  ```sh
  sh /root/soal-12-fix-casper-fw.sh fix
  iptables -S          # Pastikan -P INPUT DROP tetap ada!
  ping -c 2 8.8.8.8    # BERHASIL
  apt-get update       # BERHASIL!
  ```
- Dari **`Unit-00`**:
  ```sh
  echo "Halo Casper dari Unit-00 setelah fix" | nc -w 3 -q 1 192.212.4.58 5000; echo "exit=$?"
  ping -c 2 -W 2 192.212.4.58   # Tetap GAGAL (hardening & Soal 11 tetap terjaga!)
  ```
- Di **`Magi-Casper`**: `cat /tmp/magi-5000.log` (pesan dari `Unit-00` tampil!)

### Checklist Screenshot Soal 12
| Nama File | Konten yang Di-screenshot |
| :--- | :--- |
| `Screenshot/soal-12/sabotase-dan-diagnosis.png` | Output `break_fw.sh`, `iptables -S`, gagal ping/apt di Casper & gagal `nc` dari `Unit-00` |
| `Screenshot/soal-12/fix-iptables-casper.png` | Output `soal-12-fix-casper-fw.sh fix` + `iptables -S` (terlihat `-P INPUT DROP` tetap aktif) |
| `Screenshot/soal-12/bukti-unit00-dan-apt.png` | Bukti `Unit-00` sukses `nc` ke port 5000 (muncul di `/tmp/magi-5000.log`), `apt-get update` berhasil, & ping masuk tetap ditolak |

---

## Troubleshooting Cepat

| Masalah | Penyebab | Solusi Cepat |
| :--- | :--- | :--- |
| `iptables`: `Failed to initialize nft` / `Protocol not supported` | Kernel host butuh backend `iptables-legacy` | Jalankan `update-alternatives --set iptables /usr/sbin/iptables-legacy` (skrip kita sudah otomatis melakukan ini!) |
| `eth0` di `Gendou` tidak dapat IP DHCP dari `NAT1` | `dhclient` belum jalan atau NAT1 belum tersambung ke `eth0` | Pastikan kabel `NAT1 -> Gendou eth0`, lalu `dhclient -v eth0`. Jika masih gagal, fallback manual: `ip addr replace 192.168.122.100/24 dev eth0 && ip route replace default via 192.168.122.1`. |
| `ping` gagal padahal rute sudah benar | Kabel interface di GNS3 tertukar | Cocokkan label kabel (*Show/Hide interface labels*) dengan tabel 0.2, atau cek `ip -br a`. |
| Perintah `nc: command not found` di host `debinet` | Node belum menjalankan Soal 6 (`soal-6-hosts-static.sh`) | Jalankan `apt-get update && apt-get install -y netcat-traditional && update-alternatives --set nc /bin/nc.traditional` (atau jalankan `soal-6-hosts-static.sh`). |
| `nc` di `debinet` menggantung setelah menampilkan jawaban port 80 | `netcat-traditional` menunggu stdin EOF | Tambahkan `< /dev/null` saat menerima banner, atau `-q 1` saat mengirim via `echo ... \| nc -w 3 -q 1 ...`. |
| `apt-get update` di node selain Gendou gagal | Soal 4 (NAT & `/etc/resolv.conf`) belum selesai | Selesaikan Soal 4 dulu, lalu pastikan `cat /etc/resolv.conf` berisi `nameserver 8.8.8.8`. |
| Setelah restart container, IP atau listener hilang | `/root/init.sh` belum pernah dijalankan di node tersebut | Jalankan `sh /root/init.sh` sekali di node tersebut; setelah itu setiap restart otomatis pulih. |
