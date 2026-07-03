# TypeScript vs JavaScript

**Q：TS 对比 JS 有什么优势？你怎么看待 TS？**

---

## TypeScript 的核心优势

### 1. 类型安全 — 编译期发现问题

```js
// JS：运行时才发现 bug
function add(a, b) { return a + b }
add('1', 2)  // '12'，没有报错！

// TS：编译时就报错
function add(a: number, b: number): number { return a + b }
add('1', 2)  // ❌ 类型错误
```

### 2. 更好的 IDE 支持

- 自动补全（知道对象有哪些属性）
- 跳转到定义
- 重构安全（改了接口，所有用到的地方都报错）
- 内联文档提示

### 3. 接口约束 — 团队协作更清晰

```ts
interface UserInfo {
  id: number
  name: string
  avatar?: string  // 可选
}

// 调用方和实现方有明确的契约
async function getUser(id: number): Promise<UserInfo> {
  return await api.get(`/user/${id}`)
}
```

### 4. 类型即文档

```ts
// 看类型就知道怎么用，不用翻文档
type Theme = 'light' | 'dark' | 'auto'
interface Config {
  theme: Theme
  fontSize: number
  lang: 'zh-CN' | 'en-US'
}
```

---

## TS 的劣势（诚实说）

1. **学习成本**：泛型、工具类型、条件类型等高级特性有门槛
2. **开发速度**：前期写类型定义确实多写代码
3. **小型项目可能过度**：几个页面的小项目加 TS 收益不高
4. **类型体操**：复杂类型定义可读性差
5. **生态兼容**：有些库没有 `@types` 声明

---

## 面试怎么回答

> "TypeScript 的核心价值是在**编译期**捕获类型错误，而不是等到用户在运行时报错。对于多人协作的中大型项目，TS 的接口约束和类型提示能显著降低沟通成本和维护成本。我个人没在生产项目中用过 TS，但理解它的价值，也在学习中。小程序的 `WXML` 本身就有一定的类型约束，迁移到 TS 的心智模型不算太远。"

---

## TS 常考知识点

### 接口 vs 类型别名

```ts
interface User { name: string }   // 可扩展、可合并
type ID = string | number          // 联合类型、交叉类型用 type

// interface 可以声明合并
interface User { age: number }     // 自动合并到上面的 User

// type 不可以重复声明
// type ID = boolean  // ❌ 报错
```

### 泛型

```ts
// 基本泛型
function identity<T>(arg: T): T { return arg }
const result = identity<string>('hello')  // 显式指定
const result2 = identity(42)              // 类型推断

// 泛型约束
interface HasLength { length: number }
function logLength<T extends HasLength>(arg: T): number {
  return arg.length
}
logLength('hello')    // ✅
logLength([1, 2, 3])  // ✅
// logLength(123)      // ❌ number 没有 length

// 泛型接口
interface ApiResponse<T> {
  code: number
  data: T
  message: string
}

// 使用
const res: ApiResponse<UserInfo> = await getUser(1)
res.data.name  // 自动补全
```

### 常用工具类型

```ts
Partial<T>     // 所有属性变可选
Required<T>    // 所有属性变必填
Pick<T, K>     // 取部分属性
Omit<T, K>     // 排除部分属性
Record<K, V>   // 键值对映射
Readonly<T>    // 所有属性只读

// 示例
interface User {
  id: number
  name: string
  email: string
  age: number
}

type UserPreview = Pick<User, 'id' | 'name'>
// { id: number; name: string }

type CreateUser = Omit<User, 'id'>
// { name: string; email: string; age: number }

type UpdateUser = Partial<User>
// { id?: number; name?: string; email?: string; age?: number }

type UserMap = Record<string, User>
// { [key: string]: User }
```

### 类型守卫

```ts
function isString(val: unknown): val is string {
  return typeof val === 'string'
}

function processValue(val: string | number) {
  if (isString(val)) {
    console.log(val.toUpperCase())  // TS 知道这里是 string
  } else {
    console.log(val.toFixed(2))     // TS 知道这里是 number
  }
}
```

### 枚举

```ts
enum Status {
  Pending = 'PENDING',
  Fulfilled = 'FULFILLED',
  Rejected = 'REJECTED'
}

// 使用
function handle(status: Status) {
  switch (status) {
    case Status.Pending: /* ... */ break
    case Status.Fulfilled: /* ... */ break
    case Status.Rejected: /* ... */ break
  }
}
```

---

## TS 在 Vue 项目中的应用

```ts
// Vue 3 + TS 的典型写法

// 1. 组件 props 类型
import { defineComponent, PropType } from 'vue'

interface User {
  id: number
  name: string
}

export default defineComponent({
  props: {
    user: {
      type: Object as PropType<User>,
      required: true
    }
  },
  setup(props) {
    console.log(props.user.name)  // 有类型提示
  }
})

// 2. ref 类型
const count = ref<number>(0)
const user = ref<User | null>(null)

// 3. reactive 类型
interface State {
  list: User[]
  loading: boolean
}
const state = reactive<State>({
  list: [],
  loading: false
})

// 4. 事件类型
const handleClick = (e: MouseEvent) => {
  console.log(e.clientX, e.clientY)
}
```

---

## TS 的编译原理

```
TS 源码 (.ts/.tsx)
    ↓
类型检查（编译期）
    ↓
去掉类型注解，生成纯 JS
    ↓
JS 输出 (.js/.jsx)
    ↓
浏览器/Node.js 执行（运行时）

关键点：
- TS 的类型只在编译时存在，运行时没有任何类型信息
- TS 不会改变 JS 的运行行为
- TS 编译器就是"更严格的 JS 语法检查器 + 类型推断引擎"
```
