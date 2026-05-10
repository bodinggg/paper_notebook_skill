---
name: paper-reader-heilmeier
description: 阅读研究论文并生成 Heilmeier 风格分析或完整中文学习笔记。当用户分享研究论文（PDF上传、arXiv链接、arXiv ID、DOI或粘贴的论文文本）并提出类似"阅读这篇"、"总结"、"分析"、"学习笔记"、"Heilmeier分析"、"审查"或"批评"的请求时，激活此技能。触发此技能时无需用户明确说"Heilmeier"——任何消化、总结、审查或批判性评估学术论文的请求都应激活它。不要将此技能用于非学术文章、博客文章或新闻。
---

# Paper Reader + Heilmeier's Catechism / 中文学习笔记

本技能根据用户意图生成两种输出之一：

- **中文学习笔记**（默认）：完整的、结构化的中文学习笔记，适合深入学习和知识沉淀
- **Heilmeier 七问分析**：批判性分析，用于快速评估论文

---

## 模式选择

| 用户意图关键词 | 输出模式 |
|----------------|----------|
| "学习笔记"、"读懂"、"理解"、"笔记"、"中文" | 中文学习笔记（默认） |
| "Heilmeier分析"、"批判性分析"、"评估"、"审查" | Heilmeier 七问分析（英文） |
| "总结"、"摘要" | 一句话快速摘要 |
| 无明确要求 | 默认：中文学习笔记 |

用户可显式指定模式："用 Heilmeier 风格分析" 或 "生成中文学习笔记"。

---

## 模式一：中文学习笔记（默认模式）

### Step 1: 获取论文

始终从头阅读论文。绝不依赖对论文的记忆，即使标题看起来很熟悉。

| 输入类型 | 操作 |
|--------- |------|
| 上传 PDF 文件 | 使用 pdf-reading 技能读取 |
| arXiv 链接/ID/DOI | 使用 `web_fetch` 抓取 arXiv 摘要页，再抓 PDF/HTML 全文 |
| 粘贴的论文文本 | 直接使用 |
| 只有标题没有链接 | 要求用户提供链接，不允许猜测 |

如果论文很长，优先阅读：摘要、引言、方法/理论、实验、结论。只在问题 2 有用时略读相关工作。

### Step 1.5: 提取图片

在生成中文学习笔记时，同步提取论文中的图片并保存。

| 来源 | 方法 | 优先级 |
|------|------|--------|
| arXiv HTML | 从 HTML 页面提取 `<img>` 标签，优先使用 ar5iv.org | **首选** |
| arXiv PDF | 通过 `curl` 下载 PDF，再提取图片 | 次选 |
| 上传 PDF | 通过 PDF 工具提取图片 | 次选 |
| 粘贴文本 | 无图片可用，跳过 | 不适用 |

**提取规则**：

1. **arXiv HTML（首选）**：
   - 使用 `curl` 获取 `https://ar5iv.org/html/{paper_id}` 页面
   - 从 HTML 中提取图片 URL：查找 `<img src="...assets/...">` 标签
   - ar5iv 图片 URL 格式：`https://ar5iv.org/html/{paper_id}/assets/{filename}.png`
   - 使用 `curl -L` 下载所有图片到 `./学习笔记/{论文标题}_images/` 目录

   **具体命令**：
   ```bash
   # 1. 获取 HTML 并提取所有图片 URL（包括子目录中的图片）
   curl -sL "https://ar5iv.org/html/{paper_id}" > /tmp/paper.html
   grep -oE 'src="[^"]*\.(png|jpg|jpeg|gif|svg)"' /tmp/paper.html | sed 's/src="//;s/"//' | sort -u

   # 2. 创建图片目录
   mkdir -p "./学习笔记/{论文标题}_images/"

   # 3. 下载所有图片（批量处理）
   # 方法一：逐个下载
   for url in $(grep -oE 'src="[^"]*\.(png|jpg|jpeg|gif|svg)"' /tmp/paper.html | sed 's/src="//;s/"//'); do
       filename=$(basename "$url")
       curl -sL "https://ar5iv.org${url}" -o "./学习笔记/{论文标题}_images/${filename}"
   done

   # 方法二：如果是 PDF 中的图片，下载整个 assets 目录
   curl -sL "https://arXiv.org/e-print/{paper_id}" -o /tmp/paper.pdf
   ```

   **注意**：
   - 图片 URL 可能包含子目录（如 `imgs/xxx.png`），需要用 `basename` 提取文件名
   - 优先使用 `src=` 属性（不是 `href=`），因为论文图片通常用 src
   - 如果 curl 下载失败，继续处理下一张，不要中断
   ```

2. **arXiv PDF（次选）**：
   - 下载 PDF：`curl -sL "https://arxiv.org/e-print/{paper_id}" -o /tmp/paper.pdf`
   - 如果 PDF < 20MB，可用 pdf-reading 技能读取
   - 或使用 Python 脚本提取：`import pdfplumber; pdfplumber.open("/tmp/paper.pdf").images`

3. **图片命名**：
   - 按论文原始图编号命名（如 `figure_1.png`、`table_1.png`）
   - 如果论文使用 Figure X 格式，则保存为 `figure_X.png`

4. **保存位置**：`./学习笔记/{论文标题}_images/` 目录

5. **不限制数量**：提取论文中的所有图片，不设上限

6. **下载失败处理**：如果某张图片下载失败，跳过该图片，继续处理其他图片。在笔记中注明哪些图片提取失败

**目录结构**：
```
./学习笔记/
├── {论文标题}_学习笔记.md
└── {论文标题}_images/
    ├── figure_1.png
    ├── figure_2.png
    ├── table_1.png
    └── ...
