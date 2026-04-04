# Bitable 原生架构实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 PDCA 系统升级为"一个项目一个 Bitable 应用"的原生架构，利用 Bitable 内置任务、收集表、仪表盘和工作流实现统一管理

**Architecture:** Wiki 保留为详细文档存储，每个项目创建独立的 Bitable 应用，内含项目主表、任务数据表（任务即数据行）、数据记录表、执行日志表，并配置收集表、仪表盘和工作流自动化

**Tech Stack:** 飞书 Bitable API (数据表/收集表/仪表盘/工作流), Wiki API, OpenClow HTTP API, Markdown

---

## 文件结构概览

### 新建文件
- `_系统/工具/收集表配置指南.md` — 按框架维度配置收集表的字段映射
- `_系统/工具/仪表盘组件配置.md` — Bitable 仪表盘各组件的数据绑定配置
- `_系统/工具/工作流自动化配置.md` — 定时触发和数据事件触发的工作流配置
- `_系统/工具/OpenClow API集成.md` — OpenClow `/pdca/analyze` 接口的调用规范

### 修改文件
- `_系统/工具/Bitable表结构定义.md` — 更新为新架构的 4 张表定义（任务即数据行、新增关联记录字段）
- `_系统/Agent/PlanAgent.md` — Phase 4 创建 Bitable 应用时增加收集表/仪表盘/工作流配置
- `_系统/Agent/PDCA控制器.md` — 巡检逻辑改为从 Bitable 工作流触发
- `pdca/SKILL.md` — 更新项目创建流程描述
- `pdca/references/feishu-integration.md` — 更新 Bitable 表结构引用、新增收集表/仪表盘/工作流 API 模式

---

## Task 1: 更新 Bitable 表结构定义

**Files:**
- Modify: `_系统/工具/Bitable表结构定义.md`

**目标：** 将现有 4 张表定义更新为 Bitable 原生架构的设计

- [ ] **Step 1: 更新表 1 项目主表**

移除 `巡检频率` 和 `频率来源` 字段（由 Bitable 工作流管理），新增 `Bitable链接` 字段：

```markdown
## 表 1: 项目主表 (projects)

### 字段定义

| 字段名 | 类型 | type值 | 说明 | 值格式 | 必填 |
|--------|------|--------|------|--------|------|
| 项目ID | 文本 | 1 | 唯一标识符 | UUID 字符串 | 是 |
| 项目名称 | 文本 | 1 | 项目标题 | 字符串 | 是 |
| 选择框架 | 单选 | 3 | MECE 分析框架 | 4M1E/TREND/PPTD/5P/COMET/3RL-TD/GRCT/5S/TIME/SIPOC/5P2E | 是 |
| 当前阶段 | 单选 | 3 | PDCA 当前阶段 | Plan/Do/Check/Act/已完成 | 是 |
| 状态 | 单选 | 3 | 项目健康状态 | 正常/预警/超时/已完成 | 是 |
| 负责人 | 人员 | 11 | 项目负责人 | `[{id: "ou_xxx"}]` | 是 |
| 开始日期 | 日期 | 5 | 项目启动日期 | 毫秒时间戳 | 是 |
| 预计结束日期 | 日期 | 5 | 计划结束日期 | 毫秒时间戳 | 是 |
| 完成度 | 数字 | 2 | 项目完成百分比 | 0-100 | 是 |
| Bitable链接 | 超链接 | 15 | Bitable 应用链接 | `{link: "url", text: "标题"}` | 是 |
| Wiki链接 | 超链接 | 15 | Wiki 项目节点链接 | `{link: "url", text: "标题"}` | 是 |
```

- [ ] **Step 2: 更新表 2 任务表（任务即数据行）**

任务表不再同步飞书 Task，改为"任务即数据行"模式，新增 `数据记录`（关联记录）和 `完成度`（数字）字段，移除 `飞书任务ID` 字段：

