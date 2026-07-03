# 前端面试题补充 — 前后端交互 & 新方向

> 承接 frontend-interview.md，覆盖前后端交互、安全、设计模式、错误监控、部署运维等方向。

---

## 一、前后端交互（核心重点）

### 1.1 HTTP 请求方法
**Q：GET 和 POST 的区别？不只是"参数放哪"的区别。**

| | GET | POST |
|---|---|---|
| 语义 | 获取资源 | 提交/创建资源 |
| 参数位置 | URL query string | request body |
| 参数长度 | 浏览器限制（约 2KB-8KB） | 理论上无限制 |
| 缓存 | 会被缓存 | 默认不缓存 |
| 幂等性 | 幂等（多次请求结果相同） | 非幂等 |
| 安全性 | 参数暴露在 URL 中 | body 相对安全（但都是明文） |
| TCP 数据包 | 通常发 1 个包 | 可能发 2 个包（先发 header，再发 body） |

**面试追问：** "POST 发两个包"是什么情况？
→ 早期 HTTP/1.1 规范中，POST 请求如果 body 较大，服务器可能先返回 `100 Continue`，客户端再发送 body。但现代浏览器和服务器已经优化，大多数情况下 POST 也只发一个包。

---

### 1.2 RESTful API 设计
**Q：你们项目中的接口是怎么设计的？**

RESTful 风格：

```
GET    /api/users          → 获取用户列表
GET    /api/users/123      → 获取单个用户
POST   /api/users          → 创建用户
PUT    /api/users/123      → 更新用户（全量）
PATCH  /api/users/123      → 更新用户（部分）
DELETE /api/users/123      → 删除用户

嵌套资源：
GET    /api/users/123/orders  → 获取用户 123 的订单
```

状态码约定：
```
200 OK              → 成功
201 Created         → 创建成功
204 No Content      → 删除成功（无返回体）
400 Bad Request     → 参数错误
401 Unauthorized    → 未登录
403 Forbidden       → 无权限
404 Not Found       → 资源不存在
409 Conflict        → 冲突（如重复创建）
422 Unprocessable   → 业务逻辑错误（参数格式对但内容不对）
500 Internal Error  → 服务器错误
```

---

### 1.3 请求封装与拦截器
**Q：你们项目中 axios 是怎么封装的？为什么要封装？**

```js
import axios from 'axios'

// 创建实例
const service = axios.create({
  baseURL: process.env.VUE_APP_API,
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' }
})

// 请求拦截器：统一添加 token、签名等
service.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => Promise.reject(error)
)

// 响应拦截器：统一错误处理、数据格式化
service.interceptors.response.use(
  response => {
    const res = response.data
    // 后端返回格式：{ code: 0, data: {}, message: '' }
    if (res.code !== 0) {
      // 业务错误
      if (res.code === 401) {
        // token 过期 → 跳登录
        store.dispatch('user/logout')
        router.push('/login')
      }
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    return res.data
  },
  error => {
    // HTTP 错误
    if (error.response) {
      switch (error.response.status) {
        case 401: /* 跳登录 */ break
        case 403: /* 无权限 */ break
        case 500: /* 服务器错误 */ break
      }
    } else if (error.code === 'ECONNABORTED') {
      console.error('请求超时')
    }
    return Promise.reject(error)
  }
)

export default service
```

**为什么要封装？**
1. 统一处理 token 注入、过期刷新
2. 统一错误处理（网络错误、业务错误、权限错误）
3. 统一数据格式（剥离 `code/data/message` 包装）
4. 统一 loading 状态管理
5. 请求取消、防重复提交

---

### 1.4 Token 认证与刷新
**Q：token 过期了怎么办？用户正在操作突然要重新登录体验很差。**

**方案：无感刷新 token**

```js
let isRefreshing = false
let pendingRequests = []

service.interceptors.response.use(
  response => response.data,
  async error => {
    const { config, response } = error
    
    if (response.status === 401 && !config._retry) {
      if (isRefreshing) {
        // 正在刷新中，把请求挂起
        return new Promise(resolve => {
          pendingRequests.push(newToken => {
            config.headers.Authorization = `Bearer ${newToken}`
            resolve(service(config))
          })
        })
      }

      isRefreshing = true
      config._retry = true

      try {
        // 用 refresh_token 换新 token
        const { token, refreshToken } = await refreshToken()
        localStorage.setItem('token', token)
        localStorage.setItem('refreshToken', refreshToken)

        // 重试当前请求
        config.headers.Authorization = `Bearer ${token}`
        
        // 重试队列中的请求
        pendingRequests.forEach(cb => cb(token))
        pendingRequests = []

        return service(config)
      } catch (refreshError) {
        // refresh_token 也过期了 → 跳登录
        store.dispatch('user/logout')
        router.push('/login')
        return Promise.reject(refreshError)
      } finally {
        isRefreshing = false
      }
    }

    return Promise.reject(error)
  }
)
```

