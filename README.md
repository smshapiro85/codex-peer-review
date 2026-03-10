# Codex Peer Review

A Claude Code plugin that validates Claude's work using OpenAI Codex CLI — two AI perspectives catch more issues than one.

Forked from [jcputney/agent-peer-review](https://github.com/jcputney/agent-peer-review).

## What This Fork Changes

- **3-round discussion protocol** — more chances to resolve disagreements before involving the user
- **No external escalation** — when rounds fail, both AI positions are presented for the user to decide (no Perplexity/WebSearch arbitration)
- **Output protection** — timeout, output caps, and tool-prevention safeguards on all Codex invocations

## Installation

```bash
/plugin marketplace add <this-repo>
/plugin install codex-peer-review
```

### Prerequisites

- **Claude Code** with Pro, Max, Team Premium, or Enterprise subscription
- **Codex CLI**: `npm i -g @openai/codex` then `codex login`

### Data Sharing

This plugin sends code, designs, and review prompts to **OpenAI's Codex API** for peer review. No data is sent unless Codex CLI is installed and authenticated. Ensure your usage policies permit sending codebase content to OpenAI.

## License

MIT
