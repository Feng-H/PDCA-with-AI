# 飞书工具链集成指南

PDCA skill 与飞书全工具链的集成方式，实现文档存储、知识沉淀、进度可视化、任务管理、时间管理的完整闭环。

## 工具链概览

```
飞书 Wiki（知识库）
  ├── 项目文档（Plan/Do/Check/Act 各阶段模板）
  ├── 经验库（已完成项目沉淀）
  └── SOP 文档库（标准化流程）

飞书 Bitable（多维表格）
  ├── PDCA项目看板（所有项目状态一览）
  ├── 阶段转换记录表
  └── 交付物检查清单

飞书 Task（任务）
  ├── 各阶段具体待办事项
  ├── 负责人分配
  └── 截止日期追踪

飞书 Calendar（日历）
  ├── 阶段里程碑时间节点
  ├── 阶段截止日
  └── 评审/复盘会议

飞书 Sheet（电子表格）
  ├── 数据收集模板
  ├── 效果对比分析（改善前 vs 改善后）
  └── 统计图表

AI Agent（OpenClaw）
  ├── 读写上述所有工具
  ├── 主动判断进展
  ├── 定时提醒和催办
  └── 自动生成报告
```

## 1. 飞书 Wiki（知识库）— 项目主存储

### Wiki 层级结构规范

#### 根节点：PDCA项目管理

所有 PDCA 项目必须创建在 **"PDCA项目管理"** 根节点下。这是项目文档的唯一事实来源。

#### 完整层级结构

```
飞书 Wiki 知识空间
└── PDCA项目管理（根节点，space_node_id: 需在 SKILL.md 中配置）
    ├── 📊 项目索引.md（跟踪展示所有项目进展）
    │   └── 内容：项目名称、当前阶段、状态、负责人、开始日期、完成度
    │
    └── 📁 [项目名称]/（子节点，每个项目一个）
        ├── 📋 项目信息.md
        ├── 📁 Plan阶段/
        │   ├── 问题分析.md
        │   ├── 目标设定.md
        │   ├── 解决方案.md
        │   └── 执行计划.md
        ├── 📁 Do阶段/
        │   ├── 执行日志.md
        │   ├── 进度报告.md
        │   └── 问题记录.md
        ├── 📁 Check阶段/
        │   ├── 数据分析.md
        │   ├── 效果评估.md
        │   └── 问题诊断.md
        └── 📁 Act阶段/
            ├── 行动决策.md
            ├── 实施方案.md
            └── 知识总结.md
```

#### 项目索引规范

**文件名**：`📊 项目索引.md`
**位置**：PDCA项目管理/项目索引.md
**内容格式**：

```markdown
# PDCA 项目索引

更新时间：YYYY-MM-DD HH:mm

## 活跃项目

| 项目名称 | 当前阶段 | 状态 | 负责人 | 开始日期 | 完成度 | Wiki链接 |
|---------|---------|------|--------|---------|--------|----------|
| 挖掘机臂架开裂改善 | Plan | 🟡 正常 | 张三 | 2024-03-15 | 30% | [查看](wiki_url) |
| 提升核心机加设备OEE | Do | 🔴 预警 | 李四 | 2024-03-01 | 65% | [查看](wiki_url) |

## 已完成项目

| 项目名称 | 完成日期 | 最终达成度 | 负责人 | Wiki链接 |
|---------|---------|-----------|--------|----------|
| 焊接工艺优化 | 2024-02-28 | 95% | 王五 | [查看](wiki_url) |
```

#### 项目节点创建流程

**⚠️ 强制要求**：创建新项目时，必须按照以下顺序执行：

**前置条件**：必须先获取 `space_id` 和根节点 `parent_node_token`

**步骤 0：获取必要信息**
```bash
# 获取知识空间列表，找到 PDCA 项目管理的 space_id
feishu_wiki_space_list

# 获取空间下的节点列表，找到"PDCA项目管理"根节点的 node_token
feishu_wiki_space_node.list --space_id "<space_id>"
```

**步骤 1：确认/创建根节点**
- 调用 `feishu_wiki_space_node.list --space_id "<space_id>"` 检查"PDCA项目管理"节点是否存在
- 如果存在，记录其 `node_token` 作为 `parent_node_token`
- 如果不存在：
  - 调用 `feishu_wiki_space_node.create` 创建根节点
  - 参数：`space_id`, `parent_node_token`（根目录为空或 space 本身）, `title="PDCA项目管理"`
  - **创建失败处理**：如果失败，**停止整个流程**，向用户报告错误，不要在其他地方创建文件

