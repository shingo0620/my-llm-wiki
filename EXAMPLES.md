# LLM Wiki — 操作範例

本文件以具體範例展示每個操作的實際流程與預期產出，幫助 LLM 理解「做對了是什麼樣子」。

---

## Init — 初始化範例

### 情境：建立一個 AI 論文研究知識庫

**使用者：** 「我想建一個知識庫來追蹤 AI 領域的重要論文」

**LLM 提問流程：**

```
1. 主題／領域 — 知識庫關於什麼？
   → 使用者回答：「AI／機器學習論文研究」

2. 專案目錄 — 建在哪裡？
   → 使用者回答：「~/wikis/ai-papers」

3. 語言 — wiki 內容使用的語言
   → 使用者回答：「繁體中文」

4. 建立目的 — 這個知識庫主要用來做什麼？
   → 使用者回答：「追蹤重要論文的核心貢獻、方法演進、以及不同方法之間的比較」

5. 預期使用者 — 誰會查閱這個知識庫？
   → 使用者回答：「只有我自己，幫助我快速回憶讀過的論文」

6. 主要來源類型 — 通常會匯入什麼？
   → 使用者回答：「學術論文 PDF、技術部落格文章、YouTube 演講」

7. 組織方式 — 你希望知識怎麼被組織？
   → 使用者回答：「按主題分類，但也要能追蹤時間線上的演變」

8. 摘要風格 — 你偏好什麼樣的摘要？
   → 使用者回答：「結構化條列，方便快速掃描」

9. 原文引用 — 需要保留來源的原文引用嗎？
   → 使用者回答：「只保留關鍵數據和定義的原文」

10. 矛盾處理 — 不同來源說法衝突時怎麼辦？
    → 使用者回答：「並列呈現，標註各自來源和發表時間」

11. 信心標注 — 需要標注資訊的可信度嗎？
    → 使用者回答：「不需要，論文本身就是證據」

12. 自訂欄位 — 你的領域有沒有每個條目都該記錄的特殊資訊？
    → 使用者回答：「論文的發表年份、引用數、所屬領域（NLP/CV/RL 等）」
```

**產出的 CLAUDE.md：**

```markdown
# LLM Wiki Schema

## 知識庫概述
- 主題：AI／機器學習論文研究
- 目的：追蹤重要論文的核心貢獻、方法演進、以及不同方法之間的比較
- 預期使用者：個人使用，快速回憶讀過的論文
- 語言：繁體中文

## 高層原則
- 組織邏輯：按主題分類為主，輔以時間線追蹤演進
- 摘要風格：結構化條列，方便快速掃描
- 知識庫調性：嚴謹的學術研究知識庫，重視方法比較與演進脈絡

## 具體指引

### 來源處理
- 主要來源類型：學術論文 PDF、技術部落格文章、YouTube 演講
- 原文引用：只保留關鍵數據和定義的原文

### 頁面結構
- 自訂欄位：year（發表年份）、citations（引用數）、domain（NLP/CV/RL 等）

### 品質控制
- 矛盾處理策略：並列呈現，標註各自來源和發表時間
- 信心標注：不使用

## 頁面類型
- **來源摘要**（source）：每個匯入來源一頁
- **實體頁**（entity）：人物、組織、產品、地點、事件
- **概念頁**（concept）：理論、方法、框架
- **綜整頁**（synthesis）：跨來源的分析與整合
- **比較頁**（comparison）：並排比較

## 規則
- raw/ 中的檔案不可修改
- 每次操作後更新 index.md 和 log.md
- 使用 [[wikilink]] 格式交叉引用
- 新資料與舊主張矛盾時，依矛盾處理策略處理
- 每個 wiki 頁面包含 YAML frontmatter
```

---

## Ingest — 匯入範例

### 範例 1：匯入一篇 PDF 論文

**使用者：** 「幫我匯入 raw/attention-is-all-you-need.pdf」

