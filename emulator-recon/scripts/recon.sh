#!/system/bin/sh
echo "=== ID ==="
id
echo "=== MOUNT ==="
mount | grep -E ' / | /system | /vendor | /odm | /system_ext '
echo "=== LDSPOOF_FILES ==="
ls -l /system/etc/init/ldspoof.rc /system/etc/ldspoof.sh 2>&1
echo "=== LDSPOOF_RC ==="
cat /system/etc/init/ldspoof.rc 2>&1
echo "=== LDSPOOF_SH ==="
cat /system/etc/ldspoof.sh 2>&1
echo "=== EMULATOR_FILE_SCAN ==="
find /system /vendor /odm /system_ext -iname '*qemu*' -o -iname '*goldfish*' -o -iname '*ranchu*' 2>/dev/null
echo "=== DEV_NODES ==="
ls -l /dev/qemu* /dev/goldfish* /dev/socket/qemud /dev/socket/goldfish* 2>&1
echo "=== HOUDINI ==="
ls -l /system/lib64/libhoudini* /system/lib/libhoudini* /system/bin/houdini* /system/vendor/lib64/libhoudini* 2>&1
echo "=== CPUINFO ==="
head -45 /proc/cpuinfo
echo "=== VERSION ==="
cat /proc/version
echo "=== PRODUCT_PROPS ==="
getprop | grep -E 'product\.(system|vendor|odm|system_ext|bootimage)|ro\.product\.|ro\.build\.(fingerprint|description|flavor|id|tags|type|version\.)|ro\.boot\.|ro\.dalvik|ro\.hardware|ro\.opengles|phone\.'
echo "=== SETTINGS ==="
settings get secure android_id
settings get secure bluetooth_name
settings get secure bluetooth_address
cat /sys/class/net/wlan0/address 2>&1
echo "=== SENSORS ==="
dumpsys sensorservice 2>/dev/null | head -80
echo "=== PACKAGES ==="
pm list packages | grep -iE 'nd\.|aqcenter|myht|magisk|supersu|xposed|frida|ldplayer|leidian'
echo "=== SU_LIST ==="
ls -l /system/bin/su /system/xbin/su /sbin/su 2>&1
getprop init.svc.su_daemon
