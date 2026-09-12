# Zotero 论文条目与 Research Record 规范

仅在用户明确要求入库时完整阅读本文件。这里保留原论文库属性的判断标准，只改变存储位置。

## 6. Zotero 论文条目

标准 bibliographic metadata 写入 Zotero parent item；非标准的研究系统字段写入 PDF 开头的紧凑 `Research Record`。可搜索的方法/方向词可以作为 tags 添加，但不替换已有 tags。

| 原字段 | Zotero 存储位置 |
|---|---|
| 标题、作者、年份、Venue、URL、DOI | parent item 标准字段 |
| 研究方向、方法关键词 | 具体 tags + PDF `Research Record` |
| 任务类型、论文类型 | PDF `Research Record` |
| 数据集 / 环境、Project / Code | PDF `Research Record`；官方 URL 可放 parent item `url` / `extra` |
| 阅读状态、阅读优先级、实验价值 | PDF `Research Record`；仅在用户已有 tag 约定时复用 |
| 一句话结论、可复现点 | PDF `Research Record` |

不要用 `extra` 字段塞入整篇 memo，也不用 child note 替代独立 PDF。

### 标题

使用原始英文标题。不用通用标题 `AI Robotics Research Memo | 中文精读` 替换论文标题。

### Author / 作者

保留权威来源中的 creators 顺序。不为了简化而覆盖 Zotero 中更完整的作者列表。

### Year / 年份

有正式发表年份时使用正式年份，否则使用 arXiv 年份。

### Venue

填写会议、期刊或 arXiv。没有正式 venue 时使用 arXiv preprint，不猜测投稿去向。

### URL / DOI / arXiv

优先保留权威的 publisher 或 arXiv abs URL 和 DOI。PDF 中的 Research Record / appendix 同时放 Project / Code / PDF 链接。

### 研究方向

使用具体研究方向，例如 Neuro-Symbolic Planning、TAMP、World Representation、Object-centric Representation、VLA Comparison、Open-Vocabulary Manipulation、Multi-view Representation、Closed-loop Robot Learning。有更精确标签时不只使用宽泛标签。

### 任务类型

这个字段描述真实机器人任务，不是论文类型。例如 Open-vocabulary tabletop manipulation、Long-horizon pick-and-place、Planning from pixels、Bimanual manipulation、Contact-rich manipulation、Mobile manipulation。论文类型单独写 System / Method / Benchmark / Dataset / Survey。

### 方法关键词

使用具体技术关键词，例如 Object-centric 3D State、VLM Grounding、TAMP、Action Chunking、Flow Matching、Diffusion Policy、Multi-view Token Fusion、Camera-aware Positional Encoding、Predicate Learning、Execution Monitor、Belief-space Planning、Ordered Action Tokenization。宽泛标签只能与具体关键词一起使用。

### 数据集 / 环境

填写评估或训练环境，例如 DROID、LIBERO、RoboTwin、Isaac Sim、MuJoCo、Real Robot、Franka、UR5e、Open X-Embodiment。不清楚时写“未明确 / custom setup”。

### Project / Code

使用官方 project page 和 GitHub URL。没找到时写“未找到”或“未开源”，不使用非官方镜像冒充。

### 阅读状态与优先级

完成全部 Research Memo 后记为“已精读”。优先级使用 A 必读 / B 值得读 / C 可略读，并在 Research Record 中给出理由。

- A 必读：和当前 research lens 强相关，可作为 baseline、方法参考或 idea source。
- B 值得读：相关但不是核心，可用于背景、对比或局部方法参考。
- C 可略读：较边缘，主要作为 related work 或一般背景。

### 实验价值

写简洁判断，例如可作 baseline、可作 ablation inspiration、可复现 MVP、可参考 benchmark、工程复现成本高、实验价值有限。

### 一句话结论

用中文写，不复述 abstract。同时说清论文真正证明了什么，以及主要限制是什么。

示例：

> TiPToP 本质是在证明：把 foundation perception 接到显式 object-centric world state 和 GPU TAMP 上，可以零机器人训练数据解决一批 VLA 不稳定的语义、多步 tabletop manipulation，但它仍主要是开环系统，真实瓶颈在 state uncertainty、grasp 和 execution recovery。

### 可复现点

写最小可实施 pipeline、关键 baseline / ablation、必要数据、环境和缺失信息。

示例：

> 最小复现：RGB-D/stereo → object mask/depth/grasp → object-centric 3D state → symbolic goal → planner / motion planner → pick-place trajectory；核心 ablation 是 plan-once vs replan-after-each-action。
