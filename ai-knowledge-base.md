# AI 知识库 — 前端开发者视角

> 面向有技术背景但非 AI 专业的开发者，覆盖 AI 原理、大模型、Agent、Prompt 工程、RAG、MCP 等核心概念，兼顾面试和实际应用。

---

## 一、AI 基础概念

### 1.1 人工智能、机器学习、深度学习的关系

```
人工智能 (AI)
  └── 机器学习 (ML)
        └── 深度学习 (DL)
              └── 大语言模型 (LLM)
                    └── Agent
```

- **人工智能**：让机器模拟人类智能的总称（包括规则系统、专家系统等）
- **机器学习**：AI 的一个分支，让机器从数据中自动学习规律，而不是人工编写规则
- **深度学习**：机器学习的子集，使用多层神经网络处理复杂数据
- **大语言模型**：深度学习的产物，用海量文本训练出的语言理解和生成能力

---

### 1.2 机器学习的三种范式

**1. 监督学习（Supervised Learning）**

```
输入：带标签的数据（图片 + "猫"/"狗"）
输出：分类或预测模型
例子：垃圾邮件分类、图像识别、房价预测
```

**2. 无监督学习（Unsupervised Learning）**

```
输入：没有标签的数据
输出：数据的聚类、降维、关联规则
例子：用户分群、异常检测、推荐系统
```

**3. 强化学习（Reinforcement Learning）**

```
输入：环境状态 + 奖励信号
输出：最优策略（在什么状态下做什么动作）
例子：游戏 AI、机器人控制、RLHF（人类反馈强化学习）
```

---

### 1.3 神经网络基础

**Q：什么是神经网络？和传统编程有什么区别？**

```
传统编程：人类写规则 → 机器执行
  if (邮件包含"免费" && 包含"点击") → 垃圾邮件

机器学习：人类给数据 → 机器学规则
  输入：10万封邮件（标注了垃圾/正常）
  输出：自动学到的分类规则

神经网络：模仿人脑的计算结构
  输入层 → 隐藏层（多层） → 输出层
  每层由大量"神经元"组成
  每个神经元：输入 × 权重 + 偏置 → 激活函数 → 输出
```

**关键概念：**

- **权重（Weight）**：每个连接的重要性，训练就是调整权重
- **偏置（Bias）**：调整神经元的激活阈值
- **激活函数**：引入非线性（ReLU、Sigmoid、Tanh）
- **反向传播**：计算损失函数的梯度，从输出层向输入层逐层更新权重
- **损失函数**：衡量预测值和真实值的差距（均方误差、交叉熵等）
- **学习率**：每次更新权重的步长，太大震荡，太小收敛慢

---

## 二、大语言模型（LLM）

### 2.1 什么是大语言模型

**Q：什么是大语言模型？它是怎么工作的？**

大语言模型（Large Language Model）是一种基于 Transformer 架构的深度学习模型，通过在海量文本数据上训练，学会了语言的统计规律，能够理解和生成自然语言。

**核心能力：**

- 给定一段文本，预测下一个最可能的词（token）
- 逐词生成，直到完成整个回答

```
输入："今天天气"
模型内部计算 → 概率分布：
  "真" → 0.35
  "很" → 0.28
  "不" → 0.15
  "挺" → 0.08
  ...
选择"真" → "今天天气真"
继续预测 → "今天天气真好"
```

**"大"体现在哪？**

- 参数量大：GPT-3 有 1750 亿参数，GPT-4 估计万亿级
- 训练数据大：数万亿 token 的文本（书籍、网页、代码等）
- 计算资源大：数千张 GPU 训练数周到数月

---

### 2.2 Transformer 架构

**Q：Transformer 是什么？为什么它改变了 AI？**

Transformer 是 2017 年 Google 论文《Attention Is All You Need》提出的架构，是当前几乎所有大模型的基础。

**核心创新：自注意力机制（Self-Attention）**

```
传统 RNN/LSTM 的问题：
  - 逐词处理，无法并行 → 训练慢
  - 长文本会遗忘前面的信息

Transformer 的解决方案：
  - 自注意力：每个词都能直接"看到"其他所有词
  - 并行计算：所有词同时处理 → 训练快
  - 位置编码：补充词序信息
```

**自注意力机制简化理解：**

