<#
.SYNOPSIS
    清理本地工具链和构建输出
.PARAMETER All
    同时清理 build/ 目录
#>
param([switch]$All)

$TOOLS = Join-Path $PSScriptRoot ".." "tools"
$BUILD = Join-Path $PSScriptRoot ".." "build"

if (Test-Path $TOOLS) {
    Remove-Item $TOOLS -Recurse -Force
    Write-Host "🧹 tools/ 已清理" -ForegroundColor Yellow
} else {
    Write-Host "tools/ 不存在，跳过" -ForegroundColor Gray
}

if ($All -and (Test-Path $BUILD)) {
    Remove-Item $BUILD -Recurse -Force
    Write-Host "🧹 build/ 已清理" -ForegroundColor Yellow
}
