# Paper Reader + Heilmeier's Catechism

一款 Claude Code 技能，将科研论文转化为结构化分析报告。

## 功能概述

将任何科研论文转化为以下两种格式之一：
- **中文学习笔记**（默认）— 完整的、结构化的中文笔记，适合深入学习和知识沉淀
- **Heilmeier 七问分析** — 英文批判性评估报告

## 快速开始

1. 将 `SKILL.md` 复制到 Claude Code 技能目录：
   ```bash
   cp SKILL.md ~/.claude/skills/paper-reader-heilmeier.md
   ```

2. 参考 `example/` 目录中的示例输出：
   - `deepseekmath.md` — Heilmeier 分析示例
   - `deepseekmath-cn.md` — 中文学习笔记示例

3. 分享一篇论文（PDF上传、arXiv链接、DOI或粘贴文本），然后说"学习笔记"或"Heilmeier分析"

## 功能特点

| 特性 | 说明 |
|------|------|
| 多格式支持 | arXiv、PDF上传、DOI、粘贴文本 |
| 图片提取 | 从 arXiv HTML 自动提取论文图片并附中文图注 |
| 引用规范 | 外部引用必须来自同一次响应中的网络搜索 |
| 观点边界 | Q1 和 Q3 严格基于论文内容；个人判断有明显标记 |

## 输出模式

| 触发关键词 | 输出格式 |
|-----------|---------|
| "学习笔记"、"读懂"、"理解" | 中文学习笔记（默认） |
| "Heilmeier分析"、"批判性分析" | Heilmeier 七问分析（英文） |

## 中文学习笔记结构

1. **元信息** — 标题、作者、机构、日期、来源
2. **核心术语表** — 关键术语及定义
3. **一句话总结** — 20-50字概括核心贡献
4. **完整学习笔记** — 七个学习问题
5. **关键公式与推导** — 核心公式及符号解释
6. **常见疑问与解答** — FAQ
7. **延伸阅读** — 相关工作（经网络搜索验证）
8. **论文插图** — 提取的图片及图注

## Heilmeier 七问框架

1. 你试图做什么？
2. 问题是什么，当前如何做，有什么局限？
3. 方法有什么新东西，为什么会成功？
4. 谁在意？
5. 风险是什么？
6. 代价是多少？
7. 实验和结果是什么？

## 文件结构

```
paper-reader-skill/
├── SKILL.md              # 技能定义文件
├── README.md             # 本文件
├── LICENSE               # MIT 许可证
├── .gitignore            # Git 忽略配置
└── example/
    ├── deepseekmath.md         # Heilmeier 分析示例
    └── deepseekmath-cn.md      # 中文学习笔记示例
```

## 环境要求

- Claude Code CLI
- 网络连接（用于获取 arXiv 论文和网络搜索）

## 已知限制

- 最新的 arXiv 论文可能需要时间才能被索引
- 付费墙论文无法访问
- 无嵌入式文字层的扫描版 PDF 无法解析

## 许可证

MIT License — 见 LICENSE 文件