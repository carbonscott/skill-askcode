# skill-askcode

Code indexing and navigation skill using [tree-sitter-db](https://github.com/carbonscott/tree-sitter-db). Extracts functions, classes, imports, variables, and call graphs from Python/C/C++ codebases into SQLite for SQL-based analysis. Centrally deployed for LCLS users via the [deploy-opencode](https://github.com/carbonscott/deploy-opencode) meta-deploy script.

## Layout

```
claude/skills/askcode/
  SKILL.md        # skill instructions
  env.sh          # discovers tree-sitter-db (tsdb) and loads its environment
opencode/skills/askcode/
  SKILL.md        # identical to claude/ copy
  env.sh          # identical to claude/ copy
README.md         # this file
```

The two top-level directories mirror the same content for Claude Code (`~/.claude/skills/askcode/`) and OpenCode (`$OPENCODE_CONFIG_DIR/skills/askcode/`) runtimes respectively.

## Prerequisites

- [tree-sitter-db](https://github.com/carbonscott/tree-sitter-db) installed and available (provides the `tsdb` command). LCLS users get this for free via the centrally deployed `/sdf/group/lcls/ds/dm/apps/dev/tools/tree-sitter-db/env.sh`.
- [uv](https://docs.astral.sh/uv/) on your PATH (used by tree-sitter-db).

## Install

At SLAC LCLS this skill is centrally deployed — set `OPENCODE_CONFIG_DIR=/sdf/group/lcls/ds/dm/apps/dev/opencode` and it loads automatically; no per-user git clone needed.

For standalone use:

**Claude Code:**
```bash
git clone https://github.com/carbonscott/skill-askcode.git /tmp/skill-askcode
cp -r /tmp/skill-askcode/claude/skills/askcode ~/.claude/skills/askcode
```

**OpenCode:**
```bash
git clone https://github.com/carbonscott/skill-askcode.git /tmp/skill-askcode
cp -r /tmp/skill-askcode/opencode/skills/askcode "$OPENCODE_CONFIG_DIR/skills/askcode"
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

## What it covers

- Interactive workflow for indexing a new repo (in-repo `.code-index.db` vs `/tmp/<reponame>.db`)
- SQL queries for functions, classes, callers, callees, call graphs, imports
- Python/C/C++ codebases

## Meta-deploy

Deploys via `carbonscott/deploy-opencode`'s `deploy.sh` reading `skills.manifest.json` — rsyncs `opencode/skills/askcode/` into `/sdf/group/lcls/ds/dm/apps/dev/opencode/skills/askcode/` with ps-data group + g+rX permissions.

## License

Apache-2.0
