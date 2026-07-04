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
  - ⚠️ 每次重启前需检查 GGDD 系统代理是否关闭，否则会导致网络问题
  - 安装了 Ubuntu（通过 WSL2），Chrome 远程调试端口 9222
- 2026-06-22：GitHub 同步配置
  - 仓库：https://github.com/zhangmeng8687/my-openclaw.git
  - 张总在家和公司各部署一套 OpenClaw，通过 GitHub 同步 workspace
- 2026-06-23：鲨鲨上线，MEMORY.md 初始化
  - 分析了启炼AI小程序设计稿
  - 用 Puppeteer 操作飞书多维表格
  - 提交了 lejian-wx-miniapp 项目（161文件）
  - 劳动仲裁：意外睡过导致下午才上班，公司认定为旷工
- 2026-06-24：API 接入工作
  - 用 Puppeteer + Windows Chrome 抓取了 Apipost API 文档
  - 创建了 4 个 service 文件（body/posture/report/dict）
  - 改造了 5 个页面从 mock 切换到真实 API
- 2026-06-25：模型配置
  - 添加了 MiMo-V2.5-Pro-UltraSpeed 到 OpenClaw（provider: xiaomi-ultraspeed）
  - UltraSpeed 内测期 6/9-6/23 已过，但张总有 API Key 可继续使用
- 2026-06-26：ccs_web 项目初始化
  - 从 streamer-interaction 项目迁移到 ccs_web（原 E:\DownLoad\streamer-interaction.zip）
  - 主播粉丝互动平台，技术栈 Vue3 + Express + MySQL
  - 初始化项目：建库建表、安装依赖、运行项目
  - 数据库密码：yls000806
  - 前端端口 5173，后端端口 3000
- 2026-06-27：简历优化
  - 整理了张猛简历，优化启炼健康科技公司工作内容描述
  - 职位：前端负责人，主要负责小程序端全部把控，AI 项目
  - 简历文件：E:\xwechat_files\...\张猛简历.pdf
- 2026-06-28~29：面试题整理
  - 尝试自动化微信小游戏「动物历险记」幸运转盘（未成功，定位问题）
  - 整理了前端面试题，覆盖 Vue、小程序、TS、Vuex 原理、var/let/const
  - 新增前后端交互、安全、设计模式、错误监控等方向
  - 文件：frontend-interview.md, frontend-interview-2.md
  - interview-ts-vs-js.md, interview-var-let-const.md, interview-vuex.md
- 2026-06-30：劳动仲裁 + 面试题补充
  - 整理了劳动仲裁证据链和陈述
  - 关键日期：6/23 旷工争议（实际是睡过，下午已到岗）
  - 经理：方天天；员工手册规定旷工3次及以上可辞退
  - 但实际有争议的旷工仅 6/23 一天，其他为请假或未打卡
  - 补充了 Vite/Webpack 对比、主题色切换、缓存策略、搜索优化、iframe 通信
  - interview-advanced-topics.md
- 2026-07-01：面试题补充（catch/cache 区别）
- 2026-07-02：调研小程序唤起高德 app 方案
- 2026-07-03：ccs_web 大幅开发 + 安全加固 + 云服务器部署
  - **用户系统**：B站 UID 注册绑定，调用 api.bilibili.com/x/web-interface/card 查询用户信息
  - **大富翁游戏**：棋盘格子逻辑重做（蛇形排列，每行15格）、骰子1-6随机、用户头像标记位置
  - **管理员权限**：管理员/主播不限制游戏次数
  - **UI 修复**：按钮默认颜色与背景色冲突、暂无数据中文提示、弹窗间距
  - **修改密码**：右上角头像下拉菜单，修改后需重新登录
  - **头像上传**：注册时不强制，个人信息页更换
  - **次数用尽弹窗**：主题色可爱弹窗「给鲨鲨刷点就有次数咯」
  - **安全加固**：Token 无感刷新（access 2h + refresh 7d）、请求签名验证（防篡改+防重放）
  - **你画我猜词语生成**：433个词语，15个分类，每个词语3个提示词
  - **初始账号**：admin(yls000806/管理员)、ccs(yls208677/主播)
  - **GitHub 仓库**：https://github.com/zhangmeng8687/ccs_web.git
  - **云服务器部署**：阿里云轻量 120.26.222.248，宝塔面板
  - SSH：root / yls000806.（注意有点号）
  - 宝塔面板账号：62bbf148 / 密码：938950ae8dc7
  - 后端：utils/token.js, middleware/signature.js
  - 前端：utils/request.js, utils/signature.js, stores/user.js

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

- **ccs_web 主播粉丝互动平台**：
  - 本地路径：E:\projects\ccs_web
  - GitHub：https://github.com/zhangmeng8687/ccs_web.git
  - 技术栈：Vue3 + Element Plus + Express + MySQL
  - 功能：用户注册登录（B站UID绑定）、大富翁游戏、幸运转盘、话题讨论、你画我猜词语生成、管理后台
  - 安全机制：JWT双token（2h+7d）、请求签名验证（等HTTPS再开）
  - 数据库：ccs_web
  - 端口：5000（云服务器）/ 3000（本地）
  - 初始账号：admin(yls000806/管理员)、ccs(yls208677/主播)
  - 云服务器：阿里云轻量 120.26.222.248（宝塔面板）

- **前端面试题**：
  - 文件位置：C:\Users\Administrator\.openclaw\workspace\
  - frontend-interview.md：JS基础、Vue原理、小程序机制、工程化、性能优化
  - frontend-interview-2.md：前后端交互、安全、设计模式、错误监控
  - interview-advanced-topics.md：主题色切换、缓存策略、搜索优化、iframe通信
  - interview-ts-vs-js.md、interview-var-let-const.md、interview-vuex.md

## 劳动仲裁相关
- 张总在处理劳动仲裁事务
- 资料路径：E:\xwechat_files\wxid_cwkcb1bi7xrr22_aa90\msg\file\2026-06\劳动仲裁资料
- 2026-06-23：意外睡过导致下午才上班，公司认为此为旷工
- 经理：方天天；员工手册规定旷工3次及以上可辞退
- 争议点：实际有争议的旷工仅 6/23 一天，其他为请假或未打卡
- 公司手中保管员工手册，员工手中没有
- 已整理完整证据链和陈述，已补充微信截图等证据

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
- [ ] ccs_web 大富翁：多人头像显示（最多4个/位置，超出显示气泡）、主播/管理员全局视角
- [ ] ccs_web 每次回主页调用 API 更新 B站用户名
- [ ] 云服务器部署完成后测试所有功能
- [ ] 删除暴露的 GitHub token
- [ ] 本地积压代码 push（网络恢复后）

---
_最后更新：2026-07-04 01:24_
