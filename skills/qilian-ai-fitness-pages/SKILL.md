---
name: qilian-ai-fitness-pages
description: "Generate WeChat mini-program pages for 启炼AI fitness app: training detail (3 states) and body composition test detail."
---

# 启炼AI 健身小程序页面生成

为微信小程序「启炼AI」生成以下页面的完整代码（wxml / wxss / js / json）：
- **训练内容详情页**（course-detail）— 支持3种状态切换
- **体测数据详情页**（body-test-detail）

## 设计规范

| 项目 | 值 |
|---|---|
| 主色调 | #4C8FF9（品牌蓝）|
| 成功色 | #52C41A |
| 警告色 | #FAAD14 |
| 危险色 | #FF4D4F |
| 页面背景 | #F5F7FA |
| 卡片背景 | #FFFFFF |
| 标题文字 | #333333 |
| 正文文字 | #666666 |
| 辅助文字 | #999999 |
| 卡片圆角 | 16rpx |
| 按钮圆角 | 48rpx |
| 卡片阴影 | 0 2rpx 12rpx rgba(0,0,0,0.05) |
| 导航栏 | 白色背景，黑色标题，左侧返回箭头 |

## 代码模式约定

遵循项目已有页面（如 posture-assessment）的代码风格：

- 页面容器：`class="page"`，`min-height: 100vh; background: #F5F7FA; padding: 24rpx;`
- 会员卡片：`member-card` flex 布局，含头像、姓名、状态标签、性别|年龄|门店
- 状态标签：`status-tag`，活跃用蓝色 `#4C8FF9`，已完课用米黄 `#FFF7E6`+`#FAAD14`，待完课用蓝色 `#E6F7FF`+`#4C8FF9`
- 卡片区块：`section-card`，带 `section-header`（彩色竖条 + 标题）
- 底部按钮：蓝色填充胶囊按钮，`position: fixed; bottom: 0`，需预留安全区 `padding-bottom: env(safe-area-inset-bottom)`
- 数据驱动：所有内容通过 `data` 绑定，列表用 `wx:for`

---

## 页面一：训练内容详情页（course-detail）

### 文件结构
```
pages/course-detail/
  course-detail.wxml
  course-detail.wxss
  course-detail.js
  course-detail.json
```

### 页面概述

一个页面通过 `currentStep`（1/2/3）和 `status`（'pending'/'completed'）控制三种视图状态：

| 状态 | currentStep | status | 底部按钮 |
|---|---|---|---|
| 待完课（计划） | 1 | pending | 上传实际训练内容 |
| 已完课（执行） | 2 | completed | 生成训练总结 |
| 已完课（总结） | 3 | completed | 生成下次训练内容 |

### 顶部信息卡片

```html
<view class="member-card">
  <image class="member-avatar" src="{{member.avatar}}" mode="aspectFill" />
  <view class="member-info">
    <view class="member-name-row">
      <text class="member-name">{{member.name}}</text>
      <text class="status-tag {{status === 'completed' ? 'status-completed' : 'status-pending'}}">
        {{status === 'completed' ? '已完课' : '待完课'}}
      </text>
    </view>
    <view class="member-meta">
      <text>{{member.gender}} | {{member.age}}岁</text>
    </view>
    <view class="member-location">
      <text>{{schedule.date}} {{schedule.time}}</text>
      <text class="location-divider">·</text>
      <text>{{schedule.location}}</text>
    </view>
  </view>
</view>
```

状态标签样式：
- 待完课：`background: #E6F7FF; color: #4C8FF9;`
- 已完课：`background: #FFF7E6; color: #FAAD14;`

### 步骤进度条

三步导航：训练计划 → 实际执行 → 训练总结

