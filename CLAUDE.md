# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 项目概述 / Project Overview

**PDCA-with-AI** 是一个基于 PDCA 循环的 AI 驱动型工作流系统，**平台无关**（Platform-Agnostic）。AI Agent 层不绑定任何特定平台，飞书（Feishu/Lark）作为推荐深度集成后端。

**核心特点**：
- 非 traditional 软件代码库，主要由 markdown 文件定义 AI agents、workflows 和 templates
- Agent 层平台无关，飞书集成作为可选但推荐的后端（详见 `assets/references/feishu-integration.md`）
- **主动巡检**（Proactive Inspection）：AI 定期检查项目健康度，主动提醒用户
- 遵循 [superpowers:writing-skills](https://github.com/obra/superpowers) 标准

---

## 当前状态 / Current Status

| 项目 | 状态 |
|------|------|
| **GitHub** | https://github.com/Feng-H/PDCA-with-AI |
| **npm 包** | @feng-h/pdca-skill |
| **最新版本** | v1.0.9 |
| **安装方式** | `npx skills add Feng-H/PDCA-with-AI --agent skills` |

---

## 项目结构 / Project Structure

```
PDCA-with-AI/
├── SKILL.md            # 技能入口（AI Agent 读取此文件）
├── CLAUDE.md           # 开发指南（本文件）
├── assets/             # 详细文档与资源
│   ├── references/     # 参考文档（飞书集成、MECE框架、阶段检查表等）
│   ├── tests/          # 基线测试与质量验证
│   └── templates/      # 项目模板
├── system/             # 系统规范
│   ├── 规范/            # SMART 校验与因果逻辑模组
│   │   └── Validators/  # 验证器（logic.md, smart.md）
│   └── 工具/            # 工具配置（按后端分目录）
│       ├── feishu/     # 飞书/Bitable 专用配置
│       └── 智能巡检频率.md
├── bin/                # npx 可执行文件
├── package.json        # npm 包配置
└── README.md           # 项目说明（中/英/日）
```

**路径变更说明**：
- 原 `pdca/` → 现 `assets/`
- 原 `_系统/` → 现 `system/`

---

## 核心依赖 / Core Dependencies

### 推荐后端 / Recommended Backend

| 组件 | 说明 | 备注 |
|------|------|------|
| **飞书（Feishu/Lark）** | 推荐深度集成后端 | 提供 Wiki、Bitable、Calendar、Task 等能力 |
| **OpenClaw + 飞书插件** | 原始支持平台 | 通过 feishu-* API 实现集成 |
| **Hermes Agent** | 已验证可用的 Agent 平台 | 通过 MCP/工具调用实现集成 |

> **平台无关原则**：Agent 层不依赖特定平台。飞书是推荐后端但非必需——最小可用模式下，Agent 可使用本地文件系统、消息通知等通用能力运行。

### 关键 API 列表（飞书后端）

以下 API 仅在使用飞书后端时需要：

| API | 功能 |
|-----|------|
| `feishu-create-doc` | 创建 Wiki 文档 |
| `feishu-update-doc` | 更新文档内容 |
| `feishu-fetch-doc` | 读取文档内容 |
| `feishu-bitable` | 多维表格 CRUD（27种字段类型） |
| `feishu-calendar` | 日程管理 |
| `feishu-task` | 任务管理 |
| `feishu-sheet` | 电子表格 |
| `feishu-im-read` | 消息读取 |

---

## 核心工作流 / Core Workflows

### 三大命令

| 命令 | 功能 | 输出 |
|------|------|------|
| `new` | 启动新项目 | 创建 Wiki + Bitable 应用 + Calendar |
| `ongoing` | 管理活跃项目 | 进度检查 + 状态更新 + 预警 |
| `achieve` | 检索经验库 | 最佳实践推荐 + 模板匹配 |

### 阶段转换逻辑

阶段转换**严格按顺序**，需要：
1. 当前阶段所有必选任务完成
2. 对照 `assets/references/阶段转换检查表.md` 验证
3. 用户确认（通过当前平台的消息机制）

### The Loop（自治巡检）

PDCA 控制器运行的 4 步巡检循环：
1. **Scrape**：获取所有项目文档（来源由后端决定）
2. **Load (Logic)**：加载阶段特定的"必需条件"和"交付物清单"
3. **Verify**：对比文档内容与要求，识别差距或逻辑冲突
4. **Message**：发送通知（通过当前平台的消息机制，严重程度用颜色区分）

---

## 质量标准 / Quality Standards

### Red Flags - 立即停止

遇到以下信号时，**立即停止**并返回 Plan 阶段：
- 目标没有具体数字
- "执行中再调整"
- "快速补救一下"
- "老板在催，先开始吧"
- "已经花了 X 周了"（沉没成本谬误）
- 直接接受用户提供的原因而不验证

### Rationalization 防御

| 借口 | 现实 |
|------|------|
| "时间紧，需要快速上线" | 没有清晰目标的快速上线 = 朝错误方向加速 |
| "没有项目经理，用简单方式" | 简单方式仍需 SMART 基础 |
| "用户已经说了原因" | 用户说的是症状，不是根因 |

---

## 重要约束 / Important Constraints

1. **Single Source of Truth**：项目状态的事实来源（Fact Source）由工具后端决定，同一项目内保持一致
2. **User Decision Required**：所有阶段转换和项目结项需用户确认
3. **Immediate Alerting**：巡检发现逻辑偏差或进度停滞，立即通过当前平台通知用户
4. **No Shortcuts**：SMART 校验和因果逻辑验证是强制的，不可跳过

---

## 飞书 API 注意事项 / Feishu API Notes

### 关键坑位

| 字段类型 | 注意事项 |
|---------|---------|
| **人员字段** | 必须是 `[{id: "ou_xxx"}]`，不能是字符串 |
| **日期字段** | 毫秒时间戳，不是秒 |
| **超链接字段 (type=15)** | 创建时不要传 `property` 参数 |
| **日历事件** | 必须传 `user_open_id` 让用户能看到日程 |
| **并发写入** | Bitable 不支持并发写，串行调用 + 0.5-1s 延迟 |

---

## 测试 / Testing

基线测试场景：`assets/tests/baseline-test-scenarios.md`

这些验证**不加载技能时的行为**，以识别技能应该解决的问题。

---

## 使用后优化指南 / Optimization Guide

### 当你发现问题时

1. **问题分类**：
   - **内容问题**（SKILL.md 描述不清、流程有误）
   - **API 问题**（飞书 API 调用错误、参数不对）
   - **逻辑问题**（阶段转换条件、验证规则）
   - **格式问题**（文档结构、路径引用）

2. **对应文件**：
   | 问题类型 | 修改文件 |
   |---------|---------|
   | 内容问题 | `SKILL.md`, `system/Agent/*.md` |
   | API 问题 | `assets/references/feishu-integration.md` |
   | 逻辑问题 | `system/规范/Validators/*.md` |
   | 格式问题 | `README.md`, `CLAUDE.md` |

3. **修改后操作**：
   ```bash
   # 1. 提交到 GitHub
   git add -A && git commit -m "fix: 描述修改内容"
   git push origin main

   # 2. 发布新版本
   npm version patch  # 或 minor/major
   ```

   这会自动推送 + 发布到 npm（配置了 postversion hook）

### 快速进入状态

当你下次来优化时，需要检查：
1. **npm 版本**：`npm view @feng-h/pdca-skill version`
2. **文档结构**：`ls -la assets/ system/`
3. **用户反馈**：具体问题描述

---

## 最近变更 / Recent Changes

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0.9 | 2026-04-06 | 添加 OpenClaw 对比表格，说明 Lark-CLI 可能性 |
| **v2.0.0** | **2026-04-12** | **平台无关化重构**：Agent 层解绑 OpenClaw，飞书作为推荐后端；新增主动巡检规范；文件重组 |
| v1.0.8 | 2026-04-06 | 说明为什么需要 OpenClaw + 飞书 |
| v1.0.7 | 2026-04-06 | 添加中/英/日多语言 README |
| v1.0.6 | 2026-04-06 | 添加 Claude Code 技能支持 |
| v1.0.5 | 2026-04-06 | 添加 npx bin 可执行文件 |
| v1.0.0-v1.0.4 | 2026-04-06 | 初始版本，项目结构重构 |

---

## 发布流程 / Release Process

```bash
# 一键发布（自动推送到 GitHub + npm）
npm run release:patch   # 补丁版本 (1.0.9 → 1.0.10)
npm run release:minor   # 次要版本 (1.0.9 → 1.1.0)
npm run release:major   # 主要版本 (1.0.9 → 2.0.0)
```

---

**Platform-Agnostic PDCA Skill** / **平台无关的 PDCA 技能** / **プラットフォーム非依存の PDCA スキル**
