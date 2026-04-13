# Init Profile 強化 實作計畫

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 強化 llm-wiki 的 init 流程，透過結構化提問建立知識庫 Profile 寫入 CLAUDE.md，讓後續操作能依據 profile 調整行為。

**Architecture:** 修改單一檔案 `SKILL.md` 的四個區段（Init / Ingest / Query / Lint）。Init 區段為主要改動，其餘三個區段各新增一個前置步驟或檢查項目。

**Tech Stack:** Markdown（skill 定義檔）

---

### Task 1: 重寫 Init 區段 — 問題清單與更新模式偵測

**Files:**
- Modify: `SKILL.md:42-51`（Init 的「1. 確認設定」區塊）

- [ ] **Step 1: 將現有的「1. 確認設定」替換為擴充版問題清單與更新模式偵測**

將 `SKILL.md` 第 42-51 行替換為：

```markdown
## Init — 初始化知識庫

### 0. 偵測模式

檢查當前目錄是否已有 `wiki/index.md` 和 `CLAUDE.md`：
- **都不存在** → 正常初始化流程（步驟 1 起）
- **都存在** → 進入更新模式（見下方「更新模式」區段）
- **部分存在** → 提示使用者狀態異常，確認要重新初始化還是修復

### 1. 確認設定

依序詢問以下問題。每題提供範例答案供參考，使用者可直接選範例、自己寫、或跳過。若對話中已明確提供某項資訊，跳過該題。

#### 基本資訊

1. **主題／領域** — 知識庫關於什麼？
   - 範例：「機器學習論文研究」「SaaS 產品競品分析」「個人投資學習」「團隊技術決策記錄」

2. **專案目錄** — 建在哪裡？（預設：當前目錄）

3. **語言** — wiki 內容使用的語言
   - 範例：「繁體中文」「English」「日本語」

#### 目的與使用場景

4. **建立目的** — 這個知識庫主要用來做什麼？
   - 範例：「研究特定領域的學術文獻」「產品競品分析與市場調研」「個人學習筆記整理」「團隊知識共享」「專案技術決策記錄」

5. **預期使用者** — 誰會查閱這個知識庫？
   - 範例：「只有我自己」「我和幾位同事」「整個團隊」「未來的我，幫助回憶脈絡」

6. **主要來源類型** — 通常會匯入什麼？（可複選）
   - 範例：「學術論文 PDF」「技術部落格文章」「會議記錄」「書籍章節」「訪談逐字稿」「產品文件」「新聞報導」

#### 整理邏輯與偏好

7. **組織方式** — 你希望知識怎麼被組織？
   - 範例：「按主題分類，像百科全書」「按時間線排列，追蹤演變」「按因果關係連結，理解為什麼」「按專案／產品分組」

8. **摘要風格** — 你偏好什麼樣的摘要？
   - 範例：「精簡扼要，每頁 200-300 字」「詳盡完整，保留關鍵細節」「結構化條列，方便快速掃描」

9. **原文引用** — 需要保留來源的原文引用嗎？
   - 範例：「需要，重要論點要附原文」「不需要，用自己的話改寫就好」「只保留關鍵數據和定義的原文」

#### 品質標準

10. **矛盾處理** — 不同來源說法衝突時怎麼辦？
    - 範例：「並列呈現，標註各自來源」「以最新的為準，舊的標記過時」「依證據強度排序」

11. **信心標注** — 需要標注資訊的可信度嗎？
    - 範例：「不需要，太繁瑣」「需要，用 ⚠️ 標記未經驗證的資訊」「需要，標注證據等級（強／中／弱）」

#### 領域特有結構

12. **自訂欄位** — 你的領域有沒有每個條目都該記錄的特殊資訊？
    - 範例：「技術：版本相容性、效能指標」「醫學：證據等級、樣本量」「商業：市場規模、競爭格局」「法律：適用法規、判例編號」「沒有特別的」
```

- [ ] **Step 2: 驗證替換結果**

讀取 `SKILL.md` 確認第 42 行開始的內容已正確替換，且後續的「2. 建立結構」區段（原第 52 行起）沒有被影響。

---

### Task 2: 重寫 Init 區段 — CLAUDE.md 模板

**Files:**
- Modify: `SKILL.md:92-118`（Init 的「5. 建立 CLAUDE.md」區塊）

- [ ] **Step 1: 將現有的「5. 建立 CLAUDE.md」替換為結構化 Profile 版本**