```
句子："猫坐在垫子上，因为它是软的"

"它"指的是什么？
自注意力会计算"它"和每个词的"关联度"：
  "猫"  → 0.6
  "垫子" → 0.3
  "坐"  → 0.05
  "软"  → 0.05

模型通过大量训练学会了"它"最可能指"猫"
```

**Transformer 的结构：**

```
输入文本
  ↓
Token 化（分词）
  ↓
词嵌入（每个 token 变成向量）+ 位置编码
  ↓
┌────────────────────┐
│  Transformer Block  │ × N 层
│  ┌────────────────┐ │
│  │ 多头自注意力     │ │  ← 每个词关注其他所有词
│  └────────────────┘ │
│  ┌────────────────┐ │
│  │ 前馈神经网络     │ │  ← 非线性变换
│  └────────────────┘ │
│  ┌────────────────┐ │
│  │ Layer Norm      │ │  ← 稳定训练
│  └────────────────┘ │
└────────────────────┘
  ↓
输出概率分布
```

---

### 2.3 Token 和分词

**Q：什么是 Token？为什么模型不能直接理解文字？**

Token 是模型处理文本的最小单位。模型不认识文字，只认识数字。

```
英文分词（BPE 算法）：
"unhappiness" → ["un", "happiness"]
"ChatGPT" → ["Chat", "G"]

中文分词：
"人工智能" → ["人工", "智能"] 或 ["人", "工", "智", "能"]
"你好世界" → ["你好", "世界"]

一个 token ≈ 英文 0.75 个单词 ≈ 中文 0.5-1 个汉字
```

**为什么重要？**

- 模型的上下文窗口以 token 计算（如 GPT-4：128K tokens）
- API 按 token 计费
- 中文通常比英文消耗更多 token

---

### 2.4 训练过程

**Q：大语言模型是怎么训练出来的？**

三个阶段：

```
阶段 1：预训练（Pre-training）
  数据：互联网上的海量文本（万亿 token）
  目标：预测下一个 token
  结果：获得通用的语言理解和生成能力
  成本：数百万到数千万美元

阶段 2：监督微调（SFT, Supervised Fine-Tuning）
  数据：人工编写的高质量问答对
  目标：学会"如何回答问题"的格式和风格
  结果：从"续写文本"变成"回答问题"

阶段 3：人类反馈强化学习（RLHF）
  数据：人类对多个回答的偏好排序
  目标：让模型的回答更符合人类期望
  结果：更安全、更有帮助、更诚实

  RLHF 流程：
  1. 模型生成多个回答
  2. 人类标注员排序：哪个回答更好
  3. 训练一个"奖励模型"学习人类偏好
  4. 用强化学习（PPO 算法）优化原模型
```

---

### 2.5 幻觉问题

**Q：什么是 AI 幻觉（Hallucination）？怎么缓解？**

幻觉：模型生成看似合理但实际错误的内容。

```
例子：
Q："谁发明了 Python？"
A："Python 是 Guido van Rossum 在 1989 年发明的"  ← 正确
A："Python 是 James Gosling 在 1995 年发明的"  ← 幻觉（混淆了 Java）
```

**为什么会幻觉？**

- 模型本质是"概率预测"，不是"查数据库"
- 训练数据中有错误信息
- 模型倾向于"自信地回答"而非"承认不知道"

**缓解方法：**

1. **RAG（检索增强生成）**：先检索相关文档，再基于文档回答
2. **温度调低**：`temperature=0` 减少随机性
3. **要求引用来源**：让模型说明信息出处
4. **人工审核**：关键信息必须人工确认
5. **思维链（CoT）**：让模型逐步推理，减少跳跃性错误

---

## 三、Prompt 工程

### 3.1 什么是 Prompt Engineering

**Q：什么是 Prompt Engineering？为什么重要？**

Prompt Engineering 是设计和优化输入给 AI 模型的提示词，以获得更准确、更有用的输出。

```
差的 Prompt：
  "帮我写个函数"

好的 Prompt：
  "用 JavaScript 写一个防抖函数，要求：
  1. 支持立即执行模式
  2. 支持取消功能
  3. 返回值是被 debounce 后的函数
  4. 添加 JSDoc 注释"
```

---

### 3.2 Prompt 技巧

**技巧 1：角色设定（System Prompt）**

```
你是一个资深前端工程师，擅长 Vue 3 和 TypeScript。
回答要简洁、有代码示例、指出常见陷阱。
```

**技巧 2：Few-shot 示例**

