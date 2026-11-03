$ErrorActionPreference = 'Continue'
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8
$adb = $args[0]
$s   = $args[1]
$out = $args[2]
New-Item -ItemType Directory -Force -Path $out | Out-Null

$cmds = [ordered]@{
  '01_ro_product.txt'       = "getprop | grep -E 'ro.product|ro.build|ro.board|ro.hardware|ro.kernel.qemu|ro.boot.qemu|ro.le|ro.ld'"
  '01_build_prop_system.txt'= "su -c 'cat /system/build.prop'"
  '01_build_prop_vendor.txt'= "su -c 'cat /vendor/build.prop'"
  '02_proc_cmdline.txt'     = "su -c 'cat /proc/cmdline'"
  '02_lib_emu.txt'          = "ls -la /system/lib /system/lib64 /vendor/lib /vendor/lib64 2>/dev/null | grep -iE 'goldfish|ranchu|qemu|ldplayer|leidian|dnplayer|nox|vbox|virtual'"
  '02_dev_emu.txt'          = "ls -la /dev 2>/dev/null | grep -iE 'goldfish|qemu|android|vbox|leidian|ld'"
  '02_bin_emu.txt'          = "ls /system/bin /system/xbin /vendor/bin 2>/dev/null | grep -iE 'qemu|leidian|dnplayer|ld|vbox|nox'"
  '02_getprop_emu.txt'      = "getprop | grep -iE 'qemu|leidian|ldplayer|dnplayer|emulator|goldfish|ranchu|nox|vbox|virtual'"
  '02_sys_misc_ld.txt'      = "ls -la /sys/devices 2>/dev/null; echo ---; ls -la /sys/bus 2>/dev/null | grep -iE 'virtio|pci|platform|sdio'"
  '03_props_serial.txt'     = "getprop | grep -iE 'serialno|serial|imei|meid|imsi|simserial|deviceid|android_id|device_id'"
  '03_mac.txt'              = "cat /sys/class/net/wlan0/address 2>/dev/null; echo ---; ip link show 2>/dev/null; echo ---; getprop | grep -iE 'mac|wifi|bt_|bluetooth'"
  '03_bt.txt'               = "settings get secure bluetooth_address; echo ---; settings get secure bluetooth_name; echo ---; getprop | grep -iE 'bdaddr|bluetooth'"
  '03_wifi.txt'             = "dumpsys wifi | grep -iE 'Wi-Fi is|mWifiInfo|SSID|BSSID|MacAddress|IpClient'"
  '04_location.txt'         = "dumpsys location | grep -iE 'Gnss|GPS|provider|last location|enabled'"
  '04_gpu.txt'              = "ls -la /system/lib64/egl /system/lib/egl /vendor/lib64/egl /vendor/lib/egl 2>/dev/null; echo ---; getprop | grep -iE 'egl|gpu|opengl|vulkan|renderer|gralloc|glEs'"
  '05_packages_sus.txt'     = "pm list packages | grep -iE 'leidian|dnplayer|ldplayer|supersu|magisk|xposed|frida|root|su'"
  '06_netprops.txt'         = "getprop | grep -iE 'dhcp|dns|gateway|net\.|wifi|ppp|radio'"
  '06_connectivity.txt'     = "dumpsys connectivity | grep -iE 'LinkAddresses|Routes|DnsAddresses|NetworkAgentInfo|WIFI'"
}

foreach ($k in $cmds.Keys) {
  $cmd = $cmds[$k]
  $tmp = Join-Path $out $k
  $r = & $adb -s $s shell $cmd 2>&1
  $r | Out-File -FilePath $tmp -Encoding utf8
  Write-Output ("== {0} => {1} bytes" -f $k, (Get-Item $tmp).Length)
}
Write-Output 'DONE'
