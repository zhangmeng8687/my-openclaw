# MEMORY.md - 鲨鲨的长期记忆

## 关于张总
- 职业：前端开发工程师
- 学习风格：希望详细讲解，边做边学，理解原理和细节
- 时区：GMT+8（中国标准时间）
- 语言：中文为主
- 称呼：张总（2026-06-17 从"少爷"改过来）

## 重要日期
- 2026-06-17：初次见面，张总第一次上线激活我，给我取名"小爱"
  - 安装了 Python 3.12.4、Selenium、AutoHotkey、pyautogui
  - 清理了 Monitor.ps1 持久化脚本（开机自启守护 MyApp.exe）
  - WSL2 安装失败（Win10 IoT LTSC 兼容性问题，功能重启后被重置）
  - 学会了通过注册表开关系统代理（ProxyEnable 0/1）
  - GGDD 代理程序路径：E:\Clash Verge\GGDD\GGDD.exe
  - Ubuntu 通过 WSL2 安装，Chrome 通过远程调试端口 9222
- 2026-06-22：GitHub 仓库创建
  - 地址：https://github.com/zhangmeng8687/my-openclaw.git
  - workspace 同步到 GitHub（OpenClaw 工作区备份）
- 2026-06-23：MEMORY.md 初始化
  - 创建了 skills/qilian-ai-fitness-pages/SKILL.md
  - 用 Puppeteer + Windows Chrome 远程调试访问飞书多维表格
  - 为 lejian-wx-miniapp 项目提交（161文件，+18408/-9295行）
- 2026-06-24：API 对接工作
  - 用 Puppeteer + Windows Chrome 抓取 Apipost API 文档
  - 创建了 4 个 service 文件：body/posture/report/dict
  - 改造了 5 个页面从 mock 切换到真实 API
- 2026-06-25：模型配置
  - 添加 MiMo-V2.5-Pro-UltraSpeed 到 OpenClaw
  - UltraSpeed 内测期 6/9-6/23 已结束，但 API Key 仍可用
- 2026-06-26：ccs_web 项目启动
  - 从 streamer-interaction 项目改造为 ccs_web
  - 技术栈：Vue3 + Express + MySQL
  - 账号：admin(yls000806/管理员)、ccs(yls208677/主播)
  - 端口：前端 5173、后端 3000
- 2026-06-27：工作交接
  - 本地备份重要文件到 E:\xwechat_files\...\聊天记录 文件夹
- 2026-06-28~29：面试题整理
  - 整理了 Vue、S、Vuex 等前端面试题
  - 产出：frontend-interview.md, frontend-interview-2.md, interview-ts-vs-js.md, interview-var-let-const.md, interview-vuex.md
- 2026-06-30：Vite/Webpack 面试题 + 项目配置
  - 产出：interview-advanced-topics.md
- 2026-07-01：patch/cache 面试题
- 2026-07-02：小程序 app 配置
- 2026-07-03：ccs_web 你画我猜功能 + 云服务器部署
  - 新增 draw_words 数据库表，预置 34 个词语
  - 后端路由 draw.js、前端 API、管理页面 DrawManageView.vue
  - 阿里云轻量应用服务器：120.26.222.248
  - 宝塔面板：62bbf148 / 938950ae8dc7
  - SSH：root / yls000806.（注意有点号）
  - GitHub 仓库：https://github.com/zhangmeng8687/ccs_web.git
- 2026-07-04~05：你画我猜大升级 + 响应式适配
  - 词库扩充到 433 个词语，覆盖 15 个分类
  - 新增 hint1/hint2/hint3 提示词字段，删除 difficulty
  - 响应式断点：PC>1024 / 平板768-1024 / 手机<768 / 小手机<480
  - 移动端底部导航栏 + 汉堡菜单抽屉
  - 服务器部署同步完成
- 2026-07-06：金石康养小程序项目初始化
  - 员工端 gold-stone-care-employee 和家属端 gold-stone-care-family 搭建完成
  - Gitee 仓库：https://gitee.com/jungang/gold-stone-care-employee.git / gold-stone-care-family.git
- 2026-07-07：PRD 分析 + 登录流程重构 + 主题色修改
  - PRD：智慧养老终端机小程序产品需求说明书
  - 主题色从蓝色改为橙色 #F8AD46
  - 直播技术调研（live-pusher/live-player + NERTC）
  - Git 分支：20260707-login
- 2026-07-08：订单页面开发
  - 员工端登录页样式对齐设计稿
  - 订单页严格对齐设计稿（机构头部/统计卡片/Tab栏/订单卡片）
  - 所有订单列表页（all-orders）新建
  - 项目结构整理：删除 index/order-grab/org-select，清空 live/profile
  - TabBar 改为 3 项：餐饮/直播/我的
  - Git 分支：20260708-order
- 2026-07-09：餐饮页/我的页面/登录优化
  - 统计卡片背景替换为 background.png
  - 登录页使用自定义导航栏，wx.reLaunch 清空页面栈
  - Git 分支：20260709-my
