# Zotero 连接、条目发现与写入规范

## 目标

让原 paper2notion 的论文研究流程仅替换持久化后端：使用 Zotero bibliographic parent item 管理论文，将 `中文 Research Memo → 中文结构化详译` 生成独立 PDF 并附加到 parent item。

论文阅读、写作、视觉证据、Research Map 和 Actionable Ideas 要求仍以 `SKILL.md` 与原 references 为准。

## 前提与授权

- 用户需要在 Codex 中连接并授权 Zotero MCP。
- 普通精读和明确翻译不写 Zotero。
- `paper2zotero`、“入库”、“写入 Zotero”或“生成 PDF 笔记”授权创建/更新目标论文条目、导入生成的 PDF、添加窄范围 tags，并仅创建通过质量门槛的 idea child notes。
- 上述授权不包括删除旧附件、合并重复项、整理 collections、覆盖原论文 PDF 或修改无关条目。

## 初始化

`paper2zotero 初始化` 负责在当前 Codex 环境中发现兼容的 Zotero MCP，并为后续工作流建立运行时能力映射。仓库和 skill 不保存 endpoint、端口、token、library ID、item key 或个人绝对路径。

初始化先完成 Zotero MCP 诊断，再按 `pdf-renderer-setup.md` 配置 PDF renderer。未发现 MCP 或连接不可用时，不进入 renderer 安装。

### 发现与适配

1. 枚举当前会话暴露的 MCP 工具或已连接服务，识别具备 Zotero library 语义的实现；
2. 工具已暴露时，立即执行一次只读 library 调用。成功即进入快路径，不运行连接注册表、endpoint、端口或沙箱诊断；
3. 快路径读取实际工具 schema，按 `zotero-mcp-adapter.md` 映射搜索、读取、PDF 解析、附件导入和回读等语义能力；
4. 执行一次 `limit=1` 的最小 library 搜索。搜索结果足以确认条目与附件摘要时，不继续读取 item details、notes 或 PDF 全文；
5. 通过 schema 确认本地 PDF import、导入后回读、tags、child notes 和 metadata 更新等能力，并标记为“已发现、延迟验证”；
6. 只有工具未暴露或只读 library 调用失败时，才运行 `PAPER2ZOTERO_MCP_TOOLS_EXPOSED=yes|no|unknown scripts/zotero-mcp-diagnose.sh`；
7. 若诊断发现已配置但未暴露，报告“已配置、当前会话未暴露”，提示重新加载连接或新建会话；
8. 配置包含可探测 endpoint 时，只对该已注册 endpoint 做无副作用状态检查。沙箱内失败后，若运行环境支持授权重试，应请求授权在沙箱外重试同一只读检查；沙箱外成功则报告“服务可用、沙箱阻断”；
9. 沙箱外仍不可达时，再结合连接管理状态区分服务未启动、endpoint 错误或连接失效。无法获得沙箱外检查权限时报告“已配置、可达性未验证”。

初始化只使用 MCP 返回的稳定标识和附件信息。不得从仓库配置、示例路径或猜测的 Zotero storage 目录推导运行参数。

### 延迟验证

初始化不执行以下高延迟或有副作用的操作：

- PDF 全文提取或 OCR；
- 现有条目的完整 metadata、notes、annotations 和全部 children 读取；
- 创建测试条目、测试附件、测试 note 或测试 tag；
- 实际导入 PDF 及导入后回读；
- renderer 未变化时重复生成和检查样张 PDF。

第一次真正精读时验证目标论文的 PDF 内容读取；第一次真正入库时验证 PDF import 和回读；第一次安装、切换或修复 renderer 时执行完整样张 QA。某项延迟验证失败只影响对应任务能力，不推翻已经通过的 library 与搜索连接检查。

### 能力分级

- **可完整入库**：library 与搜索调用成功，条目/附件读取、本地 PDF 导入和回读 schema 齐全；尚未实际调用的能力注明“延迟验证”；
- **只读**：可以发现和读取论文，但缺少本地 PDF 导入或回读；
- **不可用**：未发现兼容 MCP，或无法读取 library / 搜索条目。

连接诊断状态必须与能力分级分开报告：

| 诊断状态 | 判定 | 下一步 |
|---|---|---|
| `available` | 工具已暴露且只读调用成功 | 继续能力映射 |
| `mcp-endpoint-available` | 当前任务无原生工具包装，但已注册 endpoint 可完成 MCP 连接 | 通过标准 MCP client fallback 继续能力映射 |
| `configured-not-exposed` | 非 HTTP MCP 已注册，但当前会话无对应工具 | 重新加载连接或新建会话 |
| `sandbox-blocked` | 沙箱内探测失败，同一只读探测在授权环境成功 | 保留连接；说明当前执行环境限制 |
| `configured-unverified` | 已发现配置，但无法获得沙箱外检查权限 | 不误报离线，等待用户授权或重载 |
| `service-unreachable` | 已发现配置，授权环境下仍无法连接 | 检查 Zotero、插件 server 与 endpoint |
| `not-configured` | 当前会话、Codex 连接管理状态均无兼容配置 | 提示安装或添加 Zotero MCP |
| `tool-call-failed` | 工具已暴露，但 schema/list/library 调用失败 | 报告具体失败阶段，不回退成“未安装” |

