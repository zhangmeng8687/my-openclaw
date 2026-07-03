# 前端面试题整理 — 5年经验 · Vue/小程序方向

> 目标：中小公司，技术栈 Vue + 微信小程序，准备覆盖 JS 基础、Vue 原理、小程序机制、工程化、性能优化、网络等高频考点。

---

## 一、JavaScript 基础（高频必考）

### 1.1 闭包
**Q：什么是闭包？有什么应用场景？有什么问题？**

A：闭包是指函数能够访问其词法作用域外部的变量，即使该函数在其他地方执行。本质是函数 + 它能访问的外部变量的引用。

```js
function createCounter() {
  let count = 0
  return {
    increment() { return ++count },
    getCount() { return count }
  }
}
```

应用场景：
- 函数封装（数据私有化）
- 柯里化、偏函数
- 防抖/节流
- 模块模式

问题：
- 内存泄漏：闭包持有外部变量引用，不释放会导致变量常驻内存
- 经典循环陷阱：`for` + `var` + 闭包 → 用 `let` 或 IIFE 解决

---

### 1.2 原型链
**Q：说说 JavaScript 的原型链机制？**

```
实例.__proto__ === 构造函数.prototype
构造函数.prototype.__proto__ === Object.prototype
Object.prototype.__proto__ === null
```

- 每个对象都有 `__proto__` 指向其构造函数的 `prototype`
- 属性查找沿原型链向上，找到即停
- `instanceof` 就是沿着原型链查找
- `hasOwnProperty` 只查自身，不查原型链

---

### 1.3 this 指向
**Q：this 的绑定规则有哪些？优先级？**

四种绑定规则（优先级从低到高）：
1. **默认绑定**：独立调用 → `window`（严格模式下 `undefined`）
2. **隐式绑定**：`obj.fn()` → `obj`
3. **显式绑定**：`call/apply/bind` → 指定对象
4. **new 绑定**：`new Foo()` → 新创建的对象

箭头函数：没有自己的 `this`，继承外层作用域的 `this`（词法 this）。

```js
const obj = {
  name: 'obj',
  regular() { console.log(this.name) },    // 'obj'
  arrow: () => { console.log(this.name) }   // 外层 this
}
```

---

### 1.4 Promise 与异步
**Q：手写一个简单的 Promise（或说清 Promise 的状态流转）**

三种状态：`pending` → `fulfilled` / `rejected`，不可逆。

```js
// 手写 Promise.all
function promiseAll(promises) {
  return new Promise((resolve, reject) => {
    const results = []
    let count = 0
    promises.forEach((p, i) => {
      Promise.resolve(p).then(val => {
        results[i] = val
        if (++count === promises.length) resolve(results)
      }, reject)
    })
  })
}
```

**async/await 本质是什么？**
- `async` 函数返回 Promise
- `await` 是 `yield` 的语法糖，暂停执行直到 Promise 完成
- 底层是 Generator + 自动执行器

---

### 1.5 事件循环（Event Loop）
**Q：说说浏览器的事件循环机制？**

```
宏任务：setTimeout、setInterval、I/O、UI 渲染、script
微任务：Promise.then/catch/finally、MutationObserver、queueMicrotask
```

执行顺序：
1. 执行同步代码（调用栈）
2. 微任务队列全部清空
3. 渲染（如果需要）
4. 取一个宏任务执行
5. 回到步骤 2

```js
console.log('1')
setTimeout(() => console.log('2'))
Promise.resolve().then(() => console.log('3'))
console.log('4')
// 输出：1, 4, 3, 2
```

**Node.js 的区别：** 有 `process.nextTick`（优先级高于微任务）和 `setImmediate`。

---

### 1.6 深拷贝
**Q：手写深拷贝，需要处理哪些问题？**

```js
function deepClone(obj, map = new WeakMap()) {
  if (obj === null || typeof obj !== 'object') return obj
  if (map.has(obj)) return map.get(obj)  // 循环引用

  const clone = Array.isArray(obj) ? [] : {}
  map.set(obj, clone)

  for (const key of Reflect.ownKeys(obj)) {
    clone[key] = deepClone(obj[key], map)
  }
  return clone
}
```

