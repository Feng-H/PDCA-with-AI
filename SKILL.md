---
name: pdca
version: 1.0.0
description: |
  AI-driven PDCA project management with Feishu/Lark integration. Use for: project setup (new), active project tracking (ongoing), experience retrieval (achieve), PDCA cycles, SMART goal validation, quality improvement (OEE, defects), manufacturing optimization, or structured problem-solving with Feishu Bitable + docs. Also use for project transitions, proactive AI alerts, or template-based experience reuse.
---

# PDCA 项目管理系统

基于 PDCA 循环的结构化问题解决系统，由 AI 驱动实现主动巡检、SMART 目标校验和飞书工具链集成。

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

## 系统依赖

**必需平台**：
- **OpenClaw**：AI CLI 框架（https://github.com/open-claw/open-claw）
- **飞书插件**：提供 `feishu-bitable`、`feishu-create-doc` 等 API

本 skill 通过这些 API 创建 Bitable 应用、Wiki 文档、任务和日程。

**项目存储位置**：所有项目统一存储在 Wiki 知识空间「PDCA」下。

## 核心工作流

1. **评估与启动 (new)**：评估问题是否适合立项，在 Wiki 知识空间创建项目文件夹 + Bitable 应用 + 项目文档
2. **计划与校验 (Plan)**：执行 SMART 校验与因果逻辑审查
3. **执行与巡检 (Do)**：AI 通过 Bitable 数据记录主动巡检并汇总进展
4. **检查与评估 (Check)**：分析数据偏差
5. **决策与沉淀 (Act)**：生成标准化 SOP 并归档经验

## 全局交互规范：AskUserQuestion 选项设计

**适用范围**：PDCA **每个阶段** 中 AI 主动发起的 AskUserQuestion 对话，不限于项目启动阶段。

设计选项时遵循三大原则：

### 1. MECE 原则 — 基于框架设计选项

选项必须"相互独立、完全穷尽"。根据当前对话的问题类型，选择对应的 MECE 框架，用其维度作为选项基础：

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

### 2. 多选优先 — 原因/因素往往不止一个

问题涉及"哪些方面"、"什么原因"、"什么因素"时，使用 `multiSelect: true`。

### 3. 允许自定义 — 必须有 Other 选项

你无法预先覆盖所有情况，所有问题必须包含 "Other" 选项。

### AskUserQuestion 模板

```yaml
questions:
  - question: "问题陈述（可多选）"
    header: "标签"
    multiSelect: true
    options:
      - label: "MECE 维度 A"  description: "说明"
      - label: "MECE 维度 B"  description: "说明"
      - label: "Other"  description: "其他（请自定义输入）"
```

### 选项设计 Red Flags

出现以下信号时，**立即停止**，重新设计选项：
- 选项之间有明显重叠 → 基于 MECE 框架重新设计
- 用户说"原因是多个"但只能单选 → 改为 `multiSelect: true`
- 用户说"我的情况不在选项里" → 缺少 Other 选项，重新设计
- 没有基于任何框架直接编选项 → 先选择合适的框架

---

## 项目创建流程 (new 命令)

**项目存储位置**：所有项目统一存储在 **Wiki 知识空间 - PDCA** 下。

### 步骤 1：选择 MECE 框架并评估问题

根据用户描述的问题类型，选择对应的 MECE 框架，使用 AskUserQuestion 引导用户进行问题评估和分析。

### 步骤 2：创建项目文件夹结构

**⚠️ 使用 `wiki_space` 参数 + title 中的 `/` 自动创建文件夹结构。**

```
API: feishu_create_doc
参数:
  - wiki_space: "<PDCA 知识空间 ID>"
  - title: "[项目名称]/项目信息"
  - content: "# 项目信息\n..."
返回: document_id, url
```

创建首个文档时，飞书在 PDCA 知识空间下自动创建 `[项目名称]` 文件夹。

### 步骤 3：创建 Bitable 应用

```
API: feishu_bitable_app.create
参数:
  - name: "[项目名称] PDCA"
返回: app_token, app_url
```

### 步骤 4：创建 4 张核心数据表

为 Bitable 应用创建以下 4 张表，使用 `feishu_bitable_app_table.create`：

| 表名 | 用途 |
|------|------|
| 项目主表 (projects) | 项目核心信息与状态管理 |
| 任务数据表 (tasks) | 任务分解与执行跟踪 |
| 数据收集记录表 (data_records) | 测量数据与指标记录 |
| 执行日志表 (logs) | 过程记录与决策追溯 |

字段类型：文本 type=1, 数字 type=2, 单选 type=3, 日期 type=5（毫秒时间戳）, 人员 type=11, 多行文本 type=15, 超链接 type=15

详细字段定义见：[Bitable表结构定义.md](system/工具/Bitable表结构定义.md)

