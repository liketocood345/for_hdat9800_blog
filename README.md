# for_hdat9800_blog — HDAT9800 健康数据科学博客

UNSW HDAT9800（Term 2 2026）课程博客。技术栈：**R Markdown + Distill + GitHub Pages**。

| 项 | 路径 |
|---|---|
| **GitHub 仓库** | [liketocood345/for_hdat9800_blog](https://github.com/liketocood345/for_hdat9800_blog) |
| **GitHub Pages** | https://liketocood345.github.io/for_hdat9800_blog/ |
| **本地工作目录** | `e:\HDAT9800\for_hdat9800\`（文件夹名未改，与远程仓库 slug 可不同） |

- **默认首页**：总览（`index.html`），进入站点即显示全部博文列表

---

## 设计说明

### 目标

1. 满足课程 Week 2 要求：用 Distill 搭建可发布的健康数据科学博客
2. 人类访客：简洁可读的文章列表与博文页
3. 机器检索（爬虫 / AI Agent）：优先使用 JSON / 源码，避免解析厚重 HTML（见「机器可读层」）

### 信息架构

```text
index.html（总览，默认首页）  →  listing: posts，新闻式罗列全部博文
about.html（关于）            →  站点说明
posts/YYYY-MM-DD-slug/        →  单篇博文
```

### 博文格式（默认）

每篇正式博文与本地工作区 `blogN-*` 文件夹对应。

**语言（两阶段）**

| 阶段 | 默认语言 | 规则文件 |
|------|----------|----------|
| 发布前（规划、本地源稿、改稿） | **中文为主** | `pre-publish-chinese-default` |
| 正式发布（`_posts/` → build → push） | **英文**（访客可见） | `english-default-site-content` |

发布前英文仅用于：技术关键词（如 `ggplot2`、`BIND`）、专名（仓库 slug、`blogN-` 前缀）、用户指定段落。上线前再将标题/正文译为英文写入 Rmd，除非用户要求中文发布。

| 字段 | YAML 键 | 规则 |
|------|---------|------|
| 标题 | `title` | **发布用**英文；规划阶段可用中文标题 + 「发布译名」列 |
| 副标题 | `description` | **默认以 `blogN-` 开头**；发布用英文；规划阶段可用中文描述 |
| 作者 | `author` | `name` + `url`（GitHub） |
| 日期 | `date` | `YYYY-MM-DD`；文件夹名前缀与之对齐 |
| 目录 | `_posts/` | `YYYY-MM-DD-slug/slug.qmd`（或 `.Rmd`）；`slug` 小写、连字符 |
| 草稿 | `draft: true` | QMD 博文未发布前保留；`render-qmd-posts.ps1` 默认跳过 |

**副标题在 Distill 中的位置**

- Overview 列表：标题下方摘要段落
- 博文页：元数据 / OG / `posts.json` 的 `description`
- 正文开头可用一行斜体重复副标题核心句（可选，不与 YAML 矛盾即可）

**本地源稿与仓库**

- 工作区：`e:/HDAT9800/blogN-<topic>/` 内用**中文**撰写、迭代（如 `blog0-…`、`blog1-ggplot2/`）
- 发布：整理/翻译为 `_posts/` 下英文 **`.qmd`**（推荐，blog1 起）或 `.Rmd`，Build 后 `docs/` 随 commit 推送

**其他格式约束**

- 多媒体：见下文「多媒体容器」；禁止正文裸放 `iframe` / `video` / `img`
- 大视频：外链嵌入；仓库默认不用 Git LFS
- About 页：导航栏不显示指向自身的 About Me 链接（`theme.css`）

**新建博文 YAML 模板**

**Quarto QMD（推荐 · blog1 起）** — 共享格式见 `_posts/_metadata.yml`（`theme.css`、`favicon.html`）：

```yaml
---
title: "Your English Title"
description: |
  blog1-Your one-line subtitle here.
author:
  - name: "liketocood345"
    url: "https://github.com/liketocood345"
date: 2026-06-08
draft: true   # 本地预览用；发布前删除或改为 false
---
```

**R Markdown（blog0 等既有稿）**：

```yaml
---
title: "Your English Title"
description: |
  blog0-Your one-line subtitle here.
author:
  - name: "liketocood345"
    url: "https://github.com/liketocood345"
date: 2026-06-06
output:
  distill::distill_article:
    self_contained: false
---
```

**QMD 源文件编码**：保存为 **UTF-8（无 BOM）**。若 `quarto render` 报 YAML/`format` 异常，用 PowerShell 重写：`Get-Content file.qmd -Encoding UTF8 | Set-Content -Encoding utf8 file.qmd`。

### 目录结构

```text
for_hdat9800/
├── README.md              # 本文件：设计与改动记录
├── _site.yml              # Distill 全站配置（标题、导航、base_url、输出目录）
├── index.Rmd              # 总览页（默认首页，listing: posts）
├── about.Rmd              # 关于页
├── .nojekyll              # GitHub Pages 必需
├── .gitignore
├── _posts/                # 博文源文件（每篇一个文件夹 + .Rmd）
│   └── YYYY-MM-DD-slug/
│       └── slug.Rmd
└── docs/                  # Build 产物（GitHub Pages 发布此目录）
    ├── index.html
    ├── posts/posts.json   # 机器可读：全文纯文本索引
    ├── search.json
    ├── sitemap.xml
    └── overview.xml       # RSS（Build 时由 listing 页生成）
```

### 发布流程

```text
编辑 .Rmd → Build Website（render_site）→ git commit → git push → GitHub Pages 更新
```

- **输出目录**：`docs/`（`_site.yml` 中 `output_dir: "docs"`）
- **GitHub Pages 设置**：`main` 分支，`/docs` 文件夹
- **认证**：HTTPS + PAT（课程推荐）；不使用 Cursor 签名提交

### 多媒体容器（默认格式）

所有访客可见的多媒体（Bilibili / YouTube iframe、`<video>`、配图、音频）**必须**放在三类容器内，禁止正文裸放：

| 类名 | 最大宽度 | 典型用途 |
|------|----------|----------|
| `media-container media-container--large` | 960px | 主视频、大图 |
| `media-container media-container--medium` | 640px | 正文内嵌视频 |
| `media-container media-container--small` | 400px | 缩略剪辑、小图 |

可复制 `_templates/media-container-snippets.Rmd` 中的 `{=html}` 片段。样式在 `theme.css`（全站通过 `favicon.html` 外链 `/for_hdat9800_blog/theme.css`，避免博文页内联样式过期）；裸 `iframe` / `video` 会显示虚线边框提示。

### 媒体与 Git LFS（默认不用）

本机可安装 **Git LFS**；本仓库**默认不走 LFS**（GitHub 免费 LFS 约 1 GB，不适合当默认视频仓库）。

| 类型 | 默认做法 |
|------|----------|
| 长视频 / 录屏 | YouTube（或同类）`<iframe>` 嵌入 |
| 照片、小 GIF、PNG | 普通提交，与 `.Rmd` 同目录 |
| 短视频自托管 | 仅极小文件（建议 < 10–20 MB）；否则用外链 |
| Git LFS | **不启用**，除非你明确要求并知晓配额 |

仓库内**不要**添加 `git lfs track` 或含 `filter=lfs` 的 `.gitattributes`，除非有意开启 LFS。

### 机器可读层（不影响页面外观）

| 端点 | 用途 |
|------|------|
| `posts/posts.json` | 博文标题、日期、纯文本 `contents` |
| `search.json` | 全站页面索引 |
| `sitemap.xml` | 爬虫 URL 地图 |
| GitHub `_posts/*.Rmd` raw | 可复现源码，Token 最省 |

建议 Agent 检索顺序：`posts.json` → GitHub raw `.Rmd` → 避免整页 HTML。

### 导航

| 标签 | 文件 | 说明 |
|------|------|------|
| Overview | `index.html` | 默认首页，文章列表 |
| About Me | `about.html` | GitHub 简介与隐私说明 |

---

## 改动记录

### 2026-06-09 — GitHub 仓库重命名

- 远程仓库由 `for_hdat9800` 更名为 [`for_hdat9800_blog`](https://github.com/liketocood345/for_hdat9800_blog)
- Pages 根路径同步为 `https://liketocood345.github.io/for_hdat9800_blog/`
- 更新 `_site.yml` `base_url`、`favicon.html` 绝对路径、博文内外链、`origin` remote
- **本地目录**仍为 `e:\HDAT9800\for_hdat9800\`（仅远程 slug 变更）

### 2026-06-05 — 初始化

- 用 `distill::create_blog(gh_pages = TRUE)` 创建博客骨架
- 配置 `base_url`、`.nojekyll`、`output_dir: docs`
- 首次 push 至 https://github.com/liketocood345/for_hdat9800_blog

### 2026-06-05 — 第一篇博文「测试」

- 新增 `_posts/2026-06-05-test/test.Rmd`
- 各页面文本位使用占位符 `<=test_place_holder=>`
- 删除示例 `welcome` 博文

### 2026-06-05 — 总览页（曾独立为 overview.html）

- 新增 `overview.Rmd`，`listing: posts` 新闻式列表
- 首页改为简短欢迎语，总览单独一页

### 2026-06-05 — 总览设为默认首页

- 将 `listing: posts` 合并到 `index.Rmd`，访问根路径即显示总览
- 删除 `overview.Rmd`，导航「总览」指向 `index.html`
- 新增本 `README.md`，集中记录设计与改动

### 2026-06-05 — 「关于我」页面

- 导航右上角设为「关于我」→ `about.html`
- 页面展示 GitHub 头像与账号名 `liketocood345`
- 底部注明：因账号另有其他公共仓库，暂不公开个人信息（About 页为英文）

### 2026-06-05 — 站点英文默认

- 导航、首页、About 页等访客可见文案改为英文（Overview / About Me）
- `_site.yml` 站点标题改为 `HDAT9800 Blog`，移除导航占位符
- 首篇博文标题 **「测试」** 保留中文，作为站点支持 CJK 字符的示例

### 2026-06-05 — 「测试」标题栏徽章图

- 将截图保存为 `_posts/2026-06-05-test/title-badge.png`
- 首页列表：在「测试」标题末尾追加徽章图
- 博文页：在 `d-title` 标题末尾追加同一徽章图

### 2026-06-05 — 多媒体容器大中小（默认格式）

- `theme.css` 新增 `.media-container--large|medium|small`（960 / 640 / 400px）
- 多媒体仅允许放在容器内；裸 iframe/video 虚线提示
- 片段模板：`_templates/media-container-snippets.Rmd`；规则：`.cursor/rules/media-container-format.mdc`
- 「测试2视频外链」示范三种尺寸各一

### 2026-06-05 — 博文「测试2视频外链」

- 新增 `_posts/2026-06-05-test2-video-link/test2-video-link.Rmd`
- 标题中文 **测试2视频外链**；正文 `test_video_link` + Bilibili 嵌入（BV19W7C64EcK）

### 2026-06-05 — 媒体策略：保留 LFS 工具，仓库默认不用

- 本机可保留 Git LFS；`for_hdat9800` 默认不 `git lfs track`
- 大视频优先外链嵌入；小图/GIF 普通提交
- 项目规则：`.cursor/rules/no-default-git-lfs.mdc`

### 2026-06-05 — Overview 自定义顶栏（仅首页）

- 几何装饰放大为 `overview-topbar`，取代 Overview 页默认 Distill 顶栏
- 左侧保留 **HDAT9800 Blog**；圆内放大镜 + 可展开搜索；右侧方框内 **About Me**
- 去掉 Overview 页重复的 Overview 导航项；博文详情页仍用默认顶栏

### 2026-06-05 — 修复 About 页与首页徽章显示

- About 页改用 `{=html}` 块，避免 Pandoc 破坏头像布局；恢复中文隐私说明
- 首页徽章由 JS 改为 `theme.css` 的 `::after`（Distill 重渲染后不再丢失）
- 博文页徽章改为文内 `<style>` + `::after`，不依赖 `DOMContentLoaded` 时机

### 2026-06-05 — 首页视觉（简历设计风格）

- 从本地 CV docx **仅提取**配色与几何语言（深蓝侧栏 + 浅蓝底 + 矩形/圆/横条），**未**写入简历正文或联系方式
- 新增 `theme.css`；`index.Rmd` 增加 `cv-home-deco` 几何装饰区
- 色板：`#213347` `#2D4B6A` `#334E6C` `#D7E1ED` `#DEEBF6`

### 2026-06-06 — 首篇实质博文：skill merge 作为学习方法

- 新增 `_posts/2026-06-06-skill-merge-fastest-way-to-learn/` — **Guiding One Skill Merge Is the Fastest Way to Learn**
- 英文正文；源稿 `blog0-skill_merge_is_the_best_way_to_learn/guided-skill-merge-fastest-way-to-learn.en.md`
- About 页隐私说明改为英文（与站点默认语言一致）
- Build 后 Overview 列表置顶显示该文

### 2026-06-06 — 发布前中文默认

- 新规则：`.cursor/rules/pre-publish-chinese-default.mdc`
- 发布前（规划、本地源稿、改稿）中文为主；英文仅关键词/专名/用户指定
- 正式发布 push Pages 仍默认英文（`english-default-site-content` 已补充两阶段说明）
- README「博文格式」增加语言两阶段表

### 2026-06-08 — Quarto QMD 支持 + blog1 草稿

- 安装 **Quarto CLI**（`winget install Posit.Quarto`）
- 新增 `_posts/_metadata.yml`（QMD 博文共享 `distill::distill_article` + `theme.css`）
- 新增 `tools/render-qmd-posts.ps1`、`tools/sync-qmd-post-to-docs.ps1`、`tools/build-website.ps1`
- 新增 `_templates/media-container-snippets.qmd`
- blog1：`_posts/2026-06-08-ggplot-hourglass-four-skill-fusion/ggplot-hourglass-four-skill-fusion.qmd`，**`draft: true`（暂不发布）**

### 2026-06-06 — 博文格式约定与 blog0 副标题

- README 新增「博文格式（默认）」：`description` 副标题默认以 `blogN-` 开头
- blog0 副标题更新为 `blog0-One merge is both study and the creation of a reusable AI asset—two birds, one stone.`
- About 页隐藏导航栏冗余 About Me 自链（`theme.css`）

### 待办（可选）

- [ ] Build 后脚本自动生成 `llms.txt`、`robots.txt`、`content/index.json`
- [ ] 将占位符替换为正式站点文案
- [ ] 基于 `9800/1.R` 撰写 ggplot2 课程博文

---

## 本地开发

**混合构建**（Rmd 站点页 + QMD 博文）：

```powershell
cd e:\HDAT9800\for_hdat9800
.\tools\build-website.ps1
```

或分步：

| 步骤 | 命令 | 说明 |
|------|------|------|
| QMD 博文 | `.\tools\render-qmd-posts.ps1` | 经 **rmarkdown + distill** 渲染；默认跳过 `draft: true` |
| 草稿预览 | `.\tools\render-qmd-posts.ps1 -IncludeDrafts` | 含草稿 |
| 全站 | `.\tools\build-website.ps1` | `render_site()` 会一并处理带 `output: distill::distill_article` 的 QMD |
| Rmd 全站 | `Rscript -e "rmarkdown::render_site()"` | index / about / 旧 Rmd 博文 |

发布 QMD 博文时：在 YAML 写 `output: distill::distill_article`（勿用 `quarto render` 裸 HTML）→ 去掉 `draft: true` → `.\tools\build-website.ps1` 或 `render_site()`。

RStudio：**Build → Build Website**（仅 Rmd 路径；QMD 用上方脚本）。

新建博文：

```r
distill::create_post("your-slug")   # Rmd 传统
```

QMD 新建：复制 `_posts/YYYY-MM-DD-slug/` 目录 + `slug.qmd` + 可选 `assets/`。
