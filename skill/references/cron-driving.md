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

## 隔离 agentTurn 的工作流

每日提醒用 agentTurn（isolated session），任务流程：
1. 读取 `workspace/pdca-projects.json` 获取项目列表
2. 过滤出"进行中"的项目
3. 对每个项目，读取飞书知识库中当前阶段的文档
4. 检查模板必填项的完成度
5. 生成提醒消息（announce 到飞书对话）
6. 如果发现阶段到期/超时，在消息中特别标注
