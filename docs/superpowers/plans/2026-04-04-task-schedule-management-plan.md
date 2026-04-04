# PDCA 任务/日程管理系统实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (\`- [ ]\`) syntax for tracking.

**Goal:** 构建基于飞书全工具链的 PDCA 任务/日程管理系统，实现任务自动生成、智能巡检频率、实时仪表板和数据流闭环

**Architecture:** 以 Bitable 为核心存储，通过 AI 控制层实现任务自动生成、智能巡检和仪表板更新，飞书工具链（Wiki/Task/Calendar/Sheet）作为用户交互层

**Tech Stack:** 飞书 Open API (Bitable/Task/Calendar/Sheet/Message Card), Markdown 文档系统, Cron 定时任务

---

## 文件结构概览

### 新建文件
- \`_系统/工具/Bitable表结构定义.md\` - 定义 4 张核心表的字段结构
- \`_系统/工具/任务自动生成器.md\` - 问题分析到任务的转换规则
- \`_系统/工具/智能巡检频率.md\` - 根据项目类型动态调整巡检频率
- \`_系统/工具/仪表板生成器.md\` - Wiki 仪表板页面生成逻辑
- \`_系统/工具/表单配置生成器.md\` - 根据框架动态生成表单字段
- \`pdca/references/dashboard-templates.md\` - 仪表板模板和示例
- \`pdca/tests/integration-test-scenarios.md\` - 集成测试场景

### 修改文件
- \`_系统/Agent/PlanAgent.md\` - 添加任务自动生成触发点
- \`_系统/Agent/PDCA控制器.md\` - 添加智能频率和仪表板更新
- \`pdca/SKILL.md\` - 添加新功能的用户入口
- \`pdca/references/feishu-integration.md\` - 更新 Bitable 表结构文档

---

## Task 1: 创建 Bitable 表结构定义文档

**Files:**
- Create: \`_系统/工具/Bitable表结构定义.md\`

- [ ] **Step 1: 创建表结构定义文档**

包含 4 张表的完整字段定义、类型说明和 API 调用示例。

\`\`\`bash
cat > /Users/apple/gemini-cli/PDCA-with-AI/_系统/工具/Bitable表结构定义.md << 'EOF'
# Bitable 表结构定义

## 概述

PDCA 项目管理系统使用 4 张核心 Bitable 表作为数据存储：
1. 项目主表 (projects)
2. 任务表 (tasks)
3. 数据收集记录表 (data_records)
4. 执行日志表 (logs)

---

## 表1: 项目主表 (projects)

### 字段定义

| 字段名 | 类型 | type值 | 说明 | 值格式 |
|--------|------|--------|------|--------|
| 项目ID | 文本 | 1 | 唯一标识 | UUID字符串 |
| 项目名称 | 文本 | 1 | 项目标题 | 字符串 |
| 选择框架 | 单选 | 3 | MECE框架 | 预定义选项 |
| 当前阶段 | 单选 | 3 | PDCA阶段 | Plan/Do/Check/Act/已完成 |
| 状态 | 单选 | 3 | 项目状态 | 正常/预警/超时/已完成 |
| 负责人 | 人员 | 11 | 项目负责人 | [{id: "ou_xxx"}] |
| 开始日期 | 日期 | 5 | 项目启动 | 毫秒时间戳 |
| 预计结束日期 | 日期 | 5 | 计划结束 | 毫秒时间戳 |
| 完成度 | 数字 | 2 | 0-100 | 数字 |
| 巡检频率 | 文本 | 1 | Cron表达式 | 如 "0 8 * * *" |
| 频率来源 | 单选 | 3 | 频率设定来源 | 系统推荐/用户自定义 |
| Wiki链接 | 超链接 | 15 | 项目文档 | {link: "url", text: "标题"} |

### 创建表 API 调用示例

见 \`pdca/references/feishu-integration.md\` 中的 Bitable 章节。

---

## 表2: 任务表 (tasks)

| 字段名 | 类型 | type值 | 说明 | 值格式 |
|--------|------|--------|------|--------|
| 任务ID | 文本 | 1 | 唯一标识 | UUID字符串 |
| 项目ID | 文本 | 1 | 关联项目 | 关联到项目主表 |
| 任务标题 | 文本 | 1 | 任务描述 | 字符串 |
| 来源维度 | 单选 | 3 | 框架维度 | 根据框架动态生成 |
| 来源类型 | 单选 | 3 | 生成方式 | 问题分析生成/执行计划生成/手动添加 |
| 任务描述 | 多行文本 | 15 | 详细说明 | 字符串 |
| 负责人 | 人员 | 11 | 任务负责人 | [{id: "ou_xxx"}] |
| 截止日期 | 日期 | 5 | 任务截止 | 毫秒时间戳 |
| 优先级 | 单选 | 3 | 任务优先级 | 高/中/低 |
| 状态 | 单选 | 3 | 任务状态 | 未开始/进行中/已完成/已取消 |
| 飞书任务ID | 文本 | 1 | 关联飞书Task | 字符串 |

---

## 表3: 数据收集记录表 (data_records)

| 字段名 | 类型 | type值 | 说明 | 值格式 |
|--------|------|--------|------|--------|
| 记录ID | 文本 | 1 | 唯一标识 | UUID字符串 |
| 项目ID | 文本 | 1 | 关联项目 | 关联到项目主表 |
| 指标名称 | 文本 | 1 | 数据项名称 | 如"体重"、"训练时长" |
| 维度 | 单选 | 3 | 框架维度 | 根据框架动态生成 |
| 数值 | 数字 | 2 | 测量值 | 数字 |
| 单位 | 文本 | 1 | 测量单位 | 如"kg"、"分钟" |
| 记录时间 | 日期时间 | 5 | 记录时间 | 毫秒时间戳 |
| 记录人 | 人员 | 11 | 记录人员 | [{id: "ou_xxx"}] |

---

## 表4: 执行日志表 (logs)

| 字段名 | 类型 | type值 | 说明 | 值格式 |
|--------|------|--------|------|--------|
| 日志ID | 文本 | 1 | 唯一标识 | UUID字符串 |
| 项目ID | 文本 | 1 | 关联项目 | 关联到项目主表 |
| 阶段 | 单选 | 3 | PDCA阶段 | Plan/Do/Check/Act |
| 日志类型 | 单选 | 3 | 日志类型 | 进展更新/问题记录/决策记录 |
| 内容 | 多行文本 | 15 | 日志内容 | 字符串 |
| 记录时间 | 日期时间 | 5 | 记录时间 | 毫秒时间戳 |
| 记录人 | 人员 | 11 | 记录人员 | [{id: "ou_xxx"}] |
EOF
\`\`\`

- [ ] **Step 2: 提交文档**

\`\`\`bash
git add _系统/工具/Bitable表结构定义.md
git commit -m "docs: add Bitable table structure definition

Define 4 core tables for PDCA task/schedule management:
- projects (项目主表)
- tasks (任务表)
- data_records (数据收集记录表)
- logs (执行日志表)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## Task 2: 创建任务自动生成器

**Files:**
- Create: \`_系统/工具/任务自动生成器.md\`

- [ ] **Step 1: 创建任务自动生成器文档**

\`\`\`bash
cat > /Users/apple/gemini-cli/PDCA-with-AI/_系统/工具/任务自动生成器.md << 'EOF'
# 任务自动生成器

## 概述

任务自动生成器在 Plan 阶段的问题分析完成后触发，根据选择的 MECE 框架自动拆解生成具体任务。

---

## 触发时机

当以下条件满足时触发：
1. Plan 阶段问题分析完成
2. 已选择 MECE 框架
3. 问题要素已提取（问题症状、影响范围、历史情况）

---

## 生成流程

\`\`\`
问题分析完成
    ↓
AI 提取问题要素
    ↓
根据选择的 MECE 框架，按维度拆解
    ↓
每个维度生成 1-N 个具体任务
    ↓
写入 Bitable 任务表
    ↓
同步创建飞书 Task
\`\`\`

---

## 框架维度任务映射

### TREND 框架（健康/体能）

| 维度 | 典型任务模板 |
|------|-------------|
| Training | 制定{训练类型}计划、购买训练设备、安排训练时间 |
| Rest | 建立睡眠追踪、规划休息日、设置睡眠提醒 |
| Eating | 制定营养方案、计算热量需求、采购营养补剂 |
| Nature | 安排体能测试、建立基线数据、预约体检 |
| Daily | 设置活动提醒、记录日常步数、规划作息 |

### 4M1E 框架（制造业）

| 维度 | 典型任务模板 |
|------|-------------|
| Man | 安排培训、制定操作规范、考核技能 |
| Machine | 设备检修、备件采购、维护计划 |
| Material | 来料检验、库存盘点、供应商评估 |
| Method | SOP 制定、流程优化、作业指导书更新 |
| Environment | 温湿度控制、5S 整理、安全检查 |

### PPTD 框架（软件开发）

| 维度 | 典型任务模板 |
|------|-------------|
| People | 团队培训、角色分配、技能提升 |
| Process | 开发流程定义、Code Review 设置、CI/CD 配置 |
| Technology | 技术选型、架构设计、工具搭建 |
| Product | 需求梳理、原型设计、用户测试 |
| Data | 数据模型设计、数据迁移方案、备份策略 |

---

## 任务生成规则

### 数量规则
- 每个维度生成 1-3 个核心任务
- 根据问题复杂度调整数量

### 优先级规则
- 高优先级：直接影响问题解决的任务
- 中优先级：支撑性任务
- 低优先级：优化性任务

### 依赖规则
- 识别任务间的前后依赖关系
- 在任务描述中标注依赖

### 时间规则
- 根据项目周期自动分配截止日期
- 按阶段均匀分布任务时间

---

## API 调用流程

### 1. 写入 Bitable 任务表

\`\`\`json
{
  "fields": {
    "任务ID": "task-uuid-001",
    "项目ID": "project-uuid-001",
    "任务标题": "制定训练计划",
    "来源维度": "Training",
    "来源类型": "问题分析生成",
    "任务描述": "根据VO2max提升目标，制定4周训练计划",
    "负责人": [{"id": "ou_xxx"}],
    "截止日期": 1712246400000,
    "优先级": "高",
    "状态": "未开始",
    "飞书任务ID": ""
  }
}
\`\`\`

### 2. 同步创建飞书 Task

\`\`\`bash
feishu_task_task.create \\
  --summary "T001 制定训练计划" \\
  --description "根据VO2max提升目标，制定4周训练计划" \\
  --due "2024-04-15T18:00:00+08:00" \\
  --assignee "ou_xxx"
\`\`\`

### 3. 关联飞书任务ID

更新 Bitable 任务表的 \`飞书任务ID\` 字段。
EOF
\`\`\`

- [ ] **Step 2: 提交文档**

\`\`\`bash
git add _系统/工具/任务自动生成器.md
git commit -m "docs: add task auto-generator

Define task generation rules based on MECE framework dimensions:
- Trigger conditions after problem analysis
- Framework-dimension task mapping (TREND/4M1E/PPTD)
- Task generation rules (quantity/priority/dependency/time)
- API call flow (Bitable + Feishu Task sync)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## Task 3: 创建智能巡检频率策略文档

**Files:**
- Create: \`_系统/工具/智能巡检频率.md\`

- [ ] **Step 1: 创建智能巡检频率文档**

\`\`\`bash
cat > /Users/apple/gemini-cli/PDCA-with-AI/_系统/工具/智能巡检频率.md << 'EOF'
# 智能巡检频率策略

## 概述

巡检频率根据项目类型、阶段、紧迫度动态调整，避免不必要的资源消耗。

---

## 按项目类型的频率基线

| 项目类型 | 对应框架 | 默认巡检频率 | Cron表达式 |
|---------|---------|-------------|-----------|
| 健康/体能 | TREND | 每日 1 次 | \`0 8 * * *\` |
| 制造业 | 4M1E | 每 8 小时 | \`0 */8 * * *\` |
| 软件开发 | PPTD | 每日 1 次 | \`0 8 * * *\` |
| 学习/教育 | COMET | 每周 1 次 | \`0 9 * * 1\` |
| 财务投资 | 3RL-TD | 每日 1 次 | \`0 8 * * *\` |
| 销售营销 | 5P | 每周 1 次 | \`0 9 * * 1\` |
| 团队协作 | GRCT | 每周 1 次 | \`0 9 * * 1\` |
| 客户服务 | 5S | 每日 1 次 | \`0 8 * * *\` |
| 个人效率 | TIME | 每周 1 次 | \`0 9 * * 1\` |
| 流程/服务 | SIPOC | 每日 1 次 | \`0 8 * * *\` |
| 管理/组织 | 5P2E | 每周 1 次 | \`0 9 * * 1\` |

---

## 动态频率调整因子

| 因子 | 触发条件 | 频率调整 | 说明 |
|------|---------|---------|------|
| 阶段因子 | Do 阶段 | ×1.5 | 执行期需更密切跟踪 |
| 紧迫度因子 | 优先级=高 | ×2 | 高优先级项目 |
| 时间因子 | 距截止 < 20% 时间 | ×2 | 临近截止 |
| 进度因子 | 状态=预警/滞后 | ×2 | 进度落后 |
| 用户覆盖 | 用户自定义设置 | 以用户设置为准 | 用户可覆盖 |

---

## 频率计算函数

\`\`\`python
def calculate_inspection_frequency(project):
    """
    计算项目的巡检频率
    
    Args:
        project: 项目信息，包含框架、阶段、优先级等
    
    Returns:
        str: Cron 表达式
    """
    # 1. 获取基线频率
    baseline = BASELINE_FREQUENCY.get(project['framework'], '0 8 * * *')
    
    # 2. 应用调整因子
    multiplier = 1.0
    
    if project['current_phase'] == 'Do':
        multiplier *= 1.5
    
    if project['priority'] == '高':
        multiplier *= 2
    
    time_remaining = project['end_date'] - project['today']
    total_time = project['end_date'] - project['start_date']
    if time_remaining / total_time < 0.2:
        multiplier *= 2
    
    if project['status'] in ['预警', '滞后']:
        multiplier *= 2
    
    # 3. 如果用户自定义，以用户设置为准
    if project.get('frequency_source') == '用户自定义':
        return project.get('inspection_frequency', baseline)
    
    # 4. 计算最终频率
    return apply_multiplier(baseline, multiplier)
\`\`\`

---

## Cron 任务管理

### 创建巡检任务

\`\`\`bash
# 健身项目 - 每日早上 8 点检查
cron add "0 8 * * *" "pdca ongoing --project '个人VO2max提升'"
\`\`\`

### 更新巡检任务

当频率调整时，先删除旧任务，再创建新任务：

\`\`\`bash
# 删除旧任务
cron delete <task_id>

# 创建新任务
cron add "<new_cron>" "pdca ongoing --project '<project_name>'"
\`\`\`

### 删除巡检任务

项目结束时删除所有关联任务：

\`\`\`bash
# 列出项目相关任务
cron list | grep "<project_name>"

# 逐个删除
cron delete <task_id_1>
cron delete <task_id_2>
...
\`\`\`
EOF
\`\`\`

- [ ] **Step 2: 提交文档**

\`\`\`bash
git add _系统/工具/智能巡检频率.md
git commit -m "docs: add intelligent inspection frequency strategy

Define baseline frequency by project type/framework:
- Dynamic adjustment factors (phase/priority/time/progress)
- User override capability
- Cron task management (create/update/delete)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## Task 4: 创建仪表板生成器文档

**Files:**
- Create: \`_系统/工具/仪表板生成器.md\`
- Create: \`pdca/references/dashboard-templates.md\`

- [ ] **Step 1: 创建仪表板生成器文档**

\`\`\`bash
cat > /Users/apple/gemini-cli/PDCA-with-AI/_系统/工具/仪表板生成器.md << 'EOF'
# 仪表板生成器

## 概述

仪表板生成器定期（根据巡检频率）生成 Wiki 仪表板页面，提供项目综合视图。

---

## 仪表板布局

\`\`\`
┌────────────────────────────────────────────────────────────┐
│  📊 [项目名称] 仪表板                                      │
├────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │  核心指标区                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  框架维度进度区                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  当前阶段任务列表                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  研究数据区（趋势可视化）                            │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  执行日志区                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  AI 分析洞察区                                        │   │
│  └─────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘
\`\`\`

---

## 数据来源

| 区域 | 数据来源 | API |
|------|---------|-----|
| 核心指标 | 项目主表 | \`feishu_bitable_app_table_record.search\` |
| 框架维度进度 | 任务表聚合 | \`feishu_bitable_app_table_record.search\` |
| 当前阶段任务 | 任务表 | \`feishu_bitable_app_table_record.search\` |
| 研究数据 | 数据记录表 | \`feishu_bitable_app_table_record.search\` |
| 执行日志 | 日志表 | \`feishu_bitable_app_table_record.search\` |
| AI 分析洞察 | AI 生成 | 基于以上数据分析 |

---

## 生成流程

1. **读取数据**：从 Bitable 各表读取最新数据
2. **计算指标**：聚合计算各区域指标
3. **生成洞察**：AI 分析数据，生成洞察
4. **渲染 Markdown**：生成仪表板 Markdown 内容
5. **更新 Wiki**：调用 \`feishu_update_doc\` 更新仪表板页面

---

## 更新频率

根据项目智能巡检频率执行，最小频率为每日 1 次。

---

## Wiki 文档路径

\`\`\`
PDCA项目管理/
└── 📁 [项目名称]/
    └── 📊 仪表板.md
\`\`\`
EOF
\`\`\`

- [ ] **Step 2: 创建仪表板模板文档**

\`\`\`bash
cat > /Users/apple/gemini-cli/PDCA-with-AI/pdca/references/dashboard-templates.md << 'EOF'
# 仪表板模板

## Wiki 仪表板页面模板

\`\`\`markdown
# 📊 [项目名称] 实时仪表板

> 更新时间：{{update_time}}

## 核心指标

| 目标达成度 | 剩余天数 | 当前阶段 | 任务完成率 |
|-----------|---------|---------|-----------|
| {{completion_progress}} | {{days_remaining}}天 | {{current_phase}} | {{task_completion_rate}} |

## 框架维度进度

{{#each dimensions}}
### {{name}}（{{description}}）- {{progress}}%
[{{progress_bar}}] {{completed_tasks}}/{{total_tasks}} 任务完成

{{/each}}

## 当前阶段任务

{{#each tasks}}
- [{{#if completed}}x{{else}} {{/if}}] {{title}} - {{status}}
{{/each}}

## 数据趋势

### {{metric_name}}
\`\`\`
{{chart_data}}
\`\`\`

## AI 洞察

💡 **正面发现**
{{#each positive_insights}}
- {{this}}
{{/each}}

⚠️ **需要注意**
{{#each warnings}}
- {{this}}
{{/each}}

## 执行日志

| 时间 | 类型 | 内容 |
|------|------|------|
{{#each logs}}
| {{time}} | {{type}} | {{content}} |
{{/each}}

---
🔄 [刷新数据] | 📋 [查看任务详情] | 📈 [查看数据分析]
\`\`\`

---

## TREND 框架仪表板示例

\`\`\`markdown
# 📊 个人VO2max提升 实时仪表板

> 更新时间：2026-04-04 08:00

## 核心指标

| 目标达成度 | 剩余天数 | 当前阶段 | 任务完成率 |
|-----------|---------|---------|-----------|
| ████████░░ 65% | 12天 | Do阶段 | 8/12 (67%) |

## 框架维度进度

### Training（训练）- 60%
[██████████░░░░░░░░░] 3/5 任务完成

### Rest（休息）- 40%
[████████░░░░░░░░░░░] 2/5 任务完成

### Eating（营养）- 70%
[███████████████░░░░] 7/10 数据点达标

### Nature（身体）- 50%
[█████████░░░░░░░░░░] 1/2 目标达成

### Daily（日常）- 40%
[████████░░░░░░░░░░░] 2/5 任务完成

## 当前阶段任务

- [x] T001 制定训练计划 - ✅ 已完成
- [~] T002 购买训练设备 - 🔄 进行中
- [ ] T003 建立睡眠追踪 - ⏳ 未开始

## 数据趋势

### 体重变化
\`\`\`
75.2 ┤     
74.8 ┤  ●           
74.5 ┤     ●       
74.2 ┤         ●   
73.8 ┤             ●
     └─────────────
     3/28  3/31  4/3
\`\`\`

### 训练时长趋势
\`\`\`
60 ┤     ████
45 ┤ ████     ████
30 ┤         
   └─────────────
   周一  周三  周五
\`\`\`

## AI 洞察

💡 **正面发现**
- 训练完成率保持稳定，每周达成目标
- 体重呈下降趋势，符合预期

⚠️ **需要注意**
- 睡眠质量评分连续3天低于4分，建议调整作息
- 蛋白质摄入未达标（平均45g，目标60g）

## 执行日志

| 时间 | 类型 | 内容 |
|------|------|------|
| 04-03 15:30 | ✅ 进展 | 完成训练计划制定 |
| 04-02 10:20 | ⚠️ 问题 | 设备缺货 → 已联系供应商 |
| 04-01 09:00 | 📊 数据 | 完成体能基线测试 |

---
🔄 [刷新数据] | 📋 [查看任务详情] | 📈 [查看数据分析]
\`\`\`
EOF
\`\`\`

- [ ] **Step 3: 提交文档**

\`\`\`bash
git add _系统/工具/仪表板生成器.md pdca/references/dashboard-templates.md
git commit -m "docs: add dashboard generator and templates

Define dashboard generation logic and templates:
- Dashboard layout with 6 sections
- Data sources from Bitable tables
- Update frequency based on inspection schedule
- Wiki template and TREND framework example

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## Task 5: 创建表单配置生成器文档

**Files:**
- Create: \`_系统/工具/表单配置生成器.md\`

- [ ] **Step 1: 创建表单配置生成器文档**

\`\`\`bash
cat > /Users/apple/gemini-cli/PDCA-with-AI/_系统/工具/表单配置生成器.md << 'EOF'
# 表单配置生成器

## 概述

表单配置生成器根据项目选择的 MECE 框架，动态生成数据收集表单的字段配置。

---

## 框架维度表单配置

### TREND 框架表单配置

| 维度 | 数据项 | 数据类型 | 采集频率 | 单位 |
|------|--------|---------|---------|------|
| Training | 训练时长 | 数字 | 每次训练后 | 分钟 |
| Training | 训练强度 | 单选 | 每次训练后 | - |
| Training | 训练类型 | 多选 | 每次训练后 | - |
| Rest | 睡眠时长 | 数字 | 每日 | 小时 |
| Rest | 睡眠质量 | 单选 | 每日 | 1-5分 |
| Rest | 休息日标记 | 是/否 | 每周 | - |
| Eating | 热量摄入 | 数字 | 每日 | kcal |
| Eating | 蛋白质 | 数字 | 每日 | g |
| Eating | 碳水化合物 | 数字 | 每日 | g |
| Nature | 体重 | 数字 | 每周 | kg |
| Nature | 静息心率 | 数字 | 每周 | bpm |
| Nature | VO2max | 数字 | 每月 | - |
| Daily | 步数 | 数字 | 每日 | 步 |
| Daily | 久坐时长 | 数字 | 每日 | 分钟 |

### 4M1E 框架表单配置

| 维度 | 数据项 | 数据类型 | 采集频率 | 单位 |
|------|--------|---------|---------|------|
| Man | 出勤率 | 数字 | 每日 | % |
| Man | 培训完成数 | 数字 | 每周 | 人次 |
| Machine | 设备OEE | 数字 | 每班次 | % |
| Machine | 停机时长 | 数字 | 每班次 | 分钟 |
| Material | 来料不良率 | 数字 | 每批 | % |
| Material | 库存周转天数 | 数字 | 每周 | 天 |
| Method | SOP执行率 | 数字 | 每周 | % |
| Environment | 温度 | 数字 | 每日 | °C |
| Environment | 湿度 | 数字 | 每日 | % |

---

## 表单字段类型映射

| 数据类型 | Bitable type | 说明 |
|---------|-------------|------|
| 数字 | 2 | 数值类型 |
| 单选 | 3 | 预定义选项 |
| 多选 | 4 | 预定义选项 |
| 是/否 | 3 | 选项：是/否 |
| 文本 | 1 | 字符串 |
| 日期 | 5 | 日期时间 |

---

## 表单创建流程

1. 项目创建时，根据选择的框架获取表单配置
2. 在 Bitable 数据记录表中创建对应字段
3. 生成表单分享链接
4. 发送给用户

---

## 数据写入流程

用户填写表单 → 数据写入数据记录表 → Cron 检测到新数据 → 更新仪表板
EOF
\`\`\`

- [ ] **Step 2: 提交文档**

\`\`\`bash
git add _系统/工具/表单配置生成器.md
git commit -m "docs: add form configuration generator

Define dynamic form generation based on MECE framework:
- TREND framework form fields (14 data points)
- 4M1E framework form fields (9 data points)
- Field type mapping to Bitable types
- Form creation and data write flow

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## Task 6: 更新 PlanAgent 添加任务自动生成触发点

**Files:**
- Modify: \`_系统/Agent/PlanAgent.md\`

- [ ] **Step 1: 在 PlanAgent.md 中添加任务自动生成章节**

在 \`PlanAgent.md\` 的"工作流程"部分，找到"第三阶段：方案制定"结束后，添加新的第四阶段：

\`\`\`markdown
### 第四阶段：任务自动生成

**目标**：根据问题分析结果和选择的 MECE 框架，自动生成项目任务

**执行步骤**：
1. **触发条件检查**
   - 问题分析已完成
   - MECE 框架已选择
   - 问题要素已提取

2. **框架维度任务拆解**
   - 读取 \`_系统/工具/任务自动生成器.md\`
   - 根据选择的框架获取维度任务映射
   - 为每个维度生成 1-3 个具体任务

3. **写入 Bitable 任务表**
   - 调用 Bitable API 创建任务记录
   - 设置任务来源为"问题分析生成"

4. **同步飞书 Task**
   - 为每个任务调用 \`feishu_task_task.create\`
   - 更新 Bitable 任务的 \`飞书任务ID\` 字段

5. **向用户确认**
   - 展示生成的任务列表
   - 询问用户是否需要调整
   - 根据用户反馈更新任务

**详细规范**：见 \`_系统/工具/任务自动生成器.md\`
\`\`\`

- [ ] **Step 2: 提交更改**

\`\`\`bash
git add _系统/Agent/PlanAgent.md
git commit -m "feat: add auto-task generation to PlanAgent

Add Phase 4: Auto Task Generation after solution planning:
- Trigger condition checks
- Framework-dimension task breakdown
- Bitable tasks table write
- Feishu Task sync
- User confirmation flow

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## Task 7: 更新 PDCA 控制器添加智能频率和仪表板

**Files:**
- Modify: \`_系统/Agent/PDCA控制器.md\`

- [ ] **Step 1: 在 PDCA控制器.md 中添加智能频率章节**

在 \`PDCA控制器.md\` 的"⏰ 时间流管理"章节后，添加新章节：

\`\`\`markdown

## 🧠 智能巡检频率

### 频率基线

根据项目类型（对应选择的 MECE 框架）设置基线频率：

| 项目类型 | 对应框架 | 默认巡检频率 |
|---------|---------|-------------|
| 健康/体能 | TREND | 每日 1 次 |
| 制造业 | 4M1E | 每 8 小时 |
| 软件开发 | PPTD | 每日 1 次 |
| 学习/教育 | COMET | 每周 1 次 |
| ... | ... | ... |

完整映射见：\`_系统/工具/智能巡检频率.md\`

### 动态调整

巡检频率根据以下因子动态调整：
- 阶段因子：Do 阶段 ×1.5
- 紧迫度因子：高优先级 ×2
- 时间因子：距截止 < 20% ×2
- 进度因子：状态=预警/滞后 ×2

用户可自定义覆盖系统推荐频率。

### Cron 任务管理

- 创建：项目启动时根据频率创建 Cron 任务
- 更新：频率调整时删除旧任务，创建新任务
- 删除：项目结束时删除所有关联任务

---

## 📊 实时仪表板

### 仪表板更新

根据巡检频率，每次巡检时：
1. 从 Bitable 读取最新数据
2. 计算各区域指标
3. 生成 AI 洞察
4. 更新 Wiki 仪表板页面

### 仪表板结构

- 核心指标区
- 框架维度进度区
- 当前阶段任务列表
- 研究数据区
- 执行日志区
- AI 分析洞察区

详细规范见：\`_系统/工具/仪表板生成器.md\`
\`\`\`

- [ ] **Step 2: 提交更改**

\`\`\`bash
git add _系统/Agent/PDCA控制器.md
git commit -m "feat: add intelligent frequency and dashboard to PDCA Controller

Add two new sections:
1. Intelligent Inspection Frequency
   - Baseline frequency by project type
   - Dynamic adjustment factors
   - Cron task management

2. Real-time Dashboard
   - Update on inspection cycle
   - 6-section layout
   - Link to detailed generator spec

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## Task 8: 更新 SKILL.md 添加新功能用户入口

**Files:**
- Modify: \`pdca/SKILL.md\`

- [ ] **Step 1: 在 SKILL.md 中添加新功能说明**

在 \`SKILL.md\` 的"📚 渐进式披露：详细指南"章节中，添加新的参考文档入口：

\`\`\`markdown

### 5. 任务与日程管理（新增）
- **Bitable 表结构**：见 [Bitable表结构定义.md](_系统/工具/Bitable表结构定义.md)
- **任务自动生成**：见 [任务自动生成器.md](_系统/工具/任务自动生成器.md)
- **智能巡检频率**：见 [智能巡检频率.md](_系统/工具/智能巡检频率.md)
- **仪表板生成**：见 [仪表板生成器.md](_系统/工具/仪表板生成器.md)
- **表单配置**：见 [表单配置生成器.md](_系统/工具/表单配置生成器.md)
- **仪表板模板**：见 [dashboard-templates.md](references/dashboard-templates.md)
\`\`\`

在"⚡ Quick Reference"表格中，更新指令说明：

\`\`\`markdown
| 指令 | 触发场景 | 输出 |
|------|---------|------|
| \`new\` | 启动新项目 | 飞书 Wiki + Bitable (4张表) + Calendar + Task (自动生成) + Cron (智能频率) + 项目索引更新 |
| \`ongoing\` | 管理活跃项目 | 进度检查 + 状态更新 + 仪表板刷新 + 预警 |
| \`achieve\` | 检索经验库 | 最佳实践推荐 + 模板匹配 |
\`\`\`

- [ ] **Step 2: 提交更改**

\`\`\`bash
git add pdca/SKILL.md
git commit -m "feat: add task/schedule management to SKILL.md

Add new reference section for task/schedule management:
- Bitable table structure
- Auto task generator
- Intelligent inspection frequency
- Dashboard generator
- Form configuration
- Dashboard templates

Update command descriptions with new features.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## Task 9: 更新 feishu-integration.md 添加表结构文档

**Files:**
- Modify: \`pdca/references/feishu-integration.md\`

- [ ] **Step 1: 在 feishu-integration.md 中添加表结构章节**

在 \`feishu-integration.md\` 的"## 2. 飞书 Bitable（多维表格）"章节中，添加表结构定义的引用：

在"字段设计"表格后，添加：

\`\`\`markdown

### 完整表结构

详细的 4 张核心表结构定义，见 \`_系统/工具/Bitable表结构定义.md\`。

### 表关系

\`\`\`
项目主表 (projects)
    ├── 1:N → 任务表 (tasks)
    ├── 1:N → 数据收集记录表 (data_records)
    └── 1:N → 执行日志表 (logs)
\`\`\`
\`\`\`

- [ ] **Step 2: 提交更改**

\`\`\`bash
git add pdca/references/feishu-integration.md
git commit -m "docs: update feishu-integration with table structure

Add reference to complete table structure definition:
- Link to Bitable表结构定义.md
- Table relationship diagram
- 4 core tables overview

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## Task 10: 创建集成测试场景文档

**Files:**
- Create: \`pdca/tests/integration-test-scenarios.md\`

- [ ] **Step 1: 创建集成测试场景文档**

\`\`\`bash
cat > /Users/apple/gemini-cli/PDCA-with-AI/pdca/tests/integration-test-scenarios.md << 'EOF'
# 集成测试场景

## 概述

本文档定义 PDCA 任务/日程管理系统的集成测试场景，用于验证端到端功能。

---

## 场景 1：新项目创建与任务自动生成

### 前置条件
- 用户执行 \`pdca new\`
- 用户选择 TREND 框架
- 用户完成问题分析

### 测试步骤
1. 系统检测到问题分析完成
2. 系统触发任务自动生成
3. 验证 Bitable 任务表中生成 5-15 个任务
4. 验证每个任务的 \`来源维度\` 字段对应 TREND 框架维度
5. 验证每个任务的 \`来源类型\` 为"问题分析生成"
6. 验证飞书 Task 中创建对应任务
7. 验证 Bitable 任务的 \`飞书任务ID\` 已填充

### 预期结果
- 任务数量：5-15 个（每个维度 1-3 个）
- 维度覆盖：Training/Rest/Eating/Nature/Daily
- 飞书 Task 同步成功

---

## 场景 2：智能巡检频率调整

### 前置条件
- 项目处于 Do 阶段
- 优先级为"高"
- 距截止日期剩余 10%

### 测试步骤
1. 系统计算巡检频率
2. 验证基线频率（TREND = 每日 1 次）
3. 应用调整因子：Do(×1.5) + 高优先级(×2) + 时间因子(×2)
4. 验证最终频率约为每日 6 次
5. 验证 Cron 任务已更新

### 预期结果
- 频率计算正确
- Cron 任务更新成功

---

## 场景 3：仪表板自动更新

### 前置条件
- 项目有任务完成
- 有新的数据记录

### 测试步骤
1. Cron 触发巡检
2. 系统读取 Bitable 数据
3. 系统生成仪表板内容
4. 系统更新 Wiki 仪表板页面
5. 验证仪表板显示最新数据

### 预期结果
- 仪表板数据与 Bitable 一致
- 更新时间戳为当前时间

---

## 场景 4：表单数据收集

### 前置条件
- 项目使用 TREND 框架
- 数据记录表已创建

### 测试步骤
1. 用户填写表单（体重：75kg）
2. 数据写入数据记录表
3. 下次巡检时，仪表板更新显示新数据
4. 验证趋势图表包含新数据点

### 预期结果
- 数据记录正确
- 仪表板图表更新

---

## 场景 5：项目结束清理

### 前置条件
- Act 阶段完成
- 用户确认项目结束

### 测试步骤
1. 系统更新 Bitable 项目状态为"已完成"
2. 系统删除所有关联 Cron 任务
3. 验证无残留 Cron 任务

### 预期结果
- 状态更新成功
- Cron 任务全部清理
EOF
\`\`\`

- [ ] **Step 2: 提交文档**

\`\`\`bash
git add pdca/tests/integration-test-scenarios.md
git commit -m "test: add integration test scenarios

Define 5 integration test scenarios:
1. New project with auto task generation
2. Intelligent inspection frequency adjustment
3. Dashboard auto-update
4. Form data collection
5. Project cleanup on completion

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
\`\`\`

---

## 自我审查 (Self-Review)

### Spec 覆盖度检查

| 设计规范章节 | 对应任务 | 状态 |
|-------------|---------|------|
| Bitable 表结构设计 | Task 1 | ✅ |
| 任务自动生成机制 | Task 2, Task 6 | ✅ |
| 智能巡检频率策略 | Task 3, Task 7 | ✅ |
| 仪表板设计 | Task 4, Task 7 | ✅ |
| 表单数据收集 | Task 5 | ✅ |
| 更新现有 Agent 集成 | Task 6, Task 7, Task 8, Task 9 | ✅ |
| 测试场景 | Task 10 | ✅ |

### Placeholder 扫描

- ✅ 无 "TBD" 或 "TODO"
- ✅ 所有代码步骤包含完整内容
- ✅ 所有命令包含具体参数
- ✅ 所有文件路径明确

### 类型一致性检查

- ✅ Bitable 字段类型在各文档中一致
- ✅ Cron 表达式格式统一
- ✅ 框架名称在各文档中一致

---

## 执行移交

**计划完成并保存到** \`docs/superpowers/plans/2026-04-04-task-schedule-management-plan.md\`

**两种执行选项：**

**1. Subagent-Driven（推荐）** - 每个任务派发新的 subagent，任务间审查，快速迭代

**2. Inline Execution** - 在当前会话中使用 executing-plans 执行，批量执行并设置检查点

**请选择执行方式？**

**如果选择 Subagent-Driven：**
- **必需子技能**：使用 superpowers:subagent-driven-development
- 每个任务使用新 subagent + 两阶段审查

**如果选择 Inline Execution：**
- **必需子技能**：使用 superpowers:executing-plans
- 批量执行，设置检查点以供审查