需要处理：
- 循环引用（WeakMap）
- 特殊对象类型：Date、RegExp、Map、Set、Symbol 属性
- 原型链保持
- 不可枚举属性

---

### 1.7 防抖与节流
**Q：手写防抖和节流函数**

```js
// 防抖：延迟执行，重复调用则重新计时
function debounce(fn, delay) {
  let timer = null
  return function(...args) {
    clearTimeout(timer)
    timer = setTimeout(() => fn.apply(this, args), delay)
  }
}

// 节流：固定间隔内只执行一次
function throttle(fn, interval) {
  let last = 0
  return function(...args) {
    const now = Date.now()
    if (now - last >= interval) {
      last = now
      fn.apply(this, args)
    }
  }
}
```

---

### 1.8 继承
**Q：ES6 class 继承和寄生组合继承的区别？**

```js
// ES6 class
class Parent {
  constructor(name) { this.name = name }
  say() { console.log(this.name) }
}
class Child extends Parent {
  constructor(name, age) {
    super(name)
    this.age = age
  }
}

// 寄生组合继承（ES5 最佳实践）
function Child(name, age) {
  Parent.call(this, name)
  this.age = age
}
Child.prototype = Object.create(Parent.prototype)
Child.prototype.constructor = Child
```

区别：ES6 class 会继承静态方法，寄生组合不会；class 必须 `new`，不能直接调用。

---

## 二、Vue.js（核心重点）

### 2.1 响应式原理
**Q：Vue 2 和 Vue 3 的响应式原理有什么区别？**

**Vue 2：`Object.defineProperty`**
- 递归遍历对象属性，对每个属性设置 getter/setter
- 问题：
  - 无法检测新增/删除属性（需要 `Vue.set` / `Vue.delete`）
  - 无法检测数组索引修改和 `length` 变化（重写了数组方法）
  - 初始化时递归所有属性，性能开销大

**Vue 3：`Proxy`**
- 代理整个对象，拦截所有操作（get/set/deleteProperty/has 等）
- 天然支持新增/删除属性、数组索引修改
- 惰性代理：只在访问嵌套对象时才递归代理
- 配合 `Reflect` 使用

```js
// Vue 3 响应式简化版
const reactive = (target) => new Proxy(target, {
  get(target, key, receiver) {
    track(target, key)      // 依赖收集
    return Reflect.get(target, key, receiver)
  },
  set(target, key, value, receiver) {
    const result = Reflect.set(target, key, value, receiver)
    trigger(target, key)    // 触发更新
    return result
  }
})
```

---

### 2.2 虚拟 DOM 和 Diff 算法
**Q：Vue 的 diff 算法是怎么工作的？**

核心思路：同层比较，不跨层级。

Vue 2（双端比较）：
1. 旧头 vs 新头 → 匹配则都向后移
2. 旧尾 vs 新尾 → 匹配则都向前移
3. 旧头 vs 新尾 → 匹配则旧头后移，新尾前移
4. 旧尾 vs 新头 → 匹配则旧尾前移，新头后移
5. 以上都不匹配 → 用 key 在旧节点中查找

Vue 3（最长递增子序列）：
1. 先从头部同步相同的节点
2. 再从尾部同步相同的节点
3. 中间乱序部分：遍历新节点，在旧节点中查找
4. 找到的可复用节点标记索引
5. 对索引求最长递增子序列，不在序列中的节点需要移动

---

### 2.3 computed vs watch
**Q：computed 和 watch 的区别？各自适用场景？**

| | computed | watch |
|---|---|---|
| 缓存 | 有缓存，依赖不变则不重新计算 | 无缓存，每次变化都执行 |
| 返回值 | 必须有返回值 | 不需要返回值 |
| 异步 | 不支持异步 | 支持异步 |
| 场景 | 模板中使用的派生数据 | 需要执行副作用（发请求、操作 DOM） |

```js
// computed 源码核心逻辑（简化）
// dirty 标记：依赖变化时 dirty=true，下次访问重新计算
// 依赖不变时 dirty=false，直接返回缓存值
```

---

### 2.4 生命周期
**Q：Vue 组件的生命周期？父子组件的执行顺序？**

**单组件：** beforeCreate → created → beforeMount → mounted → beforeUpdate → updated → beforeDestroy → destroyed

