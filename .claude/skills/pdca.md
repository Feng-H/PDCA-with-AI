---
name: pdca
description: |
  Use when initiating or managing PDCA cycle projects, manufacturing quality improvement (OEE, defect rates, efficiency, cost reduction),
  or Feishu/Lark document inspection with SMART validation is needed. Trigger for project transitions (new/ongoing/achieve) or proactive AI alerts.
---

# PDCA 项目管理系统

## 概述

基于 PDCA 循环的结构化问题解决系统，由 AI 驱动实现主动巡检、SMART 目标校验和飞书工具链集成。

## 触发条件

**使用此技能当用户：**
- 提到 "启动 PDCA 项目"、"新建项目"、"立项"
- 需要进行结构化问题分析（5W1H、鱼骨图、5Why）
- 需要量化目标和可衡量指标
- 提到 "OEE 提升"、"不良率降低"、"效率改善"
- 需要主动进度监控和预警
- 提到 "飞书"、"Bitable"、"Wiki" 集成

## 核心工作流

### 1. 评估与启动 (new)

**引导问题：**
1. "你面临的问题是什么？请简要描述。"
2. "这个问题属于哪个类型？"
   - 设备问题
   - 质量问题
   - 效率问题
   - 成本问题
   - 安全问题
   - Other (请自定义)

**然后：**
- 使用 4M1E 框架进行初步分析（Man、Machine、Material、Method、Environment）
- 评估是否适合 PDCA 项目立项
- 如果适合，引导创建项目结构

### 2. 计划与校验 (Plan)

**执行 SMART 校验：**
- Specific（具体）：目标是否明确？
- Measurable（可衡量）：是否有数字指标？
- Achievable（可实现）：资源是否足够？
- Relevant（相关）：是否与整体目标一致？
- Time-bound（有时限）：完成时间是什么？

**因果逻辑审查：**
- 使用 5Why 分析根本原因
- 验证因果关系（X → Y 是否成立？）

### 3. 执行与巡检 (Do)

- 引导用户记录执行日志
- 汇总进展数据
- 识别偏离计划的差异

### 4. 检查与评估 (Check)

- 分析目标达成率
- 识别成功因素和失败原因
- 评估数据偏差

### 5. 决策与沉淀 (Act)

- 决定：标准化、改进或放弃
- 生成 SOP（标准作业程序）
- 归档经验教训

## 飞书集成指南

### 创建项目结构

```
使用 feishu-create-doc 创建：
- 项目名称/项目信息.md
- 项目名称/Plan阶段/问题分析.md
- 项目名称/Plan阶段/目标设定.md
- 项目名称/Do阶段/执行日志.md
- 项目名称/Check阶段/数据分析.md
- 项目名称/Act阶段/总结报告.md
```

### Bitable 多维表格

创建数据表记录：
- 任务清单（任务、负责人、状态、截止日期）
- 问题记录（问题、严重程度、状态、解决方案）
- 指标追踪（指标名称、目标值、实际值、达成率）

## 用户交互规范

### AskUserQuestion 规则

1. **所有单选问题必须包含 "Other" 选项**
2. **选项必须互斥且穷尽**
3. **选项描述要清晰**

### Red Flags - 立即停止

出现以下信号时，停止并重新评估：
- 目标没有具体数字
- 说"执行中再调整"
- 说"快速补救一下"
- 说"老板在催，先开始吧"
- 直接接受用户提供的原因而不验证

## 常用命令

| 命令 | 功能 |
|------|------|
| `new` | 启动新项目 |
| `ongoing` | 查看活跃项目 |
| `achieve` | 检索历史案例 |
| `plan` | 进入计划阶段 |
| `check` | 执行 SMART 校验 |

## 参考文档

- 飞书 API 集成：见 `assets/references/feishu-integration.md`
- 质量校验标准：见 `system/规范/`
- 各阶段 Agent 提示词：见 `system/Agent/`