```markdown
## 表 2: 任务数据表 (tasks)

### 设计原则：任务即数据行

任务直接在 Bitable 数据表中管理，任务状态作为列存在，不再依赖飞书 Task。
每行既是任务也是数据记录，支持直接关联到数据记录表的测量数据。

### 字段定义

| 字段名 | 类型 | type值 | 说明 | 值格式 | 必填 |
|--------|------|--------|------|--------|------|
| 任务ID | 文本 | 1 | 唯一标识符 | 如 "TASK-001" | 是 |
| 任务标题 | 文本 | 1 | 任务名称 | 字符串 | 是 |
| 任务状态 | 单选 | 3 | 任务状态 | 未开始/进行中/已完成/已取消 | 是 |
| 任务描述 | 多行文本 | 15 | 详细说明 | 长文本 | 否 |
| 来源维度 | 单选 | 3 | MECE 框架维度 | 根据选择框架动态生成 | 是 |
| 截止日期 | 日期 | 5 | 任务截止时间 | 毫秒时间戳 | 是 |
| 负责人 | 人员 | 11 | 任务负责人 | `[{id: "ou_xxx"}]` | 是 |
| 优先级 | 单选 | 3 | 任务优先级 | 高/中/低 | 是 |
| **数据记录** | **关联记录** | **18** | **关联到数据记录表** | `["记录ID1", "记录ID2"]` | 否 |
| **完成度** | **数字** | **2** | **完成百分比** | 0-100 | 是 |
| 创建时间 | 日期时间 | 5 | 任务创建时间 | 毫秒时间戳 | 是 |
| 完成时间 | 日期时间 | 5 | 任务完成时间 | 毫秒时间戳 | 否 |
```

- [ ] **Step 3: 更新表 4 执行日志表**

新增 `AI洞察` 日志类型：

```markdown
### 字段 property 配置示例

{
  "日志类型": {
    "type": 3,
    "property": {
      "options": [
        {"name": "进展更新"},
        {"name": "问题记录"},
        {"name": "决策记录"},
        {"name": "AI洞察"}
      ]
    }
  }
}
```

- [ ] **Step 4: 更新表关系说明**

```markdown
## 数据关系图

```
项目主表 (projects)
    ├── 1:N → 任务数据表 (tasks)
    ├── 1:N → 数据记录表 (data_records)
    └── 1:N → 执行日志表 (logs)

任务数据表 ──(关联记录)──→ 数据记录表
（每行任务可关联多条数据记录）
```

```

---

## Task 2: 创建收集表配置指南

**Files:**
- Create: `_系统/工具/收集表配置指南.md`

- [ ] **Step 1: 创建收集表配置文档**

```markdown
# Bitable 收集表配置指南

## 概述

Bitable 收集表用于用户快速录入数据，提交后数据自动写入数据记录表。
每个框架维度配置一个独立的收集表。

## 创建流程

```
项目创建时 (PlanAgent Phase 4)
    ↓
根据选择的 MECE 框架 → 获取维度列表
    ↓
为每个维度创建对应的收集表
    ↓
收集表字段 → 绑定到数据记录表的 指标名称/维度/数值/单位
    ↓
分享收集表链接 → 用户通过链接填写
```

## 收集表 API 创建

```bash
# 创建收集表（通过 Bitable 工作流或 API）
feishu_bitable_app_form.create \
  --app_token "<app_token>" \
  --table_id "<table_id>" \
  --name "[维度名称]数据收集表" \
  --fields '[
    {"field_name": "指标名称", "type": "text", "required": true},
    {"field_name": "维度", "type": "select", "required": true, "options": ["[维度]"]},
    {"field_name": "数值", "type": "number", "required": true},
    {"field_name": "单位", "type": "text", "required": true}
  ]'
```

## 各框架收集表配置

详见 `pdca/references/form-configs.md`（由 PlanAgent Phase 4 引用）。
```

---

## Task 3: 创建仪表盘组件配置指南

**Files:**
- Create: `_系统/工具/仪表盘组件配置.md`

- [ ] **Step 1: 创建仪表盘配置文档**

