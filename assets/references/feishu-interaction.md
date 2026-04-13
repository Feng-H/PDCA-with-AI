# 飞书交互式卡片模板与回调处理指南

PDCA 项目在飞书平台上的交互式卡片设计规范，用于替代纯文本问答，提供按钮/下拉选择等原生交互体验。

## 适用场景

PDCA 项目流程中需要用户做选择的环节：

| 阶段 | 典型交互场景 | 卡片类型 |
|------|------------|---------|
| Plan | 选择 MECE 框架维度（多选） | 多选按钮组 |
| Plan | 确认 SMART 目标（单选） | 单选按钮组 |
| Plan | 问题根因投票（多选） | 多选按钮组 |
| Do | 任务完成确认（单选） | 确认/拒绝按钮 |
| Check | 效果评估判定（单选） | 单选按钮组 |
| Act | 决策选择（单选） | 单选按钮组 |
| 任意 | 阶段转换确认（单选） | 确认/拒绝按钮 |

## 技术前提

### Hermes Agent 飞书平台能力

Hermes Agent 的飞书适配器（`gateway/platforms/feishu.py`）已支持：

1. **发送 Interactive Card**：通过 `msg_type="interactive"` + JSON card payload
2. **接收卡片回调**：按钮点击自动路由为 synthetic COMMAND event
3. **回调格式**：`/card button {"key": "value", ...}`

### 回调处理流程

```
用户点击按钮
    ↓
飞书平台 → card_action_trigger 事件
    ↓
Hermes Feishu Adapter (_on_card_action_trigger)
    ↓
去重检查（15分钟窗口）
    ↓
hermes_action 拦截？（仅用于命令审批，PDCA 不走此路径）
    ↓ 否
生成 synthetic text: /card button {"pdca_action": "select", "value": "选项内容"}
    ↓
路由为 MessageEvent(message_type=COMMAND)
    ↓
Agent 接收到文本消息，解析卡片选择
```

### 当前限制

- **`clarify` 工具不可用**：网关模式下 `clarify` 工具无法弹出原生选择框
- **卡片回调是无状态的**：回调消息不携带原始问题的上下文，需要在 `value` 中编码足够信息
- **卡片发送依赖 Adapter**：当前 Hermes Agent 通过 `send_message` 自动将 Markdown 转为飞书 Post 格式发送，不直接暴露卡片 API 给 Agent。因此 **P0（原生交互）和 P1（Interactive Card）在当前架构下均不可用**
- **推荐方案**：使用 **P2 富文本编号列表** 作为实际交互方式（详见 SKILL.md「平台感知交互」章节）

> ⚠️ **重要**：虽然飞书平台技术层面支持 Interactive Card，但当前 Hermes Agent 的 Agent 层无法直接调用卡片发送 API。本指南的模板供未来集成使用。当前阶段，PDCA 在飞书上的交互统一使用 P2（富文本编号列表 + 用户输入编号回复）。

## 卡片模板库（供未来集成使用）

### 模板 1：多选按钮组（MECE 维度选择）

适用于 Plan 阶段的 MECE 框架维度选择、根因分析等多选场景。

```json
{
  "config": {
    "wide_screen_mode": true
  },
  "header": {
    "title": {
      "tag": "plain_text",
      "content": "📋 PDCA 问题分析 — 选择影响因素"
    },
    "template": "blue"
  },
  "elements": [
    {
      "tag": "div",
      "text": {
        "tag": "lark_md",
        "content": "**项目**：${project_name}\n**当前步骤**：${current_step}\n\n请选择导致问题的主要因素（可多选）："
      }
    },
    {
      "tag": "hr"
    },
    {
      "tag": "action",
      "actions": [
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "🔧 设备/机器"
          },
          "type": "default",
          "value": {
            "pdca_action": "select",
            "field": "${field_name}",
            "value": "设备/机器",
            "option_id": "1"
          }
        },
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "👤 人员/技能"
          },
          "type": "default",
          "value": {
            "pdca_action": "select",
            "field": "${field_name}",
            "value": "人员/技能",
            "option_id": "2"
          }
        },
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "📐 工艺/方法"
          },
          "type": "default",
          "value": {
            "pdca_action": "select",
            "field": "${field_name}",
            "value": "工艺/方法",
            "option_id": "3"
          }
        },
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "📦 材料/物料"
          },
          "type": "default",
          "value": {
            "pdca_action": "select",
            "field": "${field_name}",
            "value": "材料/物料",
            "option_id": "4"
          }
        },
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "🌍 环境/条件"
          },
          "type": "default",
          "value": {
            "pdca_action": "select",
            "field": "${field_name}",
            "value": "环境/条件",
            "option_id": "5"
          }
        }
      ]
    },
    {
      "tag": "hr"
    },
    {
      "tag": "note",
      "elements": [
        {
          "tag": "plain_text",
          "content": "💡 提示：可点击多个按钮选择多个因素。如选项不在列表中，请直接回复描述。"
        }
      ]
    }
  ]
}
```

