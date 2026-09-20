---
id: TASK-148
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-19
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `pi-install.sh`'s header reproduces two ADRs instead of pointing at them

## Context

Spawned from TASK-141 while measuring this repo's scripts against the comment rule it was adopting.
Not a review pass — found by applying the rule to the repo that had just accepted it.

`pi-install.sh:2-12` is a 12-line header doing two jobs. The first is necessary and stays: **what**
the script links and where, including the constraint that `skills-pi/` must never be linked into
`~/.claude/skills` because the real built-ins live there and stubs would shadow them. A reader about
to edit the script needs that, and it is the kind of thing that lives nowhere else.

The second job is the problem: it also summarises **why** — symlinks rather than copies so the repo
stays the single source of truth, and the shadowing rationale. Both of those are decision records
already: [ADR 0009](../../../docs/adr/0009-installers-link-rather-than-copy.md) and
[ADR 0010](../../../docs/adr/0010-skills-pi-is-frozen-and-pi-only.md). The rule's decision-record row
says a comment whose content lives in one *"delete it, or leave one line pointing at the record"*.

**Why this is P3 and was not fixed in TASK-141.** It is genuinely borderline, which is why it is
recorded rather than assumed: the summary is one clause, not an essay, and `pi-install.sh` is a file
someone edits without reading `docs/adr/`. A reasonable reviewer could call it compliant. What is not
reasonable is leaving the question in a commit message where nothing ranks it — this repo's own rule
is that an untracked paragraph describing work is a spawn that was skipped.

The same question applies to `pi-install.ps1:2-12`, which carries the parallel header. Fix both or
neither; a half-fix leaves the two installers disagreeing about how much they explain.

**Scope correction, added 2026-09-20 from TASK-151's block walk: the clause is in four files, not
two.** `install.sh:3` and `install.ps1:2` carry the same *why* — *"the repo stays the single source of
truth, so `git pull` updates the live skills with no re-install"* — which is ADR 0009's reasoning
verbatim in substance. They lack only the `skills-pi/` shadowing half, because they do not link that
tree. So the "fix both or neither" argument above applies across all four: whatever is decided for
the `pi-install` pair must be decided for the plain pair in the same change, or the four installers
end up disagreeing about how much they explain.

## Acceptance criteria

- [x] A judgement is recorded either way, with its reason — compliant as written, or reproduced content that becomes a pointer. "Left as is" without a reason does not close this.
- [x] If changed: the mechanism (which trees link where, and the never-link-`skills-pi`-into-Claude constraint) survives in full — it is the half that lives nowhere else. Only the rationale becomes a pointer.
- [x] `pi-install.sh` and `pi-install.ps1` end up consistent with each other.
- [x] If changed, the measurement table in `AGENTS.md` § Conventions is re-run, not re-edited — its own note says a reworded rule invalidates it, and the same applies to changed inputs.
- [x] `bash .github/workflows/skills-lint.sh` and `bash .github/workflows/skills-lint-test.sh` both pass.

## Out of scope

- `skills-lint.sh` — measured and compliant; TASK-141 records why.
- The rule's wording — FEATURE-002 D1/D2, settled.

## Human test plan

N/A — fully covered by reading the **four** files and the two ADRs side by side. (Written as "two
files" before the 2026-09-20 scope correction; corrected here rather than left, because a stale
expectation in a test plan is the defect TASK-161 exists for and it has bitten twice today.)

There is no runtime behaviour here: the installers' output is unchanged either way, and a human
running them would see no difference, which is exactly why this is a judgement to record rather than
a test to run. Confirmed mechanically anyway — `bash -n` on both shell scripts, a PowerShell parse on
both `.ps1` files, and lint check 6 still reporting both roots *in sync*.

## Progress log

- 2026-09-20 — **Judged: changed, not left as is.** The borderline call this task was filed to settle
  comes down against the prose, and the destinations were verified by reading them rather than
  assumed:
  - `ADR 0009` carries the *why* verbatim in substance — *"the repo is a **single source of truth**…
    with links, an edit is live everywhere immediately; with copies, every consumer is a stale
    snapshot"* — which is what all four headers said in their own words.
  - `ADR 0010` carries the other — *"would **shadow Claude Code's native pass** with a strictly
    inferior markdown reimplementation"* — which is what both `pi-install` headers said.
- 2026-09-20 — **The mechanism survives in full, per criterion 2.** Each header still states which
  trees link where, the platform form (symlinks vs directory junctions), and — in the `pi-install`
  pair — that `skills-pi/` must **never** be linked into `~/.claude/skills`, *where the real built-ins
  live*. That last clause is a fact about the world, not a rationale, and deleting it would have been
  the wrong fix. Only the reasoning became pointers.
- 2026-09-20 — **All four consistent**, which is what the scope correction demanded: one shape across
  `install.sh`, `install.ps1`, `pi-install.sh`, `pi-install.ps1`, differing only where the platform
  genuinely differs.
- 2026-09-20 — Verified **comment-only** across all four; `bash -n` passes on both shell scripts and
  both `.ps1` files parse. Lint OK (19 skills), check 6 still reports both roots in sync.
- 2026-09-20 — `AGENTS.md`'s measurement table **re-run, not re-edited**, as criterion 4 requires:
  the four installer rows drop from 12/6/11/5 comment lines to **7/5/6/4**, and their verdict changes
  from *"why-clause overlaps ADR 0009/0010 → TASK-148"* to mechanism-only. Shebang-excluded figures
  recomputed to 124 / 80 / 6 / 4.
