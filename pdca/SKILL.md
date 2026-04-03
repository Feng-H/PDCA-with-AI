---
name: pdca
description: |
  PDCA 项目管理系统 - 基于 PDCA 循环的 AI 增强型制造与质量改进工作流。
  当用户提及以下内容时触发：
  (1) "启动 PDCA 项目"、"新建项目" (new)
  (2) "查看进行中项目"、"更新进度" (ongoing)
  (3) "查看已完成项目"、"经验复用" (achieve)
  (4) 需要系统性解决 OEE、不良率、效率或成本等制造/质量问题。
  (5) 涉及 Plan/Do/Check/Act 阶段管理、SMART 校验或逻辑审查。
---

# PDCA 项目管理系统

基于经典 PDCA 循环，深度集成飞书全工具链（Wiki/Bitable/Task/Calendar/Sheet），由 AI 驱动自治巡检与质量校验。

## 🎯 核心工作流 (Core Workflow)

AI 引导项目经理从问题分析到知识沉淀的全生命周期：

1. **评估与启动 (new)**：评估问题是否适合立项，自动在飞书创建 Wiki 空间及关联工具。
2. **计划与校验 (Plan)**：辅助目标设定，执行 SMART 校验与因果逻辑审查。
3. **执行与巡检 (Do)**：AI 通过 Cron 定时巡检一线人员填写的云文档，汇总进展。
4. **检查与评估 (Check)**：读取 Sheet 数据，对比基准与目标，自动识别偏差。
5. **决策与沉淀 (Act)**：生成标准化 SOP，将成功经验归档至经验库。

## 📚 渐进式披露：详细指南

根据当前任务，阅读对应的参考文档以获取详细操作步骤：

### 1. 飞书集成与主动驱动
- **API 调用与工具配置**：见 [feishu-integration.md](references/feishu-integration.md)
- **自治巡检与 Cron 逻辑**：见 [cron-driving.md](references/cron-driving.md)
- **即时预警卡片模板**：见 [feishu-integration.md#预警卡片](references/feishu-integration.md)

### 2. 各阶段执行 Agent
- **Plan 阶段 (规划/校验)**：见 [plan-agent.md](references/plan-agent.md)
- **Do 阶段 (执行/日志)**：见 [do-agent.md](references/do-agent.md)
- **Check 阶段 (数据/评估)**：见 [check-agent.md](references/check-agent.md)
- **Act 阶段 (决策/沉淀)**：见 [act-agent.md](references/act-agent.md)

### 3. 质量与逻辑校验 (Validators)
- **SMART 原则校验**：见 [transition-checklist.md](references/transition-checklist.md)
- **因果逻辑链审查**：见 [exception-handling.md](references/exception-handling.md)

### 4. 制造场景模板
- **OEE/质量改善模板库**：见 [manufacturing-templates.md](references/manufacturing-templates.md)

## 🛠️ 关键指令集

- **`new`**：初始化新项目结构。
- **`ongoing`**：读取 Bitable 状态，选择活跃项目并加载对应阶段 Agent。
- **`achieve`**：检索经验库，辅助解决新问题。

## ⚠️ 核心规则

1. **数据事实来源**：飞书 Bitable 是项目状态的唯一事实来源。
2. **主动上报**：巡检发现逻辑偏差或进度停滞，立即发送交互式卡片。
3. **用户决策**：所有阶段转换和项目结项必须经过用户确认。
