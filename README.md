# LLM Wiki

A Claude Code skill for building and maintaining personal knowledge bases as structured, interlinked Markdown files.

Unlike RAG (retrieve every query), LLM Wiki organizes knowledge once and keeps it updated — compounding over time.

## How It Works

**You** pick sources, guide analysis, ask questions.
**LLM** summarizes, cross-references, files, organizes, and maintains.

## Commands

| Command | Description |
|---------|-------------|
| `/llm-wiki init` | Initialize a new knowledge base |
| `/llm-wiki ingest` | Import sources into wiki pages |
| `/llm-wiki query` | Query the knowledge base |
| `/llm-wiki lint` | Health check and maintenance |

## Source Types

LLM Wiki can ingest from three source types:

| Type | Method |
|------|--------|
| **Files** | Place in `raw/` directory (PDF, Markdown, images, text) |
| **URLs** | Auto-fetches via [markdown.new](https://markdown.new) API |
| **YouTube** | Auto-fetches transcript via `youtube-transcript-api` |

## Knowledge Base Structure

```
my-knowledge-base/
├── raw/                  # Immutable source files (LLM read-only)
│   └── assets/           # Images and attachments
├── wiki/                 # LLM-generated Markdown pages
│   ├── index.md          # Auto-maintained content index
│   └── log.md            # Append-only operation log
└── CLAUDE.md             # Knowledge base profile & schema
```

## Key Features

### Structured Init (12-question profile)

`init` walks you through 12 questions (with example answers) across 4 categories:

- **Basic info** — topic, directory, language
- **Purpose & audience** — goals, who will use it
- **Organization preferences** — structure, summary style, quoting policy
- **Quality standards** — contradiction handling, confidence markers, custom fields

Answers are stored in `CLAUDE.md` as a two-layer profile (high-level principles + specific guidelines) that guides all subsequent operations.

Re-running `init` enters **update mode** — selectively modify existing settings without starting over.

### Profile-Aware Operations

Every operation reads `CLAUDE.md` first:

- **Ingest** adapts summary length, quoting, custom fields, contradiction handling
- **Query** adjusts depth, tone, and search strategy
- **Lint** checks page consistency against profile settings

### Wiki Page Types

| Type | Description |
|------|-------------|
| **Source** | One page per imported source |
| **Entity** | People, organizations, products, locations, events |
| **Concept** | Theories, methods, frameworks |
| **Synthesis** | Cross-source analysis and integration |
| **Comparison** | Side-by-side comparisons |

Pages use `[[wikilinks]]` for cross-referencing. Recommended viewer: [Obsidian](https://obsidian.md).

## Installation

### As a Claude Code skill

```bash
# Copy to your skills directory
cp -r llm-wiki ~/.claude/skills/

# Or clone directly
git clone git@github.com:shingo0620/my-llm-wiki.git ~/.claude/skills/llm-wiki
```

### Dependencies

- **Python 3** — for fetch scripts
- **curl** — for markdown.new API
- **youtube-transcript-api** — auto-installed on first YouTube ingest

## Scripts

| Script | Usage |
|--------|-------|
| `scripts/fetch-url.sh` | `./fetch-url.sh <URL> <OUTPUT_DIR>` |
| `scripts/fetch-youtube.sh` | `./fetch-youtube.sh <YOUTUBE_URL> <OUTPUT_DIR>` |

Both scripts output the saved file path on success. Files include metadata headers (`source-url`, `title`, `fetched` date).

## File Reference

```
llm-wiki/
├── SKILL.md                 # Skill definition (main instruction set)
├── README.md                # This file
├── scripts/
│   ├── fetch-url.sh         # URL → Markdown fetcher
│   └── fetch-youtube.sh     # YouTube → transcript fetcher
└── references/
    └── conventions.md       # Page format standards & templates
```

## License

MIT
