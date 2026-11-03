# install_boot_persist.ps1
# Installs the LDPlayer14 index 1 L1 boot-persist guard as a Windows Scheduled Task.
# The task runs boot_persist.ps1 every minute (self-healing: replays after every
# instance boot/reboot, no human action needed).
#
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File install_boot_persist.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File install_boot_persist.ps1 -InstallDir D:\emulator-recon\boot-persist -TaskName LDPlayer14-L1-BootPersist

param(
    [string]$InstallDir = 'D:\emulator-recon\boot-persist',
    [string]$TaskName  = 'LDPlayer14-L1-BootPersist'
)

$ErrorActionPreference = 'Stop'
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8

# 1. Copy the runtime scripts to a stable install location (outside the git worktree).
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item -Force (Join-Path $PSScriptRoot 'boot_persist.ps1')   $InstallDir
Copy-Item -Force (Join-Path $PSScriptRoot 'apply_l1_props.ps1') $InstallDir
New-Item -ItemType Directory -Force -Path (Join-Path $InstallDir 'logs') | Out-Null
Write-Output "installed scripts -> $InstallDir"

# 2. Register a per-minute scheduled task (runs as the current user when logged on).
$tr = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}\boot_persist.ps1"' -f $InstallDir
schtasks /Create /TN $TaskName /SC MINUTE /MO 1 /TR $tr /F /RL HIGHEST | Out-String | Write-Output
Write-Output "scheduled task registered: $TaskName"

# 3. Run once now to prove the loop works end-to-end.
Write-Output '--- first run ---'
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $InstallDir 'boot_persist.ps1') 2>&1 | Out-String | Write-Output
Write-Output "rollback: powershell -NoProfile -ExecutionPolicy Bypass -File $(Join-Path $PSScriptRoot 'uninstall_boot_persist.ps1')"
