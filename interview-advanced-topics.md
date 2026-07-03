# 鍓嶇闈㈣瘯棰?鈥?杩涢樁涓撻

> 涓婚鑹插垏鎹€佺紦瀛樼瓥鐣ャ€佹悳绱紭鍖栥€乮frame 閫氫俊銆佸紓甯告崟鑾?鈥?瀹為檯寮€鍙戜腑楂橀閬囧埌鐨勫満鏅銆?
---

## 涓€銆佷富棰樿壊鍒囨崲鐨勫疄鐜板師鐞?
### 1.1 CSS 鍙橀噺鏂规锛堜富娴佹帹鑽愶級

**Q锛氬浣曞疄鐜扮綉绔欎富棰樿壊鍒囨崲锛熷師鐞嗘槸浠€涔堬紵**

A锛氭牳蹇冩€濊矾鏄埄鐢?**CSS 鑷畾涔夊睘鎬э紙CSS Variables锛?* 鐨勫姩鎬佹€с€傚湪 `:root` 涓婂畾涔夐鑹插彉閲忥紝缁勪欢鍙紩鐢ㄥ彉閲忥紝鍒囨崲鏃跺彧闇€鏀瑰彉閲忓€硷紝鏁寸珯棰滆壊鑷姩鏇存柊銆?
```css
/* 瀹氫箟涓婚鍙橀噺 */
:root {
  --primary-color: #1890ff;
  --bg-color: #ffffff;
  --text-color: #333333;
  --border-color: #e8e8e8;
}

/* 鏆楄壊涓婚 */
[data-theme="dark"] {
  --primary-color: #177ddc;
  --bg-color: #141414;
  --text-color: #ffffffd9;
  --border-color: #303030;
}

/* 缁勪欢鍙敤鍙橀噺 */
.btn-primary {
  background: var(--primary-color);
  color: var(--text-color);
}
```

```js
// 鍒囨崲涓婚
function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme)
  localStorage.setItem('theme', theme) // 鎸佷箙鍖?}

// 鍒濆鍖栬鍙?const saved = localStorage.getItem('theme') || 'light'
setTheme(saved)
```

**鍘熺悊娣卞叆锛?*
- CSS 鍙橀噺鍏锋湁 **绾ц仈鎬?*锛屽瓙鍏冪礌鑷姩缁ф壙鐖跺厓绱犵殑鍙橀噺鍊?- 鏀瑰彉 `:root` 鎴栨煇涓鍏堝厓绱犵殑鍙橀噺锛屾墍鏈夊悗浠ｅ厓绱犵殑 `var()` 寮曠敤 **鑷姩閲嶆柊璁＄畻**
- 娴忚鍣ㄤ細瑙﹀彂 **鏍峰紡閲嶈绠楋紙style recalculation锛?*锛屼絾涓嶉渶瑕侀噸鏂板竷灞€锛坮eflow锛夛紝鎬ц兘寰堝ソ
- 姣斿垏鎹?class 鍐嶈鐩栦竴閬嶆牱寮忚绠€娲佸緱澶?
---

### 1.2 澶氬 CSS 鏂规锛堜紶缁熸柟妗堬級

```html
<!-- 鍔ㄦ€佸垏鎹?stylesheet -->
<link id="theme-link" rel="stylesheet" href="light.css" />
```

```js
function setTheme(theme) {
  document.getElementById('theme-link').href = `${theme}.css`
}
```

**缂虹偣锛?*
- 闇€瑕佺淮鎶ゅ濂楀畬鏁?CSS 鏂囦欢锛岃€﹀悎涓ラ噸
- 鍒囨崲鏃舵湁鐭殏闂儊锛團OUC锛?- 涓嶉€傚悎鍔ㄦ€佽嚜瀹氫箟锛堟瘮濡傜敤鎴疯嚜閫夐鑹诧級

---

### 1.3 CSS-in-JS 鏂规锛圧eact 鐢熸€侊級

```js
// styled-components 绀轰緥
const theme = {
  light: { primary: '#1890ff', bg: '#fff' },
  dark: { primary: '#177ddc', bg: '#141414' }
}

function App() {
  const [isDark, setIsDark] = useState(false)
  return (
    <ThemeProvider theme={isDark ? theme.dark : theme.light}>
      <Button />
    </ThemeProvider>
  )
}

// 缁勪欢涓娇鐢?const Button = styled.button`
  background: ${props => props.theme.primary};
`
```

---

### 1.4 浠绘剰棰滆壊鍒囨崲锛堥珮绾э級

鐢ㄦ埛鑷€夐鑹叉椂锛屽彲浠ョ敤 JS 鍔ㄦ€佽绠楀悓鑹茬郴鐨勬祬鑹?娣辫壊鍙樹綋锛?
```js
function setPrimaryColor(color) {
  const root = document.documentElement
  root.style.setProperty('--primary-color', color)
  // 鐢熸垚 hover/active 绛夊彉浣?  root.style.setProperty('--primary-color-hover', lighten(color, 0.1))
  root.style.setProperty('--primary-color-active', darken(color, 0.1))
  root.style.setProperty('--primary-color-bg', color + '1a') // 10% 閫忔槑搴?}
```

鎴栬€呬娇鐢?`color-mix()`锛堢幇浠ｆ祻瑙堝櫒锛夛細

```css
.btn:hover {
  background: color-mix(in srgb, var(--primary-color) 80%, white);
}
```

---

### 1.5 鏆楄壊妯″紡閫傞厤绯荤粺鍋忓ソ

```css
@media (prefers-color-scheme: dark) {
  :root {
    --bg-color: #141414;
    --text-color: #ffffffd9;
  }
}
```

