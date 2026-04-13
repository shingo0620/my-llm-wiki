# LLM Wiki

[繁體中文](README.zh-TW.md)

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
├── .claude-plugin/
│   ├── plugin.json          # Plugin metadata
│   └── marketplace.json     # Marketplace registry
├── SKILL.md                 # Skill definition (main instruction set)
├── EXAMPLES.md              # Practical operation examples
├── README.md                # This file
├── README.zh-TW.md          # Chinese documentation
├── scripts/
│   ├── fetch-url.sh         # URL → Markdown fetcher
│   └── fetch-youtube.sh     # YouTube → transcript fetcher
└── references/
    └── conventions.md       # Page format standards & templates
```

## References & Inspiration

### Core Concept: LLM as Wiki Maintainer

The idea of using an LLM to build and maintain a persistent, structured wiki — rather than relying on RAG for every query — comes from Simon Willison's explorations of LLM-assisted knowledge management. The key insight: **organize once, update continuously, compound over time**. Instead of re-retrieving on every question, the LLM curates knowledge into interlinked pages that grow richer with each source.

- [Simon Willison's Weblog](https://simonwillison.net/) — Extensive writing on practical LLM workflows and personal knowledge management

### Wiki Structure & Obsidian Compatibility

The page format (YAML frontmatter, `[[wikilinks]]`, kebab-case filenames) is designed for compatibility with [Obsidian](https://obsidian.md), enabling graph visualization and bidirectional linking. The five page types (source, entity, concept, synthesis, comparison) draw from established knowledge management taxonomies, particularly the [Zettelkasten method](https://zettelkasten.de/introduction/) adapted for LLM-driven curation.

### Profile-Driven Behavior

The concept of a structured profile in `CLAUDE.md` that guides all subsequent operations is inspired by the pattern seen in Claude Code's own `CLAUDE.md` convention — project-level instructions that shape agent behavior. We extended this into a two-layer design (high-level principles + specific guidelines) informed by the distinction between *constitutive rules* (what the system is) and *regulative rules* (how it behaves) from John Searle's work on institutional reality.

### Source Ingestion Pipeline

- **URL fetching** via [markdown.new](https://markdown.new) — a free API by Firecrawl that converts web pages to clean Markdown, avoiding the noise of raw HTML scraping
- **YouTube transcripts** via [youtube-transcript-api](https://github.com/jdepoix/youtube-transcript-api) — lightweight Python library for fetching auto-generated and manual captions without requiring YouTube Data API credentials
- The "fetch → save to `raw/` → ingest" pipeline follows the principle of **immutable source data**: raw inputs are never modified, only read. This mirrors the event sourcing pattern in software architecture.

### Contradiction as Feature

The design decision to explicitly mark contradictions between sources (rather than silently resolving them) is influenced by [Hegelian dialectics](https://plato.stanford.edu/entries/hegel-dialectics/) and the ACH (Analysis of Competing Hypotheses) methodology used in intelligence analysis. Contradictions are valuable information — they reveal where knowledge is contested, evolving, or context-dependent.

### Plugin Structure

The `.claude-plugin/` packaging follows the [Claude Code plugin specification](https://docs.anthropic.com/en/docs/claude-code/plugins), modeled after patterns seen in projects like [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills).

## License

MIT
