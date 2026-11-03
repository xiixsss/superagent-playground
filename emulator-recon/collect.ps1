$ErrorActionPreference = 'Continue'
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8
$adb = $args[0]
$s   = $args[1]
$out = $args[2]
if (-not $adb -or -not $s -or -not $out) { Write-Output 'usage: collect.ps1 <adb> <serial> <outdir>'; exit 1 }
New-Item -ItemType Directory -Force -Path $out | Out-Null

$cmds = [ordered]@{
  '01_getprop_full.txt'        = 'getprop'
  '01_build_prop_system.txt'   = 'cat /system/build.prop'
  '01_build_prop_vendor.txt'   = 'cat /vendor/build.prop'
  '01_build_prop_product.txt'  = 'cat /product/build.prop'
  '01_ro_product.txt'          = 'getprop | grep -E "ro.product|ro.build|ro.board|ro.hardware|ro.kernel.qemu|ro.boot.qemu|ro.le|ro.ld"'
  '02_proc_cpuinfo.txt'        = 'cat /proc/cpuinfo'
  '02_proc_version.txt'        = 'cat /proc/version'
  '02_proc_cmdline.txt'        = 'cat /proc/cmdline'
  '02_proc_input_devices.txt'  = 'cat /proc/bus/input/devices'
  '02_lib_emu.txt'             = 'ls -la /system/lib /system/lib64 /vendor/lib /vendor/lib64 2>/dev/null | grep -iE "goldfish|ranchu|qemu|ldplayer|leidian|dnplayer|nox|vbox|virtual"'
  '02_dev_emu.txt'             = 'ls -la /dev 2>/dev/null | grep -iE "goldfish|qemu|android|vbox|leidian|ld"'
  '02_sys_class.txt'           = 'ls /sys/class 2>/dev/null'
  '02_bin_emu.txt'             = 'ls /system/bin /system/xbin /vendor/bin 2>/dev/null | grep -iE "qemu|leidian|dnplayer|ld|vbox|nox"'
  '02_getprop_emu.txt'         = 'getprop | grep -iE "qemu|leidian|ldplayer|dnplayer|emulator|goldfish|ranchu|nox|vbox|virtual"'
  '03_android_id.txt'          = 'settings get secure android_id'
  '03_serialno_adb.txt'        = 'get-serialno'
  '03_props_serial.txt'        = 'getprop | grep -iE "serialno|serial|imei|meid|imsi|simserial|deviceid|android_id|device_id"'
  '03_imei_service.txt'        = 'service call iphonesubinfo 1'
  '03_imei_service2.txt'       = 'service call iphonesubinfo 4'
  '03_mac.txt'                 = 'cat /sys/class/net/wlan0/address 2>/dev/null; echo ---; ip link show 2>/dev/null; echo ---; getprop | grep -iE "mac|wifi|bt_|bluetooth"'
  '03_bt.txt'                  = 'settings get secure bluetooth_address; echo ---; settings get secure bluetooth_name; echo ---; getprop | grep -iE "bdaddr|bluetooth"'
  '03_wifi.txt'                = 'dumpsys wifi | grep -iE "Wi-Fi is|mWifiInfo|SSID|BSSID|MacAddress|IpClient"'
  '04_sensors.txt'             = 'dumpsys sensorservice'
  '04_battery.txt'             = 'dumpsys battery'
  '04_telephony.txt'           = 'dumpsys telephony.registry'
  '04_location.txt'            = 'dumpsys location | grep -iE "Gnss|GPS|provider|last location|enabled"'
  '04_location_settings.txt'   = 'settings get secure location_providers_allowed'
  '04_camera.txt'              = 'dumpsys media.camera'
  '04_features.txt'            = 'pm list features'
  '04_gpu.txt'                 = 'ls -la /system/lib64/egl /system/lib/egl /vendor/lib64/egl /vendor/lib/egl 2>/dev/null; echo ---; getprop | grep -iE "egl|gpu|opengl|vulkan|renderer|gralloc|glEs"'
  '04_gl_version.txt'          = 'getprop ro.opengles.version; echo ---; getprop ro.hardware.egl'
  '05_packages.txt'            = 'pm list packages -f'
  '05_packages_sus.txt'        = 'pm list packages | grep -iE "leidian|dnplayer|ldplayer|supersu|magisk|xposed|frida|root|su"'
  '05_su.txt'                  = 'which su; echo ---; su --version 2>&1; echo ---; ls -la /system/xbin/su /system/bin/su /sbin/su 2>&1; echo ---; su -c id 2>&1'
  '05_self_status.txt'         = 'cat /proc/self/status'
  '05_meminfo.txt'             = 'cat /proc/meminfo'
  '05_cpu.txt'                 = 'grep -c processor /proc/cpuinfo; echo ---; ls /sys/devices/system/cpu 2>/dev/null; echo ---; getprop | grep -iE "cpu|core"'
  '06_ip_addr.txt'             = 'ip addr show 2>/dev/null'
  '06_ip_route.txt'            = 'ip route show 2>/dev/null; echo ---; ip route show table all 2>/dev/null'
  '06_hosts.txt'               = 'cat /etc/hosts'
  '06_netprops.txt'            = 'getprop | grep -iE "dhcp|dns|gateway|net\.|wifi|ppp|radio"'
  '06_connectivity.txt'        = 'dumpsys connectivity | grep -iE "LinkAddresses|Routes|DnsAddresses|NetworkAgentInfo|WIFI"'
}

foreach ($k in $cmds.Keys) {
  $cmd = $cmds[$k]
  $tmp = Join-Path $out $k
  $r = & $adb -s $s shell $cmd 2>&1
  $r | Out-File -FilePath $tmp -Encoding utf8
  Write-Output ("== {0} => {1} bytes" -f $k, (Get-Item $tmp).Length)
}
Write-Output 'DONE'
