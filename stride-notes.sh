#!/bin/sh

VAULT="Obsidian-Stride"
NOTION_DAILY="Notion/Josiah x Stride/Daily Log"

usage() {
    cat <<'EOF'
Usage: stride-notes.sh [RANGE] [ACTION]

Range (pick one, default: -w):
  -w          Past week (Monday through today)
  -m          Past month (30 days)
  -6          Past 6 months
  -f DATE     From YYYY-MM-DD to today

Action (pick one, default: -l):
  -l          List matching filenames
  -r          Read and display file contents

  -h          Show this help
EOF
}

# Defaults
RANGE="week"
ACTION="list"
FROM_DATE=""

while [ $# -gt 0 ]; do
    case "$1" in
        -w) RANGE="week" ;;
        -m) RANGE="month" ;;
        -6) RANGE="6months" ;;
        -f)
            RANGE="from"
            shift
            FROM_DATE="$1"
            if [ -z "$FROM_DATE" ]; then
                echo "Error: -f requires a YYYY-MM-DD date" >&2
                exit 1
            fi
            if ! echo "$FROM_DATE" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
                echo "Error: date must be YYYY-MM-DD format" >&2
                exit 1
            fi
            ;;
        -l) ACTION="list" ;;
        -r) ACTION="read" ;;
        -h) usage; exit 0 ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

# Compute START_DATE as YYYYMMDD integer
TODAY=$(date +%Y%m%d)

case "$RANGE" in
    week)
        DOW=$(date +%u)
        if [ "$DOW" -eq 1 ]; then
            START_DATE=$(date +%Y%m%d)
        else
            DAYS_SINCE_MON=$((DOW - 1))
            START_DATE=$(date -v-"${DAYS_SINCE_MON}"d +%Y%m%d)
        fi
        ;;
    month)
        START_DATE=$(date -v-30d +%Y%m%d)
        ;;
    6months)
        START_DATE=$(date -v-6m +%Y%m%d)
        ;;
    from)
        START_DATE=$(echo "$FROM_DATE" | tr -d '-')
        ;;
esac

# Fetch file list from obsidian CLI, filter out noise and non-date files
FILES=$(obsidian files "vault=$VAULT" ext=md \
    | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$")

# Also fetch Notion daily log imports
NOTION_FILES=$(obsidian files "folder=$NOTION_DAILY" "vault=$VAULT" ext=md \
    | grep -E "^Notion/Josiah x Stride/Daily Log/[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$")

# Merge both sources
if [ -n "$NOTION_FILES" ]; then
    if [ -n "$FILES" ]; then
        FILES="$FILES
$NOTION_FILES"
    else
        FILES="$NOTION_FILES"
    fi
fi

# Filter files to date range
MATCHED=""
echo "$FILES" | while IFS= read -r f; do
    [ -z "$f" ] && continue
    # Extract date from filename: any/path/2026-03-05.md -> 20260305
    BASENAME=$(echo "$f" | sed 's|.*/||; s|\.md$||')
    FILE_DATE=$(echo "$BASENAME" | tr -d '-')
    if [ "$FILE_DATE" -ge "$START_DATE" ] && [ "$FILE_DATE" -le "$TODAY" ]; then
        echo "$f"
    fi
done > /tmp/stride_matched.$$
MATCHED=$(cat /tmp/stride_matched.$$)
rm -f /tmp/stride_matched.$$

if [ -z "$MATCHED" ]; then
    echo "No stride notes found for the selected range."
    exit 0
fi

# Sort matched files by date (filename), preserving full paths
MATCHED=$(echo "$MATCHED" | awk -F/ '{print $NF, $0}' | sort | cut -d' ' -f2-)

case "$ACTION" in
    list)
        echo "$MATCHED"
        ;;
    read)
        echo "$MATCHED" | while IFS= read -r filepath; do
            name=$(echo "$filepath" | sed 's|.*/||; s|\.md$||')
            case "$filepath" in
                */Notion/*) label="$name (Notion)" ;;
                *) label="$name" ;;
            esac
            echo "=== $label ==="
            obsidian read "path=$filepath" "vault=$VAULT" < /dev/null \
                | grep -vE '^[0-9]{4}-[0-9]{2}-[0-9]{2}|Loading updated|Your Obsidian installer'
            echo ""
        done
        ;;
esac
