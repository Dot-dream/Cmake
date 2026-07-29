# AGENTS.md

This file provides guidance to Codex when working on this repository.

## Project Overview

**cmakedemo** — 自包含的 ARM MCU CMake 构建模版仓库，托管在 [github.com/Dot-dream/Cmake](https://github.com/Dot-dream/Cmake)。

设计目标是提供一个**零绑定、可移植**的 CMake 构建模版：不假设任何 `board/` `Mcal/` `app/` 目录结构，用户可在任意项目架构中引用。

## 设计决策

1. **零绑定** — cmake/ 中没有任何硬编码的项目路径。targets/ 被删除（曾包含 GENERATED_CONFIG_TARGET / GENERATED_SDK_TARGET，绑定了 YTM32B1MD1 的 board/ 和 Mcal/ 路径）。
2. **多编译器支持** — 保留 GCC、ARMCC 5/6、IAR ICCARM、GHS 五套编译器入口，用户按需裁剪。
3. **工具链自包含** — cmake/gcc.cmake 优先查找 `tools/arm-gcc/bin/`，找不到才 fallback 到系统 PATH。
4. **仓库不存工具** — tools/ 目录已从 git 中移除（.gitignore 排除），用户本地自行存放。曾尝试用 Git LFS 存储但失败（msys-2.0.dll 在 Windows 上处理大批量文件时崩溃）。
5. **最小 CMakeLists.txt** — 仅包含一个 `project(example)` 示例，不引用任何外部文件。

## 目录结构

```
cmakedemo/
├── cmake/                     ← 纯构建模版（可复制到任意项目）
│   ├── gcc.cmake              ← GCC 入口（tools/ 本地查找 → 系统 PATH fallback）
│   ├── iccarm.cmake           ← IAR 入口
│   ├── armac5.cmake           ← ARMCC 5 入口
│   ├── armac6.cmake           ← ARMCC 6 入口
│   ├── ghs.cmake              ← GHS 入口
│   ├── config.cmake           ← 通用配置函数（include 后可使用）
│   ├── configCore.cmake       ← Cortex-M/A/R 核心识别 + 编译选项
│   ├── configLib.cmake        ← 库配置
│   └── Toolchain/             ← 各编译器编译/链接选项
│       ├── GCC.cmake
│       ├── AC5.cmake
│       ├── AC6.cmake
│       ├── ICCARM.cmake
│       ├── GHS.cmake
│       └── Tools.cmake        ← 编译器分发选择
├── scripts/                   ← 工具链管理脚本
│   ├── setup.ps1              ← 安装工具链
│   ├── build.ps1              ← 构建脚本
│   └── clean.ps1              ← 清理脚本
├── .vscode/                   ← VS Code 开箱配置
│   ├── extensions.json        ← 推荐插件
│   ├── settings.json          ← CMake + 工具链设置
│   └── launch.json            ← JLink 调试配置
├── CMakeLists.txt             ← 最小入口示例
├── CMakePresets.json          ← CMake Tools 预设（GCC-ARM x3）
├── build.ps1                  ← 构建快捷入口
├── .gitignore                 ← 全面排除规则
├── .gitattributes             ← 行尾规范（*.c/*.h/*.cmake 使用 LF）
├── README.md                  ← 用户使用说明
└── AGENTS.md                  ← 项目状态文档
```

## 使用方式

### 仅编译器入口（最轻量）

```bash
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/gcc.cmake -DARM_CPU=cortex-m33 -B build
ninja -C build
```

### 使用 config 函数

```cmake
project(my_firmware C ASM)
include(/path/to/cmake/config.cmake)
set(ARM_CPU "cortex-m33")
configcore(my_target ${CMAKE_SOURCE_DIR})
```

## Git 历史关键节点

| Commit | 说明 |
|--------|------|
| `0af1667` | 解耦：删除 targets/，模版不绑定任何项目结构 |
| `3a2d4cc` | 清理项目：只保留 cmake 构建模版 |
| `467cf6b` | 重构项目结构，添加 CMake 构建模版 |
| `550b427` | Initial commit |

## 已知问题

- **msys-2.0.dll 崩溃** — 当前 Git for Windows 在处理大量 LFS 文件时 `sh.exe` 会崩溃（signal pipe error），因此放弃了 Git LFS 方案。工具链只能本地存放，不入库。
- **旧 .git 权限锁** — `.git` 目录被外部进程添加了 DENY(W,D) 权限规则，无法删除或写入。通过分离式 `.git_repo/` 目录绕过。

## 脚本体系

项目提供三套 PowerShell 脚本用于工具链管理：

| 脚本 | 功能 |
|------|------|
| `scripts/setup.ps1` | 安装工具链（从本地已知路径复制或从 GitHub Releases 下载） |
| `scripts/build.ps1` | 一键构建：自动拉取工具链 → CMake 配置 → Ninja 编译 → 可选清理 |
| `scripts/clean.ps1` | 清理 `tools/` 和 `build/` |
| `build.ps1` | 根目录快捷入口，透传到 `scripts/build.ps1` |

### 使用方式

```powershell
# 一键构建（自动拉取工具链，构建完清理）
.\build.ps1

# 构建并保留工具链
.\build.ps1 -KeepTools

# 指定 CPU
.\build.ps1 -ArmCpu cortex-m4

# 仅安装工具链
.\scripts\setup.ps1

# 从网络下载工具链（需先上传到 GitHub Releases）
.\scripts\setup.ps1 -Remote

# 清理工具链
.\scripts\clean.ps1
```

### Git 操作（绕过权限问题）

```powershell
git --git-dir=.git_repo/.git --work-tree=. status
git --git-dir=.git_repo/.git --work-tree=. add -A
git --git-dir=.git_repo/.git --work-tree=. commit -m "msg"
git -c http.proxy="" --git-dir=.git_repo/.git --work-tree=. push origin main
```

## 本地工具链路径参考

| 工具 | 原始路径 |
|------|---------|
| ARM GCC | `C:\Users\Administrator\AppData\Roaming\yt_config_tool\gcc-arm-none-eabi-10.3-2021.10\` |
| CMake | 同上 `cmake-3.26.4-windows-x86_64\` |
| Ninja | 同上 `ninja-win\` |
| JLink | `C:\Program Files\SEGGER\JLink_V862\` |

## 上传规则（Git 仓库内容）

| 目录/文件 | 状态 | 说明 |
|-----------|------|------|
| cmake/ | ✅ 提交 | 构建模版核心，多编译器入口 |
| scripts/ | ✅ 提交 | setup / build / clean 脚本 |
| build.ps1 | ✅ 提交 | 根目录快捷入口 |
| CMakeLists.txt | ✅ 提交 | 最小入口示例（零绑定） |
| .gitignore | ✅ 提交 | 构建产物、tools/、IDE 配置排除 |
| .gitattributes | ✅ 提交 | 行尾规范 |
| README.md | ✅ 提交 | 项目说明 |
| AGENTS.md | ✅ 提交 | 项目状态记录 |
| tools/ | ❌ 排除 | 用户本地存放，通过 setup.ps1 安装 |
| .git_repo/ | ❌ 排除 | 分离式 git 数据目录 |
| build/ | ❌ 排除 | 构建产物 |
| .vscode/ | ❌ 排除 | 本地 IDE 配置 |