```markdown
# Bitable 仪表盘组件配置

## 概述

Bitable 仪表盘为项目提供实时的可视化展示，所有组件绑定到 Bitable 数据表作为数据源。

## 仪表盘组件列表

### 1. 核心指标区
- **类型**: 指标卡片
- **数据源**: 项目主表
- **指标映射**:
  | 指标 | 字段 | 展示方式 |
  |------|------|---------|
  | 目标达成度 | 完成度 | 进度条 (0-100%) |
  | 剩余天数 | 预计结束日期 vs 当前日期 | 计算值 |
  | 当前阶段 | 当前阶段 | 文本标签 |
  | 任务完成率 | 任务表 (状态=已完成 / 总数) | 百分比 |

### 2. 框架维度进度区
- **类型**: 分组柱状图
- **数据源**: 任务数据表
- **分组字段**: 来源维度
- **指标**: 任务状态分布
- **交互**: 点击维度 → 筛选显示该维度任务

### 3. 任务列表区
- **类型**: 表格视图
- **数据源**: 任务数据表
- **筛选条件**: 任务状态 != "已取消"
- **排序**: 优先级 DESC, 截止日期 ASC
- **显示字段**: 任务标题、任务状态、负责人、截止日期、完成度

### 4. 数据趋势图
- **类型**: 折线图
- **数据源**: 数据记录表
- **X轴**: 记录时间
- **Y轴**: 数值
- **系列**: 按指标名称分组

### 5. 执行日志区
- **类型**: 列表视图
- **数据源**: 执行日志表
- **排序**: 记录时间 DESC
- **显示条数**: 最近 10 条
- **显示字段**: 阶段、日志类型、内容、记录时间

### 6. AI 洞察区
- **类型**: 文本卡片
- **数据源**: 执行日志表 (筛选 日志类型=AI洞察)
- **排序**: 记录时间 DESC
- **显示条数**: 最近 5 条
```

---

## Task 4: 创建工作流自动化配置

**Files:**
- Create: `_系统/工具/工作流自动化配置.md`

- [ ] **Step 1: 创建工作流配置文档**

```markdown
# Bitable 工作流自动化配置

## 概述

利用 Bitable 工作流替代 Cron 实现自动化，支持定时触发和数据事件触发。

## 工作流 1: PDCA 每日巡检

### 触发条件
- **类型**: 定时触发
- **频率**: 根据项目类型配置
  - 健康/体能（TREND）: 每日 08:00
  - 制造业（4M1E）: 每 8 小时
  - 学习/教育（COMET）: 每周一 09:00

### 工作流步骤
```
1. 触发器: 定时触发
    ↓
2. HTTP 请求: 调用 OpenClow /pdca/analyze
   POST https://<openclow-host>/pdca/analyze
   Headers: { Authorization: "Bearer <api_key>" }
   Body: {
     "project": "{{项目主表.项目名称}}",
     "trigger": "scheduled",
     "context": {}
   }
    ↓
3. 解析响应: insights, actions, updates
    ↓
4. 更新 Bitable: 更新项目主表状态和完成度
    ↓
5. 追加执行日志: 插入 日志类型=AI洞察 的记录
    ↓
6. 发送消息卡片: 向用户推送分析结果
```

## 工作流 2: 数据提交触发分析

### 触发条件
- **类型**: 数据事件触发
- **事件**: 数据记录表新增记录

### 工作流步骤
```
1. 触发器: 数据记录表 → 新增记录
    ↓
2. HTTP 请求: 调用 OpenClow /pdca/analyze
   Body: {
     "project": "{{项目主表.项目名称}}",
     "trigger": "event",
     "context": {
       "trigger_type": "form_submit",
       "data_record_id": "{{新记录.record_id}}"
     }
   }
    ↓
3. 解析响应
    ↓
4. 更新执行日志 (AI洞察)
    ↓
5. 发送消息卡片
```

## 工作流 3: 任务状态变更通知

### 触发条件
- **类型**: 数据事件触发
- **事件**: 任务数据表.任务状态 变更为"已完成"

### 工作流步骤
```
1. 触发器: 任务数据表 → 任务状态 变更为 已完成
    ↓
2. 追加执行日志: 日志类型=进展更新
   内容: "任务 {{任务标题}} 已完成"
    ↓
3. 更新项目主表完成度: 重新计算
   完成度 = (状态=已完成的记录数 / 总记录数) * 100
    ↓
4. 发送消息卡片: 通知任务完成
```

## OpenClow 调用配置

所有工作流通过 HTTP 节点调用 OpenClow API：

- **Endpoint**: `POST /pdca/analyze`
- **认证**: Bearer Token
- **超时**: 30 秒
- **重试**: 失败时重试 2 次，间隔 5 秒
```

---

## Task 5: 创建 OpenClow API 集成文档

**Files:**
- Create: `_系统/工具/OpenClow API集成.md`

- [ ] **Step 1: 创建 OpenClow API 集成文档**

