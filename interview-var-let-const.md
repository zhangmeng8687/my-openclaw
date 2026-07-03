# var / let / const 的区别

**Q：var、let、const 的区别？为什么有了 const 还需要 let？**

| | var | let | const |
|---|---|---|---|
| 作用域 | 函数作用域 | 块级作用域 | 块级作用域 |
| 变量提升 | ✅ 提升并初始化为 undefined | ✅ 提升但不初始化（暂时性死区 TDZ） | ✅ 提升但不初始化（TDZ） |
| 重复声明 | ✅ 允许 | ❌ 不允许 | ❌ 不允许 |
| 全局对象属性 | ✅ 挂到 window | ❌ 不挂 | ❌ 不挂 |
| 重新赋值 | ✅ | ✅ | ❌ |

---

## 暂时性死区（TDZ）

```js
console.log(a) // undefined（var 提升）
// console.log(b) // ReferenceError!（let 的 TDZ）
let b = 1
```

从 `let` 声明位置到块级作用域开始，这段区域叫 TDZ，在此期间访问会报错。

---

## const 的「不可变」是假的

```js
const obj = { name: '张三' }
obj.name = '李四'  // ✅ 可以！因为 obj 的引用没变
// obj = {}         // ❌ 不行，引用变了
```

`const` 保证的是**变量指向的内存地址不变**（基本类型值不变，引用类型引用不变），不是值不可变。

如果要真正不可变：`Object.freeze(obj)`（浅冻结）。

---

## 为什么需要 let？

var 的函数作用域在 `for` 循环中是经典坑：

```js
// var → 所有回调共享同一个 i
for (var i = 0; i < 3; i++) {
  setTimeout(() => console.log(i))  // 3, 3, 3
}

// let → 每次循环创建新的块级作用域
for (let i = 0; i < 3; i++) {
  setTimeout(() => console.log(i))  // 0, 1, 2
}
```

---

## 底层原理

**var 的变量提升：**
```
JS 引擎在编译阶段会把变量声明提升到作用域顶部
var a = 1 实际上分为两步：
  1. var a（声明，提升到顶部）
  2. a = 1（赋值，留在原地）
```

**let/const 的 TDZ：**
```
let/const 也会被提升，但不会初始化
从块开始到声明语句之间的区域就是 TDZ
引擎在这段区域访问该变量会直接报 ReferenceError
这是一个故意的设计，强制开发者先声明再使用
```

**块级作用域的实现：**
```
V8 引擎在进入块级作用域时，会为 let/const 创建一个新的词法环境（Lexical Environment）
块内声明的变量存在这个新环境中
块执行完毕后，这个环境被销毁，变量随之回收
这就是为什么 let/const 的变量只在块内有效
```
