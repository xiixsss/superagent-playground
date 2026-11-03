# apply_l1_props.ps1
# LDPlayer14 L1 runtime property replay (serial-robust).
# Re-applies runtime-layer props that reset on every boot. Safe to run repeatedly.
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File apply_l1_props.ps1
#   (optional) -Index 1

param(
    [string]$Index = '1'
)

$ErrorActionPreference = 'Continue'
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8

$ld  = 'D:\leidian\LDPlayer14\ldconsole.exe'
$adb = 'D:\leidian\LDPlayer14\adb.exe'

# adb serial for index 1 flips between the emulator name and the TCP endpoint
# after adb server rescans. Resolve it every run instead of hardcoding.
function Get-AdbSerial {
    $dev = & $adb devices 2>$null
    foreach ($line in $dev) {
        if ($line -match '^(emulator-5556|127\.0\.0\.1:5557)\s+device') {
            return ($line -split '\s+')[0]
        }
    }
    return $null
}

$s = Get-AdbSerial
if (-not $s) {
    Write-Output 'FAIL adb device for index 1 not found (emulator-5556 / 127.0.0.1:5557)'
    exit 1
}

function Set-Prop([string]$key, [string]$value) {
    & $ld setprop --index $Index --key $key --value $value | Out-Null
    $got = (& $ld getprop --index $Index --key $key 2>&1 | Out-String).Trim()
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
$desc = (& $ld getprop --index $Index --key ro.build.description 2>&1 | Out-String).Trim()
Write-Output "ro.build.description => [$desc]"

Write-Output '== 3. bluetooth address (resets on boot) =='
& $adb -s $s shell settings put secure bluetooth_address 8C:DE:F9:39:E4:75 | Out-Null
$bt = (& $adb -s $s shell settings get secure bluetooth_address 2>&1 | Out-String).Trim()
Write-Output "bluetooth_address => [$bt]"

Write-Output '== 4. verify =='
$fp = (& $ld getprop --index $Index --key ro.build.fingerprint 2>&1 | Out-String).Trim()
$dev = (& $ld getprop --index $Index --key ro.product.device 2>&1 | Out-String).Trim()
$qemu = (& $ld getprop --index $Index --key ro.boot.qemu 2>&1 | Out-String).Trim()
Write-Output "fingerprint=$fp"
Write-Output "device=$dev"
Write-Output "boot.qemu=$qemu"