**步骤 2：创建项目子节点**
- 使用 `feishu_wiki_space_node.create` 在根节点下创建项目文件夹
- **必填参数**：
  - `space_id`: 知识空间 ID
  - `parent_node_token`: "PDCA项目管理"根节点的 node_token
  - `object_type`: "wiki" 或 "folder"
  - `title`: 项目名称
- **创建失败处理**：如果失败，**停止整个流程**，向用户报告错误，不要在其他地方创建文件

**步骤 3：创建阶段子节点**
- 使用 `feishu_wiki_space_node.create` 在项目节点下创建阶段文件夹
- 依次创建：`Plan阶段`、`Do阶段`、`Check阶段`、`Act阶段`
- **创建失败处理**：任何一个失败，**停止整个流程**，向用户报告错误

**步骤 4：创建模板文档**
- 使用 `feishu_create_doc` 在各阶段文件夹下创建文档
- **创建失败处理**：如果失败，**停止整个流程**，向用户报告错误

**步骤 5：更新项目索引**
- 使用 `feishu_update_doc` 更新 `📊 项目索引.md`

---

### ⚠️ Wiki 节点创建错误处理规范

**绝对禁止的行为**：
- ❌ **禁止**因为 wiki_node 创建失败就在其他地方（如根目录、桌面等）创建文件
- ❌ **禁止**跳过 wiki_node 创建，直接创建文档
- ❌ **禁止**使用本地文件系统作为 fallback

**正确的错误处理**：
1. **第一次失败**：检查参数是否正确（space_id、parent_node_token、title）
2. **第二次失败**：检查权限是否足够（是否有在该空间创建节点的权限）
3. **第三次失败**：**停止流程**，向用户报告具体错误信息

**错误报告模板**：
```
⚠️ Wiki 节点创建失败

错误信息：[具体的 API 错误信息]
尝试的操作：创建节点 [节点名称] 在父节点 [父节点名称] 下

请检查：
1. space_id 是否正确
2. parent_node_token 是否正确
3. 是否有足够的权限

流程已停止，没有在任何其他位置创建文件。
```

---

### Wiki 节点创建详细调用示例

**创建根节点**：
```json
{
  "space_id": "your_space_id",
  "parent_node_token": "",  // 空表示在空间根目录创建
  "object_type": "folder",
  "title": "PDCA项目管理"
}
```

**创建项目子节点**：
```json
{
  "space_id": "your_space_id",
  "parent_node_token": "root_node_token",  // PDCA项目管理的 node_token
  "object_type": "folder",
  "title": "提升核心机加设备OEE"
}
```

**创建阶段子节点**：
```json
{
  "space_id": "your_space_id",
  "parent_node_token": "project_node_token",  // 项目节点的 node_token
  "object_type": "folder",
  "title": "Plan阶段"
}
```

**创建文档**：
```json
{
  "space_id": "your_space_id",
  "parent_node_token": "phase_node_token",  // 阶段节点的 node_token
  "title": "问题分析.md",
  "content": "# 问题分析\n..."
}
```

### 创建项目时
1. 调用 `feishu_wiki_space_node.create` 在知识空间中创建项目节点
2. 在项目下创建 4 个阶段子节点（Plan/Do/Check/Act）
3. 用 `feishu_create_doc` 为每个阶段创建模板文档（内容参考 `assets/project-template.md`）

### AI 主动操作
- **读取**：用 `feishu_fetch_doc` 读取文档内容，检查必填项完成度
- **更新**：用 `feishu_update_doc` 更新文档内容
- **创建**：用 `feishu_create_doc` + `feishu_wiki_space_node.create` 创建文档和节点

### 知识沉淀
项目结束后：
1. 将「知识总结.md」的关键内容提取到经验库文档
2. 经验库按类别组织（设备类、质量类、效率类、成本类）
3. 经验库中标注适用场景和关键指标
4. 新项目启动时，AI 主动检索经验库，推荐可复用的经验

### Wiki 节点结构
```
PDCA知识空间（space_id 已在 SKILL.md 中记录）
├── 项目名称（wiki 节点）
│   ├── 📋 项目信息.md
│   ├── 📁 Plan阶段/
│   ├── 📁 Do阶段/
│   ├── 📁 Check阶段/
│   └── 📁 Act阶段/
├── 📊 项目索引.md
└── 📚 经验库/
    ├── 设备类经验.md
    ├── 质量类经验.md
    └── 效率类经验.md
```

## 2. 飞书 Bitable（多维表格）— 可视化看板

### 创建项目时
用 `feishu_bitable_app.create` 创建多维表格，再用 `feishu_bitable_app_table.create` 创建数据表并定义字段。