```markdown
# OpenClow API 集成

## 概述

OpenClow 通过 `/pdca/analyze` 端点提供 PDCA 项目的 AI 分析能力。

## 接口定义

### POST /pdca/analyze

**请求体**:
```json
{
  "project": "[项目名称]",
  "trigger": "scheduled|event|manual",
  "context": {
    "trigger_type": "form_submit|task_complete|scheduled",
    "data_record_id": "[记录ID]",
    "task_id": "[任务ID]"
  }
}
```

**响应体**:
```json
{
  "status": "success",
  "insights": ["AI 分析结果1", "AI 分析结果2"],
  "actions": ["建议操作1", "建议操作2"],
  "updates": {
    "wiki": ["需要更新的 Wiki 文档路径"],
    "bitable": {
      "project_completion": 65,
      "project_status": "正常",
      "task_updates": []
    }
  }
}
```

## 调用方式

### 从 Bitable 工作流调用

工作流中的 HTTP 节点配置：
- **URL**: `https://<openclow-host>/pdca/analyze`
- **Method**: `POST`
- **Headers**: `{"Authorization": "Bearer ${OPENCLOW_API_KEY}"}`
- **Body**: 动态填充项目名和上下文

### 从 PDCA 控制器调用

当工作流不可用时，PDCA 控制器可以直接调用：
```bash
curl -X POST https://<openclow-host>/pdca/analyze \
  -H "Authorization: Bearer ${OPENCLOW_API_KEY}" \
  -d '{"project": "项目名称", "trigger": "manual"}'
```

## AI 分析职责

1. **读取 Bitable 数据**: 读取项目主表、任务表、数据记录表的当前状态
2. **读取 Wiki 文档**: 读取各阶段文档完成度
3. **计算完成度**: 根据阶段交付物清单计算百分比
4. **状态判定**: 判断正常/预警/超时
5. **趋势分析**: 分析数据记录的变化趋势
6. **生成洞察**: 输出分析结果和建议

## 错误处理

- **超时**: 30 秒超时，返回 `{"status": "timeout"}`
- **API 错误**: 返回 `{"status": "error", "message": "错误描述"}`
- **无新数据**: 返回 `{"status": "no_changes", "message": "自上次分析无新数据"}`
```

---

## Task 6: 更新 PlanAgent Phase 4 — 创建 Bitable 应用完整流程

**Files:**
- Modify: `_系统/Agent/PlanAgent.md`

**目标：** 更新 PlanAgent 的阶段 4，使其包含 Bitable 原生能力的创建（收集表、仪表盘、工作流）

关键变更：
- 创建 Bitable 应用 + 4 张表后，继续创建收集表、仪表盘、工作流
- 每个框架维度创建一个收集表
- 配置仪表盘绑定数据源
- 创建工作流（定时触发 + 数据事件触发）
- 在 Wiki 中记录 Bitable 应用链接

具体步骤参考设计文档 `docs/superpowers/specs/2026-04-04-bitable-native-architecture-design.md` 的"6.1 创建步骤"。

- [ ] **Step 1: 更新 Phase 4 为"创建 Bitable 应用"**

在 `PlanAgent.md` 中找到现有的 Phase 4 相关描述，替换为：

```markdown
## Phase 4: 创建 Bitable 应用

### 步骤 1: 创建 Bitable 应用和基础表
1. `feishu_bitable_app.create` 创建 Bitable 应用
2. 创建 4 张数据表（项目主表、任务数据表、数据记录表、执行日志表）
   - 字段定义见 `_系统/工具/Bitable表结构定义.md`

### 步骤 2: 创建收集表
1. 根据选择的 MECE 框架，为每个维度创建一个收集表
   - 配置见 `_系统/工具/收集表配置指南.md`
2. 收集表提交的数据自动写入数据记录表

### 步骤 3: 配置仪表盘
1. 创建仪表盘（核心指标、维度进度、任务列表、数据趋势、执行日志、AI 洞察）
   - 配置见 `_系统/工具/仪表盘组件配置.md`
2. 所有组件绑定到对应的数据表

### 步骤 4: 创建工作流
1. 创建"PDCA 每日巡检"工作流（定时触发 → OpenClow API → 更新 Bitable → 发送卡片）
2. 创建"数据提交触发分析"工作流（事件触发 → OpenClow API）
3. 创建"任务状态变更通知"工作流
   - 配置见 `_系统/工具/工作流自动化配置.md`

