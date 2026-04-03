# PDCA with AI - Project Instructional Context

This workspace contains an AI-enhanced PDCA (Plan-Do-Check-Act) Project Management System. It is designed to guide users through structured problem-solving workflows, particularly in manufacturing and quality management, integrated with the Feishu (Lark) ecosystem.

## 📁 Directory Overview

- **`_系统/`**: Core system logic and specifications.
    - **`Agent/`**: Definitions for specialized AI agents (Plan, Do, Check, Act, and the central PDCA Controller).
    - **`工具/`**: Operational guides like exception handling and phase transition checklists.
    - **`模板/`**: Reusable templates for projects and phases.
    - **`规范/`**: Core standards and conventions for the system.
- **`skill/`**: Implementation of the `pdca` skill.
    - **`SKILL.md`**: The primary entry point and evaluation logic for the skill.
    - **`references/`**: Detailed guides for each phase and integration (Feishu, Cron, etc.).
- **`项目/`**: Active and completed project instances.
    - Each project has its own directory containing `项目信息.md` and phase-specific folders (e.g., `Plan阶段/`).
- **`PDCA-CHAT.md`**: Log or reference for chat interactions within the PDCA context.

## 🤖 System Architecture

The system operates as a time-driven workflow managed by the **PDCA Controller** (`_系统/Agent/PDCA控制器.md`).

### Specialized Agents
1. **PlanAgent**: Focuses on problem analysis, SMART goal setting, and solution planning.
2. **DoAgent**: Manages execution, progress logging, and issue tracking.
3. **CheckAgent**: Handles data analysis, effect evaluation, and diagnostics.
4. **ActAgent**: Drives decision-making, standardization, and knowledge synthesis.

## 🚀 Key Workflows

### Project Management Commands
The system is navigated using three primary intents (defined in `_系统/项目管理系统.md`):
- `new`: Initialize a new project, create directory structures, and start the Plan phase.
- `ongoing`: List and select from active projects to continue work.
- `achieve`: Access completed projects for review and knowledge reuse.

### Phase Transitions
Transitions between Plan → Do → Check → Act are strictly sequential and require:
1. Completion of all mandatory tasks in the current phase.
2. Verification against the `_系统/工具/阶段转换检查表.md`.
3. Explicit user confirmation.

## 🛠️ Integration & Tools

- **Feishu (Lark)**: Primary interface for document storage (Wiki), status tracking (Bitable), task management, and scheduling (Calendar).
- **Cron**: Automated daily reminders, phase warnings, and milestone alerts.
- **Knowledge Base**: Successes are archived into a central experience library for reuse in future projects.

## 📝 Usage for Gemini CLI

When interacting with this workspace, you should:
1. **Identify the Project State**: Check the `项目/` directory and read `_系统/项目状态跟踪.md` or `项目信息.md` of specific projects.
2. **Adhere to Phase Constraints**: Do not jump ahead in the PDCA cycle. Follow the instructions in the relevant `Agent.md` and `references/` for the current phase.
3. **Use the Skill**: The `pdca` skill (`skill/SKILL.md`) provides the high-level logic for project evaluation and creation.
4. **Feishu-First**: Assume that primary project data (detailed logs, large data sets) resides in Feishu; use the provided integration guides to interact with these tools.