**字段设计**（创建时通过 `fields` 参数一次性定义）：

| 字段名 | type | 说明 | 值格式 |
|--------|------|------|--------|
| 项目名称 | 1（文本） | 项目标题 | 字符串 |
| 当前阶段 | 3（单选） | Plan/Do/Check/Act/已完成 | 字符串，property 中定义 options |
| 状态 | 3（单选） | 正常/预警/超时/已完成 | 字符串，property 中定义 options |
| 负责人 | 11（人员） | 项目负责人 | `[{id: "ou_xxx"}]` |
| 开始日期 | 5（日期） | 项目启动日期 | 毫秒时间戳 |
| 阶段截止日 | 5（日期） | 当前阶段计划结束日期 | 毫秒时间戳 |
| 完成度 | 2（数字） | 0-100 | 数字 |
| 问题类型 | 3（单选） | 设备/质量/效率/成本/流程/管理 | 字符串 |
| 优先级 | 3（单选） | 高/中/低 | 字符串 |
| 知识库链接 | 15（超链接） | 飞书 Wiki 项目节点链接 | `{link: "url", text: "标题"}` |

> ⚠️ **重要坑位**（详见 `feishu-bitable` skill）：
> - 人员字段值必须是 `[{id: "ou_xxx"}]`，不能传字符串
> - 日期字段值是**毫秒时间戳**，不是秒
> - 单选字段值是**字符串**，不是数组
> - 超链接字段(type=15) 创建时**不要传 property 参数**，否则报错
> - 创建数据表前先查字段类型：`feishu_bitable_app_table_field.list`
> - 默认表有空行，插入前先删除：`list` + `batch_delete`
> - 同一表不支持并发写，串行调用 + 延迟 0.5-1 秒

### AI 主动操作
- **创建项目**：`feishu_bitable_app_table_record.create`
- **阶段转换**：`feishu_bitable_app_table_record.update` 更新「当前阶段」「阶段截止日」
- **自动巡检**：
    1. **搜索待巡检记录**：使用 `feishu_bitable_app_table_record.search` 查找 `状态` 不等于 "已完成" 且 `项目名称` 匹配的项目。
    2. **计算完成度**：AI 读取对应的 Wiki 文档和 Sheet 数据，根据阶段交付物清单计算 `完成度`（0-100）。
    3. **状态判定**：
        - 正常：当前日期 < 阶段截止日 且 进度符合预期。
        - 预警：当前日期接近阶段截止日（如剩余 20% 时间）且 进度滞后。
        - 超时：当前日期 > 阶段截止日。
    4. **更新记录**：调用 `feishu_bitable_app_table_record.update` 更新「完成度」和「状态」字段。
- ⚠️ **「剩余天数」不由公式计算**（Bitable 不支持公式字段），由 AI 每次巡检时计算后写入

## 3. 飞书消息卡片（Interactive Cards）

用于推送预警信息和交互确认。

### 卡片 JSON 模板 (feishu-card)

```json
{
  "config": {
    "wide_screen_mode": true
  },
  "header": {
    "title": {
      "tag": "plain_text",
      "content": "⚠️ PDCA 项目预警"
    },
    "template": "orange"
  },
  "elements": [
    {
      "tag": "div",
      "text": {
        "tag": "lark_md",
        "content": "**项目名称**：${project_name}\n**当前阶段**：${current_phase}"
      }
    },
    {
      "tag": "div",
      "fields": [
        {
          "is_short": false,
          "text": {
            "tag": "lark_md",
            "content": "**预警原因**：\n${warning_reason}"
          }
        },
        {
          "is_short": true,
          "text": {
            "tag": "lark_md",
            "content": "**当前值**：\n${current_value}"
          }
        },
        {
          "is_short": true,
          "text": {
            "tag": "lark_md",
            "content": "**期望值**：\n${expected_value}"
          }
        }
      ]
    },
    {
      "tag": "hr"
    },
    {
      "tag": "action",
      "actions": [
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "确认/修改进度"
          },
          "type": "primary",
          "multi_url": {
            "url": "${wiki_url}",
            "pc_url": "",
            "android_url": "",
            "ios_url": ""
          }
        },
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "查看项目 Wiki"
          },
          "type": "default",
          "multi_url": {
            "url": "${wiki_url}",
            "pc_url": "",
            "android_url": "",
            "ios_url": ""
          }
        }
      ]
    }
  ]
}
```

## 4. 飞书 Task（任务）— 阶段待办管理

