"""OrangeFox/TWRP için init_boot flaş zip'i üretir (yedek almaz).

Kullanım: python3 -I zip-yap.py <init_boot.img> <çıktı.zip> <başlık>
"""
import os
import sys
import zipfile

img, cikti, baslik = sys.argv[1:4]
depo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

with open(os.path.join(depo, "zip", "update-binary"), encoding="utf-8") as f:
    binary = f.read().replace("@BASLIK@", baslik)

with zipfile.ZipFile(cikti, "w", zipfile.ZIP_DEFLATED) as z:
    bilgi = zipfile.ZipInfo("META-INF/com/google/android/update-binary")
    bilgi.external_attr = 0o755 << 16
    bilgi.compress_type = zipfile.ZIP_DEFLATED
    z.writestr(bilgi, binary)
    z.writestr("META-INF/com/google/android/updater-script", "#dummy\n")
    z.write(img, "init_boot.img")

print(cikti)
