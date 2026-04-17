---
name: pdca
version: 2.0.0
description: |
  AI-driven PDCA project management with proactive inspection. Use for: project setup (new), active project tracking (ongoing), experience retrieval (achieve), PDCA cycles, SMART goal validation, quality improvement (OEE, defects), manufacturing optimization, or structured problem-solving. Supports Feishu/Lark as integrated backend for Bitable + Wiki + Calendar + Task. Works on any AI Agent platform (OpenClaw, Hermes Agent, Claude Code, etc.).
---

# PDCA 项目管理系统

基于 PDCA 循环的结构化问题解决系统。AI Agent 驱动主动巡检、SMART 目标校验和 MECE 框架分析，支持飞书工具链作为深度集成后端。

## 何时使用

| 触发症状 | 不适用场景 |
|---------|-----------|
| 问题需要结构化分析（5W1H、鱼骨图、5Why） | 简单单次任务（直接用任务管理工具） |
| 需要量化目标和可衡量指标 | 纯技术研究（无需流程闭环） |
| 需要主动进度监控和预警 | 紧急故障处理（先修复，后复盘） |

**触发示例**：
- "启动一个 PDCA 项目来降低产品缺陷率"
- "用飞书 Bitable 管理我们的质量改善项目"
- "我需要 SMART 目标校验，目标是将 OEE 提升到 85%"
- "检查一下我的 PDCA 项目进度"

## 平台与后端

**Agent 平台**：本技能不绑定任何特定 AI Agent 平台，可用于：
- OpenClaw（https://github.com/open-claw/open-claw）
- Hermes Agent
- Claude Code
- 任何能加载 Markdown 技能并执行工具调用的 Agent

**工具后端（推荐：飞书）**：
- 飞书提供项目管理的全套工具链（Wiki 文档、Bitable 多维表格、Calendar 日历、Task 任务）
- 飞书集成实现详见 [feishu-integration.md](assets/references/feishu-integration.md)
- Bitable 表结构定义详见 [Bitable表结构定义.md](system/工具/Bitable表结构定义.md)

**最小可用模式**：即使没有飞书，Agent 也可以用本地文件系统管理项目（文档 + JSON 状态文件），核心的 PDCA 方法论、MECE 分析、SMART 校验仍然完整可用。

## 核心特性

### 1. MECE 框架分析

根据问题类型选择对应的分析框架，确保维度覆盖完整、无遗漏无重叠：

| 问题类型 → 框架 |
|------|
| 生产/制造 → 4M1E |
| 个人健康 → TREND |
| 软件/技术 → PPTD |
| 销售/营销 → 5P |
| 学习/教育 → COMET |
| 财务/投资 → 3RL-TD |
| 团队协作 → GRCT |
| 客户服务 → 5S |
| 个人效率 → TIME |
| 流程/服务 → SIPOC |
| 其他管理/组织 → 5P2E |

每个框架的逐维度详细说明见 [mece-frameworks.md](assets/references/mece-frameworks.md)。

### 2. 质量门（不可跳过）
- **SMART 校验**：目标必须是具体的、可衡量的、可达成的、相关的、有时限的
- **因果逻辑审查**：问题原因与对策之间必须有因果链，一票否决
- 详细规范见 [核心规范.md](system/规范/核心规范.md)、[smart.md](system/规范/Validators/smart.md)、[logic.md](system/规范/Validators/logic.md)

### 3. 主动巡检（Agent 核心价值）

**项目创建后无人跟进是 PDCA 失败的首要原因。** Agent 必须像项目经理一样定期主动检查进度。

- 每日进度检查（建议 09:00）
- 阶段到期前 2 天预警
- 里程碑到期提醒
- 进度偏差分析（时间进度 vs 完成度）
- 超时警告

完整行为规范见 [proactive-reminder.md](assets/references/proactive-reminder.md)。

---

## 全局交互规范：选项设计

**适用范围**：PDCA **每个阶段**中 AI 主动发起的选项对话。