```html
<view class="step-bar">
  <view class="step-item {{currentStep >= 1 ? 'step-active' : ''}}">
    <view class="step-dot"></view>
    <text class="step-label">训练计划</text>
  </view>
  <view class="step-line {{currentStep >= 2 ? 'line-active' : ''}}"></view>
  <view class="step-item {{currentStep >= 2 ? 'step-active' : ''}}">
    <view class="step-dot"></view>
    <text class="step-label">实际执行</text>
  </view>
  <view class="step-line {{currentStep >= 3 ? 'line-active' : ''}}"></view>
  <view class="step-item {{currentStep >= 3 ? 'step-active' : ''}}">
    <view class="step-dot"></view>
    <text class="step-label">训练总结</text>
  </view>
</view>
```

样式要点：
- 圆点：未激活 `#E0E0E0`，激活 `#4C8FF9`，尺寸 24rpx
- 连线：未激活 `#E0E0E0`，激活 `#4C8FF9`，高度 4rpx
- 标签字号 24rpx，激活加粗

### 步骤一：训练计划（currentStep === 1）

展示内容：
1. **训练计划已存入多维表** — 信息卡片，含表格名、计划ID、会员ID、目标
2. **日历提醒已创建** — 提示共 N 个重复日程
3. **每周训练安排** — 列表展示周一至周六的训练类型和时间段

```html
<view wx:if="{{currentStep === 1}}" class="step-content">
  <!-- 训练计划信息 -->
  <view class="info-card">
    <view class="info-icon">📋</view>
    <view class="info-body">
      <text class="info-title">训练计划已存入多维表</text>
      <view class="info-rows">
        <text class="info-row">表格名：{{plan.sheetName}}</text>
        <text class="info-row">计划ID：{{plan.planId}}</text>
        <text class="info-row">会员ID：{{plan.memberId}}</text>
        <text class="info-row">目标：{{plan.goal}}</text>
      </view>
    </view>
  </view>

  <!-- 日历提醒 -->
  <view class="info-card">
    <view class="info-icon">📅</view>
    <view class="info-body">
      <text class="info-title">日历提醒已创建</text>
      <text class="info-desc">共 {{plan.reminderCount}} 个重复日程</text>
    </view>
  </view>

  <!-- 每周训练安排 -->
  <view class="section-card">
    <view class="section-header">
      <view class="section-icon" style="background: #4C8FF9;"></view>
      <text class="section-title">每周训练安排</text>
    </view>
    <view class="schedule-list">
      <view class="schedule-item" wx:for="{{weeklySchedule}}" wx:key="day">
        <text class="schedule-day">{{item.day}}</text>
        <view class="schedule-tags">
          <text class="schedule-tag tag-{{item.type === '力量' ? 'strength' : 'cardio'}}">{{item.type}}</text>
        </view>
        <text class="schedule-time">{{item.time}}</text>
      </view>
    </view>
  </view>
</view>
```

每周训练安排数据结构：
```js
weeklySchedule: [
  { day: '周一', type: '力量', time: '19:00-20:00', focus: '上肢推' },
  { day: '周二', type: '有氧', time: '08:00-08:45', focus: '跑步机' },
  { day: '周三', type: '力量', time: '19:00-20:00', focus: '下肢' },
  { day: '周四', type: '休息', time: '', focus: '' },
  { day: '周五', type: '力量', time: '19:00-20:00', focus: '上肢拉' },
  { day: '周六', type: '有氧', time: '10:00-10:45', focus: '椭圆机' }
]
```

标签样式：
- 力量：`background: #E6F7FF; color: #4C8FF9;`
- 有氧：`background: #F6FFED; color: #52C41A;`
- 休息：`background: #F5F5F5; color: #999999;`

### 步骤二：实际执行（currentStep === 2）

复用步骤一的训练计划展示，额外显示执行概览统计：

```html
<view wx:if="{{currentStep === 2}}" class="step-content">
  <!-- 执行概览 -->
  <view class="exec-overview">
    <view class="exec-stat">
      <text class="exec-num">{{execStats.completed}}</text>
      <text class="exec-label">完成动作</text>
    </view>
    <view class="exec-stat">
      <text class="exec-num">{{execStats.substituted}}</text>
      <text class="exec-label">替补执行</text>
    </view>
    <view class="exec-stat">
      <text class="exec-num">{{execStats.skipped}}</text>
      <text class="exec-label">跳过动作</text>
    </view>
    <view class="exec-stat">
      <text class="exec-num">{{execStats.added}}</text>
      <text class="exec-label">额外增加</text>
    </view>
  </view>
  <!-- 同时展示训练计划内容（复用步骤一的 info-card 和 schedule-list） -->
</view>
```

