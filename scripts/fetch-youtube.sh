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
#   Fallback（字幕不可用時）：yt-dlp, ffmpeg, mlx-whisper 或 faster-whisper
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
    error_type = type(e).__name__
    print(f"ERROR:{error_type}:{e}")
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

# --- Whisper Fallback 輔助函式 ---

prompt_user() {
  # 透過 /dev/tty 讀取使用者輸入（避免 pipe 情境）
  local prompt="$1"
  local default="$2"
  local reply
  echo -n "${prompt}" >&2
  read -r reply < /dev/tty 2>/dev/null || reply="${default}"
  echo "${reply:-$default}"
}

check_and_install_deps() {
  local missing_brew=()
  local missing_pip=""
  local pip_package=""
  local is_apple_silicon=false

  # 平台偵測
  if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" ]]; then
    is_apple_silicon=true
  fi

  # 檢查 yt-dlp
  if ! command -v yt-dlp &>/dev/null; then
    missing_brew+=("yt-dlp")
  fi

  # 檢查 ffmpeg
  if ! command -v ffmpeg &>/dev/null; then
    missing_brew+=("ffmpeg")
  fi

  # 檢查 whisper 套件
  if [[ "${is_apple_silicon}" == true ]]; then
    pip_package="mlx-whisper"
    if ! python3 -c "import mlx_whisper" 2>/dev/null; then
      missing_pip="${pip_package}"
    fi
  else
    pip_package="faster-whisper"
    if ! python3 -c "import faster_whisper" 2>/dev/null; then
      missing_pip="${pip_package}"
    fi
  fi

  # 沒有缺少任何依賴
  if [[ ${#missing_brew[@]} -eq 0 && -z "${missing_pip}" ]]; then
    return 0
  fi

  # 列出缺少的依賴
  echo "" >&2
  echo "⚠️  字幕不可用，需要額外工具進行語音辨識：" >&2
  echo "" >&2

  if [[ ${#missing_brew[@]} -gt 0 ]]; then
    local brew_list
    brew_list=$(IFS=', '; echo "${missing_brew[*]}")
    echo "  缺少：${brew_list}" >&2
    echo "  安裝指令：brew install ${missing_brew[*]}" >&2
    echo "" >&2
  fi

  if [[ -n "${missing_pip}" ]]; then
    echo "  缺少：${missing_pip}" >&2
    if command -v uv &>/dev/null; then
      echo "  安裝指令：uv pip install ${missing_pip}" >&2
    else
      echo "  安裝指令：pip3 install ${missing_pip}" >&2
    fi
    echo "" >&2
  fi

  local answer
  answer=$(prompt_user "是否現在安裝？(y/N) " "n")

  if [[ "${answer}" != "y" && "${answer}" != "Y" ]]; then
    echo "已取消。請手動安裝上述依賴後重新執行。" >&2
    return 1
  fi

  # 安裝 brew 套件
  if [[ ${#missing_brew[@]} -gt 0 ]]; then
    if ! command -v brew &>/dev/null; then
      echo "錯誤：找不到 brew，請手動安裝 ${missing_brew[*]}" >&2
      return 1
    fi
    echo "正在安裝 ${missing_brew[*]}..." >&2
    brew install "${missing_brew[@]}" 2>&1 >&2
  fi

  # 安裝 Python 套件
  if [[ -n "${missing_pip}" ]]; then
    echo "正在安裝 ${missing_pip}..." >&2
    if command -v uv &>/dev/null; then
      uv pip install "${missing_pip}" 2>&1 >&2
    elif command -v pip3 &>/dev/null; then
      pip3 install --user "${missing_pip}" 2>&1 >&2
    else
      echo "錯誤：找不到 uv 或 pip3" >&2
      return 1
    fi
  fi

  echo "依賴安裝完成。" >&2
  return 0
}

prompt_whisper_model() {
  echo "" >&2
  echo "請選擇 Whisper 模型大小：" >&2
  echo "  1) small  (~460MB, 速度快, 品質中等)" >&2
  echo "  2) medium (~1.5GB, 平衡)     [預設]" >&2
  echo "  3) large-v3 (~3GB, 最佳品質)" >&2
  local choice
  choice=$(prompt_user "選擇 (1/2/3): " "2")

  case "${choice}" in
    1) echo "small" ;;
    3) echo "large-v3" ;;
    *) echo "medium" ;;
  esac
}

run_whisper_fallback() {
  local video_id="$1"
  local model_size="$2"
  local audio_file="/tmp/yt-audio-${video_id}.mp3"

  # 設定 trap 清理暫存檔（展開路徑避免 local 變數作用域問題）
  trap "rm -f '${audio_file}'" EXIT

  # 下載音訊
  echo "正在下載音訊..." >&2
  yt-dlp -x --audio-format mp3 \
    -o "${audio_file}" \
    --no-playlist \
    --quiet \
    "https://www.youtube.com/watch?v=${video_id}" 2>&1 >&2

  if [[ ! -f "${audio_file}" ]]; then
    echo "錯誤：音訊下載失敗" >&2
    return 1
  fi

  echo "正在進行語音辨識（模型：${model_size}）...這可能需要幾分鐘" >&2

  # 使用 Python 進行轉錄
  WHISPER_AUDIO="${audio_file}" WHISPER_MODEL="${model_size}" python3 << 'WHISPER_PYEOF'
import os, sys, platform, json

audio_file = os.environ["WHISPER_AUDIO"]
model_size = os.environ["WHISPER_MODEL"]

is_apple_silicon = (platform.system() == "Darwin" and platform.machine() == "arm64")

segments_data = []

if is_apple_silicon:
    import mlx_whisper

    # mlx-whisper 使用 HuggingFace 模型 ID
    model_map = {
        "small": "mlx-community/whisper-small-mlx",
        "medium": "mlx-community/whisper-medium-mlx",
        "large-v3": "mlx-community/whisper-large-v3-mlx",
    }
    repo = model_map.get(model_size, model_map["medium"])

    result = mlx_whisper.transcribe(
        audio_file,
        path_or_hf_repo=repo,
        language="zh",
        verbose=False,
    )

    for seg in result.get("segments", []):
        segments_data.append({
            "start": seg["start"],
            "text": seg["text"].strip(),
        })
else:
    from faster_whisper import WhisperModel

    model = WhisperModel(model_size, device="cpu", compute_type="int8")
    segments, _ = model.transcribe(audio_file, language="zh")

    for seg in segments:
        segments_data.append({
            "start": seg.start,
            "text": seg.text.strip(),
        })

# 輸出 JSON 給 bash 解析
print(json.dumps(segments_data, ensure_ascii=False))
WHISPER_PYEOF
}

# --- 主流程 ---

# 檢查是否為需要 fallback 的錯誤
FIRST_LINE=$(echo "${PARSED}" | head -1)

if echo "${FIRST_LINE}" | grep -q "^ERROR:"; then
  ERROR_TYPE=$(echo "${FIRST_LINE}" | cut -d: -f2)
  ERROR_MSG=$(echo "${FIRST_LINE}" | cut -d: -f3-)

  # 只有 TranscriptsDisabled 才啟用 fallback
  if [[ "${ERROR_TYPE}" != "TranscriptsDisabled" ]]; then
    echo "錯誤：${ERROR_MSG}" >&2
    exit 1
  fi

  echo "字幕不可用，嘗試語音辨識 fallback..." >&2

  # 提取 video ID（在 fallback 中需要）
  VIDEO_ID=$(YOUTUBE_URL="${URL}" python3 -c "
import re, os
url = os.environ['YOUTUBE_URL']
for p in [r'(?:v=|/v/|youtu\.be/)([a-zA-Z0-9_-]{11})', r'(?:embed/)([a-zA-Z0-9_-]{11})', r'(?:shorts/)([a-zA-Z0-9_-]{11})']:
    m = re.search(p, url)
    if m:
        print(m.group(1))
        break
")

  if [[ -z "${VIDEO_ID}" ]]; then
    echo "錯誤：無法從 URL 提取 video ID" >&2
    exit 1
  fi

  # 檢查並安裝依賴
  if ! check_and_install_deps; then
    exit 1
  fi

  # 詢問模型大小
  MODEL_SIZE=$(prompt_whisper_model)

  # 取得影片標題與作者（透過 oembed）
  OEMBED_DATA=$(python3 -c "
import urllib.request, json
video_id = '${VIDEO_ID}'
try:
    url = f'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json'
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read())
        print(f\"TITLE:{data.get('title', video_id)}\")
        print(f\"AUTHOR:{data.get('author_name', '')}\")
except Exception:
    print(f'TITLE:{video_id}')
    print('AUTHOR:')
")

  TITLE=$(echo "${OEMBED_DATA}" | grep "^TITLE:" | head -1 | sed 's/^TITLE://')
  AUTHOR=$(echo "${OEMBED_DATA}" | grep "^AUTHOR:" | head -1 | sed 's/^AUTHOR://')

  # 產生 kebab-case 檔名
  FILENAME=$(python3 -c "
import re
title = '''${TITLE}'''
s = re.sub(r'[^\w\s-]', '', title.lower())
s = re.sub(r'[\s_]+', '-', s)
s = re.sub(r'-+', '-', s).strip('-')
print('yt-' + (s if s else 'untitled') + '.md')
")

  # 執行語音辨識
  SEGMENTS_JSON=$(run_whisper_fallback "${VIDEO_ID}" "${MODEL_SIZE}")

  if [[ -z "${SEGMENTS_JSON}" || "${SEGMENTS_JSON}" == "[]" ]]; then
    echo "錯誤：語音辨識未產生任何結果" >&2
    exit 1
  fi

  # 將 segments JSON 轉為 Markdown
  MARKDOWN=$(SEGMENTS="${SEGMENTS_JSON}" python3 << 'FMTEOF'
import json, os
segments = json.loads(os.environ["SEGMENTS"])
lines = []
for seg in segments:
    text = seg["text"].strip()
    if text:
        start = int(seg["start"])
        mins, secs = divmod(start, 60)
        timestamp = f"{mins:02d}:{secs:02d}"
        lines.append(f"**[{timestamp}]** {text}")
print("\n\n".join(lines))
FMTEOF
)

  TODAY=$(date +%Y-%m-%d)

  # 寫入檔案
  mkdir -p "${OUTPUT_DIR}"
  OUTPUT_FILE="${OUTPUT_DIR}/${FILENAME}"

  {
    echo "<!-- source-url: ${URL} -->"
    echo "<!-- type: youtube-whisper-transcript -->"
    echo "<!-- title: ${TITLE} -->"
    if [ -n "${AUTHOR}" ]; then
      echo "<!-- author: ${AUTHOR} -->"
    fi
    echo "<!-- video-id: ${VIDEO_ID} -->"
    echo "<!-- whisper-model: ${MODEL_SIZE} -->"
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
  exit 0
fi

# --- 正常流程（字幕 API 成功）---

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