**关键点：**
- 用 `isRefreshing` 标记防止并发刷新
- 刷新期间的请求放进 `pendingRequests` 队列
- 刷新成功后依次重试队列中的请求
- 刷新失败才跳登录页

---

### 1.5 请求取消
**Q：页面切换时怎么取消上一个页面未完成的请求？**

```js
// 方法 1：AbortController（推荐）
const controller = new AbortController()

axios.get('/api/data', { signal: controller.signal })

// 页面离开时取消
controller.abort()

// 方法 2：axios CancelToken（已废弃，但仍常见）
const source = axios.CancelToken.source()
axios.get('/api/data', { cancelToken: source.token })
source.cancel('页面切换，取消请求')

// 实际封装：在路由守卫中统一取消
const pendingMap = new Map()

function addPending(config) {
  const key = `${config.url}&${config.method}`
  config.cancelToken = new axios.CancelToken(cancel => {
    if (!pendingMap.has(key)) {
      pendingMap.set(key, cancel)
    }
  })
}

function removePending(config) {
  const key = `${config.url}&${config.method}`
  if (pendingMap.has(key)) {
    pendingMap.get(key)('取消重复请求')
    pendingMap.delete(key)
  }
}

// 路由切换时清空所有 pending
router.beforeEach((to, from, next) => {
  pendingMap.forEach(cancel => cancel())
  pendingMap.clear()
  next()
})
```

---

### 1.6 文件上传
**Q：大文件上传怎么实现？**

```js
// 大文件上传核心流程
async function uploadLargeFile(file) {
  const CHUNK_SIZE = 5 * 1024 * 1024  // 5MB 一片
  const chunks = []

  // 1. 切片
  for (let start = 0; start < file.size; start += CHUNK_SIZE) {
    chunks.push({
      blob: file.slice(start, start + CHUNK_SIZE),
      index: chunks.length
    })
  }

  // 2. 计算文件 hash（用于标识文件，秒传判断）
  const fileHash = await calculateHash(file)

  // 3. 检查已上传的切片（断点续传）
  const { uploaded } = await api.checkUploaded(fileHash)
  // uploaded = [0, 1, 2] 表示前 3 片已上传

  // 4. 上传未完成的切片（并发控制）
  const uploadQueue = chunks
    .filter(chunk => !uploaded.includes(chunk.index))
    .map(chunk => {
      const formData = new FormData()
      formData.append('file', chunk.blob)
      formData.append('hash', fileHash)
      formData.append('index', chunk.index)
      return formData
    })

  await concurrencyControl(uploadQueue, 3, async (formData) => {
    await api.uploadChunk(formData)
    // 更新进度条
  })

  // 5. 通知后端合并切片
  await api.mergeChunks(fileHash, file.name)
}
```

**相关追问：**
- **秒传**：计算文件 hash → 后端查 hash 是否存在 → 存在则直接返回成功
- **断点续传**：记录已上传切片 → 只上传剩余部分
- **并发控制**：限制同时上传的切片数，避免浏览器卡顿

---

### 1.7 WebSocket
**Q：WebSocket 和 HTTP 的区别？什么场景用 WebSocket？**

| | HTTP | WebSocket |
|---|---|---|
| 连接方式 | 请求-响应，短连接 | 全双工，长连接 |
| 通信方向 | 单向（客户端发起） | 双向（服务端可主动推送） |
| 协议 | http/https | ws/wss |
| 开销 | 每次请求带完整 header | 握手后帧头很小（2-14字节） |
| 适用场景 | 普通数据请求 | 实时聊天、股票行情、协同编辑 |

```js
// 前端 WebSocket 使用
const ws = new WebSocket('wss://example.com/ws')

ws.onopen = () => {
  console.log('连接建立')
  ws.send(JSON.stringify({ type: 'auth', token: 'xxx' }))
}

ws.onmessage = (event) => {
  const data = JSON.parse(event.data)
  // 处理消息
}

ws.onclose = (event) => {
  if (event.code !== 1000) {
    // 非正常关闭 → 重连
    setTimeout(() => reconnect(), 3000)
  }
}

ws.onerror = (error) => {
  console.error('WebSocket 错误', error)
}

// 心跳保活
setInterval(() => {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({ type: 'ping' }))
  }
}, 30000)
```

