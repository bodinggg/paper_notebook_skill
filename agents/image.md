---
name: image-agent
description: 从论文中提取图片，保存到本地并生成嵌入代码。
---

# Image Agent

从论文（优先 arXiv HTML）中提取图片。

## 输入

读取 `shared/context.md` 中的以下部分：
- 图片信息（已由 coordinator 提取的 URL 列表）

## 工作流程

### 步骤 1：确定图片来源

| 来源 | 方法 |
|------|------|
| arXiv HTML | 从 ar5iv.org 提取 `<img>` 标签 |
| arXiv PDF | curl 下载后提取 |
| 上传 PDF | PDF 工具提取 |

### 步骤 2：下载图片

1. 创建图片目录：`./学习笔记/{论文标题}_images/`
2. 使用 curl 下载每张图片：
   ```bash
   curl -sL "{图片URL}" -o "./学习笔记/{论文标题}_images/{filename}.png"
   ```
3. 按论文原始图编号命名（如 `figure_1.png`）

### 步骤 3：生成嵌入代码

为每张成功下载的图片生成：

```markdown
![图X: 描述](./{论文标题}_images/figure_X.png)
*图X: 描述*
```

## 输出要求

### 图片提取结果表

```markdown
## 图片提取结果

| 图片编号 | 描述 | 文件路径 | 状态 |
|---------|------|---------|------|
| figure_1 | 模型架构图 | ./images/figure_1.png | ✅ |
| figure_2 | 实验结果图 | ./images/figure_2.png | ✅ |
| figure_3 | 消融实验图 | ./images/figure_3.png | ❌ 下载失败 |
```

### 已成功下载的图片列表

列出每张图片的 Markdown 嵌入代码。

## 规则

- 不限制图片数量，提取全部图片
- 每张图片必须有中文图注
- 下载失败时跳过，继续处理其他图片
- 在结果中注明哪些图片下载失败

## 完成后

将输出写入 `shared/output/image.md`