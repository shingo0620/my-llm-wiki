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

13. 內化深度 — 你希望 wiki 強迫你做多少思考？
    → 使用者回答：「中等：ingest 啟用三段但關掉挑戰階段、query 不觸發」

14. 觀點演化檢查 — 你想要 lint 主動指出你新舊觀點的衝突嗎？
    → 使用者回答：「想，矛盾本身就是學習機會」
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

## 內化機制（internalization）

- 啟用：true
- ingest 啟用挑戰階段：false
- ingest Anchor 題數：2（範圍 2-3）
- ingest Defend 字數預期：50-150
- query 觸發策略：寬鬆（寧可多觸發、避免漏抓）
- query Anchor 題數：1-2（query 自動簡化，無 Challenge 階段）
- query Defend 字數預期：50 字內
- 暫存過期天數：14
- lint 偵測新舊觀點衝突：true

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
# 偵測 skill 安裝位置
SKILL_SCRIPTS=$(find ~/.claude/skills .claude/skills -path "*/llm-wiki/scripts/fetch-url.sh" 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
"${SKILL_SCRIPTS}/fetch-url.sh" \
  "https://lilianweng.github.io/posts/2023-06-23-agent/" \
  "./raw"
# 輸出：./raw/llm-powered-autonomous-agents.md
```

然後以 `raw/llm-powered-autonomous-agents.md` 作為來源，執行標準 ingest 流程。

### 範例 3：匯入一個 YouTube 影片

**使用者：** 「匯入這個演講 https://www.youtube.com/watch?v=zjkBMFhNj_g」

**LLM 執行流程：**

```bash
# 偵測 skill 安裝位置
SKILL_SCRIPTS=$(find ~/.claude/skills .claude/skills -path "*/llm-wiki/scripts/fetch-youtube.sh" 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
"${SKILL_SCRIPTS}/fetch-youtube.sh" \
  "https://www.youtube.com/watch?v=zjkBMFhNj_g" \
  "./raw"
# 輸出：./raw/yt-intro-to-large-language-models.md
```

然後以逐字稿作為來源，執行標準 ingest 流程。逐字稿帶有時間戳，摘要時可引用具體時間點。

### 範例 4：ingest 完整三段式思考關卡

接續範例 1（已 ingest「Attention Is All You Need」進到步驟 8）。步驟 8.5 思考關卡：

#### Anchor

```
我從這篇論文萃取了 3 個核心主張，逐題出選擇題：

---

主張 1：「Transformer 完全捨棄 RNN 與 CNN，僅靠 self-attention 與
feed-forward 層，在 WMT 2014 英德翻譯達到 28.4 BLEU、超越先前所有
SOTA 集成模型，且訓練時間從數週縮短到 3.5 天（8 GPU）。」

你的反應最接近：
A. 完全同意——這是革命性的設計選擇
B. 部分同意——架構創新成立，但 BLEU 提升不算驚人
C. 存疑——translation 成功不代表能推廣到其他序列任務
D. 中立——需要更多後續驗證

主張 2：「Self-attention 透過 O(1) 個 sequential operation 連結
任意兩個位置，相對於 RNN 需要 O(n) 個 step，對學習長距離依賴有
根本優勢。」

你的反應最接近：
A. 完全同意——長依賴的問題終於有解
B. 部分同意——對「依賴」的捕捉確實更直接，但 O(n²) memory 是代價
C. 存疑——長依賴的瓶頸實際上是資料而非架構
D. 中立

主張 3：「Multi-Head Attention 允許模型同時關注不同表示空間的資訊，
這對性能提升至關重要。」
...
```

使用者答：1B、2B、3A。

#### Defend

```
你對主張 1 選了 B、主張 2 選了 B。請說明：

(1) BLEU 提升不算驚人的具體判準是什麼？你會拿什麼樣的數字當基準？

(2) O(n²) memory 在哪些情境會構成實質代價？（例如序列長度多少之後）
```

使用者答（120 字）：「(1) WMT 翻譯任務已飽和，BLEU +2.1 相對於先前 26.3 是 8%
相對提升，但訓練成本下降才是真正驚人。 (2) 長文件、長對話、code 場景容易超過 4K
token，attention memory 變成 GPU 記憶體瓶頸，需要 sparse / linear 變體解決。」

#### Challenge

```
你說 BLEU 提升幅度普通，O(n²) 是長序列瓶頸。但反方會這樣說：

「BLEU 28.4 vs 先前 ensemble 模型的 26.3 看起來只差 2 點，但 WMT
翻譯任務早已飽和——2014-2017 年間，每 1 BLEU 的提升通常需要 10
倍以上的計算資源。Transformer 同時做到『+2.1 BLEU』和『訓練時間
從 12 天降到 3.5 天』，等於以 1/3 的計算達到更高品質。這在飽和區
是難以想像的躍進。至於 O(n²) memory，2017 年的論文不需要對 2026
年才浮現的長文件場景負責——它要回答的是『翻譯任務上 attention 是否
work』，這個任務上序列長度本來就 < 100。你的批評是用後見之明攻擊
原始貢獻。」

你怎麼回應？
```

使用者答（80 字）：「接受『飽和區邊際難度被低估』這個校準。我把 BLEU +2.1
重新理解為『以 1/3 計算達到更高品質』，這確實是飛躍。但 O(n²) memory 的批評不是
後見之明——原論文應用範圍未來會擴展是當時可預期的。」

#### Compose

寫入 `wiki/attention-is-all-you-need.md` 底部：

```markdown
## 我的觀點

### 2026-05-18

**對核心主張的立場：**
- 主張 1（Transformer 革命性勝過 SOTA）：部分同意（B）— BLEU 提升不算驚人
- 主張 2（self-attention 長依賴優勢）：部分同意（B）— 優勢成立但 O(n²) memory 是代價
- 主張 3（Multi-Head 對性能至關重要）：完全同意（A）

**我的論述：**
WMT 翻譯任務已飽和，BLEU +2.1 相對於先前 26.3 是 8% 相對提升，但
訓練成本下降才是真正驚人。O(n²) memory 在長文件、長對話、code 場景
構成實質瓶頸，需要 sparse/linear 變體解決。

**對紅隊質疑的回應：**
接受「飽和區邊際難度被低估」這個校準——把 BLEU +2.1 重新理解為
「以 1/3 計算達到更高品質」是飛躍。但 O(n²) memory 的批評不是後見
之明，原論文應用範圍未來會擴展是當時可預期的。

**未解問題：**
- 飽和區 SOTA 的計算成本框架是否還能套用到 LLM scaling？
- O(n²) 替代方案（linear attention、state space）在通用性與性能上的權衡？

**標籤：** #stance:partial-agree #strength:moderate
```

接著進步驟 9 更新 index、步驟 10 在 log.md 同時追加 ingest 與 reflect 兩筆。

### 範例 5：ingest 複利——重述既有觀點

**情境**：使用者已 ingest 過「Attention Is All You Need」（觀點：對 self-attention 通用性存疑）。現在要 ingest 新論文「GPT-3: Language Models are Few-Shot Learners」。

**LLM 流程：**
1. 步驟 1：識別來源 + 搜尋 wiki 既有 `## 我的觀點` 區塊
2. 發現 [[attention-is-all-you-need]] 中對「self-attention 通用性」標 `#stance:skeptical`
3. 跑完步驟 2-8，到步驟 8.5 Anchor 階段時 inline 重述既有立場：

```
你正在 ingest「GPT-3: Language Models are Few-Shot Learners」。

提醒：你在 [[attention-is-all-you-need]]（2026-01-15）對「self-attention
通用性」標 `#stance:skeptical`，寫道：「translation 成功不代表能推廣
到其他序列任務」。

現在這篇來源主張：「在 175B 參數規模下，純 Transformer 架構展現出
few-shot learning 等湧現能力，跨數十種任務（翻譯、QA、算術、文字生成）
無需 fine-tune 即可運作。」

這個證據對你之前的存疑立場是：
A. 推翻——通用性已被證實
B. 部分支持——但 few-shot 不等於跨模態
C. 不影響——few-shot 仍在語言模態內，存疑點是視覺/時序等
D. 我想重新看一下之前的觀點再決定
```

選 D 時，LLM inline 完整貼出 2026-01-15 的觀點段供重讀。

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

### 範例 3：query 立場性結論觸發簡化版思考

**使用者：** 「Self-attention 的 O(n²) memory 在實務上會是瓶頸嗎？」

**LLM 流程：**
1. 讀 CLAUDE.md profile（內化機制啟用、query 寬鬆觸發）
2. 讀 index、相關頁面，整合答案
3. 判斷產出為「立場性結論」（不是事實查詢）→ 觸發簡化版思考關卡
4. 整合回答：

```
從 [[attention-is-all-you-need]]、[[long-context-llm]] 等頁綜合：
- 序列長度 < 2K：實際不是瓶頸，GPU memory 足夠
- 序列長度 2K-32K：開始成為主要 GPU 限制因素，產業已大量採用 sparse
  與 linear attention 變體
- 序列長度 > 32K：必須用替代架構（state space、ring attention 等）

要存成綜整頁嗎？
```

**使用者：** 「好」

**LLM 觸發簡化版三段式：**

```
存入前先做簡化版思考——

主張：「self-attention 的 O(n²) memory 只在序列長度 > 2K 時才構成實質
瓶頸；< 2K 場景下不是問題。」

你的反應最接近：
A. 完全同意
B. 部分同意——分界點可能不是 2K
C. 不同意——< 2K 在某些硬體上已是瓶頸
D. 中立
```

使用者答：B。

```
請說明：你認為分界點應該設在哪、判準是什麼？（50 字內）
```

使用者答：「分界點依硬體不同：消費級 GPU 可能 1K 就感受到、A100/H100
8K 才明顯。所以不該用單一閾值。」

**寫入 `wiki/o-n-squared-memory-bottleneck.md` 底部：**

```markdown
## 我的觀點

### 2026-05-18（query 產出）

**對結論的立場：**
- 結論（O(n²) memory 在 > 2K 才是瓶頸）：部分同意（B）— 分界點該依硬體區分

**我的論述：**
分界點依硬體不同：消費級 GPU 可能 1K 就感受到、A100/H100 8K 才明顯。
不該用單一閾值。

**標籤：** #stance:partial-agree
```

接著更新 index、log（同時追加 query 與 reflect 兩筆）。

### 範例 4：query 複利——回答口吻個人化

**使用者：** 「Transformer 在所有序列任務上都優於 RNN 嗎？」

**LLM 流程：**
1. 讀 index → 找相關頁面
2. 同時搜尋使用者既有 `## 我的觀點` 中相關立場（透過 `#stance:` 標籤）
3. 整合回答時主動引用：

```
從 [[attention-is-all-you-need]]、[[transformer-architecture]]、[[gpt-3]]
三頁綜合：在 NLP 任務上是，長序列且記憶體受限的場景 RNN 仍有利基。

但注意你的立場演化（從 wiki 中 `#stance:` 標籤聚合而來）：
- 2026-01-15 對「self-attention 通用性」標存疑
- 2026-08-12 對 GPT-3 跨任務 few-shot 表態為「部分支持」

結論建議：對 NLP 內部任務接受、對跨模態保留——這與你的累積立場一致。

要把這個建議存成綜整頁嗎？
```

回答口吻從「根據 wiki」轉變為「根據 wiki + 你的立場」，更個人化。

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

#### 範例：新舊觀點衝突的處理

🟡 注意（接續）

8. **新舊觀點衝突**：[[attention-is-all-you-need]] 中主張 1 立場變了：

   2026-01-15：完全同意（A）— 你寫道：「Transformer 是純粹的架構勝利，
   BLEU 提升只是附帶。」

   2026-05-18：部分同意（B）— 你寫道：「BLEU +2.1 在飽和區的邊際難度
   被低估，但我仍對通用性存疑。」

   是哪一個推動了改變？
   (a) 看了 [[scaling-laws]] 後修正了計算成本框架
   (b) 紅隊論點實際說服了你
   (c) 兩者皆有 / 其他原因

   要把這個演化寫成 `#### 演化說明` 子段，留下推進軌跡嗎？

使用者選 (c)，填寫：「兩者皆有：scaling laws 給了框架，紅隊論點點出
飽和區的邊際成本。」LLM 在 2026-05-18 子段下方追加：

```markdown
#### 演化說明

從 2026-01-15「完全同意（A）」演化到本次「部分同意（B）」：
兩者皆有——[[scaling-laws]] 給了計算成本框架，紅隊論點點出了
飽和區的邊際難度。
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