**⚠️ 人员字段**：`[{id: "ou_xxx"}]`，不能是字符串
**⚠️ 日期字段**：毫秒时间戳
**⚠️ 超链接字段**：创建时不要传 `property` 参数
**⚠️ 单选字段**：值是字符串，不是数组
**⚠️ 并发限制**：Bitable 不支持并发写，串行调用并延迟 0.5-1 秒

### 步骤 5：创建项目文档

使用 `feishu_create_doc` + `wiki_space` 参数，title 中用 `/` 保持文件夹结构：

```
API: feishu_create_doc
参数:
  - wiki_space: "<PDCA 知识空间 ID>"
  - title: "[项目名称]/Plan阶段/问题分析"
  - content: "# 问题分析\n..."
```

文档结构（Wiki 中通过 title 中的 `/` 自动创建）：
```
PDCA 知识空间/
├── [项目名称]/
│   ├── 项目信息.md（步骤 2 已创建）
│   ├── Plan阶段/
│   │   ├── 问题分析.md
│   │   ├── 目标设定.md
│   │   ├── 解决方案.md
│   │   └── 执行计划.md
│   ├── Do阶段/
│   ├── Check阶段/
│   ├── Act阶段/
│   └── 项目甘特图.md
└── 项目索引.md
```

### 步骤 6：创建项目甘特图

使用 `feishu_create_doc` + `wiki_space` 创建甘特图文档：

```
API: feishu_create_doc
参数:
  - wiki_space: "<PDCA 知识空间 ID>"
  - title: "[项目名称]/项目甘特图"
  - content: "<甘特图内容，包含任务、时间线、里程碑>"
```

甘特图应包含：
- 项目阶段时间线（Plan/Do/Check/Act）
- 关键任务节点
- 里程碑日期
- 负责人分配
- 完成进度标记

### 步骤 7：初始化项目主表记录

```
API: feishu_bitable_app_table_record.create
参数:
  - app_token: "<步骤 3 获取>"
  - table_id: "<项目主表ID>"
  - fields:
      项目ID: "<UUID>"
      项目名称: "[项目名称]"
      选择框架: "[选择的框架]"
      当前阶段: "Plan"
      状态: "正常"
      负责人: [{id: "ou_<用户ID>"}]
      开始日期: <当前毫秒时间戳>
      预计结束日期: <根据项目设定>
      完成度: 0
      文档链接: {link: "<项目文件夹 URL>", text: "查看文档"}
```

### 步骤 8：更新项目索引

使用 `feishu_update_doc` 更新 PDCA 知识空间根目录的"项目索引.md"文档，添加新项目的状态条记录。

**⚠️ 文档更新优先使用局部更新**（`replace_range`/`append`/`insert_before`/`insert_after`），慎用 `overwrite` 会丢失图片和评论。

## 渐进式披露：详细指南

根据当前任务，阅读对应的参考文档：

### 1. 飞书集成与主动驱动

- **API 调用与工具配置**：见 [feishu-integration.md](assets/references/feishu-integration.md)
- **自治巡检**：见 [cron-driving.md](assets/references/cron-driving.md)

### 2. Bitable 原生架构（一个项目一个应用）

- **表结构定义**：见 [Bitable表结构定义.md](system/工具/Bitable表结构定义.md)
- **收集表配置**：见 [收集表配置指南.md](system/工具/收集表配置指南.md)
- **仪表盘组件配置**：见 [仪表盘组件配置.md](system/工具/仪表盘组件配置.md)
- **工作流自动化配置**：见 [工作流自动化配置.md](system/工具/工作流自动化配置.md)
- **Bitable 应用文档模板**：见 [Bitable应用文档模板.md](system/工具/Bitable应用文档模板.md)
- **OpenClow API 集成**：见 [OpenClow API集成.md](system/工具/OpenClow API集成.md)

### 3. 各阶段执行 Agent

- **Plan 阶段 (规划/校验)**：见 [plan-agent.md](assets/references/plan-agent.md)
- **Do 阶段 (执行/日志)**：见 [do-agent.md](assets/references/do-agent.md)
- **Check 阶段 (数据/评估)**：见 [check-agent.md](assets/references/check-agent.md)
- **Act 阶段 (决策/沉淀)**：见 [act-agent.md](assets/references/act-agent.md)

### 4. 质量与逻辑校验 (Validators)

- **SMART 原则校验**：见 [transition-checklist.md](assets/references/transition-checklist.md)
- **因果逻辑链审查**：见 [exception-handling.md](assets/references/exception-handling.md)

### 5. 制造场景模板与其他

