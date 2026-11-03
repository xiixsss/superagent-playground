# uninstall_boot_persist.ps1
# Removes the scheduled task and (optionally) the installed scripts.
#
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File uninstall_boot_persist.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File uninstall_boot_persist.ps1 -InstallDir D:\emulator-recon\boot-persist -TaskName LDPlayer14-L1-BootPersist

param(
    [string]$InstallDir = 'D:\emulator-recon\boot-persist',
    [string]$TaskName  = 'LDPlayer14-L1-BootPersist',
    [switch]$RemoveFiles
)

$ErrorActionPreference = 'Continue'
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
Write-Output "task removed: $TaskName"

if ($RemoveFiles) {
    Remove-Item -Recurse -Force $InstallDir -ErrorAction SilentlyContinue
    Write-Output "files removed: $InstallDir"
} else {
    Write-Output "files kept: $InstallDir (use -RemoveFiles to delete)"
}
