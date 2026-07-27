# CMake ARM MCU Project Template

自包含的 ARM MCU 嵌入式项目构建模版，基于 CMake + Ninja/Make，支持 **GCC / ARMCC / IAR / GHS** 多编译器，可脱离系统环境变量独立使用。

## 设计目标

嵌入式项目通常面临以下问题：

- **工具链与项目绑定**：换电脑就要重装工具链、配环境变量 → 此模版允许将 ARM GCC / CMake / Ninja / JLink 直接放入 `tools/` 目录，**项目即环境**
- **不同芯片、不同编译器**：通过 ARM_CPU 一个变量切换目标核心，通过 cmake/ 下的编译器选择切换工具链
- **MCAL + 板级配置分层**：`GENERATED_CONFIG_TARGET`（板级初始化） + `GENERATED_SDK_TARGET`（外设驱动） 分离，移值芯片时相关文件修改不影响构建逻辑
- **跨项目复用**：cmake/ 目录作为只读模版，项目间复制即可，无需修改构建脚本

## 目录结构

```
cmakedemo/
├── cmake/                    ← 构建模版（**只读**，跨项目复用）
│   ├── gcc.cmake             ← GCC 入口（自动查找 tools/ 或系统 PATH）
│   ├── iccarm.cmake          ← IAR 入口
│   ├── armac5.cmake          ← ARMCC 5 入口
│   ├── armac6.cmake          ← ARMCC 6 入口
│   ├── ghs.cmake             ← GHS 入口
│   ├── config.cmake          ← 通用配置载入
│   ├── configCore.cmake      ← Cortex-M/A/R 核心识别 + 编译选项
│   ├── configLib.cmake       ← 库配置
│   ├── Toolchain/            ← 编译器特有编译/链接选项
│   │   ├── GCC.cmake
│   │   ├── AC5.cmake
│   │   ├── AC6.cmake
│   │   ├── ICCARM.cmake
│   │   ├── GHS.cmake
│   │   └── Tools.cmake       ← 编译器选择分发
│   └── targets/
│       ├── GENERATED_CONFIG_TARGET.cmake  ← 板级文件（.c/.S）组装
│       └── GENERATED_SDK_TARGET.cmake     ← MCAL 驱动文件组装
├── board/                    ← 板级配置 + 启动文件（换芯片换这里）
├── Mcal/                     ← MCAL 外设驱动（换芯片换这里）
├── app/                      ← 应用代码
├── examples/skeleton/        ← 示例骨架（空目录占位）
├── tools/                    ← 自包含工具链（.gitignore 排除，自愿选择是否入库）
│   ├── arm-gcc/              ← ARM GCC 工具链
│   ├── cmake/                ← CMake
│   ├── ninja/                ← Ninja
│   └── jlink/                ← JLink 烧录工具
├── CMakeLists.txt            ← 项目入口（改 ARM_CPU 即可移植）
├── .vscode/                  ← VS Code 工作区配置
│   ├── settings.json         ← CMake 配置（tools/ 本地路径）
│   ├── launch.json           ← cortex-debug 调试配置
│   └── chip.svd              ← SVD 寄存器描述文件
└── .gitignore                ← 排除 build/、tools/（可调整）
```

## 前置条件

### 方式 A：自包含（推荐，无需系统 PATH）

将以下工具放入 `tools/` 目录：

| 工具 | 说明 | 获取地址 |
|------|------|----------|
| ARM GCC | arm-none-eabi-gcc | [ARM GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) |
| CMake | cmake.exe | [CMake 官方下载](https://cmake.org/download/) |
| Ninja | ninja.exe | [Ninja Releases](https://github.com/ninja-build/ninja/releases) |
| JLink | JLinkGDBServerCL.exe | [SEGGER JLink](https://www.segger.com/downloads/jlink/) |

### 方式 B：系统 PATH 安装

在系统环境变量中安装上述工具即可，cmake/gcc.cmake 会自动 fallback 到系统 PATH 查找。

## 快速开始

### 使用 GCC 编译

```bash
# 配置（从 cmake 目录选择编译器入口）
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/gcc.cmake -DARM_CPU=cortex-m33 -B build

# 编译
ninja -C build
```

### 使用 IAR 编译

```bash
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/iccarm.cmake -DARM_CPU=cortex-m33 -B build
ninja -C build
```

### 调试与烧录（JLink）

```bash
# 启动 GDB Server
JLinkGDBServerCL -device YTM32B1MD1 -if SWD -speed 4000 &

# GDB 连接烧录
arm-none-eabi-gdb build/YTM32B1MD1.elf -ex "target remote localhost:2331" -ex "load"
```

VS Code 用户可直接使用 `.vscode/launch.json` 中预配置的 cortex-debug 任务。

## 换芯片流程

```diff
# CMakeLists.txt
- set(ARM_CPU "cortex-m33")
+ set(ARM_CPU "cortex-m4")

- set(DEVICE_NAME "YTM32B1MD1")
+ set(DEVICE_NAME "STM32F407")
```

同时替换：

- `board/` → 新芯片的启动文件、链接脚本、外设配置
- `Mcal/` → 新芯片的 MCAL 驱动库
- `tools/jlink/` → 对应芯片的烧录算法
- `.vscode/launch.json` → 修改 device 型号
- `.vscode/chip.svd` → 替换为对应芯片的 SVD 文件

## 构建架构

```
CMakeLists.txt
├── cmake/gcc.cmake           ← 工具链查找（本地 tools/ → 系统 PATH）
├── cmake/configCore.cmake    ← 核心识别 + 编译/链接选项
├── cmake/targets/
│   ├── GENERATED_CONFIG_TARGET  →  board/ 启动 + 配置
│   └── GENERATED_SDK_TARGET     →  Mcal/  驱动库
└── app/main.c                ← 应用入口
```

`GENERATED_CONFIG_TARGET` 与 `GENERATED_SDK_TARGET` 通过 `-Wl,--whole-archive` 互相链接，确保启动代码和驱动库的符号不被链接器丢弃。

## 支持编译器

| 编译器 | cmake 入口 | 关键词 |
|--------|-----------|--------|
| ARM GCC | cmake/gcc.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/gcc.cmake` |
| ARMCC 5 | cmake/armac5.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/armac5.cmake` |
| ARMCC 6 | cmake/armac6.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/armac6.cmake` |
| IAR ICCARM | cmake/iccarm.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/iccarm.cmake` |
| GHS | cmake/ghs.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/ghs.cmake` |

## 合并自

本模版核心 cmake 脚本源自 [YTM32 MCAL SDK](https://www.yth.com/) 的 BSW 构建框架，经提取泛化后形成通用模版，支持 AUTOSAR 风格的 MCAL + 板级配置分层架构。

## License

MIT
