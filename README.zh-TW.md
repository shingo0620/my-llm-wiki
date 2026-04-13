# LLM Wiki

一個 Claude Code skill，用於建立與維護個人知識庫——以結構化、彼此連結的 Markdown 檔案組成。

不同於 RAG 每次查詢都重新擷取，LLM Wiki 將知識整理一次、持續更新，產生複利效果。

## 運作方式

**你** 挑選來源、引導分析、提出問題。
**LLM** 摘要、交叉引用、歸檔、整理與維護。

## 指令

| 指令 | 說明 |
|------|------|
| `/llm-wiki init` | 初始化新的知識庫 |
| `/llm-wiki ingest` | 匯入來源，建立與更新 wiki 頁面 |
| `/llm-wiki query` | 查詢知識庫 |
| `/llm-wiki lint` | 健康檢查與維護 |

## 支援的來源類型

LLM Wiki 可匯入三種來源：

| 類型 | 方式 |
|------|------|
| **檔案** | 放入 `raw/` 目錄（PDF、Markdown、圖片、純文字） |
| **URL** | 透過 [markdown.new](https://markdown.new) API 自動擷取網頁 |
| **YouTube** | 透過 `youtube-transcript-api` 自動擷取逐字稿 |

## 知識庫結構

```
my-knowledge-base/
├── raw/                  # 原始來源檔案（不可變，LLM 只讀不改）
│   └── assets/           # 圖片與附件
├── wiki/                 # LLM 生成與維護的 Markdown 頁面
│   ├── index.md          # 自動維護的內容索引
│   └── log.md            # 僅追加的操作日誌
└── CLAUDE.md             # 知識庫 Profile 與 schema 設定
```

## 主要功能

### 結構化初始化（12 題 Profile 問卷）

`init` 會依序詢問 12 個問題（每題附範例答案），分為 4 大類：

- **基本資訊** — 主題、目錄、語言
- **目的與使用場景** — 建立目的、預期使用者
- **整理邏輯與偏好** — 組織方式、摘要風格、原文引用策略
- **品質標準** — 矛盾處理、信心標注、自訂欄位

回答會存入 `CLAUDE.md`，以雙層架構（高層原則 + 具體指引）指導後續所有操作。

重新執行 `init` 會進入**更新模式**——可局部修改既有設定，不需從頭來過。

### Profile 感知操作

每個操作執行前都會先讀取 `CLAUDE.md`：

- **Ingest** 依據 profile 調整摘要長度、引用策略、自訂欄位、矛盾處理
- **Query** 依據 profile 調整回答深度、語氣、搜尋策略
- **Lint** 檢查頁面是否與 profile 設定一致

### Wiki 頁面類型

| 類型 | 說明 |
|------|------|
| **來源摘要**（source） | 每個匯入來源一頁 |
| **實體頁**（entity） | 人物、組織、產品、地點、事件 |
| **概念頁**（concept） | 理論、方法、框架 |
| **綜整頁**（synthesis） | 跨來源的分析與整合 |
| **比較頁**（comparison） | 並排比較 |

頁面使用 `[[wikilinks]]` 進行交叉引用。推薦使用 [Obsidian](https://obsidian.md) 瀏覽。

## 安裝

### 方式一：npx skills add（推薦）

```bash
# 全域安裝
npx skills add shingo0620/my-llm-wiki -g -y

# 或只安裝到當前專案
npx skills add shingo0620/my-llm-wiki -y
```

### 方式二：Git clone

```bash
git clone git@github.com:shingo0620/my-llm-wiki.git ~/.claude/skills/llm-wiki
```

### 方式三：Claude Code plugin

```bash
claude plugin add shingo0620/my-llm-wiki
```

### 驗證安裝

在 Claude Code session 中輸入 `/llm-wiki`，如果 skill 載入成功就代表安裝完成。然後執行 `/llm-wiki init` 建立第一個知識庫。

### 前置需求

| 依賴 | 用途 | 備註 |
|------|------|------|
| **Python 3** | 擷取腳本 | macOS/Linux 通常已預裝 |
| **curl** | URL 擷取（markdown.new） | 通常已預裝 |
| **youtube-transcript-api** | YouTube 擷取 | 首次使用時自動安裝（透過 `pip` 或 `uv`） |

### 快速開始

```bash
# 1. 安裝 skill
npx skills add shingo0620/my-llm-wiki -g -y

# 2. 開啟 Claude Code，初始化知識庫
#    輸入：/llm-wiki init

# 3. 放入來源檔案或提供 URL
#    輸入：/llm-wiki ingest

# 4. 查詢知識庫
#    輸入：/llm-wiki query

# 5. 定期健康檢查
#    輸入：/llm-wiki lint
```

## 腳本

| 腳本 | 用法 |
|------|------|
| `scripts/fetch-url.sh` | `./fetch-url.sh <URL> <輸出目錄>` |
| `scripts/fetch-youtube.sh` | `./fetch-youtube.sh <YouTube URL> <輸出目錄>` |

兩個腳本成功時會印出儲存的檔案路徑。檔案開頭自動包含 metadata（`source-url`、`title`、`fetched` 日期）。

## 檔案結構

```
llm-wiki/
├── .claude-plugin/
│   ├── plugin.json          # Plugin metadata
│   └── marketplace.json     # Marketplace 註冊資訊
├── SKILL.md                 # Skill 定義檔（主要指令集）
├── EXAMPLES.md              # 操作範例（init/ingest/query/lint 實際流程展示）
├── README.md                # 英文說明
├── README.zh-TW.md          # 繁體中文說明（本檔案）
├── scripts/
│   ├── fetch-url.sh         # URL → Markdown 擷取腳本
│   └── fetch-youtube.sh     # YouTube → 逐字稿擷取腳本
└── references/
    └── conventions.md       # 頁面格式規範與模板
```

## 參考來源與設計靈感

### 原始構想：Andrej Karpathy 的 LLM Wiki

本專案的原始概念與架構來自 [Andrej Karpathy 撰寫的 LLM Wiki 完整構想文件](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)。該文件確立了三層架構（原始來源 → wiki 頁面 → schema）、四個核心操作（init、ingest、query、lint），以及根本哲學：

> "The human's job is to curate sources, direct analysis, ask good questions. The LLM's job is everything else."
> （人類的工作是策展來源、引導分析、提出好問題。其他所有事情都是 LLM 的工作。）

本專案實作了 Karpathy 文件中的關鍵設計：
- **不可變的原始來源** — LLM 只讀不改原始資料
- **LLM 擁有的 wiki** — LLM 生成、更新、維護所有 wiki 頁面
- **Schema 驅動** — 設定文件定義結構與慣例
- **複利型產物** — wiki 隨每個來源越來越豐富，不同於 RAG 每次從零開始
- **矛盾作為功能** — 不同來源的衝突主張被明確標記，而非靜默解決

### 延伸靈感

- [Simon Willison's Weblog](https://simonwillison.net/) — 大量關於 LLM 實務工作流程與個人知識管理的文章

### Wiki 結構與 Obsidian 相容性

頁面格式（YAML frontmatter、`[[wikilinks]]`、kebab-case 檔名）設計為與 [Obsidian](https://obsidian.md) 相容，可直接使用知識圖譜視覺化與雙向連結。五種頁面類型（source、entity、concept、synthesis、comparison）借鑑了成熟的知識管理分類法，特別是 [Zettelkasten 方法](https://zettelkasten.de/introduction/)——但適配為 LLM 驅動的策展模式，而非人工逐筆建卡。

### Profile 驅動行為

在 `CLAUDE.md` 中以結構化 profile 指導所有後續操作，這個概念受 Claude Code 自身 `CLAUDE.md` 慣例的啟發——專案層級指令塑造 agent 行為。我們將其擴展為雙層設計（高層原則 + 具體指引），參考了 John Searle 制度性現實理論中 *構成性規則*（系統是什麼）與 *調節性規則*（系統怎麼運作）的區分。

### 來源擷取管線

- **URL 擷取**透過 [markdown.new](https://markdown.new) — Firecrawl 提供的免費 API，將網頁轉換為乾淨的 Markdown，避免原始 HTML 的雜訊
- **YouTube 逐字稿**透過 [youtube-transcript-api](https://github.com/jdepoix/youtube-transcript-api) — 輕量 Python 套件，直接取得自動生成或手動上傳的字幕，不需 YouTube Data API 金鑰
- 「擷取 → 存入 `raw/` → 匯入」的管線遵循**不可變來源資料**原則：原始輸入永不修改，只讀取。這借鏡了軟體架構中的 Event Sourcing 模式

### 矛盾作為功能

明確標記來源之間的矛盾（而非靜默解決）的設計決策，受到[黑格爾辯證法](https://plato.stanford.edu/entries/hegel-dialectics/)和情報分析中 ACH（競爭假設分析）方法論的影響。矛盾本身就是有價值的資訊——它揭示了知識在哪些地方是有爭議的、正在演變的、或依賴脈絡的。

### Plugin 結構

`.claude-plugin/` 封裝遵循 [Claude Code plugin 規範](https://docs.anthropic.com/en/docs/claude-code/plugins)，參考了 [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) 等專案的模式。

## 授權

MIT
