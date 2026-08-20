---
id: TASK-049
parent: STORY-005
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
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

- [ ] `skills/tasks/verbs/close.md` step 5b runs the intent axis alongside the standards axis
- [ ] `/feature review` runs both, consistent with how it already pairs adherence and correctness
- [ ] The two verdicts are reported **separately**, each with its own findings and severity ordering;
      neither is folded into the other's list and nothing reranks across them
- [ ] The merge decision states both verdicts — a reader can see "standards pass, intent fail" as a
      distinct outcome from "both pass"
- [ ] Whether the intent axis is conditional or unconditional is decided and **written down**, next to
      the existing conditional-[[security-review]] rule so the two read as one policy
- [ ] `verify-intent` still runs standalone with no task, gate, or feature in play
- [ ] The runtime-degradation pattern the gate already uses for [[code-review]] is followed, so a
      runtime without the skill still closes
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Building either axis** — TASK-046/047 (intent) and TASK-048 (smell baseline). This is wiring and
  reporting only.
- Changing the merge decision itself, or what blocks a close. This task makes both verdicts visible;
  what a maintainer does with "standards pass, intent fail" is a policy question nobody has asked yet.
- [[fix-next]]'s unattended path, which inherits whatever `close` does here — TASK-015 settled that
  contract and this task must not quietly change it.

## Human test plan

- [ ] Close a real task through the gate and confirm both verdicts print separately, with neither
      list absorbing the other
- [ ] Construct a diff that passes conventions and fails intent, and confirm the report makes that
      combination obvious rather than burying the intent finding among warnings
- [ ] Construct the reverse and confirm it reads as clearly
- [ ] Run `/fix-next` through a close and confirm the unattended path still behaves as TASK-015 defined
- [ ] Confirm `verify-intent` standalone is unaffected by the wiring

## Implementation plan

_Populated by `/tasks plan TASK-049` — leave empty until then._
