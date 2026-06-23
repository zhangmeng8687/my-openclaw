# 设计稿对比检查报告

## 发现的不一致问题

### 1. 会员卡片结构不统一
| 页面 | 容器类名 | 头像类名 | 状态标签类名 | 元信息类名 |
|------|----------|----------|-------------|-----------|
| fitness-test | page > card member-card | avatar | status-tag | member-meta |
| body-composition | page > member-card | avatar-wrap > avatar | member-tag | member-meta + member-store |
| posture-assessment | page > card member-card | avatar-wrap > avatar | status-tag | member-meta |
| joint-screening | page-container > member-card | member-avatar | member-status | member-detail |
| health-questionnaire | page-container > member-card | member-avatar | member-status | member-detail |

### 2. 页面容器类名不统一
- fitness-test, body-composition, posture-assessment: `class="page"`
- joint-screening, health-questionnaire: `class="page-container"`

### 3. 状态标签样式不统一
- fitness-test, body-composition: 蓝色文字 + 蓝色背景
- posture-assessment: 活跃=绿色, 非活跃=橙色
- joint-screening: 活跃=绿色, 非活跃=橙色
- health-questionnaire: 无特殊样式

### 4. 名称字号不统一
- fitness-test, joint-screening: 34rpx
- body-composition, posture-assessment, health-questionnaire: 32rpx

## 需要统一的规范
- 容器类名: `page`
- 头像类名: `avatar-wrap > avatar` (支持占位符)
- 状态标签: `status-tag` + `status-active/status-inactive`
- 元信息: `member-meta`
- 名称字号: 32rpx
