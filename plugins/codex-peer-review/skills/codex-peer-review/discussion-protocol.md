# Discussion Protocol: Claude vs Codex

Structured 3-round resolution of disagreements through evidence-based discussion.

## Protocol Rules

### Rule 1: Evidence Required (When Available)
Every position should cite evidence from these categories **as applicable**:
- Specific code lines or files (for code review discussions)
- Project conventions (from CLAUDE.md or equivalent)
- Industry best practices (with source)
- Test results or behavior observations

**For design/architecture discussions** where code doesn't exist yet, acceptable evidence includes:
- Analogous patterns from existing codebase
- Industry case studies or engineering blog posts
- Framework/language documentation
- Threat modeling or risk analysis
- RFCs or design documents

### Rule 2: Three Round Maximum
- Round 1: State positions, provide evidence
- Round 2: Respond to evidence, attempt synthesis
- Round 3: Final evidence, last attempt at resolution
- After Round 3: Present both positions to user if unresolved

### Rule 3: Good Faith
- Assume the other AI has valid reasoning
- Look for complementary insights
- Seek "both right in different ways" resolutions

### Rule 4: Session Continuity
- **Capture session ID** from Round 1 using `codex exec --json` (look for `thread_id` in output)
- **Resume session** in subsequent rounds using `codex exec resume [SESSION_ID]`
- This maintains conversation context so Codex remembers prior discussion
- Without session continuity, later rounds start fresh and lose valuable context

### Rule 5: Output Protection
- **All `codex exec` invocations** must include `timeout 120`, `head -c 500000`, and the tool-prevention suffix
- End every prompt with: `IMPORTANT: Do not use any tools. Respond with text analysis only.`
- Use `mktemp` for all temporary files — never use static `/tmp/codex_*` paths
- Clean up temp files after reading with `rm -f`
- Embed code content directly in prompts instead of referencing file paths

### Rule 6: Classify Disagreement Type

| Type | Definition | Action |
|------|------------|--------|
| Contradiction | Mutually exclusive positions | Must resolve one way |
| Complement | Both valid, additive | Synthesize both |
| Priority | Different ranking of same issues | Use project context |
| Scope | Different interpretation of task | Clarify before proceeding |

## Round 1 Structure

### Claude's Opening
```yaml
position: "[Clear statement of recommendation]"
evidence:
  - code: "[specific file:line or pattern]"
  - convention: "[from project standards]"
  - rationale: "[technical reasoning]"
confidence: "[high|medium|low]"
open_to: "[what evidence would change your mind]"
```

### Codex's Response (via subagent)
```yaml
position: "[Clear statement]"
agreement_areas: "[where aligned with Claude]"
disagreement_areas: "[where divergent]"
counter_evidence:
  - code: "[specific reference]"
  - rationale: "[technical reasoning]"
```

### Round 1 Outcome
```yaml
outcome: "[resolved|unresolved]"
synthesis: "[if resolved, the merged view]"
remaining_issues: "[if unresolved, specific points to address]"
```

## Round 2 Structure

### Focus
Address ONLY `remaining_issues` from Round 1. No new topics.

### Claude's Response
```yaml
addressing: "[specific remaining issue]"
new_evidence: "[something not presented in Round 1]"
concession: "[what I now agree with from Codex]"
maintained: "[what I still believe, with stronger reasoning]"
```

### Codex's Response
```yaml
addressing: "[specific remaining issue]"
response_to_evidence: "[how new evidence changes or confirms view]"
proposed_synthesis: "[attempt to merge positions]"
```

### Round 2 Outcome
```yaml
outcome: "[resolved|continue]"
final_synthesis: "[if resolved, the agreed approach]"
remaining_issues: "[if continuing, specific points for Round 3]"
```

## Round 3 Structure

### Focus
Final attempt at resolution. Address ONLY `remaining_issues` from Round 2. Present strongest evidence.

### Claude's Response
```yaml
addressing: "[specific remaining issue]"
final_evidence: "[strongest evidence not yet presented]"
key_concession: "[what Claude now accepts from Codex]"
core_position: "[Claude's refined final stance]"
```

### Codex's Response
```yaml
addressing: "[specific remaining issue]"
response_to_evidence: "[how final evidence changes or confirms view]"
proposed_synthesis: "[final attempt to merge positions]"
final_position: "[Codex's refined final stance if no synthesis]"
```

### Round 3 Outcome
```yaml
outcome: "[resolved|unresolved]"
final_synthesis: "[if resolved, the agreed approach]"
claude_position: "[if unresolved, Claude's final stance]"
codex_position: "[if unresolved, Codex's final stance]"
```

## Example Discussion

### Setup
- Claude: "This function should use a Result/Either type for error handling"
- Codex: "The current exception-based approach is clearer for this codebase"

### Round 1

**Claude:**
```yaml
position: "Use Result type for explicit error handling"
evidence:
  - code: "user_service.py:45 returns None on not-found"
  - convention: "Project uses type hints extensively"
  - rationale: "Result types are more expressive and statically checkable"
confidence: "high"
open_to: "Performance concerns or team familiarity arguments"
```

**Codex:**
```yaml
position: "Keep exception-based error handling"
agreement_areas: "Explicit error handling is important"
disagreement_areas: "Implementation approach"
counter_evidence:
  - code: "Other methods in user_service use exceptions consistently"
  - rationale: "Consistency within module aids readability"
```

**Round 1 Outcome:**
```yaml
outcome: "unresolved"
synthesis: null
remaining_issues:
  - "Module consistency vs modern idiom adoption"
```

### Round 2

**Claude:**
```yaml
addressing: "Module consistency vs modern idiom"
new_evidence: "Git history shows 3 commits in last month adopting Result types elsewhere"
concession: "Consistency matters for readability"
maintained: "Migration is already underway, this continues the pattern"
```

**Codex:**
```yaml
addressing: "Module consistency vs modern idiom"
response_to_evidence: "Migration trend is valid context I missed"
proposed_synthesis: "Use Result type here, add TODO for full module migration"
```

**Round 2 Outcome:**
```yaml
outcome: "resolved"
final_synthesis: "Use Result type with TODO comment for module-wide migration"
```

## When Discussion Fails

If after Round 3:
- Positions remain fundamentally opposed
- Evidence is inconclusive on both sides
- Neither AI can provide decisive new evidence

Then present both positions to the user and let them decide:

```
## Unresolved Disagreement

Both AIs reviewed this and could not reach consensus after 3 rounds of discussion.

**Claude's position:** [summary with key evidence]
**Codex's position:** [summary with key evidence]

**Where they agree:** [common ground]
**Where they differ:** [core disagreement]

**Your call:** [what the user needs to decide, framed as a clear choice]
```

## Anti-Patterns

### Bad Discussion
- **Echo Chamber:** Restating positions without new evidence
- **Goalpost Moving:** Changing the disagreement mid-discussion
- **Appeal to Authority:** "Codex/Claude is usually right"
- **False Consensus:** Claiming agreement without actual alignment

### Good Discussion
- **Evidence-Based:** Every claim backed by code or standards
- **Focused:** One issue at a time
- **Constructive:** Seeking synthesis, not victory
- **Honest:** Acknowledging uncertainty and conceding valid points
