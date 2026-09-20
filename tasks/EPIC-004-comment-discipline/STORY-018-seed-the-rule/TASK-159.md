---
id: TASK-159
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: blocked
priority: P2
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: [TASK-158]
findings: [DRILL-154-1]
pr: null
github-issue: null
jira-key: null
---

# The destination table has no row for the project's own guide

## Context

Surfaced by TASK-154's verification run and then confirmed textually. **Blocked, not `todo`:** the fix
edits `CONVENTIONS-universal.md`, which ships byte-identical to every consumer and is lint-enforced by
check 5, so it is a FEATURE-002 decision (**D15**, `proposed`) rather than an edit. Implementing an
undecided row is the violation this repo names as coding without a task.

### The gap, checkable in three steps

1. **The table has five rows and the guide is not one of them:** *in the code itself* · *in version
   history* · *in the ticket* · *in a decision record — `docs/adr/`, the feature's `decisions.md`* ·
   *nowhere*.
2. **The rule text never mentions it.** Inside the `comment-rule` markers there is no occurrence of
   `CLAUDE.md`, `AGENTS.md`, *guide*, *rulebook* or *convention*. Verified by grep over `AGENTS.md`
   `:371-400`.
3. **This repo's own five-records table makes the guide a *distinct* record** from both `docs/adr/`
   and `docs/features/*/decisions.md` — *"`AGENTS.md § Conventions` | what we do now | the standing
   rule"* — and § Conventions states that rulebook entries mostly have **no** decision record, because
   *"a convention's footprint is the prose it will shape."*

So content living in the guide **has a home** — it is not *nowhere*, and the rule is explicit that
*nowhere* means no home rather than nobody-wrote-it-down — **yet no row says what to do about it.**

### Three readers have split on it, and one of them was me

| Reader | Handling |
|---|---|
| TASK-141 reader B | reported `:199-203`, destination **"a decision record"**, citing `CLAUDE.md:355-358` — i.e. mapped guide → decision record |
| TASK-157 reader I | reported `:10` as a violation citing `CLAUDE.md` § Commands |
| TASK-154 step-1 reader | **declined to report** `:11`, stating the guide is not one of the five rows and noting the five-records table puts § Conventions outside `docs/adr/` |

**And the mis-classification is already committed.** TASK-154 (`1932557`) relocated check 6's argument
to `AGENTS.md § Testing` and recorded the destination as *"a decision record"*. `### Testing` sits under
`## Conventions` — it is a rulebook entry, not a decision record. **The relocation is right; the row it
was filed under does not exist.** Present state of the script shows the split cleanly:

| Comment | Points at | Row that covers it |
|---|---|---|
| `:199` | `AGENTS.md § Testing` | **none** |
| `:160` | § *Where the same prose…* **+ FEATURE-002 D13** | half — D13 only |
| `:208` | `ADR 0010` | decision record ✓ |

### Why this is not cosmetic

Most cross-cutting content in this repo lives in the guide, by design — § Conventions is the record for
*what we do now*. Under the strict five-row reading, a comment may duplicate the rulebook indefinitely
and the check can never say so, which removes the axis from the majority of what it would otherwise
catch. Under the loose reading, every such finding is filed against a row that the project's own
taxonomy says is a different record.

## Acceptance criteria

- [ ] **D15 is stamped** by `/feature decide` before any file changes. The row is `proposed` today.
- [ ] Whichever way it goes, the rule says it **explicitly** — a reader must not have to infer from the absence of a row whether the guide counts.
- [ ] If a row is added: it goes in `CONVENTIONS-universal.md` **and** `AGENTS.md`, between the markers, byte-identical, or check 5 fails. That is the mechanism, not an afterthought.
- [ ] If a row is added: its action is stated (delete outright, or delete-or-pointer) — the existing rows differ on this and the difference is load-bearing.
- [ ] TASK-154's recorded destination for `:199` is corrected to match the settled answer, and TASK-158's `:10` finding is either confirmed or withdrawn on the same basis.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- The **content** of any relocation already made — TASK-154's two pointers are correct as pointers; only their classification is in question.
- Whether `§ Conventions` should be folded into `docs/adr/` — the five-records table settles that, and reopening it is a `domain` question, not this one.
- The 5:1 split on whether the `ARG_RE` block is a rationale essay — **TASK-158**; a different boundary in the same rule.

## Human test plan

- [ ] After the rule changes, two cold readers on a fixture whose guide carries a comment-duplicating passage. Expected: both reach the same verdict on it, in whichever direction D15 settled.
- [ ] Expected failure to watch for: adding the row makes *every* pointer-to-the-guide reportable, including the ones this feature deliberately created. A rule that indicts its own remedy is worse than the gap.

## Implementation plan

_Populated by `/tasks plan TASK-159` once D15 is stamped — leave empty until then._
