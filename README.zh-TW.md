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

### 作為 Claude Code skill

```bash
# 複製到 skills 目錄
cp -r llm-wiki ~/.claude/skills/

# 或直接 clone
git clone git@github.com:shingo0620/my-llm-wiki.git ~/.claude/skills/llm-wiki
```

### 依賴

- **Python 3** — 擷取腳本需要
- **curl** — markdown.new API 需要
- **youtube-transcript-api** — 首次匯入 YouTube 時自動安裝

## 腳本

| 腳本 | 用法 |
|------|------|
| `scripts/fetch-url.sh` | `./fetch-url.sh <URL> <輸出目錄>` |
| `scripts/fetch-youtube.sh` | `./fetch-youtube.sh <YouTube URL> <輸出目錄>` |

兩個腳本成功時會印出儲存的檔案路徑。檔案開頭自動包含 metadata（`source-url`、`title`、`fetched` 日期）。

## 檔案結構

```
llm-wiki/
├── SKILL.md                 # Skill 定義檔（主要指令集）
├── README.md                # 英文說明
├── README.zh-TW.md          # 繁體中文說明（本檔案）
├── scripts/
│   ├── fetch-url.sh         # URL → Markdown 擷取腳本
│   └── fetch-youtube.sh     # YouTube → 逐字稿擷取腳本
└── references/
    └── conventions.md       # 頁面格式規範與模板
```

## 授權

MIT