```js
// 璺熼殢绯荤粺
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)')
prefersDark.addEventListener('change', (e) => {
  setTheme(e.matches ? 'dark' : 'light')
})
```

**鏈€浣冲疄璺碉細** 浼樺厛璇?localStorage 鈫?娌℃湁鍒欒窡闅忕郴缁熷亸濂姐€?
---

## 浜屻€佷笉鍚?Cache 鐨勫尯鍒?
### 2.1 缂撳瓨鍏ㄦ櫙鍥?
**Q锛氬墠绔秹鍙婄殑缂撳瓨鏈夊摢浜涳紵鍖哄埆鏄粈涔堬紵**

| 缂撳瓨绫诲瀷 | 浣嶇疆 | 浣滅敤 | 鐢熷懡鍛ㄦ湡 |
|---|---|---|---|
| 寮虹紦瀛?| 娴忚鍣ㄦ湰鍦?| 鐩存帴鐢ㄦ湰鍦板壇鏈紝涓嶅彂璇锋眰 | 鐢卞搷搴斿ご鎺у埗 |
| 鍗忓晢缂撳瓨 | 娴忚鍣?+ 鏈嶅姟鍣?| 鍙戣姹傞棶鏈嶅姟鍣ㄦ湁娌℃湁鏇存柊 | 鐢卞搷搴斿ご鎺у埗 |
| Service Worker Cache | 娴忚鍣?SW 绾跨▼ | 鎷︽埅璇锋眰锛岃嚜瀹氫箟缂撳瓨绛栫暐 | JS 鎺у埗 |
| Memory Cache | 鍐呭瓨 | 褰撳墠椤甸潰鐨勮祫婧愮紦瀛?| 椤甸潰鍏抽棴鍗冲け鏁?|
| Disk Cache | 纾佺洏 | 鎸佷箙鍖栫殑 HTTP 缂撳瓨 | 鐢?HTTP 澶存帶鍒?|
| Push Cache | HTTP/2 杩炴帴 | 鍗曟浼氳瘽鐨勬帹閫佽祫婧?| 杩炴帴鍏抽棴鍗冲け鏁?|
| Prefetch Cache | 娴忚鍣?| 棰勫彇璧勬簮鐨勭紦瀛?| 椤甸潰鐢熷懡鍛ㄦ湡 |

---

### 2.2 寮虹紦瀛橈紙涓嶅彂璇锋眰锛?
**Q锛氬己缂撳瓨鐨勫疄鐜版柟寮忥紵浼樺厛绾э紵**

鍝嶅簲澶达紙浜岄€変竴鎴栧苟瀛橈紝**Cache-Control 浼樺厛绾ф洿楂?*锛夛細

```
Cache-Control: max-age=31536000    # 鐩稿鏃堕棿锛岀
Expires: Thu, 01 Jan 2027 00:00:00 GMT  # 缁濆鏃堕棿锛圚TTP/1.0 閬楃暀锛?```

**Cache-Control 甯哥敤鎸囦护锛?*

| 鎸囦护 | 鍚箟 |
|---|---|
| `max-age=3600` | 鍝嶅簲鍦?3600 绉掑唴鏈夋晥 |
| `no-cache` | **涓嶆槸涓嶇紦瀛?*锛岃€屾槸姣忔浣跨敤鍓嶅繀椤诲幓鏈嶅姟鍣ㄩ獙璇?|
| `no-store` | 鐪熸鐨勪笉缂撳瓨锛屾瘡娆￠兘瀹屾暣璇锋眰 |
| `public` | 浠讳綍涓棿鑺傜偣锛圕DN銆佷唬鐞嗭級閮藉彲浠ョ紦瀛?|
| `private` | 鍙湁娴忚鍣ㄥ彲浠ョ紦瀛橈紝CDN 涓嶈 |
| `s-maxage=3600` | 瑕嗙洊 `max-age`锛屼粎瀵?CDN/浠ｇ悊鐢熸晥 |
| `immutable` | 璧勬簮姘歌繙涓嶅彉锛屾祻瑙堝櫒涓嶈鍙戦獙璇佽姹?|
| `stale-while-revalidate=60` | 杩囨湡鍚?60 绉掑唴鍙互鍏堢敤鏃х殑锛屽悓鏃跺悗鍙板埛鏂?|

**鍒ゆ柇娴佺▼锛?*
```
璇锋眰璧勬簮
  鈫?鏈夌紦瀛橈紵
    鈫?妫€鏌?Cache-Control / Expires
      鈫?鏈繃鏈燂紵 鈫?200 (from memory/disk cache)锛屼笉鍙戣姹?      鈫?宸茶繃鏈燂紵 鈫?杩涘叆鍗忓晢缂撳瓨
    鈫?鏃犵紦瀛?鈫?姝ｅ父璇锋眰
```

---

### 2.3 鍗忓晢缂撳瓨锛堝彂璇锋眰闂湇鍔″櫒锛?
**Q锛氬崗鍟嗙紦瀛樻€庝箞瀹炵幇锛烢Tag 鍜?Last-Modified 鐨勫尯鍒紵**

| | Last-Modified / If-Modified-Since | ETag / If-None-Match |
|---|---|---|
| 渚濇嵁 | 鏂囦欢鏈€鍚庝慨鏀规椂闂?| 鏂囦欢鍐呭鐨勫搱甯?鎸囩汗 |
| 绮惧害 | 绉掔骇 | 鍐呭绾?|
| 闂 | 1. 1 绉掑唴澶氭淇敼鏃犳硶璇嗗埆<br>2. 淇敼浜嗗張鏀瑰洖鏉ワ紝鏃堕棿鍙樹簡浣嗗唴瀹规病鍙?| 璁＄畻鍝堝笇鏈夊紑閿€ |
| 浼樺厛绾?| 浣?| **楂橈紙鍚屾椂瀛樺湪鏃朵紭鍏堢敤 ETag锛?* |

