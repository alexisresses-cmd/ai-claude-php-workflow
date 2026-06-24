#!/usr/bin/env bash
# =============================================================================
# ai-claude-php-workflow — Installation script
# Non-destructive: skips files that already exist unless --force is passed.
# Merges settings.json intelligently (adds permissions, doesn't replace).
# =============================================================================

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Config ───────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
FORCE=false
INSTALL_CLI=false
SKIPPED=0
INSTALLED=0
ERRORS=0

# ─── Args parsing ─────────────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --force)   FORCE=true ;;
    --cli)     INSTALL_CLI=true ;;
    --help|-h) show_help; exit 0 ;;
  esac
done

show_help() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Options:
  --force    Overwrite existing files (default: skip existing)
  --cli      Also attempt to install Claude Code CLI
  --help     Show this help message

Examples:
  ./install.sh            # Install config only, skip existing files
  ./install.sh --force    # Install config, overwrite existing files
  ./install.sh --cli      # Install CLI + config
EOF
}

# ─── Helpers ──────────────────────────────────────────────────────────────────
print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${BLUE}  ai-claude-php-workflow — Installer${NC}"
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

log_ok()   { echo -e "  ${GREEN}✓${NC}  $1"; ((INSTALLED++)) || true; }
log_skip() { echo -e "  ${YELLOW}→${NC}  $1 ${YELLOW}(already exists, skipped)${NC}"; ((SKIPPED++)) || true; }
log_err()  { echo -e "  ${RED}✗${NC}  $1"; ((ERRORS++)) || true; }
log_info() { echo -e "  ${BLUE}ℹ${NC}  $1"; }

# Copy a file — skip if exists unless --force
install_file() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [[ -f "$dst" ]] && [[ "$FORCE" == "false" ]]; then
    log_skip "$(basename "$dst") → ${dst#$HOME/}"
    return
  fi

  if [[ -f "$dst" ]] && [[ "$FORCE" == "true" ]]; then
    cp "$dst" "${dst}.bak" 2>/dev/null || true
  fi

  if cp "$src" "$dst"; then
    log_ok "$(basename "$dst") → ${dst#$HOME/}"
  else
    log_err "Failed to copy $(basename "$src")"
  fi
}

# Copy a directory recursively
install_dir() {
  local src_dir="$1"
  local dst_dir="$2"
  local name="$3"

  if [[ ! -d "$src_dir" ]]; then
    return
  fi

  mkdir -p "$dst_dir"

  while IFS= read -r -d '' file; do
    local rel="${file#$src_dir/}"
    install_file "$file" "$dst_dir/$rel"
  done < <(find "$src_dir" -type f -print0)
}

