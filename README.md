# PDCA with AI — AI-Driven Project Management System

[English](#english) | [中文](#中文) | [日本語](#日本語)

---

<a href="https://www.npmjs.com/package/@feng-h/pdca-skill"><img src="https://img.shields.io/npm/v/@feng-h/pdca-skill" alt="npm version"></a>
<a href="https://www.npmjs.com/package/@feng-h/pdca-skill"><img src="https://img.shields.io/npm/dm/@feng-h/pdca-skill" alt="npm downloads"></a>
<a href="https://github.com/Feng-H/PDCA-with-AI/blob/main/LICENSE"><img src="https://img.shields.io/npm/l/@feng-h/pdca-skill" alt="License"></a>
<a href="https://github.com/Feng-H/PDCA-with-AI"><img src="https://img.shields.io/github/stars/Feng-H/PDCA-with-AI?style=social" alt="GitHub stars"></a>

---

## 中文

**基于 PDCA 循环的 AI 增强型问题解决工作流** — 集成飞书全工具链（Wiki + Bitable + Task + Calendar + Sheet），由 AI 主动巡检与质量校验。

### 🎯 系统简介

PDCA with AI 是一个**时间流驱动**的项目管理系统。它将经典 PDCA 循环（Plan-Do-Check-Act）与 AI Agent 的主动驱动能力结合，通过飞书 API 实现从「问题分析」到「知识沉淀」的完整闭环。

### 核心亮点

- **自治巡检 (The Loop)**：AI 自动读取一线人员填写的云文档，汇总进展并同步至 Bitable 看板
- **质量校验 (Validator)**：在 Plan 阶段执行 **SMART 校验**与**因果逻辑链审查**
- **即时预警 (Real-time Cards)**：巡检发现逻辑偏差或进度停滞，AI 立即发送飞书交互式卡片
- **知识库 (Archiving)**：项目结项后，AI 自动提炼成功措施并归档
- **制造场景优化**：内置设备 OEE 提升、不良率降低等专业模板

### 🚀 快速开始

```bash
# npm 安装
npm install -g @feng-h/pdca-skill

# 或 npx 直接运行
npx @feng-h/pdca-skill
```

### 常用指令

| 指令 | 说明 |
|------|------|
| `new` | 启动新项目 |
| `ongoing` | 查看活跃项目看板 |
| `achieve` | 检索历史成功案例 |

---

## English

**AI-enhanced problem-solving workflow based on the PDCA cycle** — Integrated with Feishu/Lark full toolchain (Wiki + Bitable + Task + Calendar + Sheet), powered by AI-driven inspection and quality validation.

### 🎯 Overview

PDCA with AI is a **time-flow driven** project management system. It combines the classic PDCA cycle (Plan-Do-Check-Act) with AI Agent's proactive capabilities, achieving a complete closed loop from "problem analysis" to "knowledge retention" through Feishu API.

### Key Features

- **Autonomous Inspection (The Loop)**: AI automatically reads cloud documents, summarizes progress, and syncs to Bitable dashboards
- **Quality Validation**: SMART verification and causal logic chain review in Plan phase
- **Real-time Alerts**: AI sends Feishu interactive cards immediately when logic deviations or progress stagnation are detected
- **Knowledge Archiving**: AI extracts successful measures for future reuse
- **Manufacturing Optimization**: Built-in templates for OEE improvement, defect rate reduction, etc.

### 🚀 Quick Start

```bash
# Install via npm
npm install -g @feng-h/pdca-skill

# Or run directly with npx
npx @feng-h/pdca-skill
```

### Common Commands

| Command | Description |
|---------|-------------|
| `new` | Start a new project |
| `ongoing` | View active project dashboard |
| `achieve` | Search historical success cases |

---

## 日本語

**PDCAサイクルに基づくAI強化型問題解決ワークフロー** — Feishu/Larkフルツールチェーン（Wiki + Bitable + Task + Calendar + Sheet）と統合され、AI主導の検査と品質検証を備えています。

### 🎯 概要

PDCA with AIは**タイムフロー駆動型**のプロジェクト管理システムです。古典的なPDCAサイクル（Plan-Do-Check-Act）とAIエージェントの能動的な能力を組み合わせ、Feishu APIを通じて「問題分析」から「知識蓄積」までの完全なクローズドループを実現します。

### 主な機能

- **自律検査（The Loop）**：AIが自動的にクラウドドキュメントを読み取り、進捗を要約してBitableダッシュボードに同期
- **品質検証**：PlanフェーズでのSMART検証と因果ロジックチェーンレビュー
- **リアルタイムアラート**：論理の偏差や進捗の停滞を検出すると、AIが即座にFeishuインタラクティブカードを送信
- **知識アーカイブ**：プロジェクト完了後、AIが成功した施策を抽出して保存
- **製造業向け最適化**：OEE向上、不良率低減などの専門テンプレートを内蔵

### 🚀 クイックスタート

```bash
# npmでインストール
npm install -g @feng-h/pdca-skill

# またはnpxで直接実行
npx @feng-h/pdca-skill
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
├── SKILL.md            # Main skill entry point
├── assets/             # Documentation and tests
│   ├── references/     # Execution guides and API integration specs
│   ├── tests/          # Baseline tests and quality validation
│   └── templates/      # Project templates
├── system/             # Core engine layer
│   ├── Agent/          # Plan/Do/Check/Act Agent prompts
│   └── 规范/            # SMART validation and causal logic modules
└── README.md
```

## 📚 Documentation

- [飞书集成指南](assets/references/feishu-integration.md) - Feishu/Lark API Integration
- [质量标准](assets/tests/) - Quality Standards & Testing
- [GitHub Repository](https://github.com/Feng-H/PDCA-with-AI)

## 📄 License

[MIT](LICENSE)

---

**Powered by AI, making PDCA cycles truly spin!** / **由 AI 驱动，让 PDCA 循环真正「转」起来！** / **AI で駆動され、PDCA サイクルを本当に回す！**
