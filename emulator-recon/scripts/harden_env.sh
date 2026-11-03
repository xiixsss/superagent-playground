#!/system/bin/sh
echo "=== whoami ==="
id
echo "=== remount ==="
mount -o rw,remount / 2>&1; echo rc=$?
echo "=== set props ==="
setprop ro.product.system_ext.brand Redmi
setprop ro.product.system_ext.device garnet
setprop ro.product.system_ext.manufacturer Xiaomi
setprop ro.product.system_ext.model 2312DRA50G
setprop ro.product.system_ext.name garnet_global
setprop ro.system_ext.build.fingerprint Redmi/garnet_global/garnet:14/UKQ1.231003.002/V816.0.6.0.UNRMIXM:user/release-keys
setprop ro.product.cpu.abi arm64-v8a
setprop ro.product.cpu.abilist arm64-v8a
setprop ro.product.cpu.abilist64 arm64-v8a
echo "=== bind fake cpuinfo ==="
mount --bind /data/local/tmp/cpuinfo_arm64 /proc/cpuinfo 2>&1; echo rc=$?
head -5 /proc/cpuinfo
echo "=== hide su ==="
mkdir -p /data/local/tmp/rootbak
cp -f /system/xbin/su /data/local/tmp/rootbak/su 2>&1
rm -f /system/bin/su
rm -f /system/xbin/su
ls -l /system/bin/su /system/xbin/su 2>&1
echo "=== verify props ==="
getprop ro.product.system_ext.device
getprop ro.product.system_ext.manufacturer
getprop ro.system_ext.build.fingerprint
getprop ro.product.cpu.abilist
getprop ro.product.model
getprop ro.product.manufacturer
