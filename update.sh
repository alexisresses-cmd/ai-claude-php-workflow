#!/usr/bin/env bash
# =============================================================================
# ai-claude-php-workflow — Update script
# Pulls latest changes from remote and reinstalls the config.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BOLD='\033[1m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${BLUE}  ai-claude-php-workflow — Update${NC}"
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ─── Step 1: Pull latest changes ──────────────────────────────────────────────

echo -e "${BOLD}Step 1 — Pull latest changes${NC}"

cd "$SCRIPT_DIR"

BEFORE=$(git rev-parse HEAD)
git pull origin main
AFTER=$(git rev-parse HEAD)

if [[ "$BEFORE" == "$AFTER" ]]; then
  echo -e "  ${GREEN}✓${NC}  Already up to date — no changes pulled"
  echo ""
  echo -e "  Nothing to reinstall."
  echo ""
  exit 0
fi

echo ""
echo -e "  ${GREEN}✓${NC}  Updated from ${BEFORE:0:7} to ${AFTER:0:7}"
echo ""
echo "  Changes:"
git log --oneline "${BEFORE}..${AFTER}" | sed 's/^/    /'
echo ""

# ─── Step 2: Reinstall ────────────────────────────────────────────────────────

echo -e "${BOLD}Step 2 — Reinstall config${NC}"
echo ""

bash "$SCRIPT_DIR/install.sh" --force
