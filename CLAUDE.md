# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PDCA-with-AI is an **AI-driven workflow system** based on the PDCA (Plan-Do-Check-Act) cycle, not a traditional software codebase. The system integrates with Feishu (Lark) tools (Wiki, Bitable, Calendar, Task, Sheet) to provide structured problem-solving workflows for manufacturing and quality improvement scenarios.

**Key distinction:** This project consists primarily of markdown files that define AI agents, workflows, and templates. There is no TypeScript/JavaScript source code to build or test.

## Architecture

### Entry Point
- **`pdca/SKILL.md`** — The main skill definition. When the `pdca` skill is invoked, this file contains the primary logic for project evaluation and creation.

### Core System Files (`_系统/`)
- **`Agent/PDCA控制器.md`** — Central orchestrator managing the PDCA time flow, phase transitions, and rollback mechanisms
- **`Agent/PlanAgent.md`**, **`DoAgent.md`**, **`CheckAgent.md`**, **`ActAgent.md`** — Phase-specific AI agents
- **`规范/核心规范.md`** — Core system standards, including the principle that **Bitable is the single source of truth for all data**
- **`规范/Validators/smart.md`** — SMART goal validation standards
- **`规范/Validators/logic.md`** — Causal logic chain validation

### Reference Documentation (`pdca/references/`)
- **`feishu-integration.md`** — Complete Feishu API integration patterns (Wiki, Bitable, Calendar, Task, Sheet)
- **`cron-driving.md`** — Automated inspection loop logic (The Loop: Scrape → Load → Verify → Message)
- **`transition-checklist.md`** — Phase transition requirements
- **`exception-handling.md`** — Exception handling patterns

### Project Structure
```
PDCA-with-AI/
├── pdca/               # Skill package (frontend interface layer)
│   ├── SKILL.md        # Main skill entry point
│   ├── references/     # Detailed guides
│   └── tests/          # Baseline tests
├── _系统/              # Core engine (backend specifications)
│   ├── Agent/          # Agent definitions
│   ├── 规范/            # Standards and validators
│   └── 工具/            # Operational guides
└── 项目/               # Active project instances
```

## Key Workflows

### Three Primary Commands
The system is invoked through three main intents (defined in `_系统/项目管理系统.md`):

| Command | Purpose | Output |
|---------|---------|--------|
| `new` | Initialize a new project | Creates Feishu Wiki + Bitable + Calendar resources |
| `ongoing` | Manage active projects | Progress check + status update + alerts |
| `achieve` | Search experience library | Best practice recommendations + template matching |

### Phase Transition Logic
Phase transitions are **strictly sequential** and require:
1. Completion of all mandatory tasks in current phase
2. Verification against `_系统/工具/阶段转换检查表.md`
3. Explicit user confirmation (via Feishu interactive cards)

### The Loop (Automated Inspection)
The PDCA Controller runs a 4-step inspection cycle:
1. **Scrape (Wiki)**: Fetch all project documents from Feishu Wiki
2. **Load (Logic)**: Load phase-specific "required conditions" and "deliverables checklist"
3. **Verify**: Compare Wiki content against requirements, identify gaps or logic conflicts
4. **Message (Card)**: Send Feishu interactive card (green/yellow/red based on severity)

## Quality Standards

This project follows [superpowers:writing-skills](https://github.com/obra/superpowers) standards:
- **RED-GREEN-REFACTOR**: All skills validated via baseline tests
- **Rationalization Defense**: Explicit prohibitions against common agent shortcuts
- **Red Flags**: Stop-and-restart signals when quality is at risk

### Critical Red Flags
When you encounter these signals, **STOP immediately** and return to Plan phase:
- Goals without specific numbers
- "We'll adjust during execution"
- "Quick fix is enough"
- "Boss is rushing, let's start"
- "Already spent X weeks" (sunk cost fallacy)
- Accepting user-provided causes without Why/verification

### Rationalization Defenses
Common excuses that must be rejected:
- "Time is tight, need to launch quickly" → Fast launch without clear goals = accelerating in wrong direction
- "No project manager, use simple approach" → Simple approach still needs SMART foundation
- "User already identified the cause" → User provides symptoms, not root causes
- "Plan took 3 weeks, too long" → Time is not a reason to skip quality checks

## Important Constraints

1. **Single Source of Truth**: Feishu Bitable is the only authoritative source for project status data
2. **User Decision Required**: All phase transitions and project closures require explicit user confirmation
3. **Immediate Alerting**: When inspection finds logic deviations or progress stagnation, immediately send Feishu interactive card
4. **No Shortcuts**: SMART validation and causal logic verification are mandatory, not optional

## Testing

Baseline test scenarios are in `pdca/tests/baseline-test-scenarios.md`. These verify behavior WITHOUT the skill loaded to identify problems that the skill should solve.

## Feishu Integration Notes

Key Feishu API patterns from `feishu-integration.md`:
- **Bitable person fields**: Must be `[{id: "ou_xxx"}]`, not strings
- **Bitable date fields**: Millisecond timestamps, not seconds
- **Bitable hyperlink fields (type=15)**: Do NOT pass `property` parameter on create
- **Calendar events**: Always pass `user_open_id` from SenderId so user can see the event
- **No concurrent writes**: Bitable does not support concurrent writes, call serially with 0.5-1s delay