```
将以下自然语言转换为 SQL：

用户："查询所有年龄大于 25 的用户"
SQL：SELECT * FROM users WHERE age > 25

用户："统计每个部门的人数"
SQL：SELECT department, COUNT(*) FROM users GROUP BY department

用户："删除 30 天前的日志"
SQL：
```

**技巧 3：思维链（Chain of Thought）**

```
请一步步思考：

问题：一个水池有两个水管，A 管每小时注入 3 吨水，
B 管每小时排出 1 吨水。水池容量 20 吨，从空开始，
多少小时能装满？

请先分析问题，再列出计算步骤，最后给出答案。
```

**技巧 4：输出格式约束**

```
请以 JSON 格式返回结果：
{
  "summary": "一句话总结",
  "pros": ["优点1", "优点2"],
  "cons": ["缺点1", "缺点2"],
  "score": 8.5
}
```

**技巧 5：限制和边界**

```
如果问题超出你的知识范围，请回答"我不确定"而不是编造答案。
只基于我提供的文档内容回答，不要使用你的预训练知识。
```

---

### 3.3 上下文窗口

**Q：什么是上下文窗口？为什么有限制？**

上下文窗口是模型一次能处理的最大 token 数量。

```
GPT-3.5：4K / 16K tokens
GPT-4：8K / 32K / 128K tokens
Claude 3：200K tokens
Gemini 1.5：1M tokens

128K tokens ≈ 一本 300 页的书
1M tokens ≈ 一整套《哈利·波特》
```

**为什么有限制？**

- 自注意力的计算复杂度是 O(n²)，token 越多计算越慢
- 显存占用与 token 数成正比
- 上下文越长，模型对中间内容的"注意力"越弱（Lost in the Middle）

**实际影响：**

- 对话越长，API 费用越高
- 超过上下文窗口会被截断
- 需要合理管理上下文（摘要、滑动窗口等）

---

## 四、AI Agent

### 4.1 什么是 AI Agent

**Q：什么是 AI Agent？和普通的 ChatGPT 对话有什么区别？**

```
普通 LLM 对话：
  用户 → 提问 → 模型 → 回答（一次性）

AI Agent：
  用户 → 提出目标 → Agent 自主规划 → 执行 → 观察结果 → 调整 → 继续
                     ↑                                    ↓
                     └────────── 循环直到完成 ──────────────┘
```

**Agent = LLM + 记忆 + 工具 + 规划能力**

| 组件             | 作用                             | 类比     |
| ---------------- | -------------------------------- | -------- |
| LLM（大脑）      | 理解任务、推理决策               | 人的大脑 |
| 记忆（Memory）   | 存储对话历史、长期知识           | 人的记忆 |
| 工具（Tools）    | 调用外部 API、执行代码、操作文件 | 人的手脚 |
| 规划（Planning） | 拆解任务、制定计划、反思调整     | 人的思维 |

---

### 4.2 Agent 的工作流程

```
用户目标："帮我订一张明天从北京到上海的机票，经济舱"

Agent 的执行过程：

1. 【规划】拆解任务：
   - 查询明天的航班
   - 筛选经济舱
   - 比较价格
   - 选择最优方案
   - 完成预订

2. 【执行】调用工具：
   - 调用航班查询 API → 获取航班列表
   - 筛选经济舱 → 排除商务舱
   - 按价格排序 → 找到最便宜的

3. 【观察】检查结果：
   - 最便宜的是 MU5101，¥680
   - 但出发时间是 6:00 AM，太早

4. 【调整】重新筛选：
   - 加入时间约束（8:00-20:00）
   - 重新排序 → CA1501，¥720，9:00 出发

5. 【确认】向用户确认：
   - "找到 CA1501，明天 9:00 出发，经济舱 ¥720，确认预订吗？"

6. 【完成】用户确认后：
   - 调用预订 API
   - 返回订单信息
```

---

### 4.3 Agent 的核心能力

**1. 工具调用（Tool Calling / Function Calling）**

```json
// Agent 可以调用的工具定义
{
  "name": "search_flights",
  "description": "搜索航班信息",
  "parameters": {
    "type": "object",
    "properties": {
      "departure": { "type": "string", "description": "出发城市" },
      "arrival": { "type": "string", "description": "到达城市" },
      "date": { "type": "string", "description": "出发日期" },
      "cabin": { "type": "string", "enum": ["economy", "business"] }
    },
    "required": ["departure", "arrival", "date"]
  }
}

// 模型输出工具调用
{
  "tool_call": {
    "name": "search_flights",
    "arguments": {
      "departure": "北京",
      "arrival": "上海",
      "date": "2026-06-28",
      "cabin": "economy"
    }
  }
}
```