**父子组件加载顺序：**
```
父 beforeCreate → 父 created → 父 beforeMount →
  子 beforeCreate → 子 created → 子 beforeMount → 子 mounted →
父 mounted
```

**销毁顺序：**
```
父 beforeDestroy →
  子 beforeDestroy → 子 destroyed →
父 destroyed
```

**Vue 3 变化：** `beforeDestroy` → `beforeUnmount`，`destroyed` → `unmounted`。

---

### 2.5 nextTick
**Q：nextTick 的原理？为什么需要它？**

**为什么：** Vue 的 DOM 更新是异步的。数据变化后，DOM 不会立即更新，而是在下一个事件循环的微任务中批量更新。

**原理：** 将回调放入微任务队列，等 DOM 更新后执行。

```js
// nextTick 降级策略
let timerFunc
if (Promise) {
  timerFunc = () => Promise.resolve().then(flushCallbacks)
} else if (MutationObserver) {
  // ...
} else if (setImmediate) {
  timerFunc = () => setImmediate(flushCallbacks)
} else {
  timerFunc = () => setTimeout(flushCallbacks, 0)
}
```

---

### 2.6 Vue Router
**Q：hash 模式和 history 模式的区别？**

| | hash | history |
|---|---|---|
| URL | `/#/path` | `/path` |
| 服务器 | 不需要配置 | 需要配置 fallback |
| API | `hashchange` 事件 | `pushState` / `replaceState` |
| 刷新 | 不会发给服务器 | 会请求服务器，需要后端配合 |
| 兼容性 | IE8+ | IE10+ |

**history 模式后端配置（Nginx）：**
```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

---

### 2.7 Vuex / Pinia
**Q：Vuex 的核心概念？和 Pinia 的区别？**

Vuex：state、getters、mutations（同步）、actions（异步）、modules

Pinia（Vue 3 推荐）：
- 去掉 mutations，直接修改 state
- 去掉 modules，每个 store 独立
- 完整的 TypeScript 支持
- 支持组合式 API 风格

```js
// Pinia
export const useUserStore = defineStore('user', () => {
  const name = ref('')
  const doubleName = computed(() => name.value + '!')
  function setName(newName) { name.value = newName }
  return { name, doubleName, setName }
})
```

---

## 三、微信小程序（核心重点）

### 3.1 生命周期
**Q：小程序的页面生命周期和组件生命周期？**

**页面生命周期：**
- `onLoad`：页面加载（获取路由参数）
- `onShow`：页面显示（每次切回都触发）
- `onReady`：页面初次渲染完成
- `onHide`：页面隐藏（跳转到其他页面）
- `onUnload`：页面卸载（redirectTo/navigateBack）

**组件生命周期：**
- `created`：组件实例创建（不能 setData）
- `attached`：进入节点树（可以 setData）
- `ready`：组件渲染完成
- `detached`：离开节点树

**执行顺序：** created → attached → ready → detached

---

### 3.2 数据通信
**Q：小程序父子组件如何通信？**

```js
// 1. 父传子：properties
Component({
  properties: {
    title: { type: String, value: '' }
  }
})

// 2. 子传父：triggerEvent
this.triggerEvent('change', { value: 123 })

// 3. 获取组件实例
const child = this.selectComponent('#my-comp')
child.setData({ ... })
child.someMethod()
```

其他方式：
- 全局数据：`getApp().globalData`
- 事件总线：`EventEmitter`
- 存储：`wx.setStorageSync`

---

### 3.3 小程序架构
**Q：小程序的双线程模型？**

```
┌─────────────────┐     ┌─────────────────┐
│   逻辑层         │     │   渲染层         │
│  (JsCore)       │ ──→ │  (WebView)      │
│                 │     │                 │
│  App/Page/      │     │  WXML/WXSS      │
│  Component JS   │     │  渲染           │
└─────────────────┘     └─────────────────┘
        ↑                        ↑
        └───── Native 层 ────────┘
              (微信客户端)