```
# 鍝嶅簲澶?ETag: "abc123"
Last-Modified: Wed, 10 Jun 2026 08:00:00 GMT

# 涓嬫璇锋眰甯︿笂
If-None-Match: "abc123"
If-Modified-Since: Wed, 10 Jun 2026 08:00:00 GMT

# 鏈嶅姟鍣ㄥ姣?鈫?娌″彉锛?04 Not Modified锛堜笉杩斿洖 body锛?鈫?鍙樹簡锛?00 + 鏂拌祫婧?```

---

### 2.4 Service Worker Cache

**Q锛歋ervice Worker 缂撳瓨鍜?HTTP 缂撳瓨鏈変粈涔堝尯鍒紵**

```js
// 瀹夎闃舵锛氶缂撳瓨鍏抽敭璧勬簮
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open('v1').then((cache) => {
      return cache.addAll(['/', '/style.css', '/app.js'])
    })
  )
})

// 鎷︽埅璇锋眰锛氳嚜瀹氫箟绛栫暐
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (cached) return cached
      return fetch(event.request).then((response) => {
        // 缂撳瓨鏂拌祫婧?        const clone = response.clone()
        caches.open('v1').then((cache) => cache.put(event.request, clone))
        return response
      })
    })
  )
})
```

**鍖哄埆锛?*

| | HTTP 缂撳瓨 | Service Worker Cache |
|---|---|---|
| 鎺у埗鏂?| 鏈嶅姟鍣ㄥ搷搴斿ご | 鍓嶇 JS 浠ｇ爜 |
| 绮掑害 | 鎸?URL | 鎸変换鎰忛€昏緫锛圲RL銆佽姹傚ご銆佹潯浠讹級 |
| 鐏垫椿鎬?| 鏈夐檺 | 瀹屽叏鑷畾涔?|
| 閫傜敤鍦烘櫙 | 闈欐€佽祫婧愮増鏈鐞?| 绂荤嚎搴旂敤銆佸鏉傜紦瀛樼瓥鐣?|

**甯歌 SW 缂撳瓨绛栫暐锛?*
- **Cache First**锛氬厛鏌ョ紦瀛橈紝娌℃湁鍐嶈姹傦紙閫傚悎闈欐€佽祫婧愶級
- **Network First**锛氬厛璇锋眰缃戠粶锛屽け璐ヤ簡鐢ㄧ紦瀛橈紙閫傚悎 API锛?- **Stale While Revalidate**锛氬厛杩斿洖缂撳瓨锛屽悓鏃跺悗鍙版洿鏂帮紙閫傚悎棰戠箒鏇存柊浣嗕笉绱ф€ョ殑璧勬簮锛?
---

### 2.5 Memory Cache vs Disk Cache

**Q锛氭祻瑙堝櫒浠€涔堟椂鍊欑敤鍐呭瓨缂撳瓨锛屼粈涔堟椂鍊欑敤纾佺洏缂撳瓨锛?*

| | Memory Cache | Disk Cache |
|---|---|---|
| 瀛樺偍浣嶇疆 | 鍐呭瓨 | 纾佺洏 |
| 閫熷害 | 鏋佸揩 | 杈冨揩 |
| 瀹归噺 | 灏?| 澶?|
| 鐢熷懡鍛ㄦ湡 | 椤甸潰鍏抽棴鍗冲け鏁?| 鎸佷箙鍖?|
| 鍏稿瀷璧勬簮 | 褰撳墠椤甸潰鐨勫浘鐗囥€佽剼鏈?| CSS銆佸瓧浣撱€佸ぇ鏂囦欢 |

娴忚鍣ㄧ殑鍐崇瓥閫昏緫锛圕hrome 涓轰緥锛夛細
- **澶ф枃浠?*锛堝鍥剧墖锛夆啋 浼樺厛 Disk Cache锛堜笉鍗犲唴瀛橈級
- **灏忔枃浠?*锛堝 JS/CSS锛夆啋 浼樺厛 Memory Cache
- **base64 鍥剧墖** 鈫?Memory Cache
- **鍒锋柊椤甸潰锛團5锛?* 鈫?璺宠繃寮虹紦瀛橈紝璧板崗鍟嗙紦瀛?- **寮哄埗鍒锋柊锛圕trl+F5锛?* 鈫?璺宠繃鎵€鏈夌紦瀛?
---

### 2.6 HTTP/2 Push Cache

```
# 鏈嶅姟绔帹閫?Link: </style.css>; rel=preload; as=style
```

- 浠呭湪 HTTP/2 杩炴帴瀛樻椿鏈熼棿瀛樺湪
- 浼樺厛绾т綆浜?Memory/Disk Cache
- 鍙褰撳墠椤甸潰浣跨敤锛屽叾浠栭〉闈笉鍏变韩
- 宸茶 Chrome 106+ 绉婚櫎鏀寔锛岄€愭笎琚?`103 Early Hints` 鍙栦唬

---

### 2.7 瀹炴垬锛氬墠绔紦瀛樻渶浣冲疄璺?
```js
// vite.config.js 鈥?甯?hash 鐨勬枃浠跺悕
export default {
  build: {
    rollupOptions: {
      output: {
        entryFileNames: 'assets/[name].[hash].js',
        chunkFileNames: 'assets/[name].[hash].js',
        assetFileNames: 'assets/[name].[hash].[ext]'
      }
    }
  }
}
```

