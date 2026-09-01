# AI Robotics Paper to Research Zotero

一套给 Codex 使用的 AI Robotics / Embodied AI / Robot Learning 论文精读工作流。它会把论文 PDF、project page、GitHub 与关键视觉证据整理成中文 Research Memo；在用户要求入库时，还会生成按原文章节组织的中文结构化详译，两者合并为独立 PDF，再通过 Zotero MCP 附加到论文条目。

核心笔记方法来自上游 `paper2notion-cn-v1.2.0`。这个公开的 Zotero fork 只把 Notion 持久化映射替换为 Zotero parent item + PDF attachment + 高质量 idea child notes，并保留上游的精读、结构化详译、视觉证据和 Research Map 要求。

## 安装

前提：已经安装 Codex 和 Zotero 桌面端。仓库不保存 Zotero MCP 的端口、服务地址、library ID、storage 路径或其他机器相关配置；安装 skill 后通过 `paper2zotero 初始化` 完成连接发现和能力检查。

公开仓库可以直接通过 HTTPS 克隆并本地安装：

```bash
git clone --branch feature/zotero-backend https://github.com/MicroGrey/ai-robotics-paper-to-research-notion.git ai-robotics-paper-to-research-zotero
cd ai-robotics-paper-to-research-zotero
bash install.sh
```

安装器会把 skill 放到 Codex 当前使用的个人 skill 目录：

```text
~/.agents/skills/ai-robotics-paper-to-research-zotero
```

它不会保存 Zotero token 或直接修改 Zotero SQLite 数据库。重复执行同一条命令即可升级。Codex 通常会自动发现更新；如果 skill 没有出现，重启 Codex。

