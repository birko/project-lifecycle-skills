---
id: TASK-034
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: [TASK-022]
findings: [VC-020-1]
pr: null
github-issue: null
jira-key: null
---

# `tasks/README.md` holds narrative its own template cannot regenerate

## Context

Raised as a 🛑 blocker by `/verify-conventions` at TASK-020's close (2026-08-19), against
`AGENTS.md § Conventions › Working rules`: *"Generated files are owned by their verbs — never
hand-edit them … `tasks/README.md` by `/tasks triage`."*

This repo's `tasks/README.md` carries content `triage`'s template has no slot for:

- an **"In review"** section that, while verification debt was zero, explained *why the zero is
  trustworthy* — naming TASK-004 (closed on Presenter's evidence rather than the Symbio/WorkoutTracker
  drill its plan named) and TASK-018 (whose deliverable changed while it stayed `done`);
- a closing paragraph attributing each batch of closures to the round that produced it.

Neither is derivable from frontmatter, so a faithful `triage` render **deletes both**. That forces a
choice on every run: destroy the narrative, or hand-edit and diverge from the generator. TASK-020's
close took the second option — counts, priority line, in-progress section and one tree marker updated
by targeted edit — which is the violation this task owns. The reason was sound and stated at the time;
it does not make the edit compliant, and "the closer judged it fine" is not a mechanism.

The convention is not wrong. What is missing is a place for durable commentary that survives
regeneration. Note the same shape will hit `/feature status`'s generated files the moment anyone wants
to explain a phase rather than just state it — so the fix should not be README-only if that is cheap
to avoid.

## Acceptance criteria

- [x] `triage` can regenerate `tasks/README.md` **without destroying** commentary a human wrote, or the commentary provably belongs somewhere else and is moved there
- [x] Whichever way it resolves, running `triage` on this repo is lossless — the TASK-004 and TASK-018 caveats survive a render, or live somewhere `triage` never overwrites
- [x] The mechanism is stated in `AGENTS.md § Conventions` if it is a new pattern (register-on-introduce), not left as tribal knowledge in one skill
- [x] This repo's `tasks/README.md` is brought back to a state a plain `triage` run reproduces exactly — verified by running it and diffing, not by eye
- [x] Whether `/feature status`'s generated files need the same slot is answered, either by extending the fix or by recording why they differ
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- The content of the TASK-004 / TASK-018 caveats. They are accurate; this is about where they can live.
- Relaxing the never-hand-edit rule. The rule stays — and of the two branches offered here, **neither was needed**: the content did not have to move, because it was already on the task files. The generator gained no slot. See the drill record.
- TASK-001's dependency-edge work on `STORY.md` — unrelated shape, different file.

## Human test plan

- [x] Run `/tasks triage` on this repo and confirm the output is byte-identical to the committed file (the real test that hand-edits are gone)
- [x] Confirm the TASK-004 / TASK-018 caveats are still readable by someone who only opens `tasks/`

## Implementation plan

### The premise collapses on inspection — and that is the answer

The task assumes the dashboard holds commentary *nothing else records*. It does not. Both caveats are
**lossy summaries of content already on the task files**, in fuller form:

| Dashboard line | Where the fuller record already lives |
|---|---|
| TASK-004 closed on Presenter's evidence, not the named drill | `TASK-004.md` acceptance line: the 53/67 commit-subject override, the `Deck`/`Presentation` synonym refusal, why WorkoutTracker/Symbio became moot — several times the detail |
| TASK-018 stayed `done` while its deliverable changed | `TASK-018.md` § *Follow-up drill (2026-08-18)*, ending *"Left at `done` rather than reopened: the deliverable changed and the new case is verified"* |

So deleting them from the generated file **loses nothing** and removes a second, staler copy. The
"content the template cannot regenerate" turns out to be content that should never have been there.

### The policy: nothing in a generated file that is not derivable

Three homes, all of which already exist — **no template slot, no new file**:

| Kind of writing | Home | Generated? |
|---|---|---|
| Commentary about **one task** (why it closed as it did, what its evidence really was) | that task's own file | no |
| Cross-cutting **state or judgement** ("the backlog has inverted", "drills find more than building") | the EPIC body — `EPIC-001.md` § *State as of* already does this | no |
| **Tree-level provenance** (this tree came from `/tasks import` off `SPEC.md` § v2 — the Presenter case TASK-022 cites) | `tasks/.config.yml` comments — already hand-owned and already carries explanatory prose in this repo | no |

