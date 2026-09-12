---
name: ai-robotics-paper-to-research-zotero
description: >
  当用户让你读一篇 AI Robotics / Embodied AI / Robot Learning 论文时使用这个 skill。
  用户可以只说“读一下这篇文章”“讲一下这篇论文”“精读一下这个 paper”，也可以要求中文翻译、全文详译、按原文章节翻译或标注自己关注的问题。
  这个工作流会读取论文 PDF、项目网页、代码页和相关来源，产出带图、有研究判断的中文 Research Memo；对于“入库 / 写入 Zotero / paper2zotero / 精读入库”，还默认追加与原文章节对齐的中文结构化详译，并将完整内容生成独立 PDF，通过 Zotero MCP 附加到论文条目。
---

# AI Robotics 论文精读与 Research Zotero Skill

## 0. 核心原则

这个 skill 不是通用论文总结模板，也不是只翻译 abstract 的翻译器。目标是把一篇 AI Robotics / Embodied AI / Robot Learning 论文读成真正有用的中文研究笔记，并在用户要求时沉淀到 Zotero / 研究日志 / research map 中。

一篇合格笔记应该产出：

1. 论文真正解决的问题；
2. 方法从输入到输出的完整故事；
3. 随文嵌入的关键图、表、demo 和 source anchors；
4. 实验结果到底支持了什么、不支持什么；
5. 具体 failure、hidden assumptions 和局限；
6. 和用户当前研究兴趣的连接；
7. 是否值得更新 research map / mindmap；
8. 对精读入库任务，提供与原文结构对齐、可回查的中文结构化详译；
9. 如果用户要求入库，则创建或更新 Zotero 论文条目、导入独立 Research Memo PDF，并仅为高质量想法创建 child notes。

输出分为两个职责明确的内容层：

1. **Research Memo**：负责解释、归纳、批判与研究连接；
2. **中文结构化详译**：按原文章节忠实转述，负责覆盖论文内容和便于回查，不混入未经标注的个人判断。

避免把内容拆成很多碎片小点。优先写完整论证、高层 claim、关键 intuition 和研究判断。主要语言必须是中文；英文只保留必要技术词。

## 1. 触发与模式

只要用户让你读一篇相关论文，就运行这个工作流，不需要固定暗号。典型触发包括：

- 读一下 / 讲一下 / 精读这篇论文；
- 带着图讲、搜索文章和项目网页；
- 整理成论文笔记；
- 分析 pipeline / backbone / action / VLA / world model / neuro-symbolic；
- 检查能否更新 mindmap；
- 论文入库 / paper2zotero / 写入 Zotero / 精读入库；
- 中文翻译 / 全文详译 / 按原文章节翻译。

推荐日常短指令是 `paper2zotero`：

- `paper2zotero <论文 URL>`：默认执行精读、结构化详译、生成 PDF 并入库；
- `paper2zotero 只精读不入库：<论文 URL>`：只产出中文 Research Memo，不写 Zotero；
- `paper2zotero 初始化`：发现当前可用的 Zotero MCP，适配实际工具 schema，并检查 library 读取、论文附件读取、PDF 导入和回读能力；
- `paper2zotero 当前版本`：只返回版本 label。

完整的 `$ai-robotics-paper-to-research-zotero` 是显式调用形式，语义与上述短指令相同。

用户可能只给 arXiv、PDF、project page 或 GitHub URL。自动寻找缺失来源，不要求用户补齐。用户如果标注“我关注的问题”，优先围绕这些问题读；否则使用动态 research lens。

模式选择：

- **普通精读**：产出中文 Research Memo；除非用户要求翻译，不展开全文级详译，也不写 Zotero。
- **明确翻译**：产出 Research Memo，并追加中文结构化详译；不自动写 Zotero。
- **入库 / paper2zotero**：产出 Research Memo，再追加中文结构化详译，将两层内容生成一个独立 PDF，然后通过 Zotero MCP 创建或更新论文条目、导入 PDF 和必要的高质量 idea child notes。
- **Zotero 初始化**：发现并验证当前 Codex 环境中的 Zotero MCP，建立本次运行所需的能力映射；不创建 collection、测试条目或测试附件，不运行论文阅读流程。
- **版本查询**：只输出版本，不运行其他流程。

不要把聊天解释、中文详译和 Zotero 入库写成互不相干的流程；它们共用同一套来源核查与阅读逻辑，但保持作者内容与个人判断的边界。

### 1.1 版本查询

当前版本 label：`paper2zotero-cn-v1.2.2`。

当用户明确询问 paper2zotero 当前版本时，只输出：

```text
paper2zotero-cn-v1.2.2
```

