# for_hdat9800 — HDAT9800 健康数据科学博客

UNSW HDAT9800（Term 2 2026）课程博客。技术栈：**R Markdown + Distill + GitHub Pages**。

- **线上地址**：https://liketocood345.github.io/for_hdat9800/
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

### 2026-06-05 — 初始化

- 用 `distill::create_blog(gh_pages = TRUE)` 创建博客骨架
- 配置 `base_url`、`.nojekyll`、`output_dir: docs`
- 首次 push 至 https://github.com/liketocood345/for_hdat9800

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
- 底部注明：因账号内有其他公共项目，暂不公布个人信息

### 2026-06-05 — 站点英文默认

- 导航、首页、About 页等访客可见文案改为英文（Overview / About Me）
- `_site.yml` 站点标题改为 `HDAT9800 Blog`，移除导航占位符
- 首篇博文标题 **「测试」** 保留中文，作为站点支持 CJK 字符的示例

### 2026-06-05 — 「测试」标题栏徽章图

- 将截图保存为 `_posts/2026-06-05-test/title-badge.png`
- 首页列表：在「测试」标题末尾追加徽章图
- 博文页：在 `d-title` 标题末尾追加同一徽章图

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

### 待办（可选）

- [ ] Build 后脚本自动生成 `llms.txt`、`robots.txt`、`content/index.json`
- [ ] 将占位符替换为正式站点文案
- [ ] 基于 `9800/1.R` 撰写第一篇 ggplot2 课程博文

---

## 本地开发

```r
setwd("e:/HDAT9800/for_hdat9800")
rmarkdown::render_site()
```

RStudio：**Build → Build Website**

新建博文：

```r
distill::create_post("your-slug")
```
