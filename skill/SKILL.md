---
name: pdca
description: |
  PDCA项目管理系统 - 基于PDCA循环的AI增强问题解决工作流系统。专注于制造和质量管理领域的持续改进。
  当以下情况时使用此 Skill：
  (1) 用户提到"PDCA"、"启动项目"、"PDCA项目"、"持续改进"
  (2) 用户需要系统性解决制造/质量/管理问题（设备OEE、不良率、效率等）
  (3) 用户说"new"启动新项目、"ongoing"查看进行中项目、"achieve"查看已完成项目
  (4) 用户提到"Plan"、"Do"、"Check"、"Act"阶段或需要阶段转换
  (5) 用户需要问题分析、目标设定、方案制定、执行监控、效果评估、标准化等PDCA流程
---

# PDCA 项目管理系统

严格按 Plan→Do→Check→Act 时间流推进的结构化问题解决工作流，集成飞书全工具链（Wiki + Bitable + Task + Calendar + Sheet）和 cron 主动驱动。

## 评估入口

当用户描述问题时，**先聊一两句了解背景**，不要急着下判断。然后评估：

| 维度 | 走PDCA | 不走PDCA |
|------|--------|--------|
| 复杂度 | 多步骤、多因素交织 | 单步可解决 |
| 周期 | 数天到数周 | 几分钟到几小时 |
| 可衡量 | 有明确量化目标 | 主观判断即可 |
| 风险 | 试错成本高（资金/安全/质量） | 试错成本低 |
| 经验价值 | 解决后经验可复用 | 一次性问题 |
| 数据需求 | 需要收集和分析数据 | 不需要数据支撑 |

**推荐原则：**
- 推荐一次，用户拒绝 → 尊重，直接帮忙
- 边界模糊 → 偏向"直接帮"，不硬推
- 值得"立项"的问题走PDCA，值得"随手解决"的问题直接帮

## 项目启动流程（创建项目）

创建项目时，AI 自动在飞书全工具链中初始化所有需要的资源。详细集成逻辑参考 `references/feishu-integration.md`。

### 1. 创建飞书知识库结构（Wiki）
调用飞书 Wiki 工具创建项目空间：
```
PDCA知识空间
├── 项目名称/
│   ├── 📋 项目信息.md（项目状态、时间规划、负责人）
│   ├── 📁 Plan阶段/
│   │   ├── 问题分析.md（模板）
│   │   ├── 目标设定.md（模板）
│   │   ├── 解决方案.md（模板）
│   │   └── 执行计划.md（模板）
│   ├── 📁 Do阶段/
│   │   ├── 执行日志.md（模板）
│   │   ├── 进度报告.md（模板）
│   │   └── 问题记录.md（模板）
│   ├── 📁 Check阶段/
│   │   ├── 数据分析.md（模板）
│   │   ├── 效果评估.md（模板）
│   │   └── 问题诊断.md（模板）
│   └── 📁 Act阶段/
│       ├── 行动决策.md（模板）
│       ├── 实施方案.md（模板）
│       └── 知识总结.md（模板）
├── 项目索引.md（全局项目状态汇总）
└── 经验库/（已完成项目的经验，按类别组织）
```

### 2. 创建多维表格看板（Bitable）
在知识空间中创建「PDCA项目看板」多维表格。字段设计、AI 操作逻辑详见 `references/feishu-integration.md`。

### 3. 创建日历事件（Calendar）
为关键时间节点创建日历事件：各阶段截止日、里程碑日期、评审会议。

### 4. 创建数据收集表格（Sheet）
在 Plan 阶段目标设定后，根据量化指标创建数据收集 Sheet。

各工具的详细集成逻辑、字段设计、AI 操作方式，参考 `references/feishu-integration.md`。

### 5. 自动化 Cron 任务注册
项目创建完成后，AI 将自动向控制器注册以下 Cron 任务，实现全自动化进度驱动：
- **每日早报（Daily Reminder）**：每天 09:00 读取 Wiki 与 Bitable，通过卡片推送当前阶段待办及过期任务。
- **阶段到期预警（Phase Pre-warning）**：在阶段计划结束前 24 小时，由控制器执行「Scrape-Load-Verify-Message」巡检循环，检测转换条件。
- **里程碑触发器（Milestone Trigger）**：里程碑到期当日触发巡检，确保关键产出物已同步至 Wiki。

