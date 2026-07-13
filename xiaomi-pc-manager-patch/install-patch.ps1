# 小米电脑管家 非小米设备补丁部署脚本
# 作者：鲨鲨 🦈
# 用途：自动检测小米电脑管家安装路径并部署 wtsapi32.dll 补丁

param(
    [string]$DllPath  # 可选：直接指定 wtsapi32.dll 的路径
)

#Requires -RunAsAdministrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  小米电脑管家 非小米设备补丁部署工具" -ForegroundColor Cyan
Write-Host "  🦈 by 鲨鲨" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 查找小米电脑管家安装路径
$installPaths = @(
    "C:\Program Files\MI\XiaomiPCManager",
    "C:\Program Files (x86)\MI\XiaomiPCManager",
    "${env:LOCALAPPDATA}\Programs\MI\XiaomiPCManager"
)

$foundPath = $null
$versionDir = $null

foreach ($path in $installPaths) {
    if (Test-Path $path) {
        $foundPath = $path
        # 查找版本号目录
        $versions = Get-ChildItem -Path $path -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' } | Sort-Object Name -Descending
        if ($versions.Count -gt 0) {
            $versionDir = $versions[0].FullName
        }
        break
    }
}

if (-not $foundPath) {
    Write-Host "[错误] 未找到小米电脑管家安装目录" -ForegroundColor Red
    Write-Host "请确认小米电脑管家已安装，或手动指定安装路径" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "常见安装路径：" -ForegroundColor Yellow
    Write-Host "  C:\Program Files\MI\XiaomiPCManager" -ForegroundColor Gray
    Write-Host "  C:\Program Files (x86)\MI\XiaomiPCManager" -ForegroundColor Gray
    Write-Host ""
    $manualPath = Read-Host "请输入小米电脑管家安装路径（或按 Enter 退出）"
    if ($manualPath -and (Test-Path $manualPath)) {
        $foundPath = $manualPath
        $versions = Get-ChildItem -Path $foundPath -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' } | Sort-Object Name -Descending
        if ($versions.Count -gt 0) {
            $versionDir = $versions[0].FullName
        }
    } else {
        exit 1
    }
}

Write-Host "[信息] 找到安装目录: $foundPath" -ForegroundColor Green
if ($versionDir) {
    Write-Host "[信息] 版本目录: $versionDir" -ForegroundColor Green
}
Write-Host ""

# 2. 获取 wtsapi32.dll 文件
$dllDestination = $null

if ($DllPath -and (Test-Path $DllPath)) {
    # 使用参数指定的 DLL
    $dllSource = $DllPath
    Write-Host "[信息] 使用指定的补丁文件: $dllSource" -ForegroundColor Green
} else {
    # 检查当前目录是否有 wtsapi32.dll
    $currentDirDll = Join-Path $PSScriptRoot "wtsapi32.dll"
    if (Test-Path $currentDirDll) {
        $dllSource = $currentDirDll
        Write-Host "[信息] 找到当前目录的补丁文件: $dllSource" -ForegroundColor Green
    } else {
        Write-Host "[提示] 未找到 wtsapi32.dll 补丁文件" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "请从以下位置下载补丁文件：" -ForegroundColor Yellow
        Write-Host "  1. 酷安搜索「小米电脑管家 非小米」" -ForegroundColor Gray
        Write-Host "  2. B站搜索「小米电脑管家 非小米电脑」" -ForegroundColor Gray
        Write-Host "  3. GitHub 搜索「xiaomi pc manager wtsapi32」" -ForegroundColor Gray
        Write-Host ""
        Write-Host "下载后将 wtsapi32.dll 放到以下任一位置：" -ForegroundColor Yellow
        Write-Host "  - 与此脚本同目录" -ForegroundColor Gray
        Write-Host "  - 桌面" -ForegroundColor Gray
        Write-Host "  - 下载文件夹" -ForegroundColor Gray
        Write-Host ""
        
        # 尝试常见下载位置
        $searchPaths = @(
            "$env:USERPROFILE\Desktop\wtsapi32.dll",
            "$env:USERPROFILE\Downloads\wtsapi32.dll",
            "$env:USERPROFILE\Downloads\*\wtsapi32.dll"
        )
        
        foreach ($searchPath in $searchPaths) {
            $found = Get-Item -Path $searchPath -ErrorAction SilentlyContinue
            if ($found) {
                $dllSource = $found[0].FullName
                Write-Host "[信息] 自动找到补丁文件: $dllSource" -ForegroundColor Green
                break
            }
        }
        
        if (-not $dllSource) {
            $dllSource = Read-Host "请输入 wtsapi32.dll 的完整路径"
            if (-not (Test-Path $dllSource)) {
                Write-Host "[错误] 文件不存在: $dllSource" -ForegroundColor Red
                exit 1
            }
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  开始部署补丁" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 3. 部署补丁到安装目录（根目录）
Write-Host "[步骤 1] 复制补丁到安装根目录..." -ForegroundColor Yellow
$dest1 = Join-Path $foundPath "wtsapi32.dll"
try {
    Copy-Item -Path $dllSource -Destination $dest1 -Force
    Write-Host "  [完成] $dest1" -ForegroundColor Green
} catch {
    Write-Host "  [失败] $($_.Exception.Message)" -ForegroundColor Red
}

# 4. 部署补丁到版本目录
if ($versionDir) {
    Write-Host "[步骤 2] 复制补丁到版本目录..." -ForegroundColor Yellow
    $dest2 = Join-Path $versionDir "wtsapi32.dll"
    try {
        Copy-Item -Path $dllSource -Destination $dest2 -Force
        Write-Host "  [完成] $dest2" -ForegroundColor Green
    } catch {
        Write-Host "  [失败] $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  补丁部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Yellow
Write-Host "  1. 如果小米电脑管家正在运行，请先关闭它" -ForegroundColor Gray
Write-Host "  2. 重启电脑（推荐）" -ForegroundColor Gray
Write-Host "  3. 重新打开小米电脑管家" -ForegroundColor Gray
Write-Host ""
Write-Host "注意事项：" -ForegroundColor Yellow
Write-Host "  - 确保手机和电脑连接同一个 WiFi" -ForegroundColor Gray
Write-Host "  - 如果搜索不到设备，尝试关闭再打开 WiFi/蓝牙" -ForegroundColor Gray
Write-Host ""

$restart = Read-Host "是否现在重启电脑？(Y/N)"
if ($restart -eq 'Y' -or $restart -eq 'y') {
    Write-Host "正在重启..." -ForegroundColor Yellow
    Restart-Computer -Force
}
