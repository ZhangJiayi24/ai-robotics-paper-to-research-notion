# 来源、视觉证据与 Source Anchors

在开始收集论文来源和视觉材料前完整阅读本文件。这里保留来源优先级、图随文走、project demo 提取和 source anchor 规则。

## 目录

1. 阅读来源
2. 图表使用原则
3. Project Page 和 Demo 提取
4. 引用和 Source Anchors

## 4. 阅读来源

在可用时，按以下顺序阅读和核对来源：

1. **Paper PDF**

   优先使用 arXiv PDF 或用户上传的 PDF。阅读 abstract、introduction、method、experiments、ablation、conclusion。关键 figures、tables、method diagrams、result plots 和 failure cases 必须看原始页面，不能只依赖抽取文本。

2. **Project page**

   查找 teaser、method figure、interactive demo、qualitative results、code link、dataset link、videos 和说明性 caption。项目网页往往比 paper 更直观，尤其适合解释 pipeline 和真实 demo。

3. **GitHub / code page**

   查看 README、安装说明、demo commands、configs、model names、checkpoints、dataset assumptions 和 reproduction notes。只有当代码能澄清方法或复现时才重点使用；不要让代码细节喧宾夺主。

4. **Supplementary / appendix**

   用来确认实验设置、更多 ablation、失败案例、超参数和真实机器人细节。

5. **相关方法名 / baseline**

   只有在理解 baselines、terminology、novelty 或可疑 claim 时才搜索。不要扩展成泛泛 literature review。

如果 project page 和 paper 不一致，要指出差异。如果细节缺失，直接写“论文没有明确说明”或“这里需要进一步看 code / appendix 确认”。不要幻觉补全。

生成中文结构化详译时，以 Paper PDF 为唯一正文基准。Project page、GitHub 和 supplementary 只能补充或核对，不能无标注地混入“论文原文”。遇到公式、变量、表格或 OCR 损坏时，必须回看 PDF 原页。

---

## 5. 图表使用原则：图随文走

不要单独开一个“所有有用的图”列表来堆图。

### 5.1 视觉材料来源优先级

按以下优先级寻找和使用视觉材料：

1. **并列第一优先级：paper 原文与 project webpage 的原始视觉材料。** Paper 中优先使用原文图、表、method diagram、result plot、ablation、qualitative result 和 failure figure；project webpage 中优先使用 teaser、demo sequence、method figure、qualitative result、真实机器人视频帧或 GIF。两者同等重要，应根据解释目标选择信息最清晰、证据最直接的版本；如果二者表达不同或存在冲突，必须说明差异。
2. **第二优先级：官方 GitHub / README / documentation 的视觉材料。** 仅在它能补充实现、复现、模型结构或 demo 细节时使用。
3. **第三优先级：自绘或生成图。** 只有在 paper、project webpage 和官方代码资料中没有适合的图，或确实需要整合多个来源的信息时才使用。必须明确标注“自绘/生成示意图，非论文原图”，不得模仿成论文原始 figure。

不要因为原始图需要截图、裁切、定位或从网页 demo 中选帧，就直接跳到自绘图。先完成 paper 与 project webpage 的视觉材料检索，再决定是否需要生成图。

选定图后只获取这些素材，不批量下载整个 project page 或提取论文里的每一张图。质量顺序是：

1. 原始 SVG、矢量 PDF 或官方仓库中的矢量资产；
2. project page / README 的最大 `srcset` 或原始栅格图；
3. 从 PDF 直接提取的嵌入图像；
4. 直接对目标区域做矢量保真的 PDF/SVG 裁取；
5. 只在上述方法不可靠时，对目标区域做紧裁的 400–600 DPI RGB 栅格裁取。

原始 SVG 和透明 PNG 可以继续作为高质量输入。矢量 PDF 如果包含 `smask` / `mask`，不要先转成 SVG；这条转换路径可能把 PDF transparency group 拆成错误的重叠图层。只将目标图以 400–600 DPI 渲染为保留 alpha 的 RGBA PNG，再交给 WeasyPrint。不要铺白底、清除 alpha、栅格化整页或栅格化整份 memo。