```

### Step 2: 生成中文学习笔记

按以下结构输出，使用简体中文。

#### 2.1 元信息

```
论文标题：（中文译题 / 英文原题）
作者：（第一作者，等）
机构：（如论文有）
发布日期：（YYYY-MM-DD）
来源：arXiv:xxxx / DOI:xxxx
阅读日期：（自动填充）
```

#### 2.2 核心术语表

列出论文中出现的所有关键术语及其定义。

规则：
- 每个术语独占一行
- 术语用**粗体**
- 定义用通俗语言，避免使用正在定义的术语本身
- 包含英文原文（括号标注）
- 至少列出 5 个核心术语

示例：
- **GRPO (Group Relative Policy Optimization)**：一种强化学习算法，通过组内归一化计算优势函数，无需学习价值函数，从而节省约一半显存。

#### 2.3 一句话总结

用一句中文（20-50字）概括论文的核心贡献。不要使用"本文"、"该论文"等冗余词。

格式：
```
🖊 一句话总结：（内容）
```

#### 2.4 完整学习笔记

按以下七个问题组织，用**学习视角**而非批判视角回答。在适当的段落中嵌入论文图片。

**问题 1：论文试图解决什么问题？**

- 用中文详细解释问题背景
- 用通俗语言解释为什么这个问题重要
- 避免仅复述论文，用自己的话解释
- **图片嵌入**：如有架构图或问题示意图，在对应段落后插入：
  ```markdown
  ![Figure 1: Problem Overview](./{论文标题}_images/figure_1.png)
  *图 1: 问题背景示意图*
  ```

**问题 2：这个问题为什么重要？**

- 阐述问题的实际意义或理论意义
- 指出当前方法的不足
- 用具体例子说明问题的影响

**问题 3：作者提出了什么方法？**

- 用中文概述作者的核心方法
- 突出创新点
- 不用公式，用直观语言解释
- **图片嵌入**：如有方法框架图，在对应段落后插入：
  ```markdown
  ![Figure 2: Method Framework](./{论文标题}_images/figure_2.png)
  *图 2: 方法框架图，包含数据管道和训练流程*
  ```

**问题 4：方法的技术细节**

- 核心公式（LaTeX 格式）
- 算法步骤
- 实现要点
- 每个符号必须解释
- 使用 `\left` 和 `\right` 配对
- 括号用 `\lbrace` 和 `\rbrace`（不用 `\{` 和 `\}`）
- **图片嵌入**：如有算法流程图或网络结构图，在对应段落后插入

**问题 5：实验结果与关键发现**

- 主要 benchmark 结果
- 关键洞察
- 消融实验结论
- **图片嵌入**：如有实验结果图（折线图、柱状图等），在对应段落后插入：
  ```markdown
  ![Figure 3: Main Results](./{论文标题}_images/figure_3.png)
  *图 3: 主要实验结果，在 GSM8K 和 MATH 基准上的表现*
  ```

**问题 6：学习心得与思考**

- 这个工作的整体评价
- 值得学习的地方
- 可能的改进方向
- 与其他工作的关系

**问题 7：如何应用到自己的研究？**

- 可能的借鉴点
- 可以尝试的方向
- 适用场景与不适用场景

**图片嵌入总规则**：
- 首次引用图片的段落之后插入图片
- 每张图片必须有中文图注，格式：`*图 X: 描述*`
- 图片路径使用相对路径：`./{论文标题}_images/filename.png`
- 如果同一位置有多张图片，按顺序列出

#### 2.5 关键公式与推导

列出论文中最重要的 2-5 个公式，附详细中文解释。

规则：
- 公式用 display math (`$$...$$`)
- 每个符号必须解释
- 解释用中文

#### 2.6 常见疑问与解答（FAQ）

基于对该领域常见困惑，预判并回答 2-3 个问题。

格式：
```
Q: 常见问题？
A: 解答（中文）
```

#### 2.7 延伸阅读

推荐 2-5 篇相关工作，说明：
- 为什么相关
- 值得阅读的理由

必须通过 `web_search` 验证推荐的有效性。每篇推荐需附上搜索结果作为依据。

#### 2.8 论文插图

**图片嵌入格式**（在 2.4 各问题的适当位置插入）：

在引用图片的段落后，插入 Markdown 图片语法和中文图注：

```markdown
![Figure 1: Caption](./{论文标题}_images/figure_1.png)
*图 1: 图片描述*
```

**列出所有图片**：

规则：
- 提取成功多少张就列出多少张
- 每行包含：图片编号、简短描述、文件路径
- 如果某张图片提取失败，在描述中注明"（提取失败）"
- 如果没有任何图片提取成功，此章节可省略

**格式**：

```markdown
## 2.8 论文插图

