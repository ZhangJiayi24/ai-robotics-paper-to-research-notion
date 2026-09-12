---
name: ai-robotics-paper-to-research-notion
description: >
  当用户让你读一篇 AI Robotics / Embodied AI / Robot Learning 论文时使用这个 skill。
  用户可以只说“读一下这篇文章”“讲一下这篇论文”“精读一下这个 paper”，也可以要求中文翻译、全文详译、按原文章节翻译或标注自己关注的问题。
  这个工作流会读取论文 PDF、项目网页、代码页和相关来源，产出带图、有研究判断的中文 Research Memo；对于“入库 / 写入 Notion / paper2notion / 精读入库”，还默认追加与原文章节对齐的中文结构化详译，并同步创建或更新 Notion 论文库、想法库和 research map 建议。
---

# AI Robotics 论文精读与 Research Notion Skill

## 0. 核心原则

这个 skill 不是通用论文总结模板，也不是只翻译 abstract 的翻译器。目标是把一篇 AI Robotics / Embodied AI / Robot Learning 论文读成真正有用的中文研究笔记，并在用户要求时沉淀到 Notion / 研究日志 / research map 中。

一篇合格笔记应该产出：

1. 论文真正解决的问题；
2. 方法从输入到输出的完整故事；
3. 随文嵌入的关键图、表、demo 和 source anchors；
4. 实验结果到底支持了什么、不支持什么；
5. 具体 failure、hidden assumptions 和局限；
6. 和用户当前研究兴趣的连接；
7. 是否值得更新 research map / mindmap；
8. 对精读入库任务，提供与原文结构对齐、可回查的中文结构化详译；
9. 如果用户要求入库，则创建或更新 Notion 论文库条目和少量高质量想法。

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
- 论文入库 / paper2notion / 写入 Notion / 精读入库；
- 中文翻译 / 全文详译 / 按原文章节翻译。

推荐日常短指令是 `paper2notion`：

- `paper2notion <论文 URL>`：默认执行精读、结构化详译并入库；
- `paper2notion 只精读不入库：<论文 URL>`：只产出中文 Research Memo；
- `paper2notion 初始化`：初始化或补齐 Notion 研究 Hub；
- `paper2notion 当前版本`：只返回版本 label。

完整的 `$ai-robotics-paper-to-research-notion` 是显式调用形式，语义与上述短指令相同。

用户可能只给 arXiv、PDF、project page 或 GitHub URL。自动寻找缺失来源，不要求用户补齐。用户如果标注“我关注的问题”，优先围绕这些问题读；否则使用动态 research lens。

模式选择：

- **普通精读**：产出中文 Research Memo；除非用户要求翻译，不展开全文级详译，也不写 Notion。
- **明确翻译**：产出 Research Memo，并追加中文结构化详译；不自动写 Notion。
- **入库 / paper2notion**：产出 Research Memo，再追加中文结构化详译，然后创建或更新 Notion 论文条目和必要的高质量 ideas。
- **Notion 初始化**：只初始化或补齐研究 Hub，不运行论文阅读流程。
- **版本查询**：只输出版本，不运行其他流程。

不要把聊天解释、中文详译和 Notion 入库写成互不相干的流程；它们共用同一套来源核查与阅读逻辑，但保持作者内容与个人判断的边界。

### 1.1 版本查询

当前版本 label：`paper2notion-cn-v1.2.0`。

当用户明确询问 paper2notion 当前版本时，只输出：

```text
paper2notion-cn-v1.2.0
```

### 1.2 Notion 初始化

当用户明确说“初始化 AI Robotics Research Hub”“创建 paper2notion 工作区”或“复建研究库”时，完整阅读 [Notion 工作区初始化与发现规范](references/notion-workspace-setup.md)，然后创建或复用 Hub、论文库、想法库、Current Research Lens 和 Research Map。

初始化是显式外部写入。没有用户的初始化指令时，不要因为找不到 Hub 就自行创建整套工作区。

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

### 2.5 Notion 入库

仅当用户明确要求入库时执行外部写入。先完整阅读：

1. [Notion 工作区初始化与发现规范](references/notion-workspace-setup.md)：Hub 发现、schema、去重和页面写入；
2. [Notion 论文条目规范](references/notion-paper-records.md)：论文属性和字段内容。

如果找到多个同名 Hub，让用户选择，不要猜测。若没有 Hub：初始化任务按规范创建；普通入库任务提示用户先初始化，不静默创建整套工作区。

已有同一论文条目时更新，不创建重复项。正文顺序固定为 `中文 Research Memo` → `中文结构化详译`，且不重复数据库 metadata。只把达到 Actionable Ideas 标准的想法写入想法库。

### 2.6 完成前检查

完成任何 paper memo 前，完整阅读并执行 [质量检查与完成汇报](references/quality-and-completion.md)。不要为了满足清单而制造内容；检查的目标是发现会改变结论、可回查性或 Notion 写入结果的遗漏。

## 3. 全流程不变量

- 先核清问题、输入和输出，再讲方法。
- 不幻觉补全缺失细节；直接写“论文没有明确说明”或指出需要看 code / appendix。
- Paper 与 project page 不一致时明确指出差异。
- 图必须服务解释并放在对应段落；不单独堆“关键图表总表”。
- 重要事实使用人类可读 source anchors，例如 `Paper Fig. 2`、`Paper Table I`、`Appendix A`、`Project Page Demo`、`GitHub README`。
- 明确区分作者结论与个人判断。
- 结论既说明论文证明了什么，也说明没有证明什么。
- Research Memo 负责研究判断；中文结构化详译负责忠实覆盖，两层不能混写。
- 不自动覆盖现有 mindmap，不为低质量或一次性想法污染 idea database。
- 没有明确入库或初始化指令时，不写 Notion。

## 4. Notion 目标 Hub

默认目标名称是 `AI Robotics Research Hub`。不要依赖作者个人工作区的页面 ID、数据库 ID 或绝对 URL。

定位顺序：

1. 用户本轮明确提供的 Hub URL；
2. 当前 Notion 工作区中标题精确匹配的 Hub；
3. 用户已经存在且明确指定的同类研究 Hub。

优先使用 Hub 内的 `AI Robotics 论文库` 和 `AI Robotics 想法库`；如果可用，也读取 `Current Research Lens`、`Research Map / Mindmap` 和近期 ideas。只有显式初始化任务可以补建缺失的 Hub 组件。