不默认先以低/中 DPI 渲染整页 PDF，再放大其中一小块。不对低分辨率裁图伪上采样。表格优先使用矢量裁取或核对数值后重排的 HTML table；重排时标注 `根据 Paper Table X 重排`。

默认覆盖数量：普通论文使用 2–4 个关键视觉材料；中心论文至少 3 个；robotics system、demo-rich project 或视觉证据较多的论文通常使用 4–8 个。数量不是硬凑图指标，但少于 2 个时，必须在完成汇报中说明原因，例如原文确实无可用图、用户提供的是无图转存 PDF、项目页不可访问或图片无法可靠提取。

### 5.2 图随文走

图要放在它最能帮助理解的地方：

- 方法总览图放在 **Method Story** 里；
- 模型结构图放在讲 encoder / decoder / planner / policy 的段落里；
- action representation 图放在讲 action 的段落里；
- 训练目标图放在讲 loss / objective 的段落里；
- 结果表放在 **Evidence** 里；
- ablation 图放在解释“为什么不是玄学”的段落里；
- failure 图放在 **Failure & Hidden Assumptions** 里；
- self-made research mapping diagram 放在 research map 或 research connection 里。

每一张图都必须承担解释功能。使用图时要写清楚：

- 这张图在论文论证链条里负责什么；
- 它对应哪个 claim；
- 读图时先看哪里；
- 它和 method / experiment / limitation 的关系；
- 它是否真的支持作者想证明的东西。

推荐图块格式：

```markdown
> 图：Paper Fig. X / Project Page / GitHub README / 自绘示意图，非论文原图
>
> 这张图要看的是……它支持的核心 claim 是……但它还不能证明……
```

避免：

- 复制很多低价值图片；
- 只贴图不解释；
- 只写“如图所示”；
- 生成假的论文风格图；
- 用自绘图但不标注“自绘示意图，非论文原图”。

可以使用的图包括：teaser / overview figure、method / pipeline figure、core mechanism figure、qualitative result figure、main result table、ablation plot、real robot setup、failure case、project page demo sequence、自绘 pipeline schematic、自绘 research mapping diagram。

### 5.3 临时文件

- 优先就地读取 Zotero 中的原论文 PDF，不为提图再保存一份永久副本。
- 下载、裁取、SVG/PDF 中间件、栅格 fallback、HTML builder、页面渲染和 contact sheet 都放进 task-scoped 临时目录。
- 只保留到最终 PDF 已生成、完整视觉检查、通过 Zotero MCP 导入且导入副本已验证。
- 随后删除临时资产和 builder；默认只将最终 Research Memo PDF 作为持久本地产物，除非用户明确要求保留可编辑源文件。

---

---

## 10. Project Page 和 Demo 提取策略

对于 project page，提取：

- demo tasks；
- method diagrams；
- robot setup photos；
- result visuals；
- failure cases；
- visible video sequences；
- model overview diagrams；
- code / release information。

对于 demo video：

- 总结 demo 证明了什么；
- 标注它是否可能 cherry-picked；
- 标注是否展示 failures；
- 如果可推断，标注执行是 open-loop 还是 closed-loop。

对于私人研究笔记，优先嵌入 paper / project webpage 的原始视觉材料，并标注来源和 source anchor。license 检查不作为本工作流的阻塞步骤；如果用户准备公开发布或再分发，应提醒用户自行确认相应使用权限，但不要因此用自绘图替代本可用于研究笔记的原始图。

---

---

## 12. 引用和 Source Anchors

重要事实 claim 必须包含 source anchors。

使用人类可读的 source anchors，例如：

- Paper Fig. 1
- Paper Fig. 2
- Paper Table I
- Paper Appendix A
- Project Page Demo
- GitHub README
- arXiv Abstract

如果知道准确页码或图号，就写出来。

示例：

```markdown
Source: Paper Fig. 2
Source: Project Page demo sequence
Source: GitHub README installation section
```

区分作者 claim 和个人判断。需要时使用：

> 作者结论：

或：

> 我的判断：

---