將 `SKILL.md` 中「### 5. 建立 CLAUDE.md（schema）」到「根據使用者的主題領域調整 schema 內容。不要照搬範本——理解主題後產出符合該領域的慣例。」這整段替換為：

```markdown
### 5. 建立 CLAUDE.md（知識庫 Profile）

在專案根目錄建立或更新 CLAUDE.md。Profile 分為兩層：高層原則（指導精神，LLM 遇到模糊情況時依此判斷）與具體指引（直接改變操作行為的規則）。

```markdown
# LLM Wiki Schema

## 知識庫概述
- 主題：{topic}
- 目的：{purpose}
- 預期使用者：{audience}
- 語言：{language}

## 高層原則
- 組織邏輯：{organization_style}
- 摘要風格：{summary_style}
- 知識庫調性：{由 LLM 根據所有回答綜合判斷，一句話描述，例如「嚴謹的學術研究知識庫，重視證據與溯源」或「輕量的個人學習筆記，重視快速查閱」}

## 具體指引

### 來源處理
- 主要來源類型：{source_types}
- 原文引用：{quote_policy}

### 頁面結構
- 自訂欄位：{custom_fields，寫成具體的 frontmatter 欄位或頁面區塊規範。若無則省略此項}

### 品質控制
- 矛盾處理策略：{contradiction_policy}
- 信心標注：{confidence_policy}

## 頁面類型
- **來源摘要**（source）：每個匯入來源一頁
- **實體頁**（entity）：人物、組織、產品、地點、事件
- **概念頁**（concept）：理論、方法、框架
- **綜整頁**（synthesis）：跨來源的分析與整合
- **比較頁**（comparison）：並排比較
{如有自訂頁面類型，列在此處}

## 規則
- raw/ 中的檔案不可修改
- 每次操作後更新 index.md 和 log.md
- 使用 [[wikilink]] 格式交叉引用
- 新資料與舊主張矛盾時，依矛盾處理策略處理
- 每個 wiki 頁面包含 YAML frontmatter
```

根據使用者的回答調整 profile 內容。不要照搬範本——理解使用者的需求後產出符合其目的與領域的指引。「知識庫調性」由 LLM 綜合所有回答後自行歸納一句話。
```

- [ ] **Step 2: 驗證替換結果**

讀取 `SKILL.md` 確認 CLAUDE.md 模板已正確替換，且步驟 6（告知後續步驟）沒有被影響。

---

### Task 3: 新增 Init 更新模式區段

**Files:**
- Modify: `SKILL.md`（在 Init 的「6. 告知後續步驟」之後、`---` 分隔線之前插入）

- [ ] **Step 1: 在 Init 區段末尾、Ingest 區段之前插入更新模式區段**

在「### 6. 告知後續步驟」段落結束後（「推薦用 Obsidian 開啟專案目錄即時瀏覽」之後），`---` 分隔線之前，插入：

```markdown

### 更新模式

當步驟 0 偵測到已初始化的知識庫時，進入此流程：

1. **讀取現有 CLAUDE.md**，解析目前的 profile 設定
2. **展示目前設定摘要**，以編號列表呈現所有設定項，例如：
   ```
   目前知識庫設定：
   1. 主題：LLM 技術研究
   2. 目的：追蹤學術論文與技術進展
   3. 摘要風格：結構化條列
   4. 原文引用：只保留關鍵數據和定義
   5. 矛盾處理：並列呈現，標註各自來源
   ...

   要修改哪些項目？（輸入編號，或「全部重新設定」）
   ```
3. **只重新詢問使用者選擇的項目**，附帶範例答案，其餘保留不動
4. **更新 CLAUDE.md**，原地修改對應區塊，保留未變動的內容
5. **追加 log.md**，記錄 `update-schema` 操作與變更了哪些欄位

#### 安全機制
- 不刪除舊 CLAUDE.md，而是原地修改 `# LLM Wiki Schema` 區塊內的對應內容
- CLAUDE.md 中若有使用者手動加的其他內容（非 `# LLM Wiki Schema` 區塊），保留不動
```

- [ ] **Step 2: 驗證插入位置**

讀取 `SKILL.md` 確認更新模式區段正確插入在 Init 區段末尾、`---` 分隔線之前，且 Ingest 區段未受影響。

---

### Task 4: Ingest 區段 — 新增 Profile 讀取步驟

**Files:**
- Modify: `SKILL.md`（Ingest 的「前置檢查」與「流程」之間）

- [ ] **Step 1: 在「前置檢查」之後、「### 流程」之前插入 profile 讀取步驟**

在「確認 `wiki/index.md` 和 `wiki/log.md` 存在。若不存在，引導使用者先跑 init。」之後，「### 流程」之前，插入：

```markdown