### 1.2 Zotero 初始化

当用户明确说“初始化 paper2zotero”“检查 Zotero MCP”或“复建研究库连接”时，完整阅读 [Zotero 连接、条目发现与写入规范](references/zotero-workspace-setup.md)、[Zotero MCP Adapter](references/zotero-mcp-adapter.md) 和 [PDF Renderer 初始化与选择](references/pdf-renderer-setup.md)。先发现和验证 Zotero MCP；通过后再让用户在 WeasyPrint（推荐、视觉效果更稳定）、Codex PDF skill 和 Auto 之间选择。

初始化不得依赖仓库中的固定 endpoint、端口、library ID、item key、token 或本地 storage 路径，也不得要求用户把这些机器专用信息写入 skill。连接信息由 Codex 的 MCP 管理机制维护；运行时只使用 MCP 返回的稳定标识和附件信息。

初始化默认走无副作用的快路径：若当前会话已暴露 Zotero 工具，先用一次 library 读取确认连接，再读取工具 schema、执行一次最小条目搜索并检查 PDF renderer 环境；成功后不再运行 endpoint/沙箱诊断。论文 PDF 全文读取、实际 PDF 导入、导入后回读以及完整渲染样张均延迟到第一次真正精读、入库或 renderer 变更时验证。初始化只按 schema 报告这些能力为“已发现、延迟验证”，不得为了验证而创建测试内容。

若未发现兼容的 Zotero MCP，停止初始化并明确说明需要先在 Codex 中连接兼容实现；不要猜测连接地址或生成机器专用配置。若只能读取不能导入，报告“只读”，不得声称已完成入库配置。

“当前会话没有 Zotero 工具”不等于“MCP 未安装”。必须按 `zotero-workspace-setup.md` 的分层诊断区分：未配置、已配置但未暴露给当前会话、沙箱阻断、服务不可达和工具已暴露但调用失败。只有确认没有兼容配置后才能提示安装；诊断尚未完成时使用“未暴露”或“可达性未验证”，不得误报为“未安装”。

只有当前会话没有暴露 Zotero 工具，或首次只读 library 调用失败时，才运行 `scripts/zotero-mcp-diagnose.sh`，并把工具暴露状态通过 `PAPER2ZOTERO_MCP_TOOLS_EXPOSED=yes|no|unknown` 传入。不得仅凭一次沙箱内网络失败输出“Zotero MCP 服务没有启动”；出现 `sandbox-retry-required` 时必须请求授权，在授权环境重跑同一只读诊断。只有授权环境仍不可达，且没有本机监听证据时，才能报告服务不可达。

当前任务没有原生 Zotero 工具包装时，不得停止在 `configured-not-exposed`。若已注册 endpoint 返回 `mcp-endpoint-available`，使用 `scripts/zotero-mcp-client.sh list-tools` 读取实际 schema，并通过 `scripts/zotero-mcp-client.sh call <tool> '<json>'` 继续标准 MCP 调用；该路径仍是 Zotero MCP，不是直接读取数据库。只有 MCP 握手或 `tools/list` 本身失败时，才判定当前任务无法使用。

Zotero transport 的安全优先级固定为：原生 MCP 工具优先；原生工具未注入时，只有在 Codex 的 MCP 注册信息、本机 endpoint、MCP 握手与用户授权均已确认后，才允许使用标准 MCP HTTP transport。不得把 HTTP transport 一律禁止，也不得把它降级描述为非 MCP 直连。HTTP fallback 的写入必须来自用户本轮明确的 Zotero 写入意图；每次写入都要记录返回的稳定 key，并强制通过 MCP 回读 parent item 或 children。无法回读时不得声称写入成功。

如果诊断返回 `registry-unavailable`、`registry-unreadable` 或 `not-configured`，先请用户打开 Zotero 的 MCP 设置页，复制其中为 MCP client 准备的 configuration。该配置只用于本次连接诊断和 Codex 原生 MCP 配置流程；不得写入仓库、skill 文件、论文笔记或初始化报告，也不得回显 token 等敏感字段。拿到配置后先核对 transport、endpoint/command 和启用状态，再判断是否需要添加或重新加载 Codex 连接。

## 2. 渐进式工作流

按任务阶段读取对应 reference，不要预先加载与当前模式无关的文件。

### 2.1 来源与视觉证据

开始收集论文来源和图片前，完整阅读 [来源、视觉证据与 Source Anchors](references/source-and-visual-evidence.md)。它规定 PDF / project page / GitHub / supplementary 的核查顺序、图随文走、demo 提取和 source anchors。