```
# Nginx 閰嶇疆

# 甯?hash 鐨勯潤鎬佽祫婧愶細寮虹紦瀛?1 骞?location /assets/ {
    add_header Cache-Control "public, max-age=31536000, immutable";
}

# HTML锛氫笉缂撳瓨锛屾瘡娆￠兘鍗忓晢
location / {
    add_header Cache-Control "no-cache";
}
```

**鏍稿績鍘熷垯锛?*
- **HTML**锛歚no-cache`锛堟瘡娆￠獙璇侊紝淇濊瘉鑳芥嬁鍒版渶鏂扮殑璧勬簮寮曠敤锛?- **甯?hash 鐨?JS/CSS/鍥剧墖**锛歚max-age=31536000, immutable`锛堟枃浠跺悕鍙樹簡灏辨槸鏂拌祫婧愶級
- **API 鏁版嵁**锛氭牴鎹笟鍔￠渶姹傦紝鐢?SW 鎴栬嚜瀹氫箟缂撳瓨绛栫暐

---

## 涓夈€佹悳绱紭鍖?
### 3.1 闃叉姈锛圖ebounce锛?
**Q锛氭悳绱㈡杈撳叆鏃跺浣曚紭鍖栬姹傦紵**

鏈€鍩烘湰鐨勫仛娉曪細鐢ㄦ埛鍋滄杈撳叆涓€娈垫椂闂村悗鎵嶅彂璇锋眰銆?
```js
function debounce(fn, delay) {
  let timer = null
  return function (...args) {
    clearTimeout(timer)
    timer = setTimeout(() => fn.apply(this, args), delay)
  }
}

// 浣跨敤
const search = debounce(async (keyword) => {
  const res = await fetch(`/api/search?q=${keyword}`)
  // ...
}, 300)

input.addEventListener('input', (e) => search(e.target.value))
```

**Vue 缁勫悎寮?API锛?*

```js
import { ref, watch } from 'vue'

const keyword = ref('')
const results = ref([])

// watch + 闃叉姈
watch(keyword, (val) => {
  // 鍒╃敤 watch 鐨勭涓変釜鍙傛暟
})

// 鏇村ソ鐨勬柟寮忥細鐢?watchEffect + 闃叉姈灏佽
function useDebouncedRef(value, delay = 300) {
  const debounced = ref(value.value)
  let timer
  watch(value, (val) => {
    clearTimeout(timer)
    timer = setTimeout(() => { debounced.value = val }, delay)
  })
  return debounced
}
```

---

### 3.2 鑺傛祦锛圱hrottle锛?
閫傚悎楂橀瑙﹀彂浣嗛渶瑕佷繚璇佹墽琛岄鐜囩殑鍦烘櫙锛堝婊氬姩鍔犺浇锛夛細

```js
function throttle(fn, interval) {
  let last = 0
  return function (...args) {
    const now = Date.now()
    if (now - last >= interval) {
      last = now
      fn.apply(this, args)
    }
  }
}
```

**闃叉姈 vs 鑺傛祦锛?*

| | 闃叉姈 | 鑺傛祦 |
|---|---|---|
| 瑙﹀彂鏃舵満 | 鍋滄鎿嶄綔鍚?delay ms | 姣?interval ms 鏈€澶氭墽琛屼竴娆?|
| 閫傜敤鍦烘櫙 | 鎼滅储妗嗐€佺獥鍙?resize | 婊氬姩浜嬩欢銆佹寜閽槻閲嶅鐐瑰嚮 |
| 鏁堟灉 | 鏈€鍚庝竴娆℃墠鎵ц | 鍥哄畾棰戠巼鎵ц |

---

### 3.3 AbortController 鍙栨秷杩囨湡璇锋眰

**Q锛氱敤鎴峰揩閫熻緭鍏ユ椂锛屽浣曚繚璇佸彧鏈夋渶鍚庝竴娆¤姹傜殑缁撴灉琚娇鐢紵**

```js
let controller = null

async function search(keyword) {
  // 鍙栨秷涓婁竴娆¤姹?  if (controller) controller.abort()
  controller = new AbortController()

  try {
    const res = await fetch(`/api/search?q=${keyword}`, {
      signal: controller.signal
    })
    const data = await res.json()
    return data
  } catch (err) {
    if (err.name === 'AbortError') {
      // 璇锋眰琚彇娑堬紝蹇界暐
      return
    }
    throw err
  }
}
```

**Vue 瀹屾暣绀轰緥锛?*

```js
const results = ref([])
const loading = ref(false)
let controller = null

async function doSearch(keyword) {
  if (!keyword.trim()) {
    results.value = []
    return
  }

  if (controller) controller.abort()
  controller = new AbortController()
  loading.value = true

  try {
    const res = await fetch(`/api/search?q=${encodeURIComponent(keyword)}`, {
      signal: controller.signal
    })
    const data = await res.json()
    results.value = data.list
  } catch (err) {
    if (err.name !== 'AbortError') console.error(err)
  } finally {
    loading.value = false
  }
}
```

---

### 3.4 鎼滅储缁撴灉缂撳瓨

**Q锛氱浉鍚屽叧閿瘝閲嶅鎼滅储鏃讹紝濡備綍閬垮厤閲嶅璇锋眰锛?*

