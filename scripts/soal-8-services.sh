#!/bin/sh
# ==============================================================================
# soal-8-services.sh - Wrapper Soal 8: Deteksi Pen-Pen / Tokyo3-Core
# Praktikum Jarkom Modul 5 - Kelompok K-02
# ==============================================================================
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NODE=$(hostname | tr '[:upper:]' '[:lower:]')

case "$NODE" in
    *pen-pen*|*penpen*)
        [ -f "$SCRIPT_DIR/penpen.sh" ] && [ "$SCRIPT_DIR/penpen.sh" != "/root/penpen.sh" ] && cp "$SCRIPT_DIR/penpen.sh" /root/penpen.sh && chmod +x /root/penpen.sh
        sh /root/penpen.sh "$@"
        ;;
    *tokyo3*)
        [ -f "$SCRIPT_DIR/tokyo3.sh" ] && [ "$SCRIPT_DIR/tokyo3.sh" != "/root/tokyo3.sh" ] && cp "$SCRIPT_DIR/tokyo3.sh" /root/tokyo3.sh && chmod +x /root/tokyo3.sh
        sh /root/tokyo3.sh "$@"
        ;;
    *)
        echo "[ERROR] Script ini hanya untuk Pen-Pen atau Tokyo3-Core."
        exit 1
        ;;
esac