设计选项时遵循三大原则：

### 1. MECE 原则 — 基于框架设计选项

选项必须"相互独立、完全穷尽"。根据当前对话的问题类型，选择对应的 MECE 框架维度作为选项基础（见上表）。

### 2. 多选优先 — 原因/因素往往不止一个

问题涉及"哪些方面"、"什么原因"、"什么因素"时，使用多选。

### 3. 允许自定义 — 必须有 Other 选项

所有问题必须包含自定义选项，因为无法预先覆盖所有情况。

### 选项设计 Red Flags

- 选项之间有明显重叠 → 基于 MECE 框架重新设计
- 用户说"原因是多个"但只能单选 → 改为多选
- 用户说"我的情况不在选项里" → 缺少自定义选项
- 没有基于任何框架直接编选项 → 先选择合适的框架

### 4. 平台感知交互 — 根据平台能力选择呈现方式

不同平台对交互组件的支持不同。Agent 必须根据当前运行平台的能力，自动选择最优的交互方式。**选项内容不变（MECE 原则），变化的只是呈现载体。**

#### 飞书 Channel 网关模式（OpenClaw / Hermes Agent）

**当前可用方案**：P2 富文本编号列表

在飞书 channel 网关模式下（通过飞书机器人与用户交互）：
- ❌ `clarify` 工具**不可用**（网关模式无法弹出原生选择框）
- ❌ Interactive Card **当前 Agent 层无法直接发送**（需要平台适配器支持，未来集成用）
- ✅ **富文本编号列表**：唯一当前可用的交互方式

**格式规范**：

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

**Agent 处理流程**：
1. 基于 MECE 框架生成选项内容
2. 使用 P2 格式通过 `send_message` 发送到飞书对话
3. 用户输入编号（如 `1,3,5` 或 `其他：员工流动性大`）
4. Agent 解析编号映射到选项内容
5. 确认选择并推进流程

> 📖 **详细模板**：Interactive Card JSON 模板供未来集成使用，见 [feishu-interaction.md](assets/references/feishu-interaction.md)

#### CLI 模式（Hermes / OpenClaw 命令行）

**当前可用方案**：P0 原生交互组件 → P2 文本编号列表

在命令行模式下：
- ✅ `clarify` 工具**可用**（原生支持多选/单选/自定义）
- 🔄 备选：文本编号列表

#### 平台检测

| 检测方式 | 说明 | 示例值 |
|---------|------|--------|
| `HERMES_SESSION_PLATFORM` 环境变量 | Hermes Agent 平台标识 | `cli`, `feishu`, `telegram`, `discord` |
| 平台适配器回调能力 | 检测 `clarify` 工具是否可用 | 可用 = CLI 模式 |
| 消息来源判断 | 飞书 channel vs CLI 终端 | 飞书 = P2，CLI = P0→P2 |

#### 各平台推荐方案汇总

| 运行模式 | 首选方案 | 备选方案 | 说明 |
|---------|---------|---------|------|
| **OpenClaw 飞书 channel** | P2 文本编号列表 | - | 网关模式，仅此可用 |
| **Hermes Agent 飞书** | P2 文本编号列表 | - | 网关模式，仅此可用 |
| **OpenClaw CLI** | P0 clarify 工具 | P2 文本编号列表 | 原生交互可用 |
| **Hermes CLI** | P0 clarify 工具 | P2 文本编号列表 | 原生交互可用 |
| **其他平台** | 平台原生组件 | P2 文本编号列表 | 根据平台能力判断 |

#### 通用文本 Fallback 格式

当平台不支持原生交互组件和卡片时，使用以下格式：

```
**[问题标题]**
[1-2 句背景说明]

请选择最符合您情况的选项（可多选）：

1️⃣ **选项A** — 补充说明
2️⃣ **选项B** — 补充说明
3️⃣ **选项C** — 补充说明
4️⃣ **选项D** — 补充说明
5️⃣ 其他（请描述您的具体情况）

💡 输入编号选择，多个选项用逗号分隔（如 1,3,5）
```

