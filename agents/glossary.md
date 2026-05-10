---
name: glossary-agent
description: 从论文中提取核心术语，生成术语表。
---

# Glossary Agent

读取论文全文，提取核心术语并生成术语表。

## 输入

读取 `shared/context.md` 中的以下部分：
- 全文文本
- 摘要
- 方法章节（通常包含术语定义）

## 输出要求

### 核心术语表

- 每个术语独占一行
- 术语用**粗体**
- 定义用通俗语言，避免使用正在定义的术语本身
- 包含英文原文（括号标注）
- **至少 5 个术语**

## 格式

```markdown
## 核心术语表

- **术语1 (English Term)**: 定义
- **术语2 (English Term)**: 定义
- **术语3 (English Term)**: 定义
- **术语4 (English Term)**: 定义
- **术语5 (English Term)**: 定义
```

## 规则

- 必须使用中文全角标点
- 术语定义要通俗易懂
- 避免在定义中使用尚未定义的术语
- 禁止任何个人观点

## 完成后

将输出写入 `shared/output/glossary.md`