```

- 逻辑层和渲染层分离，运行在不同线程
- 通过 Native 层的 `JSBridge` 通信
- `setData` 是跨线程通信，数据序列化传输
- 这就是为什么 `setData` 要尽量减少数据量

---

### 3.4 setData 优化
**Q：setData 如何优化？为什么不能频繁调用？**

问题：
- 数据序列化 → 跨线程传输 → 反序列化 → 触发渲染
- 数据量大或频率高会导致卡顿

优化：
```js
// ❌ 错误：循环中频繁 setData
for (let i = 0; i < 100; i++) {
  this.setData({ [`list[${i}].name`]: 'new' })
}

// ✅ 正确：合并一次 setData
const update = {}
for (let i = 0; i < 100; i++) {
  update[`list[${i}].name`] = 'new'
}
this.setData(update)

// ✅ 局部更新，只改需要的部分
this.setData({ 'list[5].name': 'new' })  // 路径更新

// ✅ 纯数据字段（不参与渲染的数据）
Component({
  options: { pureDataPattern: /^_/ },
  data: { _rawData: null }  // 不会发给渲染层
})
```

---

### 3.5 分包加载
**Q：小程序分包是什么？怎么配置？**

```json
// app.json
{
  "pages": ["pages/index/index"],
  "subpackages": [
    {
      "root": "packageA",
      "pages": ["pages/detail/detail"]
    },
    {
      "root": "packageB",
      "name": "pkgB",
      "pages": ["pages/list/list"],
      "independent": true  // 独立分包
    }
  ],
  "preloadRule": {
    "pages/index/index": {
      "network": "all",
      "packages": ["packageA"]
    }
  }
}
```

- 主包限制 2MB，总包限制 20MB
- 预下载：用户访问某个页面时自动下载指定分包
- 独立分包：可以独立运行，不依赖主包

---

### 3.6 小程序性能优化
**Q：小程序有哪些性能优化手段？**

1. **setData 优化**：减少数据量、合并调用、路径更新
2. **分包加载**：主包精简，非首屏内容放入分包
3. **图片优化**：CDN + WebP + 懒加载 + 合理尺寸
4. **长列表优化**：虚拟列表（只渲染可视区域）
5. **骨架屏**：提升感知速度
6. **避免频繁 GC**：减少临时对象创建
7. **WXML 优化**：减少节点层级、避免 hidden 大量节点
8. **预加载**：`wx.preload` 或 preloadRule
9. **数据缓存**：`wx.setStorageSync` 缓存接口数据

---

## 四、CSS 高频题

### 4.1 BFC
**Q：什么是 BFC？怎么触发？有什么用？**

BFC（Block Formatting Context）：块级格式化上下文，是一个独立的渲染区域，内部元素不影响外部。

触发条件：
- `overflow` 不为 `visible`（如 `hidden`、`auto`）
- `display: flow-root`（推荐）
- `float` 不为 `none`
- `position: absolute / fixed`
- `display: inline-block / flex / grid`

用途：
- 清除浮动（父元素包裹浮动子元素）
- 防止 margin 重叠
- 阻止元素被浮动元素覆盖

---

### 4.2 Flex 布局
**Q：flex: 1 是什么的简写？**

```css
flex: 1 = flex-grow: 1; flex-shrink: 1; flex-basis: 0%;
flex: auto = flex-grow: 1; flex-shrink: 1; flex-basis: auto;
flex: none = flex-grow: 0; flex-shrink: 0; flex-basis: auto;
```

**Q：如何实现水平垂直居中？**
```css
/* Flex（最常用） */
.parent { display: flex; justify-content: center; align-items: center; }

/* Grid */
.parent { display: grid; place-items: center; }

/* 定位 + transform */
.child { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); }
```

---

### 4.3 移动端适配
**Q：小程序和 H5 的移动端适配方案？**

**小程序：** 使用 `rpx`（responsive pixel），750rpx = 设计稿宽度。系统自动换算。

**H5 方案：**
- `rem`：根元素字体大小 + JS 动态计算
- `vw/vh`：视口单位，`postcss-px-to-viewport` 插件自动转换
- `flexible.js` + `rem`（阿里方案，已不推荐）
- 推荐：`vw` 方案或 `rem` + 媒体查询

---

## 五、网络与浏览器

### 5.1 HTTP 缓存
**Q：强缓存和协商缓存？**

**强缓存（不发请求）：**
- `Cache-Control: max-age=31536000`（优先级高）
- `Expires: Thu, 01 Jan 2025 00:00:00 GMT`

**协商缓存（发请求，服务器判断是否用缓存）：**
- `Last-Modified` / `If-Modified-Since`（精度：秒）
- `ETag` / `If-None-Match`（精度：内容哈希，优先级高）

```
请求 → 强缓存命中？ → 是 → 直接用缓存
                   → 否 → 发请求 → 协商缓存命中？ → 304 → 用缓存
                                                    → 200 → 返回新资源
