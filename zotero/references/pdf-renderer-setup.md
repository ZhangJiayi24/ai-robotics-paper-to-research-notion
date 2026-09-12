# PDF Renderer 初始化与选择

仅在 `paper2zotero 初始化`、用户要求重新配置 PDF，或当前 renderer 失效时完整阅读本文件。

## 原则

- `install.sh` 只安装 skill 文件，不静默修改 Python 或系统环境。
- 初始化先验证 Zotero MCP；只有 MCP 达到完整入库或只读可诊断状态后，才进入 PDF renderer 配置。
- WeasyPrint 的 HTML/CSS 图文排版、字体、表格和分页效果通常更稳定，默认标记为推荐。
- Codex PDF skill 是免安装选项和 fallback；它是一套生成与 QA 工作流，不是假定存在的固定命令。
- 仓库不保存 endpoint、端口、token、library ID、绝对路径或机器专用配置。

## 初始化交互

先运行 `scripts/pdf-runtime.sh check`，再结合当前 Codex 环境中是否存在 PDF skill。已有有效 renderer 偏好且依赖状态未变化时，沿用当前选择，不重复询问或生成样张；首次初始化、偏好无效或用户要求重新配置时才显示：

```text
PDF 环境
Codex PDF skill：可用 / 不可用
WeasyPrint：可用 / 未安装 / 原生依赖缺失
Poppler QA：可用 / 缺少工具
CJK 字体：可用 / 缺失 / 未知
```

然后让用户选择：

1. **WeasyPrint（推荐）**：与当前 Research Memo HTML/CSS 模板最匹配；缺少时需要安装专用虚拟环境。
2. **Codex PDF skill**：无需安装 WeasyPrint；复杂图文排版可能与推荐版略有差异。
3. **Auto**：优先使用可用的 WeasyPrint，否则回退到 Codex PDF skill。

不要在用户选择前安装任何依赖。

## WeasyPrint 安装授权

选择 WeasyPrint 且 renderer 缺失时，先说明以下影响并请求授权：

- 创建 paper2zotero 专用虚拟环境；
- 下载固定版本的 WeasyPrint 及 Python 依赖；
- 不修改系统 Python；
- 后续任务复用，不重复下载；
- 不静默调用 Homebrew、apt、dnf、pacman 或其他系统包管理器。

获得授权后运行：

```text
scripts/pdf-runtime.sh install-weasyprint
```

若 Pango 等原生库缺失，报告缺项并链接 WeasyPrint 官方安装文档。系统包安装需要新的明确授权。Poppler或 CJK 字体缺失时同样报告，不把缺项伪装成配置成功。

## 保存选择

使用下面的命令保存 renderer 偏好：

```text
scripts/pdf-runtime.sh set-renderer auto
scripts/pdf-runtime.sh set-renderer weasyprint
scripts/pdf-runtime.sh set-renderer codex-pdf
```

配置只包含 renderer 名称，保存在用户本地配置目录，不进入仓库，也不在初始化报告中输出绝对路径。使用 `scripts/pdf-runtime.sh get-renderer` 读取当前偏好。

## 验证

仅在首次安装 WeasyPrint、切换 renderer、renderer 健康检查失败或用户明确要求验证时，在 task-scoped 临时目录生成一页验证 PDF，并在完成后删除。普通初始化沿用健康的 renderer 时跳过样张。样张至少包含中文 regular/bold、英文、语义化上下标、表格和一张透明图片。

两种 renderer 使用同一验收标准：

- A4 页面；
- regular / bold CJK 字体正确嵌入；
- 没有 Type 3 字体；
- `pdftotext` 可读，公式没有 Unicode 上下标乱码；
- `pdfimages -list` 可追踪透明图来源；合法 `smask` 不作为失败条件；
- 透明图在 Poppler 和当前 Zotero/PDF.js 中都没有黑底、黑边或错误背景合成；
- 全页渲染没有溢出、重叠、黑块或缺字。

初始化不能把样张导入 Zotero。

## 完成报告

```text
Zotero MCP：可完整入库 / 只读 / 不可用
Codex PDF skill：可用 / 不可用
WeasyPrint：可用 / 未安装 / 原生依赖缺失
PDF renderer：weasyprint / codex-pdf / auto
Poppler QA：可用 / 缺少工具
CJK 字体：可用 / 缺失 / 未知
验证：通过 / fallback only / 未完成
```

若用户运行 `paper2zotero 重新配置 PDF`，重新执行选择与验证，但不要重复安装已经可用的专用环境。
