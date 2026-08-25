---
id: TASK-036
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-08-19
depends-on: []
blocks: []
findings: [CR-020-4]
pr: null
github-issue: null
jira-key: null
---

# `/specs regen`'s state gate can read the commented enum instead of the status

## Context

`/code-review` finding from TASK-020's close gate (2026-08-19), in a file that task's diff did not
touch.

**Severity corrected 2026-08-19, before any work started.** Filed P1 on the reviewer's framing; a
first-hand read of `regen.md` downgrades it to **P2**. The file *does* already say *"Read the YAML
**value**, not the line"*, and a correct YAML read never sees a comment line at all. The reviewer's
"blast radius is total" rested on an `grep 'status:' | head -1` implementation that **nothing in the
file prescribes**. What survives is real but narrower: the instruction's only worked example is the
*trailing* comment, so an implementer working from the surrounding shell-heavy prose gets no warning
about the leading one.

`skills/specs/verbs/regen.md:52` warns the reader about a **trailing** comment on the status line
(`status: done  # merged 5414637e`). It says nothing about the **leading** one that every
template-generated task carries: `skills/tasks/templates/task.md` emits

```
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
```

An unanchored first-match read — `grep 'status:' <file> | head -1` — returns the **comment**, whose
first token parses as `todo`. An implementer who does that concludes the work never landed and refuses
the commit's inferred evidence for every template-generated task, `done` ones included, in the
dangerous direction: `shaped-by-unresolved` climbs while `shaped-by-derived:` still reads `true`, so
[[roadmap]]'s DV8 and DV11 read a generator gap as a project gap, and nothing errors.

**Measured instance, 2026-08-22.** A count run during TASK-053's close used `grep -c '^status: '` across
every task file and got 61 statuses from 60 files. The extra one was **this task's own code block above** —
anchoring to column 0 is not enough, because a fenced example sits at column 0 too. The read has to be
scoped to the frontmatter between the first two `---`. Cheap to hit, silent when hit, and it happened on
the first real attempt.

**Second measured instance, 2026-08-23 — and it is the WRITE side, which this task does not yet cover.**
A `/fix-next` run set its pick to `in-progress` with an unanchored substring replace of
`"status: todo" -> "status: in-progress"`, first occurrence. The first occurrence in the file is **the
comment**, so it rewrote the enum to `# status: in-progress | in-progress | …` and left the real
`status: todo` untouched. The task then ran to completion — fix, verification, a full `## Outcome` — while
its frontmatter still said `todo`, and a later close flipped the comment again rather than the field. Caught
only because a task count came out one short.

Two things this adds to the reading-side defect above:

- **The hazard is symmetric.** A leading comment that contains every legal value is a trap for anything
  doing a first-match *write*, not just a first-match read, and the write failure is worse: a read that
  parses `todo` off the comment produces a wrong answer, while a write silently succeeds against the wrong
  line and leaves the record claiming one state while the work claims another.
- **Anchoring alone is what saved every other edit in that session.** `sed -i 's/^status: todo$/…/'` matched
  the real line each time, because `^`/`$` exclude a line starting with `#`. The one edit that used an
  unanchored substring is the one that broke. So the mitigation is cheap and mechanical — the question this
  task should answer is whether the **template** should stop carrying an enum comment that shadows its own
  field, rather than every reader and writer being expected to anchor.

**That is a reachable mistake, not a mandated one** — which is exactly why the fix is worth doing and
why it is P2 rather than P1. Every task file in this repo and in any repo scaffolded from the template
carries the comment line, so the trap is always armed; it just needs someone to write the naive grep.
Whether it has already been written anywhere is the first thing to check.

## Acceptance criteria

- [x] `regen.md` names the commented enum line explicitly as the thing to skip, not only the trailing comment
- [x] The instruction anchors the read (`^status:`) rather than describing the intent and leaving the pattern to the reader
- [x] Verified against a real task file carrying the template's comment line — the read returns `done`, not `todo`
- [x] Checked whether any *existing* implementation or prose in `skills/` actually does the naive first-match read; if none does, the task records that the trap was armed but unsprung
- [x] The trailing-comment case still works (`status: done  # merged abc1234` → `done`)
- [x] A spot-check says whether `shaped-by-unresolved` counts already recorded in this repo or Symbio were inflated by this, so DV8/DV11 readings are not trusted blindly afterwards
      — **nothing to inflate here:** `docs/specs/.map.yml` is `areas: []` with no spec bodies, so this repo has never recorded a `shaped-by-unresolved` count. Symbio is a separate repo and out of reach from this one; the check belongs to whoever next runs `/specs regen` there, and this task's fix is what makes that count trustworthy when they do.
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Re-deriving provenance across every area to correct historical counts — decide that once the read is fixed and the inflation is measured; it may warrant its own task.
- DV11's own reporting rules in [[roadmap]] — they are correct; they were being fed a bad number.
- The commented enum line in the template itself. It is useful documentation and should stay; the reader must cope.