#### 交互流程规范

无论使用哪种交互载体，Agent 的行为必须一致：

1. **生成选项**：基于 MECE 框架维度生成选项内容
2. **选择载体**：根据平台能力选择 P0/P1/P2
3. **呈现选项**：使用对应载体的格式发送
4. **接收选择**：解析用户回复（按钮回调 / clarify 返回 / 文本编号）
5. **确认 + 下一步**：向用户确认已选内容，推进流程

#### 交互 Red Flags

- 所有平台一律用纯文本长问句 → 没有检测平台能力，应使用结构化选项
- 飞书 channel 尝试使用 `clarify` 工具 → 该工具在网关模式下不可用
- 飞书 channel 尝试直接发送 Interactive Card → 当前 Agent 层无法直接调用卡片 API
- 提供选项但用户不知道怎么选（没有说明操作方式）→ 缺少"输入编号选择"的操作提示

---

## 三大指令

### `new` — 启动新项目

**流程**：
1. **评估问题**：根据问题类型选择 MECE 框架，引导用户进行结构化分析
2. **SMART 校验**：量化目标，通过 SMART + 因果逻辑双重校验
3. **创建项目结构**：
   - 项目文档（问题分析、目标、解决方案）
   - 数据表（项目主表、任务表、数据记录表、执行日志表）
   - 项目甘特图（阶段时间线、关键节点、里程碑）
4. **生成执行计划**：按 MECE 维度分解任务，设定时间节点
5. **注册巡检**：创建每日巡检 + 阶段到期预警 + 里程碑提醒

**飞书后端实现**：如果使用飞书，步骤 3-5 的具体 API 调用见 [feishu-integration.md](assets/references/feishu-integration.md) 的「项目创建流程」章节。

### `ongoing` — 管理活跃项目

**流程**：
1. **巡检**：按 [proactive-reminder.md](assets/references/proactive-reminder.md) 执行每日检查
2. **状态更新**：评估完成度、计算偏差、判定状态（正常/预警/超时）
3. **预警推送**：发现异常时发送预警消息，附带具体建议
4. **阶段转换**：检查转换条件，用户确认后进入下一阶段
5. **巡检参数更新**：阶段转换后更新巡检周期和预警阈值

### `achieve` — 检索经验库

**流程**：
1. 分析当前问题的领域和类型
2. 匹配历史项目中的相似案例
3. 推荐最佳实践和模板
4. 如果是制造场景，参考 [manufacturing-templates.md](assets/references/manufacturing-templates.md)

---

## 渐进式披露：详细指南

根据当前任务，阅读对应的参考文档：

### 1. 主动巡检与驱动

- **主动巡检行为规范**：见 [proactive-reminder.md](assets/references/proactive-reminder.md)
- **定时任务配置**：见 [cron-driving.md](assets/references/cron-driving.md)

### 2. 飞书集成（推荐后端）

- **API 调用与工具配置**：见 [feishu-integration.md](assets/references/feishu-integration.md)
- **表结构定义**：见 [Bitable表结构定义.md](system/工具/Bitable表结构定义.md)
- **收集表配置**：见 [收集表配置指南.md](system/工具/收集表配置指南.md)
- **仪表盘组件配置**：见 [仪表盘组件配置.md](system/工具/仪表盘组件配置.md)
- **工作流自动化配置**：见 [工作流自动化配置.md](system/工具/工作流自动化配置.md)
- **Bitable 应用文档模板**：见 [Bitable应用文档模板.md](system/工具/Bitable应用文档模板.md)

### 3. 各阶段执行指南

- **Plan 阶段（规划/校验）**：见 [plan-agent.md](assets/references/plan-agent.md)
- **Do 阶段（执行/日志）**：见 [do-agent.md](assets/references/do-agent.md)
- **Check 阶段（数据/评估）**：见 [check-agent.md](assets/references/check-agent.md)
- **Act 阶段（决策/沉淀）**：见 [act-agent.md](assets/references/act-agent.md)

