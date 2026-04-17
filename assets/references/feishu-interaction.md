# 飞书用户交互指南

PDCA 项目在飞书平台上的用户交互规范。

## OpenClaw + openclaw-lark 插件（推荐）

**官方插件**：[openclaw-lark](https://github.com/larksuite/openclaw-lark)

### `feishu_ask_user_question` 工具

OpenClaw 官方飞书插件提供了 `feishu_ask_user_question` 工具，支持完整的交互式卡片功能。

#### 工具参数结构

```typescript
{
  questions: [
    {
      question: string,      // 问题文本（支持 lark_md 格式）
      header: string,        // 短标签（最多12字符）
      options: [             // 空数组 = 文本输入，有内容 = 下拉选择
        {
          label: string,     // 选项标题
          description: string // 选项说明
        }
      ],
      multiSelect: boolean   // false=单选, true=多选
    }
  ]
}
```

**约束条件**：
- 最多 4 个问题
- `header` 最多 12 字符
- `options` 为空数组时显示文本输入框
- `options` 有内容时显示下拉选择器

#### 交互类型对照表

| options 配置 | multiSelect | 控件类型 | PDCA 适用场景 |
|-------------|-------------|---------|--------------|
| `[]` | - | 文本输入框 | 自定义补充、具体描述 |
| 有内容 | `false` | 单选下拉 | 阶段转换确认、效果评估判定 |
| 有内容 | `true` | 多选下拉 | MECE 维度选择、根因分析 |
| 不传 | - | 文本输入 | 默认行为（等同于 `[]`） |

#### 完整交互流程

```
1. Agent 调用 feishu_ask_user_question
   ↓
2. 插件发送 CardKit v2 卡片到飞书
   - 使用 Form 容器
   - form_action_type: "submit"
   ↓
3. 工具立即返回 { status: 'pending' }
   ↓
4. 用户在飞书客户端中填写并提交
   ↓
5. 插件接收到 card_action_trigger 事件
   ↓
6. 插件注入 synthetic message（包含用户答案）
   ↓
7. Agent 从消息上下文中获取答案，继续处理
```

#### 调用示例

**示例 1：MECE 维度多选**

```typescript
feishu_ask_user_question({
  questions: [{
    question: "**项目**：挖掘机臂架开裂改善\n\n请选择导致问题的主要因素（可多选）：",
    header: "根因分析",
    options: [
      { label: "🔧 设备/机器", description: "设备故障、老化、维护不当" },
      { label: "👤 人员/技能", description: "培训不足、流动性大" },
      { label: "📐 工艺/方法", description: "流程不合理、标准缺失" },
      { label: "📦 材料/物料", description: "原料质量、供应不稳定" },
      { label: "🌍 环境/条件", description: "温湿度、照明、噪音" }
    ],
    multiSelect: true
  }]
})
```

**示例 2：阶段转换单选确认**

```typescript
feishu_ask_user_question({
  questions: [{
    question: "**项目**：挖掘机臂架开裂改善\n**阶段转换**：Plan → Do\n\n- 必选任务完成率：100%\n- 交付物检查：通过\n\n请确认是否可以进行阶段转换：",
    header: "阶段转换",
    options: [
      { label: "✅ 确认转换", description: "所有必选任务已完成" },
      { label: "⏳ 延期", description: "需要更多时间" },
      { label: "❌ 返回", description: "返回当前阶段" }
    ],
    multiSelect: false
  }]
})
```

**示例 3：文本输入（自定义补充）**

```typescript
feishu_ask_user_question({
  questions: [{
    question: "**请描述您的具体情况**：\n\n如果选项列表中没有符合您的情况，请详细描述：",
    header: "补充说明",
    options: []  // 空数组 = 文本输入框
  }]
})
```

**示例 4：混合问题（单选 + 文本输入）**

```typescript
feishu_ask_user_question({
  questions: [
    {
      question: "请选择问题类型：",
      header: "问题分类",
      options: [
        { label: "质量问题", description: "产品缺陷、不良率" },
        { label: "效率问题", description: "生产效率、OEE" },
        { label: "成本问题", description: "费用、浪费" }
      ],
      multiSelect: false
    },
    {
      question: "请具体描述问题表现：",
      header: "具体描述",
      options: []  // 文本输入
    }
  ]
})
```

#### PDCA 流程中的典型交互场景

| 阶段 | 典型交互场景 | 交互类型 | multiSelect |
|------|------------|---------|-------------|
| Plan | 选择 MECE 框架维度 | 下拉选择 | `true` |
| Plan | 确认 SMART 目标 | 下拉选择 | `false` |
| Plan | 问题根因分析 | 下拉选择 | `true` |
| Plan | 自定义补充说明 | 文本输入 | - |
| Do | 任务完成确认 | 下拉选择 | `false` |
| Check | 效果评估判定 | 下拉选择 | `false` |
| Act | 决策选择 | 下拉选择 | `false` |
| 任意 | 阶段转换确认 | 下拉选择 | `false` |

---

## Hermes Agent 飞书适配器

**当前状态**：无官方交互式卡片支持

**可用方案**：P2 富文本编号列表

### P2 富文本编号列表格式

```markdown
**📋 [问题标题]**

[1-2 句背景说明，说明为什么问这个问题]

请选择（可多选）：

1️⃣ **选项 A** — 补充说明
2️⃣ **选项 B** — 补充说明
3️⃣ **选项 C** — 补充说明
4️⃣ **选项 D** — 补充说明
5️⃣ 其他（请描述您的具体情况）

💡 输入编号选择，多个选项用逗号分隔（如 1,3,5）
```

### Agent 处理流程

1. 基于 MECE 框架生成选项内容
2. 使用 P2 格式通过 `send_message` 发送到飞书对话
3. 用户输入编号（如 `1,3,5` 或 `其他：员工流动性大`）
4. Agent 解析编号映射到选项内容
5. 确认选择并推进流程

---

## 平台检测与方案选择

### 检测方式

| 检测方法 | 说明 | 适用判断 |
|---------|------|---------|
| `feishu_ask_user_question` 工具可用性 | 尝试调用工具 | OpenClaw + openclaw-lark |
| 环境变量 `HERMES_SESSION_PLATFORM` | Hermes Agent 平台标识 | `feishu` = Hermes 飞书 |
| 消息来源判断 | 飞书 channel vs CLI 终端 | 根据实际运行环境 |

### 方案选择决策树

```
运行在飞书环境？
├── 是 → feishu_ask_user_question 可用？
│   ├── 是 → 使用 P1 交互式卡片（首选）
│   └── 否 → 使用 P2 文本编号列表
└── 否 → 使用平台原生组件（如 clarify 工具）
```

---

## 通用 Fallback 格式

当交互式卡片不可用时，统一使用以下格式：

```markdown
**📋 [问题标题]**

[1-2 句背景说明，说明为什么问这个问题]

请选择最符合您情况的选项（可多选）：

1️⃣ **选项A** — 补充说明
2️⃣ **选项B** — 补充说明
3️⃣ **选项C** — 补充说明
4️⃣ **选项D** — 补充说明
5️⃣ 其他（请描述您的具体情况）

💡 输入编号选择，多个选项用逗号分隔（如 1,3,5）
```

---

## 注意事项

### OpenClaw + openclaw-lark

1. **安装插件**：确保已安装 [openclaw-lark](https://github.com/larksuite/openclaw-lark) 插件
2. **配置权限**：确保机器人有发送消息卡片的权限
3. **synthetic message**：用户提交后，答案会通过 synthetic message 传递给 Agent
4. **超时处理**：如果用户长时间未提交，可能需要重新发送卡片

### Hermes Agent

1. **仅支持文本交互**：当前版本不支持交互式卡片
2. **编号映射**：Agent 需要自行维护编号到选项的映射关系
3. **多选处理**：解析逗号分隔的编号（如 `1,3,5`）

### 跨平台兼容

无论使用哪种平台，选项内容的设计都必须遵循 **MECE 原则**：
- 选项相互独立、完全穷尽
- 多选优先（原因/因素往往不止一个）
- 允许自定义（必须有 Other 选项）
