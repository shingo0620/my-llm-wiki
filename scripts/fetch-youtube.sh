#!/usr/bin/env bash
# fetch-youtube.sh — 取得 YouTube 影片逐字稿並存為 Markdown
#
# 用法：
#   ./fetch-youtube.sh <YOUTUBE_URL> <OUTPUT_DIR>
#
# 範例：
#   ./fetch-youtube.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" "./raw"
#
# 依賴：
#   youtube-transcript-api（Python 套件，腳本會自動安裝）
#
# 輸出：
#   將逐字稿存入 <OUTPUT_DIR>/yt-<kebab-case-title>.md
#   檔案開頭含 source-url、type、fetched metadata
#   成功時印出檔案路徑，失敗時印出錯誤訊息並以非零狀態碼退出

set -euo pipefail

URL="${1:?用法: fetch-youtube.sh <YOUTUBE_URL> <OUTPUT_DIR>}"
OUTPUT_DIR="${2:?用法: fetch-youtube.sh <YOUTUBE_URL> <OUTPUT_DIR>}"

# 確認 youtube-transcript-api 已安裝
if ! python3 -c "import youtube_transcript_api" 2>/dev/null; then
  echo "正在安裝 youtube-transcript-api..." >&2
  if command -v uv &>/dev/null; then
    uv pip install youtube-transcript-api --quiet 2>&1 >&2
  elif command -v pip3 &>/dev/null; then
    pip3 install --user youtube-transcript-api --quiet 2>&1 >&2
  else
    echo "錯誤：找不到 uv 或 pip3，無法安裝 youtube-transcript-api" >&2
    exit 1
  fi
fi

echo "正在擷取: ${URL}" >&2

# 使用 Python 取得逐字稿和影片資訊
PARSED=$(YOUTUBE_URL="${URL}" python3 << 'PYEOF'
import sys, re, os, json

url = os.environ.get("YOUTUBE_URL", "")

# 從 URL 提取 video ID
def extract_video_id(url):
    patterns = [
        r'(?:v=|/v/|youtu\.be/)([a-zA-Z0-9_-]{11})',
        r'(?:embed/)([a-zA-Z0-9_-]{11})',
        r'(?:shorts/)([a-zA-Z0-9_-]{11})',
    ]
    for p in patterns:
        m = re.search(p, url)
        if m:
            return m.group(1)
    return None

video_id = extract_video_id(url)
if not video_id:
    print("ERROR:無法從 URL 提取 video ID")
    sys.exit(0)

# 取得逐字稿
try:
    from youtube_transcript_api import YouTubeTranscriptApi

    ytt_api = YouTubeTranscriptApi()

    # 嘗試取得繁體中文 > 簡體中文 > 英文 > 任何可用語言
    preferred_langs = ['zh-TW', 'zh-Hant', 'zh', 'zh-Hans', 'en']
    try:
        transcript = ytt_api.fetch(video_id, languages=preferred_langs)
    except Exception:
        transcript = ytt_api.fetch(video_id)
except Exception as e:
    print(f"ERROR:無法取得逐字稿: {e}")
    sys.exit(0)

# 取得影片標題（透過 oembed API，不需 API key）
import urllib.request
title = ""
author = ""
try:
    oembed_url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
    req = urllib.request.Request(oembed_url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read())
        title = data.get("title", "")
        author = data.get("author_name", "")
except Exception:
    pass

if not title:
    title = video_id

# kebab-case 檔名
def to_kebab(s):
    s = re.sub(r'[^\w\s-]', '', s.lower())
    s = re.sub(r'[\s_]+', '-', s)
    s = re.sub(r'-+', '-', s).strip('-')
    return s if s else 'untitled'

filename = "yt-" + to_kebab(title) + ".md"

# 格式化逐字稿為 Markdown
lines = []
for snippet in transcript:
    text = snippet.text.strip()
    if text:
        # 將秒數轉為 MM:SS
        start = int(snippet.start)
        mins, secs = divmod(start, 60)
        timestamp = f"{mins:02d}:{secs:02d}"
        lines.append(f"**[{timestamp}]** {text}")

markdown = "\n\n".join(lines)

print(f"TITLE:{title}")
print(f"AUTHOR:{author}" if author else "AUTHOR:")
print(f"FILENAME:{filename}")
print(f"VIDEO_ID:{video_id}")
print(f"MARKDOWN_START")
print(markdown)
PYEOF
)

# 檢查錯誤
if echo "${PARSED}" | head -1 | grep -q "^ERROR:"; then
  ERROR_MSG=$(echo "${PARSED}" | head -1 | sed 's/^ERROR://')
  echo "錯誤：${ERROR_MSG}" >&2
  exit 1
fi

TITLE=$(echo "${PARSED}" | grep "^TITLE:" | head -1 | sed 's/^TITLE://')
AUTHOR=$(echo "${PARSED}" | grep "^AUTHOR:" | head -1 | sed 's/^AUTHOR://')
FILENAME=$(echo "${PARSED}" | grep "^FILENAME:" | head -1 | sed 's/^FILENAME://')
VIDEO_ID=$(echo "${PARSED}" | grep "^VIDEO_ID:" | head -1 | sed 's/^VIDEO_ID://')
MARKDOWN=$(echo "${PARSED}" | sed -n '/^MARKDOWN_START$/,$ p' | tail -n +2)
TODAY=$(date +%Y-%m-%d)

# 寫入檔案
mkdir -p "${OUTPUT_DIR}"
OUTPUT_FILE="${OUTPUT_DIR}/${FILENAME}"

{
  echo "<!-- source-url: ${URL} -->"
  echo "<!-- type: youtube-transcript -->"
  echo "<!-- title: ${TITLE} -->"
  if [ -n "${AUTHOR}" ]; then
    echo "<!-- author: ${AUTHOR} -->"
  fi
  echo "<!-- video-id: ${VIDEO_ID} -->"
  echo "<!-- fetched: ${TODAY} -->"
  echo ""
  echo "# ${TITLE}"
  echo ""
  if [ -n "${AUTHOR}" ]; then
    echo "> 頻道：${AUTHOR}"
    echo ""
  fi
  echo "---"
  echo ""
  echo "${MARKDOWN}"
} > "${OUTPUT_FILE}"

echo "${OUTPUT_FILE}"