### 模板 2：单选按钮组（确认/决策）

适用于阶段转换确认、效果评估判定等单选场景。

```json
{
  "config": {
    "wide_screen_mode": true
  },
  "header": {
    "title": {
      "tag": "plain_text",
      "content": "✅ PDCA 阶段转换确认"
    },
    "template": "green"
  },
  "elements": [
    {
      "tag": "div",
      "text": {
        "tag": "lark_md",
        "content": "**项目**：${project_name}\n**当前阶段**：${from_phase} → **目标阶段**：${to_phase}\n\n**完成情况**：\n- 必选任务完成率：${task_completion}%\n- 交付物检查：${deliverable_status}\n\n请确认是否可以进行阶段转换："
      }
    },
    {
      "tag": "hr"
    },
    {
      "tag": "action",
      "actions": [
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "✅ 确认转换"
          },
          "type": "primary",
          "value": {
            "pdca_action": "confirm_transition",
            "project_id": "${project_id}",
            "from_phase": "${from_phase}",
            "to_phase": "${to_phase}",
            "decision": "approve"
          }
        },
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "⏳ 延期，需要更多时间"
          },
          "type": "default",
          "value": {
            "pdca_action": "confirm_transition",
            "project_id": "${project_id}",
            "decision": "extend"
          }
        },
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "❌ 拒绝，返回当前阶段"
          },
          "type": "danger",
          "value": {
            "pdca_action": "confirm_transition",
            "project_id": "${project_id}",
            "decision": "reject"
          }
        }
      ]
    }
  ]
}
```

### 模板 3：预警通知卡片

适用于巡检发现异常时的预警推送（仅展示，无需用户操作）。

```json
{
  "config": {
    "wide_screen_mode": true
  },
  "header": {
    "title": {
      "tag": "plain_text",
      "content": "⚠️ PDCA 项目预警"
    },
    "template": "orange"
  },
  "elements": [
    {
      "tag": "div",
      "text": {
        "tag": "lark_md",
        "content": "**项目名称**：${project_name}\n**当前阶段**：${current_phase}\n**预警类型**：${warning_type}"
      }
    },
    {
      "tag": "div",
      "fields": [
        {
          "is_short": false,
          "text": {
            "tag": "lark_md",
            "content": "**预警原因**：\n${warning_reason}"
          }
        },
        {
          "is_short": true,
          "text": {
            "tag": "lark_md",
            "content": "**当前完成度**：\n${current_progress}%"
          }
        },
        {
          "is_short": true,
          "text": {
            "tag": "lark_md",
            "content": "**阶段截止日**：\n${deadline}"
          }
        },
        {
          "is_short": true,
          "text": {
            "tag": "lark_md",
            "content": "**剩余天数**：\n${remaining_days} 天"
          }
        },
        {
          "is_short": true,
          "text": {
            "tag": "lark_md",
            "content": "**建议措施**：\n${suggestion}"
          }
        }
      ]
    },
    {
      "tag": "hr"
    },
    {
      "tag": "action",
      "actions": [
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "📋 查看项目详情"
          },
          "type": "primary",
          "multi_url": {
            "url": "${wiki_url}",
            "pc_url": "",
            "android_url": "",
            "ios_url": ""
          }
        },
        {
          "tag": "button",
          "text": {
            "tag": "plain_text",
            "content": "💬 忽略本次预警"
          },
          "type": "default",
          "value": {
            "pdca_action": "dismiss_warning",
            "project_id": "${project_id}",
            "warning_id": "${warning_id}"
          }
        }
      ]
    }
  ]
}
```

### 模板 4：巡检摘要卡片

适用于每日巡检的正常状态汇报（信息展示 + 快捷操作）。

