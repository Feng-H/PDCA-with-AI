# PDCA with AI — OpenClaw + Feishu 集成技能包

[English](#english) | [中文](#中文) | [日本語](#日本語)

---

<a href="https://www.npmjs.com/package/@feng-h/pdca-skill"><img src="https://img.shields.io/npm/v/@feng-h/pdca-skill" alt="npm version"></a>
<a href="https://www.npmjs.com/package/@feng-h/pdca-skill"><img src="https://img.shields.io/npm/dm/@feng-h/pdca-skill" alt="npm downloads"></a>
<a href="https://github.com/Feng-H/PDCA-with-AI/blob/main/LICENSE"><img src="https://img.shields.io/npm/l/@feng-h/pdca-skill" alt="License"></a>
<a href="https://github.com/Feng-H/PDCA-with-AI"><img src="https://img.shields.io/github/stars/Feng-H/PDCA-with-AI?style=social" alt="GitHub stars"></a>

---

## ⚠️ 重要说明 / Important Notice

**这是一个专门为 OpenClow + 飞书（Feishu/Lark）设计的技能包。**

This is a skill package designed specifically for **OpenClaw + Feishu/Lark** integration.

**これは、OpenClaw + Feishu/Lark の統合のために特別に設計されたスキルパッケージです。**

---

### 适用平台 / Supported Platform

| 平台 | 支持状态 |
|------|---------|
| **OpenClaw** | ✅ 完全支持 |
| **Gemini CLI** | ✅ 完全支持 |
| **Claude Code** | ⚠️ 参考文档（不直接使用） |
| **Codex / Cursor / Continue** | ⚠️ 参考文档（不直接使用） |

### 核心依赖 / Core Dependencies

本技能包依赖以下飞书 API：

- `feishu-create-doc` - 创建云文档
- `feishu-update-doc` - 更新云文档
- `feishu-bitable` - 多维表格操作
- `feishu-calendar` - 日程管理
- `feishu-task` - 任务管理
- `feishu-im-read` - 消息读取

**如果没有安装 OpenClaw 飞书插件，此技能包无法正常工作。**

---

## 中文

### 🎯 系统简介

基于 PDCA 循环的 AI 增强型问题解决工作流，专为 **OpenClaw + 飞书** 环境设计。

### 快速开始

```bash
# 通过 skills.sh 安装到 OpenClaw
npx skills add Feng-H/PDCA-with-AI --agent skills

# 或使用 Gemini CLI
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git
```

### 常用指令

| 指令 | 说明 |
|------|------|
| `new` | 启动新项目 |
| `ongoing` | 查看活跃项目看板 |
| `achieve` | 检索历史成功案例 |

---

## English

### 🎯 Overview

AI-enhanced problem-solving workflow based on the PDCA cycle, designed specifically for **OpenClaw + Feishu/Lark** environments.

### Quick Start

```bash
# Install via skills.sh for OpenClaw
npx skills add Feng-H/PDCA-with-AI --agent skills

# Or using Gemini CLI
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git
```

### Common Commands

| Command | Description |
|---------|-------------|
| `new` | Start a new project |
| `ongoing` | View active project dashboard |
| `achieve` | Search historical success cases |

---

## 日本語

### 🎯 概要

PDCAサイクルに基づくAI強化型問題解決ワークフロー、**OpenClaw + Feishu/Lark** 環境のために特別に設計されました。

### クイックスタート

```bash
# skills.sh 経由で OpenClaw にインストール
npx skills add Feng-H/PDCA-with-AI --agent skills

# または Gemini CLI を使用
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git
```

### 一般コマンド

| コマンド | 説明 |
|---------|------|
| `new` | 新規プロジェクトを開始 |
| `ongoing` | アクティブなプロジェクトダッシュボードを表示 |
| `achieve` | 過去の成功事例を検索 |

---

## 📁 Project Structure

```
PDCA-with-AI/
├── SKILL.md            # OpenClaw/Gemini skill entry point
├── .claude/skills/     # Reference documentation (not for execution)
├── assets/             # Documentation and tests
│   ├── references/     # Feishu API integration guides
│   ├── tests/          # Quality validation
│   └── templates/      # Project templates
├── system/             # Core engine layer
│   ├── Agent/          # Plan/Do/Check/Act Agent prompts
│   └── 规范/            # SMART validation modules
└── README.md
```

## 📚 Documentation

- [飞书 API 集成指南](assets/references/feishu-integration.md) - Feishu/Lark API Integration
- [OpenClaw 文档](https://github.com/open-claw/open-claw) - OpenClaw Plugin
- [质量标准](assets/tests/) - Quality Standards & Testing

## 📄 License

[MIT](LICENSE)

---

**Designed for OpenClaw + Feishu** / **专为 OpenClaw + 飞书设计** / **OpenClaw + Feishu のために設計**
