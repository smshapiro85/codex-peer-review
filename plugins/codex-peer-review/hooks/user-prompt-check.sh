#!/bin/bash
# UserPromptSubmit hook: Identify requests likely needing peer review

# Try env var first (Claude Code 4.x+), fall back to stdin JSON
if [ -n "$CLAUDE_USER_PROMPT" ]; then
  USER_PROMPT="$CLAUDE_USER_PROMPT"
elif command -v jq &>/dev/null; then
  INPUT=$(cat)
  USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)
else
  # jq unavailable and no env var - safe default: always trigger reminder
  USER_PROMPT="trigger"
fi

# Keywords that suggest peer review would be valuable
PLAN_KEYWORDS="implement|design|architect|refactor|plan|build|create.*feature|add.*feature"
REVIEW_KEYWORDS="review|check|analyze|audit|security|performance"
BROAD_KEYWORDS="how should|what's the best|recommend|approach|strategy"

# Check if prompt matches patterns (case insensitive)
if [ -n "$USER_PROMPT" ] && echo "$USER_PROMPT" | grep -qiE "$PLAN_KEYWORDS|$REVIEW_KEYWORDS|$BROAD_KEYWORDS"; then
  cat << 'EOF'
**Peer Review Advisory:** This request may produce output that benefits from peer validation. Remember to dispatch to `codex-peer-review:codex-peer-reviewer` before presenting:
- Implementation plans or designs
- Code review findings
- Architecture recommendations
EOF
fi