![Figure 1: Caption](./{论文标题}_images/figure_1.png)
*图 1: 图片描述*

![Figure 2: Caption](./{论文标题}_images/figure_2.png)
*图 2: 图片描述*

| 图片编号 | 描述 | 文件 |
|---------|------|------|
| 图 1 | 模型架构图 | ./{论文标题}_images/figure_1.png |
| 图 2 | 实验结果图 | ./{论文标题}_images/figure_2.png |
```

**说明**：如果论文中的图片编号不是连续的（如跳过了某些编号），按原论文编号保存，不必重新排序。

### Step 3: 质量自检

完成笔记后，按以下清单自检：

- [ ] 元信息完整
- [ ] 术语表覆盖核心术语（至少 5 个）
- [ ] 一句话总结简洁准确（20-50字）
- [ ] 七个问题全部回答
- [ ] 技术细节准确（公式符号有解释）
- [ ] 学习心得有个人见解
- [ ] 无事实错误
- [ ] 中文表达流畅
- [ ] 延伸阅读有搜索验证
- [ ] 关键位置已嵌入论文图片
- [ ] 每张图片有中文图注

### Step 4: 保存学习笔记和图片

完成笔记后，将笔记和图片保存到 `./学习笔记/` 目录。

**步骤**：

1. **创建图片目录**（如果不存在）：
   ```bash
   mkdir -p "./学习笔记/{论文标题}_images"
   ```

2. **下载并保存图片**到图片目录，使用原始图编号命名

3. **保存笔记**到 `./学习笔记/{论文标题}_学习笔记.md`

4. **验证**：确保笔记中的图片路径与实际保存文件一致

**文件名规则**：
- 笔记文件名：`{论文英文标题简称}_学习笔记.md`
- 标题中的空格用下划线 `_` 替代
- 去除冒号 `:` 和其他特殊字符
- 图片目录名：`{论文英文标题简称}_images`

**示例**：
```
论文：Externalization in LLM Agents
笔记：./学习笔记/Externalization_in_LLM_Agents_学习笔记.md
图片：./学习笔记/Externalization_in_LLM_Agents_images/
    ├── figure_1.png
    ├── figure_2.png
    └── table_1.png