官方说明：[Codex Skills](https://developers.openai.com/codex/skills) · [Codex Plugins](https://developers.openai.com/codex/plugins)

## 配置 Zotero MCP

推荐使用 [cookjohn/zotero-mcp](https://github.com/cookjohn/zotero-mcp)。它以 Zotero 插件形式提供集成的 Streamable HTTP MCP server，可以直接读取本地文库、全文和附件，并支持写入 metadata、notes、tags 和 PDF 附件。

本 skill 需要把生成的本地 PDF 附加到论文 parent item，因此建议使用 **v1.5.0 或更高版本**；`write_item` 的本地文件 `import` 能力从 v1.5.0 开始提供。安装步骤：

1. 从项目的 [Releases](https://github.com/cookjohn/zotero-mcp/releases) 下载最新 `.xpi`；
2. 在 Zotero 的 `Tools -> Add-ons` 中安装 `.xpi`，然后重启 Zotero；
3. 打开 `Preferences -> Zotero MCP Plugin`，启用集成 MCP server 和写入能力；
4. 使用插件自带的 **Generate Client Configuration** 生成连接配置，并在 Codex 的 MCP 管理界面添加该连接；
5. 回到 Codex 运行 `paper2zotero 初始化`。

不要把插件生成的连接地址、端口或本地路径提交到本仓库。不同机器直接使用各自 Zotero 插件生成的 client configuration；`paper2zotero 初始化` 会读取当前 Codex 环境中的连接和工具 schema，并验证是否具备完整入库能力。

## 第一次使用：初始化 Zotero MCP

安装后，在 Codex 中发送：

```text
paper2zotero 初始化
```

初始化会从 Codex 当前可用的 MCP 连接中发现 Zotero 能力，并按实际工具 schema 完成运行时适配，不依赖仓库内的固定工具名或连接参数。

初始化检查以下必要能力：

- 读取当前可用的 Zotero library；
- 搜索 bibliographic parent item；
- 读取条目 metadata、attachments 和 notes；
- 读取或解析论文 PDF；
- 将本地生成的 PDF 导入指定 parent item；
- 导入后重新读取 parent item 完成验证。

以下能力是可选的：

- 添加 tags；
- 创建高质量 `Research Idea | ...` child notes；
- 更新 bibliographic metadata。

初始化只做无副作用的连接与能力探测，不创建测试条目、测试附件或 collection，也不会移动、覆盖或删除现有内容。完成后会报告：

```text
Zotero MCP：已连接 / 未连接
Library 读取：可用 / 不可用
条目搜索与读取：可用 / 不可用
PDF 读取：可用 / 不可用
PDF 导入与回读：可用 / 不可用
可选写入能力：tags / child notes / metadata
结论：可完整入库 / 只读 / 缺少必要能力
```

如果没有发现 Zotero MCP，初始化应停止并指出需要先在 Codex 的 MCP 管理界面连接一个兼容实现；它不会猜测端口、生成机器专用配置，或把连接信息写入仓库。连接完成后再次运行同一条初始化指令即可。

初始化还会配置 PDF renderer。用户可以选择：

- **WeasyPrint（推荐）**：与 Research Memo 的 HTML/CSS 模板最匹配，图文、字体、表格和分页效果更稳定；缺少时会先请求授权，再安装到专用虚拟环境。
- **Codex PDF skill**：不额外安装 WeasyPrint，直接使用 Codex 自带的 PDF 生成与 QA 工作流；复杂排版可能与推荐版略有差异。
- **Auto**：优先使用可用的 WeasyPrint，否则回退到 Codex PDF skill。

`install.sh` 不安装 renderer 或系统包。初始化只在用户选择 WeasyPrint 并明确授权后下载 Python 依赖；Pango、Poppler 和 CJK 字体等系统依赖缺失时会单独报告，不会静默调用系统包管理器。Renderer 选择只保存在用户本地配置中，不进入仓库。

初始化默认采用快路径：已暴露的 Zotero 工具只验证 library、工具 schema、一次最小搜索和 PDF 环境。PDF 全文提取、实际附件导入与回读、完整样张 QA 延迟到首次相关任务，避免每次初始化重复等待。只有工具未暴露或只读调用失败时才进入 endpoint 与沙箱诊断。

当前任务没有原生 Zotero 工具包装、但 Codex 已注册的 MCP endpoint 可以完成握手时，skill 会通过标准 MCP JSON-RPC fallback 继续工作，不会要求用户反复新建任务。Fallback 仍只调用 Zotero MCP，不读取 Zotero 数据库或猜测本地 storage 路径。

安全策略是“原生工具优先”，而不是禁止 HTTP transport。只有确认 Codex 注册配置、本机 endpoint、MCP 握手和用户授权后才使用 fallback；任何写入都必须通过 MCP 强制回读验证。

### MCP 兼容要求

本 skill 按语义能力适配 Zotero MCP，不绑定某个 MCP 项目或固定工具命名。兼容实现只要能够提供上述必要能力即可。实际工具可能叫 `search_library`、`search_items`、`get_item`、`get_content`、`import_attachment` 等，初始化会以工具 schema 为准进行映射。

连接信息由 Codex 与 Zotero MCP 自己管理。仓库、生成的 skill 和初始化报告都不应记录个人绝对路径、固定端口、访问 token、library ID 或 item key。

## 触发指令：`paper2zotero`

日常使用直接输入 `paper2zotero` 即可。最短写法：

```text
paper2zotero <PDF / arXiv / project page URL>
```

默认含义是：中文精读 → 中文结构化详译 → 生成 PDF → 写入 Zotero。

完整的 `$ai-robotics-paper-to-research-zotero` 是显式调用形式；当你想明确指定 skill 时使用，效果相同。

## 常用方式

只做中文精读，不写 Zotero：

```text
paper2zotero 只精读不入库：<PDF / arXiv / project page URL>
```

精读、结构化详译并入库：

```text
paper2zotero <PDF / arXiv / project page URL>
```

带着自己的研究问题读：

```text
paper2zotero <论文 URL>
我关注的问题：这篇工作如何表示 action、是否闭环、wrist camera 是否真正建模了 view correspondence？
```

检查 Zotero MCP：

```text
paper2zotero 初始化
```

查看版本：

```text
paper2zotero 当前版本
```

## 这套流程会产出什么

- 中文 Research Memo：问题、主论点、method story、实验依据、failure、hidden assumptions 与研究连接。
- 图随文走的视觉证据：优先使用 paper 和 project page 原图，并说明它支持与不能支持的 claim。
- 中文结构化详译：入库或明确要求翻译时，按论文原文章节覆盖摘要、方法、实验、限制与关键附录。
- Zotero 论文条目：权威 bibliographic metadata、具体 tags，以及 PDF 内的 Research Record。
- 一个包含完整 Research Memo 和中文结构化详译的独立 PDF 附件。
- 少量高质量 Actionable Idea child notes，以及 PDF 内是否值得更新 Research Map 的判断。

## 仓库结构

```text
.
├── SKILL.md
├── agents/
│   └── openai.yaml
├── references/
│   ├── chinese-structured-translation.md
│   ├── notion-paper-records.md
│   ├── notion-workspace-setup.md
│   ├── quality-and-completion.md
│   ├── research-map-and-ideas.md
│   ├── research-memo-writing.md
│   ├── source-and-visual-evidence.md
│   ├── zotero-mcp-adapter.md
│   ├── zotero-paper-records.md
│   └── zotero-workspace-setup.md
├── install.sh
├── LICENSE
└── README.md
```

`SKILL.md` 只保留触发、模式选择、关键不变量和渐进式路由。来源与视觉证据、Research Memo 写法、Research Map、Zotero 字段、详译和完成检查分别在需要时加载；笔记方法和判断标准没有因后端变更而删减。上游 `notion-*.md` 文件按原样保留用于差异审计；Zotero 运行时路由到 `zotero-*.md`。

## 环境覆盖

默认安装到 `~/.agents/skills`。如需安装到另一个 Codex skills 目录：

```bash
CODEX_SKILLS_DIR=/your/skills/path bash install.sh
```

公开仓库推荐使用 HTTPS clone；已经配置 GitHub SSH 认证时也可以改用 SSH 地址，再执行本地 `install.sh`。

## 隐私与边界

- 仓库不包含个人 Zotero library ID、item key、本地 storage 路径或访问 token。
- 普通论文精读不会写入 Zotero。
- Zotero 论文入库只在用户明确要求时执行。
- 公开发布包含论文原图的笔记前，仍需由发布者确认相应图片与内容的再分发权限。

## License

[MIT](LICENSE)