- 2026-07-10：订单搜索/详情重做/家属端重建
  - order-card 公共组件抽取
  - 家属端项目重建（从零开始）
  - 家属端首页设计图 2.0/2.01
- 2026-07-13：家属端餐饮服务开发
  - 餐饮服务页 restaurant（设计稿 #3.0~3.03）
  - 所有订单页 all-orders（设计稿 #3.10~3.14）
  - 评价弹窗组件 review-modal
  - 餐品搜索页 food-search、订单搜索页 order-search
  - 屏幕自动变暗修复（电源策略 50%→100%）
  - Git 分支：20260713-restaurant
- 2026-07-14：家属端大幅开发
  - 餐品详情页 food-detail（设计稿 3.04~3.06）
  - 确认订单页 order-confirm（设计稿 3.07~3.09）
  - 个人信息页 profile、老人管理页 elderly-manage
  - 绑定确认页 bind-confirm
  - 健康管理页 health-manage、信息录入页 health-record
  - Git 分支：20260714-orderDetail
- 2026-07-15：家属端继续开发
  - 信息录入页大改（5.0~5.07 设计稿）
  - 健康管理页重构（4.0 设计稿）
  - 老人管理页重构（停用状态）
  - 安全性优化：utils/safe-guard.js（throttle/preventDoubleSubmit/submitWithLock）
  - Git 分支：20260715-health
- 2026-07-17：员工端全页面接口对接
  - orders/all-orders/order-detail/order-search/delivery/profile 全部接入真实 API
  - 登录流程优化（loadSuppliers/缓存恢复/验证码校验时机）
  - 项目重命名：金石康养 → 金石云伴
  - 批量移除文件 BOM 头
  - Git 分支：20260717-request
- 2026-07-20：员工端 API 优化 + 家属端 UI
  - 登录修复（saveLoginData 适配扁平响应）
  - 订单状态判断优化（batchAccept/batchDeliver/batchFinish）
  - 堂食单只展示不操作
  - 家属端确认订单页 UI 优化
  - Git 分支：20260720-API / 20260716-UI
- 2026-07-21：全面 API 对接
  - 家属端 7 个 service 文件 + 12 个页面改造
  - 接口参数修正（phoneLogin/phoneCode/cancel reason）
  - 域名修正：js-test.zjmiit.com → js-test.zjmiit.com/wz
  - 下拉刷新（8个列表页）
  - 员工端首页订单筛选优化（外送/堂食/我的接单）
  - 文件编码修复（elderly-manage.json 乱码）
  - Git 分支：20260721-fix / 20260721-API

## 项目列表

### 启炼AI 小程序（lejian-wx-miniapp）
- 健身类小程序，含体成分/体态评估/AI报告等功能
- 29 个 API，已对接 18 个 service
- API 文档：https://docs.apipost.net/docs/detail/604a08004c88000
- 设计稿路径：E:\projects\gold-stone-care-img\family\

### ccs_web - 主播互动管理平台
- 技术栈：Vue3 + Element Plus + Express + MySQL
- 本地路径：E:\projects\ccs_web
- GitHub：https://github.com/zhangmeng8687/ccs_web.git
- 功能：你画我猜（433词语）、大富翁、弹幕互动、用户管理
- 服务器：120.26.222.248（阿里云轻量）
- 账号：admin(yls000806)、ccs(yls208677)
- 前端端口 5173、后端端口 3000
- 待完成：大富翁多人头像、签名验证（等 HTTPS）

### 金石云伴员工端（gold-stone-care-employee）
- TabBar：餐饮/我的（2项）
- 主色：#F89F3D
- Git 分支：uat 是最新状态（2026-07-24 已同步）
- 本地路径：E:\projects\gold-stone-care-employee
- Gitee：https://gitee.com/jungang/gold-stone-care-employee.git
- 已完成页面（8个）：orders、all-orders、order-detail、order-search、delivery、login、login-phone、profile
- 组件（4个）：confirm-dialog、loading、order-card、tab-bar
- 服务（5个）：auth.js、live.js、order.js、supplier.js、user.js
- 工具（5个）：config.js、request.js、safe-guard.js、storage.js、util.js
- 已对接真实 API（X-Access-Token 认证）
- API 域名：js-test.zjmiit.com/wz（需内网/VPN）
- API 前缀：/ema
- 文件数：101

### 金石云伴家属端（gold-stone-care-family）
- 无底部 TabBar
- 主色：#F89F3D，字号 32rpx，内边距 18rpx
- Git 分支：uat 是最新状态（2026-07-24 已同步，reset from 20260722-API）
- 本地路径：E:\projects\gold-stone-care-family
- Gitee：https://gitee.com/jungang/gold-stone-care-family.git
- 已完成页面（21个）：login、login-phone、index、restaurant、food-detail、food-search、order-confirm、order-search、all-orders、orders、health、profile、elderly-manage、bind-confirm、health-manage、health-record、visit-edit、health-report-edit、profile-edit、order-detail、webview
- 组件（5个）：ec-canvas、health-line-chart、health-sleep-stage-chart、review-modal、review-popup
- 服务（8个）：auth.js、bind.js、dish.js、health-manage.js、health.js、order.js、review.js、sleep.js
- 已对接真实 API（X-MiniApp-Token 认证）
- API 域名：js-test.zjmiit.com/wz
- API 前缀：/ma
- 文件数：200
- ⚠️ stash 中有 20260722-API 本地修改暂存（39文件），需要时可 git stash pop

