# Direktori Skrip Otomasi & Recovery Node (`/root`)

Seluruh skrip di direktori ini ditulis dengan **POSIX `/bin/sh`**, dioptimalkan untuk seluruh 42 container **`ardhptr21/debinet:latest`** (juga tetap kompatibel dengan `alpinet`), serta bersifat **idempoten** (aman dijalankan berulang kali tanpa menduplikasi alamat IP, rute, maupun aturan `iptables`).

## Daftar Skrip (Soal 1 – 12 & Recovery)

| Berkas Skrip | Nomor Soal | Node Target | Fungsi Utama |
| :--- | :---: | :--- | :--- |
| **`init.sh`** | Semua (1–12+) | **Semua 42 Node** (17 Router + 25 Host) | Inisialisasi universal, penyimpanan `/etc/network/interfaces`, auto-recovery sekali per boot (via marker `/run/.geofront_init_done`), pemulihan `iptables-restore` (`/root/<nama>.rules`) & listener layanan setelah restart. |
| **`soal-2-router-ip.sh`** | Soal 2 | 17 Router | Konfigurasi IP seluruh interface router sesuai tabel VLSM K-02, DHCP `eth0` pada Gendou, aktifkan `net.ipv4.ip_forward=1`, dan helper `--ping-links` untuk uji ping 2 ujung tiap link. |
| **`soal-3-routing.sh`** | Soal 3 | 17 Router + 4 Host Uji | Pemasangan static routing minimal (default route ke atas + rute ke bawah) dengan **4 ringkasan CIDR tepat** di Gendou, plus IP sementara untuk `Armisael`, `Lilith`, `Sachiel`, dan `Comm-Net`. |
| **`soal-4-nat.sh`** | Soal 4 | `Gendou` (+ `--dns` untuk host) | Pemasangan `iptables`, konfigurasi NAT `MASQUERADE` khusus `-s 192.212.0.0/16 -o eth0`, dan setup DNS `/etc/resolv.conf`. |
| **`gendo.sh`** | Soal 2–5 | `Gendou` (`/root/gendo.sh`) | Skrip gabungan wajib Soal 5: IP + forwarding (Soal 2), 21 static route diringkas (Soal 3), NAT `MASQUERADE` + DNS (Soal 4), dan firewall Default Deny `INPUT`/`FORWARD DROP` + 4 izin + loopback + DHCP NAT1 (Soal 5). |
| **`soal-5-gendo-fw.sh`** | Soal 5 | `Gendou` | Wrapper yang menyalin & menjalankan `/root/gendo.sh`. |
| **`soal-6-hosts-static.sh`** | Soal 6 | 25 Host Non-Router | Konfigurasi IP statis permanen + default gateway + DNS di `/etc/network/interfaces`, serta otomatis memasang `ifupdown` & `netcat-traditional` pada seluruh 25 host `debinet`. |
| **`casper.sh`**<br>**`balthasar.sh`**<br>**`melchior.sh`**<br>**`soal-7-magi.sh`** | Soal 7 | `Magi-Casper`<br>`Magi-Balthasar`<br>`Magi-Melchior` | Diletakkan di `/root/<nama>.sh`. Memasang `iptables`, `netcat-traditional`, `ifupdown`, dan menjalankan listener TCP persisten (`5000` di Casper & Melchior; `5000` & `5001` di Balthasar) dengan log di `/tmp/magi-<port>.log`. |
| **`penpen.sh`**<br>**`tokyo3.sh`**<br>**`soal-8-services.sh`** | Soal 8 | `Pen-Pen`<br>`Tokyo3-Core` | Diletakkan di `/root/penpen.sh` & `/root/tokyo3.sh`. Menjalankan responder TCP 80 (`Welcome to {hostname}`) dan TCP 8080 di `Tokyo3-Core` (`syifa imutz`). |
| **`soal-9-fix-shigeru.sh`** | Soal 9 | `Shigeru` | Mode `diagnose` & `fix` untuk 4 penyebab sabotase `break_routing.sh` (`ip_forward=0`, default route loop ke Makoto, blackhole `192.212.4.72/29`, dan PBR `ip rule` table 100). |
| **`soal-10-fix-nat.sh`** | Soal 10 | `Misato` & `Gendou` | Mode `diagnose` & `fix` untuk 2 penyebab sabotase `break_nat.sh` (SNAT palsu `172.31.99.1` di Misato dan rule `RETURN` #1 di Gendou). |
| **`soal-11-casper-ghost.sh`** | Soal 11 | `Magi-Casper` | Memasang host-based firewall `INPUT -p icmp --icmp-type echo-request -j DROP` di `Magi-Casper` (termasuk memblokir host satu switch) sambil mempertahankan ping keluar & TCP 5000. |
| **`soal-12-fix-casper-fw.sh`** | Soal 12 | `Magi-Casper` | Mode `diagnose` & `fix` untuk 4 masalah `break_fw.sh` sambil mempertahankan `policy INPUT DROP` (hardening aktif): tambah `ESTABLISHED,RELATED`, persempit blokir ICMP ke `echo-request`, izinkan TCP 5000, dan hapus blokir `OUTPUT` DNS UDP 53. |
| **`sabotage/break_routing.sh`**<br>**`sabotage/break_nat.sh`**<br>**`sabotage/break_fw.sh`** | Soal 9, 10, 12 | `Shigeru`<br>`Misato`, `Gendou`<br>`Magi-Casper` | Berkas skrip sabotase resmi dari asisten. |
