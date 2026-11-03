#!/system/bin/sh
# L3 persistence apply (instance 0) - writes into the per-instance system.vdi
mount -o rw,remount / 2>&1 || { echo "REMOUNT FAILED"; exit 1; }
echo "=== backup originals to /data/local/tmp/l3_backup ==="
mkdir -p /data/local/tmp/l3_backup
cp -f /system/etc/ldspoof.sh /data/local/tmp/l3_backup/ldspoof.sh.orig
cp -f /system/system_ext/etc/build.prop /data/local/tmp/l3_backup/system_ext_build.prop.orig
cp -f /system/system_ext/bin/init.qemu-adb-keys.sh /data/local/tmp/l3_backup/init.qemu-adb-keys.sh.orig
ls -l /data/local/tmp/l3_backup
echo "=== install ldspoof.sh (new) ==="
cp -f /data/local/tmp/ldspoof_new.sh /system/etc/ldspoof.sh
chmod 0644 /system/etc/ldspoof.sh
echo "=== install fake cpuinfo to /system/etc ==="
cp -f /data/local/tmp/cpuinfo_arm64 /system/etc/cpuinfo_arm64
chmod 0644 /system/etc/cpuinfo_arm64
echo "=== append system_ext build.prop overrides ==="
cat /data/local/tmp/sysext_append.prop >> /system/system_ext/etc/build.prop
echo "=== delete qemu feature script ==="
rm -f /system/system_ext/bin/init.qemu-adb-keys.sh
echo "=== result ==="
ls -l /system/etc/ldspoof.sh /system/etc/cpuinfo_arm64 /system/system_ext/etc/build.prop
tail -12 /system/system_ext/etc/build.prop
ls -l /system/system_ext/bin/init.qemu-adb-keys.sh 2>&1
sync
echo "=== DONE ==="
