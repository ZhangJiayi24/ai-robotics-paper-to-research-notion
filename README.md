# AI Robotics Paper to Research

一套给 Codex 使用的 AI Robotics / Embodied AI / Robot Learning 论文精读工作流。它会综合论文 PDF、project page、GitHub 与关键视觉证据，生成带图、有研究判断的中文 Research Memo；在用户明确要求入库时，还会追加与原文章节对齐的中文结构化详译，并写入 Notion 或 Zotero。

## 选择后端

| 后端 | 日常指令 | 入库形式 | 适合场景 |
| --- | --- | --- | --- |
| Notion | `paper2notion` | 论文库条目、正文、Ideas、Research Map | 构建可检索、可连接的研究知识库 |
| Zotero | `paper2zotero` | 论文 parent item、独立 Research Memo PDF、少量 idea child notes | 以文献管理器和 PDF 为中心管理阅读成果 |

两个后端共享相同的论文阅读、来源核查、视觉证据、Research Memo 和中文结构化详译标准，只在最终持久化方式上不同。Notion 与 Zotero 是两个独立 skill，可以单独安装，也可以同时安装。

## 安装

前提：已经安装 Codex。默认安装 Notion 版，保持原有安装行为不变。

### Notion

```bash
curl -fsSL https://raw.githubusercontent.com/ZhangJiayi24/ai-robotics-paper-to-research-notion/main/install.sh | bash
```

### Zotero

```bash
curl -fsSL https://raw.githubusercontent.com/ZhangJiayi24/ai-robotics-paper-to-research-notion/main/install.sh | bash -s -- zotero
```

### 同时安装

```bash
curl -fsSL https://raw.githubusercontent.com/ZhangJiayi24/ai-robotics-paper-to-research-notion/main/install.sh | bash -s -- all
```

也可以 clone 后本地安装：

```bash
git clone https://github.com/ZhangJiayi24/ai-robotics-paper-to-research-notion.git
cd ai-robotics-paper-to-research-notion
bash install.sh notion   # 或 zotero / all
```

skill 默认安装到 `~/.agents/skills`。重复执行相同命令即可升级；如果 Codex 没有发现更新，重启 Codex。

官方说明：[Codex Skills](https://developers.openai.com/codex/skills) · [Codex Plugins](https://developers.openai.com/codex/plugins)

## Notion 后端

前提：在 Codex 中安装、连接并授权 Notion 插件。

首次使用时发送：

```text
paper2notion 初始化
```

Codex 会在当前 Notion 工作区创建或复用：

- `AI Robotics Research Hub`
- `AI Robotics 论文库`
- `AI Robotics 想法库`
- `Current Research Lens`
- `Research Map`

初始化属于 Notion 外部写入，只有在用户明确发送初始化指令时才会执行。日常入库使用：

```text
paper2notion <PDF / arXiv / project page URL>
```

完整的 `$ai-robotics-paper-to-research-notion` 是显式调用形式，语义相同。

## Zotero 后端

前提：已经安装 Zotero 桌面端，并在 Codex 中连接一个兼容的 Zotero MCP。推荐使用 [cookjohn/zotero-mcp](https://github.com/cookjohn/zotero-mcp) v1.5.0 或更高版本，以支持读取文库、全文与附件，以及导入本地 PDF。

在 Zotero 中安装并启用插件后，使用插件生成的 client configuration 将 MCP 连接添加到 Codex。不要把端口、连接地址、library ID、storage 路径或 token 提交到仓库。

首次使用时发送：

```text
paper2zotero 初始化
```

初始化会检查：

- Zotero library、论文条目和附件是否可读；
- 原论文 PDF 是否可以读取；
- 本地生成的 PDF 是否可以导入并回读；
- WeasyPrint 或 Codex PDF renderer 是否可用；
- tags、metadata 和 child notes 等可选写入能力。

日常入库使用：

```text
paper2zotero <PDF / arXiv / project page URL>
```

完整的 `$ai-robotics-paper-to-research-zotero` 是显式调用形式，语义相同。

Zotero 后端不会把笔记制作成原论文上的 PDF 批注。它会生成一个独立 PDF，内容顺序固定为：

1. 中文 Research Memo；
2. 中文结构化详译。

该 PDF 通过 Zotero MCP 附加到论文 parent item，不覆盖原论文 PDF 或现有用户内容。只有达到质量标准的 Actionable Ideas 才会创建为 child notes。Zotero 写入只通过 MCP 完成，不直接修改 Zotero SQLite 数据库。

PDF renderer 可选择：

- **WeasyPrint（推荐）**：更适合当前 HTML/CSS 模板，图文、字体、公式、表格和分页通常更稳定；
- **Codex PDF skill**：无需额外安装 WeasyPrint；
- **Auto**：优先使用 WeasyPrint，否则回退到 Codex PDF skill。

## 常用方式

只精读，不写外部研究库：

```text
paper2notion 只精读不入库：<论文 URL>
paper2zotero 只精读不入库：<论文 URL>
```

带着自己的研究问题读：

```text
paper2zotero <论文 URL>
我关注的问题：这篇工作如何表示 action、是否闭环、wrist camera 是否真正建模了 view correspondence？
```

查看版本：

```text
paper2notion 当前版本
paper2zotero 当前版本
```

## 共同产出

- 中文 Research Memo：问题、主论点、method story、实验依据、failure、hidden assumptions 与研究连接。
- 图随文走的视觉证据：优先使用 paper 和 project page 原图，并说明它支持与不能支持的 claim。
- 中文结构化详译：入库或明确要求翻译时，按论文原文章节覆盖摘要、方法、实验、限制与关键附录。
- 对实验价值、可复现性、失败模式和研究机会的判断。
- 少量高质量 Actionable Ideas，以及是否值得更新 Research Map 的建议。

## 仓库结构

```text
.
├── SKILL.md                         # Notion skill，保留原有入口
├── agents/
├── references/
├── install.sh                      # notion / zotero / all
├── zotero/
│   ├── SKILL.md                    # Zotero skill
│   ├── agents/
│   ├── references/
│   ├── scripts/
│   └── tests/
├── LICENSE
└── README.md
```

Notion skill 保持在仓库根目录，以兼容已有安装方式。Zotero skill 是一个自包含的并列目录，保留 Zotero MCP、PDF renderer、独立 PDF 入库和验证逻辑，不改变 Notion 后端的运行行为。

## 环境覆盖

如需安装到另一个 Codex skills 目录：

```bash
CODEX_SKILLS_DIR=/your/skills/path bash install.sh zotero
```

如 fork 了仓库，可在远程安装时覆盖来源和分支：

```bash
curl -fsSL https://raw.githubusercontent.com/your-name/your-repo/main/install.sh | \
  AI_ROBOTICS_SKILL_REPO=your-name/your-repo AI_ROBOTICS_SKILL_REF=main bash -s -- all
```

## 隐私与边界

- 仓库不包含个人 Notion URL、页面 ID、Zotero library ID、item key、本地 storage 路径或访问 token。
- 普通论文精读不会写入 Notion 或 Zotero。
- 初始化和论文入库只在用户明确要求时执行。
- Zotero 后端不会直接读取或修改 Zotero 数据库。
- 公开发布包含论文原图的笔记前，仍需由发布者确认相应图片与内容的再分发权限。

## License

[MIT](LICENSE)
