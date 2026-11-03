#!/system/bin/sh
# LDPlayer14 L3 real-device spoof (instance 0) - post-boot runtime props.
# Runs as root service at sys.boot_completed=1 (see /system/etc/init/ldspoof.rc).
# Device profile: Xiaomi Redmi Note 13 Pro 5G (garnet), Android 14 / SDK 34.

# --- identity (ldinit may overwrite these after build.prop) ---
setprop ro.product.brand Redmi
setprop ro.product.name garnet_global
setprop ro.product.board parrot
setprop ro.product.device garnet
setprop ro.board.platform parrot
setprop ro.product.model 2312DRA50G
setprop ro.product.manufacturer Xiaomi
setprop phone.productname garnet
setprop ro.build.characteristics nosdcard
setprop ro.build.flavor missi_phone_global-user
setprop ro.build.fingerprint "Redmi/garnet_global/garnet:14/UKQ1.231003.002/V816.0.6.0.UNRMIXM:user/release-keys"
setprop ro.build.description "missi_phone_global-user 14 UKQ1.231003.002 V816.0.6.0.UNRMIXM release-keys"
setprop ro.boot.qemu 0
setprop ro.kernel.qemu 0
setprop ro.bootimage.build.fingerprint "Redmi/garnet_global/garnet:14/UKQ1.231003.002/V816.0.6.0.UNRMIXM:user/release-keys"
setprop ro.bootimage.build.id UKQ1.231003.002
setprop ro.bootimage.build.version.incremental V816.0.6.0.UNRMIXM
setprop ro.serialno 4b7c9d21
setprop ro.boot.serialno 4b7c9d21

# --- system_ext partition identity (was AOSP/unicorn) ---
setprop ro.product.system_ext.brand Redmi
setprop ro.product.system_ext.device garnet
setprop ro.product.system_ext.manufacturer Xiaomi
setprop ro.product.system_ext.model 2312DRA50G
setprop ro.product.system_ext.name garnet_global
setprop ro.system_ext.build.fingerprint "Redmi/garnet_global/garnet:14/UKQ1.231003.002/V816.0.6.0.UNRMIXM:user/release-keys"
setprop ro.system_ext.build.id UKQ1.231003.002
setprop ro.system_ext.build.version.incremental V816.0.6.0.UNRMIXM

# --- /proc/cpuinfo: present an ARM64 SoC view instead of host Xeon + hypervisor ---
if [ -f /system/etc/cpuinfo_arm64 ]; then
    mount --bind /system/etc/cpuinfo_arm64 /proc/cpuinfo
fi

# --- identifiers visible to Java/Settings consumers ---
settings put secure android_id b56f8672c393fb04
settings put secure bluetooth_name 2312DRA50G
settings put secure bluetooth_address 3C:BD:3E:82:0C:C2
settings put global device_name 2312DRA50G
