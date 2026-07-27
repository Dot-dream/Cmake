# CMake ARM MCU Project Template

自包含的 ARM MCU 嵌入式项目构建模版，支持多编译器。

## 支持的编译器

| 编译器 | cmake 入口 | 命令 |
|--------|-----------|------|
| ARM GCC | cmake/gcc.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/gcc.cmake` |
| ARMCC 5 | cmake/armac5.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/armac5.cmake` |
| ARMCC 6 | cmake/armac6.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/armac6.cmake` |
| IAR ICCARM | cmake/iccarm.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/iccarm.cmake` |
| GHS | cmake/ghs.cmake | `-DCMAKE_TOOLCHAIN_FILE=cmake/ghs.cmake` |

## 使用

```bash
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/gcc.cmake -DARM_CPU=cortex-m33 -B build
ninja -C build
```

工具链查找逻辑（`cmake/gcc.cmake`）：`tools/arm-gcc/bin/` → fallback 到系统 PATH。

## 目录结构

```
cmake/                     ← 可复用的构建模版
├── gcc.cmake              ← GCC 入口
├── iccarm.cmake           ← IAR 入口
├── armac5/6.cmake         ← ARMCC 入口
├── ghs.cmake              ← GHS 入口
├── config.cmake           ← 通用配置
├── configCore.cmake       ← Cortex-M/A/R 核心识别
├── configLib.cmake        ← 库配置
├── Toolchain/             ← 各编译器编译/链接选项
└── targets/               ← MCAL + 板级配置目标模版
    ├── GENERATED_CONFIG_TARGET.cmake
    └── GENERATED_SDK_TARGET.cmake
```

## License

MIT
