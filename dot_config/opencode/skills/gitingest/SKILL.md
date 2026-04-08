---
name: gitingest
description: >
  Convert any Git repository into a text file optimized for LLM consumption using GitIngest.
  Use when the user wants to ingest a repo, create a text digest of a codebase, prepare a repository for LLM analysis, convert a GitHub URL to a readable text file, or dump a codebase for AI context. This skill also covers filtering by file type, ingesting specific branches, managing output size, and handling private repositories.
---

# GitIngest

Convert any Git repository into a prompt-friendly text file for LLM consumption. GitIngest extracts the structure and contents of a repository into a single text file optimized for language models.

## When to Use

- User wants to analyze an entire codebase with an LLM
- User needs a text representation of a repository
- User mentions "ingest", "digest", or converting a repo to text
- User wants to prepare code for LLM context
- User provides a GitHub URL and wants it converted to text
- User wants to filter a repository by file type (e.g., only Python files)
- User needs a specific branch ingested

## Quick Reference

| Scenario | Command |
|----------|---------|
| Local directory | `gitingest /path/to/repo -o output.txt` |
| GitHub repository | `gitingest https://github.com/owner/repo -o output.txt` |
| Current directory | `gitingest . -o output.txt` |
| Preview to stdout | `gitingest . -o -` |
| Only Python files | `gitingest . -i "*.py" -o output.txt` |
| Exclude test files | `gitingest . -e "*.test.*" -e "test/" -o output.txt` |
| Specific branch | `gitingest https://github.com/owner/repo -b develop -o output.txt` |
| Private repository | `gitingest https://github.com/owner/repo -t <GITHUB_TOKEN> -o output.txt` |
| Include ignored files | `gitingest . --include-gitignored -o output.txt` |
| Include submodules | `gitingest . --include-submodules -o output.txt` |
| Limit file size (bytes) | `gitingest . -s 5242880 -o output.txt` |

## Workflow

### 1. Identify the Target

Determine what the user wants to ingest:
- **Local directory:** A path on the filesystem
- **GitHub URL:** A repository URL like `https://github.com/owner/repo`
- **Current directory:** If unspecified, confirm with the user

Ask clarifying questions if needed:
- Do they want a specific branch? (default: default branch, usually `main`)
- Do they want all files or a subset? (use `--include-pattern` / `--exclude-pattern`)
- Is it a large repository? (suggest filtering or size limits)
- Is it a private repo? (need a GitHub token)

### 2. Build the Command

Start with the base command, then add options as needed:

```bash
gitingest <source> -o output.txt
```

Add options based on the user's requirements:
- `-i "*.py"` — include only files matching the pattern (can be repeated)
- `-e "node_modules/*"` — exclude files matching the pattern (can be repeated)
- `-b <branch>` — ingest a specific branch
- `-s <bytes>` — skip files larger than this (default: 10MB)
- `--include-gitignored` — include files normally ignored by `.gitignore`
- `--include-submodules` — process git submodules

### 3. Run and Verify

After running, confirm success and report:
- Output file location
- Any warnings about skipped files, large files, or rate limits
- Suggest reviewing the output to confirm it looks right

## Output Format

The digest file contains:
1. **Tree header** — a directory structure showing the repo layout
2. **File contents** — each file preceded by a delimiter line (e.g., `--- src/main.py ---`)
3. **Token estimate** — GitIngest reports total tokens, which helps judge if the output fits in an LLM context window

Example structure:
```
Directory tree:
src/
  main.py
  utils.py
tests/
  test_main.py

--- src/main.py ---
[file contents here]

--- src/utils.py ---
[file contents here]

Total tokens: ~4500
```

## Managing Large Repositories

For repos that produce very large outputs:

1. **Filter by file type** — ask the user which languages/frameworks they care about:
   ```bash
   gitingest . -i "*.py" -i "*.md" -o output.txt
   ```

2. **Exclude known large directories:**
   ```bash
   gitingest . -e "node_modules/*" -e "dist/*" -e ".git/*" -o output.txt
   ```

3. **Skip large files** — use `--max-size` to exclude files over a certain size:
   ```bash
   gitingest . -s 1048576 -o output.txt  # 1MB limit
   ```

4. **Ingest a subdirectory** — if the user only needs part of the repo:
   ```bash
   gitingest /path/to/repo/src -o output.txt
   ```

5. **Use stdout for inspection** — redirect to a file to preview:
   ```bash
   gitingest . -o output.txt && head -100 output.txt
   ```

## Private Repositories

Private repos require a GitHub personal access token (PAT):

```bash
gitingest https://github.com/owner/private-repo -t <GITHUB_TOKEN> -o output.txt
```

Alternatively, set the environment variable:
```bash
export GITHUB_TOKEN=<token>
gitingest https://github.com/owner/private-repo -o output.txt
```

If the user does not have a token, guide them to generate one at GitHub Settings > Developer Settings > Personal access tokens (classic). The token only needs `repo` scope for private repos.

## Common Patterns

**Read a repo README and code structure first, then ingest selectively:**
```bash
gitingest https://github.com/owner/repo -i "*.md" -i "*.py" -o preview.txt
```
Review the output, then decide if a full ingest is needed.

**Ingest a feature branch to review changes:**
```bash
gitingest https://github.com/owner/repo -b feature/new-login -o output.txt
```

**Combine filters and size limits for a focused digest:**
```bash
gitingest . -i "src/*" -e "*.test.*" -s 2097152 -o output.txt
```

## Tips

- For very large repos, always ask the user if they want the full repo or a subset before ingesting
- The token count in the output helps users know if they will hit LLM context limits — if the output is very large, suggest filtering
- Output is optimized for LLM consumption but is also human-readable — users can open it directly to review
- When ingesting from GitHub, the tool handles cloning automatically — no need to clone manually first
