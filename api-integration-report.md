# 启炼AI小程序 - API接入情况分析

> 基准：Apipost API文档 (2026-06-10)
> 项目：D:\projects\lejian-wx-miniapp
> 分析时间：2026-06-24

---

## 📊 总览

| 分类 | 总接口数 | ✅ 已接入 | ❌ 未接入 |
|------|---------|----------|----------|
| 教练端登录 | 5 | 5 | 0 |
| 教练端管理会员 | 16 | 1 | 15 |
| 公共接口 | 8 | 5 | 3 |
| **合计** | **29** | **11** | **18** |

---

## ✅ 已接入的 API（11个）

### 教练端登录（5/5 全部已接入）

| # | 接口名 | API路径 | 接入位置 |
|---|--------|---------|----------|
| 1 | 微信openid登录 | `/miniapp/user/wxlogin` | `app.js` → `globalData.login()` |
| 2 | 根据openid查询教练信息 | `/miniapp/user/get-info` | `service/user/index.js` → `getUserInfo()` |
| 3 | 验证手机号-微信授权 | `/miniapp/user/wxphone` | `service/user/index.js` → `wxPhone()` |
| 4 | 验证手机号-短信验校验 | `/miniapp/user/update-phone-bycode` | `service/user/index.js` → `verifyPhoneCode()` |
| 5 | 根据openid修改用户信息 | `/miniapp/user/update-info` | `service/user/index.js` → `updateUserInfo()` |

### 教练端管理会员（1/16 已接入）

| # | 接口名 | API路径 | 接入位置 |
|---|--------|---------|----------|
| 6 | 会员基本信息-查询 | `/miniapp/vipuser/select` | `service/user/index.js` → `selectVipUser()` |

### 公共接口（5/8 已接入）

| # | 接口名 | API路径 | 接入位置 |
|---|--------|---------|----------|
| 7 | 上传图片到oss | `/public/uploadFile/add` | `service/user/index.js` → `uploadCertFile()` |
| 8 | 发送验证码 | `/public/sms/send` | `service/user/index.js` → `sendSmsCode()` |
| 9 | 语音转文字 | `/public/asr/transcribe` | `service/chat/index.js` → `transcribeAudio()` |
| 10 | 创建会话组 | `/miniapp/conversationGroup/add` | `service/chat/index.js` → `addConversationGroup()` |
| 11 | 查询会话组列表 | `/miniapp/conversationGroup/select` | `service/chat/index.js` → `selectConversationGroup()` |
| 12 | ai问答接口 | `/miniapp/conversation/create` | `service/chat/index.js` → `streamConversation()` (SSE流式) |
| 13 | 查询单个会话聊天记录 | `/miniapp/conversation/select` | `service/chat/index.js` → `selectConversation()` |

---

## ❌ 未接入的 API（18个）

### 教练端管理会员 - 会员基本信息（3个未接入）

| # | 接口名 | API路径 | 建议接入位置 |
|---|--------|---------|-------------|
| 1 | 会员基本信息-新增 | `POST /miniapp/vipuser/add` | `service/user/index.js` → 新增 `addVipUser()` |
| 2 | 会员基本信息-修改 | `POST /miniapp/vipuser/update` | `service/user/index.js` → 新增 `updateVipUser()` |
| 3 | 会员基本信息-删除 | `POST /miniapp/vipuser/delete` | `service/user/index.js` → 新增 `deleteVipUser()` |

**使用场景：** 会员管理页面（新增会员、编辑会员信息、删除会员）

### 教练端管理会员 - 档案-体成分(体测)（4个未接入）

| # | 接口名 | API路径 | 建议接入位置 |
|---|--------|---------|-------------|
| 4 | 体成分-查询 | `POST /miniapp/body_composition/select` | 新建 `service/body/index.js` |
| 5 | 体成分-新增 | `POST /miniapp/body_composition/add` | 同上 |
| 6 | 体成分-修改 | `POST /miniapp/body_composition/update` | 同上 |
| 7 | 体成分-删除 | `POST /miniapp/body_composition/delete` | 同上 |

**当前状态：** `body-composition` 页面使用 `mock-api.js` 硬编码数据，有 TODO 注释待接入
**使用场景：** 体测数据详情页、新增/编辑体测记录

### 教练端管理会员 - 档案-体态评估（4个未接入）

| # | 接口名 | API路径 | 建议接入位置 |
|---|--------|---------|-------------|
| 8 | 体态评估-查询 | `POST /miniapp/posture_assess/select` | 新建 `service/posture/index.js` |
| 9 | 体态评估-新增 | `POST /miniapp/posture_assess/add` | 同上 |
| 10 | 体态评估-修改 | `POST /miniapp/posture_assess/update` | 同上 |
| 11 | 体态评估-删除 | `POST /miniapp/posture_assess/delete` | 同上 |

**当前状态：** `posture-assessment` 页面使用 `mock-api.js` 硬编码数据，有 TODO 注释待接入
**使用场景：** 体态评估详情页、上传评估照片、查看历史记录

### 教练端管理会员 - AI报告分析（4个未接入）

| # | 接口名 | API路径 | 建议接入位置 |
|---|--------|---------|-------------|
| 12 | ai报告-查询 | `POST /miniapp/report/select` | 新建 `service/report/index.js` |
| 13 | ai报告-新增 | `POST /miniapp/report/add` | 同上 |
| 14 | ai报告-修改 | `POST /miniapp/report/update` | 同上 |
| 15 | ai报告-删除 | `POST /miniapp/report/delete` | 同上 |

**使用场景：** AI分析报告展示、生成报告、管理报告

### 公共接口（3个未接入）

| # | 接口名 | API路径 | 建议接入位置 |
|---|--------|---------|-------------|
| 16 | 数据字典表查询 | `POST /public/sysDict/getByType` | `service/user/index.js` 或新建 `service/dict/index.js` |
| 17 | ~~ai问答接口~~ | ~~已接入~~ | — |
| 18 | ~~查询会话组列表~~ | ~~已接入~~ | — |

**数据字典用途：** 提供枚举值（gender性别、teaching_years执教年限、preferred_content训练偏好、equipment_preference器械偏好）

---

## 📁 建议的 Service 文件组织

```
service/
├── user/index.js          ← 已有，补充 vipuser 增删改
├── chat/index.js          ← 已有，完整
├── body/index.js          ← 新建：体成分 CRUD
├── posture/index.js       ← 新建：体态评估 CRUD
├── report/index.js        ← 新建：AI报告 CRUD
└── dict/index.js          ← 新建：数据字典查询
```

---

## 🔥 优先级建议

### P0 - 核心业务（直接影响页面功能）
1. **体态评估 CRUD** → posture-assessment 页面已有，只差 API 接入
2. **体成分 CRUD** → body-composition 页面已有，只差 API 接入
3. **会员增删改** → 会员管理的核心操作

### P1 - 增强功能
4. **AI报告 CRUD** → AI分析报告展示
5. **数据字典** → 统一枚举值管理

### P2 - 已有 mock 的页面
6. fitness-test（体能测试）→ 当前无对应 API，可能需要后端新增
7. health-questionnaire（健康问卷）→ 当前无对应 API
8. joint-screening（关节筛查）→ 当前无对应 API

---

## 📝 注意事项

- **API基础地址：** `https://lejian-api.bboycc.cn`（已配置在 `api/index.js`）
- **门店编码：** 暂时固定 `store_code: "123456"`
- **网络请求封装：** `utils/netWork/index.js` 中的 `service()` 函数
- **Mock文件：** `utils/mock-api.js`，接入真实 API 后可逐步删除
