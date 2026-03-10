# Reviewing Past Notes with a Local LLM

A local LLM workflow for weekly notes

<!-- end_slide -->

## The Problem

Notes pile up every week — ideas, decisions, things learned.

Hard to step back and see what mattered or what's worth revisiting.

Weekly review is valuable. But rereading everything takes time.

**Can a local model do a first pass?**

<!-- end_slide -->

## Demo: What It Produces

This pulls notes from the past week and pipes them into a local LLM for summarization.

At the weekly level it works well — captures themes, highlights things worth revisiting.

```bash
task stride:week:read | fabric -s -p summarize
```

<!-- end_slide -->

## [Live Run]

```bash +exec
task stride:week:read | fabric -s -p summarize
```

<!-- end_slide -->

## The Stack

- **Obsidian** — note storage
- **Fabric** — running prompts from the CLI
- **Ollama** — local model runtime
- **Gemma3:4b** — the model

<!-- end_slide -->

## stride-notes.sh

Fetches dated Obsidian notes for a time range and prints to stdout.

```sh
stride-notes.sh [RANGE] [ACTION]
  -w  past week    -m  past month    -6  past 6 months
  -l  list files   -r  read contents
```

**How it works:**
1. Computes start date using BSD `date -v` (macOS)
2. Calls `obsidian files` — filters to dated `.md` files
3. Filters by date using integer comparison on `YYYYMMDD`
4. `-l` lists filenames, `-r` streams full note contents

`task stride:week:read` == `./stride-notes.sh -w -r`

<!-- end_slide -->

## Repo Structure

Small by design — four files.

- `Taskfile.yaml` — task runner / test harness
- `README.md` — usage notes
- `CLAUDE.md` — prompt used to help generate the script
- `stride-notes.sh` — the script

Philosophy: **small scripts that each do one thing well**

<!-- end_slide -->

## Fabric Flags

```bash
fabric -s -p summarize
```

- `-s` — streaming output
- `-p` — selects a pattern (predefined prompt)

`summarize` is one of Fabric's built-in patterns — ships with Fabric, no custom prompt needed.

<!-- end_slide -->

## Limitations

Weekly works well.

Six months of notes — the model loses the thread.

This highlights the **current limits of smaller local models** with larger contexts.

<!-- end_slide -->

## Next Steps

- Write custom prompts tailored to my notes
- Create shell aliases for common analyses
- Experiment with ways to reduce context for longer time ranges
- Explore Fabric's built-in patterns (summarize is just one of many)
- Repo available as a gist — link in chat

<!-- end_slide -->

## Try It Yourself

Repo: _attached in thread_

Stack: Obsidian · Fabric · Ollama · Gemma3:4b