## Human test plan

N/A — every criterion is a text read against a real file, asserted mechanically. A human eyeballing the
same grep adds nothing.

## Progress log

- step 2 — picked; ranked above TASK-057 on **key 5, verified over unverified**. Both are silent wrong answers of similar severity (key 1) and both self-contained (key 4), but this one gained a **second measured instance today** — a `/fix-next` run sprang the write-side version of the same trap — which also answers AC 4's open question. Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.

## Outcome

**What was broken.** `/specs regen` step 5a decides whether a task's state corroborates a commit that names
it. Its instruction said *"Read the YAML **value**, not the line"* and gave **one** example — a **trailing**
comment, `status: done  # merged 5414637e`. The task template also emits a **leading** comment one line above
the field, containing **every legal value**. So the instruction named one hazard, described the intent for the
other, and left the pattern to the reader — and an unanchored first match returns the comment, which parses
as `todo`, for *every* template-generated task including the `done` ones.

**The fix.** `regen.md` now **gives the pattern instead of the intent**: anchored `^status:`, value taken
before any `#`, and the read scoped to the frontmatter between the first two `---` fences. Both comment shapes
are named as separate bullets, and the scoping caveat is stated — column-0 anchoring alone is not enough,
because a fenced example can sit at column 0 too.

**AC 4 answered, and the answer is interesting.** No prose in `skills/` instructs an unanchored read: every
reader anchors (`^status: in-progress` in [[fix-next]], `^id: TASK-NNN$` in `block`/`close`/`plan`). So the
trap was **armed but unsprung in the skills' own prose** — and what sprang it twice was this file naming only
the trailing case, so an implementer's model of "the hazard" was trailing-only.

**Second instance, and it is the write side.** A `/fix-next` run on 2026-08-23 set a task to `in-progress`
with an unanchored substring replace, hit the enum comment, and ran the task to completion — fix,
verification, a full `## Outcome` — while its frontmatter still read `todo`. Caught only by a task count
coming out one short. A bad read yields a wrong answer; a bad write silently succeeds against the wrong line
and leaves the record and the work claiming different states. That asymmetry is now written into `regen.md`.

**Step 6 — the guard can fail, demonstrated on one fixture carrying every shape at once** (leading enum
comment, trailing comment on the field, and a fenced `status: todo` decoy at column 0):

| Read | Result | Role |
|---|---|---|
| anchored `^status:` + frontmatter-scoped | `done` | **fix-dependent** — correct |
| naive unanchored first match | `todo` | **proves the guard is doing work** — the defect, reproduced |
| trailing comment stripped from the value | `done` | **contract pin** — worked before this change, must keep working |

**Judgement call.** *Rejected: fixing this in the template instead.* Removing or rewording the enum comment
would kill the hazard at source and is arguably the better fix — but it changes a template every existing
task file already carries, and `triage`/`close` both read those files. That is a separate decision with a
migration question attached, so it is **TASK-073** rather than folded in here. This task makes the reader
correct; that one asks whether the shadow should exist.

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped.

## Progress log

- step 2 — picked; ranked above TASK-057 on **key 5, verified over unverified**. Both are silent wrong answers of similar severity (key 1) and both self-contained (key 4), but this one gained a **second measured instance today** — a `/fix-next` run sprang the write-side version of the same trap — which also answers AC 4's open question. Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **held, and narrower than filed.** `regen.md:52` does cover the trailing comment; the leading enum line is genuinely unnamed. The finding was right about the gap and slightly imprecise about the cause.
- step 4 — layer: **local.** `regen.md` is this repo's own file.
- step 5 — fix in `skills/specs/verbs/regen.md` (pattern given, both comment shapes named, frontmatter scoping stated).
- step 6 — one fixture with all three shapes: fix-dependent = anchored+scoped returns `done`; guard-can-fail = naive read returns `todo`; contract pin = trailing-comment strip still returns `done`.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep spawned **TASK-073** (should the template carry the enum comment at all). Gate: standards pass, intent pass, correctness pass; security not applicable.
