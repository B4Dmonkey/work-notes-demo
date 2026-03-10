# Scripts

Personal utility scripts, symlinked to `~/bin` for system-wide use.

## stride-notes.sh

Fetch daily notes from the Obsidian Stride vault.

```sh
stride-notes.sh -w -r    # Read this week's notes
stride-notes.sh -m -l    # List past month's notes
stride-notes.sh -f 2026-02-15 -l  # List from a specific date
```

| Flag | Description |
|------|-------------|
| `-w` | Past week, Monday through today **(default range)** |
| `-m` | Past month (30 days) |
| `-6` | Past 6 months |
| `-f DATE` | From a specific `YYYY-MM-DD` date |
| `-l` | List filenames **(default action)** |
| `-r` | Read and display contents |
| `-h` | Show help |
