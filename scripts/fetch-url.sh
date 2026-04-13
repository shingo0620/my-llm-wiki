#!/usr/bin/env bash
# fetch-url.sh — 透過 markdown.new 將網頁轉為 Markdown
#
# 用法：
#   ./fetch-url.sh <URL> <OUTPUT_DIR>
#
# 範例：
#   ./fetch-url.sh "https://example.com/article" "./raw"
#
# 輸出：
#   將 Markdown 存入 <OUTPUT_DIR>/<kebab-case-title>.md
#   檔案開頭含 source-url 和 fetched metadata
#   成功時印出檔案路徑，失敗時印出錯誤訊息並以非零狀態碼退出

set -euo pipefail

URL="${1:?用法: fetch-url.sh <URL> <OUTPUT_DIR>}"
OUTPUT_DIR="${2:?用法: fetch-url.sh <URL> <OUTPUT_DIR>}"

API_BASE="https://markdown.new"
MAX_RETRIES=30
POLL_INTERVAL=2

# 1. 發起 crawl
echo "正在擷取: ${URL}" >&2
JSON_BODY=$(URL_INPUT="${URL}" python3 -c "import json,os; print(json.dumps({'url': os.environ['URL_INPUT'], 'limit': 1}))")
RESPONSE=$(curl -sf -X POST "${API_BASE}/crawl" \
  -H 'Content-Type: application/json' \
  -d "${JSON_BODY}")

JOB_ID=$(echo "${RESPONSE}" | python3 -c "import json,sys; print(json.load(sys.stdin)['jobId'])")

if [ -z "${JOB_ID}" ]; then
  echo "錯誤：無法取得 jobId" >&2
  exit 1
fi

echo "Job ID: ${JOB_ID}" >&2

# 2. 輪詢等待完成
for i in $(seq 1 ${MAX_RETRIES}); do
  RESULT=$(curl -sf "${API_BASE}/crawl/status/${JOB_ID}?format=json")
  STATUS=$(echo "${RESULT}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('result',{}).get('status','unknown'))")

  if [ "${STATUS}" = "completed" ]; then
    break
  fi

  if [ "${STATUS}" = "failed" ]; then
    echo "錯誤：crawl 失敗" >&2
    exit 1
  fi

  echo "等待中... (${i}/${MAX_RETRIES})" >&2
  sleep ${POLL_INTERVAL}
done

if [ "${STATUS}" != "completed" ]; then
  echo "錯誤：超時，crawl 未在 $((MAX_RETRIES * POLL_INTERVAL)) 秒內完成" >&2
  exit 1
fi

# 3. 取出 Markdown 和 title
PARSED=$(echo "${RESULT}" | SOURCE_URL="${URL}" python3 -c "
import json, sys, re, os

d = json.load(sys.stdin)
records = d.get('result', {}).get('records', [])
if not records:
    print('ERROR:NO_RECORDS')
    sys.exit(0)

rec = records[0]
title = rec.get('metadata', {}).get('title', '').strip()
markdown = rec.get('markdown', '')
url = rec.get('url', '')
source_url = os.environ.get('SOURCE_URL', url)

# fallback: 若 metadata title 為空，從 markdown 第一個 # heading 取得
if not title:
    m = re.search(r'^#\s+(.+)$', markdown, re.MULTILINE)
    if m:
        title = m.group(1).strip()
        # 移除 markdown link 語法 [text](url) → text
        title = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', title)

# fallback: 若仍為空，從 URL path 取得
if not title:
    from urllib.parse import urlparse
    path = urlparse(source_url).path.strip('/')
    title = path.split('/')[-1] if path else 'untitled'

# kebab-case 檔名
def to_kebab(s):
    s = re.sub(r'[^\w\s-]', '', s.lower())
    s = re.sub(r'[\s_]+', '-', s)
    s = re.sub(r'-+', '-', s).strip('-')
    return s if s else 'untitled'

filename = to_kebab(title) + '.md'

print(f'TITLE:{title}')
print(f'FILENAME:{filename}')
print(f'URL:{url}')
print(f'MARKDOWN_START')
print(markdown)
")

# 檢查是否有 records
if echo "${PARSED}" | head -1 | grep -q "ERROR:NO_RECORDS"; then
  echo "錯誤：crawl 完成但無內容" >&2
  exit 1
fi

# 確認 Python 解析成功產出完整結果
if ! echo "${PARSED}" | grep -q "^MARKDOWN_START$"; then
  echo "錯誤：無法解析 API 回應" >&2
  exit 1
fi

TITLE=$(echo "${PARSED}" | grep "^TITLE:" | head -1 | sed 's/^TITLE://')
FILENAME=$(echo "${PARSED}" | grep "^FILENAME:" | head -1 | sed 's/^FILENAME://')
ACTUAL_URL=$(echo "${PARSED}" | grep "^URL:" | head -1 | sed 's/^URL://')
MARKDOWN=$(echo "${PARSED}" | sed -n '/^MARKDOWN_START$/,$ p' | tail -n +2)
TODAY=$(date +%Y-%m-%d)

# 4. 寫入檔案
mkdir -p "${OUTPUT_DIR}"
OUTPUT_FILE="${OUTPUT_DIR}/${FILENAME}"

{
  echo "<!-- source-url: ${ACTUAL_URL:-${URL}} -->"
  echo "<!-- title: ${TITLE} -->"
  echo "<!-- fetched: ${TODAY} -->"
  echo ""
  echo "${MARKDOWN}"
} > "${OUTPUT_FILE}"

echo "${OUTPUT_FILE}"
