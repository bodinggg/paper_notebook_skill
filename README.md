# Paper Reader + Heilmeier's Catechism

一款 Claude Code 技能，通过多 Agent 协作将科研论文转化为结构化分析报告。

## 功能概述

将任何科研论文转化为以下两种格式之一：
- **中文学习笔记**（默认）— 多 Agent 协作生成的完整笔记
- **Heilmeier 七问分析** — 单 Agent 英文批判性评估

## 多 Agent 架构

```
用户输入（论文）
       │
       ▼
┌──────────────────────────────────────┐
│           Coordinator                │
│  1. 获取论文并提取内容                │
│  2. 提取并下载图片                   │
│  3. 调用子 Agent 并行处理            │
│  4. 汇总生成最终笔记                 │
└──────────────────────────────────────┘
         │
    并行执行
    │
    ├── q1_problem（问题1+2）
    ├── q3_method（问题3）
    ├── q4_technical（问题4）
    ├── q5_experiment（问题5）
    ├── q6_reflection（问题6）
    ├── q7_application（问题7）
    ├── glossary（术语表）
    ├── faq（常见疑问）
    ├── reference（延伸阅读）
    └── image（图片提取）
```

## 快速开始

1. 将 `SKILL.md` 复制到 Claude Code 技能目录：
   ```bash
   cp SKILL.md ~/.claude/skills/paper-reader-heilmeier.md
   ```

2. 参考 `example/` 目录中的示例输出

3. 分享一篇论文，说"学习笔记"

## 文件结构

```
paper-reader-skill/
├── SKILL.md                 # 主技能（coordinator）
├── README.md                # 本文件
├── LICENSE                  # MIT 许可证
├── .gitignore
│
├── agents/                  # 子 Agent 定义
│   ├── q1_problem.md       # 问题1+2
│   ├── q3_method.md         # 问题3
│   ├── q4_technical.md      # 问题4
│   ├── q5_experiment.md     # 问题5
│   ├── q6_reflection.md     # 问题6
│   ├── q7_application.md    # 问题7
│   ├── glossary.md          # 术语表
│   ├── faq.md              # 常见疑问
│   ├── reference.md        # 延伸阅读
│   └── image.md            # 图片提取
│
├── shared/                  # 共享上下文
│   ├── context.md          # 上下文模板
│   ├── style_guide.md       # 统一风格指南
│   └── output/              # Agent 输出目录
│
└── example/
    ├── deepseekmath.md
    └── deepseekmath-cn.md
```

## 子 Agent 职责

| Agent | 职责 |
|-------|------|
| `q1_problem` | 分析论文背景与重要性 |
| `q3_method` | 概述论文方法（无观点） |
| `q4_technical` | 技术细节、公式、算法 |
| `q5_experiment` | 实验结果与关键发现 |
| `q6_reflection` | 学习心得（有归属观点） |
| `q7_application` | 应用建议（有归属观点） |
| `glossary` | 提取核心术语（>=5个） |
| `faq` | 生成常见疑问与解答 |
| `reference` | 推荐延伸阅读（web_search验证） |
| `image` | 提取并保存论文图片 |

## 核心特性

| 特性 | 说明 |
|------|------|
| 多 Agent 协作 | 10 个专业 Agent 并行处理 |
| 共享上下文 | 通过 `shared/context.md` 传递信息 |
| 统一风格 | 所有 Agent 遵循 `shared/style_guide.md` |
| 观点归属 | Q6/Q7 必须使用 "In my opinion," 等标记 |
| 图片提取 | 自动从 arXiv HTML 提取，保存到本地 |

## 输出模式

| 触发关键词 | 输出格式 |
|-----------|---------|
| "学习笔记"、"读懂"、"理解" | 中文学习笔记（多Agent） |
| "Heilmeier分析"、"批判性分析" | Heilmeier 七问（单Agent英文） |
| "总结"、"摘要" | 一句话快速摘要 |

## 风格规则

- 中文全角标点（，。：；？！""）
- 禁止破折号 `——`
- 公式用 `\left`/`\right`，括号用 `\lbrace`/`\rbrace`
- Q6/Q7 必须标注个人观点来源

## 安装方式

### 方式1：运行安装脚本（推荐）

**Unix/Linux/Mac:**
```bash
git clone https://github.com/bodinggg/paper_notebook_skill.git
cd paper_notebook_skill
./install.sh
```

**Windows:**
```cmd
git clone https://github.com/bodinggg/paper_notebook_skill.git
cd paper_notebook_skill
install.cmd
```

### 方式2：手动安装

```bash
# Unix
cp -r paper-reader-skill ~/.claude/skills/

# Windows
xcopy /E /Y paper-reader-skill %USERPROFILE%\.claude\skills\
```

### 方式3：npm 安装

```bash
npm install -g paper-reader-skill
```

## 使用方法

安装后，在 Claude Code 中：
- `/paper-reader <论文链接或文件路径>` — 使用 slash command
- 分享论文并说 `学习笔记` — 生成中文学习笔记（多Agent模式）
- 分享论文并说 `Heilmeier分析` — 生成英文批判性分析
- 分享论文并说 `总结` — 一句话快速摘要

## 卸载

```bash
# Unix
./uninstall.sh

# Windows
uninstall.cmd

# 或手动删除
rm -rf ~/.claude/skills/paper-reader
```

## 许可证

MIT License — 见 LICENSE 文件