### 步骤 5: 在 Wiki 中记录链接
`feishu_update_doc` — 在 Wiki 项目信息中更新 Bitable 应用链接

### 步骤 6: 按框架生成初始任务
按 MECE 框架维度生成任务写入任务数据表。
```

---

## Task 7: 更新 PDCA 控制器和工作流集成

**Files:**
- Modify: `_系统/Agent/PDCA控制器.md`
- Modify: `pdca/references/feishu-integration.md`

**目标：** 巡检逻辑改为从 Bitable 工作流触发为主，Cron 作为备用

- [ ] **Step 1: 更新 PDCA 控制器的巡检触发方式**

在 `PDCA控制器.md` 的"智能巡检频率"部分添加：

```markdown
## 🔄 Bitable 工作流巡检

### 主要巡检方式：Bitable 工作流

1. **定时巡检**: Bitable 内置工作流按项目类型配置的频率触发
   - 工作流 → 调用 OpenClow /pdca/analyze → 更新 Bitable 数据 → 发送卡片

2. **事件驱动巡检**: 数据提交或任务完成时自动触发
   - 收集表提交 → 触发工作流 → OpenClow 分析
   - 任务状态变更 → 触发工作流 → 更新完成度

3. **手动巡检**: 用户通过飞书卡片或 API 手动触发

### 备用巡检方式：Cron

当 Bitable 工作流不可用时，使用 System Cron 作为备用：
- `cron add` 创建定时任务
- 任务执行 `pdca ongoing --project "<name>"`
- 巡检结果通过飞书消息推送

### 巡检统一入口

无论触发方式如何，最终都调用 OpenClow `/pdca/analyze` 端点进行分析。
```

- [ ] **Step 2: 更新 feishu-integration.md 添加收集表/仪表盘/工作流/文档 API 模式**

在 `pdca/references/feishu-integration.md` 的 Bitable 章节后添加新章节：

```markdown
## 1.5 飞书 Bitable 收集表

### AI 主动操作
- **创建收集表**: 通过 Bitable 工作流编辑器或 API
- **字段绑定**: 收集表字段映射到数据记录表字段
- **分享链接**: 获取收集表分享链接发送给用户

## 1.6 飞书 Bitable 仪表盘

### AI 主动操作
- **创建仪表盘**: 在 Bitable 应用中创建仪表盘视图
- **绑定数据源**: 将组件绑定到数据表字段
- **配置组件**: 设置图表类型、筛选条件、排序规则

## 1.7 飞书 Bitable 工作流

### AI 主动操作
- **创建工作流**: 通过 Bitable 工作流编辑器
- **定时触发**: 设置 cron 表达式和调用参数
- **事件触发**: 配置数据变更触发条件
- **HTTP 调用**: 配置 OpenClow API 端点和认证

## 2. 飞书 Wiki（知识库）— 文档存储

### 与 Bitable 的关联
- Wiki 项目信息中包含 Bitable 应用链接
- AI 分析后通过 `feishu_update_doc` 更新 Wiki 文档
- Wiki 作为详细文档的存储，Bitable 作为数据管理
```

---

## Task 8: 更新 pdca/SKILL.md

**Files:**
- Modify: `pdca/SKILL.md`

**目标：** 更新项目创建流程，反映 Bitable 原生架构

关键变更：
- 项目创建描述更新为"创建 Wiki + Bitable 应用（含收集表/仪表盘/工作流）"
- 引用新增的配置文档
- 更新核心工作流描述

---

## 实施顺序建议

```
Task 1 (表结构更新) → Task 2 (收集表) → Task 3 (仪表盘) → Task 4 (工作流) → Task 5 (OpenClow API) → Task 6 (PlanAgent) → Task 7 (控制器) → Task 8 (SKILL.md)
```

每个 Task 完成后都应提交 commit。

---

## 注意事项

1. **向后兼容**：现有项目仍可使用旧架构，新项目采用 Bitable 原生架构
2. **Bitable 字段类型 18（关联记录）**：需确认飞书 API 是否支持，如不支持则用文本字段存储关联 ID 列表
3. **工作流创建 API**：飞书 Bitable 工作流的 API 能力需要验证，可能需要手动在 UI 中配置
4. **OpenClow API 端点**：需要 OpenClow 侧先实现 `/pdca/analyze` 端点
5. **Wiki 和 Bitable 链接**：双向链接需要正确维护