执行概览样式：四个统计项水平排列，数字大号加粗 `48rpx`，标签 `24rpx` 灰色。

### 步骤三：训练总结（currentStep === 3）

展示 AI 生成的训练总结，分三个模块：

```html
<view wx:if="{{currentStep === 3}}" class="step-content">
  <!-- 执行概览（同步骤二） -->
  <view class="exec-overview">...</view>

  <!-- 训练总结 -->
  <view class="section-card">
    <view class="section-header">
      <view class="section-icon" style="background: #52C41A;"></view>
      <text class="section-title">训练总结</text>
    </view>

    <view class="summary-block">
      <text class="summary-label">📊 完成度</text>
      <text class="summary-text">{{summary.completion}}</text>
    </view>

    <view class="summary-block">
      <text class="summary-label">💪 强度分析</text>
      <text class="summary-text">{{summary.intensity}}</text>
    </view>

    <view class="summary-block">
      <text class="summary-label">📝 下节建议</text>
      <text class="summary-text">{{summary.nextSuggestion}}</text>
    </view>
  </view>
</view>
```

训练总结数据：
```js
summary: {
  completion: '动作完成度100%，深蹲容量下调但整体负荷高于上周。',
  intensity: '深蹲RPE触及9.5，导致末组重量调整，强度判定为"高"。',
  nextSuggestion: '侧重上肢推类训练，深蹲保持负重但提升休息时间。'
}
```

总结模块样式：
- 每个 summary-block 有左侧彩色标签 + 正文
- 标签与正文之间有 12rpx 间距
- 正文 28rpx，行高 1.6，颜色 #666666

### 底部操作按钮

```html
<view class="bottom-action">
  <button class="action-btn" bindtap="onAction">
    {{currentStep === 1 ? '上传实际训练内容' : currentStep === 2 ? '生成训练总结' : '生成下次训练内容'}}
  </button>
</view>
```

按钮样式：
```css
.bottom-action {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 24rpx 32rpx;
  padding-bottom: calc(24rpx + env(safe-area-inset-bottom));
  background: #FFFFFF;
  box-shadow: 0 -2rpx 12rpx rgba(0,0,0,0.05);
}
.action-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  background: #4C8FF9;
  color: #FFFFFF;
  font-size: 32rpx;
  font-weight: 600;
  border-radius: 48rpx;
  border: none;
}
```

### JS 数据结构

```js
Page({
  data: {
    currentStep: 3,  // 1 | 2 | 3
    status: 'completed',  // 'pending' | 'completed'
    member: {
      name: '张三',
      avatar: '/assets/images/avatar-default.png',
      gender: '男',
      age: 28
    },
    schedule: {
      date: '2026/05/13',
      time: '19:00-20:00',
      location: '杭州滨江海创店：私教室'
    },
    plan: {
      sheetName: '训练计划表',
      planId: 'P20260513001',
      memberId: 'M001',
      goal: '12周减脂10斤',
      reminderCount: 12
    },
    weeklySchedule: [ /* 见上文 */ ],
    execStats: {
      completed: '4/4',
      substituted: 1,
      skipped: 0,
      added: 1
    },
    summary: {
      completion: '...',
      intensity: '...',
      nextSuggestion: '...'
    }
  },
  onAction() {
    const { currentStep } = this.data
    if (currentStep === 1) {
      // 上传实际训练内容
    } else if (currentStep === 2) {
      // 生成训练总结
    } else {
      // 生成下次训练内容
    }
  }
})
```

---

## 页面二：体测数据详情页（body-test-detail）

