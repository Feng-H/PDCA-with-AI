# PDCA with AI — 自治驱动的项目管理系统

**基于 PDCA 循环的 AI 增强型问题解决工作流** — 集成飞书全工具链（Wiki + Bitable + Task + Calendar + Sheet），由 AI 主动巡检与质量校验。

---

## 🎯 系统简介

PDCA with AI 是一个**时间流驱动**的项目管理系统。它将经典 PDCA 循环（Plan-Do-Check-Act）与 AI Agent 的主动驱动能力结合，通过飞书 API 实现从「问题分析」到「知识沉淀」的完整闭环。

### 核心亮点

- **自治巡检 (The Loop)**：AI 自动读取一线人员填写的云文档，汇总进展并同步至 Bitable 看板。
- **质量校验 (Validator)**：在 Plan 阶段执行 **SMART 校验**与**因果逻辑链审查**，确保方案足以达成目标。
- **即时预警 (Real-time Cards)**：巡检发现逻辑偏差或进度停滞，AI 立即向项目经理发送飞书交互式卡片。
- **知识库 (Archiving)**：项目结项后，AI 自动提炼成功措施并归档，供未来项目复用。
- **制造场景优化**：内置设备 OEE 提升、不良率降低等专业模板。

---

## 📁 项目结构

```
PDCA-with-AI/
├── SKILL.md            # 符合 skill-creator 规范的主控文件
├── assets/             # 详细文档与测试
│   ├── references/     # 执行指南与 API 集成规范
│   ├── tests/          # 基线测试与质量验证
│   └── templates/      # 项目模板
├── system/             # 核心引擎层（后端规范与逻辑）
│   ├── Agent/          # Plan/Do/Check/Act 专业 Agent 提示词
│   └── 规范/            # SMART 校验与因果逻辑模组
└── README.md
```

---

## ✅ 质量标准

本项目遵循 [superpowers:writing-skills](https://github.com/obra/superpowers) 标准：

- **RED-GREEN-REFACTOR**：所有 skill 经过基线测试验证
- **Rationalization 防御**：明确禁止 Agent 的常见违规理由
- **Red Flags 机制**：识别何时需要停止并重新评估
- **Token 效率**：主文件保持精简，详细内容分离到 references/

测试文档：[assets/tests/](assets/tests/)

---

## 🚀 快速开始

### 1. 安装 Skill

**方式 A：通过 npm 安装（推荐）**
```bash
npm install -g @feng-h/pdca-skill
# 或使用 npx 直接运行
npx @feng-h/pdca-skill
```

**方式 B：通过 Git 安装**
```bash
# OpenClaw / Gemini CLI 环境
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git

# 或使用 skills 框架
npx skills add Feng-H/PDCA-with-AI
```

### 2. 常用指令
- **启动新项目**：输入 `new` 或提到「启动 PDCA 项目」。
- **跟进进度**：输入 `ongoing` 查看活跃项目看板。
- **借鉴经验**：输入 `achieve` 检索历史成功案例。

---

## 🛠️ 飞书集成概览

基于 **OpenClaw Lark 插件**（官方插件，由飞书开放平台团队开发），系统拥有以下原生能力：

### Core Workflow

```
🚀 PDCA项目管理系统

可用命令：
- new     ：启动新项目
- ongoing : 选择进行中的项目
- achieve : 选择已完成的项目
```

### 核心原则：一个项目 = 一个文件夹 = 一个 Bitable 应用

每个 PDCA 项目的所有资源归**同一个飞书文件夹**，确保结构清晰、集中管理、便于追溯。

使用 `feishu-create-doc` 的 `wiki_space` 或 `folder_token` 参数创建项目根文件夹，`title` 参数中使用 `/` 自动创建子文件夹层次（如 `项目A/Plan阶段/问题分析`）。

### 工具链能力矩阵

| 工具 | 用途 | 核心 Skill |
|------|------|-----------|
| **Create Doc** | 创建云文档到指定文件夹/知识库 | `feishu-create-doc` (`wiki_space`, `folder_token`, `title` with `/`) |
| **Update Doc** | 局部更新云文档 (append/replace_range/insert_before/after/delete_range/replace_all) | `feishu-update-doc` |
| **Fetch Doc** | 读取云文档 Markdown 内容 | `feishu-fetch-doc` |
| **Bitable** | 多维表格 CRUD + 批量操作 + 高级筛选 | `feishu-bitable` (27种字段类型) |
| **Calendar** | 日程管理 + 忙闲查询 + 参会人管理 | `feishu-calendar` |
| **Task** | 任务创建/查询/更新/完成 + 清单管理 | `feishu-task` |
| **Sheet** | 电子表格创建/编辑 | `feishu-sheets` |
| **IM Read** | 群聊/私聊历史读取 | `feishu-im-read` |
| **Troubleshoot** | API 连通性/权限诊断 | `feishu-troubleshoot` |

---

## 📚 文档创建指南

### 文档创建规则

1. **项目根文件夹**：首次创建项目时，用 `create-doc` 创建"项目信息.md"，指定 `wiki_space` 或 `folder_token`，`title` 设为 `[项目名称]/项目信息`，飞书自动创建 `[项目名称]` 文件夹
2. **阶段文档**：`title` 设为 `[项目名称]/Plan阶段/问题分析`，自动归入对应文件夹
3. **项目索引**：在根目录创建或更新，记录所有项目的名称、阶段、状态、Bitable链接

### 文档更新规则

使用 `feishu-update-doc` 更新已有文档：
- 优先使用**局部更新**（`replace_range`/`append`/`insert_before`/`insert_after`）保护图片和评论
- 慎用 `overwrite`（会清空文档重写）

---

**由 AI 驱动，让 PDCA 循环真正「转」起来！**
