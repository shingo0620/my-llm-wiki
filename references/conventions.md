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

## 我的觀點

（由內化機制三段式產出，dated subheading 累加。詳見 [`references/internalization.md`](internalization.md) 與本檔「`## 我的觀點` 區塊格式」段落）
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

## 我的觀點

（由內化機制三段式產出，dated subheading 累加。詳見 [`references/internalization.md`](internalization.md) 與本檔「`## 我的觀點` 區塊格式」段落）
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

## 我的觀點

（由內化機制三段式產出，dated subheading 累加。詳見 [`references/internalization.md`](internalization.md) 與本檔「`## 我的觀點` 區塊格式」段落）
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

## 比較
- [[gpt4-vs-claude3]] — GPT-4 與 Claude 3 的能力比較（來源數：3）
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

### reflect op 格式

每次完成思考環節（不論 ingest 或 query 觸發）都在 log.md 追加：

```markdown
## [YYYY-MM-DD] reflect | <來源或綜整頁標題>
- <來源頁 / 綜整頁>：[[頁面名稱]]
- 主張數：N（X 同意、Y 部分同意、Z 反對 / 存疑）
- 紅隊回合：M（一行描述紅隊論點要旨與使用者回應方向）
- 觸發於：<ingest / query>
```

範例：

```markdown
## [2026-05-18] reflect | Attention Is All You Need
- 來源頁：[[attention-is-all-you-need]]
- 主張數：3（2 同意、1 部分同意、0 反對）
- 紅隊回合：1（接受批評，校準了 BLEU 飽和區的理解）
- 觸發於：ingest（與當日 ingest 操作配對）

## [2026-05-18] reflect | Transformer vs RNN（query 產出）
- 綜整頁：[[transformer-vs-rnn]]
- 主張數：2（皆完全同意）
- 紅隊回合：0（query 簡化版）
- 觸發於：query
```

用一致前綴方便篩選：

```bash
grep "^## \[.*\] reflect" wiki/log.md
```

## `## 我的觀點` 區塊格式

來源頁、綜整頁、比較頁底部累加思考軌跡。**新觀點以 dated subheading 加在後面，不覆蓋舊觀點。**

### 完整範例（ingest 產出）

````markdown
## 我的觀點

### 2026-05-18

**對核心主張的立場：**
- 主張 1（Transformer 革命性勝過 SOTA）：部分同意（B）— BLEU 提升不算驚人
- 主張 2（self-attention 取代 RNN 普遍有效）：存疑（C）— translation 成功不代表通用
- 主張 3（訓練時間縮短）：完全同意（A）

**我的論述：**
我接受架構創新本身的價值，但對「BLEU +2.1 是飛躍」的詮釋持保留。
我傾向把 SOTA 邊際提升放回計算成本的框架看……

**對紅隊質疑的回應：**
反方指出 BLEU 飽和區的邊際難度被低估。這個批評讓我重新校準——……

**未解問題：**
- self-attention 在 vision、time-series 等其他模態是否同樣成立？
- 訓練成本下降是否會被推論成本上升抵銷？

**標籤：** #stance:partial-agree #strength:moderate
````

### 標籤命名空間

| 標籤 | 對應 Anchor 選項 |
|------|-----------------|
| `#stance:agree` | A — 完全同意 |
| `#stance:partial-agree` | B — 部分同意 |
| `#stance:skeptical` | C — 不同意 / 存疑 |
| `#stance:neutral` | D — 中立 / 待定 |

| 信心標籤 | 意義 |
|---------|------|
| `#strength:strong` | 經 Defend + Challenge 仍維持立場 |
| `#strength:moderate` | Defend 有合理論述但 Challenge 部分動搖 |
| `#strength:weak` | Challenge 後立場明顯偏移 |

（完整定義與使用時機見 [`references/internalization.md`](internalization.md)「標籤命名空間」段。）

### 演化說明子段（由 lint 觸發）

新舊觀點衝突被 lint 偵測且使用者選擇留下推進軌跡時，加在較新的 dated subheading 之下：

````markdown
### 2026-05-18

（觀點內容如前述）

#### 演化說明

從 2026-01-15「完全同意（A）」演化到本次「部分同意（B）」的推動因素：
- 看了 [[scaling-laws]] 後修正了對 SOTA 邊際提升的計算成本框架
- 紅隊論點關於 BLEU 飽和區的部分實際說服了我
````

## 品質標準

1. **有據可查**：每個主張都應能追溯到具體來源
2. **矛盾透明**：不同來源的衝突主張要明確標記，不要靜默選邊
3. **時效標記**：過時資訊用 ~~刪除線~~ 標記，附上更新資訊的來源
4. **一致性優先**：頁面之間的一致性比單一頁面的完美更重要
5. **適度詳細**：摘要保留足夠細節以便理解，但不要照抄全文
