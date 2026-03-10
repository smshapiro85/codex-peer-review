# Codex Peer Review

A Claude Code plugin that validates Claude's work using OpenAI Codex CLI — two AI perspectives catch more issues than one.

Forked from [jcputney/agent-peer-review](https://github.com/jcputney/agent-peer-review).

## What This Fork Changes

### Security Hardening
- **Output protection on every Codex invocation** — `timeout 120`, `head -c 500000` (500KB cap), and a tool-prevention suffix that blocks Codex from running tools in full-auto mode
- **Content embedding, not path references** — file contents are pasted into prompts so Codex never gets the opportunity to read arbitrary files
- **Explicit tool allow-list** — the peer review agent only has access to 16 approved Bash patterns; no arbitrary shell, no network tools, no file editing
- **Random temp files** — all temp files use `mktemp` with random suffixes to prevent path-prediction attacks and collisions

### Operational Improvements
- **No raw JSONL in context** — Codex output streams to a temp file and a cheap model (`gpt-5.3-codex-spark`) summarizes it, so massive review output never pollutes the conversation
- **Live progress monitoring** — reviews run in the background with a polling loop that updates a spinner with real-time status
- **Session continuity across discussion rounds** — captures Codex thread IDs so Round 2 and 3 resume the same conversation instead of starting fresh
- **Base branch validation** — always asks the user which branch to compare against; never guesses

### Discussion Protocol
- **3-round structured discussion** — more chances to resolve disagreements through evidence before involving the user (original had 2 rounds)
- **No external escalation** — removed Perplexity/WebSearch arbitration entirely; when 3 rounds fail, both AI positions are presented for the user to decide
- **Disagreement classification** — categorizes conflicts (contradiction, complement, priority, scope) to focus discussion on what actually matters

### Guidance & Guardrails
- **Comprehensive anti-pattern documentation** — 8 categories of common mistakes with "rationalization vs. reality" tables and recovery strategies
- **Red flag checklist** — 9 warning signs (e.g. "this doesn't need validation", "security issue is probably fine") that trigger self-correction
- **Advisory hooks, not enforcing** — slimmed down from aggressive hooks on every tool call to keyword-gated reminders that respect user autonomy

## Usage

### Review Code Changes

```
/codex-peer-review                  # Interactive — asks what to review
/codex-peer-review --base main      # Review changes against a branch
/codex-peer-review --uncommitted    # Review staged/unstaged changes only
/codex-peer-review --commit abc123  # Review a specific commit
/codex-peer-review <question>       # Validate a broad technical question
```

### Review a Plan from the Current Conversation

```
/review-plan                        # Auto-extract the most recent plan and send to Codex
/review-plan security               # Review the plan with a specific focus area
```

Use `/review-plan` after Claude generates an implementation plan, architecture design, or refactoring strategy. It extracts the most recent plan from your conversation context, sends it directly to Codex for review (skipping Claude opinion formation), and returns Codex's findings on completeness, ordering, risk, alternatives, and feasibility.

## Installation

```bash
/plugin marketplace add smshapiro85/codex-peer-review
/plugin install codex-peer-review@agent-peer-review-marketplace
```

### Prerequisites

- **Claude Code** with Pro, Max, Team Premium, or Enterprise subscription
- **Codex CLI**: `npm i -g @openai/codex` then `codex login`

### Permissions

To run without confirmation prompts on every bash command, add the following to your `~/.claude/settings.json` under `permissions.allow`:

```json
{
  "permissions": {
    "allow": [
      "Bash(mktemp /tmp/codex_*)",
      "Bash(timeout *)",
      "Bash(codex exec*)",
      "Bash(codex review*)",
      "Bash(command -v codex*)",
      "Bash(command -v jq*)",
      "Bash(jq *)",
      "Bash(cat /tmp/codex_*)",
      "Bash(rm -f /tmp/codex_*)",
      "Bash(rm /tmp/codex_*)",
      "Bash(head *)",
      "Bash(git diff*)",
      "Bash(git show*)",
      "Bash(git log*)"
    ]
  }
}
```

If you already have a `permissions` block, merge the `allow` array into it. These patterns are narrowly scoped to Codex CLI operations and temp files in `/tmp/codex_*` — no arbitrary shell access, no file editing, no network tools.

### Data Sharing

This plugin sends code, designs, and review prompts to **OpenAI's Codex API** for peer review. No data is sent unless Codex CLI is installed and authenticated. Ensure your usage policies permit sending codebase content to OpenAI.

## License

MIT
