# OpenClow API 集成

## 概述

OpenClow 通过 `/pdca/analyze` 端点提供 PDCA 项目的 AI 分析能力。
Bitable 工作流和 PDCA 控制器通过该 API 实现对项目的智能巡检。

## 接口定义

### POST /pdca/analyze

**请求体**:
```json
{
  "project": "[项目名称]",
  "trigger": "scheduled|event|manual",
  "context": {
    "trigger_type": "form_submit|task_complete|scheduled",
    "data_record_id": "[记录ID]",
    "task_id": "[任务ID]"
  }
}
```

**请求参数说明**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| project | string | 是 | 项目名称，用于定位 Bitable 中的数据 |
| trigger | string | 是 | 触发方式：scheduled(定时)/event(事件)/manual(手动) |
| context | object | 否 | 附加上下文信息 |
| context.trigger_type | string | 否 | 具体触发类型 |
| context.data_record_id | string | 否 | 新数据记录 ID（事件触发时传入） |
| context.task_id | string | 否 | 任务 ID（任务变更时传入） |

**响应体**:
```json
{
  "status": "success",
  "insights": ["AI 分析结果1", "AI 分析结果2"],
  "actions": ["建议操作1", "建议操作2"],
  "updates": {
    "wiki": ["需要更新的 Wiki 文档路径"],
    "bitable": {
      "project_completion": 65,
      "project_status": "正常",
      "task_updates": []
    }
  }
}
```

**响应字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| status | string | 分析状态：success/timeout/error/no_changes |
| insights | string[] | AI 分析洞察，每条为一条分析结果 |
| actions | string[] | 建议的操作行动 |
| updates.wiki | string[] | 需要更新的 Wiki 文档路径列表 |
| updates.bitable.project_completion | number | 建议的项目完成度 (0-100) |
| updates.bitable.project_status | string | 建议的项目状态：正常/预警/超时/已完成 |
| updates.bitable.task_updates | object[] | 需要更新的任务记录列表 |

## 调用方式

### 从 Bitable 工作流调用

工作流中的 HTTP 节点配置：
- **URL**: `https://<openclow-host>/pdca/analyze`
- **Method**: `POST`
- **Headers**: `{"Authorization": "Bearer ${OPENCLOW_API_KEY}"}`
- **Body**: 动态填充项目名和上下文

### 从 PDCA 控制器调用

当工作流不可用时，PDCA 控制器可以直接调用：
```bash
curl -X POST https://<openclow-host>/pdca/analyze \
  -H "Authorization: Bearer ${OPENCLOW_API_KEY}" \
  -d '{"project": "项目名称", "trigger": "manual"}'
```

## AI 分析职责

1. **读取 Bitable 数据**: 读取项目主表、任务数据表、数据记录表的当前状态
2. **读取 Wiki 文档**: 读取各阶段文档完成度
3. **计算完成度**: 根据阶段交付物清单计算百分比
4. **状态判定**: 判断正常/预警/超时
5. **趋势分析**: 分析数据记录的变化趋势
6. **生成洞察**: 输出分析结果和建议

## 错误处理

| 状态码 | 响应 | 说明 |
|--------|------|------|
| success | 正常响应 | 分析完成 |
| timeout | `{"status": "timeout"}` | 30 秒超时 |
| error | `{"status": "error", "message": "错误描述"}` | API 错误 |
| no_changes | `{"status": "no_changes", "message": "自上次分析无新数据"}` | 无新数据 |

## 认证

使用 Bearer Token 认证：
```
Authorization: Bearer ${OPENCLOW_API_KEY}
```

API Key 通过环境变量或密钥管理获取，不应硬编码在工作流配置中。