**LLM 執行流程：**

1. 讀取 CLAUDE.md Profile（確認：結構化條列、保留關鍵數據原文、自訂欄位 year/citations/domain）
2. 讀取 PDF 內容
3. 與使用者討論重點：

```
這篇論文的關鍵發現：
1. 提出 Transformer 架構，完全基於 attention mechanism，不使用 RNN/CNN
2. 在翻譯任務上達到 SOTA，訓練時間大幅縮短
3. Self-attention 能有效捕捉長距離依賴
4. Multi-head attention 允許模型同時關注不同位置的資訊

想強調哪些重點？有沒有要忽略的部分？
```

4. 產出來源摘要頁 `wiki/attention-is-all-you-need.md`：

```markdown
---
title: Attention Is All You Need
type: source
sources: [attention-is-all-you-need.pdf]
created: 2026-04-13
updated: 2026-04-13
tags: [transformer, attention, NLP]
year: 2017
citations: 120000
domain: NLP
---

# Attention Is All You Need

## 核心貢獻
- 提出 [[transformer-architecture]]，完全基於 attention mechanism
- 不使用 RNN 或 CNN，僅依賴 self-attention 與 feed-forward layers
- 訓練速度比先前 SOTA 快數倍

## 方法
- **Multi-Head Attention**：將 attention 分成多個 head，各自學習不同的表示
- **Positional Encoding**：使用正弦/餘弦函數編碼位置資訊
- **Encoder-Decoder 架構**：6 層 encoder + 6 層 decoder

## 關鍵數據
> WMT 2014 英德翻譯：28.4 BLEU（超越先前最佳 ensemble 模型）
> 訓練時間：8 GPU × 3.5 天（約 $150 美元）

## 與知識庫的關聯
- 相關概念：[[attention-mechanism]]、[[self-attention]]、[[positional-encoding]]
- 相關實體：[[google-brain]]、[[ashish-vaswani]]
- 後續發展：[[bert]]、[[gpt]]
```

5. 同時建立或更新概念頁 `wiki/transformer-architecture.md`、實體頁 `wiki/google-brain.md`
6. 更新 index.md 和 log.md

### 範例 2：匯入一個 URL

**使用者：** 「匯入這篇 https://lilianweng.github.io/posts/2023-06-23-agent/」

**LLM 執行流程：**

```bash
~/.claude/skills/llm-wiki/scripts/fetch-url.sh \
  "https://lilianweng.github.io/posts/2023-06-23-agent/" \
  "./raw"
# 輸出：./raw/llm-powered-autonomous-agents.md
```

然後以 `raw/llm-powered-autonomous-agents.md` 作為來源，執行標準 ingest 流程。

### 範例 3：匯入一個 YouTube 影片

**使用者：** 「匯入這個演講 https://www.youtube.com/watch?v=zjkBMFhNj_g」

**LLM 執行流程：**

```bash
~/.claude/skills/llm-wiki/scripts/fetch-youtube.sh \
  "https://www.youtube.com/watch?v=zjkBMFhNj_g" \
  "./raw"
# 輸出：./raw/yt-intro-to-large-language-models.md
```

然後以逐字稿作為來源，執行標準 ingest 流程。逐字稿帶有時間戳，摘要時可引用具體時間點。

---

## Query — 查詢範例

### 範例 1：一般問題

**使用者：** 「Transformer 和 RNN 的主要差異是什麼？」

**LLM 流程：**
1. 讀取 CLAUDE.md Profile（確認：結構化條列風格、個人使用語氣）
2. 讀取 index.md，找到相關頁面：`transformer-architecture.md`、`rnn.md`、`attention-is-all-you-need.md`
3. 閱讀相關頁面，整合回答

**產出：**

