# PDCA with AI — AI 驱动的 PDCA 工作流技能包

<a href="https://www.npmjs.com/package/@feng-h/pdca-skill"><img src="https://img.shields.io/npm/v/@feng-h/pdca-skill" alt="npm version"></a>
<a href="https://www.npmjs.com/package/@feng-h/pdca-skill"><img src="https://img.shields.io/npm/dm/@feng-h/pdca-skill" alt="npm downloads"></a>
<a href="https://github.com/Feng-H/PDCA-with-AI/blob/main/LICENSE"><img src="https://img.shields.io/npm/l/@feng-h/pdca-skill" alt="License"></a>
<a href="https://github.com/Feng-H/PDCA-with-AI"><img src="https://img.shields.io/github/stars/Feng-H/PDCA-with-AI?style=social" alt="GitHub stars"></a>

---

## [中文](#中文) | [English](#english) | [日本語](#日本語)

---

<a name="中文"></a>

## 中文

### ℹ️ 平台说明

**本技能包的平台无关（Platform-Agnostic）设计：** AI Agent 层不绑定任何特定平台。飞书（Feishu/Lark）作为**推荐深度集成后端**，提供 Bitable、Wiki、Calendar 等完整工具链，但非必需。

### 为什么推荐飞书？

飞书后端提供以下能力，可充分发挥 PDCA 工作流潜力：

| API 调用 | 功能 | OpenClaw | Hermes Agent |
|---------|------|----------|--------------|
| `feishu-create-doc` | 创建云文档到 Wiki/知识库 | ✅ | ✅ |
| `feishu-update-doc` | 局部更新文档内容 | ✅ | ✅ |
| `feishu-bitable` | 多维表格 CRUD (27种字段类型) | ✅ | ✅ |
| `feishu-calendar` | 日程管理和事件创建 | ✅ | ✅ |
| `feishu-task` | 任务创建、查询、更新 | ✅ | ✅ |
| `feishu-sheet` | 电子表格操作 | ✅ | ✅ |
| `feishu-im-read` | 群聊/私聊历史读取 | ✅ | ✅ |
| `feishu_ask_user_question` | 交互式卡片（用户选择） | ✅ | ❌ |

