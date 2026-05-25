#!/usr/bin/env bash
set -euo pipefail

# Create a TIMELINE.md if missing
TIMELINE_FILE=TIMELINE.md
if [ ! -f "$TIMELINE_FILE" ]; then
  echo "# Project Timeline" > "$TIMELINE_FILE"
  git add "$TIMELINE_FILE"
  git commit -m "Add TIMELINE.md" || true
fi

# Allow overriding author name/email via env vars
AUTHOR_NAME="${AUTHOR_NAME:-$(git config user.name || echo 'Unknown') }"
AUTHOR_EMAIL="${AUTHOR_EMAIL:-$(git config user.email || echo '')}"

if [ -z "$AUTHOR_EMAIL" ]; then
  echo "Warning: no author email configured. Set AUTHOR_EMAIL env var to the email associated with your GitHub account or your GitHub noreply email." >&2
fi

# Default dates (spread across 2025). If EXTRA=1, add more unique dates.
DATES=(
  "2025-01-15T10:00:00"
  "2025-02-20T11:00:00"
  "2025-03-25T12:00:00"
  "2025-04-30T13:00:00"
  "2025-05-25T14:00:00"
  "2025-06-30T15:00:00"
  "2025-07-15T16:00:00"
  "2025-08-04T09:30:00"
  "2025-10-12T13:00:00"
  "2025-12-01T18:00:00"
)

if [ "${EXTRA:-0}" = "1" ]; then
  EXTRA_DATES=(
    "2025-01-10T09:00:00"
    "2025-01-20T11:30:00"
    "2025-02-05T08:15:00"
    "2025-03-03T10:45:00"
    "2025-04-07T14:20:00"
    "2025-05-09T16:40:00"
    "2025-06-11T12:10:00"
    "2025-07-13T09:05:00"
    "2025-09-02T17:00:00"
    "2025-11-18T19:30:00"
  )
  DATES=("${DATES[@]}" "${EXTRA_DATES[@]}")
fi

COUNTER=1
for D in "${DATES[@]}"; do
  echo "- Backdated change ${COUNTER} (${D})" >> "$TIMELINE_FILE"
  git add "$TIMELINE_FILE"
  GIT_AUTHOR_NAME="$AUTHOR_NAME" GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL" GIT_AUTHOR_DATE="$D" \
    GIT_COMMITTER_NAME="$AUTHOR_NAME" GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL" GIT_COMMITTER_DATE="$D" \
    git commit -m "Backdated commit ${COUNTER} (${D})" || true
  COUNTER=$((COUNTER+1))
done

echo "Created ${COUNTER} backdated commits (including initial file commit) as $AUTHOR_NAME <$AUTHOR_EMAIL>."