```js
const cache = new Map()
const CACHE_MAX = 50 // 鏈€澶氱紦瀛?50 鏉?
async function searchWithCache(keyword) {
  if (cache.has(keyword)) {
    return cache.get(keyword)
  }

  const data = await fetch(`/api/search?q=${keyword}`).then(r => r.json())

  // LRU锛氳秴杩囦笂闄愬垹鏈€鏃╃殑
  if (cache.size >= CACHE_MAX) {
    const firstKey = cache.keys().next().value
    cache.delete(firstKey)
  }

  cache.set(keyword, data)
  return data
}
```

---

### 3.5 鍓嶇鎼滅储浼樺寲锛堟湰鍦版暟鎹級

褰撴暟鎹噺涓嶅ぇ锛堝嚑鐧惧埌鍑犲崈鏉★級鏃讹紝鍙互鍏ㄩ噺鍔犺浇鍚庢湰鍦版悳绱細

```js
// 1. 绠€鍗曡繃婊?const results = list.filter(item =>
  item.name.toLowerCase().includes(keyword.toLowerCase())
)

// 2. 鎷奸煶鎼滅储锛堜腑鏂囧満鏅級
import { pinyin } from 'pinyin-pro'

function matchPinyin(text, keyword) {
  const py = pinyin(text, { toneType: 'none' }).replace(/\s/g, '')
  return py.includes(keyword.toLowerCase()) ||
         text.toLowerCase().includes(keyword.toLowerCase())
}

// 3. 楂樹寒鍏抽敭璇?function highlight(text, keyword) {
  if (!keyword) return text
  const regex = new RegExp(`(${keyword})`, 'gi')
  return text.replace(regex, '<mark>$1</mark>')
}
```

---

### 3.6 铏氭嫙鍒楄〃锛堟悳绱㈢粨鏋滆繃澶氾級

褰撴悳绱㈢粨鏋滃彲鑳芥湁鎴愬崈涓婁竾鏉℃椂锛岀敤铏氭嫙鍒楄〃鍙覆鏌撳彲瑙佸尯鍩燂細

```vue
<!-- 浣跨敤 vue-virtual-scroller 绛夊簱 -->
<RecycleScroller
  :items="results"
  :item-size="50"
  key-field="id"
  v-slot="{ item }"
>
  <div class="search-result-item">{{ item.name }}</div>
</RecycleScroller>
```

---

### 3.7 鎼滅储浼樺寲鍏ㄦ櫙鎬荤粨

```
鐢ㄦ埛杈撳叆
  鈹?  鈹溾攢 闃叉姈锛?00ms锛夆攢鈹€鈫?閬垮厤姣忔鎸夐敭閮借姹?  鈹?  鈹溾攢 AbortController 鈹€鈹€鈫?鍙栨秷杩囨湡璇锋眰锛岄伩鍏嶇珵鎬?  鈹?  鈹溾攢 缂撳瓨锛圡ap/LRU锛夆攢鈹€鈫?鐩稿悓鍏抽敭璇嶄笉閲嶅璇锋眰
  鈹?  鈹溾攢 杈撳叆涓虹┖鏃舵竻绌?鈹€鈹€鈫?涓嶅彂鏃犳剰涔夎姹?  鈹?  鈹溾攢 loading 鐘舵€?鈹€鈹€鈫?闃叉閲嶅鎻愪氦
  鈹?  鈹斺攢 铏氭嫙鍒楄〃 鈹€鈹€鈫?澶ч噺缁撴灉鏃朵笉鍗￠〉闈?```

---

## 鍥涖€乮frame 宓屽叆涓庨€氫俊

### 4.1 鍩烘湰鐢ㄦ硶

**Q锛歩frame 濡備綍涓庣埗椤甸潰閫氫俊锛熸湁鍝簺鏂瑰紡锛?*

```html
<!-- 鐖堕〉闈?-->
<iframe id="myFrame" src="https://child.com/page" />
```

---

### 4.2 postMessage锛堟爣鍑嗘柟寮忥級

**Q锛歱ostMessage 鐨勫師鐞嗗拰娉ㄦ剰浜嬮」锛?*

**鐖堕〉闈㈠彂娑堟伅缁?iframe锛?*

```js
const iframe = document.getElementById('myFrame')

// 绛?iframe 鍔犺浇瀹?iframe.onload = () => {
  iframe.contentWindow.postMessage(
    { type: 'SET_USER', data: { name: '寮犳€?, role: 'admin' } },
    'https://child.com'  // 鐩爣 origin锛屽繀椤绘寚瀹氾紒
  )
}

// 鐩戝惉 iframe 鐨勫洖澶?window.addEventListener('message', (event) => {
  // 鈿狅笍 瀹夊叏妫€鏌ワ細蹇呴』楠岃瘉鏉ユ簮
  if (event.origin !== 'https://child.com') return

  console.log('鏀跺埌 iframe 娑堟伅:', event.data)
})
```

**iframe 鍐呮帴鏀跺拰鍥炲锛?*

```js
// iframe 鍐?window.addEventListener('message', (event) => {
  // 鈿狅笍 瀹夊叏妫€鏌?  if (event.origin !== 'https://parent.com') return

  const { type, data } = event.data

  switch (type) {
    case 'SET_USER':
      setUser(data)
      break
    case 'SET_THEME':
      applyTheme(data.theme)
      break
  }

  // 鍥炲鐖堕〉闈?  event.source.postMessage(
    { type: 'USER_SET', success: true },
    event.origin
  )
})
```

---

### 4.3 postMessage 灏佽