### 创建项目时
根据执行计划，用 `feishu_task_task.create` 创建飞书任务：
- `summary`：任务编号 + 任务描述（如「T001 收集设备停机数据」）
- `members`：指定负责人（assignee）和关注人（follower）
- `due`：按执行计划设定截止时间
- `description`：包含任务要求、交付物标准

### AI 主动操作
- **创建**：`feishu_task_task.create`
- **检查**：`feishu_task_task.list` 查询任务状态
- **更新**：`feishu_task_task.patch` 标记完成或调整截止日期

### 注意
- Task 工具需要在 `openclaw.json` 中保持启用：`tools.deny` 中不包含 task 相关工具名
- 当前所有 task 工具已可用（`feishu_task_task`、`feishu_task_tasklist`、`feishu_task_comment`、`feishu_task_subtask`）

## 4. 飞书 Calendar（日历）— 时间节点管理

### 创建项目时
用 `feishu_calendar_event.create` 为关键时间节点创建日历事件。

> ⚠️ **必填参数**：
> - `summary`（标题）、`start_time`、`end_time` 是最小必填
> - **`user_open_id` 强烈建议传入**（从 SenderId 获取 `ou_xxx`），确保用户作为参会人能看到日程
> - 时间格式：ISO 8601 带时区，如 `2026-04-10T18:00:00+08:00`

为以下时间节点创建事件：
- 各阶段截止日（如「PDCA-xxx Plan阶段截止」）
- 里程碑日期（如「PDCA-xxx 数据收集完成」）
- 评审会议（如「PDCA-xxx Check阶段评审会」）

### AI 主动操作
- **创建**：`feishu_calendar_event.create`
- **检查冲突**：创建新事件前用 `feishu_calendar_freebusy.list` 检查忙闲
- **查找**：`feishu_calendar_event.search` 按关键词查找 PDCA 相关日程
- **提醒**：事件开始前 1 天，通过 cron 发送提醒

## 5. 飞书 Sheet（电子表格）— 数据分析

### Plan 阶段
用 `feishu_sheet.create` 创建数据收集表格，通过 `headers` + `data` 一次性创建：
```json
{
  "action": "create",
  "title": "PDCA-xxx 数据收集表",
  "headers": ["指标名称", "单位", "基准值", "目标值", "收集频率", "负责人"],
  "data": [["设备OEE", "%", 65, 85, "每日", "张三"]]
}
```

### Do 阶段
用户在 Sheet 中记录执行数据，AI 定期用 `feishu_sheet.read` 读取：
- 检查数据是否按计划填写
- 用 `feishu_sheet.append` 追加新数据行

### Check 阶段
AI 用 `feishu_sheet.read` 读取数据，生成效果分析：
- 改善前 vs 改善后 对比
- 计算达成率
- 可用 `feishu_sheet.export` 导出为 xlsx 做进一步分析

## 6. 数据流闭环

```
用户描述问题
    ↓
AI 评估 → 用户确认
    ↓
自动创建：
  Wiki（项目文档+模板）— feishu_wiki_space_node.create + feishu_create_doc
  + Bitable（看板记录）— feishu_bitable_app.create + feishu_bitable_app_table.create
  + Calendar（关键时间节点）— feishu_calendar_event.create
  + Task（具体待办）— feishu_task_task.create
  + Sheet（数据收集模板）— feishu_sheet.create
  + Cron（定时提醒）— cron add
    ↓
用户在飞书中工作
  ├── 填写 Wiki 文档
  ├── 在 Sheet 中录入数据
  ├── 完成 Task 中的待办
  └── 查看 Bitable 看板
    ↓
AI 主动巡检（Cron + Heartbeat）
  ├── feishu_fetch_doc → 判断文档完成度
  ├── feishu_bitable_app_table_record.update → 更新状态
  ├── feishu_task_task.list → 检查待办完成
  └── feishu_sheet.read → 数据趋势分析
    ↓
AI 推送提醒到飞书对话
    ↓
用户确认决策（阶段转换/项目结束）
    ↓
AI 更新所有工具 + 更新 Cron
    ↓
项目结束 → 经验沉淀到 Wiki 经验库
    ↓
清理 Cron + Bitable 标记完成
```

## 实施优先级

| 优先级 | 工具 | 价值 | 状态 |
|--------|------|------|------|
| P0 | Wiki + Cron | 已完成，项目主存储和主动驱动 | ✅ 已实现 |
| P1 | Bitable 看板 | 可视化多项目状态 | 待实施 |
| P2 | Calendar | 时间节点管理 | 待实施 |
| P3 | Task | 待办管理 | 待实施 |
| P4 | Sheet | 数据分析 | 待实施 |
