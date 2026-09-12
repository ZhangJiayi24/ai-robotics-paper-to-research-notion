# Notion 工作区初始化与发现规范

## 目标

让不同用户在自己的 Notion 工作区中复建同一套 AI Robotics 研究流程，同时不依赖作者个人页面 ID、数据库 ID 或绝对 URL。

本规范只处理工作区发现、首次初始化和数据库写入约定；论文阅读与笔记内容以 `SKILL.md` 及其路由到的写作 references 为准。

## 前提与授权

- 用户需要在 Codex 中安装并连接 Notion。
- 初始化会创建 Notion 页面和数据库，只在用户明确要求“初始化 / 创建 / 复建”时执行。
- 普通“精读”不需要 Notion。普通“入库”可以创建或更新论文条目，但如果整套 Hub 尚不存在，先提示用户运行初始化，不要静默创建整套工作区。

## Hub 发现

默认 Hub 标题：`AI Robotics Research Hub`。

按以下顺序定位：

1. 使用用户本轮明确提供的 Hub URL；
2. 在当前连接的 Notion 工作区中搜索标题精确匹配的页面；
3. 使用用户明确指定的同类 Hub。

找到候选后读取页面，确认它包含或指向论文库、想法库、Current Research Lens、Research Map 中的至少一个组件。多个同名候选无法判断时，让用户选择，不要猜测。

不要把搜索结果中的旧页面、公开网页或名字相似的数据库当作 Hub。

## 初始化流程

用户明确要求初始化时：

1. 确认当前 Notion 连接可用，并识别当前工作区；
2. 搜索 `AI Robotics Research Hub`；存在则复用，不重复创建；
3. 在 Hub 内搜索下列组件，只补建缺失项：
   - `AI Robotics 论文库`
   - `AI Robotics 想法库`
   - `Current Research Lens`
   - `Research Map`
4. 创建数据库后读取返回的 data source ID；想法库的“来源论文”关系必须指向这次实际定位到的论文库 data source，不能写死 ID；
5. 将 Hub 首页更新为简短导航，链接到实际创建或复用的组件；
6. 重新读取 Hub 和两个数据库一次，确认页面存在且核心字段可用，然后报告实际 URL。

如果已有数据库字段名称不同但语义明确，复用现有字段。只补充缺失的核心字段，不删除用户字段，不创建同义重复字段，也不重写已有内容。

## 论文库 schema

使用下面的 schema 创建 `AI Robotics 论文库`。如果 Notion 工具使用 SQL DDL，将其作为基准；颜色可以按工具支持情况调整，不改变字段语义。

```sql
CREATE TABLE (
  "标题" TITLE,
  "作者" RICH_TEXT,
  "年份" NUMBER,
  "Venue" RICH_TEXT,
  "URL" URL,
  "研究方向" MULTI_SELECT(
    'Embodied AI':purple,
    'Robot Learning':blue,
    'Robot Manipulation':orange,
    'VLA':pink,
    'TAMP':green,
    'World Representation':yellow,
    'Multi-view Representation':blue,
    'Closed-loop Robot Learning':red
  ),
  "任务类型" RICH_TEXT,
  "方法关键词" RICH_TEXT,
  "数据集 / 环境" RICH_TEXT,
  "代码链接" URL,
  "阅读状态" SELECT('待读':gray, '已整理':blue, '已精读':green),
  "阅读优先级" SELECT('A 必读':red, 'B 值得读':yellow, 'C 可略读':gray),
  "实验价值" RICH_TEXT,
  "一句话结论" RICH_TEXT,
  "可复现点" RICH_TEXT,
  "创建时间" CREATED_TIME,
  "最后编辑" LAST_EDITED_TIME
)
```

`研究方向` 使用多选标签；`任务类型`、`方法关键词`、`数据集 / 环境` 保持文本字段，避免为了每篇论文的动态术语频繁修改数据库 schema。

## 想法库 schema

先取得论文库的实际 data source ID，再创建 `AI Robotics 想法库`。把 `<PAPER_DATA_SOURCE_ID>` 替换为实际 ID。

```sql
CREATE TABLE (
  "想法标题" TITLE,
  "类型" SELECT(
    'Seed Question':yellow,
    'Experiment Idea':blue,
    'Project Direction':purple,
    'Paper-level Idea':pink,
    'Baseline / Ablation Idea':green
  ),
  "来源论文" RELATION('<PAPER_DATA_SOURCE_ID>'),
  "研究问题" RICH_TEXT,
  "Motivation" RICH_TEXT,
  "具体实验设计" RICH_TEXT,
  "需要的系统 / 数据 / 代码" RICH_TEXT,
  "预期结果" RICH_TEXT,
  "可能失败原因" RICH_TEXT,
  "优先级" SELECT('A 高':red, 'B 中':yellow, 'C 低':gray),
  "Research Lens" RICH_TEXT,
  "状态" SELECT('Seed':gray, '待验证':yellow, '进行中':blue, '已验证':green, '搁置':red),
  "创建时间" CREATED_TIME,
  "最后编辑" LAST_EDITED_TIME
)
```

## 两个辅助页面

### Current Research Lens

创建一个可持续更新的短页面，不预填永久研究偏好。使用以下骨架：

```markdown
# Current Research Lens

## Active Questions

## Working Hypotheses

## Evaluation Priorities

## Recently Deprioritized

## Last Updated
```

### Research Map

保留三层结构，避免把一次性论文术语直接塞进主图：

```markdown
# Research Map

## Field Map

稳定的大领域分类。

## Current Research Lens

当前正在追踪的 representation、planning、action、memory、execution 等研究问题。

## Update Candidates

来自近期论文、尚待验证是否值得进入主图的候选概念。
```

## 日常写入

### 论文去重

写入论文前，先在论文库按以下顺序查重：

1. 标题规范化后的精确匹配；
2. arXiv / DOI / project URL 指向同一论文；
3. 标题发生版本变化但作者与内容明确相同。

命中已有条目时更新，不新建重复项。无法判断是否同一论文时，保留现有条目并向用户说明歧义。

### 属性映射

写入前读取实际数据库 schema，使用数据库已有的精确字段名和选项。正文不要重复数据库 metadata。

如果用户的数据库缺少某个非核心属性，将信息保留在正文中即可；不要为了单篇论文修改 schema。只有显式初始化或用户要求调整数据库时，才修改 schema。

### 页面正文

论文页正文顺序固定为：

1. `中文 Research Memo`
2. `中文结构化详译`（仅在入库或用户明确要求翻译时）

创建或更新页面前，通过当前连接的 Notion 工具读取其最新 Markdown 规范。图随文走，同一视觉材料只上传一次；其他位置用 source anchor 交叉引用。

### 想法写入

只把符合 `references/research-map-and-ideas.md` 中 Actionable Ideas 标准的想法写入想法库。`来源论文` 使用真实 relation，不能退化成手写标题或失效 URL，除非现有数据库本身没有 relation 字段。

## 初始化完成汇报

简洁报告：

- 使用了哪个 Notion 工作区；
- Hub 是创建还是复用；
- 两个数据库和两个辅助页面分别是创建还是复用；
- 实际 Hub URL；
- 是否存在未能补齐的字段或权限限制；
- 下一条可直接使用的 prompt：`使用 $ai-robotics-paper-to-research-notion 精读并入库：<论文 URL>`。