### 4. 质量与逻辑校验

- **SMART 原则校验**：见 [smart.md](system/规范/Validators/smart.md)
- **因果逻辑链审查**：见 [logic.md](system/规范/Validators/logic.md)
- **阶段转换检查**：见 [transition-checklist.md](assets/references/transition-checklist.md)
- **异常处理**：见 [exception-handling.md](assets/references/exception-handling.md)

### 5. 制造场景模板与其他

- **OEE/质量改善模板库**：见 [manufacturing-templates.md](assets/references/manufacturing-templates.md)
- **仪表板模板**：见 [dashboard-templates.md](assets/references/dashboard-templates.md)
- **任务自动生成**：见 [任务自动生成器.md](system/工具/任务自动生成器.md)
- **智能巡检频率**：见 [智能巡检频率.md](system/工具/智能巡检频率.md)
- **仪表板生成**：见 [仪表板生成器.md](system/工具/仪表板生成器.md)
- **表单配置**：见 [表单配置生成器.md](system/工具/表单配置生成器.md)
- **阶段转换检查表**：见 [阶段转换检查表.md](system/工具/阶段转换检查表.md)

---

## 阶段概览

| 阶段 | 核心交付物 | 校验标准 |
|------|-----------|---------|
| Plan | 问题分析、目标设定、解决方案 | SMART + 因果逻辑 |
| Do | 执行日志、进度报告、问题记录 | 任务完成率 + 数据完整性 |
| Check | 数据分析、效果评估、问题诊断 | 目标达成率 + 趋势分析 |
| Act | 行动决策、实施方案、知识总结 | 决策矩阵 + SOP 沉淀 |

---

## 核心规则

1. **SMART 校验和因果逻辑验证是强制的，不可跳过**
2. **阶段转换严格按顺序**，需要当前阶段所有必选任务完成
3. **所有阶段转换和项目结项必须经过用户确认**
4. **巡检发现异常必须主动推送**，沉默的巡检等于没有巡检
5. **项目数据的事实来源**由工具后端决定（飞书 Bitable / 本地文件 / 其他）
6. **主动巡检是 Agent 的核心职责**，不是可选功能

## 通用 Red Flags

出现以下信号时，**立即停止**：

### 方法论 Red Flags
- 目标没有具体数字 → 回到 Plan，完成 SMART 校验
- "执行中再调整" → 目标不够清晰
- "快速补救一下" → 补救≠符合标准
- "老板在催，先开始吧" → 权威压力不是降低标准的理由
- "已经花了 X 周了" → 沉没成本不是跳过检查的理由
- 直接接受用户提供的原因而不验证 → 用 MECE 框架逐维度扫描
- 跳过某个 MECE 维度 → 必须有数据支持才能判定不相关

### 巡检 Red Flags
- 连续多天没有发送巡检消息 → 巡检机制可能失效
- 巡检只报"一切正常"但完成度没有变化 → 数据可能不准确
- 用户长期不响应 → 考虑降低频率或询问是否暂停

## Rationalization 防御

| 借口 | 现实 |
|------|------|
| "MECE 太复杂，简单问一下就行" | 简单提问 = 遗漏关键因素，后期返工更浪费时间 |
| "选项已经覆盖所有情况了" | 你无法预知所有情况，必须有自定义选项 |
| "用户已经说了原因，不需要再分析" | 用户说的是症状，不是根因 |
| "单选就够了" | 现实中问题往往是多因素导致的，限制用户只能选一个会遗漏原因 |
| "简单项目不需要完整的 PDCA 结构" | 简单项目也需要完整的 PDCA 结构，才能保证质量 |
| "每天发消息太打扰了" | 连续 3 天状态相同时自动降为摘要模式，状态变化时才发详情 |
| "巡检发现了问题但用户没回复" | 发送预警就够了，尊重用户的节奏，不要催促 |

**Violating the letter of the rules is violating the spirit of the rules.**
