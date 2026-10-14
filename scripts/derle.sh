#!/bin/bash
# Konteynerin içinde çalışır: /aosp kaynak ağacı, AOSP_LUNCH lunch hedefi.
set -eo pipefail

cd /aosp
java -version

# Önceden derlenmiş dex (dexpreopt) kapalı: daha hızlı derleme, daha küçük imaj.
export WITH_DEXPREOPT=false

source build/envsetup.sh
lunch "$AOSP_LUNCH"

# Çıktı klasörünün yolunu runner'a bildir (ör. out/target/product/generic_arm64).
get_build_var PRODUCT_OUT | sed 's|^/aosp/||' > product_out.txt

make -j"$(nproc)" 2>&1 | tee build.log
