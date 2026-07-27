# CMake ARM MCU Build Template

纯 ARM MCU 构建模版，**不绑定任何项目结构**。你可以在任意项目架构中引用它。

## 设计原则

- **零绑定**：模版内没有 `board/`、`Mcal/`、`app/` 等路径假设
- **即插即用**：`-DCMAKE_TOOLCHAIN_FILE=cmake/gcc.cmake` 即可使用 GCC
- **多编译器**：GCC / ARMCC 5+6 / IAR ICCARM / GHS
- **自包含**：工具链可放 `tools/arm-gcc/bin/` 下，自动识别

## 使用方式

### 方式 A：仅用编译器入口（最轻量）

```bash
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=/path/to/template/cmake/gcc.cmake -DARM_CPU=cortex-m33 -B build
ninja -C build
```

工具链查找顺序：`tools/arm-gcc/bin/` → 系统 PATH。

### 方式 B：使用 config 函数

```cmake
# 你的 CMakeLists.txt
project(my_firmware C ASM)

# 引入模版的 ARM 核心识别等功能
include(/path/to/template/cmake/config.cmake)

set(ARM_CPU "cortex-m33")
configcore(my_firmware ${CMAKE_SOURCE_DIR})
```

## 支持的编译器

| 编译器 | cmake 入口 |
|--------|-----------|
| ARM GCC | `cmake/gcc.cmake` |
| ARMCC 5 | `cmake/armac5.cmake` |
| ARMCC 6 | `cmake/armac6.cmake` |
| IAR ICCARM | `cmake/iccarm.cmake` |
| GHS | `cmake/ghs.cmake` |

## 目录

```
cmake/                     ← 纯构建模版，可复制到任意项目
├── gcc.cmake              ← GCC 编译器入口
├── iccarm.cmake           ← IAR 编译器入口
├── armac5.cmake           ← ARMCC 5 入口
├── armac6.cmake           ← ARMCC 6 入口
├── ghs.cmake              ← GHS 入口
├── config.cmake           ← 通用配置函数
├── configCore.cmake       ← Cortex-M/A/R 核心识别
├── configLib.cmake        ← 库配置
└── Toolchain/             ← 各编译器编译/链接选项
    ├── GCC.cmake
    ├── AC5/6.cmake
    ├── ICCARM.cmake
    ├── GHS.cmake
    └── Tools.cmake         ← 编译器分发
```

**不绑定路径**：模版中不包含 `board/`、`Mcal/`、`app/` 等目录引用。

## License

MIT
