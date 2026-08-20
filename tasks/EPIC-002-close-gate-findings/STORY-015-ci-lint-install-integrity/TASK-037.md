---
id: TASK-037
parent: STORY-015
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Nothing detects a `skills-pi/` stub shadowing a real built-in

## Context

Named as a spawn candidate in TASK-016's implementation plan and filed by its `close` step 5d sweep
(2026-08-19), rather than folded into that task.

`pi-install.ps1`'s own header states the hazard outright:

> `skills-pi/` must NEVER be linked into `~/.claude/skills`: there the real built-ins exist and the
> stubs would shadow them.

TASK-016 added check 4, which detects a **missing** junction and a **stale** one. Neither covers this:
a junction named `code-review` in the Claude root, pointing at `skills-pi/code-review`, has a source
folder that exists, so it is not stale — and it is not missing from anywhere. Check 4 reports it as
perfectly healthy. Its `skills-pi` half is deliberately never compared against the Claude root
(TASK-016's criterion 4 requires that), so the check is structurally blind here by design.

The consequence is the worst kind: the merge gate still *runs*, but `/code-review` resolves to a
fallback stub instead of Claude Code's real pass, and every review from then on is weaker with no
signal at all. Nothing errors, and the output still looks like a review.

**Not currently present** — checked both roots at TASK-016's close: the four links in the Claude root
that point outside this repo all resolve into `Birko.Framework`, and no `skills-pi` source appears in
that root. So this is latent, like TASK-016's rename case was.

The installers cannot be the detector, for TASK-016's reason: the drift they must catch is the one
that happens when they are *not* run. This belongs as a third condition in check 4.

## Acceptance criteria

- [x] A junction in the Claude root whose target resolves into `skills-pi/` is reported, naming the skill and why it matters (it shadows a real built-in)
- [x] It stays advisory — same reasoning as check 4: the remedy is removing a link outside the repo, which no diff can do
- [x] TASK-016's criterion 4 still holds: `skills-pi/` **absent** from the Claude root is still never reported
- [x] The reverse is not invented as a defect — `skills/` linked into the pi root is correct and must stay unreported
- [x] `skills-lint-test.sh` gains a case that fails without the new condition, non-vacuous (it must require check 4 to have run, per the guard TASK-016 added)
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Removing the offending junction automatically. Detect-and-report, for the same reason TASK-016 declined to auto-create: silently mutating a directory outside the repo needs its own agreement.
- Whether `skills-pi/` should exist at all. It is frozen and deliberate; see `docs/architecture.md` § The three trees.

## Human test plan

- [x] Junction a `skills-pi/` skill into a simulated Claude root and confirm it is reported by name
      — automated as `r_shadow` + `case_says "skills-pi shadowing the claude root"`
- [x] Confirm a clean pair of roots stays quiet — `case_silent "skills-pi absent from claude root"`
      plus `case_says "legit skills-pi link in the pi root"` asserting `roots/pi is in sync`
- [x] Confirm `skills/` linked into the pi root is still never reported — `r_linked` links
      `skills/alpha` and `skills/beta` into the pi root and the case above requires it to report in sync

_Every step is now discharged by a named automated case, so there is nothing left for a human to run._

## Progress log

- step 2 — picked; ranked above TASK-015 because both fail silently, but this one degrades the review
  gate itself (every later defect ships under a weaker pass), while TASK-015 stalls on an open design
  question — "the answer is probably auto-spawn" — which key 4 penalises. Key 6 (theme) never engaged:
  the pool separated on keys 1-5.
- step 3 — verified: held. The `for l in "$root"/*` loop at `skills-lint.sh:151` already walks every
  link and its `case` already matches `*/$repo_name/skills-pi/*` as "ours" — but the only test applied
  after that match is `[ ! -d "$t" ]`, staleness. A `code-review` junction in the Claude root pointing
  at `skills-pi/code-review` has an existing source, so it falls through both halves and the root
  reports "in sync". Confirmed by reading, not assumed from the task.
- step 4 — layer: local. The detector belongs in this repo's lint; the installers cannot own it,
  because the drift they must catch is the drift that happens when they are not run (TASK-016's reason).
- step 5 — fix in `.github/workflows/skills-lint.sh` (check 4's link loop); tests in
  `.github/workflows/skills-lint-test.sh` (`r_shadow` fixture + three cases); suite 34/34 green.
- step 6 — reverted fix: 2/34 failed; fix-dependent = `skills-pi shadowing the claude root` and
  `shadow root is not called empty`; contract pins = the other 32, including the new
  `legit skills-pi link in the pi root`, which passes with and without the fix because it defends the
  **false-positive** direction (break the membership test the other way and it fails). A pin, not
  evidence — recorded as such.
- step 7 — no usable spec map (`docs/specs/.map.yml` has `areas: []`) — run `/specs init` to bootstrap
  the spec layer. Nothing to respec; not skipped silently. Tracked as STORY-008.
- step 8 — `/code-review`: 7 findings, all confirmed, all addressed. Three were in this fix:
  the caller's tree argument was compared against a path-derived name (correct only because both call
  sites pass bare relative names — now `basename`d); the "nothing is linked into it" collapse fired on
  a root whose only link was the shadow, contradicting the shadow line and telling the user to run an
  installer that would leave it in place (the link loop now runs first so the collapse knows); and the
  advisory claimed *every* non-tree target shadows a runtime skill, which is false for e.g. a link into
  `docs/`, while its `continue` swallowed a dangling shadow (message narrowed, `continue` removed —
  both facts are separately actionable).
  Two were mine elsewhere: `fix-next` had no rule for a `theme:` slug that is not on the ladder, which
  `--adopt`'s propose-and-correct path can produce (now treated as undeclared); and EPIC-002 restated
  the ladder inline **in the same change that declared intake's table its single source** — and the
  copy had already drifted, "docs & coverage" against the table's "Docs, i18n & coverage". Replaced
  with a pointer.
  One was a missing test direction, which was also this task's own unticked criterion 4: nothing
  asserted that a legitimate `skills-pi` → pi-root link stays unreported. Added as a **positive**
  assertion (`roots/pi is in sync`), since a bare must-not-appear check passes trivially when the
  section is deleted.
  One was a stale dashboard — flipping TASK-040 to `done` and picking TASK-037 without re-running
  triage.

## Outcome

**What was broken.** `skills-pi/` holds fallback copies of review passes that Claude Code ships
natively. If one is ever junctioned into the Claude skills root, `/code-review` resolves to this repo's
stub instead of the real pass — every merge gate from then on runs a weaker review, nothing errors, and
the output still looks like a review. Check 4 could not see it: the junction's source folder exists, so
it is not stale, and it is missing from nowhere, so both existing halves report the root "in sync".

**The fix.** Check 4's link loop already read each junction's raw target and already recognised a
`skills-pi` target as belonging to this repo — it simply never asked *which tree* the target was in.
It now derives the tree from the path and compares it against the trees that root was called with
(`skills` for the Claude root, `skills` + `skills-pi` for pi). A link into a tree the root was not asked
to hold is reported as a shadow and returns before the staleness test.

**Judgement call: derived, not listed.** The obvious implementation is a `skills|skills-pi` alternation.
Rejected — that hard-codes a list that grows, and the day a third tree is added the check keeps passing
while missing it, silently. Deriving the tree name from the path has no list to fall out of sync, and it
generalises to any tree without being told about it. This also *widened* the fix beyond the task's
framing, which described the defect as specific to `skills-pi`.

**Advisory, deliberately.** The new finding calls `advise` and never touches `fail`, so exit stays 0 —
same reasoning as the rest of check 4: the remedy is removing a junction outside the repo, no diff can
clear it, and the roots do not exist on the CI runner. The test therefore asserts on **output** with
exit 0, per the repo's rule that an advisory section is tested on what it prints.

**Step 6 split.** Reverting the fix while keeping the tests: **32 pass, 2 fail**. The fix-dependent
tests are `skills-pi shadowing the claude root` and `shadow root is not called empty`. The other 32 are
contract pins — including the new `legit skills-pi link in the pi root`, which passes either way because
it defends the **false-positive** direction (it fails only if the membership test is broken the other
way, reporting the entire real pi install as shadowing). A pin, not evidence.

**Not currently present in either root**, confirmed at TASK-016's close and unchanged: this is a latent
defect made detectable, not an incident. Nothing was flagged and left unfixed.
