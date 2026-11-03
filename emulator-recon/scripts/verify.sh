#!/system/bin/sh
echo "=== BOOT ==="
getprop sys.boot_completed
echo "=== IDENTITY ==="
for k in ro.product.model ro.product.manufacturer ro.product.brand ro.product.device ro.product.name ro.product.board ro.board.platform ro.build.fingerprint ro.build.description ro.build.characteristics ro.build.flavor ro.boot.qemu ro.boot.serialno ro.serialno ro.product.system_ext.model ro.product.system_ext.device ro.product.system_ext.manufacturer ro.system_ext.build.fingerprint phone.productname; do
  printf "%-45s = %s\n" "$k" "$(getprop $k)"
done
echo "=== SU ==="
ls -l /system/xbin/su /system/bin/su /sbin/su 2>&1
echo "=== CPUINFO (first 6 lines) ==="
head -6 /proc/cpuinfo
echo "=== CPUINFO MOUNT ==="
mount | grep cpuinfo
echo "=== QEMU FILES ==="
ls -l /system/system_ext/bin/init.qemu-adb-keys.sh 2>&1
find /system /vendor /odm /system_ext -iname '*qemu*' -o -iname '*goldfish*' -o -iname '*ranchu*' 2>/dev/null
echo "=== DEV NODES ==="
ls -l /dev/qemu* /dev/goldfish* /dev/socket/qemud 2>&1
echo "=== SETTINGS ==="
settings get secure android_id
settings get secure bluetooth_name
settings get secure bluetooth_address
settings get global device_name
echo "=== MAC ==="
cat /sys/class/net/wlan0/address
echo "=== LOCATION ==="
dumpsys location 2>/dev/null | grep -iE 'last location|gps' | head -6
echo "=== PKG ==="
pm path com.nd.aqcenter
echo "=== LDSPOOF LOG ==="
logcat -d -s ldspoof 2>/dev/null | tail -5