**追问：WebSocket 断线重连怎么实现？**
```js
function reconnect(url, maxRetries = 5) {
  let retries = 0
  let ws

  function connect() {
    ws = new WebSocket(url)

    ws.onopen = () => {
      retries = 0  // 重连成功，重置计数
      console.log('重连成功')
    }

    ws.onclose = () => {
      if (retries < maxRetries) {
        retries++
        const delay = Math.min(1000 * 2 ** retries, 30000)  // 指数退避
        console.log(`${delay}ms 后第 ${retries} 次重连`)
        setTimeout(connect, delay)
      }
    }
  }

  connect()
  return ws
}
```

---

### 1.8 SSE（Server-Sent Events）
**Q：SSE 和 WebSocket 有什么区别？**

| | SSE | WebSocket |
|---|---|---|
| 方向 | 服务端 → 客户端（单向） | 双向 |
| 协议 | HTTP | 独立协议（ws） |
| 自动重连 | ✅ 内置 | ❌ 需手动实现 |
| 数据格式 | 纯文本 | 文本/二进制 |
| 浏览器支持 | 现代浏览器 | 全部 |

**适用场景：** AI 对话流式输出、通知推送、日志流

```js
// 前端
const source = new EventSource('/api/stream')

source.onmessage = (event) => {
  console.log('收到:', event.data)
}

source.onerror = () => {
  // 浏览器会自动重连
}

// 关闭
source.close()

// 后端响应格式
// Content-Type: text/event-stream
// data: {"message": "hello"}
//
// data: {"message": "world"}
//
```

---

### 1.9 跨域深入
**Q：CORS 的预检请求（Preflight）是什么？什么时候会触发？**

**简单请求**（不触发预检）：
- 方法：GET、HEAD、POST
- Content-Type：`text/plain`、`multipart/form-data`、`application/x-www-form-urlencoded`
- 无自定义请求头

**非简单请求**（触发预检）：
- PUT、DELETE、PATCH
- `Content-Type: application/json`
- 自定义头（如 `Authorization`）

```
// 预检请求流程
浏览器                              服务器
  |--- OPTIONS /api/data ----------→|
  |    Origin: http://a.com        |
  |    Access-Control-Request-Method: PUT |
  |    Access-Control-Request-Headers: Authorization |
  |                                 |
  |←-- 204 No Content -------------|
  |    Access-Control-Allow-Origin: http://a.com |
  |    Access-Control-Allow-Methods: GET, POST, PUT |
  |    Access-Control-Allow-Headers: Authorization |
  |    Access-Control-Max-Age: 86400 |
  |                                 |
  |--- PUT /api/data (真正请求) ---→|
  |                                 |
  |←-- 200 OK --------------------|
```

**`Access-Control-Max-Age`**：预检结果缓存时间（秒），避免每次都发 OPTIONS 请求。

---

### 1.10 接口错误处理策略
**Q：你们项目中接口报错怎么处理的？**

```js
// 分层处理策略
const errorHandler = {
  // 网络层错误
  network(error) {
    if (!navigator.onLine) {
      showToast('网络已断开，请检查网络连接')
      return
    }
    if (error.code === 'ECONNABORTED') {
      showToast('请求超时，请重试')
      return
    }
    showToast('网络异常，请稍后重试')
  },

  // HTTP 层错误
  http(status) {
    const map = {
      400: '请求参数错误',
      401: '登录已过期，请重新登录',
      403: '没有权限访问',
      404: '请求的资源不存在',
      429: '请求太频繁，请稍后重试',
      500: '服务器内部错误',
      502: '服务器网关错误',
      503: '服务暂时不可用'
    }
    showToast(map[status] || `请求失败(${status})`)

    if (status === 401) {
      store.dispatch('user/logout')
      router.push('/login')
    }
  },

  // 业务层错误
  business(code, message) {
    // 通用业务错误码处理
    const businessMap = {
      10001: 'token 无效',
      10002: '用户不存在',
      20001: '余额不足'
    }
    showToast(businessMap[code] || message || '操作失败')

    // 需要特殊处理的错误码
    if (code === 10001) {
      store.dispatch('user/logout')
    }
  }
}
```

---

## 二、前端安全

### 2.1 XSS（跨站脚本攻击）
**Q：什么是 XSS？怎么防御？**