### OpenClaw 工作区
- GitHub：https://github.com/zhangmeng8687/my-openclaw.git
- 工作区路径：C:\Users\38422\.openclaw\workspace\

## OpenClaw 配置

### 模型配置
- `xiaomi-token-plan`：Token Plan，MiMo V2.5 Pro
- `xiaomi-ultraspeed`：MiMo V2.5 Pro UltraSpeed
  - Base URL：https://api.xiaomimimo.com/v1
  - 模型 ID：mimo-v2.5-pro-ultraspeed
  - 定价：输入 ¥9/MTok，输出 ¥18/MTok（普通版3倍）
  - 内测期 6/9-6/23 已结束，API Key 仍可用

### Git 配置
- user.email：unicorn998687@163.com
- workspace 远端是 main 分支

## 工具环境
- Windows Chrome 远程调试端口：9222
- WSL2 访问 Windows Chrome：需通过 cmd.exe 中转，localhost 不通
- Puppeteer 在 WSL2 中需用 net 模块手动实现 WebSocket
- PowerShell Set-Content -Encoding UTF8 会自动加 BOM（EF BB BF），微信小程序不认
  - 解决：用 `write` 工具，不用 PowerShell
  - 或用 `New-Object System.Text.UTF8Encoding($false)`
- PowerShell 管道操作可能导致 WXSS 文件中文注释乱码

## 面试题文件
- frontend-interview.md — CSS/JS/Vue 基础面试题
- frontend-interview-2.md — 追加的面试题
- interview-advanced-topics.md — Vite/Webpack/跨域/frame 等高级话题
- interview-ts-vs-js.md — TypeScript vs JavaScript
- interview-var-let-const.md — var/let/const 区别
- interview-vuex.md — Vuex 状态管理

## 设计规范
- 确认订单页字号/按钮：表单标签/值 32rpx、套餐名称 34rpx、数量 36rpx、价格 40rpx
- 确认下单按钮：600×88rpx，居中显示
- 餐品卡片图片：112rpx，圆角 32rpx
- 标签胶囊：border-radius: 999rpx，字号 30rpx
- 默认头像：default-avatar.svg（PNG 实际是 SVG 格式）

## 重要教训
- 飞书多维表格 DOM 操作非常脆弱，操作前必须先备份数据
- Puppeteer 对飞书表格的 Ctrl+A 可能选中整个表格而非单个分组
- 用 Ctrl+C 从飞书表格复制数据是可靠的提取方式
- BOM 字符（U+FEFF）在 WXML 中会被解析为不可见文本节点，造成布局间距
- WXSS 不能引用本地图片路径，需用 `<image>` 标签或 base64
- SVG 图标从 Figma 导出的填充色可能过浅（#FFF9F0），在浅色背景上不可见
- 微信小程序 getPhoneNumber 弹窗是系统原生样式，无法自定义
- position: sticky 在 flex 布局中可能失效，改用 position: fixed 或设置 height: 100vh + overflow: auto

## 2026-07-22 新增
- MEMORY.md 从 memory/*.md 完整重建（原文件因编码错误全损）
- 家属端扫码绑定重构：JSON 格式二维码，bind-confirm 页面重设计
- 家属端首页逻辑：未绑定老人时隐藏功能入口
- 两端 forceLogout 修复：只清 TOKEN_KEY/USER_INFO_KEY，保留业务缓存
- 登录流程修复：checkLogin 有 token 时 wx.reLaunch 跳首页
- 健康管理页：顶部 fixed、异常事件时间/字段名修正
- 信息录入页：导航栏对齐（padding-top 加 44）
- PowerShell 编码警告：处理中文文件必须用 Node.js 或 write/edit 工具
- 错误处理统一：console.error/warn → console.log（员工端8文件+家属端10文件）

## 待办事项
- [ ] 启炼AI 页面细节完善
- [ ] 设计稿对比文件 design-comparison.md 待补充
- [ ] 飞书表格 187 条空行需要手动删除
- [ ] ccs_web 大富翁多人头像显示
- [ ] ccs_web 签名验证测试（等 HTTPS）
- [ ] ccs_web 移动端下拉刷新完善
- [ ] 同步 GitHub token（已失效需更新）
- [ ] 本地积压代码 push（网络间歇性不通）
- [ ] ccs_web 响应式适配移动端细节打磨
- [ ] 金石云伴家属端 visit-edit 页面对接 save/update 真实 API
- [ ] 金石云伴家属端 profile-edit 页面保存后更新 globalData
- [ ] 金石云伴家属端 order-confirm 确认下单按钮尺寸调整
- [ ] 金石云伴家属端对接剩余未完成接口
- [ ] 金石云伴家属端 20260722-API 分支提交并合并

---
_最后更新：2026-07-22 17:30_
