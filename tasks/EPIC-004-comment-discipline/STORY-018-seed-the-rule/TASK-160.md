---
id: TASK-160
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [DRILL-159-1]
pr: null
github-issue: null
jira-key: null
---

# The eight sites D15 made reportable

## Context

**These exist because a decision was taken, not because a sweep was rerun.** FEATURE-002 **D15**
(approved 2026-09-20, TASK-159) added a sixth destination to the comment test — *the project's own
guide* — and with it, eight comments in `.github/workflows/skills-lint.sh` went from unreportable to
reportable in one step. Every one restates `AGENTS.md` § Conventions; none was catchable by the five
previous rows.

Found by TASK-159's two verification readers, on a fixture carrying the six-row rule and the guide
**minus the measurement table only**, so neither could see any prior verdict about the file.

| Site | Restates | Found by |
|---|---|---|
| `:2` | § Testing — *"the repo's only automated gate"* | M |
| `:4-5` | § *Defer to a shared inventory — never restate its lists* | M |
| `:11` | § Commands / § Testing — *"Run locally: …"* (also TASK-158, whose code half stands separately) | M |
| `:104-107` | § *A format one skill reads is a contract* | **both** |
| `:113-117` | § *Defer to a shared inventory* | M |
| `:118-119` | § *A format one skill reads is a contract* — the *every flag* rule | N |
| `:144-148` | the same bullet's anchored-flag rule **and** its `--unattend`/`--unattended` example | **both** |
| `:247-249` | § *Defer to a shared inventory* | M |

### `:4-5` is this feature's own prose, and that is the point

TASK-157 replaced a stale check enumeration with *"those banners are the inventory — do not restate
them here, because a copy goes stale the next time a check is inserted."* The **instruction** is local
and stays. The **reason** attached to it is the guide's, and until D15 no row covered it.

So the sixth row caught a comment written under this feature three commits earlier. That is the
strongest available evidence the row does work rather than decorate the table — and it sets the shape
for the whole sweep: **keep the local consequence, point at the shared rationale.**

## Acceptance criteria

- [ ] Each of the eight is acted on or dismissed **with a reason recorded**; "left as is" alone does not close this.
- [ ] Each fix **keeps the local consequence and relocates only the shared rationale.** A fix that deletes the instruction along with its reason has removed the thing that stops the original defect returning — `:4-5` is the worked example.
- [ ] `:144-148` keeps the `grep -qF` prefix-matching mechanic; only the restated rule and its example go. That mechanic lives nowhere else.
- [ ] Every deletion names the **section** that holds the content, verified by reading it — not by trusting the heading's name, per the guide row's own instruction in [[review-comments]] § *The only copy*.
- [ ] Pointers added here are checked against the same run: a pointer is never a finding, and the sweep must not end with more findings than it started.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- `:22` (`RUNTIME_REFS`), `:166`, `:149`, `:295-296` — **TASK-158**; different destinations, filed before D15.
- `:15-17`'s *"checks 2 and 3"* factual error — **fixed in TASK-159**, where it was found, because it is the same restated-list pattern that task's own header fix was meant to end.
- `:217`'s backwards run-order premise — **TASK-081**, confirmed independently again by reader M.
- The `ARG_RE` block's rationale-essay question — **TASK-158**; the tally is now **4:2**, not 5:1.

## Human test plan

- [ ] Two cold readers on the same six-row fixture. Expected: these eight gone, the three pointers (`:160`, `:199`, `:208`) still unreported, and the four TASK-151 survivors still protected.
- [ ] Expected failure to watch for: the sweep converts eight restatements into eight pointers and the file now says less than the guide requires a reader to know locally. The test is whether someone editing a check can still tell what it does to the build — the same question TASK-154's script-alone readers answered, and worth re-asking once eight more pointers exist.

## Implementation plan

_Populated by `/tasks plan TASK-160` — leave empty until then._