**类型：**
1. **存储型 XSS**：恶意脚本存入数据库（如评论区注入 `<script>`）
2. **反射型 XSS**：恶意脚本在 URL 中，服务器"反射"回页面
3. **DOM XSS**：前端 JS 直接操作 DOM 插入未转义内容

```js
// 危险示例
document.getElementById('name').innerHTML = userInput  // XSS！

// 防御 1：转义输出
function escapeHtml(str) {
  const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }
  return str.replace(/[&<>"']/g, c => map[c])
}

// 防御 2：使用 textContent 而非 innerHTML
element.textContent = userInput  // 安全

// 防御 3：CSP（Content Security Policy）
// 服务器响应头：
// Content-Security-Policy: default-src 'self'; script-src 'self' 'nonce-abc123'
// 只允许加载同源脚本 + 带 nonce 的内联脚本

// 防御 4：HttpOnly Cookie
// Set-Cookie: token=xxx; HttpOnly
// JS 无法读取 HttpOnly Cookie，防止被 XSS 偷走

// Vue 中的防护
// v-html 是危险的！只对可信内容使用
<div v-html="trustedHtml"></div>  // 仅限管理员编辑的富文本
<span>{{ userInput }}</span>       // 模板语法自动转义，安全
```

---

### 2.2 CSRF（跨站请求伪造）
**Q：什么是 CSRF？怎么防御？**

**原理：** 用户登录了 A 网站 → 访问恶意 B 网站 → B 网站自动向 A 网站发请求 → 浏览器自动带上 A 的 Cookie → 请求成功。

```html
<!-- 恶意网站 B 的页面 -->
<img src="https://bank.com/api/transfer?to=hacker&amount=10000" />
<!-- 浏览器会自动带上 bank.com 的 Cookie！ -->
```

**防御：**

```js
// 1. CSRF Token
// 后端生成 token → 前端放在请求头中 → 后端验证
axios.defaults.headers.common['X-CSRF-Token'] = getCsrfToken()

// 2. SameSite Cookie
// Set-Cookie: token=xxx; SameSite=Strict
// Lax：导航跳转可以带 Cookie，POST 请求不带
// Strict：所有跨站请求都不带 Cookie
// None：都带（必须配合 Secure）

// 3. 验证 Origin / Referer 头
// 后端检查请求头中的 Origin 是否在白名单

// 4. 关键操作二次验证
// 转账、改密码等操作需要输入验证码或短信确认
```

---

### 2.3 点击劫持
**Q：什么是点击劫持？怎么防御？**

**原理：** 恶意网站用透明 iframe 嵌入目标网站，诱导用户点击。

```html
<!-- 恶意页面 -->
<style>
  iframe { opacity: 0; position: absolute; top: 0; left: 0; }
  button { position: absolute; top: 100px; left: 100px; }
</style>
<iframe src="https://bank.com/delete-account"></iframe>
<button>点击领取红包</button>  <!-- 实际点击的是 iframe 中的删除按钮 -->
```

**防御：**
```
// 1. X-Frame-Options（最常用）
X-Frame-Options: DENY          // 禁止被 iframe 嵌入
X-Frame-Options: SAMEORIGIN    // 只允许同源 iframe

// 2. CSP frame-ancestors（更灵活）
Content-Security-Policy: frame-ancestors 'self' https://trusted.com

// 3. JS 防御（辅助）
if (top !== window) {
  top.location = window.location  // 跳脱 iframe
}
```

---

## 三、设计模式（前端常用）

### 3.1 单例模式
**Q：前端什么时候用单例模式？**

```js
// 全局弹窗、登录框、Vuex store — 只需要一个实例
class Modal {
  static instance = null

  static getInstance() {
    if (!Modal.instance) {
      Modal.instance = new Modal()
    }
    return Modal.instance
  }

  show(content) {
    // 创建 DOM，显示弹窗
  }
}

// Vue 中的单例：全局组件、toast
let toastInstance = null
function showToast(msg) {
  if (!toastInstance) {
    const ToastConstructor = Vue.extend(Toast)
    toastInstance = new ToastConstructor()
    toastInstance.$mount()
    document.body.appendChild(toastInstance.$el)
  }
  toastInstance.show(msg)
}
```

---

### 3.2 发布订阅模式
**Q：发布订阅和观察者模式的区别？**

```
观察者模式：Subject → Observer（直接通知）
发布订阅模式：Publisher → EventCenter → Subscriber（通过事件中心解耦）
```

