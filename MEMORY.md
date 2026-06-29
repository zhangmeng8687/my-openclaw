# MEMORY.md - 鲨鲨的长期记忆

## 关于张总
- 职业：前端开发工程师
- 学习风格：详细讲解，边做边学，理解原理和细节
- 语言：中文为主
- 时区：GMT+8
- 杭州

## 历史
- 2026-06-17：第一个助手「小爱」上线，当时张总叫「少爷」
  - 安装了 Python 3.12.4、Selenium、AutoHotkey、pyautogui
  - 清理了可疑的 Monitor.ps1 持久化脚本
  - 尝试安装 WSL2 但 Win10 IoT LTSC 有兼容性问题（后来成功了）
  - 玩崩坏：星穹铁道，货币战争模式
  - 代理管理：GGDD 路径 E:\Clash Verge\GGDD\GGDD.exe
- 2026-06-23：鲨鲨上线，MEMORY.md 初始化
  - 分析了启炼AI小程序设计稿
  - 用 Puppeteer 操作飞书多维表格
  - 提交了 lejian-wx-miniapp 项目（161文件）
- 2026-06-24：API 接入工作
  - 用 Puppeteer + Windows Chrome 抓取了 Apipost API 文档
  - 创建了 4 个 service 文件（body/posture/report/dict）
  - 改造了 5 个页面从 mock 切换到真实 API
- 2026-06-25：模型配置
  - 添加了 MiMo-V2.5-Pro-UltraSpeed 到 OpenClaw（provider: xiaomi-ultraspeed）
  - UltraSpeed 内测期 6/9-6/23 已过，但张总有 API Key 可继续使用

## 项目
- **启炼AI 微信小程序**：健身教练/会员管理工具
  - 技术栈：微信小程序原生（WXML/WXSS/JS）
  - API 基础地址：https://lejian-api.bboycc.cn
  - 设计规范：主色 #4C8FF9，圆角 16rpx，卡片阴影
  - 已完成页面：posture-assessment（体态评估）
  - 已接入 API：body-composition、posture-assessment、fitness-test、joint-screening、health-questionnaire
  - 待完善：页面细节和设计规范统一
  - API 文档：https://docs.apipost.net/docs/detail/604a08004c88000
  - 29个 API，已接入 18个（含 service 层）

## 重要约定
- 鲨鲨 🦈 是我的名字，每次回复前加「🦈鲨鲨收到！」
- 张总在家和公司各部署了一套 OpenClaw，通过 GitHub 同步 workspace
- Windows Chrome 远程调试：`--remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug-profile`
- WSL2 访问 Windows Chrome 需要通过 cmd.exe 中转（localhost 不通）

## OpenClaw 配置
- **模型提供商**：
  - `xiaomi-token-plan` → Token Plan 版 MiMo V2.5 Pro（当前主力）
  - `xiaomi-ultraspeed` → MiMo V2.5 Pro UltraSpeed（API 按量付费）
    - Base URL: `https://api.xiaomimimo.com/v1`
    - 模型 ID: `mimo-v2.5-pro-ultraspeed`
    - 定价：输入 ¥9/MTok，输出 ¥18/MTok（缓存命中 ¥0.075/MTok）
    - 特点：1T 参数，峰值 1000 tokens/s，FP4 + DFlash 投机解码
    - API Key: sk-ck9…79s0（platform.xiaomimimo.com 申请）
    - ⚠️ 不支持 Token Plan，按量付费，3× 普通版价格换 10× 速度

## 待办
- [ ] 启炼AI 页面细节完善
- [ ] 设计规范统一（design-comparison.md 中记录了不一致问题）
- [ ] 飞书表格 187 条空行清理

---
_最后更新：2026-06-25_