参考 `references/cron-driving.md` 获取更底层的 Cron API 调用逻辑。

### 6. 告知用户
- 告知知识库链接、看板链接
- 告知当前阶段和需要填写的文档
- 告知时间规划和里程碑节点

## 主动驱动机制

### Cron 任务（按项目注册）
详见「项目启动流程 - 5. 自动化 Cron 任务注册」。

### 进展判断（方案C）
基于 Bitable 仪表盘与 Wiki 内容的双向验证：
- **Bitable 校验**：AI 定期读取 Bitable 的「验证状态」字段（Validating / Passed / Rejected），同步更新本地 JSON。
- **文档比对**：将 Bitable 记录的进度与 Wiki 存档的文档版本号进行匹配，确保信息不泄露且一致。
- **用户确认回环**：当 Bitable 显示「Passed」但 Wiki 缺少文件时，主动推送补全提示。

详细操作流程参考 `references/feishu-integration.md` 中「数据流闭环」章节。

### Heartbeat 轻量检查
在 HEARTBEAT.md 中加入 PDCA 检查项：
- 有活跃的 PDCA 项目吗？
- 今天有没有到期的阶段/里程碑？
- 有没有超时的项目需要关注？

## 阶段管理

### Plan → Do → Check → Act
参考各阶段 Agent 指南：
- `references/plan-agent.md`
- `references/do-agent.md`
- `references/check-agent.md`
- `references/act-agent.md`

### 阶段转换
- 参考 `references/transition-checklist.md`
- AI 主动检查完成度 → 提醒用户 → 用户确认
- 阶段转换时同步更新所有飞书工具（Wiki + Bitable + Calendar + Cron），详见 `references/feishu-integration.md`

## 异常处理
- 参考 `references/exception-handling.md`
- 超时预警：黄(80%) → 橙(100%) → 红(120%)

## 制造质量项目
- 参考 `references/manufacturing-templates.md`

## 飞书工具链集成
- 参考 `references/feishu-integration.md`

## 知识沉淀

### 项目结束时的沉淀流程
1. **提炼经验**：从 Act 阶段的「知识总结.md」提取关键内容
2. **归档到经验库**：按问题类型（设备/质量/效率/成本/流程/管理）归类
3. **标准化提取**：将成功做法提炼为可复用的 SOP 或模板
4. **更新项目索引**：标记项目为已完成，记录关键成果
5. **清理 cron**：删除项目相关的所有定时任务
6. **更新 Bitable**：标记项目状态为「已完成」

### 新项目启动时的经验复用
1. AI 检索经验库中同类型的已完成项目
2. 向用户推荐可复用的经验、模板、指标
3. 在 Wiki 项目文档中关联相关经验文档

## 数据持久化

### 本地状态文件
`workspace/pdca-projects.json`：
```json
{
  "projects": [
    {
      "id": "PDCA-20260403-001",
      "name": "提升设备OEE",
      "status": "进行中",
      "currentPhase": "Do",
      "spaceId": "space-xxx",
      "timeline": { "plan": {...}, "do": {...} },
      "milestones": [...],
      "cronJobs": { "daily": "id", "phaseWarning": "id" }
    }
  ]
}
```

## 关键规则
1. **用户提问题 → AI推荐PDCA → 用户同意 → 创建项目**
2. **飞书全工具链为主存储**：Wiki 存文档、Bitable 存状态、Calendar 存时间、Task 存待办、Sheet 存数据
3. **本地 JSON 为状态索引**，与飞书数据同步
4. **AI 主动推动：cron 提醒 + 全工具链读取判断进展**
5. **关键决策（阶段转换、项目结束）必须用户确认**
6. **数据驱动：量化指标跟踪，时间预警，完成度可视化**
7. **知识沉淀：项目结束后经验自动归档到经验库，新项目可复用**
8. **阶段转换时同步更新所有飞书工具**（Wiki + Bitable + Calendar + Cron）
