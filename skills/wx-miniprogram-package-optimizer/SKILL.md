---
name: wx-miniprogram-package-optimizer
description: "Optimize WeChat mini-program main package size by cleaning unused files, compressing images, and trimming dependencies."
---

# 微信小程序主包体积优化

系统化优化小程序主包大小，目标：**主包 < 2MB**（微信限制）。

## 第一步：分析主包结构

```bash
cd /path/to/miniprogram

# 整体大小
du -sh .

# 各目录大小
du -sh */ | sort -rh

# 主包各目录（排除 node_modules）
du -sh pages components utils icon static api service miniprogram_npm 2>/dev/null
```

主包包含：`pages/`、`components/`、`utils/`、`icon/`、`static/`、`api/`、`service/`、`miniprogram_npm/`、`app.js`、`app.json`、`app.wxss`

分包目录（`subpackages/`）不计入主包。

## 第二步：清理垃圾文件

常见垃圾文件：
- `.bak` 备份文件
- `.optimized.js` 中间产物
- 未引用的 JSON/JS 源文件

```bash
# 查找垃圾文件
find . -name "*.bak" -not -path "*/node_modules/*"
find . -name "*.optimized.*" -not -path "*/node_modules/*"
find . -name "*.orig" -not -path "*/node_modules/*"

# 删除前确认
rm -i file.bak
```

## 第三步：裁剪未使用的 Vant 组件

### 3.1 统计已安装 vs 实际使用

```bash
# 已安装组件数
ls miniprogram_npm/@vant/weapp/ | wc -l

# 实际在 WXML 中使用的组件
grep -r '<van-' --include='*.wxml' -h | grep -oP '<van-[a-z-]+' | sort -u

# 已注册的组件（JSON 文件中）
grep -r "@vant/weapp" --include="*.json" -h | grep -oP "@vant/weapp/[^\"']+" | sort -u
```

### 3.2 删除未使用组件

```bash
# 列出所有已安装组件
ls miniprogram_npm/@vant/weapp/ > /tmp/installed.txt

# 列出实际使用的组件（手动整理）
# van-icon, van-button, van-popup, van-loading, van-info, van-cell,
# van-transition, van-picker, van-overlay, van-goods-action-button,
# van-toast, van-tag, van-tabs, van-tab, van-sticky, van-sidebar-item,
# van-sidebar, van-goods-action, van-field

# 删除未使用的（示例）
cd miniprogram_npm/@vant/weapp
rm -rf area calendar card cascader cell-group checkbox checkbox-group \
  circle col collapse collapse-item config-provider count-down \
  datetime-picker definitions divider dropdown-item dropdown-menu \
  empty goods-action-icon grid grid-item image index-anchor index-bar \
  nav-bar notice-bar notify panel picker-column progress radio radio-group \
  rate row search share-sheet skeleton slider stepper steps submit-bar \
  swipe-cell switch tabbar tabbar-item tree-select uploader wxs
```

⚠️ **删除前务必确认**：有些组件可能被其他组件内部依赖。删除后测试所有页面。

### 3.3 验证

```bash
# 删除后大小
du -sh miniprogram_npm/@vant/weapp/
```

## 第四步：压缩图片

### 4.1 查找大图

```bash
find . -name "*.png" -size +50KB -not -path "*/node_modules/*" | xargs ls -lh
find . -name "*.jpg" -size +100KB -not -path "*/node_modules/*" | xargs ls -lh
```

### 4.2 压缩方案

**方案 A：使用 sharp（推荐）**
```bash
npm install sharp
node -e "
const sharp = require('sharp');
sharp('input.png')
  .resize({ width: 200, height: 200, fit: 'inside' })
  .png({ quality: 80 })
  .toFile('output.png');
"
```

**方案 B：使用 jimp（纯 JS，无原生依赖）**
```bash
cd /tmp && npm install jimp
```

```javascript
const { Jimp } = require('jimp');

async function compress(input, output, maxSize = 200) {
  const image = await Jimp.read(input);
  if (image.bitmap.width > maxSize || image.bitmap.height > maxSize) {
    image.resize({ w: maxSize, h: maxSize });
  }
  await image.write(output);
}
```

**方案 C：TinyPNG API**
```bash
curl -u api:YOUR_KEY --data-binary @input.png https://api.tinify.com/shrink
```

### 4.3 转 WebP（如平台支持）

WebP 比 PNG 小 25-35%，比 JPEG 小 25%：

```bash
# 检查 cwebp 是否可用
which cwebp || apt install webp

# 转换
cwebp -q 80 input.png -o output.webp
```

⚠️ 微信小程序支持 WebP，但需确认所有基础库版本。

## 第五步：检查 static 目录

```bash
du -sh static/* | sort -rh

# 检查 lottie 文件是否都被引用
grep -r "lottie" --include="*.js" --include="*.json" -l

# 未引用的 lottie 文件可删除
```

## 第六步：检查 utils 目录

```bash
du -sh utils/* | sort -rh

# 大文件检查
find utils -type f -size +50KB | xargs ls -lh

# 检查是否被引用
grep -r "filename" --include="*.js" --include="*.json" -l
```

常见可优化项：
- `crypter/` 加密库（216KB）— 如果只用到部分算法，可裁剪
- `mock-api.js` — 生产环境可删除
- `canvas-helper.js` — 检查是否所有页面都用到

## 第七步：检查分包配置

确认 `app.json` 中分包配置正确，大页面应放在分包：

```json
{
  "pages": ["pages/chat/chat", "pages/home/home", "pages/login/login"],
  "subpackages": [
    {
      "root": "subpackages/pkg1",
      "pages": [...]
    }
  ]
}
```

可移到分包的内容：
- 不常用的功能页面
- 大型组件
- 独立的 lottie 动画文件

## 第八步：最终验证

```bash
# 主包大小
du -sh . --exclude=subpackages --exclude=node_modules

# 或用微信开发者工具的「详情 → 本地设置 → 上传时自动压缩」功能

# 上传前检查
# 1. 所有页面可正常打开
# 2. 动效正常显示
# 3. API 调用正常
# 4. 分包页面可正常跳转
```

## 优化清单模板

| 步骤 | 操作 | 预计节省 | 状态 |
|---|---|---|---|
| 1 | 删除垃圾文件 | 460KB | ⬜ |
| 2 | 裁剪 Vant 组件 | 500KB+ | ⬜ |
| 3 | 压缩 icon 图片 | 100KB+ | ⬜ |
| 4 | 清理 static | 50KB+ | ⬜ |
| 5 | 裁剪 utils | 50KB+ | ⬜ |

## 注意事项

- 每步操作后**测试验证**，确认无功能异常
- Vant 组件删除前检查**组件间依赖关系**
- 图片压缩后**对比视觉效果**
- 保留原始文件备份，验证无误后再删除
- 微信开发者工具的「代码依赖分析」可辅助排查