```

---

### 5.2 跨域
**Q：跨域的原因和解决方案？**

原因：浏览器同源策略（协议+域名+端口都相同才同源）。

方案：
1. **CORS**（推荐）：服务器设置 `Access-Control-Allow-Origin`
2. **代理**：开发用 `webpack-dev-server`，生产用 Nginx 反向代理
3. **JSONP**：只支持 GET，利用 `<script>` 标签
4. **postMessage**：跨窗口通信

**小程序为什么不跨域？** 因为小程序的请求不经过浏览器，由微信客户端发起，不受同源策略限制。

---

### 5.3 HTTPS
**Q：HTTPS 的加密过程？**

```
客户端 → 服务器：Client Hello（支持的 TLS 版本、加密套件、随机数1）
服务器 → 客户端：Server Hello（选定的加密套件、随机数2）+ 证书
客户端：验证证书 → 生成随机数3 → 用服务器公钥加密发送
双方：用三个随机数生成对称密钥 → 后续用对称加密通信
```

本质：非对称加密交换密钥，对称加密传输数据。

---

## 六、性能优化

### 6.1 首屏优化
**Q：首屏加载慢怎么优化？**

1. **资源优化**
   - 代码分割（路由懒加载）
   - 图片懒加载 + WebP
   - Gzip/Brotli 压缩
   - Tree Shaking

2. **加载策略**
   - 关键 CSS 内联
   - JS `defer` / `async`
   - 资源预加载：`<link rel="preload">`
   - DNS 预解析：`<link rel="dns-prefetch">`

3. **缓存策略**
   - 强缓存 + 内容哈希文件名
   - 接口数据缓存

4. **渲染优化**
   - SSR / SSG
   - 骨架屏
   - 服务端渲染首屏 HTML

---

### 6.2 Vue 项目优化
**Q：Vue 项目有哪些优化手段？**

1. `v-if` vs `v-show`：频繁切换用 `v-show`，条件少变用 `v-if`
2. `v-for` 必须加 `key`，避免和 `v-if` 同时使用
3. 组件懒加载：`() => import('./Heavy.vue')`
4. `Object.freeze()` 冻结大列表数据
5. `computed` 缓存替代 `methods` 中的重复计算
6. `keep-alive` 缓存组件
7. 长列表虚拟滚动
8. 第三方库按需引入（如 Element UI）

---

## 七、工程化

### 7.1 Webpack vs Vite
**Q：Webpack 和 Vite 的区别？**

| | Webpack | Vite |
|---|---|---|
| 开发服务器 | 先打包再启动 | 原生 ESM，按需编译 |
| 启动速度 | 慢（全量打包） | 极快（按需加载） |
| 热更新 | 较慢 | 极快（模块级 HMR） |
| 生态 | 完善 | 快速发展中 |
| 配置 | 复杂 | 简单，开箱即用 |
| 原理 | Bundle-based | ESM + esbuild 预构建 |

---

### 7.2 Git 工作流
**Q：你们团队的 Git 分支管理？**

```
main/master     ← 生产分支
  └── develop   ← 开发分支
        ├── feature/xxx  ← 功能分支
        ├── bugfix/xxx   ← 修复分支
        └── release/1.0  ← 发布分支
```

常用命令：
```bash
git rebase -i HEAD~3     # 合并提交
git cherry-pick abc123   # 摘取提交
git stash / git stash pop  # 暂存工作区
git bisect               # 二分查找 bug
```

---

## 八、手写题（高频）

### 8.1 数组扁平化
```js
// 递归
function flatten(arr) {
  return arr.reduce((acc, cur) =>
    acc.concat(Array.isArray(cur) ? flatten(cur) : cur), []
  )
}

