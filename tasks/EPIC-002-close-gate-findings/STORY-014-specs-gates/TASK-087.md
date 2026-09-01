---
id: TASK-087
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-033-1]
pr: null
github-issue: null
jira-key: null
---

# A re-discovery rewrites `.map.yml` and nothing says the human's prose survives

## Context

**From the 2026-09-01 cold drill of `/specs init`** (TASK-033's re-drill, run read-only against
`BardStudio` and `Presenter`).

`.map.yml` is declared **"HAND-EDITABLE: this is the only human-owned file in `docs/specs/`"**. Step 6
says to write it *"from [templates/map.yml] with the blessed areas"*. Step 2 says a re-discovery must
*"propose additions/renames against the existing map, never drop an existing area without asking."*

**Everything in that protects the `areas:` — the structured data — and nothing protects the prose.**
Presenter's map opens with two hand-written blocks a person wrote and no verb can regenerate: when and
why it was discovered, and a paragraph explaining that `Program.cs` is mapped to `http-api` rather than
smeared across every domain area *because it is a minimal-API host whose single 386-line file carries the
whole HTTP surface*. That is precisely the kind of reasoning the repo's own rules say must not live only
in a person's head.

**The skill argues against itself here, and the drill quoted it.** `SKILL.md` justifies using *keys*
rather than comments for the coverage stamp on the grounds that *"a comment is the part of a YAML file
any re-serialization drops."* Taken at face value that sentence predicts exactly this: a re-discovery
that re-serializes from the template drops the previous author's rationale as a side effect. The drill
hand-preserved the comments and flagged that it was choosing, not following — *"a literal 're-serialize
from the template' reading would delete real content the previous run's author wrote."*

**Why this outranks its size.** Silent loss of hand-written rationale from a file the skill calls
human-owned is the worst shape of data loss: reversible only if someone notices, and nothing makes them
notice. It is the same class as TASK-066 (landing before regenerating) — a generated-shape file carrying
content its verb cannot reproduce.

## Acceptance criteria

- [ ] A re-discovery's effect on hand-written comments is **stated** — preserved, or dropped with the loss announced, chosen deliberately
- [ ] If preserved: what "preserve" means is concrete enough to follow (whole-file comments, per-area comments, or both), since a naive template re-render loses all of them
- [ ] `SKILL.md`'s *"a comment is what any re-serialization drops"* line no longer reads as licence to drop the human's prose — it is an argument for keys, not against comments
- [ ] The rule holds for the `ignore:` block too, which in three consumer maps carries per-entry explanations of why a path is not source
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The coverage keys themselves — TASK-033 owns those.
- Whether `.map.yml` should be machine-owned instead. It is hand-owned by declaration; changing that is a different decision.

## Human test plan

- [ ] Run `/specs init` as a re-discovery against a map carrying hand-written comments (Presenter's is the standing example) and confirm the outcome matches whatever this task decided, rather than depending on how the agent felt about re-serializing

## Implementation plan

_Populated by `/tasks plan TASK-087` — leave empty until then._