诊断脚本返回 `sandbox-retry-required` 时，代表已发现启用的 Zotero MCP 配置及本机监听，但当前沙箱无法访问 endpoint。此时必须申请授权，在授权环境重跑同一脚本。重跑成功应归类为 `mcp-endpoint-available` 或 `available`，随后通过 `zotero-mcp-client.sh` 继续初始化；重跑仍失败才能继续判断服务不可达。`service-unreachable-unverified` 只表示需要授权复验，不能转述成“Zotero 没启动”。

`mcp-endpoint-available` 不是失败状态。先执行 `scripts/zotero-mcp-client.sh list-tools`，再用 `call` 子命令完成 library 读取与最小搜索。原生工具包装可用时仍优先使用原生工具；fallback 只弥补当前任务没有包装函数的情况。读写授权、副作用边界、去重和回读要求与原生工具路径完全相同。

标准 MCP HTTP fallback 必须同时满足四项前提：Codex 注册配置已确认、使用注册表返回的本机 endpoint、MCP 握手成功、用户已授权使用 fallback。用户本轮的“入库 / 写入 Zotero / paper2zotero”可授权该任务范围内的必要写入，但不授权删除、合并或修改无关内容。每次 fallback 写入后都必须通过 MCP 回读返回的 attachment/item key 及其 parent；回读失败时标记“写入未验证”，不得报告完成。

### 用户提供 MCP Configuration

以下情况应请用户从 Zotero 的 MCP 设置页复制面向客户端的 configuration，而不是直接要求重装插件：

- Codex 连接注册表不可用或无法解析；
- 当前会话没有 Zotero 工具，且无法确认 Codex 是否已经注册连接；
- 用户确认 Zotero 插件正在运行，但 skill 无法定位正确 transport；
- 已注册配置疑似过期，需要和 Zotero 当前生成的配置核对。

收到配置后：

1. 将内容视为用户提供的运行时连接资料，只读取 transport 类型、endpoint 或 command、必要参数及启用状态；
2. 不把配置、token、本机绝对路径或环境变量值写入仓库、skill、PDF、日志摘要或完成报告；
3. 不直接执行配置中的任意 command。先确认它属于预期的 Zotero MCP client configuration，再通过 Codex 原生 MCP 连接流程添加或更新；
4. 如果配置带有 credential，只说明已检测到敏感字段，不在回复中复述；
5. 配置完成后新建或重新加载会话，再从工具暴露检查和只读 library 调用重新验证。

初始化完成时先报告连接诊断状态，再报告每项能力和最终分级。只有状态为 `not-configured` 时，才提示用户安装或添加兼容 MCP；不要因为当前会话缺少工具就推断未安装。不要猜测 endpoint、要求提供 storage 路径，或生成机器专用配置。

未发现兼容 MCP 时，提供推荐仓库 `https://github.com/cookjohn/zotero-mcp` 和 Releases 安装入口，并说明安装 `.xpi`、重启 Zotero、启用集成 server 与写入能力、生成 client configuration、添加到 Codex 后重新运行初始化。已发现配置但连接失败时，提醒检查 Zotero 是否运行、插件 server 是否启用和 Codex 连接是否有效。只能读取时报告“只读”；缺少本地 PDF import 时提醒升级至支持 `write_item import` 的 v1.5.0 或更高版本。

### 无副作用边界

初始化不创建 collection、测试条目、测试附件或 child note，不补建类 Notion Hub，不移动或修改现有内容，也不执行论文阅读。工具 schema 能确认但无法无副作用验证的写入能力，应报告为“已发现、尚未实际验证”，而不是通过污染 library 来测试。

## 论文发现与去重

按以下顺序定位 parent item：

1. 用户给出的 item key；
2. 归一化 DOI；
3. 归一化 arXiv ID；
4. 精确标题 + 年份 + 第一作者；
5. 精确标题。

读取候选的 metadata、attachments、notes 和现有 Research Memo PDFs。多个候选无法消歧时让用户选择；不为了方便新建重复条目。

无条目且用户明确要求入库时，使用权威元数据创建/import bibliographic item，并在能力可用时附加原论文 PDF。

## 生成 PDF 与导入

- PDF 主标题使用论文原始英文标题，副标题使用 `中文 Research Memo`。
- 入库模式的单一 PDF 内容顺序是 `中文 Research Memo` → `中文结构化详译`。
- 使用稳定、论文特定的文件名和附件标题，例如 `<paper short title> | 中文 Research Memo`。
- 导入前检查 parent item 中的现有 memo。同名版本存在且 MCP 不能安全替换时，使用带日期的新附件标题，不删除旧版本。
- 不用 Zotero highlights、annotations、sticky notes、area annotations 或 child note 替代主 PDF。

## Idea Child Notes

只为符合 `research-map-and-ideas.md` 质量门槛的想法创建 `Research Idea | <title>` child note。创建前按归一化标题和来源条目去重。弱想法只保留在 PDF 的 Actionable Ideas 或短 note 中。

## 写入验证

导入后重新读取 parent item，验证：

1. 新 PDF 附件在正确 parent item 下；
2. 附件标题和文件名清楚指向该论文；
3. 原论文 PDF、旧 memo、notes 和用户内容仍然存在；
4. 导入后的 PDF 可打开，页数和文件 hash/大小与本地结果一致；
5. 所有 idea notes 都通过质量门槛。

没有完成回读验证时，不得声称“已写入 Zotero”。