### 讀取 CLAUDE.md Profile

閱讀 CLAUDE.md 中的知識庫 profile，確認以下設定並在後續步驟中遵守：
- **摘要風格** → 控制摘要長度與格式
- **原文引用策略** → 決定是否產生 Key Quotes 區塊
- **自訂欄位** → 在 frontmatter 和頁面內容中加入對應欄位
- **矛盾處理策略** → 遇到衝突時依策略處理
- **信心標注** → 決定是否加入可信度標記
```

- [ ] **Step 2: 驗證插入位置**

讀取 `SKILL.md` 確認新步驟正確插入在前置檢查與流程之間。

---

### Task 5: Query 區段 — 新增 Profile 讀取步驟

**Files:**
- Modify: `SKILL.md`（Query 的「### 流程」之後、「#### 1. 讀取 index.md」之前）

- [ ] **Step 1: 在「### 流程」之後、「#### 1. 讀取 index.md」之前插入 profile 讀取步驟**

在 Query 區段的「### 流程」行之後，「#### 1. 讀取 index.md」之前，插入：

```markdown

#### 0. 讀取 CLAUDE.md Profile

閱讀 CLAUDE.md 中的知識庫 profile，確認以下設定：
- **知識庫目的與使用者** → 調整回答的深度與語氣
- **組織邏輯** → 影響搜尋相關頁面的策略
- **摘要風格** → 回答風格與 profile 一致
```

- [ ] **Step 2: 驗證插入位置**

讀取 `SKILL.md` 確認新步驟正確插入，且原有的步驟 1-5 未受影響。

---

### Task 6: Lint 區段 — 新增 Profile 一致性檢查

**Files:**
- Modify: `SKILL.md`（Lint 的檢查項目清單末尾）

- [ ] **Step 1: 在現有七項檢查之後新增第八項**

在 Lint 檢查項目的第 7 項「**建議問題**：值得進一步探索的新問題與新來源」之後，新增：

```markdown
8. **Profile 一致性**：頁面是否符合 CLAUDE.md 中的具體指引？包含：
   - 設定「不保留原文引用」但某些頁面有 Key Quotes 區塊
   - 自訂欄位是否在所有適用頁面中一致存在
   - 摘要長度是否符合風格設定
   - 這些不一致可能因 profile 更新後舊頁面未跟上，標出讓使用者決定是否批次修正
```

- [ ] **Step 2: 驗證新增結果**

讀取 `SKILL.md` 確認第八項正確新增在第七項之後，且輸出格式和修正流程區段未受影響。

---

### Task 7: 更新 log.md 模板

**Files:**
- Modify: `SKILL.md`（Init 的「4. 建立 wiki/log.md」區塊）

- [ ] **Step 1: 擴充 log.md 模板以記錄更多 init 資訊**

將 log.md 模板中的 init 記錄從：

```markdown
## [YYYY-MM-DD] init | 知識庫初始化
- 主題：{topic}
- 語言：{language}
```

替換為：

```markdown
## [YYYY-MM-DD] init | 知識庫初始化
- 主題：{topic}
- 目的：{purpose}
- 語言：{language}
- Profile 設定：已寫入 CLAUDE.md
```

- [ ] **Step 2: 驗證替換結果**

讀取 `SKILL.md` 確認 log.md 模板已正確更新。

---

### Task 8: 最終驗證與 Commit

**Files:**
- Verify: `SKILL.md`（完整閱讀確認所有修改正確）

- [ ] **Step 1: 完整閱讀 SKILL.md**

從頭到尾讀取修改後的 `SKILL.md`，確認：
- Init 區段：問題清單 12 題含範例、更新模式偵測、CLAUDE.md profile 模板、更新模式流程
- Ingest 區段：profile 讀取步驟在前置檢查與流程之間
- Query 區段：profile 讀取步驟在流程開頭
- Lint 區段：第八項 profile 一致性檢查
- log.md 模板：擴充版
- 各區段之間沒有斷裂或重複

- [ ] **Step 2: Commit**

```bash
git add SKILL.md
git commit -m "feat: 強化 init 流程，新增結構化知識庫 Profile"
```