### 文件结构
```
pages/body-test-detail/
  body-test-detail.wxml
  body-test-detail.wxss
  body-test-detail.js
  body-test-detail.json
```

### 页面概述

展示会员的 InBody 体测数据，包含五个区域：
1. 顶部用户信息
2. Inbody 评分环形图 + 等级解读
3. 核心指标九宫格
4. 节段分析人体图
5. 体型区间矩阵图

### 顶部用户信息

```html
<view class="member-card">
  <image class="member-avatar" src="{{member.avatar}}" mode="aspectFill" />
  <view class="member-info">
    <view class="member-name-row">
      <text class="member-name">{{member.name}}</text>
      <text class="status-tag status-active">{{member.status}}</text>
    </view>
    <text class="eval-date">评估日期：{{evalDate}}</text>
  </view>
</view>
```

### Inbody 评分 + 等级解读

```html
<view class="score-card">
  <view class="score-ring-wrapper">
    <canvas canvas-id="inbodyRing" class="score-ring" />
    <view class="score-inner">
      <text class="score-number">{{inbodyScore}}</text>
      <text class="score-label">Inbody评分</text>
    </view>
  </view>
  <text class="score-level">等级：{{scoreLevel}}</text>
  <text class="score-desc">{{scoreDesc}}</text>
</view>
```

环形图绘制逻辑参考 posture-assessment 的 `drawScoreRing`，根据分数区间着色：
- < 60: #FF4D4F（较差）
- 60-79: #FAAD14（一般）
- 80-89: #4C8FF9（良好）
- >= 90: #52C41A（优秀）

### 核心指标九宫格

```html
<view class="section-card">
  <view class="section-header">
    <view class="section-icon" style="background: #4C8FF9;"></view>
    <text class="section-title">核心指标</text>
  </view>
  <view class="metrics-grid">
    <view class="metric-item" wx:for="{{metrics}}" wx:key="key">
      <text class="metric-label">{{item.label}}</text>
      <text class="metric-value">{{item.value}} <text class="metric-unit">{{item.unit}}</text></text>
      <view class="metric-status status-{{item.statusType}}">{{item.status}}</view>
      <text class="metric-change" wx:if="{{item.change}}">{{item.change > 0 ? '+' : ''}}{{item.change}}</text>
    </view>
  </view>
</view>
```

指标数据结构：
```js
metrics: [
  { key: 'weight', label: '体重', value: '61.4', unit: 'Kg', status: '标准', statusType: 'normal', change: '-0.8' },
  { key: 'height', label: '身高', value: '1.75', unit: 'm', status: '', statusType: '', change: '' },
  { key: 'bmi', label: 'BMI', value: '19.8', unit: '', status: '标准', statusType: 'normal', change: '-0.3' },
  { key: 'fatRate', label: '体脂率', value: '23.8', unit: '%', status: '偏高', statusType: 'high', change: '-1.2' },
  { key: 'muscle', label: '骨骼肌', value: '28.2', unit: 'Kg', status: '偏低', statusType: 'low', change: '+0.5' },
  { key: 'visceralFat', label: '内脏脂肪', value: '4', unit: '级', status: '标准', statusType: 'normal', change: '-1' },
  { key: 'metabolism', label: '基础代谢', value: '1499', unit: 'kcal', status: '偏低', statusType: 'low', change: '+20' },
  { key: 'water', label: '身体水分', value: '58.2', unit: '%', status: '偏高', statusType: 'high', change: '+0.8' },
  { key: 'whr', label: '腰臀比', value: '0.86', unit: '', status: '标准', statusType: 'normal', change: '-0.01' }
]
```

九宫格样式：
```css
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24rpx;
}
.metric-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24rpx 0;
  background: #F8FAFE;
  border-radius: 12rpx;
}
.metric-label { font-size: 24rpx; color: #999; margin-bottom: 8rpx; }
.metric-value { font-size: 36rpx; font-weight: 700; color: #333; }
.metric-unit { font-size: 22rpx; font-weight: 400; color: #999; }
.metric-status { font-size: 22rpx; padding: 2rpx 12rpx; border-radius: 16rpx; margin-top: 8rpx; }
.status-normal { background: #F6FFED; color: #52C41A; }
.status-high { background: #FFF1F0; color: #FF4D4F; }
.status-low { background: #FFF7E6; color: #FAAD14; }
.metric-change { font-size: 22rpx; color: #999; margin-top: 4rpx; }
```

