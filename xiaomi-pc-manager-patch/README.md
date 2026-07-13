# 小米电脑管家 非小米设备补丁

## 🦈 说明

这个工具帮助在**非小米电脑**上安装和使用小米电脑管家，实现妙享桌面、投屏、互传等功能。

## 📋 前置条件

1. 下载小米电脑管家安装包（官方或第三方）
2. 下载 `wtsapi32.dll` 补丁文件
3. 以管理员权限运行 PowerShell 脚本

## 📥 下载资源

### 小米电脑管家安装包
- 官网：https://www.mi.com/xiaomipcmanager
- 或在小米电脑管家官网下载最新版

### wtsapi32.dll 补丁文件
这个补丁文件需要从第三方获取，以下是常见来源：

1. **百度网盘**：https://pan.baidu.com/s/1eMxxeh9EBLiefZl1xzBCNw?pwd=52pj
2. **酷安 App**：搜索「小米电脑管家 非小米」，找 @ChsBuffer 的帖子
3. **B站**：搜索「小米电脑管家 非小米电脑」，视频简介通常有下载链接
4. **GitHub**：搜索 `xiaomi pc manager wtsapi32`

> ⚠️ 请从可信来源下载，避免使用来路不明的文件。

## 🚀 使用方法

### 方法一：自动部署（推荐）

1. 将下载的 `wtsapi32.dll` 放到与此脚本同目录
2. 右键点击 `install-patch.ps1` → **使用 PowerShell 运行**
3. 按提示操作，脚本会自动：
   - 检测小米电脑管家安装路径
   - 复制补丁到安装目录
   - 复制补丁到版本目录
4. 重启电脑

### 方法二：手动部署

1. 运行小米电脑管家安装程序
2. 安装完成后**不要启动程序**
3. 将 `wtsapi32.dll` 复制到以下目录：
   ```
   C:\Program Files\MI\XiaomiPCManager\
   C:\Program Files\MI\XiaomiPCManager\[版本号]\
   ```
4. 重启电脑

## 📁 文件结构

```
xiaomi-pc-manager-patch/
├── README.md           # 本文件
├── install-patch.ps1   # 自动部署脚本
└── wtsapi32.dll        # 补丁文件（需要自己下载）
```

## ❓ 常见问题

### Q: 安装后提示「不支持的设备」
A: 确保 `wtsapi32.dll` 已放在安装目录和版本目录中，然后重启电脑。

### Q: 搜索不到手机/平板
A: 
- 确保手机和电脑连接同一个 WiFi
- 关闭再打开 WiFi 和蓝牙
- 检查防火墙是否阻止了小米电脑管家

### Q: AI 文件搜索功能不可用
A: 需要将 `wtsapi32.dll` 同时放在版本目录中（如 `C:\Program Files\MI\XiaomiPCManager\5.3.0.334\`）

### Q: 脚本无法运行
A: 
- 右键 PowerShell → 以管理员身份运行
- 执行 `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- 然后再运行脚本

## ⚠️ 免责声明

- 此补丁来源于社区（酷安 @ChsBuffer）
- 仅供学习研究使用，请支持正版软件
- 使用风险自担

---

*Made with 🦈 by 鲨鲨*