// 迭代
function flatten(arr) {
  const stack = [...arr]
  const result = []
  while (stack.length) {
    const item = stack.pop()
    Array.isArray(item) ? stack.push(...item) : result.unshift(item)
  }
  return result
}

// 原生
arr.flat(Infinity)
```

### 8.2 发布订阅模式
```js
class EventEmitter {
  constructor() { this.events = {} }

  on(event, fn) {
    (this.events[event] ||= []).push(fn)
  }

  off(event, fn) {
    this.events[event] = this.events[event]?.filter(f => f !== fn)
  }

  emit(event, ...args) {
    this.events[event]?.forEach(fn => fn(...args))
  }
}
```

### 8.3 数组去重
```js
// 最简
[...new Set(arr)]

// 处理对象引用
function unique(arr) {
  const map = new Map()
  return arr.filter(item => {
    const key = typeof item === 'object' ? JSON.stringify(item) : item
    if (map.has(key)) return false
    map.set(key, true)
    return true
  })
}
```

---

## 九、算法（中小公司频率不高但偶尔考）

### 常见题型
1. **两数之和**（哈希表）
2. **反转链表**（迭代/递归）
3. **有效的括号**（栈）
4. **最大子数组和**（动态规划）
5. **二分查找**
6. **冒泡/快排**（手写排序）
7. **斐波那契数列**（递归 + 记忆化）

```js
// 快排
function quickSort(arr) {
  if (arr.length <= 1) return arr
  const pivot = arr[0]
  const left = arr.slice(1).filter(x => x <= pivot)
  const right = arr.slice(1).filter(x => x > pivot)
  return [...quickSort(left), pivot, ...quickSort(right)]
}
```

---

## 十、软技能 / 项目题

### Q：介绍一个你做过的有挑战的项目？
**答题框架（STAR）：**
- **S**ituation：项目背景
- **T**ask：你的职责
- **A**ction：具体做了什么（技术选型、难点攻克）
- **R**esult：成果（性能提升、用户增长等）

### Q：遇到过最难的 bug 是什么？怎么解决的？
- 描述问题现象
- 排查思路（缩小范围、断点调试、日志分析）
- 根因分析
- 解决方案
- 总结复盘

### Q：你有什么想问我们的？
好问题：
- 团队的技术栈和架构是怎样的？
- 项目的发布流程和 CI/CD？
- 团队规模和协作方式？
- 对这个岗位的期望是什么？

---

> 💡 **建议：** JS 基础 + Vue 原理是重中之重，小程序是你加分项。算法不用太深入，但手写题（防抖、深拷贝、EventEmitter）要能闭眼写出来。
>
> 📅 最后更新：2026-06-27

---

# 十一、底层原理深入（加分题）

---

## 11.1 var / let / const 的区别

> 📄 详细内容已拆分到独立文件：[interview-var-let-const.md](./interview-var-let-const.md)

---

## 11.2 Vuex 原理

> 📄 详细内容已拆分到独立文件：[interview-vuex.md](./interview-vuex.md)

---

## 11.3 TypeScript vs JavaScript

> 📄 详细内容已拆分到独立文件：[interview-ts-vs-js.md](./interview-ts-vs-js.md)

---

## 11.4 事件循环深入

**Q：`async/await` 和 `Promise` 在事件循环中的区别？**

```js
async function async1() {
  console.log('async1 start')
  await async2()
  console.log('async1 end')  // 这行相当于 Promise.then 的回调
}

async function async2() {
  console.log('async2')
}

console.log('script start')
async1()
console.log('script end')

// 输出：
// script start
// async1 start
// async2
// script end
// async1 end
```

**`await` 后面的代码等于放进了微任务队列。**

```js
// await async2() 等价于：
async2().then(() => {
  console.log('async1 end')
})
```

### 宏任务微任务面试终极题

```js
console.log('1')

setTimeout(() => {
  console.log('2')
  Promise.resolve().then(() => console.log('3'))
}, 0)

Promise.resolve().then(() => {
  console.log('4')
  setTimeout(() => console.log('5'), 0)
})

console.log('6')