**2. 记忆系统（Memory）**

```
短期记忆：当前对话的上下文（对话历史）
长期记忆：向量数据库存储的历史知识、用户偏好
工作记忆：当前任务的中间状态

记忆管理策略：
- 滑动窗口：只保留最近 N 轮对话
- 摘要压缩：把长对话压缩成摘要
- 向量检索：按相关性检索历史记忆
```

**3. 规划能力（Planning）**

```
任务拆解策略：
- 简单任务：直接执行
- 复杂任务：拆解为子任务，逐个完成
- 不确定任务：先探索，再规划

反思机制：
- 执行后检查结果是否符合预期
- 如果失败，分析原因，调整策略重试
- 类似人类的"复盘"
```

---

### 4.4 Agent 框架

**主流 Agent 框架对比：**

| 框架      | 特点               | 适用场景        |
| --------- | ------------------ | --------------- |
| LangChain | 生态最大、工具最多 | 通用 Agent 开发 |
| AutoGPT   | 全自动、自主规划   | 探索性任务      |
| CrewAI    | 多 Agent 协作      | 团队协作场景    |
| Dify      | 低代码、可视化     | 快速搭建 Agent  |
| Coze/扣子 | 字节出品、中文友好 | 国内应用        |

---

### 4.5 Multi-Agent（多智能体）

**Q：什么是多智能体系统？**

```
单 Agent：一个 AI 完成所有任务
多 Agent：多个 AI 各司其职，协作完成任务

例子：一个"AI 开发团队"
┌─────────────────────────────────────────┐
│  产品经理 Agent                         │
│  → 分析需求，输出 PRD                    │
│       ↓                                 │
│  架构师 Agent                           │
│  → 设计技术方案                          │
│       ↓                                 │
│  前端开发 Agent                         │
│  → 编写前端代码                          │
│       ↓                                 │
│  测试 Agent                             │
│  → 编写测试用例，执行测试                 │
│       ↓                                 │
│  代码审查 Agent                         │
│  → Review 代码，提出修改建议              │
└─────────────────────────────────────────┘
```

---

## 五、RAG（检索增强生成）

### 5.1 什么是 RAG

**Q：什么是 RAG？为什么需要它？**

RAG（Retrieval-Augmented Generation）= 检索 + 生成

```
普通 LLM：
  用户提问 → 模型根据训练知识回答（可能过时或错误）

RAG：
  用户提问 → 检索相关文档 → 将文档 + 问题一起给模型 → 基于文档回答
```

**为什么需要 RAG？**

1. **知识时效性**：模型训练数据有截止日期，RAG 可以接入最新数据
2. **减少幻觉**：基于真实文档回答，而非"编造"
3. **私有数据**：企业内部文档、个人笔记等不在训练数据中的内容
4. **可溯源**：可以告诉用户答案来自哪篇文档

---

### 5.2 RAG 的工作流程

```
1. 文档预处理（离线）
   ┌──────────┐    ┌──────────┐    ┌──────────┐
   │ 原始文档  │ →  │ 分块     │ →  │ 向量化   │ → 存入向量数据库
   │ (PDF/网页)│    │ (Chunk)  │    │(Embedding)│
   └──────────┘    └──────────┘    └──────────┘

2. 检索 + 生成（在线）
   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
   │ 用户提问  │ →  │ 问题向量化│ →  │ 向量检索  │ →  │ LLM 生成 │
   └──────────┘    └──────────┘    │ Top-K 文档│    │ 最终回答  │
                                   └──────────┘    └──────────┘
```

---

### 5.3 向量数据库与 Embedding

**Q：什么是向量数据库？什么是 Embedding？**

```
Embedding（嵌入）：将文本转换为高维向量（一组数字）

"猫" → [0.2, 0.8, -0.1, 0.5, ...]  (1536 维)
"狗" → [0.3, 0.7, -0.2, 0.4, ...]  (相似！)
"汽车" → [-0.5, 0.1, 0.9, -0.3, ...] (不相似)

向量之间的距离 = 语义相似度
"猫" 和 "狗" 的向量距离近 → 语义相似
"猫" 和 "汽车" 的向量距离远 → 语义不相关
```