```js
// 灏佽涓€涓?Promise 鐗堢殑 postMessage
function postMessageAsync(target, message, targetOrigin, timeout = 5000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error('postMessage timeout'))
      window.removeEventListener('message', handler)
    }, timeout)

    function handler(event) {
      if (event.origin !== targetOrigin) return
      if (event.data?.id !== message.id) return // 鍖归厤璇锋眰

      clearTimeout(timer)
      window.removeEventListener('message', handler)
      resolve(event.data)
    }

    window.addEventListener('message', handler)
    target.postMessage(message, targetOrigin)
  })
}

// 浣跨敤
const reply = await postMessageAsync(
  iframe.contentWindow,
  { id: 'req-1', type: 'GET_DATA', params: {} },
  'https://child.com'
)
```

---

### 4.4 URL 鍙傛暟閫氫俊锛堢畝鍗曞満鏅級

```js
// 鐖堕〉闈細閫氳繃 URL 浼犲弬
const iframe = document.getElementById('myFrame')
iframe.src = `https://child.com/page?theme=dark&lang=zh&token=xxx`

// iframe 鍐呰鍙?const params = new URLSearchParams(window.location.search)
const theme = params.get('theme') // 'dark'
```

**閫傜敤鍦烘櫙锛?* 鍒濆鍖栭厤缃€佺畝鍗曟暟鎹紶閫掋€?**缂虹偣锛?* 鍗曞悜銆乁RL 闀垮害鏈夐檺銆佹晱鎰熸暟鎹笉瀹夊叏銆?
---

### 4.5 璺ㄥ煙 cookie 鍏变韩

**Q锛歩frame 涓浣曞叡浜櫥褰曠姸鎬侊紵**

```html
<!-- 鐖堕〉闈㈣缃?cookie 鏃跺姞涓?SameSite=None; Secure -->
<!-- 浠呭湪 HTTPS 涓嬬敓鏁?-->
Set-Cookie: token=xxx; SameSite=None; Secure; Domain=.example.com
```

```js
// iframe 璇锋眰鏃跺甫涓?cookie
fetch('https://api.example.com/data', {
  credentials: 'include'  // 鎼哄甫 cookie
})
```

**娉ㄦ剰锛?* Chrome 80+ 榛樿 `SameSite=Lax`锛岃法绔?iframe 璇锋眰涓嶅甫 cookie锛屽繀椤绘樉寮忚缃?`SameSite=None; Secure`銆?
---

### 4.6 iframe 鑷€傚簲楂樺害

**Q锛歩frame 濡備綍鏍规嵁鍐呭鑷€傚簲楂樺害锛?*

```js
// iframe 鍐呴儴
function reportHeight() {
  const height = document.documentElement.scrollHeight
  window.parent.postMessage(
    { type: 'RESIZE', height },
    'https://parent.com'
  )
}

// 鍐呭鍙樺寲鏃舵姤鍛?const observer = new ResizeObserver(reportHeight)
observer.observe(document.body)

// 鍒濆鎶ュ憡
window.addEventListener('load', reportHeight)
```

```js
// 鐖堕〉闈㈡帴鏀?window.addEventListener('message', (event) => {
  if (event.origin !== 'https://child.com') return
  if (event.data.type === 'RESIZE') {
    iframe.style.height = event.data.height + 'px'
  }
})
```

---

### 4.7 iframe 娌欑瀹夊叏

**Q锛氬浣曢槻姝?iframe 涓殑鎭舵剰浠ｇ爜锛?*

```html
<!-- sandbox 灞炴€ч檺鍒?iframe 鑳藉姏 -->
<iframe
  sandbox="allow-scripts allow-same-origin allow-forms"
  src="https://untrusted.com"
/>
```

| sandbox 鍊?| 鍏佽鐨勮兘鍔?|
|---|---|
| `allow-scripts` | 杩愯 JS |
| `allow-same-origin` | 浣跨敤鑷繁鐨?origin锛堜笉鍔犲垯瑙嗕负璺ㄥ煙锛?|
| `allow-forms` | 鎻愪氦琛ㄥ崟 |
| `allow-popups` | 寮瑰嚭鏂扮獥鍙?|
| `allow-modals` | 寮瑰嚭 alert/confirm |
| `allow-top-navigation` | 璺宠浆鐖堕〉闈?|

**涓嶅姞浠讳綍鍊?= 鏈€涓ユ牸闄愬埗**锛堢姝竴鍒囪剼鏈€佽〃鍗曘€佸脊绐楃瓑锛夈€?
---

### 4.8 瀹炴垬锛氬井鍓嶇 iframe 閫氫俊鍗忚

```js
// 瀹氫箟閫氫俊鍗忚
const MessageTypes = {
  // 鐖?鈫?瀛?  SET_USER: 'app:set-user',
  SET_THEME: 'app:set-theme',
  NAVIGATE: 'app:navigate',
  // 瀛?鈫?鐖?  READY: 'app:ready',
  LOGOUT: 'app:logout',
  RESIZE: 'app:resize',
  ROUTE_CHANGE: 'app:route-change'
}

// 鐖堕〉闈㈠皝瑁?class IframeBridge {
  constructor(iframe, childOrigin) {
    this.iframe = iframe
    this.childOrigin = childOrigin
    this.handlers = new Map()

    window.addEventListener('message', this._onMessage.bind(this))
  }

  send(type, data) {
    this.iframe.contentWindow.postMessage(
      { type, data, id: crypto.randomUUID() },
      this.childOrigin
    )
  }

  on(type, handler) {
    if (!this.handlers.has(type)) {
      this.handlers.set(type, [])
    }
    this.handlers.get(type).push(handler)
  }

  _onMessage(event) {
    if (event.origin !== this.childOrigin) return
    const { type, data } = event.data
    const handlers = this.handlers.get(type) || []
    handlers.forEach(fn => fn(data))
  }

  destroy() {
    window.removeEventListener('message', this._onMessage)
    this.handlers.clear()
  }
}