```js
// Vue 的事件总线就是发布订阅
// Vue 2
Vue.prototype.$bus = new Vue()
this.$bus.$emit('update', data)
this.$bus.$on('update', handler)

// Vue 3（没有 $bus，用 mitt）
import mitt from 'mitt'
const emitter = mitt()
emitter.emit('update', data)
emitter.on('update', handler)

// 小程序中的事件总线
class EventBus {
  constructor() { this.events = {} }
  on(name, fn) { (this.events[name] ||= []).push(fn) }
  emit(name, ...args) { this.events[name]?.forEach(fn => fn(...args)) }
  off(name, fn) { this.events[name] = this.events[name]?.filter(f => f !== fn) }
}
export default new EventBus()
```

---

### 3.3 策略模式
**Q：什么时候用策略模式？举个前端例子。**

```js
// 表单验证 — 替代大量 if-else
const validators = {
  required: (value) => value !== '' && value != null || '此项必填',
  minLength: (min) => (value) => value.length >= min || `最少 ${min} 个字符`,
  maxLength: (max) => (value) => value.length <= max || `最多 ${max} 个字符`,
  email: (value) => /\S+@\S+\.\S+/.test(value) || '邮箱格式不正确',
  phone: (value) => /^1[3-9]\d{9}$/.test(value) || '手机号格式不正确'
}

function validate(value, rules) {
  for (const rule of rules) {
    const validator = typeof rule === 'string' ? validators[rule] : rule
    const result = validator(value)
    if (result !== true) return result
  }
  return true
}

// 使用
const result = validate('abc', [
  validators.required,
  validators.minLength(6),
  validators.email
])
```

---

### 3.4 代理模式
**Q：前端有哪些代理模式的应用？**

```js
// 1. 事件代理（事件委托）
document.getElementById('list').addEventListener('click', (e) => {
  if (e.target.tagName === 'LI') {
    console.log('点击了', e.target.textContent)
  }
})

// 2. ES6 Proxy（Vue 3 响应式就是代理模式）
const proxy = new Proxy(target, handler)

// 3. 图片懒加载代理
const imgProxy = new Image()
imgProxy.src = realSrc
imgProxy.onload = () => {
  document.getElementById('img').src = realSrc
}
```

---

### 3.5 装饰器模式
**Q：前端什么时候用装饰器模式？**

```js
// 1. 函数增强（AOP 思想）
function log(target, name, descriptor) {
  const original = descriptor.value
  descriptor.value = function(...args) {
    console.log(`调用 ${name}，参数:`, args)
    const result = original.apply(this, args)
    console.log(`${name} 返回:`, result)
    return result
  }
  return descriptor
}

// 2. axios 拦截器就是装饰器模式
// 在不修改原始请求逻辑的情况下，添加 token、错误处理等功能

// 3. 防抖/节流装饰器
function debounceDecorator(fn, delay) {
  let timer
  return function(...args) {
    clearTimeout(timer)
    timer = setTimeout(() => fn.apply(this, args), delay)
  }
}

// 4. TypeScript 装饰器（Angular 大量使用）
class UserApi {
  @log
  @debounce(300)
  getUser(id: number) { /* ... */ }
}
```

---

## 四、错误监控与日志

### 4.1 前端错误捕获
**Q：你们项目怎么做前端错误监控的？**

```js
// 1. 全局 JS 错误
window.onerror = (msg, url, line, col, error) => {
  reportError({ type: 'js', msg, url, line, col, stack: error?.stack })
}

// 2. 未捕获的 Promise 错误
window.addEventListener('unhandledrejection', (event) => {
  reportError({ type: 'promise', reason: event.reason })
})

// 3. Vue 全局错误
app.config.errorHandler = (err, instance, info) => {
  reportError({
    type: 'vue',
    message: err.message,
    stack: err.stack,
    component: instance?.$options?.name,
    info
  })
}

// 4. 资源加载错误
window.addEventListener('error', (event) => {
  if (event.target.tagName) {
    reportError({
      type: 'resource',
      tag: event.target.tagName,
      src: event.target.src || event.target.href
    })
  }
}, true)  // 注意：资源错误需要在捕获阶段监听

// 5. 接口错误（在 axios 拦截器中上报）
// 6. 性能数据（Performance API）
```

---

### 4.2 Source Map 与错误定位
**Q：线上报错怎么定位到源码位置？**

