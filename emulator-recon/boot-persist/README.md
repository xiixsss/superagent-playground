# LDPlayer14 L1 运行时属性 · 开机自动重放（boot-persist）

针对 issue #14：LDPlayer14 index 1 的 L1 运行时属性（`ro.*` + 蓝牙地址）在每次开机后自动重放，不等人工。

## 结论：选方案 b（宿主机持久），不选 a（客户机内持久）

| 判据 | a. 客户机内持久 | b. 宿主机持久（本单采用） |
| --- | --- | --- |
| 注入点 | 需 `/data/adb` 服务脚本、init.d、或改 system 镜像加 init 服务 | Windows 计划任务，每分钟 + 登录时运行 |
| 本实例可行性 | ❌ 无 `/data/adb`、无 init.d；`/init.rc` 为 LD 加密二进制；`/system` 运行时只读 | ✅ 直接可用 |
| 是否需动镜像 | 要持久必须离线改 `system.vdi`（L2，本单硬约束不碰） | 否，纯 L1 |
| 可回滚性 | 改镜像难回滚 | 删计划任务 + 删目录即回滚 |
| 可观察性 | 客户机内日志难取 | 宿主机 `logs\boot_persist.log` 直接可读 |
| 覆盖范围 | 需自写脚本，且漏掉蓝牙地址 | 复用已验证的 `apply_l1_props.ps1`，覆盖全部运行时项（含蓝牙地址） |

调查到的开机链事实（2026-11-03 实测）：
- LDPlayer14 客户机内 `ldinit`（`init.svc.ldinit`）负责把 `leidian1.config` 的持久标识注入属性，并挂载 `/mnt/shared/*` 共享目录；`/system/etc/init/ldspoof.rc`（system 镜像内，预存）在 `sys.boot_completed=1` 时执行一次 `/system/etc/ldspoof.sh` 覆盖多数 `ro.*`，但**不覆盖蓝牙地址**。
- `/init.rc` 在磁盘上是 LD 加密文件，客户机内只读；无官方「开机执行脚本」目录；`ldconsole` 无开机注入命令。
- 因此最稳的 L1 注入点是**宿主机**：`ldconsole isrunning/getprop/setprop` + `ldconsole adb` 全部可用且不依赖 adb serial。

## 文件

| 文件 | 作用 |
| --- | --- |
| `boot_persist.ps1` | 自愈引擎：实例已开机且任一运行时属性回退 → 重放 `apply_l1_props.ps1` → 复验写日志。幂等，可每分钟跑 |
| `apply_l1_props.ps1` | 运行时属性重放（serial 自适应版，基于 PR #13 的 `emulator-recon/apply_l1_props.ps1`） |
| `install_boot_persist.ps1` | 安装到 `D:\emulator-recon\boot-persist` 并注册计划任务 `LDPlayer14-L1-BootPersist`（每分钟） |
| `uninstall_boot_persist.ps1` | 回滚：删计划任务（可选删文件） |
| `evidence/` | 实测回显（重启 / 注入自愈 / 宿主重启后） |

## 安装

```powershell
cd C:\Users\Administrator\src\superagent-playground\emulator-recon\boot-persist
powershell -NoProfile -ExecutionPolicy Bypass -File install_boot_persist.ps1
```

安装后：
- 脚本落在 `D:\emulator-recon\boot-persist\`（日志在 `logs\boot_persist.log`）。
- 计划任务 `LDPlayer14-L1-BootPersist` 以当前用户（Administrator）每 1 分钟运行一次，登录后自动可用。

## 回滚

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File uninstall_boot_persist.ps1 -RemoveFiles
```

## 实测（真实回显，见 evidence/）

### 1) 重启实例自动恢复（`evidence/reboot_test.log`，无人工干预）

```text
15:47:06  pre-reboot  fp=Redmi/garnet... dev=garnet qemu=0 brand=Redmi bt=8C:DE:F9:39:E4:75
15:47:26  t+0s        fp=Redmi/garnet... dev=garnet qemu=0 brand=Redmi bt=DA:4C:10:DE:17:02   ← 蓝牙地址开机回退
15:48:13  t+47s       fp=Redmi/garnet... dev=garnet qemu=0 brand=Redmi bt=8C:DE:F9:39:E4:75   ← 计划任务自动重放后恢复
```

对应任务日志（`logs\boot_persist.log`）：`15:48:03 mismatch(1): bluetooth_address=[DA:4C...]; replaying` → `15:48:10 VERIFY OK`。

### 2) 运行时属性被改回后自动自愈（`evidence/selfheal_required3_test.log`）

任务要求的三个校验项被手工打回原形后，下一分钟任务自动恢复：

```text
15:50:14  injected fp=Xiaomi/unicorn/unicorn... dev=unicorn qemu=1
15:51:31  check    fp=Redmi/garnet... dev=garnet qemu=0
```

任务日志：`15:51:03 mismatch(3): ro.product.device=[unicorn] ro.build.fingerprint=[Xiaomi/unicorn...] ro.boot.qemu=[1]; replaying` → `15:51:10 VERIFY OK`。

### 3) 宿主重启后任务仍在（`evidence/post_restart_test.log`）

宿主重启后实例停止，任务每 1 分钟记录 `instance not running; skip`；实例重新启动后自动重放（见该日志与任务日志）。

## 说明

- 本单只做 L1 运行时属性注入的自动化，未改任何镜像/未碰游戏文件。
- 实例当前的 `system.vdi` 内存在先前工作遗留的 guest 侧 `ldspoof` 服务（`/system/etc/init/ldspoof.rc`），它开机覆盖多数 `ro.*`；本单交付的宿主机任务与其并存，作为 L1 安全网补齐它不覆盖的蓝牙地址，并在任何属性回退时兜底重放。
