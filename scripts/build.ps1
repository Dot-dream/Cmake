<#
.SYNOPSIS
    一键构建 ARM MCU 固件
.DESCRIPTION
    自动拉取工具链 → CMake 配置 → Ninja 编译 → 可选清理
.PARAMETER KeepTools
    构建完成后保留工具链（默认自动清理）
.PARAMETER ArmCpu
    目标 CPU 核心（默认 cortex-m33）
.PARAMETER Generator
    CMake 生成器（默认 Ninja）
.PARAMETER Clean
    先清理 build 目录再构建
#>
param(
    [switch]$KeepTools,
    [string]$ArmCpu   = "cortex-m33",
    [string]$Generator = "Ninja",
    [switch]$Clean
)

$ROOT = $PSScriptRoot
$CMAKE  = Join-Path $ROOT "tools" "cmake" "bin" "cmake.exe"
$NINJA  = Join-Path $ROOT "tools" "ninja" "ninja.exe"
$BUILD  = Join-Path $ROOT "build"

# ========== 1. 确保工具链 ==========
if (-not (Test-Path (Join-Path $ROOT "tools" "arm-gcc" "bin" "arm-none-eabi-gcc.exe"))) {
    Write-Host "`n=== 拉取工具链 ===" -ForegroundColor Cyan
    & (Join-Path $ROOT "scripts" "setup.ps1")
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# ========== 2. 清理（可选） ==========
if ($Clean -and (Test-Path $BUILD)) {
    Remove-Item $BUILD -Recurse -Force
    Write-Host "  🧹 build/ 已清理" -ForegroundColor Yellow
}

# ========== 3. CMake 配置 ==========
Write-Host "`n=== CMake 配置 ===" -ForegroundColor Cyan
& $CMAKE -G $Generator `
    -DCMAKE_TOOLCHAIN_FILE="cmake/gcc.cmake" `
    -DARM_CPU=$ArmCpu `
    -B $BUILD `
    -S $ROOT
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# ========== 4. Ninja 编译 ==========
Write-Host "`n=== 编译 ===" -ForegroundColor Cyan
& $NINJA -C $BUILD
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n✅ 构建成功！输出文件在 build/" -ForegroundColor Green

# ========== 5. 清理工具链（可选） ==========
if (-not $KeepTools) {
    Write-Host "`n=== 清理工具链 ===" -ForegroundColor Cyan
    & (Join-Path $ROOT "scripts" "clean.ps1")
}