**Rejected: a preserved region in the generated file** (a `<!-- NOTES -->` block `triage` round-trips).
It makes a generated file partly hand-owned, which is precisely the ambiguity that produced this task,
and it obliges `triage` to parse-and-preserve — fragile, and it would let the second copy grow back.

### Steps

1. **`tasks/README.md`** — strip everything not derivable from frontmatter: the "In review" narrative,
   the per-task parentheticals in the loose list, the closing attribution paragraph. Keep counts, the
   in-progress/review lists, the tree, the loose list, and a `Completed` section.
2. **Nothing is lost in the process.** Before deleting each line, confirm its content exists on the task
   or the EPIC; if any does not, move it to the right home from the table above **first**. This is the
   step that must not be rushed — a "duplicate" that turns out unique becomes a deletion.
3. **`AGENTS.md § Conventions`** — record the rule (criterion 3). It is a new cross-cutting pattern: the
   existing rule says generated files are owned by their verbs, but not what may go *in* them. Phrase it
   as the derivability test plus the three homes, so it covers `/feature status` too.
4. **Criterion 5** — answer `/feature status` explicitly: same policy, same reasoning, no slot needed.
   Its hand-owned neighbours (`idea.md`, `decisions.md`) are the per-feature homes, exactly as the task
   file is for a task. Record that rather than leaving it inferred.
5. **Criterion 4 is the real gate:** render the dashboard faithfully from `triage`'s template + the
   collection pass, and **diff it against the committed file**. Byte-identical, or the difference is
   itself a finding. This is the criterion that ends the hand-edit habit — three closes this session
   edited this file by hand, each a knowing violation.
6. `skills-lint` + `skills-lint-test`.

### Risks and open questions

- **Criterion 4 may expose that `triage`'s template cannot render what this repo legitimately needs** —
  e.g. the `Loose tasks` section's shape, or a `Completed` collapse. If so, that is a *template* gap and
  a separate finding, not a licence to hand-edit. Spawn rather than paper over.
- **`.config.yml` as a provenance home is my inference, not TASK-022's request.** TASK-022 says "decide
  and record whether the verb keeps such a line or the template gains a slot"; this plan answers
  *neither* — it moves the content. Record the third option explicitly so TASK-022's criterion 7 can be
  ticked against a decision rather than an omission.
- **This task's own diff will be almost entirely deletions**, which reads as data loss in review. The
  commit message has to carry where each line went, or the next reader will think the caveats were
  discarded.

### Drill record — 2026-08-20

**The premise did not survive contact.** Neither branch of criterion 1 was needed. The dashboard's
"unreproducible commentary" was a **lossy second copy** of records already on the task files — verified
before deleting anything, per the plan's step 2:

| Dashboard line | Verified present on |
|---|---|
| TASK-004 closed on Presenter's evidence | `TASK-004.md`, 3 matching passages, several times the detail |
| TASK-018 stayed `done` while its deliverable changed | `TASK-018.md` § *Follow-up drill* |
| TASK-006 / TASK-023 / TASK-026 / TASK-038 parentheticals | their own task files (3, 5, 7 and 4 hits) |
| TASK-021's Presenter commit `86f24bf` | `TASK-021.md` |

So the fix was **deletion, not relocation**, and nothing was moved. Every task id (39) is still present
in the rendered dashboard.

**Criterion 4 was met by rendering, not by hand.** A script performed the collection pass and rendered
`templates/README.md.tmpl` faithfully; running it twice gives a byte-identical file (`diff` clean), and it
stayed idempotent after TASK-039 was filed mid-close, which is the harder test — the tree moved and the
render still converged. Net 52 insertions / 80 deletions.

**Two template gaps surfaced, handled differently on purpose.** The committed file's tree used an aligned
code fence and `[done]` markers where `triage` step 4 specifies a markdown list with `[x]`; that is the
committed file being wrong, and the render corrected it. But the `` `todo` by priority `` line is
*derivable and useful* and the template simply has no slot for it — so it was **dropped and filed as
TASK-039** rather than hand-added back. Hand-adding it is precisely what this task exists to stop, and
that restraint is the task working on itself.

**A discrepancy worth keeping as evidence:** the dashboard said verification debt "ran 9" while
`EPIC.md` says "seven". Two hand-written copies of one non-derivable fact, disagreeing, neither now
checkable. That is the argument for the convention in one line, and it is quoted in `AGENTS.md` for that
reason.

**Debt cleared:** three closes earlier in this session hand-edited this file, each flagged at the time as
a knowing violation. The dashboard is now reproducible, so that habit has nowhere left to hide.
