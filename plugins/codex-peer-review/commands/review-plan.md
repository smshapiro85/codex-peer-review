---
name: review-plan
description: Send a plan or design from the current conversation to Codex for peer review. Extracts the plan from conversation context automatically.
---

# Review Plan Command

You have been explicitly asked to send a plan, design, or recommendation from the current conversation to Codex for peer review validation.

## Parse Arguments

Check for arguments in the command:
- `/review-plan` - Auto-detect and extract the most recent plan from conversation
- `/review-plan <focus>` - Extract the plan, with a specific focus area for the review

## Step 1: Extract the Plan from Conversation Context

**You are running in the main conversation context and CAN see the full conversation history.**

Search backwards through the conversation for the **most recently generated** plan, design, or recommendation from Claude. Look for:

- Implementation plans (numbered steps, phases, task breakdowns)
- Architecture designs or proposals
- Refactoring strategies
- Migration plans
- Design decisions with trade-offs
- Any structured recommendation Claude made

**IMPORTANT — Multiple plans:** If the conversation contains more than one plan (e.g., Claude generated a plan, the user asked for revisions, and Claude generated an updated plan), extract ONLY the most recent one. Ignore all earlier versions. The most recent plan is the one closest to the end of the conversation history.

**Extract the FULL plan content** — not a summary, not a reference, but the actual text. Include:
- All steps/phases/tasks
- Code snippets if they were part of the plan
- Trade-offs or alternatives that were discussed
- Any constraints or assumptions mentioned

If no plan is found in the conversation, inform the user:
"No plan or design found in the current conversation. Generate a plan first, then run this command to have it peer reviewed."

**Do NOT proceed to Step 2 if no plan was found.**

## Step 2: Confirm What Was Found

Before dispatching, briefly tell the user what you found:
"Found a plan: **[1-line description of the plan]** ([N] steps/phases). Sending to Codex for peer review..."

Do NOT ask for confirmation — just inform and proceed.

## Step 3: Dispatch to Agent

Dispatch to the `codex-peer-reviewer` agent with the full plan content embedded:

```
Use Agent tool:
  subagent_type: "codex-peer-review:codex-peer-reviewer"
  prompt: |
    Run peer review validation on Claude's plan.

    Type: design
    Focus: [focus area from arguments, or "general plan review"]

    Claude's plan (extracted from conversation):
    ---
    [THE FULL PLAN TEXT — paste every line, do not summarize]
    ---

    Validate this plan using `codex exec`. Embed the full plan text above
    in the codex exec heredoc prompt. Do NOT reference conversation context
    or file paths — the plan content is everything between the --- markers above.

    Ask Codex to evaluate:
    1. Completeness — are any steps missing?
    2. Ordering — are dependencies handled correctly?
    3. Risk — what could go wrong?
    4. Alternatives — is there a better approach?
    5. Feasibility — are any steps unrealistic or overly complex?

    Return the synthesized peer review result.
```

**CRITICAL:** The subagent has NO access to conversation history. Everything it needs must be in the prompt above. If the plan references specific files, use the `Read` tool to get their contents and include relevant snippets in the dispatch.

## Step 4: Present Results

The agent will return a synthesized result. Present it to the user:
- **Validated**: Codex agreed the plan is sound
- **Suggestions**: Codex proposed improvements (list them)
- **Concerns**: Codex identified risks or issues (list them with severity)
- **Alternative**: Codex recommended a different approach (present both for user decision)
