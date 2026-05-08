#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <file-path> [branch]"
  exit 1
fi

FILE="$1"
BRANCH="${2:-main}"

# If this is the azure-rest-api-specs-pr repo, default branch to RPSaaSMaster
if [ "${2:-}" == "" ]; then
  REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
  if [ "$REPO_NAME" == "azure-rest-api-specs-pr" ]; then
    BRANCH="RPSaaSMaster"
  fi
fi

# Ensure repo is up to date
git fetch origin "$BRANCH" >/dev/null 2>&1 || true

echo "🔍 Finding first commit that introduced: $FILE (on $BRANCH)"

# Step 1: find first commit that added the file
# Note: --follow is intentionally omitted because rename detection can produce
# false positives in large repos with many similarly-structured files.
SHA=$(git log "origin/$BRANCH" \
  --diff-filter=A \
  --format=%H \
  -- "$FILE" | tail -n 1)

if [ -z "$SHA" ]; then
  echo "❌ No commit found introducing $FILE"
  exit 1
fi

echo "✅ First commit: $SHA"

# Step 2: find PR(s) containing this commit
echo "🔍 Searching for PR containing commit..."

PRS_JSON=$(gh pr list \
  --search "$SHA" \
  --state merged \
  --json number,title,mergedAt,baseRefName,url \
  || echo "[]")

# Filter for PRs merged into our branch
PR=$(echo "$PRS_JSON" | jq -r \
  --arg BR "$BRANCH" '
  map(select(.baseRefName == $BR))
  | sort_by(.mergedAt)
  | .[0]
')

if [ "$PR" = "null" ] || [ -z "$PR" ]; then
  echo "⚠️ No PR found (file may have been added via direct push)"
  exit 0
fi

echo "✅ PR found:"
echo "$PR" | jq -r '"PR #\(.number): \(.title)\n\(.url)"'

# Now open the PR in the browser
PR_URL=$(echo "$PR" | jq -r '.url')
if [ -n "$PR_URL" ]; then
  echo "🌐 Opening PR in browser: $PR_URL"
  xdg-open "$PR_URL" >/dev/null 2>&1 || open "$PR_URL" >/dev/null 2>&1 || echo "⚠️ Could not open browser"
fi