```json
{
  "config": {
    "wide_screen_mode": true
  },
  "header": {
    "title": {
      "tag": "plain_text",
      "content": "📊 PDCA 每日巡检摘要"
    },
    "template": "turquoise"
  },
  "elements": [
    {
      "tag": "div",
      "text": {
        "tag": "lark_md",
        "content": "**日期**：${date}\n**活跃项目数**：${active_count}"
      }
    },
    {
      "tag": "column_set",
      "flex_mode": "bisect",
      "background_style": "grey",
      "columns": [
        {
          "tag": "column",
          "width": "weighted",
          "weight": 1,
          "elements": [
            {
              "tag": "div",
              "text": {
                "tag": "lark_md",
                "content": "**🟢 正常**\n${normal_count} 个项目"
              }
            }
          ]
        },
        {
          "tag": "column",
          "width": "weighted",
          "weight": 1,
          "elements": [
            {
              "tag": "div",
              "text": {
                "tag": "lark_md",
                "content": "**🟡 预警**\n${warning_count} 个项目"
              }
            }
          ]
        },
        {
          "tag": "column",
          "width": "weighted",
          "weight": 1,
          "elements": [
            {
              "tag": "div",
              "text": {
                "tag": "lark_md",
                "content": "**🔴 超时**\n${overdue_count} 个项目"
              }
            }
          ]
        }
      ]
    }
  ]
}
```

## 回调数据设计规范

### value 字段结构

所有 PDCA 卡片按钮的 `value` 字段必须包含以下通用字段：

```json
{
  "pdca_action": "string — 操作类型（见下表）",
  "project_id": "string — 项目标识",
  "context": "object — 附加上下文（可选，如阶段名、问题编号等）"
}
```

### pdca_action 类型

| action | 说明 | 触发场景 |
|--------|------|---------|
| `select` | 选择/投票 | MECE 维度选择、根因分析 |
| `confirm_transition` | 阶段转换确认 | Plan→Do, Do→Check 等 |
| `dismiss_warning` | 忽略预警 | 预警通知卡片 |
| `update_progress` | 更新进度 | 巡检后的手动进度更新 |
| `add_note` | 添加备注 | 任意阶段补充说明 |

### Agent 端回调解析

当卡片按钮被点击后，Agent 收到的消息格式为：

```
/card button {"pdca_action": "select", "project_id": "xxx", "value": "设备/机器", "option_id": "1"}
```

Agent 解析步骤：

1. 检测消息前缀 `/card button`
2. JSON 解析 `value` 对象
3. 读取 `pdca_action` 判断操作类型
4. 读取 `project_id` 定位项目
5. 执行对应逻辑并回复确认

### 回调上下文丢失问题

卡片回调不携带原始问题的完整上下文。解决策略：

1. **`value` 编码足够信息**：每个按钮的 `value` 中包含 `project_id`、当前阶段、选项内容等
2. **Agent 对话历史**：利用 Hermes Agent 的会话机制，Agent 之前发送过卡片，对话历史中已有上下文
3. **项目状态查询**：如果上下文不足，通过 Bitable/Wiki API 查询最新项目状态

## 当前可用的交互方式（P2）

由于 Interactive Card 当前无法直接从 Agent 层发送，PDCA 在飞书上的实际交互使用 **P2 富文本编号列表**：

### 格式规范

```markdown
**📋 [问题标题]**

[1-2 句背景说明，说明为什么问这个问题]

请选择（可多选）：

1️⃣ **选项 A** — 补充说明
2️⃣ **选项 B** — 补充说明
3️⃣ **选项 C** — 补充说明
4️⃣ **选项 D** — 补充说明
5️⃣ 其他（请描述您的具体情况）

💡 输入编号选择，多个选项用逗号分隔（如 1,3,5）
```

### Agent 处理逻辑

1. Agent 基于 MECE 框架生成选项内容
2. 使用 P2 格式通过 `send_message` 发送到飞书对话
3. 用户输入编号（如 `1,3,5` 或 `其他：员工流动性大`）
4. Agent 解析编号映射到选项内容
5. 确认选择并推进流程

### 飞书 Post 格式注意事项

Hermes Agent 发送到飞书的消息会被转换为飞书 Post 格式，支持：
- **粗体**：`**文字**`
- 列表：`- 项目` 或 `1. 项目`
- Emoji：直接使用 Unicode emoji
- 分割线：`---` 会被转换为分割线

不支持：
- HTML 标签
- Markdown 链接（使用纯文本 URL）
- 代码块（使用引用格式 `>` 代替）