```
根據知識庫中 3 個來源的資訊：

| 面向 | Transformer | RNN |
|------|------------|-----|
| 平行化 | 可完全平行化訓練 | 必須循序處理 |
| 長距離依賴 | 透過 self-attention 直接連結 | 資訊需逐步傳遞，容易衰減 |
| 訓練速度 | 快（可利用 GPU 平行化） | 慢（循序瓶頸） |
| 記憶體 | O(n²)（attention matrix） | O(n)（hidden state） |

來源：[[attention-is-all-you-need]]、[[transformer-architecture]]、[[rnn]]

要把這個比較存成 wiki 頁面嗎？
```

### 範例 2：使用者同意存入 wiki

**使用者：** 「好，存起來」

**LLM 產出 `wiki/transformer-vs-rnn.md`：**

```markdown
---
title: Transformer vs RNN 比較
type: comparison
sources: [attention-is-all-you-need.md, rnn.md]
created: 2026-04-13
updated: 2026-04-13
tags: [transformer, rnn, comparison]
---

# Transformer vs RNN 比較

## 摘要
Transformer 以 self-attention 取代循序處理，在平行化和長距離依賴上有明顯優勢，但記憶體使用較高。

## 比較

| 面向 | Transformer | RNN |
|------|------------|-----|
| 平行化 | 可完全平行化訓練 | 必須循序處理 |
| 長距離依賴 | 透過 [[self-attention]] 直接連結 | 資訊需逐步傳遞，容易衰減 |
| 訓練速度 | 快 | 慢 |
| 記憶體 | O(n²) | O(n) |

## 結論
對於大多數 NLP 任務，Transformer 已成為預設選擇。RNN 在序列極長且記憶體受限的場景仍有利基。
```

---

## Lint — 健康檢查範例

**使用者：** 「檢查一下知識庫的健康狀況」

**LLM 產出：**

```
知識庫健康檢查結果（共 45 頁）：

🔴 嚴重
1. **矛盾**：[[bert]] 說 Transformer encoder 有 12 層，[[bert-large]] 說有 24 層
   → 兩者都正確，分別是 BERT-base 和 BERT-large，建議在 [[bert]] 中明確區分

🟡 注意
2. **孤立頁面**：[[positional-encoding]] 沒有任何反向連結
   → 建議在 [[transformer-architecture]] 中加入連結
3. **缺漏實體**：「Ilya Sutskever」被 5 個頁面提及但沒有獨立實體頁
   → 建議建立 [[ilya-sutskever]] 實體頁
4. **Profile 一致性**：3 個頁面有 Key Quotes 區塊，但 profile 設定為「只保留關鍵數據和定義」
   → 影響頁面：[[gpt-3]]、[[scaling-laws]]、[[chinchilla]]

🟢 建議
5. **缺少交叉引用**：[[attention-mechanism]] 和 [[self-attention]] 應互相連結
6. **資料缺口**：知識庫有 15 篇 NLP 論文但只有 2 篇 CV 論文，考慮補充 ViT、CLIP 等
7. **建議問題**：「scaling laws 在不同模型架構之間是否一致？」值得做成綜整頁

要修正哪些項目？
```

---

## 更新模式範例

**使用者：** 對已初始化的知識庫再次執行 `/llm-wiki init`

**LLM 展示：**

```
偵測到已初始化的知識庫，進入更新模式。

目前知識庫設定：
1. 主題：AI／機器學習論文研究
2. 目的：追蹤重要論文的核心貢獻、方法演進
3. 語言：繁體中文
4. 摘要風格：結構化條列
5. 原文引用：只保留關鍵數據和定義
6. 組織方式：按主題分類，輔以時間線
7. 矛盾處理：並列呈現，標註來源和時間
8. 信心標注：不使用
9. 自訂欄位：year、citations、domain

要修改哪些項目？（輸入編號，或「全部重新設定」）
```

**使用者：** 「4, 9」

**LLM：** 分別重新詢問第 4 和第 9 項，附帶範例答案，更新 CLAUDE.md 對應區塊。