```

---

## 模式二：Heilmeier 七问分析

此模式输出英文分析，保持原有严格规则，用于批判性评估。

### Question 1. What are you trying to do?

Open with a one-sentence statement of the paper's contribution written for a smart non-specialist, with absolutely no jargon. Ban acronyms and any technical term a first-year undergrad would not know. If a term of art is unavoidable, define it parenthetically in plain words. Then add one or two sentences expanding the objective in slightly more technical language.

Opinions allowed: no. Stay faithful to the paper.
External citations allowed: no.

### Question 2. What is the problem, how is it done today, and what are the limits of current practice?

Describe the real-world or scientific problem the paper addresses, then give a brief overview of how the field handles it at the time of the paper, and what the limitations are. This is meant to be a self-contained landscape paragraph, not a literature review. Cover the main competing approaches in plain prose.

Opinions allowed: a small amount, only if it sharpens the framing of the limits.
External citations allowed: no. Do not search for or cite outside sources here. Just give an overview from the paper and your general knowledge of the field.

### Question 3. What is new in the approach, including core idea, math, and method, and why does the paper claim it will succeed?

This is the technical heart of the response and absorbs what would otherwise be a "method" summary. Cover, in this order:

1. The central technical move that distinguishes the paper from prior work.
2. The key mathematical objects and formulation. Include the main equation or two, define every symbol you introduce, use display math with `\left` and `\right` for brackets, keep inline math on one line, and prefer standard LaTeX notation.
3. How the proposed method actually solves the problem mechanically.
4. The paper's own claim about why the approach will succeed.

Opinions allowed: NO. This subsection is strictly about what the paper says and proposes. Save your evaluation for questions 4, 5, and 6.
External citations allowed: no.

### Question 4. Who cares? If successful, what difference does it make?

Discuss the impact: which communities benefit, what becomes possible, and whether this paper has actually shifted the field since publication.

Opinions allowed: yes. This is one of the questions where your judgment matters most.
External citations allowed: yes, and encouraged when assessing post-publication impact (adoption by other groups, follow-up papers, deployment). Every external citation must come from a `web_search` or `web_fetch` you actually ran in this turn.

### Question 5. What are the risks?

Cover both the risks the paper itself acknowledges and the ones you see independently. Be concrete: contamination, reward hacking, failure modes, narrow benchmarks, scaling, reproducibility.

Opinions allowed: yes.
External citations allowed: yes, when an outside source materially supports a risk claim.

### Question 6. How much will it cost?

Interpret as compute, data, engineering effort, or deployment cost, depending on the paper. State which interpretation you are using. Pull whatever numbers the paper provides (token counts, batch sizes, GPU hours, data volumes) and translate into a rough sense of "what would it take to reproduce this".

Opinions allowed: yes, especially for the "what would it take to reproduce" framing.
External citations allowed: yes. Be careful not to conflate this paper's costs with related work by the same authors. If you cite a cost figure, state exactly which paper or model that figure refers to.

### Question 7. What are the experiments and results?

Cover the experimental setup (benchmarks, datasets, baselines, metrics, ablations) and the headline results. This subsection answers "what are the criteria for success and did the paper meet them". Note any conspicuous gap between claims and evidence.

Opinions allowed: small amount, only for noting gaps between claims and evidence.
External citations allowed: no.

---

## 通用格式规范

### 数学公式规则

- 使用 `\left` 和 `\right` 配对
- 括号用 `\lbrace` 和 `\rbrace`（**禁止**使用 `\{` 和 `\}`，GitHub 会渲染错误）
- 单行展示复杂公式
- 符号定义必须完整
- 公式后跟随中文解释

### 中文排版规则

- 标点符号：中文全角（，。：；？！""）
- 标题层级：`#` > `##` > `###`
- 列表：可用 `-` 或 `1.`，保持一致
- 引用：使用 `>` 块注
- 强调：**粗体** / *斜体*

### 章节长度规范

| 章节 | 最短 | 最长 | 典型 |
|------|------|------|------|
| 一句话总结 | 20字 | 50字 | 30字 |
| 核心术语表 | 5项 | 无上限 | 10项 |
| 每个学习问题 | 100字 | 无上限 | 200字 |
| 关键公式 | 1个 | 5个 | 3个 |
| FAQ | 2条 | 5条 | 3条 |
| 延伸阅读 | 2篇 | 5篇 | 3篇 |

### 图片命名与存储规则

- **命名**：使用论文原始图编号，如 `figure_1.png`、`table_1.png`
- **目录**：`{论文标题}_images/` 子目录
- **路径**：Markdown 中使用相对路径 `./{论文标题}_images/filename.png`
- **数量**：不限制，提取全部图片

### 不允许事项

- **禁止使用破折号** `——`，使用逗号、句号、分号或换句代替
- 不使用英文引号 `""`，使用中文引号 `""`
- 不混用中英文标点
- 不在正文中使用口语化表达
- 不重复同一内容

---

## 引用规则（模式一）

每个外部引用必须来自本轮实际运行的 `web_search` 或 `web_fetch`。禁止记忆引用。唯一例外：当论文本身引用某工作且你**完全重复**论文对该工作的描述时，可不搜索。一旦超出论文原文所述，务必搜索并引用。

## 引用规则（模式二）

Every external citation in your response must come from a `web_search` or `web_fetch` you actually ran in this turn. No citations from memory. There is exactly one carve-out: if the paper itself cites a prior work and you are *exactly* repeating what the paper says about that cited work, you may mention it without a web search. The moment you add anything beyond what the paper literally says, search and cite the search result.

---

## 归属规则（适用于模式二）

The user must always be able to tell paper content apart from your own analysis. In any subsection where opinions are allowed, prefix every personal judgment with one of: **"In my opinion,"**, **"My analysis is that,"**, **"My read is,"** or an equivalent first-person marker. Never blur the line. In the subsections where opinions are not allowed (questions 1 and 3), do not use these markers at all.

---

## 快速摘要模式

当用户请求"总结"时，输出：
- 一行中文（20-50字）概括核心贡献
- 三个要点（每个一句话）
- 适合快速了解论文

---

## 已知限制

- **很新的 arXiv 论文**：可能未被抓取，需等待索引
- **付费墙论文**：无法下载，仅支持开放获取的 PDF、arXiv、粘贴文本和上传文件
- **扫描版 PDF**：若无嵌入文字层则无法解析，OCR 不在本流程范围内
- **图片提取失败**：arXiv HTML 结构变化可能导致部分图片无法获取，但笔记仍可正常生成