- **OEE/质量改善模板库**：见 [manufacturing-templates.md](assets/references/manufacturing-templates.md)
- **任务自动生成**：见 [任务自动生成器.md](system/工具/任务自动生成器.md)
- **智能巡检频率**：见 [智能巡检频率.md](system/工具/智能巡检频率.md)
- **仪表板生成**：见 [仪表板生成器.md](system/工具/仪表板生成器.md)
- **表单配置**：见 [表单配置生成器.md](system/工具/表单配置生成器.md)
- **仪表板模板**：见 [dashboard-templates.md](assets/references/dashboard-templates.md)

## 指令速查

| 指令 | 触发场景 | 输出 |
|------|---------|------|
| `new` | 启动新项目 | 在 PDCA Wiki 空间创建项目文件夹 + Bitable 应用（4张表）+ 项目文档 + 项目索引更新 |
| `ongoing` | 管理活跃项目 | 进度检查 + 状态更新 + 预警 |
| `achieve` | 检索经验库 | 最佳实践推荐 + 模板匹配 |

| API | 用途 |
|-----|------|
| `feishu_bitable_app.create` | 创建 Bitable 应用 |
| `feishu_bitable_app_table.create` | 创建数据表并定义字段 |
| `feishu_bitable_app_table_record.create` | 插入数据记录 |
| `feishu_bitable_app_table_record.update` | 更新数据记录 |
| `feishu_bitable_app_table_record.search` | 搜索数据记录 |
| `feishu_create_doc` | 创建 Wiki 文档（wiki_space + title 中 `/` 自动创建文件夹） |
| `feishu_update_doc` | 更新 Wiki 文档内容 |

| 阶段 | 核心交付物 | 校验标准 |
|------|-----------|---------|
| Plan | 问题分析、目标设定、解决方案 | SMART + 因果逻辑 |
| Do | 执行日志、进度报告、问题记录 | 任务完成率 + 数据完整性 |
| Check | 数据分析、效果评估、问题诊断 | 目标达成率 + 趋势分析 |
| Act | 行动决策、实施方案、知识总结 | 决策矩阵 + SOP 沉淀 |

## 核心规则

1. **Wiki 专属存储**：所有项目必须在 Wiki 知识空间「PDCA」下创建，**禁止使用云空间**
2. **数据事实来源**：飞书 Bitable 是项目状态的唯一事实来源
3. **主动上报**：巡检发现逻辑偏差或进度停滞，立即发送交互式卡片
4. **用户决策**：所有阶段转换和项目结项必须经过用户确认
5. **SMART 校验和因果逻辑验证是强制的，不可跳过**
6. **阶段转换严格按顺序，需要当前阶段所有必选任务完成**

## 通用 Red Flags

出现以下信号时，**立即停止**：
- **尝试在云空间创建项目** → 禁止！必须在 Wiki 知识空间「PDCA」下创建
- 目标没有具体数字 → 回到 Plan，完成 SMART 校验
- "执行中再调整" → 目标不够清晰
- "快速补救一下" → 补救≠符合标准
- "老板在催，先开始吧" → 权威压力不是降低标准的理由
- "已经花了 X 周了" → 沉没成本不是跳过检查的理由
- 直接接受用户提供的原因而不验证 → 用 MECE 框架逐维度扫描
- 跳过某个 MECE 维度 → 必须有数据支持才能判定不相关
- Bitable 创建失败 → 向用户报告错误，不要在错误位置创建文件
- `wiki_space` 参数未配置 → 确认 PDCA 知识空间 ID 已配置

## Rationalization 防御

| 借口 | 现实 |
|------|------|
| "云空间创建更方便" | 禁止！PDCA 项目必须在 Wiki 知识空间管理，云空间无法支持 `/` 语法创建文件夹结构 |
| "Bitable 创建太复杂，先建文档" | 文档无法做数据管理，没有 Bitable 的核心功能就失去 PDCA 系统的价值 |
| "用户急着要，我先建文档" | 文档不等于项目管理系统，匆忙创建错误结构更难修复 |
| "MECE 太复杂，简单问一下就行" | 简单提问 = 遗漏关键因素，后期返工更浪费时间 |
| "选项已经覆盖所有情况了" | 你无法预知所有情况，必须有 Other 选项 |
| "用户已经说了原因，不需要再分析" | 用户说的是症状，不是根因 |
| "单选就够了" | 现实中问题往往是多因素导致的，限制用户只能选一个会遗漏原因 |
| "整篇 overwrite 覆盖更快" | overwrite 会清空文档重写，丢失图片、评论、协作历史 |
| "简单项目不需要完整的 PDCA 结构" | 简单项目也需要完整的 PDCA 结构，才能保证质量 |

**Violating the letter of the rules is violating the spirit of the rules.**

## 关键指令集

- **`new`**：初始化新项目
- **`ongoing`**：管理活跃项目
- **`achieve`**：检索经验库
