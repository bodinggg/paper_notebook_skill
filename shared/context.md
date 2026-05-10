# 共享上下文模板

## 论文基本信息

```yaml
title: ""
original_title: ""
authors: []
institutions: []
publish_date: ""
source: ""  # arXiv ID / DOI / Uploaded PDF
read_date: "{自动填充}"
paper_id: ""  # 用于图片目录命名
```

## 原始论文内容

由 coordinator 提取并分割，供各子 Agent 读取。

### 摘要 (Abstract)
（由 coordinator 填充）

### 引言/背景 (Introduction)
（由 coordinator 填充）

### 方法 (Method)
（由 coordinator 填充）

### 实验结果 (Experiment/Results)
（由 coordinator 填充）

### 结论 (Conclusion)
（由 coordinator 填充）

### 全文文本
（完整文本，供需要全文的 Agent 使用）

### 图片信息
```yaml
images:
  - id: figure_1
    url: ""
    local_path: ""
    caption: ""
  - id: figure_2
    url: ""
    local_path: ""
    caption: ""
```

## Agent 输出占位

各 Agent将自己的输出写入对应章节。

### q1_problem（问题1+2）
```markdown
## 问题一：论文试图解决什么问题？

（Agent 输出内容）

## 问题二：这个问题为什么重要？

（Agent 输出内容）
```

### q3_method（问题3）
```markdown
## 问题三：作者提出了什么方法？

（Agent 输出内容 - 无观点，纯论文内容）
```

### q4_technical（问题4）
```markdown
## 问题四：方法的技术细节

### 核心公式

$$公式$$

### 算法步骤

1. ...
2. ...

### 符号说明

- $x$: ...
- $y$: ...
```

### q5_experiment（问题5）
```markdown
## 问题五：实验结果与关键发现

### 主要 Benchmark 结果

### 关键洞察

### 消融实验结论
```

### q6_reflection（问题6）
```markdown
## 问题六：学习心得与思考

（必须包含 "In my opinion," 等归属标记）
```

### q7_application（问题7）
```markdown
## 问题七：如何应用到自己的研究？

（必须包含 "In my opinion," 等归属标记）
```

### glossary（核心术语表）
```markdown
## 核心术语表

- **术语1 (English)**: 定义
- **术语2 (English)**: 定义
...
```

### faq（常见疑问与解答）
```markdown
## FAQ

Q: 问题？
A: 解答

Q: 问题？
A: 解答
```

### reference（延伸阅读）
```markdown
## 延伸阅读

### 推荐1
- 相关性：...
- 推荐理由：...
- 搜索验证：已通过 web_search 验证

### 推荐2
...
```

### image（图片提取结果）
```markdown
## 图片提取结果

| 图片编号 | 描述 | 文件路径 | 状态 |
|---------|------|---------|------|
| figure_1 | ... | ./images/figure_1.png | ✅ |
| figure_2 | ... | ./images/figure_2.png | ❌ 下载失败 |

### 已成功下载的图片
（列表）
```

## 元信息（最终汇总）

```yaml
final:
  word_count: ""
  image_count: 0
  glossary_count: 0
  issues_resolved: []
  quality_check: passed/failed
```