<#
.SYNOPSIS
    下载/安装 ARM MCU 工具链依赖
.DESCRIPTION
    默认从本地已知路径复制，使用 -Remote 从 GitHub Releases 下载
.PARAMETER Force
    强制重新安装（即使已存在）
.PARAMETER Remote
    从网络下载而非本地复制
#>
param(
    [switch]$Force,
    [switch]$Remote
)

$TOOLS_DIR = Join-Path $PSScriptRoot ".." "tools"
$GCC_CHECK = Join-Path $TOOLS_DIR "arm-gcc" "bin" "arm-none-eabi-gcc.exe"

# GitHub Releases 远端地址（使用前替换为你的 Release URL）
$REMOTE_URL = "https://github.com/Dot-dream/Cmake/releases/download/toolchain-v1/toolchain.zip"

# 本地源路径
$LOCAL_GCC    = "C:\Users\Administrator\AppData\Roaming\yt_config_tool\gcc-arm-none-eabi-10.3-2021.10"
$LOCAL_CMAKE  = "C:\Users\Administrator\AppData\Roaming\yt_config_tool\cmake-3.26.4-windows-x86_64"
$LOCAL_NINJA  = "C:\Users\Administrator\AppData\Roaming\yt_config_tool\ninja-win"
$LOCAL_JLINK  = "C:\Program Files\SEGGER\JLink_V862"

# 检查是否已安装
if ((Test-Path $GCC_CHECK) -and -not $Force) {
    Write-Host "[setup] tools/ 已就绪，跳过安装（使用 -Force 强制重装）" -ForegroundColor Green
    return
}

Write-Host "[setup] 安装工具链到 $TOOLS_DIR ..." -ForegroundColor Cyan

if ($Remote) {
    # ========== 远端下载模式 ==========
    Write-Host "[setup] 从 GitHub Releases 下载..." -ForegroundColor Yellow
    $zipPath = Join-Path $env:TEMP "cmake_toolchain.zip"
    
    try {
        Invoke-WebRequest -Uri $REMOTE_URL -OutFile $zipPath -UseBasicParsing
        Write-Host "[setup] 下载完成，解压中..." -ForegroundColor Cyan
        Expand-Archive -Path $zipPath -DestinationPath $TOOLS_DIR -Force
        Remove-Item $zipPath -Force
        Write-Host "[setup] 工具链安装完成！" -ForegroundColor Green
    }
    catch {
        Write-Host "[setup] 下载失败：$_" -ForegroundColor Red
        exit 1
    }
}
else {
    # ========== 本地复制模式 ==========
    Write-Host "[setup] 从本地路径复制..." -ForegroundColor Yellow

    # ARM GCC
    if (Test-Path $LOCAL_GCC) {
        robocopy (Join-Path $LOCAL_GCC "bin") (Join-Path $TOOLS_DIR "arm-gcc" "bin") /E /NFL /NDL /NJH /NJS /NP | Out-Null
        Write-Host "  ✅ ARM GCC" -ForegroundColor Green
    } else { Write-Host "  ⚠️  ARM GCC 未找到" -ForegroundColor Red }

    # CMake
    if (Test-Path $LOCAL_CMAKE) {
        robocopy $LOCAL_CMAKE $TOOLS_DIR\cmake /E /NFL /NDL /NJH /NJS /NP | Out-Null
        Write-Host "  ✅ CMake" -ForegroundColor Green
    } else { Write-Host "  ⚠️  CMake 未找到" -ForegroundColor Red }

    # Ninja
    if (Test-Path $LOCAL_NINJA) {
        robocopy $LOCAL_NINJA $TOOLS_DIR\ninja /E /NFL /NDL /NJH /NJS /NP | Out-Null
        Write-Host "  ✅ Ninja" -ForegroundColor Green
    } else { Write-Host "  ⚠️  Ninja 未找到" -ForegroundColor Red }

    # JLink
    if (Test-Path $LOCAL_JLINK) {
        robocopy $LOCAL_JLINK $TOOLS_DIR\jlink /E /NFL /NDL /NJH /NJS /NP | Out-Null
        Write-Host "  ✅ JLink" -ForegroundColor Green
    } else { Write-Host "  ⚠️  JLink 未找到" -ForegroundColor Red }

    Write-Host "[setup] 工具链安装完成！" -ForegroundColor Green
}