// 输出：1, 6, 4, 2, 3, 5
```

解析：
1. 同步：`1`、`6`
2. 微任务：`4`（此时微任务队列清空）
3. 宏任务 setTimeout1：`2`，产生微任务 `3`
4. 清空微任务：`3`
5. 宏任务 setTimeout2：`5`

---

## 11.5 垃圾回收

**Q：JS 的垃圾回收机制？**

### 核心算法：标记-清除（Mark-Sweep）

```
1. 标记阶段：从根对象（window/global）出发，
   标记所有能访问到的对象
2. 清除阶段：没被标记的对象就是垃圾，回收内存
```

### V8 引擎的分代回收

```
新生代（Young Generation）— 小而新
├── Scavenge 算法：空间换时间
├── 对象存活时间短，频繁回收
└── 存活对象晋升到老生代

老生代（Old Generation）— 大而老
├── Mark-Sweep（标记清除）+ Mark-Compact（标记整理）
├── 增量标记（Incremental Marking）避免卡顿
└── 并发回收
```

### 内存泄漏的常见原因

```js
// 1. 闭包持有引用
function createHeavy() {
  const bigData = new Array(1000000).fill('*')
  return function() {
    // bigData 被闭包引用，无法回收
    console.log(bigData.length)
  }
}

// 2. 全局变量
function leak() {
  leaked = 'I leak to window'  // 没有 var/let/const
}

// 3. 未清理的定时器/事件监听
clearInterval(timer)
removeEventListener('click', handler)

// 4. DOM 引用
const elements = []
function addElement() {
  const div = document.createElement('div')
  document.body.appendChild(div)
  elements.push(div)  // 即使从 DOM 移除，数组仍持有引用
}

// 5. 未清理的 Map/WeakMap
// WeakMap 的 key 是弱引用，不阻止垃圾回收
const weak = new WeakMap()  // 推荐持有 DOM 引用
```

---

## 11.6 Proxy vs Object.defineProperty

**Q：为什么 Vue 3 用 Proxy 替换了 Object.defineProperty？深入说说两者的差异。**

```js
// Object.defineProperty 的局限
const obj = { a: 1, b: { c: 2 } }

// 1. 只能劫持已有属性
Object.defineProperty(obj, 'a', {
  get() { track('a'); return value },
  set(newVal) { value = newVal; trigger('a') }
})
obj.d = 4  // ❌ 新增属性无法检测 → Vue.set()

// 2. 必须递归遍历所有属性
// 初始化时就要遍历整个对象，嵌套深了性能差

// 3. 数组问题
// arr[0] = 'new' 无法检测
// arr.length = 0 无法检测
// Vue 2 只能重写 7 个数组方法来解决

// Proxy 的优势
const proxy = new Proxy(obj, {
  get(target, key, receiver) {
    track(target, key)
    // 惰性代理：只在访问时才递归代理嵌套对象
    const result = Reflect.get(target, key, receiver)
    if (typeof result === 'object' && result !== null) {
      return reactive(result)  // 按需代理
    }
    return result
  },
  set(target, key, value, receiver) {
    const result = Reflect.set(target, key, value, receiver)
    trigger(target, key)
    return result
  },
  deleteProperty(target, key) {
    const result = Reflect.deleteProperty(target, key)
    trigger(target, key)
    return result
  }
  // 还能拦截 has、ownKeys 等
})
```

**一句话总结：** `Object.defineProperty` 是「逐个属性劫持」，`Proxy` 是「整层代理拦截」。Proxy 更全面、更高效、更优雅。

---

## 11.7 模块化

**Q：CommonJS 和 ES Module 的区别？**

| | CommonJS | ES Module |
|---|---|---|
| 加载方式 | 运行时同步加载 | 编译时静态分析 |
| 值的关系 | 值的拷贝 | 值的引用（活绑定） |
| this | 当前模块 | undefined |
| 循环依赖 | 支持（部分导出） | 支持（活绑定） |
| 环境 | Node.js | 浏览器 + Node.js |
| 语法 | `require` / `module.exports` | `import` / `export` |

```js
// CommonJS — 值的拷贝
// a.js
let count = 0
module.exports = { count, increment() { count++ } }

// b.js
const a = require('./a')
a.count     // 0（拷贝的快照）
a.increment()
a.count     // 仍然是 0！

