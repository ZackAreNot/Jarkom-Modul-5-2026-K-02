#!/bin/sh
# ==============================================================================
# soal-7-magi.sh - Wrapper Soal 7: Deteksi node MAGI & jalankan /root/<nama>.sh
# Praktikum Jarkom Modul 5 - Kelompok K-02
# ==============================================================================
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NODE=$(hostname | tr '[:upper:]' '[:lower:]')

case "$NODE" in
    *casper*)
        [ -f "$SCRIPT_DIR/casper.sh" ] && [ "$SCRIPT_DIR/casper.sh" != "/root/casper.sh" ] && cp "$SCRIPT_DIR/casper.sh" /root/casper.sh && chmod +x /root/casper.sh
        sh /root/casper.sh "$@"
        ;;
    *balthasar*)
        [ -f "$SCRIPT_DIR/balthasar.sh" ] && [ "$SCRIPT_DIR/balthasar.sh" != "/root/balthasar.sh" ] && cp "$SCRIPT_DIR/balthasar.sh" /root/balthasar.sh && chmod +x /root/balthasar.sh
        sh /root/balthasar.sh "$@"
        ;;
    *melchior*)
        [ -f "$SCRIPT_DIR/melchior.sh" ] && [ "$SCRIPT_DIR/melchior.sh" != "/root/melchior.sh" ] && cp "$SCRIPT_DIR/melchior.sh" /root/melchior.sh && chmod +x /root/melchior.sh
        sh /root/melchior.sh "$@"
        ;;
    *)
        echo "[ERROR] Script ini hanya untuk Magi-Casper, Magi-Balthasar, atau Magi-Melchior."
        exit 1
        ;;
esac
