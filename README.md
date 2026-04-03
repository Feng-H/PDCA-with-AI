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
├── pdca/               # OpenClaw Skill 包（前端接口层）
│   ├── SKILL.md        # 符合 skill-creator 规范的主控文件
│   └── references/     # 详细的执行指南与 API 集成规范
├── _系统/              # 核心引擎层（后端规范与逻辑）
│   ├── Agent/          # Plan/Do/Check/Act 专业 Agent 提示词
│   ├── 规范/            # SMART 校验与因果逻辑模组
│   └── 经验库.md        # 组织知识沉淀
└── 项目/               # 项目实例数据（本地映射）
```

---

## 🚀 快速开始

### 1. 安装 Skill
在你的 OpenClaw / Gemini CLI 环境中运行：
```bash
gemini skills install https://github.com/Feng-H/PDCA-with-AI.git --path pdca
```

### 2. 常用指令
- **启动新项目**：输入 `new` 或提到「启动 PDCA 项目」。
- **跟进进度**：输入 `ongoing` 查看活跃项目看板。
- **借鉴经验**：输入 `achieve` 检索历史成功案例。

---

## 🛠️ 飞书集成概览

| 工具 | 用途 |
|------|------|
| **Wiki** | 项目主存储（方案、日志、总结） |
| **Bitable** | 项目看板（进度、状态可视化） |
| **Card** | 交互式预警（即时上报、决策按钮） |
| **Calendar** | 时间管理（截止日、里程碑提醒） |
| **Sheet** | 数据分析（OEE、合格率等指标记录） |

---

**由 AI 驱动，让 PDCA 循环真正「转」起来！**
