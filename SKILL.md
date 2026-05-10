---
name: paper-reader-heilmeier
description: 阅读研究论文并生成中文学习笔记。通过多Agent协作，每个Agent负责特定问题，确保输出质量。
---

# Paper Reader + Heilmeier's Catechism / 中文学习笔记

本技能通过多Agent协作生成结构化的中文学习笔记。

---

## 工作流程

```
用户输入（论文）
       │
       ▼
┌──────────────────────────────────────┐
│           Coordinator                │
│  1. 获取论文并提取内容                │
│  2. 提取并下载图片                   │
│  3. 填充共享上下文                   │
│  4. 调用子Agent并行处理              │
│  5. 汇总生成最终笔记                 │
└──────────────────────────────────────┘
```

---

## 子Agent列表

| Agent | 职责 | 输出文件 |
|-------|------|---------|
| `q1_problem` | 问题1+2：背景与重要性 | `shared/output/q1_problem.md` |
| `q3_method` | 问题3：方法概述 | `shared/output/q3_method.md` |
| `q4_technical` | 问题4：技术细节 | `shared/output/q4_technical.md` |
| `q5_experiment` | 问题5：实验结果 | `shared/output/q5_experiment.md` |
| `q6_reflection` | 问题6：学习心得 | `shared/output/q6_reflection.md` |
| `q7_application` | 问题7：应用建议 | `shared/output/q7_application.md` |
| `glossary` | 核心术语表 | `shared/output/glossary.md` |
| `faq` | 常见疑问 | `shared/output/faq.md` |
| `reference` | 延伸阅读 | `shared/output/reference.md` |
| `image` | 图片提取 | `shared/output/image.md` |

---

## Step 1: 获取论文

始终从头阅读论文。绝不依赖对论文的记忆。

| 输入类型 | 操作 |
|---------|------|
| 上传 PDF 文件 | 使用 pdf-reading 技能读取 |
| arXiv 链接/ID/DOI | 使用 `web_fetch` 抓取 arXiv 摘要页，再抓 HTML 全文 |
| 粘贴的论文文本 | 直接使用 |
| 只有标题没有链接 | 要求用户提供链接 |

### arXiv HTML 获取

使用 ar5iv.org 获取 HTML 格式（便于提取图片）：
```
https://ar5iv.org/html/{paper_id}
```

---

## Step 2: 提取图片

### 图片提取优先级

| 来源 | 方法 |
|------|------|
| arXiv HTML | 从 HTML 提取 `<img>` 标签 |
| arXiv PDF | curl 下载后提取 |

### 提取命令

```bash
# 1. 获取 HTML 并提取图片 URL
curl -sL "https://ar5iv.org/html/{paper_id}" > /tmp/paper.html
grep -oE 'src="[^"]*\.(png|jpg|jpeg|gif|svg)"' /tmp/paper.html | sed 's/src="//;s/"//' | sort -u

# 2. 创建图片目录
mkdir -p "./学习笔记/{论文标题}_images/"

# 3. 下载图片
for url in $(grep -oE 'src="[^"]*\.(png|jpg|jpeg|gif|svg)"' /tmp/paper.html | sed 's/src="//;s/"//'); do
  filename=$(basename "$url")
  curl -sL "https://ar5iv.org${url}" -o "./学习笔记/{论文标题}_images/${filename}"
done
```

### 图片命名

- 按论文原始图编号命名（如 `figure_1.png`）
- 不限制数量，提取全部图片

---

## Step 3: 填充共享上下文

创建并填充 `shared/context.md`：

```markdown
# 论文: {标题}
# 来源: {arXiv ID / DOI}
# 日期: {处理日期}

## 论文基本信息
- 标题：
- 作者：
- 机构：
- 发布日期：
- 来源：

## 原始论文内容

### 摘要 (Abstract)
（内容）

### 引言/背景 (Introduction)
（内容）

### 方法 (Method)
（内容）

### 实验结果 (Experiment/Results)
（内容）

### 结论 (Conclusion)
（内容）

### 图片信息
（已提取的图片URL列表）
```

---

