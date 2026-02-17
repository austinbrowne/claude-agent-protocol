#!/usr/bin/env bash
set -euo pipefail

# bump-version.sh — Bump version on feature branch + marketplace on main
#
# Usage:
#   ./scripts/bump-version.sh <version> [feature-branch] [description]
#
# Examples:
#   ./scripts/bump-version.sh 5.9.0-experimental
#   ./scripts/bump-version.sh 5.9.0-experimental experimental-agent-teams
#   ./scripts/bump-version.sh 5.9.0-experimental experimental-agent-teams "v5.9.0: New feature description."
#
# What it does:
#   1. On <feature-branch>: updates plugin.json + marketplace.json version, commits, pushes
#   2. On main: updates marketplace.json version + description, commits, pushes
#   3. Returns to original branch

VERSION="${1:-}"
FEATURE_BRANCH="${2:-experimental-agent-teams}"
EXTRA_DESC="${3:-}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: ./scripts/bump-version.sh <version> [feature-branch] [description]"
  echo ""
  echo "  version          e.g. 5.9.0-experimental"
  echo "  feature-branch   default: experimental-agent-teams"
  echo "  description      optional: appended to marketplace description"
  exit 1
fi

ORIGINAL_BRANCH=$(git branch --show-current)

# Ensure clean working tree
if ! git diff --quiet || ! git diff --staged --quiet; then
  echo "ERROR: Working tree is dirty. Commit or stash changes first."
  exit 1
fi

echo "=== Bumping to v${VERSION} ==="
echo "Feature branch: ${FEATURE_BRANCH}"
echo "Original branch: ${ORIGINAL_BRANCH}"
echo ""

# --- Feature branch: plugin.json + marketplace.json ---
echo "--- Updating ${FEATURE_BRANCH} ---"
git checkout "${FEATURE_BRANCH}"
git pull --ff-only origin "${FEATURE_BRANCH}" 2>/dev/null || true

# Update plugin.json version
if command -v jq &>/dev/null; then
  jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > /tmp/plugin.json.tmp
  mv /tmp/plugin.json.tmp .claude-plugin/plugin.json
else
  sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"${VERSION}\"/" .claude-plugin/plugin.json
fi
echo "  plugin.json → ${VERSION}"

# Update marketplace.json version
if command -v jq &>/dev/null; then
  jq --arg v "$VERSION" '.plugins[0].version = $v' .claude-plugin/marketplace.json > /tmp/marketplace.json.tmp
  mv /tmp/marketplace.json.tmp .claude-plugin/marketplace.json
else
  # Match the version line inside plugins array
  sed -i '' "s/\"version\": \"[^\"]*-experimental\"/\"version\": \"${VERSION}\"/" .claude-plugin/marketplace.json
fi

# Update marketplace.json description version prefix
sed -i '' "s/GODMODE v[0-9.]*-experimental/GODMODE v${VERSION}/" .claude-plugin/marketplace.json

# Append extra description if provided
if [[ -n "$EXTRA_DESC" ]]; then
  # Append before closing quote of description
  python3 -c "
import json, sys
with open('.claude-plugin/marketplace.json') as f:
    data = json.load(f)
desc = data['plugins'][0]['description']
# Remove trailing period if present, append new desc
desc = desc.rstrip('.')
desc += '. ${EXTRA_DESC}'
data['plugins'][0]['description'] = desc
with open('.claude-plugin/marketplace.json', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" 2>/dev/null || echo "  WARNING: Could not append description (python3 not available)"
fi
echo "  marketplace.json → ${VERSION}"

git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: bump version to ${VERSION}"
git push origin "${FEATURE_BRANCH}"
echo "  Pushed to ${FEATURE_BRANCH}"
echo ""

# --- Main branch: marketplace.json only ---
echo "--- Updating main ---"
git checkout main
git pull --ff-only origin main 2>/dev/null || true

# Copy marketplace.json from feature branch
git show "${FEATURE_BRANCH}:.claude-plugin/marketplace.json" > .claude-plugin/marketplace.json

git add .claude-plugin/marketplace.json
git commit -m "chore: bump marketplace version to ${VERSION}"
git push origin main
echo "  Pushed to main"
echo ""

# --- Return to original branch ---
git checkout "${ORIGINAL_BRANCH}"
echo "=== Done. v${VERSION} pushed to ${FEATURE_BRANCH} + main ==="
