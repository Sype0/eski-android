#!/bin/bash
# Lollipop kaynağına tapas (GKI 5.15) için gereken yamaları uygular.
# Kullanım: yamala.sh <aosp-kök-dizini>
set -euo pipefail

AOSP="$1"
INIT_C="$AOSP/system/core/init/init.c"

# 1) SELinux'u kapat.
# Yeni çekirdek androidboot.* ayarlarını /proc/cmdline yerine bootconfig'den
# veriyor; Lollipop init'i androidboot.selinux'u göremiyor. Lollipop'un
# sepolicy'si 5.15'e yüklenemezse init telefonu bootloader'a atar, bu yüzden
# politikayı hiç yüklemiyoruz.
if ! grep -q "tapas: SELinux kapalı" "$INIT_C"; then
  sed -i '/^static bool selinux_is_disabled(void)/,/^{/ s|^{|{\n    return true; /* tapas: SELinux kapalı */|' "$INIT_C"
fi
grep -q "tapas: SELinux kapalı" "$INIT_C" || { echo "HATA: SELinux yaması uygulanamadı"; exit 1; }
echo "SELinux yaması tamam"
