#!/data/data/com.termux/files/usr/bin/bash
# Telefonda (Termux + root) çalışır. CI çıktısından Lollipop init_boot imajı
# üretir ve system.img'i microSD'ye kopyalar. Hiçbir bölüme yazmaz.
#
# Kullanım: paketle.sh <cikti-klasoru> <yedek-init_boot_a.img>
#   cikti-klasoru: CI'dan indirilen root.tar.gz ve system.img'in olduğu yer
set -euo pipefail

CIKTI=$(realpath "$1")
YEDEK=$(realpath "$2")
DEPO=$(cd "$(dirname "$0")/.." && pwd)
CIHAZ="$DEPO/device/xiaomi/tapas"
IS=$(realpath "${TMPDIR:-/data/data/com.termux/files/usr/tmp}")/tapas-paketle
MB=/data/adb/magisk/magiskboot
BB=/data/adb/magisk/busybox

for f in "$CIKTI/root.tar.gz" "$CIKTI/system.img" "$YEDEK" "$MB" "$BB"; do
  su -c "[ -e '$f' ]" || { echo "Bulunamadı: $f"; exit 1; }
done

su -c "rm -rf '$IS' && mkdir -p '$IS/kok'"

# 1) Ramdisk: Lollipop kökü + tapas rc dosyaları. Dosyalar root'a ait olmalı,
#    bu yüzden her şey root olarak yapılıyor.
su -c "
set -e
cd '$IS/kok'
tar -xzf '$CIKTI/root.tar.gz' --strip-components=1
cp '$CIHAZ/init.tapas.rc' '$CIHAZ/init.tapas.modules.rc' .
chmod 0750 init.tapas.rc init.tapas.modules.rc
chown 0:0 init.tapas.rc init.tapas.modules.rc
grep -q '^import /init.tapas.rc' init.rc || sed -i '1i import /init.tapas.rc' init.rc
# userdata'ya dokunabilecek her şeyi çıkar: emülatör fstab'ı (mount_all) ve
# Lollipop'un şifreleme servisleri (vdc cryptfs).
rm -f init.goldfish.rc fstab.goldfish ueventd.goldfish.rc
sed -i 's|^service defaultcrypto .*|service defaultcrypto /system/bin/sh -c exit|; s|^service encrypt .*|service encrypt /system/bin/sh -c exit|' init.rc
if grep -q 'cryptfs' init.rc || ls fstab.* >/dev/null 2>&1; then echo 'HATA: userdata koruması uygulanamadı'; exit 1; fi
find . | $BB cpio -o -H newc > '$IS/yeni.cpio' 2>/dev/null
"

# 2) Yedek init_boot'u aç, ramdisk'i değiştir, yeniden paketle.
su -c "
set -e
cd '$IS'
$MB unpack '$YEDEK' >/dev/null 2>&1
mv -f yeni.cpio ramdisk.cpio
$MB repack '$YEDEK' lollipop_init_boot.img
"

BOYUT=$(su -c "stat -c %s '$IS/lollipop_init_boot.img'")
SINIR=$(su -c "stat -c %s '$YEDEK'")
if [ "$BOYUT" -gt "$SINIR" ]; then
  echo "HATA: imaj ($BOYUT bayt) init_boot bölümünden ($SINIR bayt) büyük"; exit 1
fi
su -c "cp '$IS/lollipop_init_boot.img' '$CIKTI/' && chown $(id -u):$(id -g) '$CIKTI/lollipop_init_boot.img'"
echo "Hazır: $CIKTI/lollipop_init_boot.img ($BOYUT bayt)"

# 3) microSD'ye system.img ve log betiği.
SD=$(su -c "grep ' /mnt/media_rw/' /proc/mounts | awk '{print \$2}' | head -1")
if [ -z "$SD" ]; then
  echo "microSD bulunamadı; system.img'i kartın /lollipop/ klasörüne elle kopyala."
  exit 0
fi
su -c "mkdir -p '$SD/lollipop' && cp '$CIKTI/system.img' '$SD/lollipop/system.img' && cp '$CIHAZ/log.sh' '$SD/lollipop/log.sh' && sync"
echo "microSD ($SD) hazır: lollipop/system.img, lollipop/log.sh"
