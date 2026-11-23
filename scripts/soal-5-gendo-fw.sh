#!/bin/sh
# ==============================================================================
# soal-5-gendo-fw.sh - Soal 5: Terapkan /root/gendo.sh (Default Deny di Gendou)
# Praktikum Jarkom Modul 5 - Kelompok K-02
# ==============================================================================
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/gendo.sh" ] && [ "$SCRIPT_DIR/gendo.sh" != "/root/gendo.sh" ]; then
    cp "$SCRIPT_DIR/gendo.sh" /root/gendo.sh
    chmod +x /root/gendo.sh
fi

if [ ! -f /root/gendo.sh ]; then
    echo "[ERROR] /root/gendo.sh tidak ditemukan! Salin scripts/gendo.sh ke /root/gendo.sh terlebih dahulu."
    exit 1
fi

sh /root/gendo.sh
