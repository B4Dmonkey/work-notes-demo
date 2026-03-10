# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of personal utility scripts. Each script is a standalone tool in the repo root. Scripts are symlinked to `~/bin` for system-wide use.

## Testing scripts

`Taskfile.yaml` is used for **testing only** (not how scripts are invoked by the user). Run `task --list` to see available test commands.

**When adding or modifying a script, always update Taskfile.yaml to match.** Every script flag/mode combination should have a corresponding task entry so scripts can be tested via `task <name>`. Follow the existing naming convention: `<script>:<mode>` for list actions, `<script>:<mode>:read` for read actions, and a generic `<script>:review` passthrough using `CLI_ARGS`.

## Platform

macOS only. Scripts use BSD `date -v` for relative date math — do not use GNU date flags.

## Shell conventions

- Scripts use `#!/bin/sh` (POSIX sh), not bash
- No hardcoded filesystem paths — use CLI tools (e.g., `obsidian` CLI) to access external data
- Date filtering uses integer comparison on `YYYYMMDD` strings (strip dashes, compare with `-ge`/`-le`)

## Obsidian CLI quirks

The `obsidian` CLI prints loading/version noise on **stdout** (not stderr). When reading file contents, grep out noise lines rather than redirecting stderr. Current pattern:

```sh
grep -vE '^[0-9]{4}-[0-9]{2}-[0-9]{2}|Loading updated|Your Obsidian installer'
```

If the obsidian CLI output format changes, test raw output first before writing new filters.

## Workflow preferences

- Check file/system state before assuming it (e.g., don't `chmod +x` without checking first)
- When a CLI tool has unpredictable output, run it raw first, inspect, then write filters
- Test every flag combination after implementing a script
- **After any rename (file, function, variable), grep the entire project for the old name and update all references in one pass** — scripts, Taskfile, README, CLAUDE.md, and any other docs