// 浣跨敤
const bridge = new IframeBridge(
  document.getElementById('app-frame'),
  'https://child.com'
)

bridge.on(MessageTypes.READY, () => {
  const user = JSON.parse(localStorage.getItem('user'))
  bridge.send(MessageTypes.SET_USER, user)
  bridge.send(MessageTypes.SET_THEME, localStorage.getItem('theme'))
})

bridge.on(MessageTypes.RESIZE, ({ height }) => {
  iframe.style.height = height + 'px'
})

bridge.on(MessageTypes.LOGOUT, () => {
  localStorage.clear()
  window.location.href = '/login'
})
```

---

### 4.9 閫氫俊鏂瑰紡瀵规瘮

| 鏂瑰紡 | 璺ㄥ煙 | 鏂瑰悜 | 鏁版嵁閲?| 瀹夊叏鎬?| 閫傜敤鍦烘櫙 |
|---|---|---|---|---|---|
| postMessage | 鉁?| 鍙屽悜 | 澶?| 闇€楠岃瘉 origin | 閫氱敤锛屾帹鑽?|
| URL 鍙傛暟 | 鉁?| 鍗曞悜 | 灏?| 浣?| 鍒濆鍖栭厤缃?|
| Cookie | 鉁?| 鍙屽悜 | 灏?| 闇€ HTTPS | 鐧诲綍鎬佸叡浜?|
| window.name | 鉁?| 瀛愨啋鐖?| 澶?| 浣?| 鍏煎鎬ф柟妗堬紙涓嶆帹鑽愶級 |
| URL hash | 鉁?| 鐖垛啋瀛?| 灏?| 浣?| 绠€鍗曠姸鎬?|
| BroadcastChannel | 鉁?| 鍙屽悜 | 澶?| 闇€鍚屾簮绛栫暐 | 鍚岀珯澶?tab 閫氫俊 |

---


## 五、不同 catch 的区别

### 5.1 try/catch

**Q：try/catch 能捕获哪些错误？不能捕获哪些？**

```js
try {
  // 可能出错的代码
  const data = JSON.parse(invalidJSON)
  undefinedFunction()
} catch (err) {
  console.error(err.message)  // 错误信息
  console.error(err.name)      // 错误类型：SyntaxError, ReferenceError 等
  console.error(err.stack)     // 调用栈
} finally {
  // 无论是否出错都会执行
  // 适合做清理工作：关闭连接、隐藏 loading 等
}
```

**能捕获的（同步错误）：**
- `SyntaxError`（JSON.parse 失败等）
- `ReferenceError`（未定义的变量）
- `TypeError`（调用 null 的方法等）
- `RangeError`（递归爆栈等）
- 手动 `throw` 的任意值

**不能捕获的：**
- **异步错误**（setTimeout/Promise 回调里的错误）
- **语法错误**（代码写错了，解析阶段就挂了）
- **事件处理器**里的错误

```js
// ❌ try/catch 捕获不到异步错误
try {
  setTimeout(() => {
    undefinedFunction()  // 这个错误不会被外层 catch 捕获
  }, 100)
} catch (err) {
  // 不会执行！
}

// ✅ 要在异步内部自己 catch
setTimeout(() => {
  try {
    undefinedFunction()
  } catch (err) {
    // 这里才能捕获
  }
}, 100)
```

---

### 5.2 Promise.prototype.catch()

**Q：Promise 的 .catch() 能捕获什么？和 try/catch 有什么区别？**

```js
fetch('/api/data')
  .then(res => res.json())
  .then(data => processData(data))
  .catch(err => {
    // 捕获整个链中任何一个环节的错误
    console.error('请求失败:', err)
  })
```

**.catch() 能捕获的：**
- `reject()` 抛出的错误
- `.then()` 回调里 `throw` 的错误
- `.then()` 回调里同步代码的运行时错误
- `.then()` 回调里返回的 rejected Promise

```js
Promise.resolve()
  .then(() => {
    throw new Error('then 里的错误')  // 会被 catch 捕获
  })
  .catch(err => {
    console.log(err.message)  // 'then 里的错误'
  })
```

---

### 5.3 async/await + try/catch

**Q：async/await 的错误处理有什么坑？**

```js
// ✅ 基本用法
async function fetchData() {
  try {
    const res = await fetch('/api/data')
    const data = await res.json()
    return data
  } catch (err) {
    // 能捕获 fetch 失败、JSON 解析失败等
    console.error(err)
  } finally {
    hideLoading()
  }
}

// ✅ 也可以用 .catch()（不推荐混用）
async function fetchData() {
  const data = await fetch('/api/data')
    .then(r => r.json())
    .catch(err => {
      console.error(err)
      return null  // 返回兜底值
    })
  return data
}
```

**常见坑：**

```js
// ❌ 坑 1：忘记 await
async function bad() {
  try {
    fetch('/api/data')  // 忘了 await，错误不会被 catch 捕获
  } catch (err) {
    // 永远不会执行！
  }
}

// ❌ 坑 2：forEach 里的 async 不会被 await
async function bad2() {
  const urls = ['/api/1', '/api/2', '/api/3']
  try {
    urls.forEach(async (url) => {
      await fetch(url)  // forEach 不会等待 async 回调
    })
  } catch (err) {
    // 捕获不到！
  }
}

