# Cron 驱动机制

每个 PDCA 项目创建一组 cron 任务，实现主动推进。

## 创建项目时的 cron 注册

### 1. 每日进度提醒（agentTurn）
```
sessionTarget: "isolated"
schedule: { kind: "cron", expr: "0 9 * * *", tz: "Asia/Shanghai" }
payload: { kind: "agentTurn", message: "..." }
delivery: { mode: "announce" }
```

message 模板（包含项目上下文）：
```
PDCA项目提醒：{项目名称}
当前阶段：{phase}（计划结束：{endDate}，剩余 {days} 天）
今日待办：
- [检查飞书知识库中 {phase} 阶段文档的填写进度]
- [如有到期里程碑，提醒]
- [如时间已超过80%，发出预警]

请读取飞书文档判断完成度，生成简短提醒发送给用户。
```

### 2. 阶段到期预警（systemEvent）
```
sessionTarget: "main"
schedule: { kind: "at", at: "{阶段结束前1天的09:00 ISO时间}" }
payload: { kind: "systemEvent", text: "..." }
```

text 模板：
```
⚠️ PDCA阶段到期预警：{项目名称} 的 {phase} 阶段明天到期。
请检查转换条件，提醒用户确认是否转换。
```

### 3. 里程碑到期提醒（systemEvent）
```
sessionTarget: "main"
schedule: { kind: "at", at: "{里程碑日期的09:00 ISO时间}" }
payload: { kind: "systemEvent", text: "..." }
```

text 模板：
```
📌 PDCA里程碑提醒：{项目名称} 的里程碑「{milestoneName}」今天到期。
请提醒用户检查交付物完成情况。
```

## 阶段转换时的 cron 更新

1. 删除旧的阶段到期预警 cron（如果已过期）
2. 创建新阶段的到期预警 cron
3. 更新每日提醒的消息模板中的阶段信息
4. 如有新里程碑，创建里程碑 cron

## 项目结束时的清理

1. 删除该项目的所有 cron 任务
2. 更新 pdca-projects.json 中的状态

## 本地状态同步

cron 创建/删除后，同步更新 `workspace/pdca-projects.json`：
- 创建 cron 时，将 jobId 写入对应项目的 cronJobs 字段
- 阶段转换时，更新/替换 cronJobs
- 项目结束时，清除 cronJobs 并标记 status 为"已完成"

## 巡检与预警逻辑 (Cron Job Logic)

### 1. 每日巡检 (Daily Inspection)
- **触发频率**：每天 09:00 (cron: `0 9 * * *`)
- **执行步骤**：
    1. **获取待办项目**：读取 `workspace/pdca-projects.json`，识别所有状态为 "进行中" 的项目。
    2. **Bitable 状态同步**：调用 `feishu_bitable_app_table_record.search` 获取看板上的 `阶段截止日` 和当前 `完成度`。
    3. **深度内容检查**：
        - 调用 `feishu_fetch_doc` 获取对应阶段 Wiki 内容。
        - 识别 Wiki 中任务列表的完成情况，结合里程碑进度计算实际 `完成度`（0-100）。
        - 如涉及数据收集，调用 `feishu_sheet.read` 验证 Sheet 数据是否按时录入。
    4. **偏差分析**：计算 `(当前日期 - 阶段开始日期) / (阶段截止日 - 阶段开始日期)` 得到时间进度，与 `完成度` 进行对比。
    5. **自动更新看板**：调用 `feishu_bitable_app_table_record.update` 同步最新的 `完成度` 和 `状态` 到 Bitable 看板。

### 2. 里程碑与到期预警 (Milestone & Due Warning)
- **预警触发条件**：
    - **时间维**：距离 `阶段截止日` 仅剩 2 天，或已过截止日。
    - **进度维**：时间进度已过 80% 但 `完成度` 低于 60%。
- **预警执行逻辑**：
    - **正常巡检消息**：如果一切正常，发送文本消息概要。
    - **触发预警卡片**：若满足预警条件，调用 `feishu_message.send`（通过消息卡片模板）推送预警。
    - **自动状态调整**：在 Bitable 中将 `状态` 字段标记为 "预警" 或 "超时"。
- **里程碑驱动**：里程碑到期当日，若交付物未就绪，强制发送交互式卡片要求确认原因。

## 隔离 agentTurn 的工作流

每日提醒用 agentTurn（isolated session），任务流程：
1. 读取 `workspace/pdca-projects.json` 获取项目列表
2. 过滤出"进行中"的项目
3. 对每个项目，执行以下检查：
   a. 读取飞书 Wiki 中当前阶段的文档，检查必填项完成度
   b. 读取 Bitable 看板，更新完成度和状态字段
   c. 检查是否有超时的阶段或里程碑
4. 生成提醒消息（announce 到飞书对话）
5. 如果发现阶段到期/超时，在消息中特别标注
6. 将 Bitable 状态变更写回（如：正常→预警→超时）