```
1. 打包时生成 Source Map（.map 文件）
2. Source Map 上传到错误监控平台（Sentry、Fundebug 等）
3. 线上报错时上报压缩后的行号列号
4. 监控平台用 Source Map 还原为源码位置

注意：
- Source Map 不要放在 CDN 上（暴露源码）
- 只在监控平台使用
- webpack 配置：devtool: 'source-map'
```

---

### 4.3 性能监控
**Q：前端性能指标有哪些？怎么采集？**

```js
// Core Web Vitals（Google 核心指标）
// 1. LCP（Largest Contentful Paint）最大内容绘制
new PerformanceObserver((list) => {
  const entries = list.getEntries()
  const lcp = entries[entries.length - 1]
  console.log('LCP:', lcp.startTime)  // 目标 < 2.5s
}).observe({ type: 'largest-contentful-paint', buffered: true })

// 2. FID（First Input Delay）首次输入延迟
new PerformanceObserver((list) => {
  const entry = list.getEntries()[0]
  console.log('FID:', entry.processingStart - entry.startTime)  // 目标 < 100ms
}).observe({ type: 'first-input', buffered: true })

// 3. CLS（Cumulative Layout Shift）累积布局偏移
let clsValue = 0
new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (!entry.hadRecentInput) clsValue += entry.value
  }
  console.log('CLS:', clsValue)  // 目标 < 0.1
}).observe({ type: 'layout-shift', buffered: true })

// 传统指标
const timing = performance.timing
const metrics = {
  DNS: timing.domainLookupEnd - timing.domainLookupStart,
  TCP: timing.connectEnd - timing.connectStart,
  TTFB: timing.responseStart - timing.requestStart,  // 首字节时间
  DOMReady: timing.domContentLoadedEventEnd - timing.navigationStart,
  Load: timing.loadEventEnd - timing.navigationStart
}
```

---

## 五、部署与运维

### 5.1 前端项目的部署流程
**Q：你们项目的部署流程是怎样的？**

```
开发者 push 代码
    ↓
Git 仓库（GitHub/GitLab）
    ↓
CI/CD 触发（Jenkins/GitLab CI/GitHub Actions）
    ↓
┌─────────────────────────────┐
│  1. 安装依赖 (npm install)   │
│  2. 代码检查 (eslint)        │
│  3. 单元测试 (jest)          │
│  4. 构建打包 (npm run build) │
│  5. 上传 CDN / 服务器        │
│  6. 刷新缓存 / 热更新        │
└─────────────────────────────┘
    ↓
生产环境（Nginx / CDN）
```

**Nginx 配置要点：**
```nginx
server {
    listen 80;
    server_name www.example.com;

    # 前端静态文件
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;  # SPA history 模式
        index index.html;
    }

    # API 反向代理（解决跨域）
    location /api/ {
        proxy_pass http://backend:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 静态资源缓存
    location ~* \.(js|css|png|jpg|ico)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # HTML 不缓存（保证更新）
    location ~* \.html$ {
        expires -1;
        add_header Cache-Control "no-cache";
    }

    # Gzip 压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    gzip_min_length 1024;
}
```

---

### 5.2 前端灰度发布
**Q：什么是灰度发布？前端怎么做？**

```js
// 灰度策略
const grayConfig = {
  // 1. 按用户 ID
  userIds: ['user_001', 'user_002'],

  // 2. 按百分比
  percentage: 10,  // 10% 用户走新版本

  // 3. 按地区/设备
  regions: ['beijing', 'shanghai'],
  devices: ['ios', 'android']
}

// 实现方式 1：Nginx 分流
// 根据 Cookie 或 Header 将请求路由到不同版本的静态资源

// 实现方式 2：前端代码控制
async function loadApp() {
  const isGray = await checkGrayUser()  // 后端接口判断
  if (isGray) {
    import('./app-v2.js')  // 新版本
  } else {
    import('./app-v1.js')  // 旧版本
  }
}
```

---

### 5.3 微前端
**Q：你了解微前端吗？什么场景需要微前端？**

**适用场景：**
- 多团队协作，技术栈不同（Vue + React + Angular）
- 老项目渐进式迁移
- 需要独立部署的子应用

**主流方案：**

| 方案 | 原理 | 优点 | 缺点 |
|---|---|---|---|
| iframe | 浏览器原生隔离 | 简单、隔离性好 | 通信困难、体验差 |
| qiankun | JS 沙箱 + 样式隔离 | 生态成熟、接入简单 | 沙箱不完美 |
| Module Federation | Webpack 5 模块共享 | 构建时共享、性能好 | 需要统一构建工具 |
| Web Components | 浏览器原生组件标准 | 框架无关 | 兼容性、生态不足 |

