---
name: askcode
description: "Code indexing and navigation using tree-sitter. Use when users want to find functions, search code structure, analyze call graphs, find callers/callees, index a repository, or navigate code architecture for Python/C/C++ codebases."
---

# askcode Skill

Help users work with `tree-sitter-db`, a CLI tool for indexing Python/C/C++ codebases. It extracts functions, classes, imports, variables, and call graphs into SQLite. All analysis is done via SQL queries.

## Environment Setup

Every bash command must source env.sh before calling `tsdb`, because each command runs in a fresh shell:

```bash
source <this-skill-dir>/env.sh && tsdb <repo_path> [options]
```

This loads the `tsdb` shell function (provided by tree-sitter-db).

## Interactive Workflow

**IMPORTANT:** Before indexing, follow this interactive workflow:

### Step 0: Check for existing database and ask user preferences

1. **Check if a database already exists** in the working repo:
   ```bash
   ls -la /path/to/repo/.code-index.db 2>/dev/null
   ```

2. **If database exists**, ask the user:
   - "I found an existing code index database at `.code-index.db` (last modified: <date>). Would you like to:"
     - **Use existing** - Skip indexing and use the current database
     - **Re-index** - Update the database with fresh indexing

3. **If no database exists**, ask the user:
   - "No existing code index found. Where should I save the database?"
     - **Save in repo** - Store at `.code-index.db` in the repo root (persists across sessions, add to `.gitignore`)
     - **Use /tmp** - Store at `/tmp/<reponame>.db` (temporary, lost on reboot)

### Step 1: Index the repository

Based on user's choice:

```bash
# If saving in repo:
source <this-skill-dir>/env.sh && \
tsdb /path/to/repo --db /path/to/repo/.code-index.db --verbose

# If using /tmp:
source <this-skill-dir>/env.sh && \
tsdb /path/to/repo --db /tmp/reponame.db --verbose
```

**Note:** If user chooses to save in repo, remind them to add `.code-index.db` to `.gitignore`.

Options:
- `--db <path>` or `-d <path>`: Output database path
- `--exclude <pattern>` or `-e <pattern>`: Glob patterns to exclude
- `--verbose` or `-v`: Show progress

### Step 2: Query with sqlite3

All analysis is done via SQL queries:

```bash
sqlite3 -header -column /path/to/db "SELECT * FROM functions LIMIT 10"
```

## Database Schema

| Table | Key Columns |
|-------|-------------|
| files | id, path, language, indexed_at |
| functions | id, file_id, name, line_start, line_end, signature, class_name, docstring |
| classes | id, file_id, name, line_start, line_end, bases, docstring |
| imports | id, file_id, module, alias, line |
| variables | id, file_id, name, line, scope, class_name, type_hint |
| calls | id, file_id, caller_function, callee_name, line |

## Common SQL Queries

### Database statistics

```sql
SELECT
  (SELECT COUNT(*) FROM files) as files,
  (SELECT COUNT(*) FROM functions) as functions,
  (SELECT COUNT(*) FROM classes) as classes,
  (SELECT COUNT(*) FROM imports) as imports,
  (SELECT COUNT(*) FROM calls) as calls
```

### Find functions by name

```sql
SELECT f.name, fi.path, f.line_start, f.signature
FROM functions f JOIN files fi ON f.file_id = fi.id
WHERE f.name LIKE '%process%'
ORDER BY fi.path, f.line_start
```

### Find callers of a function

```sql
SELECT c.caller_function, fi.path, c.line
FROM calls c JOIN files fi ON c.file_id = fi.id
WHERE c.callee_name = 'my_function'
ORDER BY fi.path, c.line
```

### Find callees of a function

```sql
SELECT DISTINCT c.callee_name
FROM calls c WHERE c.caller_function = 'my_function'
ORDER BY c.callee_name
```

### Methods of a class

```sql
SELECT name, line_start, signature
FROM functions WHERE class_name = 'MyClass'
ORDER BY line_start
```

### All functions in a file

```sql
SELECT f.name, f.line_start, f.signature
FROM functions f JOIN files fi ON f.file_id = fi.id
WHERE fi.path LIKE '%filename%'
ORDER BY f.line_start
```

### Class hierarchy

```sql
SELECT c.name, c.bases, fi.path, c.line_start
FROM classes c JOIN files fi ON c.file_id = fi.id
ORDER BY fi.path, c.line_start
```

### Import analysis

```sql
SELECT fi.path, i.module, i.alias, i.line
FROM imports i JOIN files fi ON i.file_id = fi.id
WHERE i.module LIKE '%numpy%'
ORDER BY fi.path
```

### Call graph for a module

```sql
SELECT fi.path, c.caller_function, c.callee_name, c.line
FROM calls c JOIN files fi ON c.file_id = fi.id
WHERE fi.path LIKE '%mymodule%'
ORDER BY fi.path, c.line
```

## Supported Languages

- **Python:** `.py`, `.pyi`
- **C:** `.c`, `.h`
- **C++:** `.cpp`, `.hpp`, `.cc`, `.cxx`, `.hxx`, `.hh`

## Key Reminders

- **Always check for existing `.code-index.db` first** and ask user preference before indexing
- Always source env.sh before the `tsdb` command
- Use `--verbose` flag to see indexing progress
- Default exclusions: `**/__pycache__/**`, `**/build/**`, `**/.git/**`
- Use `--exclude` to skip additional directories
- After finding a location, use the Read tool to view the actual code
- If saving database in repo, remind user to add `.code-index.db` to `.gitignore`
