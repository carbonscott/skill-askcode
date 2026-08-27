#!/bin/bash
# Environment for askcode skill.
# Discovers tree-sitter-db (tsdb) and loads its environment.
# Override any variable via env.local or by exporting before sourcing.

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# tree-sitter-db: check PATH first, then known locations
if ! command -v tsdb &>/dev/null; then
    # Try TREE_SITTER_DB_DIR if set, or look for sibling
    TSDB_ENV="${TREE_SITTER_DB_DIR:-$SKILL_DIR/../tree-sitter-db}/env.sh"
    if [ -f "$TSDB_ENV" ]; then
        source "$TSDB_ENV"
    fi
fi

# uv cache per user
export UV_CACHE_DIR="${UV_CACHE_DIR:-/tmp/uv-cache-$USER}"

# User overrides last
if [ -f "$SKILL_DIR/env.local" ]; then
    source "$SKILL_DIR/env.local"
fi
