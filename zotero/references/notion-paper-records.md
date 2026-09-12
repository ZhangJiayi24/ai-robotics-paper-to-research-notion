# Notion 论文条目规范

仅在用户明确要求入库时完整阅读本文件。这里保留论文库属性、字段内容与去重后的条目写法；工作区发现和 schema 初始化另见 `notion-workspace-setup.md`。

## 6. 论文库条目

当用户明确要求入库时，在 AI Robotics 论文库中创建或更新论文条目。

如果已经存在同标题条目，则更新该条目，不要创建重复项。

### 6.1 必填属性

如果数据库里有对应属性，就填写。

### 标题

使用原始英文标题。

### Author / 作者

填写主要作者。作者很多时，除非数据库要求全量作者，否则列出前 3–5 位 + et al.。

### Year / 年份

有正式发表年份时使用正式年份，否则使用 arXiv 年份。

### Venue

填写会议、期刊或 arXiv。例如：arXiv 2026、ICRA 2025、CoRL 2024、RSS 2025、RA-L 2026。没有正式 venue 时使用 arXiv preprint。

### URL

优先使用 arXiv abs 页面或 project page。正文中同时包含 PDF / Project / Code 链接。

### 研究方向

使用具体研究方向标签，例如：Neuro-Symbolic Planning、TAMP、Modular Robot Manipulation、World Representation、Object-centric Representation、VLA Comparison、Embodied AI、Robot Learning、Open-Vocabulary Manipulation、Multi-view Representation、Closed-loop Robot Learning。

如果有更精确标签，不要只使用宽泛标签。

### 任务类型

这个字段描述真实机器人任务，而不是论文类型。

好的示例：Open-vocabulary tabletop manipulation、Semantic object rearrangement、Long-horizon pick-and-place、Planning from pixels、Bimanual manipulation、Contact-rich manipulation、Dexterous manipulation、Mobile manipulation、Navigation、Imitation learning benchmark。

不要把 “System” 放进任务类型，除非没有更合适字段且用户明确要求。如果论文类型重要，应写到单独字段：System / Method / Benchmark / Dataset / Survey。

### 方法关键词

使用具体技术关键词，例如：Object-centric 3D State、VLM Grounding、TAMP、cuTAMP、cuRobo、FoundationStereo、SAM-2、M2T2、Open-loop Execution、Action Chunking、Flow Matching、Diffusion Policy、Multi-view Token Fusion、Camera-aware Positional Encoding、Predicate Learning、Execution Monitor、Belief-space Planning、Ordered Action Tokenization、Coarse-to-fine Action Representation、Prefix-decodable Policy。

避免只写 Control、Planning、Perception、Foundation Model 这种宽泛标签。宽泛标签只能和具体关键词一起使用。

### 数据集 / 环境

填写评估或训练环境，例如：DROID、LIBERO、RoboTwin、Isaac Sim、MuJoCo、Real Robot、Franka、UR5e、WidowX、Open X-Embodiment、Custom tabletop setup。不清楚时写“未明确 / custom setup”。

### 代码链接

使用 GitHub 或官方代码 URL。没找到时写“未找到”或“未开源”。

### 阅读状态

如果已经写了完整 research memo，使用数据库已有选项，如“已整理”或“已精读”。

### 阅读优先级

使用 A 必读 / B 值得读 / C 可略读，或数据库已有选项。

A 必读：和当前 research lens 强相关，可作为 baseline、方法参考或 idea source。

B 值得读：相关但不是核心，可用于背景、对比或局部方法参考。

C 可略读：较边缘，主要作为 related work 或一般背景。

### 实验价值

写简洁判断，例如：可作 baseline、可作 ablation inspiration、可复现 MVP、可参考 benchmark、主要作 related work、工程复现成本高、实验价值有限。

### 一句话结论

用中文写，不要复述 abstract。说清楚这篇论文真正证明了什么，以及主要限制是什么。

示例：

> TiPToP 本质是在证明：把 foundation perception 接到显式 object-centric world state 和 GPU TAMP 上，可以零机器人训练数据解决一批 VLA 不稳定的语义、多步 tabletop manipulation，但它仍主要是开环系统，真实瓶颈在 state uncertainty、grasp 和 execution recovery。

### 可复现点

写简洁、实用的复现要点。

示例：

> 最小复现：RGB-D/stereo → object mask/depth/grasp → object-centric 3D state → symbolic goal → planner / motion planner → pick-place trajectory；核心 ablation 是 plan-once vs replan-after-each-action。

---
