#!/usr/bin/env bash
set -euo pipefail

TIMELINE_FILE=TIMELINE.md
if [ ! -f "$TIMELINE_FILE" ]; then
  echo "# Project Timeline" > "$TIMELINE_FILE"
  git add "$TIMELINE_FILE"
  git commit -m "Add TIMELINE.md" || true
fi

AUTHOR_NAME="${AUTHOR_NAME:-$(git config user.name || echo 'Unknown')}"
AUTHOR_EMAIL="${AUTHOR_EMAIL:-$(git config user.email || echo '')}"

if [ -z "$AUTHOR_EMAIL" ]; then
  echo "Warning: no author email configured. Set AUTHOR_EMAIL env var to the email associated with your GitHub account or your GitHub noreply email." >&2
fi

# Generate 200 evenly-spaced dates across 2025 at noon UTC
DATES=$(python3 - <<'PY'
import datetime
year=2025
count=200
start=datetime.date(year,1,1)
dates=[]
for i in range(count):
    idx = int(i * 364 / (count-1))
    d = start + datetime.timedelta(days=idx)
    dates.append(d.strftime('%Y-%m-%dT12:00:00'))
print('\n'.join(dates))
PY
)

i=1
for D in $DATES; do
  echo "- 200-day backdated change ${i} (${D})" >> "$TIMELINE_FILE"
  git add "$TIMELINE_FILE"
  GIT_AUTHOR_NAME="$AUTHOR_NAME" GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL" GIT_AUTHOR_DATE="$D" \
    GIT_COMMITTER_NAME="$AUTHOR_NAME" GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL" GIT_COMMITTER_DATE="$D" \
    git commit -m "200-day commit ${i} (${D})" || true
  i=$((i+1))
done

echo "Created $((i-1)) backdated commits in 2025 as $AUTHOR_NAME <$AUTHOR_EMAIL>."