> **交互式卡片说明**：OpenClaw 配合 [openclaw-lark](https://github.com/larksuite/openclaw-lark) 插件支持完整的交互式卡片功能（单选/多选/文本输入）。Hermes Agent 暂不支持，需使用文本编号列表作为备选方案。

### 🎯 系统简介

基于 PDCA 循环的 AI 增强型问题解决工作流，**平台无关设计**，推荐配合飞书使用。

### 核心亮点

- **自治巡检 (The Loop)**：AI 自动读取一线人员填写的云文档，汇总进展并同步至 Bitable 看板
- **质量校验 (Validator)**：在 Plan 阶段执行 **SMART 校验**与**因果逻辑链审查**
- **即时交互 (Interactive Cards)**：OpenClaw 支持飞书交互式卡片，AI 可发送选项让用户选择（单选/多选/文本输入）
- **知识库 (Archiving)**：项目结项后，AI 自动提炼成功措施并归档
- **制造场景优化**：内置设备 OEE 提升、不良率降低等专业模板

### 🚀 快速开始

**前提条件**：已安装支持的 AI Agent 平台

```bash
# 安装（选择 OpenClaw + Global）
npx skills add Feng-H/PDCA-with-AI

# 提示选择时：
# - Agent: 选择 OpenClaw
# - Scope: 选择 Global (安装到 ~/.agents/skills/pdca/)

# 更新已安装的 skill
npx skills update pdca
```

**OpenClaw 飞书插件**：
```bash
# 安装官方飞书插件（支持交互式卡片）
npm install -g @openclaw/plugin-lark
```

### 常用指令

| 指令 | 说明 |
|------|------|
| `new` | 启动新项目 |
| `ongoing` | 查看活跃项目看板 |
| `achieve` | 检索历史成功案例 |

---

<a name="english"></a>

## English

### ℹ️ Platform Notice

**This skill package uses a platform-agnostic design.** The AI Agent layer is not tied to any specific platform. Feishu/Lark is the **recommended backend** for deep integration (Bitable, Wiki, Calendar, etc.), but is not required.

### Why Feishu?

The Feishu backend provides the following capabilities for full PDCA workflow support:

| API Call | Function | OpenClaw + openclaw-lark | Hermes Agent |
|---------|----------|-------------------------|--------------|
| `feishu-create-doc` | Create docs in Wiki/Knowledge Base | ✅ | ✅ |
| `feishu-update-doc` | Partial document updates | ✅ | ✅ |
| `feishu-bitable` | Bitable CRUD (27 field types) | ✅ | ✅ |
| `feishu-calendar` | Calendar & event management | ✅ | ✅ |
| `feishu-task` | Task creation, query, update | ✅ | ✅ |
| `feishu-sheet` | Spreadsheet operations | ✅ | ✅ |
| `feishu-im-read` | Group/private chat history | ✅ | ✅ |
| `feishu_ask_user_question` | Interactive cards (user selection) | ✅ | ❌ |

> **Interactive Cards**: OpenClaw with [openclaw-lark](https://github.com/larksuite/openclaw-lark) plugin supports full interactive card features (single/multi-select, text input). Hermes Agent currently uses text numbered lists as fallback.

### 🎯 Overview

AI-enhanced problem-solving workflow based on the PDCA cycle, with **platform-agnostic design**. Feishu/Lark recommended as the integration backend.

### Key Features

- **Autonomous Inspection (The Loop)**: AI automatically reads cloud documents, summarizes progress, and syncs to Bitable dashboards
- **Quality Validation**: SMART verification and causal logic chain review in Plan phase
- **Interactive Cards**: OpenClaw supports Feishu interactive cards for user selections (single/multi-select, text input)
- **Knowledge Archiving**: AI extracts successful measures for future reuse
- **Manufacturing Optimization**: Built-in templates for OEE improvement, defect rate reduction, etc.

### 🚀 Quick Start

**Prerequisite**: A supported AI Agent platform installed

```bash
# Install via skills.sh
npx skills add Feng-H/PDCA-with-AI --agent skills

# Or using Gemini CLI
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git
```

**OpenClaw Lark Plugin**:
```bash
# Install official Lark plugin (supports interactive cards)
npm install -g @openclaw/plugin-lark
```

### Common Commands

| Command | Description |
|---------|-------------|
| `new` | Start a new project |
| `ongoing` | View active project dashboard |
| `achieve` | Search historical success cases |

---

<a name="日本語"></a>

## 日本語

### ℹ️ プラットフォームについて

**このスキルパッケージはプラットフォームに依存しない設計です。** AI Agent レイヤーは特定のプラットフォームに結びついていません。Feishu/Lark は**推奨統合バックエンド**として Bitable、Wiki、Calendar などの完全なツールチェーンを提供しますが、必須ではありません。

### なぜ Feishu なのか？

Feishu バックエンドは、PDCA ワークフローを完全にサポートするための以下機能を提供します：

| API 呼び出し | 機能 | OpenClaw + openclaw-lark | Hermes Agent |
|-------------|------|-------------------------|--------------|
| `feishu-create-doc` | Wiki/ナレッジベースにドキュメント作成 | ✅ | ✅ |
| `feishu-update-doc` | ドキュメントの部分更新 | ✅ | ✅ |
| `feishu-bitable` | Bitable CRUD（27種のフィールドタイプ） | ✅ | ✅ |
| `feishu-calendar` | カレンダーとイベント管理 | ✅ | ✅ |
| `feishu-task` | タスク作成、照会、更新 | ✅ | ✅ |
| `feishu-sheet` | スプレッドシート操作 | ✅ | ✅ |
| `feishu-im-read` | グループ/プライベートチャット履歴 | ✅ | ✅ |
| `feishu_ask_user_question` | インタラクティブカード（ユーザー選択） | ✅ | ❌ |

> **インタラクティブカード**: OpenClaw と [openclaw-lark](https://github.com/larksuite/openclaw-lark) プラグインの組み合わせで、完全なインタラクティブカード機能（単一/複数選択、テキスト入力）をサポートします。Hermes Agent は現在、テキスト番号リストを代替手段として使用します。

### 🎯 概要

PDCAサイクルに基づく AI 強化型問題解決ワークフロー、**プラットフォームに依存しない設計**。Feishu/Lark が統合バックエンドとして推奨されます。

### 主な機能

- **自律検査（The Loop）**：AI が自動的にクラウドドキュメントを読み取り、進捗を要約して Bitable ダッシュボードに同期
- **品質検証**：Plan フェーズでの SMART 検証と因果ロジックチェーンレビュー
- **インタラクティブカード**：OpenClaw は Feishu インタラクティブカードをサポートし、ユーザー選択（単一/複数選択、テキスト入力）が可能
- **知識アーカイブ**：AI が成功した施策を抽出して将来のために保存
- **製造業向け最適化**：OEE 向上、不良率低減などの専門テンプレートを内蔵

### 🚀 クイックスタート

**前提条件**：サポートされている AI Agent プラットフォームがインストールされていること

```bash
# skills.sh 経由でインストール
npx skills add Feng-H/PDCA-with-AI --agent skills

# または Gemini CLI を使用
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git
```

**OpenClaw Lark プラグイン**：
```bash
# 公式 Lark プラグインをインストール（インタラクティブカードをサポート）
npm install -g @openclaw/plugin-lark
```

### 一般コマンド

| コマンド | 説明 |
|---------|-------------|
| `new` | 新規プロジェクトを開始 |
| `ongoing` | アクティブなプロジェクトダッシュボードを表示 |
| `achieve` | 過去の成功事例を検索 |

---

## 📁 Project Structure

```
PDCA-with-AI/
├── SKILL.md            # Skill entry point
├── .claude/skills/     # Reference documentation
├── assets/             # Documentation and tests
│   ├── references/     # Feishu API integration guides + MECE frameworks
│   ├── tests/          # Quality validation
│   └── templates/      # Project templates
├── system/             # Core engine layer
│   ├── Agent/          # Plan/Do/Check/Act Agent prompts
│   ├── 规范/            # SMART validation modules
│   ├── 工具/            # Bitable config, workflows
│   └── 模板/            # System templates
├── bin/                # npx executable
└── README.md
```

## 📚 Documentation

- [飞书 API 集成指南](assets/references/feishu-integration.md) - Complete Feishu/Lark API Integration Guide
- [飞书交互指南](assets/references/feishu-interaction.md) - Interactive Cards & User Interaction Guide
- [OpenClaw 项目](https://github.com/open-claw/open-claw) - OpenClaw Plugin
- [openclaw-lark 插件](https://github.com/larksuite/openclaw-lark) - Official Lark Plugin (supports `feishu_ask_user_question`)
- [质量标准](assets/tests/) - Quality Standards & Testing

## 📄 License

[MIT](LICENSE)

---

**Platform-Agnostic PDCA Skill** / **平台无关的 PDCA 技能** / **プラットフォーム非依存の PDCA スキル**
