# skill-askcode

Code indexing and navigation using tree-sitter. Extracts functions, classes, imports, variables, and call graphs from Python/C/C++ codebases into SQLite for SQL-based analysis.

## Prerequisites

- [tree-sitter-db](https://github.com/carbonscott/tree-sitter-db) installed and available (provides the `tsdb` command)
- [uv](https://docs.astral.sh/uv/) on your PATH (used by tree-sitter-db)

## Install

**Claude Code:**
```bash
git clone https://github.com/carbonscott/skill-askcode.git ~/.claude/skills/askcode
```

**OpenCode:**
```bash
git clone https://github.com/carbonscott/skill-askcode.git "$OPENCODE_CONFIG_DIR/skills/askcode"
```

### Configuring tree-sitter-db location

If `tsdb` is not on your PATH, tell the skill where to find it via `env.local`:

```bash
echo 'export TREE_SITTER_DB_DIR="/path/to/tree-sitter-db"' > ~/.claude/skills/askcode/env.local
```

Or install tree-sitter-db as a sibling directory:
```bash
git clone https://github.com/carbonscott/tree-sitter-db.git ~/.claude/skills/tree-sitter-db
```

## Usage

The skill guides the LLM through an interactive workflow:
1. Check for existing `.code-index.db` in the target repo
2. Index the repo if needed (creates SQLite database)
3. Query with SQL for functions, classes, callers, call graphs

## License

Apache-2.0