### 节段分析

人体解剖图，标注五个节段（左上肢、右上肢、躯干、左下肢、右下肢）的肌肉和脂肪数据。

```html
<view class="section-card">
  <view class="section-header">
    <view class="section-icon" style="background: #722ED1;"></view>
    <text class="section-title">节段分析</text>
  </view>
  <view class="body-segments">
    <view class="segment-item" wx:for="{{segments}}" wx:key="part">
      <text class="segment-name">{{item.part}}</text>
      <view class="segment-data">
        <text class="segment-muscle">肌肉 {{item.muscle}}Kg</text>
        <text class="segment-fat">脂肪 {{item.fat}}Kg</text>
      </view>
      <text class="segment-status status-{{item.statusType}}">{{item.status}}</text>
    </view>
  </view>
</view>
```

节段数据：
```js
segments: [
  { part: '左上肢', muscle: '2.8', fat: '0.9', status: '偏低', statusType: 'low' },
  { part: '右上肢', muscle: '2.9', fat: '0.8', status: '标准', statusType: 'normal' },
  { part: '躯干', muscle: '12.5', fat: '3.2', status: '标准', statusType: 'normal' },
  { part: '左下肢', muscle: '7.8', fat: '2.1', status: '标准', statusType: 'normal' },
  { part: '右下肢', muscle: '7.9', fat: '2.0', status: '标准', statusType: 'normal' }
]
```

### 体型区间

二维矩阵图（体脂率 x BMI），标记用户当前位置和体型分类。

```html
<view class="section-card">
  <view class="section-header">
    <view class="section-icon" style="background: #FAAD14;"></view>
    <text class="section-title">体型区间</text>
  </view>
  <view class="body-type-matrix">
    <canvas canvas-id="bodyTypeChart" class="body-type-canvas" />
    <view class="body-type-label">当前体型：{{bodyType}}</view>
  </view>
</view>
```

体型分类：消瘦型、偏瘦型、健康型、偏胖型、肥胖型、强壮型等。用 Canvas 绘制坐标轴和用户标记点。

### JS 数据结构

```js
Page({
  data: {
    member: { name: '张三', avatar: '/assets/images/avatar-default.png', status: '在服会员' },
    evalDate: '2026.05.21',
    inbodyScore: 85,
    scoreLevel: '较好',
    scoreDesc: '基础代谢稳定，体脂率下降，水分略高',
    metrics: [ /* 9项指标，见上文 */ ],
    segments: [ /* 5个节段，见上文 */ ],
    bodyType: '健康型'
  },
  onLoad() {
    this.drawInbodyRing()
    this.drawBodyTypeChart()
  },
  drawInbodyRing() {
    // 参考 posture-assessment 的 drawScoreRing
    // 圆环尺寸 280rpx，线宽 10px，根据 inbodyScore 着色
  },
  drawBodyTypeChart() {
    // 绘制 BMI x 体脂率 坐标系
    // X轴：体脂率范围（10%-40%）
    // Y轴：BMI范围（15-35）
    // 用不同颜色区域标注体型分类
    // 在交叉点绘制用户标记
  }
})
```

---

## 注意事项

1. **Canvas 适配**：需处理 `pixelRatio`，canvas 尺寸用 px 计算（rpx / 2）
2. **安全区**：底部固定按钮必须预留 `env(safe-area-inset-bottom)`
3. **骨架屏**：数据加载前展示骨架占位
4. **空状态**：无数据时展示空状态插画和引导文案
5. **分享**：页面需支持 `onShareAppMessage` 和 `onShareTimeline`
6. **下拉刷新**：体测详情页支持下拉刷新最新数据