**向量数据库：** 专门存储和检索向量的数据库

- Pinecone、Milvus、Weaviate、Qdrant、ChromaDB
- 支持高效的相似度搜索（近似最近邻 ANN）

---

### 5.4 RAG 优化技巧

```
1. 分块策略
   - 固定大小分块（如 512 token 一块）
   - 按语义分块（段落、章节）
   - 重叠分块（相邻块有重叠，避免截断上下文）

2. 检索优化
   - 混合检索：向量检索 + 关键词检索
   - 重排序（Reranking）：用另一个模型对检索结果重新排序
   - 查询改写：将用户问题改写成更适合检索的形式

3. 生成优化
   - 提示词中明确要求"基于以下文档回答"
   - 要求模型引用来源
   - 如果文档中没有相关信息，要求模型说"我不确定"
```

---

## 六、MCP（Model Context Protocol）

### 6.1 什么是 MCP

**Q：什么是 MCP？它解决了什么问题？**

MCP（Model Context Protocol）是 Anthropic 提出的开放协议，用于标准化 AI 模型与外部工具/数据源的连接方式。

```
没有 MCP 之前：
  每个 AI 应用都要自己写工具对接代码
  ChatGPT 有自己的插件系统
  Claude 有自己的工具调用方式
  各家不兼容

有了 MCP：
  统一的协议标准
  任何 AI 应用都能通过 MCP 连接任何工具
  类似 USB 统一了各种设备的接口
```

**MCP 的架构：**

```
┌─────────────┐     MCP 协议     ┌─────────────┐
│  AI 应用     │ ←────────────→  │  MCP Server  │
│  (Client)    │                 │  (工具/数据)  │
└─────────────┘                 └─────────────┘

MCP Server 可以提供：
- Tools（工具）：执行操作（发邮件、查数据库）
- Resources（资源）：提供数据（文件、API 数据）
- Prompts（提示词）：预定义的提示模板
```

---

### 6.2 MCP 与 Function Calling 的区别

```
Function Calling：
  - 每个模型有自己的工具调用格式
  - 工具定义在对话开始时传入
  - 一次性绑定

MCP：
  - 统一的协议标准
  - 工具可以动态发现和连接
  - 跨模型、跨应用通用
  - 支持双向通信（不仅模型调工具，工具也能通知模型）
```

---

## 七、前端与 AI 的结合

### 7.1 前端开发者如何使用 AI

**1. AI 辅助编码**

- GitHub Copilot：代码补全
- Cursor：AI 代码编辑器
- Claude / ChatGPT：代码生成、Bug 排查、代码审查

**2. AI 应用开发**

- 接入大模型 API（OpenAI、Claude、文心一言等）
- 搭建 RAG 应用（企业知识库、智能客服）
- 开发 AI Agent（自动化工具）

**3. AI 前端组件**

- 智能搜索框（语义搜索）
- AI 对话界面（Chat UI）
- 智能表单（自动填充、验证）

---

### 7.2 调用大模型 API

**Q：前端怎么调用大模型 API？**

```js
// OpenAI API 调用示例
async function chat(messages) {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${API_KEY}`,
    },
    body: JSON.stringify({
      model: "gpt-4",
      messages: [
        { role: "system", content: "你是一个前端技术专家" },
        ...messages,
      ],
      temperature: 0.7,
      max_tokens: 2000,
    }),
  });
  return response.json();
}

