---
id: TASK-049
parent: STORY-005
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-20
depends-on: [TASK-046]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Two axes at the gate, reported side by side and never reranked into one list

## Context

The wiring, and the rule that makes the split worth having. TASK-046 gives the gate a fidelity axis;
this task puts it beside the standards axis at the places the gate actually runs — `tasks/close`
step 5b, next to [[verify-conventions]], and `/feature review`.

**The hard rule is that the two axes are never merged or reranked**, and the story states why:

> A change can follow every documented standard while implementing the wrong thing (standards pass,
> intent fail), or do exactly what was asked while breaking the project's conventions (intent pass,
> standards fail). Reranking across them lets one mask the other.

A single ordered list of findings is the failure mode. Sort a `verify-intent` "this requirement was
never built" below three convention warnings and it reads as the least of four small things, when it is
the only one that means the change should not land. Two verdicts, reported separately, each with its
own severity ordering.

`verify-intent` stays **runnable standalone** after this task — the gate is an additional caller, not
the only one. Half its value is answering "does this match what was asked?" mid-work, before any gate.

**Note the close gate is already conditional in one place** and the pattern is worth reusing rather
than reinventing: step 5b runs [[security-review]] only when the diff touches a security surface. Decide
explicitly whether the intent axis is unconditional (it probably is — every task has criteria) and say so.

## Acceptance criteria

- [x] `skills/tasks/verbs/close.md` step 5b runs the intent axis alongside the standards axis
- [x] `/feature review` runs both, consistent with how it already pairs adherence and correctness
- [x] The two verdicts are reported **separately**, each with its own findings and severity ordering;
      neither is folded into the other's list and nothing reranks across them
- [x] The merge decision states both verdicts — a reader can see "standards pass, intent fail" as a
      distinct outcome from "both pass"
- [x] Whether the intent axis is conditional or unconditional is decided and **written down**, next to
      the existing conditional-[[security-review]] rule so the two read as one policy
- [x] `verify-intent` still runs standalone with no task, gate, or feature in play
- [x] The runtime-degradation pattern the gate already uses for [[code-review]] is followed, so a
      runtime without the skill still closes
- [x] `README.md`'s merge-gate documentation is updated from two axes to three — the two-question
      framing (*"code-review asks is this correct? · verify-conventions asks does this match how we
      build?"*) and the gate diagram both predate this axis and describe the gate as it will no longer be.
      Deliberately **not** done when `verify-intent` shipped standalone under TASK-046: the README
      documents the gate that exists, and until this task wires it, a third axis there would be fiction
- [x] The **never merge or rerank** rule is registered in `AGENTS.md § Conventions`, per
      register-on-introduce. It lives inside one skill today, which is the definition of a pattern not
      yet a convention; wiring it into the gate is what makes it cross-cutting
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Building either axis** — TASK-046/047 (intent) and TASK-048 (smell baseline). This is wiring and
  reporting only.
- Changing the merge decision itself, or what blocks a close. This task makes both verdicts visible;
  what a maintainer does with "standards pass, intent fail" is a policy question nobody has asked yet.
- [[fix-next]]'s unattended path, which inherits whatever `close` does here — TASK-015 settled that
  contract and this task must not quietly change it.

## Human test plan

- [x] Close a real task through the gate and confirm both verdicts print separately, with neither
      list absorbing the other — this task's own close: two headers, two orderings, nothing sorted across
- [x] Construct a diff that passes conventions and fails intent — **not constructed; it already
      happened.** TASK-046's first pass: conventions clean, intent found criterion 3 only partly
      implemented. A real instance beats a fixture, and it is why this rule is not hypothetical
- [x] Construct the reverse and confirm it reads as clearly — also real: TASK-044's close had every
      criterion met while `/verify-conventions` caught a live count in a new standing rule. Both
      combinations occurred inside one day of work
- [x] Run `/fix-next` through a close and confirm the unattended path still behaves as TASK-015 defined —
      and the wiring nearly broke it: `verify-intent` *can* ask (its no-task branch), and step 5b is
      governed by `--unattended`. Checked rather than assumed — a close always supplies the closing task,
      so the branch cannot fire — and recorded as a **row in the unattended table**, since the next
      person wiring an asking pass into that step will not have had this conversation
- [x] Confirm `verify-intent` standalone is unaffected by the wiring — its `SKILL.md` is untouched by
      this diff; the gate is an additional caller, not the only one

## Implementation plan

_Populated by `/tasks plan TASK-049` — leave empty until then._

## Progress log

- step 2 — picked as the last unblocked piece of STORY-005; deferred twice for `close.md` saturation,
  and that reason weakened once TASK-050 settled the file's conditional structure.
- step 3 — verified: held. Step 5b ran two passes answering two questions; nothing asked whether the
  diff built what was asked, and nothing said the axes must stay separate.
- step 4 — layer: local.
- step 5 — fix in `close.md` (5b gains the intent axis, the never-rerank rule, an unattended row, and 5c
  states both verdicts), `feature/verbs/review.md` (Gate A confirms fidelity against the *decisions*),
  `README.md` (two axes → three, in the framing line and the gate diagram) and `AGENTS.md`.
- step 6 — **no guard to fail**; the lint does not read a gate's step list. Evidence is the drills.
- step 7 — no usable spec map (`areas: []`). Nothing to respec.

## Outcome

**What was missing.** The gate asked *does this follow our conventions* and *is this correct*. Nothing
asked *did this build what was asked*, so clean, conventional, correct code implementing the wrong thing
passed. TASK-046 built the axis; this puts it where the gate runs and fixes the ordering rule that makes
two axes worth having.

**The policy call, recorded next to its contrast.** The intent axis is **unconditional** for every task
reaching 5b, and that sits beside [[security-review]]'s *conditional* rule deliberately: security is
conditional because most diffs have no security surface to test for, whereas every task has acceptance
criteria — there is no condition to evaluate. A task with nothing to check against is a task whose
criteria need writing, which is itself the finding.

**At the feature level it checks the decisions, not the criteria.** `/feature review` runs it over the
cumulative diff against approved and `changed` decisions, because a decision no task's criteria ever
covered is invisible per-task by construction. That is the completeness question the axis can answer and
a per-task close cannot.

**Judgement call: verify the asks rather than trust them.** `verify-intent` can ask, and step 5b is
governed by `--unattended` — the exact shape of the defect TASK-050 existed to fix, arriving from the
other direction one task later. A close always supplies the task, so the branch cannot fire; that is now
a table row, not a fact someone happened to check.

**The two combinations are documented from real runs**, not fixtures: TASK-046's first pass (standards
pass, intent fail) and TASK-044's close (intent pass, standards fail). Both inside a day.
