# microSD'ye /lollipop/log.sh olarak kopyalanır; Lollipop açılışında çalışır.
L=/sd/lollipop/log
mkdir -p $L
while true; do
    dmesg > $L/dmesg.txt
    logcat -d -v time > $L/logcat.txt
    getprop > $L/getprop.txt
    ps > $L/ps.txt
    sync
    sleep 5
done