---

## 六、小程序专项深入

### 6.1 小程序登录流程
**Q：微信小程序的登录流程是怎样的？**

```
┌──────────┐    ┌──────────┐    ┌──────────┐
│ 小程序    │    │ 微信服务器│    │ 你的服务器│
└────┬─────┘    └────┬─────┘    └────┬─────┘
     │               │               │
     │  wx.login()   │               │
     │──────────────→│               │
     │               │               │
     │  返回 code    │               │
     │←──────────────│               │
     │               │               │
     │  发送 code    │               │
     │──────────────────────────────→│
     │               │               │
     │               │  code + appid │
     │               │  + appsecret  │
     │               │←──────────────│
     │               │               │
     │               │  openid +     │
     │               │  session_key  │
     │               │──────────────→│
     │               │               │
     │  自定义 token │               │
     │←──────────────────────────────│
     │               │               │
     // 后续请求都带自定义 token

关键点：
1. code 只能用一次，5 分钟过期
2. session_key 不要下发给前端（用于解密用户数据）
3. 用自定义 token 做后续鉴权
4. openid 是用户在该小程序的唯一标识
```

---

### 6.2 小程序 vs H5 vs App
**Q：小程序、H5、原生 App 的区别？你们为什么选小程序？**

| | 小程序 | H5 | 原生 App |
|---|---|---|---|
| 安装 | 不需要 | 不需要 | 需要下载安装包 |
| 性能 | 接近原生 | 较差 | 最好 |
| 体验 | 流畅 | 受网络影响 | 最流畅 |
| 推送 | 模板消息/订阅消息 | 无（除非 PWA） | 系统推送 |
| 离线 | 部分支持 | 部分支持（PWA） | 支持 |
| 审核 | 微信审核（严格） | 无需审核 | 应用商店审核 |
| 开发成本 | 中等 | 低 | 高（双端） |
| 入口 | 微信内扫码/搜索 | 浏览器/链接 | 桌面图标 |
| 系统能力 | 有限（摄像头、位置等） | 有限 | 完整 |

---

### 6.3 小程序自定义组件
**Q：小程序自定义组件和页面有什么区别？**

```js
// 组件 Component({
Component({
  // 组件属性（类似 Vue props）
  properties: {
    title: {
      type: String,
      value: '',
      observer(newVal) { /* 监听变化 */ }
    }
  },

  // 组件内部数据
  data: {
    count: 0
  },

  // 组件方法
  methods: {
    onTap() {
      this.setData({ count: this.data.count + 1 })
      // 触发父组件事件
      this.triggerEvent('change', { count: this.data.count })
    }
  },

  // 组件生命周期
  lifetimes: {
    created() { /* 实例创建，不能 setData */ },
    attached() { /* 进入节点树，可以 setData */ },
    ready() { /* 渲染完成 */ },
    detached() { /* 离开节点树，清理资源 */ }
  },

  // 数据监听器（类似 Vue watch）
  observers: {
    'count': function(val) {
      console.log('count 变化了:', val)
    }
  },

  // 组件间关系
  relations: {
    '../parent/parent': {
      type: 'parent',
      linked(target) { /* 被插入父组件时 */ }
    }
  },

  // 插槽
  options: {
    multipleSlots: true  // 启用多插槽
  }
})
```

---

### 6.4 小程序的 wx.request 封装
**Q：你们小程序的请求是怎么封装的？**

```js
// request.js
const BASE_URL = 'https://api.example.com'

const request = (options) => {
  return new Promise((resolve, reject) => {
    // 显示 loading
    if (options.loading !== false) {
      wx.showLoading({ title: '加载中...' })
    }

    wx.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      data: options.data,
      header: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${wx.getStorageSync('token')}`
      },
      success(res) {
        if (res.statusCode === 200) {
          if (res.data.code === 0) {
            resolve(res.data.data)
          } else if (res.data.code === 401) {
            // token 过期 → 重新登录
            wx.navigateTo({ url: '/pages/login/login' })
            reject(new Error('登录过期'))
          } else {
            wx.showToast({ title: res.data.message, icon: 'none' })
            reject(new Error(res.data.message))
          }
        } else {
          wx.showToast({ title: '网络错误', icon: 'none' })
          reject(new Error(`HTTP ${res.statusCode}`))
        }
      },
      fail(err) {
        wx.showToast({ title: '网络异常', icon: 'none' })
        reject(err)
      },
      complete() {
        if (options.loading !== false) {
          wx.hideLoading()
        }
      }
    })
  })
}