## Step 4: 并行调用子Agent

**可以并行执行的Agent**（无依赖关系）：
- `q1_problem`（问题1+2）
- `q3_method`（问题3）
- `q4_technical`（问题4）
- `q5_experiment`（问题5）
- `q6_reflection`（问题6）
- `q7_application`（问题7）
- `glossary`（术语表）
- `faq`（常见疑问）
- `reference`（延伸阅读）
- `image`（图片处理）

每个子Agent需要：
1. 读取 `shared/context.md` 获取论文内容
2. 按照自己的职责生成输出
3. 将输出写入 `shared/output/{agent_name}.md`

---

## Step 5: 汇总生成最终笔记

读取所有子Agent的输出，按以下结构组装：

### 最终笔记结构

```markdown
# {论文标题} 学习笔记

## 2.1 元信息

论文标题：（中文译题 / 英文原题）
作者：（第一作者，等）
机构：（如论文有）
发布日期：（YYYY-MM-DD）
来源：arXiv:xxxx / DOI:xxxx
阅读日期：（自动填充）

## 2.2 核心术语表

（从 `shared/output/glossary.md` 读取）

## 2.3 一句话总结

🖊 一句话总结：（20-50字）

## 2.4 完整学习笔记

### 问题一：论文试图解决什么问题？
（从 `shared/output/q1_problem.md` 读取）

### 问题二：这个问题为什么重要？
（从 `shared/output/q1_problem.md` 读取）

### 问题三：作者提出了什么方法？
（从 `shared/output/q3_method.md` 读取）

### 问题四：方法的技术细节
（从 `shared/output/q4_technical.md` 读取）

### 问题五：实验结果与关键发现
（从 `shared/output/q5_experiment.md` 读取）

### 问题六：学习心得与思考
（从 `shared/output/q6_reflection.md` 读取）

### 问题七：如何应用到自己的研究？
（从 `shared/output/q7_application.md` 读取）

## 2.5 关键公式与推导
（从 `shared/output/q4_technical.md` 读取）

## 2.6 常见疑问与解答
（从 `shared/output/faq.md` 读取）

## 2.7 延伸阅读
（从 `shared/output/reference.md` 读取，有 web_search 验证）

## 2.8 论文插图
（从 `shared/output/image.md` 读取）

## 质量自检清单

- [ ] 元信息完整
- [ ] 术语表覆盖核心术语（至少 5 个）
- [ ] 一句话总结简洁准确（20-50字）
- [ ] 七个问题全部回答
- [ ] 技术细节准确（公式符号有解释）
- [ ] 学习心得有个人见解（有归属标记）
- [ ] 无事实错误
- [ ] 中文表达流畅
- [ ] 延伸阅读有搜索验证
- [ ] 关键位置已嵌入论文图片
- [ ] 每张图片有中文图注
```

---

## 风格指南

所有输出必须遵循以下规则：

### 中文标点
- 使用中文全角标点：`，。：；？！""`
- 禁止使用破折号 `——`
- 禁止使用英文引号 `""`

### 数学公式
- 使用 `\left` 和 `\right` 配对
- 括号用 `\lbrace` 和 `\rbrace`（禁止 `\{` 和 `\}`）
- 每个符号必须解释

### 观点归属
- 问题1和问题3：禁止个人观点
- 问题6和问题7：**必须使用归属标记**（`In my opinion,`、`My analysis is that,`）

### 图片嵌入
```markdown
![图1: 描述](./{论文标题}_images/figure_1.png)
*图1: 描述*
```

---

## 输出模式

| 用户意图关键词 | 输出模式 |
|----------------|----------|
| "学习笔记"、"读懂"、"理解"、"笔记"、"中文" | 中文学习笔记（默认，多Agent模式） |
| "Heilmeier分析"、"批判性分析" | Heilmeier 七问分析（英文，**单Agent模式**） |
| "总结"、"摘要" | 一句话快速摘要 |

---

## 已知限制

- 很新的 arXiv 论文可能未被抓取
- 付费墙论文无法访问
- 扫描版 PDF 无法解析
- 图片提取失败不影响文字输出