# Wiki 頁面慣例

本文件定義 LLM Wiki 中各類頁面的格式、命名與組織規範。

## 頁面類型

### 來源摘要（source）

每匯入一個來源就建立一頁。

```markdown
---
title: 來源標題
type: source
sources: [原始檔名.md]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [相關標籤]
---

# 來源標題

**作者**：xxx
**日期**：xxx
**原始連結**：xxx（如有）

## 核心主張

- 重點 1
- 重點 2
- 重點 3

## 詳細摘要

（結構化摘要，保留來源的重要論述與數據）

## 關鍵引用

> 值得保留的原文引用

## 與 Wiki 的關聯

- 支持 [[概念A]] 的論點
- 與 [[來源B]] 的主張矛盾（見 [[來源B#某段]]）
- 新增了關於 [[實體C]] 的資訊
```

### 實體頁（entity）

關於具體事物——人物、組織、產品、地點、事件。

```markdown
---
title: 實體名稱
type: entity
sources: [提及此實體的來源列表]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [相關標籤]
---

# 實體名稱

（一段簡短描述）

## 基本資訊

（依實體類型而異——人物有背景、組織有成立資訊等）

## 在各來源中的角色

- [[來源A]]：在此脈絡中的角色或提及
- [[來源B]]：另一個脈絡

## 相關實體

- [[實體X]]：關係描述
- [[實體Y]]：關係描述

## 相關概念

- [[概念A]]：與此實體的關聯
```

### 概念頁（concept）

抽象概念、理論、方法、框架。

```markdown
---
title: 概念名稱
type: concept
sources: [討論此概念的來源列表]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [相關標籤]
---

# 概念名稱

## 定義

（清晰的定義）

## 不同觀點

- [[來源A]] 認為：...
- [[來源B]] 認為：...
（若有矛盾，明確標註）

## 相關概念

- [[概念X]]：關係描述
- [[概念Y]]：關係描述

## 應用與案例

（實際應用或具體案例）
```

### 綜整頁（synthesis）

整合多個來源或頁面的分析。通常由 query 操作產生。

```markdown
---
title: 分析標題
type: synthesis
sources: [涉及的來源列表]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [相關標籤]
---

# 分析標題

## 背景

（為什麼做這個分析）

## 主要發現

### 發現 1
（論述，附帶來源引用）

### 發現 2
（論述，附帶來源引用）

## 跨來源模式

（不同來源之間觀察到的共通趨勢）

## 矛盾與未解問題

（各來源之間的衝突點，以及尚無定論的問題）

## 結論

（綜合判斷）
```

### 比較頁（comparison）

並排比較兩個或多個事物。

```markdown
---
title: A vs B（或多項比較標題）
type: comparison
sources: [涉及的來源列表]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [相關標籤]
---

# 比較：A vs B

## 比較摘要

（一段文字概述差異）

## 維度比較

| 維度 | A | B |
|------|---|---|
| 維度 1 | ... | ... |
| 維度 2 | ... | ... |

## 分析

（對比較結果的解讀）

## 結論與建議

（依情境不同的選擇建議）
```

## 檔名慣例

- 使用 kebab-case：`knowledge-management.md`、`attention-mechanism.md`
- 來源摘要檔名反映來源標題：`attention-is-all-you-need.md`
- 實體頁用實體名稱：`openai.md`、`geoffrey-hinton.md`
- 概念頁用概念名稱：`transformer-architecture.md`
- 綜整頁可用描述性名稱：`llm-scaling-laws-analysis.md`
- 比較頁：`gpt4-vs-claude3.md`

## 交叉引用規則

使用 Obsidian 風格 wikilink：

- 基本連結：`[[頁面名稱]]`
- 帶顯示文字：`[[頁面名稱|顯示文字]]`
- 連結到標題：`[[頁面名稱#標題]]`

### 何時加入交叉引用

- 首次在頁面中提到另一個已存在的 wiki 頁面時
- 建立新頁面後，回到提及該主題的既有頁面加入連結
- 發現兩個頁面有因果、對比、補充關係時

### 反向連結

不需要手動維護反向連結清單——Obsidian 會自動顯示。但在「相關實體」或「相關概念」區段主動列出有意義的關聯仍然有價值，因為它捕捉的是關係的性質，不只是連結的存在。

## Index 維護

`wiki/index.md` 按類別組織：

```markdown
# 索引

## 來源摘要
- [[attention-is-all-you-need]] — Transformer 架構原始論文（來源數：1）
- [[scaling-laws-for-neural-lm]] — 神經語言模型的 scaling law（來源數：1）

## 實體
- [[openai]] — AI 研究公司（來源數：3）
- [[geoffrey-hinton]] — 深度學習先驅（來源數：2）

## 概念
- [[transformer-architecture]] — 基於 attention 的序列模型架構（來源數：4）
- [[scaling-law]] — 模型規模與效能的冪次律關係（來源數：2）

## 綜整與分析
- [[llm-scaling-debate]] — 關於 scaling 是否足夠的多方觀點整理（來源數：5）
```

每個條目一行，包含：
1. wikilink 到頁面
2. 一行摘要（簡短、具描述性）
3. 來源數量（幫助判斷資訊的厚度）

每次匯入、查詢產出新頁、或 lint 修正後，都必須同步更新 index。

## Log 維護

`wiki/log.md` 是僅追加的操作紀錄：

```markdown
## [2026-04-12] ingest | Attention Is All You Need
- 建立來源摘要：[[attention-is-all-you-need]]
- 建立概念頁：[[transformer-architecture]], [[self-attention]]
- 更新實體頁：[[google-brain]]
- 更新索引

## [2026-04-12] query | Transformer 與 RNN 的比較
- 建立比較頁：[[transformer-vs-rnn]]
- 更新索引
```

以一致前綴開頭，方便用指令解析：
```bash
grep "^## \[" wiki/log.md | tail -5
```

## 品質標準

1. **有據可查**：每個主張都應能追溯到具體來源
2. **矛盾透明**：不同來源的衝突主張要明確標記，不要靜默選邊
3. **時效標記**：過時資訊用 ~~刪除線~~ 標記，附上更新資訊的來源
4. **一致性優先**：頁面之間的一致性比單一頁面的完美更重要
5. **適度詳細**：摘要保留足夠細節以便理解，但不要照抄全文
