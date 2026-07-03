# Vuex 原理

**Q：Vuex 的核心原理是什么？为什么修改 state 必须通过 mutation？**

---

## 核心：单一状态树 + 响应式

```js
// Vuex 初始化 state 的核心逻辑（简化）
function installModule(store, rootState, path, module) {
  // 1. 将 module 的 state 设置到父级 state 上
  if (path.length > 0) {
    const parentState = getNestedState(rootState, path.slice(0, -1))
    Vue.set(parentState, path[path.length - 1], module.state)
  }

  // 2. 注册 mutations、actions、getters 到 store
  module.forEachMutation((mutation, key) => {
    store._mutations[key] = store._mutations[key] || []
    store._mutations[key].push(payload => {
      mutation.call(store, module.state, payload)
    })
  })

  module.forEachAction((action, key) => {
    store._actions[key] = store._actions[key] || []
    store._actions[key].push(payload => {
      action.call(store, store, payload)
    })
  })

  // 3. getters 通过 defineProperty 变成 computed
  module.forEachGetter((getter, key) => {
    Object.defineProperty(store.getters, key, {
      get: () => getter(module.state)
    })
  })
}
```

---

## 为什么 state 是响应式的？

因为 Vuex 用 `new Vue({ data: { state } })` 创建了一个 Vue 实例来托管 state。利用 Vue 的响应式系统，state 变化自动通知所有依赖它的组件更新。

```js
// Vuex 构造函数中的关键代码
store._vm = new Vue({
  data: { $$state: state },
  computed: getters  // getters 变成 computed 属性
})
```

**底层原理：**
```
1. Vuex 创建一个隐藏的 Vue 实例（store._vm）
2. state 作为这个实例的 data（$$state）
3. Vue 的响应式系统会为 state 的每个属性创建 getter/setter
4. 组件通过 this.$store.state 访问时触发 getter → 收集依赖
5. commit mutation 修改 state 时触发 setter → 通知所有依赖组件更新
6. getters 作为 computed 属性，有缓存，依赖不变不重新计算
```

---

## 为什么必须通过 mutation 修改 state？

```js
// store.commit
commit(_type, _payload) {
  const { type, payload } = unifyObjectStyle(_type, _payload)
  const entry = this._mutations[type]
  entry.forEach(fn => fn(payload))
}
```

原因：
1. **可追踪**：所有 state 变化都经过 mutation，DevTools 可以记录每次变化的快照
2. **可调试**：时间旅行调试（回退到任意历史状态）
3. **可预测**：mutation 必须是同步的，保证状态变化的时序确定

---

## mutation 必须同步的原因

```js
mutations: {
  // ❌ 异步 mutation → DevTools 无法追踪状态变化时机
  SET_USER(state) {
    api.getUser().then(user => { state.user = user })
  }
}

actions: {
  // ✅ 异步放 action 里，完成后 commit mutation
  async fetchUser({ commit }) {
    const user = await api.getUser()
    commit('SET_USER', user)
  }
}
```

异步操作放 mutation 里 → DevTools 记录 mutation → 但此时 state 还没变 → 快照错乱 → 时间旅行失效。

**action 的本质：**
```
action 就是一个异步函数，内部通过 commit 触发 mutation
action 可以包含任意异步操作
action 完成后通过 commit 把结果同步写入 state
这样既支持异步，又保证了 state 变化的可追踪性
```

---

## Vuex 的 install 方法

```js
// Vuex 的 install 方法：把 store 注入到每个组件
export function install(_Vue) {
  Vue = _Vue
  applyMixin(Vue)
}

// applyMixin 就是在 beforeCreate 中混入 $store
function applyMixin(Vue) {
  Vue.mixin({
    beforeCreate() {
      const options = this.$options
      if (options.store) {
        this.$store = options.store
      } else if (options.parent && options.parent.$store) {
        this.$store = options.parent.$store
      }
    }
  })
}
```

这就是为什么 `this.$store` 在所有组件中都能访问——通过 `Vue.mixin` 全局混入。

**完整流程：**
```
1. Vue.use(Vuex) → 调用 Vuex.install
2. install 中用 Vue.mixin 在每个组件的 beforeCreate 中注入 $store
3. 根组件创建时传入 store 选项
4. 子组件通过 parent.$store 逐级传递
5. 所有组件最终共享同一个 store 实例
```

---

## Vuex 的核心概念关系

```
┌─────────────────────────────────────────────┐
│                  Store                       │
│                                              │
│  ┌─────────┐  commit  ┌──────────┐          │
│  │  State  │←────────│ Mutations│ (同步)    │
│  └────┬────┘         └──────────┘          │
│       │                                      │
│       │ computed                             │
│  ┌────▼────┐  dispatch ┌──────────┐         │
│  │ Getters │          │ Actions  │ (异步)   │
│  └─────────┘          └────┬─────┘         │
│                             │                │
│                      commit│                │
│                             ▼                │
│                        Mutations            │
└─────────────────────────────────────────────┘

组件读取 → this.$store.state / this.$store.getters
组件修改 → this.$store.commit('mutation', payload)  (同步)
         → this.$store.dispatch('action', payload)   (异步)
```
