# PDCA with AI — OpenClaw + 飞书集成技能包

[English](#english) | [中文](#中文) | [日本語](#日本語)

---

<a href="https://www.npmjs.com/package/@feng-h/pdca-skill"><img src="https://img.shields.io/npm/v/@feng-h/pdca-skill" alt="npm version"></a>
<a href="https://www.npmjs.com/package/@feng-h/pdca-skill"><img src="https://img.shields.io/npm/dm/@feng-h/pdca-skill" alt="npm downloads"></a>
<a href="https://github.com/Feng-H/PDCA-with-AI/blob/main/LICENSE"><img src="https://img.shields.io/npm/l/@feng-h/pdca-skill" alt="License"></a>
<a href="https://github.com/Feng-H/PDCA-with-AI"><img src="https://img.shields.io/github/stars/Feng-H/PDCA-with-AI?style=social" alt="GitHub stars"></a>

---

## ⚠️ 重要说明 / Important Notice

**这是一个深度集成飞书 API 的专业技能包，必须配合 OpenClaw 飞书插件使用。**

This is a specialized skill package with **deep Feishu/Lark API integration**, designed exclusively for **OpenClaw with Feishu Plugin**.

**これは、Feishu/Lark API と深く統合された専門スキルパッケージであり、OpenClaw Feishu プラグインでの使用が必須です。**

---

## 为什么是 OpenClaw + 飞书？/ Why OpenClaw + Feishu?

### 中文

本技能包的核心功能依赖于以下**飞书专属 API**，这些 API 只有 OpenClaw 飞书插件提供：

| API 调用 | 功能 | OpenClaw | Claude Code | Gemini | Codex |
|---------|------|----------|-------------|--------|-------|
| `feishu-create-doc` | 创建云文档到 Wiki/知识库 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-update-doc` | 局部更新文档内容 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-bitable` | 多维表格 CRUD (27种字段类型) | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-calendar` | 日程管理和事件创建 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-task` | 任务创建、查询、更新 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-sheet` | 电子表格操作 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-im-read` | 群聊/私聊历史读取 | ✅ | ⚠️* | ⚠️* | ⚠️* |

> *⚠️ 理论上可通过 Lark-CLI 等第三方工具实现，但未经测试。本技能包仅针对 OpenClaw 飞书插件进行验证。*

**关键特性**：
- **一个项目 = 一个文件夹 = 一个 Bitable 应用** — 飞书原生架构
- **自治巡检 (The Loop)** — AI 定期读取飞书文档、汇总 Bitable 数据
- **交互式卡片预警** — 飞书消息卡片推送
- **知识沉淀** — 自动归档到 Wiki 经验库

这些功能都建立在飞书工具链的深度集成之上，无法在通用 AI 工具中实现。

---

### English

This skill package relies on the following **Feishu-exclusive APIs**, only available via OpenClaw Feishu Plugin:

| API Call | Function | OpenClaw | Claude Code | Gemini | Codex |
|---------|----------|----------|-------------|--------|-------|
| `feishu-create-doc` | Create docs in Wiki/Knowledge Base | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-update-doc` | Partial document updates | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-bitable` | Bitable CRUD (27 field types) | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-calendar` | Calendar & event management | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-task` | Task creation, query, update | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-sheet` | Spreadsheet operations | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-im-read` | Group/private chat history | ✅ | ⚠️* | ⚠️* | ⚠️* |

> *⚠️ Theoretically achievable via third-party tools like Lark-CLI, but untested. This skill package is only validated for OpenClaw Feishu Plugin.*

**Key Features**:
- **One Project = One Folder = One Bitable App** — Native Feishu architecture
- **Autonomous Inspection (The Loop)** — AI periodically reads Feishu docs, aggregates Bitable data
- **Interactive Card Alerts** — Feishu message card push notifications
- **Knowledge Archiving** — Auto-archive to Wiki experience library

These features are built on deep integration with Feishu toolchain and cannot be achieved in generic AI tools.

---

### 日本語

このスキルパッケージは、以下の **Feishu 専用 API** に依存しており、OpenClaw Feishu プラグイン経由でのみ利用可能です：

| API 呼び出し | 機能 | OpenClaw | Claude Code | Gemini | Codex |
|-------------|------|----------|-------------|--------|-------|
| `feishu-create-doc` | Wiki/ナレッジベースにドキュメント作成 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-update-doc` | ドキュメントの部分更新 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-bitable` | Bitable CRUD（27種のフィールドタイプ） | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-calendar` | カレンダーとイベント管理 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-task` | タスク作成、照会、更新 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-sheet` | スプレッドシート操作 | ✅ | ⚠️* | ⚠️* | ⚠️* |
| `feishu-im-read` | グループ/プライベートチャット履歴 | ✅ | ⚠️* | ⚠️* | ⚠️* |

> *⚠️ 理論的には Lark-CLI などのサードパーティツールで実現可能ですが、未テストです。このスキルパッケージは OpenClaw Feishu プラグインでのみ検証されています。*

**主な機能**：
- **1プロジェクト = 1フォルダ = 1 Bitable アプリ** — Feishu ネイティブアーキテクチャ
- **自律検査（The Loop）** — AI が定期的に Feishu ドキュメントを読み取り、Bitable データを集約
- **インタラクティブカードアラート** — Feishu メッセージカードプッシュ通知
- **知識アーカイブ** — Wiki 経験ライブラリへ自動アーカイブ

これらの機能は Feishu ツールチェーンとの深い統合に基づいており、汎用 AI ツールでは実現できません。

---

## 🚀 快速开始 / Quick Start

### 中文

**前提条件**：已安装 OpenClaw 并配置飞书插件

```bash
# 通过 skills.sh 安装
npx skills add Feng-H/PDCA-with-AI --agent skills

# 或使用 Gemini CLI
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git
```

**核心命令**：
- `new` — 启动新 PDCA 项目（自动创建 Wiki + Bitable + Calendar）
- `ongoing` — 查看活跃项目看板
- `achieve` — 检索历史成功案例

---

### English

**Prerequisite**: OpenClaw installed with Feishu plugin configured

```bash
# Install via skills.sh
npx skills add Feng-H/PDCA-with-AI --agent skills

# Or using Gemini CLI
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git
```

**Core Commands**:
- `new` — Start a new PDCA project (auto-creates Wiki + Bitable + Calendar)
- `ongoing` — View active project dashboard
- `achieve` — Search historical success cases

---

### 日本語

**前提条件**: OpenClaw がインストールされ、Feishu プラグインが設定されていること

```bash
# skills.sh 経由でインストール
npx skills add Feng-H/PDCA-with-AI --agent skills

# または Gemini CLI を使用
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git
```

**主要コマンド**:
- `new` — 新規 PDCA プロジェクトを開始（Wiki + Bitable + Calendar を自動作成）
- `ongoing` — アクティブなプロジェクトダッシュボードを表示
- `achieve` — 過去の成功事例を検索

---

## 📁 项目结构 / Project Structure

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

## 📚 文档 / Documentation

- [飞书 API 集成指南](assets/references/feishu-integration.md) - Complete Feishu API Integration Guide
- [OpenClaw 项目](https://github.com/open-claw/open-claw) - OpenClaw Plugin
- [质量标准](assets/tests/) - Quality Standards & Testing

## 📄 License

[MIT](LICENSE)

---

**Designed for OpenClaw + Feishu** / **专为 OpenClaw + 飞书设计** / **OpenClaw + Feishu のために設計**
