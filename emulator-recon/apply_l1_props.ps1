# apply_l1_props.ps1
# LDPlayer14 L1 property spoofing - re-apply runtime props after each reboot.
# Runtime-layer props (fingerprint/device/serial/qemu/...) reset on every boot.
# Usage: powershell -ExecutionPolicy Bypass -File emulator-recon\apply_l1_props.ps1

$ErrorActionPreference = 'Continue'
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8

$ld  = 'D:\leidian\LDPlayer14\ldconsole.exe'
$adb = 'D:\leidian\LDPlayer14\adb.exe'
$s   = 'emulator-5556'

function Set-Prop($key, $value) {
    & $ld setprop --index 1 --key $key --value $value | Out-Null
    $got = (& $adb -s $s shell getprop $key 2>&1 | Out-String).Trim()
    if ($got -ne $value) { Write-Output "FAIL $key => [$got]" } else { Write-Output "OK   $key" }
}

Write-Output '== 1. runtime build.prop props =='
Set-Prop 'ro.product.brand' 'Redmi'
Set-Prop 'ro.product.device' 'garnet'
Set-Prop 'ro.product.name' 'garnet_global'
Set-Prop 'ro.product.board' 'parrot'
Set-Prop 'ro.board.platform' 'parrot'
Set-Prop 'ro.build.fingerprint' 'Redmi/garnet_global/garnet:14/UKQ1.231003.002/V816.0.6.0.UNRMIXM:user/release-keys'
Set-Prop 'ro.build.flavor' 'missi_phone_global-user'
Set-Prop 'ro.build.characteristics' 'nosdcard'
Set-Prop 'ro.boot.qemu' '0'
Set-Prop 'ro.serialno' 'a68563e7'
Set-Prop 'ro.boot.serialno' 'a68563e7'
Set-Prop 'ro.bootimage.build.fingerprint' 'Redmi/garnet_global/garnet:14/UKQ1.231003.002/V816.0.6.0.UNRMIXM:user/release-keys'
Set-Prop 'ro.bootimage.build.version.incremental' 'V816.0.6.0.UNRMIXM'
Set-Prop 'ro.bootimage.build.id' 'UKQ1.231003.002'
Set-Prop 'ro.bootimage.build.version.release' '14'
Set-Prop 'ro.bootimage.build.version.sdk' '34'
Set-Prop 'phone.productname' 'garnet'

Write-Output '== 2. prop with spaces (guest setprop) =='
& $adb -s $s shell "setprop ro.build.description 'missi_phone_global-user 14 UKQ1.231003.002 V816.0.6.0.UNRMIXM release-keys'" | Out-Null
$desc = (& $adb -s $s shell getprop ro.build.description 2>&1 | Out-String).Trim()
Write-Output "ro.build.description => [$desc]"

Write-Output '== 3. bluetooth address (resets on boot) =='
& $adb -s $s shell settings put secure bluetooth_address 8C:DE:F9:39:E4:75 | Out-Null
$bt = (& $adb -s $s shell settings get secure bluetooth_address 2>&1 | Out-String).Trim()
Write-Output "bluetooth_address => [$bt]"

Write-Output '== 4. verify =='
$fp = (& $adb -s $s shell getprop ro.build.fingerprint 2>&1 | Out-String).Trim()
$model = (& $adb -s $s shell getprop ro.product.model 2>&1 | Out-String).Trim()
$qemu = (& $adb -s $s shell getprop ro.boot.qemu 2>&1 | Out-String).Trim()
Write-Output "fingerprint=$fp"
Write-Output "model=$model"
Write-Output "boot.qemu=$qemu"