// ✅ 正确做法：用 Promise.all 或 for...of
async function good() {
  const urls = ['/api/1', '/api/2', '/api/3']
  try {
    await Promise.all(urls.map(url => fetch(url)))
  } catch (err) {
    // 能捕获
  }
}
```

---

### 5.4 全局错误捕获

**Q：如何捕获未处理的 Promise 错误和全局错误？**

```js
// 1. 捕获未处理的 Promise rejection（最重要！）
window.addEventListener('unhandledrejection', (event) => {
  console.error('未处理的 Promise 错误:', event.reason)
  event.preventDefault()  // 阻止默认行为（控制台报错）
  // 上报到监控系统
  reportError(event.reason)
})

// 2. 捕获全局同步错误
window.addEventListener('error', (event) => {
  console.error('全局错误:', event.message, event.filename, event.lineno)
  reportError(event)
})

// 3. 捕获资源加载错误（图片、脚本等）
window.addEventListener('error', (event) => {
  if (event.target.tagName) {
    console.error('资源加载失败:', event.target.src || event.target.href)
  }
}, true)  // 注意：要用捕获阶段！

// 4. Node.js 环境
process.on('unhandledRejection', (reason) => {
  console.error('未处理的 rejection:', reason)
})
process.on('uncaughtException', (err) => {
  console.error('未捕获的异常:', err)
})
```

---

### 5.5 catch 的执行顺序

**Q：.catch() 放在不同位置有什么区别？**

```js
// 情况 1：catch 在链尾
promise
  .then(step1)
  .then(step2)
  .catch(handleError)  // 捕获 step1、step2 的错误

// 情况 2：catch 在中间
promise
  .then(step1)
  .catch(handleError)  // 只捕获 step1 的错误
  .then(step2)         // step2 继续执行，且收到 undefined（catch 没有返回值）

// 情况 3：多个 catch
promise
  .then(step1)
  .catch(handleStep1Error)  // 捕获 step1 错误
  .then(step2)
  .catch(handleStep2Error)  // 捕获 step2 错误（包括 handleStep1Error 抛出的）
```

```js
// 关键：.catch() 返回的 Promise 是 resolved 状态（除非 catch 里又 throw）
Promise.reject('error')
  .catch(err => {
    console.log(err)       // 'error'
    return 'fallback'      // 这个值会传给下一个 .then()
  })
  .then(val => {
    console.log(val)       // 'fallback'，链没有断！
  })

// 如果 catch 里又 throw，链会继续 reject
Promise.reject('error')
  .catch(err => {
    throw new Error('处理失败')  // 重新抛出
  })
  .then(val => {
    // 不会执行
  })
  .catch(err => {
    console.log(err.message)  // '处理失败'
  })
```

---

### 5.6 Error 对象的类型

**Q：JavaScript 有哪些内置错误类型？**

```js
try {
  // ...
} catch (err) {
  if (err instanceof TypeError) {
    // 类型错误：null.xxx、undefined is not a function
  } else if (err instanceof ReferenceError) {
    // 引用错误：未定义的变量
  } else if (err instanceof SyntaxError) {
    // 语法错误：JSON.parse 失败、eval 失败
  } else if (err instanceof RangeError) {
    // 范围错误：递归爆栈、数组长度负数
  } else if (err instanceof URIError) {
    // URI 错误：encodeURI/decodeURI 参数非法
  } else if (err instanceof EvalError) {
    // eval 相关错误
  } else if (err instanceof AggregateError) {
    // Promise.allSettled/any 的多个错误
    console.log(err.errors)  // 错误数组
  }
}

// 自定义错误类
class AppError extends Error {
  constructor(message, code, data) {
    super(message)
    this.name = 'AppError'
    this.code = code
    this.data = data
  }
}

throw new AppError('用户不存在', 404, { userId: 123 })
```

---

### 5.7 各 catch 方式对比总结

| 方式 | 捕获范围 | 适用场景 | 注意事项 |
|---|---|---|---|
| `try/catch` | 同步代码 + `await` 后的异步 | async/await、JSON.parse 等 | 捕获不到普通异步回调 |
| `.catch()` | Promise 链中的错误 | Promise 链式调用 | 返回 resolved Promise（除非重新 throw） |
| `window.onerror` | 全局同步运行时错误 | 错误监控上报 | 不能捕获 Promise 错误 |
| `unhandledrejection` | 未处理的 Promise rejection | 全局兜底、错误监控 | **必须加！** 否则错误会被吞掉 |
| `addEventListener('error', ..., true)` | 资源加载失败 | 图片/脚本/CSS 加载失败 | 需要用捕获阶段 |
| `React/Vue errorHandler` | 框架组件内的错误 | 组件级错误边界 | 不影响其他组件 |

---

### 5.8 实战：统一错误处理封装

```js
// 统一的请求封装，自带错误处理
async function request(url, options = {}) {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), options.timeout || 10000)

  try {
    const res = await fetch(url, {
      ...options,
      signal: controller.signal
    })

    if (!res.ok) {
      throw new AppError(HTTP ${res.status}, res.status)
    }

    const data = await res.json()

    if (data.code !== 0) {
      throw new AppError(data.message, data.code)
    }

    return data
  } catch (err) {
    if (err.name === 'AbortError') {
      console.warn('请求超时:', url)
    } else if (err instanceof AppError) {
      // 业务错误，可以给用户提示
      showToast(err.message)
    } else {
      // 网络错误等
      showToast('网络异常，请稍后重试')
    }
    throw err  // 继续抛出，让调用方也能处理
  } finally {
    clearTimeout(timeout)
  }
}

// 使用
try {
  const data = await request('/api/user')
} catch (err) {
  // 已经在 request 内部处理了提示，这里可以做额外逻辑
  if (err.code === 401) {
    router.push('/login')
  }
}
```