关键 figures、tables、method diagrams、result plots 和 failure cases 必须看原始页面，不能只依赖抽取文本。Project page、GitHub 和 supplementary 可以补充或核对，但中文结构化详译始终以 Paper PDF 为唯一正文基准。

### 2.2 动态 Research Lens、Research Map 与 Ideas

所有 paper 任务都必须完整阅读 [Research Lens、Research Map 与 Actionable Ideas](references/research-map-and-ideas.md)，再连接用户当前研究兴趣、进行 Research Map Check 或形成 ideas。

每篇论文都要做轻量级 Research Map Check，但不要自动覆盖用户 mindmap。Research lens 来自当前 prompt 和可用的近期研究上下文，不要永久硬编码。

### 2.3 Research Memo

撰写论文精读笔记前，完整阅读 [中文 Research Memo 写作规范](references/research-memo-writing.md)。它保留正文结构，以及 Main Thesis、Method Story、Evidence、Failure & Hidden Assumptions、Quick Recall 和写作风格的全部要求。

始终先讲问题，再讲方法。对于 robotics papers，必须覆盖 observation representation、state / world representation、action representation、policy / planner / controller、training 或 inference-time optimization、open-loop vs closed-loop、embodiment assumptions 和 failure modes。

### 2.4 中文结构化详译

对入库任务或用户明确要求翻译的任务，在 Research Memo 后追加中文结构化详译。开始写详译前，完整阅读 [中文结构化详译规范](references/chinese-structured-translation.md)。

实际标题、编号和层级必须跟随原文。保留重要图号、表号、公式、数字、单位、实验协议和限定词；作者 claim、项目页补充、译者注和个人判断必须清楚分开。不要把详译写成第二份 Research Memo。

### 2.5 Zotero PDF 入库

仅当用户明确要求入库时执行外部写入。先完整阅读：

1. [Zotero 连接、条目发现与写入规范](references/zotero-workspace-setup.md)：library 发现、去重、PDF 导入和回读验证；
2. [Zotero 论文条目与 Research Record 规范](references/zotero-paper-records.md)：论文 metadata、tags 和 PDF 内字段映射；
3. [Zotero MCP Adapter](references/zotero-mcp-adapter.md)：按实际工具 schema 适配读写能力。

如果检索到多个可能的论文 parent item，让用户选择，不要猜测。没有条目且用户明确要求入库时，才使用可用的 Zotero MCP 能力创建或导入 bibliographic item 与原论文 PDF。

已有同一论文条目时复用，不创建重复项。生成的独立 PDF 顺序固定为 `中文 Research Memo` → `中文结构化详译`，且不重复标准 bibliographic metadata。该 PDF 是主输出；不使用 Zotero PDF 批注、高亮、粘滞便签或 child note 替代。只把达到 Actionable Ideas 标准的想法写成 `Research Idea | <title>` child notes。

### 2.6 完成前检查

完成任何 paper memo 前，完整阅读并执行 [质量检查与完成汇报](references/quality-and-completion.md)。不要为了满足清单而制造内容；检查的目标是发现会改变结论、可回查性或 Zotero 写入结果的遗漏。

## 3. 全流程不变量

- 先核清问题、输入和输出，再讲方法。
- 不幻觉补全缺失细节；直接写“论文没有明确说明”或指出需要看 code / appendix。
- Paper 与 project page 不一致时明确指出差异。
- 图必须服务解释并放在对应段落；不单独堆“关键图表总表”。
- 重要事实使用人类可读 source anchors，例如 `Paper Fig. 2`、`Paper Table I`、`Appendix A`、`Project Page Demo`、`GitHub README`。
- 明确区分作者结论与个人判断。
- 结论既说明论文证明了什么，也说明没有证明什么。
- Research Memo 负责研究判断；中文结构化详译负责忠实覆盖，两层不能混写。
- 不自动覆盖现有 mindmap，不为低质量或一次性想法污染 Zotero notes。
- 没有明确入库指令时，不写 Zotero。
- 原论文 PDF 是证据输入；生成的 Research Memo PDF 是独立附件，不覆盖原 PDF 或现有用户内容。

## 4. Zotero 目标 Library

默认使用当前 Zotero 用户 library。不要依赖写死的 library ID、collection key、item key 或本地 storage 路径。

定位顺序：

1. 用户本轮明确提供的 Zotero item / attachment key 或条目信息；
2. 归一化 DOI 或 arXiv ID 精确匹配的条目；
3. 标题、年份和第一作者匹配的条目。

优先复用已有 bibliographic parent item 及其原论文 PDF。如果可用，从近期高优先级论文、tags、Research Memo PDFs 和 idea child notes 推断动态 Research Lens。不为此强制创建 collection 或改造 Zotero 组织结构。