// ES Module — 值的引用（活绑定）
// a.mjs
export let count = 0
export function increment() { count++ }

// b.mjs
import { count, increment } from './a.mjs'
count       // 0
increment()
count       // 1！（活绑定，同步更新）
```

**为什么 ESM 能 Tree Shaking？**
因为 `import/export` 是静态语法，打包工具在编译时就能分析出哪些导出被用到、哪些没用到，可以安全删除无用代码。CommonJS 的 `require` 是运行时调用，无法静态分析。

---

## 11.8 浏览器渲染原理

**Q：从输入 URL 到页面显示，浏览器做了什么？**

```
1. URL 解析 → DNS 解析 → 获取 IP 地址
2. TCP 三次握手（HTTPS 还有 TLS 握手）
3. 发送 HTTP 请求
4. 服务器处理请求 → 返回响应
5. 浏览器解析：
   a. 解析 HTML → 构建 DOM 树
   b. 解析 CSS → 构建 CSSOM 树
   c. DOM + CSSOM → 渲染树（Render Tree）
   d. 布局（Layout/Reflow）：计算每个节点的位置和大小
   e. 绘制（Paint）：生成绘制记录
   f. 合成（Composite）：GPU 合成图层 → 显示
```

### 重排（Reflow）和重绘（Repaint）

```
重排（更严重）：
  元素尺寸/位置变化 → 重新计算布局
  触发：改变宽高、增删元素、窗口resize、读取 offset/scroll/client 等

重绘：
  外观变化但布局不变
  触发：改颜色、背景、visibility 等

优化：
  - 批量修改 DOM（DocumentFragment 或 display:none 后修改）
  - 避免频繁读取布局属性（强制同步布局）
  - 使用 transform/opacity 做动画（只触发合成，不重排）
  - will-change 提前告诉浏览器
```

---

## 11.9 深入 this 的面试题

**Q：以下代码输出什么？为什么？**

```js
var name = 'window'

const obj = {
  name: 'obj',
  getName() {
    return this.name
  },
  getName2: () => {
    return this.name
  }
}

console.log(obj.getName())      // 'obj'（隐式绑定）
console.log(obj.getName2())     // 'undefined'（箭头函数，this 是外层作用域的 this）
console.log(obj.getName.call({ name: 'call' }))  // 'call'（显式绑定）
console.log(obj.getName2.call({ name: 'call' })) // 'undefined'（箭头函数无法改变 this）

const getName = obj.getName
console.log(getName())          // 'window'（默认绑定，独立调用）
```

**核心原则：**
1. 箭头函数没有自己的 `this`，`call/apply/bind` 无法改变
2. 独立调用的普通函数 → `this` 指向 `window`（严格模式 `undefined`）
3. `call` 的优先级高于隐式绑定

---

## 11.10 Vue 2 的数组响应式

**Q：Vue 2 怎么实现数组的响应式？为什么不能用 defineProperty 监听数组索引？**

```js
// Vue 2 重写了 7 个数组方法
const arrayProto = Array.prototype
const arrayMethods = Object.create(arrayProto)

const methodsToPatch = [
  'push', 'pop', 'shift', 'unshift', 'splice', 'sort', 'reverse'
]

methodsToPatch.forEach(method => {
  const original = arrayProto[method]
  def(arrayMethods, method, function mutator(...args) {
    const result = original.apply(this, args)
    const ob = this.__ob__  // observe 实例

    // 新插入的元素也要变成响应式
    let inserted
    switch (method) {
      case 'push':
      case 'unshift':
        inserted = args; break
      case 'splice':
        inserted = args.slice(2); break
    }
    if (inserted) ob.observeArray(inserted)

    ob.dep.notify()  // 通知更新
    return result
  })
})
```

**为什么不用 `defineProperty` 监听索引？**
```js
// 性能问题：数组可能有成千上万个元素
// 为每个索引设置 getter/setter → 初始化时巨大的性能开销
// 而且数组长度变化频繁，defineProperty 无法监听 length 变化

// Vue 2 的选择：
// 重写 7 个变异方法，成本低、效果够用
// 用户直接 arr[0] = 'new' → 不触发 → 用 Vue.set 或 splice 替代
```

---

> 📅 底层原理部分最后更新：2026-06-27