// 流式输出（SSE）
async function chatStream(messages) {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${API_KEY}`,
    },
    body: JSON.stringify({
      model: "gpt-4",
      messages,
      stream: true, // 开启流式
    }),
  });

  const reader = response.body.getReader();
  const decoder = new TextDecoder();

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    const chunk = decoder.decode(value);
    // 解析 SSE 数据：data: {"choices":[{"delta":{"content":"你"}}]}
    const lines = chunk.split("\n").filter((line) => line.startsWith("data: "));
    for (const line of lines) {
      const data = JSON.parse(line.slice(6));
      const content = data.choices[0]?.delta?.content;
      if (content) {
        // 逐字显示
        appendToUI(content);
      }
    }
  }
}
```

---

### 7.3 AI 对话界面开发

**Q：如何实现一个流式 AI 对话界面？**

```vue
<template>
  <div class="chat-container">
    <div v-for="msg in messages" :key="msg.id" :class="['message', msg.role]">
      <div class="content" v-html="renderMarkdown(msg.content)" />
    </div>
    <div v-if="loading" class="typing-indicator">AI 正在输入...</div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { marked } from "marked";

const messages = ref([]);
const loading = ref(false);

async function sendMessage(content) {
  // 添加用户消息
  messages.value.push({ id: Date.now(), role: "user", content });

  // 添加 AI 消息占位
  const aiMsg = { id: Date.now() + 1, role: "assistant", content: "" };
  messages.value.push(aiMsg);
  loading.value = true;

  // 流式请求
  const response = await fetch("/api/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ messages: messages.value }),
  });

  const reader = response.body.getReader();
  const decoder = new TextDecoder();

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    const text = decoder.decode(value);
    // 逐字追加
    aiMsg.content += text;
  }

  loading.value = false;
}

function renderMarkdown(text) {
  return marked(text);
}
</script>
```

---

### 7.4 Function Calling 实战

**Q：什么是 Function Calling？前端怎么用？**

Function Calling 让模型不仅能生成文本，还能输出结构化的工具调用指令。

```js
// 1. 定义工具
const tools = [
  {
    type: 'function',
    function: {
      name: 'get_weather',
      description: '获取指定城市的天气信息',
      parameters: {
        type: 'object',
        properties: {
          city: { type: 'string', description: '城市名称' },
          date: { type: 'string', description: '日期，格式 YYYY-MM-DD' }
        },
        required: ['city']
      }
    }
  }
]

// 2. 调用模型
const response = await chat([
  { role: 'user', content: '明天北京天气怎么样？' }
], tools)

// 3. 模型输出工具调用
// response.choices[0].message.tool_calls = [
//   {
//     function: {
//       name: 'get_weather',
//       arguments: '{"city": "北京", "date": "2026-06-28"}'
//     }
//   }
// ]

// 4. 前端执行工具，获取结果
const weather = await getWeather('北京', '2026-06-28')

// 5. 把结果发回模型
const finalResponse = await chat([
  { role: 'user', content: '明天北京天气怎么样？' },
  { role: 'assistant', tool_calls: [...] },
  { role: 'tool', content: JSON.stringify(weather) }
])

// 6. 模型生成最终回答
// "明天北京晴转多云，气温 22-32°C，适合出行。"
```

---

## 八、常见 AI 概念速查表

| 概念                 | 解释                                                        |
| -------------------- | ----------------------------------------------------------- |
| **LLM**              | 大语言模型，如 GPT-4、Claude、Gemini                        |
| **Token**            | 模型处理文本的最小单位                                      |
| **Prompt**           | 输入给模型的提示词                                          |
| **Completion**       | 模型生成的输出                                              |
| **Temperature**      | 控制输出随机性，0=确定性，1=创造性                          |
| **Top-p**            | 核采样，控制候选 token 的概率范围                           |
| **Context Window**   | 模型一次能处理的最大 token 数                               |
| **Fine-tuning**      | 用特定数据微调模型                                          |
| **Embedding**        | 将文本转换为向量表示                                        |
| **Vector Database**  | 存储和检索向量的数据库                                      |
| **RAG**              | 检索增强生成，先检索再回答                                  |
| **Agent**            | 具有自主规划和工具调用能力的 AI 系统                        |
| **MCP**              | 模型上下文协议，标准化 AI 与工具的连接                      |
| **Function Calling** | 模型输出结构化的工具调用指令                                |
| **Chain of Thought** | 思维链，让模型逐步推理                                      |
| **Few-shot**         | 在提示词中给出几个示例                                      |
| **Zero-shot**        | 不给示例，直接提问                                          |
| **RLHF**             | 人类反馈强化学习                                            |
| **Hallucination**    | 模型生成看似合理但错误的内容                                |
| **Multi-modal**      | 多模态，支持文本+图片+音频等                                |
| **AGI**              | 通用人工智能（尚未实现）                                    |
| **Transformer**      | 当前大模型的基础架构                                        |
| **Attention**        | 自注意力机制，Transformer 的核心                            |
| **BERT**             | Google 的双向编码模型，擅长理解                             |
| **GPT**              | OpenAI 的生成式模型，擅长生成                               |
| **Diffusion**        | 扩散模型，图像生成的核心技术（如 Stable Diffusion、DALL-E） |

---

> 📅 最后更新：2026-06-27