// 导出
export const get = (url, data) => request({ url, method: 'GET', data })
export const post = (url, data) => request({ url, method: 'POST', data })
```

---

## 七、综合场景题

### 7.1 登录态管理
**Q：你们项目的登录态是怎么管理的？token 存在哪？**

```js
// 存储位置对比
// 1. localStorage — 前端常用
localStorage.setItem('token', token)
// 优点：持久化，关闭浏览器还在
// 缺点：容易被 XSS 读取

// 2. Cookie（HttpOnly）— 更安全
// 后端设置：Set-Cookie: token=xxx; HttpOnly; Secure; SameSite=Strict
// 优点：JS 无法读取，防止 XSS 窃取
// 缺点：需要防 CSRF

// 3. sessionStorage
sessionStorage.setItem('token', token)
// 关闭标签页就清除，安全性略高

// 4. 内存变量（最安全，但刷新丢失）
let token = ''

// 推荐方案：
// 前端：localStorage 存 token
// 后端：敏感操作用 HttpOnly Cookie
// 所有接口：HTTPS + Bearer Token

// 登录流程
async function login(username, password) {
  const { token, refreshToken, user } = await api.login({ username, password })
  localStorage.setItem('token', token)
  localStorage.setItem('refreshToken', refreshToken)
  store.commit('SET_USER', user)
  router.push('/')
}

// 退出登录
function logout() {
  localStorage.removeItem('token')
  localStorage.removeItem('refreshToken')
  store.commit('CLEAR_USER')
  router.push('/login')
}
```

---

### 7.2 长列表优化
**Q：页面上有上万条数据怎么优化？**

```js
// 方案 1：虚拟列表（只渲染可视区域）
// 原理：监听滚动，只渲染可见的 N 个元素
class VirtualList {
  constructor({ container, itemHeight, total, renderItem }) {
    this.container = container
    this.itemHeight = itemHeight
    this.total = total
    this.renderItem = renderItem

    // 可视区域能显示多少个
    this.visibleCount = Math.ceil(container.clientHeight / itemHeight)

    // 创建占位元素（撑开滚动高度）
    this.placeholder = document.createElement('div')
    this.placeholder.style.height = total * itemHeight + 'px'
    container.appendChild(this.placeholder)

    // 监听滚动
    container.addEventListener('scroll', () => this.onScroll())
  }

  onScroll() {
    const scrollTop = this.container.scrollTop
    const startIndex = Math.floor(scrollTop / this.itemHeight)
    const endIndex = startIndex + this.visibleCount + 1  // 多渲染 1 个缓冲

    // 只渲染可见区域
    this.renderItems(startIndex, Math.min(endIndex, this.total))
  }
}

// 方案 2：分页加载（最常用）
// 方案 3：无限滚动（IntersectionObserver）
const observer = new IntersectionObserver(entries => {
  if (entries[0].isIntersecting) {
    loadMore()
  }
})
observer.observe(sentinel)  // 监听底部哨兵元素

// 方案 4：时间分片（requestAnimationFrame）
function renderLargeList(data) {
  const chunk = data.splice(0, 100)  // 每次渲染 100 条
  chunk.forEach(item => renderOne(item))
  if (data.length > 0) {
    requestAnimationFrame(() => renderLargeList(data))
  }
}
```

---

### 7.3 多 Tab 并发请求
**Q：多个 Tab 页切换，每个 Tab 都要请求数据，怎么优化？**

```js
// 问题：快速切换 Tab 会导致：
// 1. 多个请求并发，浪费带宽
// 2. 后发的请求可能先返回，数据错乱

// 方案：取消前一个请求 + 只用最后一个结果
let currentController = null

async function fetchTabData(tabId) {
  // 取消上一个请求
  if (currentController) {
    currentController.abort()
  }

  currentController = new AbortController()

  try {
    const data = await fetch(`/api/tab/${tabId}`, {
      signal: currentController.signal
    })
    renderData(data)
  } catch (err) {
    if (err.name === 'AbortError') {
      console.log('请求被取消（切换了 Tab）')
    } else {
      throw err
    }
  }
}

// 方案 2：请求竞态（只取最后一次结果）
function createRace() {
  let requestId = 0
  return async function fetchLatest(tabId) {
    const currentId = ++requestId
    const data = await fetch(`/api/tab/${tabId}`)
    if (currentId !== requestId) return  // 过期请求，丢弃
    renderData(data)
  }
}
```

---

> 📅 本文件最后更新：2026-06-27