# Merge settings.json — add our deny rules without overwriting existing config
merge_settings() {
  local src="$SCRIPT_DIR/settings.json"
  local dst="$CLAUDE_DIR/settings.json"

  if [[ ! -f "$src" ]]; then
    log_err "settings.json not found in repo"
    return
  fi

  if [[ ! -f "$dst" ]]; then
    cp "$src" "$dst"
    log_ok "settings.json created"
    return
  fi

  # Check if jq is available for smart merge
  if command -v jq &>/dev/null; then
    # Backup existing
    cp "$dst" "${dst}.bak"

    # Merge: keep existing config, add our deny rules if not present
    local merged
    merged=$(jq -s '
      .[0] as $existing |
      .[1] as $new |
      $existing * {
        "permissions": {
          "allow": (($existing.permissions.allow // []) | unique),
          "deny": (($existing.permissions.deny // []) + ($new.permissions.deny // []) | unique)
        }
      }
    ' "$dst" "$src")

    echo "$merged" > "$dst"
    log_ok "settings.json merged (jq) — backup at settings.json.bak"
  else
    # No jq: skip merge, just report
    log_skip "settings.json (jq not found — manual merge required)"
    log_info "To merge manually, compare ${dst} with ${src}"
  fi
}

# ─── Step 1: Claude Code CLI (optional) ───────────────────────────────────────
install_cli() {
  echo -e "${BOLD}Step 1 — Claude Code CLI${NC}"

  if command -v claude &>/dev/null; then
    log_info "Claude Code CLI already installed: $(claude --version 2>/dev/null || echo 'version unknown')"
    return
  fi

  if [[ "$INSTALL_CLI" == "false" ]]; then
    log_info "Skipping CLI install (use --cli to install it)"
    log_info "Install manually: npm install -g @anthropic-ai/claude-code"
    return
  fi

  echo ""
  log_info "Attempting to install Claude Code CLI..."

  if command -v npm &>/dev/null; then
    npm install -g @anthropic-ai/claude-code && log_ok "Claude Code CLI installed via npm"
  elif command -v brew &>/dev/null; then
    brew install claude-code && log_ok "Claude Code CLI installed via brew"
  else
    log_err "Neither npm nor brew found. Install manually:"
    log_info "  npm install -g @anthropic-ai/claude-code"
    log_info "  brew install claude-code"
  fi
}

# ─── Step 2: Create ~/.claude structure ───────────────────────────────────────
create_structure() {
  echo ""
  echo -e "${BOLD}Step 2 — Directory structure${NC}"

  for dir in \
    "$CLAUDE_DIR" \
    "$CLAUDE_DIR/skills" \
    "$CLAUDE_DIR/commands"; do
    if mkdir -p "$dir" 2>/dev/null; then
      : # silent
    fi
  done

  log_ok "~/.claude structure ready"
}

# ─── Step 3: Install skills ───────────────────────────────────────────────────
install_skills() {
  echo ""
  echo -e "${BOLD}Step 3 — Skills${NC}"

  local skills_src="$SCRIPT_DIR/skills"
  local skills_dst="$CLAUDE_DIR/skills"

  if [[ ! -d "$skills_src" ]]; then
    log_err "skills/ directory not found in repo"
    return
  fi

  # Install each skill directory
  for skill_dir in "$skills_src"/*/; do
    local skill_name
    skill_name=$(basename "$skill_dir")
    install_dir "$skill_dir" "$skills_dst/$skill_name" "$skill_name"
  done
}

# ─── Step 4: Install commands ─────────────────────────────────────────────────
install_commands() {
  echo ""
  echo -e "${BOLD}Step 4 — Commands${NC}"

  local commands_src="$SCRIPT_DIR/commands"
  local commands_dst="$CLAUDE_DIR/commands"

  if [[ ! -d "$commands_src" ]]; then
    log_err "commands/ directory not found in repo"
    return
  fi

  for cmd_file in "$commands_src"/*.md; do
    [[ -f "$cmd_file" ]] || continue
    install_file "$cmd_file" "$commands_dst/$(basename "$cmd_file")"
  done
}

# ─── Step 5: Merge settings ───────────────────────────────────────────────────
install_settings() {
  echo ""
  echo -e "${BOLD}Step 5 — Settings${NC}"
  merge_settings
}

# ─── Step 6: Verify dependencies ──────────────────────────────────────────────
check_dependencies() {
  echo ""
  echo -e "${BOLD}Step 6 — Dependencies check${NC}"

  # Claude Code CLI
  if command -v claude &>/dev/null; then
    log_ok "claude CLI — $(claude --version 2>/dev/null || echo 'installed')"
  else
    log_err "claude CLI — not found (run: npm install -g @anthropic-ai/claude-code)"
  fi

  # git
  if command -v git &>/dev/null; then
    log_ok "git — $(git --version)"
  else
    log_err "git — not found"
  fi

  # gh CLI (GitHub)
  if command -v gh &>/dev/null; then
    log_ok "gh CLI — $(gh --version | head -1)"
  else
    log_skip "gh CLI — not found (optional, needed for GitHub Issues integration)"
    log_info "  Install: https://cli.github.com/"
  fi

  # jq (for settings merge)
  if command -v jq &>/dev/null; then
    log_ok "jq — $(jq --version)"
  else
    log_skip "jq — not found (optional, used for settings.json merge)"
    log_info "  Install: apt install jq / brew install jq"
  fi
}

# ─── Summary ──────────────────────────────────────────────────────────────────
print_summary() {
  echo ""
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  Installation summary${NC}"
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${GREEN}Installed${NC} : $INSTALLED files"
  echo -e "  ${YELLOW}Skipped${NC}   : $SKIPPED files (already exist)"
  if [[ $ERRORS -gt 0 ]]; then
    echo -e "  ${RED}Errors${NC}    : $ERRORS"
  fi
  echo ""

  if [[ $ERRORS -eq 0 ]]; then
    echo -e "${BOLD}${GREEN}✅ Installation complete!${NC}"
    echo ""
    echo -e "  Next steps:"
    echo -e "  1. Copy ${BOLD}CLAUDE.template.md${NC} to your project as ${BOLD}CLAUDE.md${NC}"
    echo -e "     and fill in your project-specific config."
    echo ""
    echo -e "  2. Add ${BOLD}analysis/${NC} to your project's ${BOLD}.gitignore${NC}"
    echo -e "     (or keep it versioned — your choice)."
    echo ""
    echo -e "  3. Start a new ticket in orchestra mode:"
    echo -e "     ${BOLD}/dev-analyse {ticket-url-or-text}${NC}"
    echo ""
    echo -e "  4. Or in sequential mode:"
    echo -e "     ${BOLD}/dev-plan {description}${NC}"
    echo ""
    echo -e "  📖 Docs: docs/orchestra-mode.md | docs/sequential-mode.md"
  else
    echo -e "${BOLD}${RED}⚠️  Installation finished with errors. Check above.${NC}"
  fi
  echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────
print_header

if [[ "$FORCE" == "true" ]]; then
  echo -e "  ${YELLOW}--force mode: existing files will be overwritten (backups created as .bak)${NC}"
  echo ""
fi

install_cli
create_structure
install_skills
install_commands
install_settings
check_dependencies
print_summary
