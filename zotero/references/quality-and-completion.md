# 质量检查与完成汇报

完成任何 paper memo 前完整阅读本文件；Zotero 入库任务还需执行其中的 PDF 与写入验证要求。

## 14. 质量检查清单

最终完成任何 paper memo 前，检查：

- 如果是 paper2zotero / 精读入库 / 明确翻译任务，是否已阅读并执行 `references/chinese-structured-translation.md`？
- 是否按顺序提供了“中文 Research Memo → 中文结构化详译”，而不是把两者混成一层？
- 详译是否覆盖原文 Abstract、Introduction、Method、Experiments、Limitations / Conclusion 和关键 Appendix？
- 详译是否保持原文章节编号，并保留重要图号、表号、公式、数字、单位和限定词？
- 作者 claim、项目页/代码页补充、译者注和个人判断是否清楚分开？
- PDF 抽取损坏的公式、变量或表格是否回看了原页，而不是输出残缺文本？
- 是否先讲清楚了问题，而不是直接讲方法？
- 是否先检索并优先使用了 paper 原文与 project webpage 的原始视觉材料？
- Method Story 是否至少有一张方法、系统或核心机制图；若原文确实没有，是否明确说明？
- Evidence 是否优先使用了结果表、result plot、ablation、qualitative result 或真实 demo sequence？
- 如果存在 failure figure / failure table，是否放进了 Failure & Hidden Assumptions？
- 图是否嵌入到对应讲解段落，而不是单独堆图？
- 是否解释了核心图，而不是把图当装饰？
- 每张图是否标注了来源、source anchor、对应 claim，以及它能证明和不能证明什么？
- 是否只在原始来源缺少合适视觉材料或需要跨来源整合时才使用自绘/生成图，并明确标注“非论文原图”？
- 如果关键视觉材料少于 2 个，是否在完成汇报中说明具体原因？
- 是否讲清楚输入、输出、observation、state、action、policy / planner / controller？
- 是否解释了 baseline 为什么不够？
- 是否给出了主要实验趋势，而不是堆数字？
- 是否说明了 ablation 到底证明了什么？
- 是否区分了作者 claim 和自己的判断？
- 是否指出了具体局限，而不是泛泛而谈？
- 是否和当前 research lens 建立了必要但不牵强的连接？
- 是否只在必要时建议更新 mindmap？
- 是否避免了 PDF 开头重复 Zotero 标准 bibliographic metadata？
- 是否中文为主，英文只保留必要技术词？
- 是否能让用户读完后记住“大论点”和“关键词”，而不是只记住一堆细节？
- 入库模式是否将 `中文 Research Memo → 中文结构化详译` 生成同一个独立 PDF？
- `pdfinfo` 是否确认 PDF 有效、A4 尺寸和预期页数？
- `pdffonts` 是否确认 regular / bold CJK 字体已嵌入，且没有 Type 3 字体？
- `pdfimages -list` 是否用于追踪透明图来源，而不是把合法 `smask` 一律当成错误？
- `pdftotext` 是否确认公式可读，没有 Unicode 上下标乱码？
- 是否将最终 PDF 的每一页渲染为临时 PNG 并检查 contact sheet，再以原尺寸检查公式、密集表格、粗体标题和图片页？
- 含 `smask` / `mask` 的矢量 PDF 是否避开 PDF→SVG 路径，并只将目标图转换为紧裁 400–600 DPI RGBA PNG、保留 alpha？
- 透明图是否同时通过 Poppler 全页渲染和当前 Zotero/PDF.js 实际显示检查，没有黑底、黑边或错误背景合成？
- Zotero 导入后是否重新读取 parent item，确认新附件、原论文 PDF、旧 memo 和用户 notes 都正确？

---

## 15. 默认完成汇报

工作流完成后，面向用户的回复保持简洁。

如果只是聊天精读，说明已经整理了中文笔记，并简要说明覆盖了哪些重点。

如果写入 Zotero，报告：

1. Zotero parent item 是创建还是复用，并报告 item key；
2. 是否生成并导入包含中文 Research Memo 的独立 PDF，并报告 attachment key 和页数；
3. PDF 内是否追加中文结构化详译，以及覆盖到哪些正文和附录章节；
4. 哪些关键图被嵌入到了哪些段落；
5. 是否创建通过质量门槛的 `Research Idea | ...` child notes；
6. 是否建议更新 research map；
7. 哪些来源缺失或细节不确定；
8. 是否优先使用了 paper / project webpage 原始视觉材料；若少于 2 个或未使用原始图，具体原因是什么；
9. 导入后是否回读验证，原 PDF 和已有附件是否保留。

示例：

```text
已复用 Zotero 论文 parent item，并导入包含中文 Research Memo 与按论文原文章节组织的中文结构化详译的独立 PDF。详译覆盖摘要、引言、方法、实验、讨论/局限和与复现相关的关键附录；作者内容与个人判断保持分离。PDF 没有重复 Zotero 标准 metadata，图没有单独堆成清单，而是放进 Method Story / Evidence / Failure 和详译对应章节里。

这次嵌入了 5 个关键视觉材料：
1. Paper Fig. 1 teaser：放在问题设定里
2. Paper Fig. 2 system overview：放在 Method Story 里
3. Paper Fig. 3 perception module：放在 perception-to-planning 讲解里
4. Project page failure demo：放在 Failure & Hidden Assumptions 里
5. 自绘 closed-loop extension schematic：放在 Research Map Check 里

Zotero 新增 1 条 idea child note：Research Idea | Closed-loop TiPToP with Predicate Effect Monitor。
Research Map 建议小更新：在 Current Research Lens / Planning 下加入 Perception-to-Planning Interface。
```
