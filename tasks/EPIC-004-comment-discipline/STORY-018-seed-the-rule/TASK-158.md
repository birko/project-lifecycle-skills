---
id: TASK-158
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-20
depends-on: [TASK-159]
blocks: []
findings: [DRILL-157-1]
pr: null
github-issue: null
jira-key: null
---

# Four more restatements in `skills-lint.sh`, and one comment that should exist and doesn't

## Context

Found by TASK-157's verification run — two cold readers applying this project's comment rule to
`.github/workflows/skills-lint.sh` on a fixture carrying the whole guide **minus the measurement table
only**, so no record of any prior verdict about the file was visible to them.

They are one task because they are one sweep of one file. The first is a different *kind* of defect
from the other four and is called out as such below, but splitting it would lose that both readers
found it independently in the same pass.

### The one that is not a restatement — `:22`, and **both readers found it**

```sh
RUNTIME_REFS=" init update-config Explore "
```

Check 2 accepts these three names as valid `[[link]]` targets with no skill folder behind them.
**Why lives nowhere** — not in the code, not in the banner, not in `AGENTS.md`. The rule's `nowhere`
row says that is the one case which survives, *"at whatever length it takes"* — so here it should be
**written**, not deleted.

**Reader I declined to draft it, and the reason is the point:** the fixture held only the guide and
the lint, so it could not verify what actually links to `init`, `update-config` and `Explore`, and
*"guessing it into the file would be worse than the gap."* That is the only-copy discipline applied to
a comment that does not exist yet. Whoever takes this needs to establish what those three names are
and why they have no folder — `init` and `update-config` are runtime-provided Claude Code skills and
`Explore` is an agent type, but **that must be confirmed, not assumed from this sentence.**

### Four restatements

| Site | Finding | Found by |
|---|---|---|
| `:166` | `# $1 = file` restates the signature; `[ -f "$1" ]` on the next line already says it. Not a doc comment, so the published-output carve-out does not apply. **The second sentence — that empty output means "no delimited block here" — is real content and stays** | I |
| `:10` | `# Run locally: bash .github/workflows/skills-lint.sh` — recoverable from the shebang plus the file's own path. **⚠ Blocked on D15**: its other half (*also in `AGENTS.md` § Commands*) presumes the guide is a destination, which the table does not say — see TASK-159. The code-restatement half stands on its own either way | I |
| `:149` | first clause restates `:117-121`, which **explicitly claims ownership** of that mechanic. Only the first clause duplicates — the `well--known` false positive is new and must stay | I |
| `:295-296` | the closing sentence restates the branch below it | J |

## Acceptance criteria

- [ ] **`:10` is judged only after D15 is stamped** (TASK-159). Its *restates the code* half stands regardless; its *restates the guide* half is exactly the question D15 asks, and ticking it now would settle a decision by implementation.
- [ ] `:22` gains a comment stating why those three names resolve without a skill folder, **verified against what actually links to them** — not inferred from this task's own parenthetical.
- [ ] Each of the four restatements is acted on or dismissed **with a reason recorded**; "left as is" alone does not close this.
- [ ] `:166` keeps its second sentence, `:149` keeps the `well--known` case. A fix that deletes the whole comment at either site has removed content that lives nowhere.
- [ ] Every deletion names the destination that holds the content, **verified rather than asserted** — TASK-157 found two of its six destinations mis-filed in its own context table, so this is not a formality.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- `:158-161` and `:198-202` — **TASK-154**, confirmed independently by both readers on a fixture with no record of that verdict.
- The six sites TASK-157 cut, and the header contradiction it introduced and fixed in the same task.
- `AGENTS.md`'s stale *"check 5"* for install-root drift — **TASK-081**.

## Human test plan

- [ ] Two cold readers on the same minus-the-table fixture. Expected: these five are gone, TASK-154's two still reported, and the survivors TASK-151 and TASK-157 both protected still untouched.
- [ ] Expected failure to watch for at `:22`: a comment that sounds authoritative about why those three names are exempt but was never checked against the linking sites. A confidently wrong *nowhere* comment is worse than the gap, because the next reader has no reason to doubt it.

## Implementation plan

_Populated by `/tasks plan TASK-158` — leave empty until then._
