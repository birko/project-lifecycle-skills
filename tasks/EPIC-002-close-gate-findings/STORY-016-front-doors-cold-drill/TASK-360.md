---
id: TASK-360
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-072-1]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Adoption's one round can need more than five questions, and one of them depends on another's answer

## Context

Filed 2026-11-13 from TASK-072's drill C (`%LOCALAPPDATA%/Temp/d072/c`, `report.md`, point 6). The same dependency
was raised by TASK-353's drill (`%LOCALAPPDATA%/Temp/d353`, point 2), which makes **two runners**, FEATURE-002 D10's
bar.

TASK-102 put every fill offer into step 2's round as one item, so the fills never crowd out an inference or a
declaration. It assumed the declarations themselves fit in grill-me's "**At most five questions in a round.**" A
first adoption of a repo with no task tree, no guide and no licence evidence does not fit:
- task mode;
- integration model;
- task workspace;
- canonical guide file;
- licence posture;
- the fill item.

That is six, before any `unknown` row's question. **And the workspace question depends on another answer in the
same round:** `tasks init` skips it "when the integration model is already `single-branch`", so it is not on the
first frontier until integration is answered. One runner listed all six; the other added a conditional note.

## Acceptance criteria

- [x] `adopt-project` step 2 states what happens when the round's questions exceed grill-me's five. Options include
      exempting the declaration round from the cap with a reason, ordering and deferring the rest, or merging
      dependent questions. Whatever is chosen does not reintroduce a second round, or states why one is accepted
- [x] A question that depends on another answer in the same round has a stated form. One way: put the workspace
      question conditionally ("if you chose pr-per-task: …"), and with no answer to integration, workspace is not
      asked
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where fill offers go: TASK-102 (done)
- Wording of the licence and guide-choice questions: TASK-356

## Human test plan

- [x] Run a cold full adoption of a repo with no `tasks/`, no guide and no licence evidence (`%LOCALAPPDATA%/Temp/d072/c/dotnetrepo`
      is one). Expected: the run states how it handled more than five questions and the workspace dependency, and
      neither is in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d360`: a fresh copy of `d072/c/dotnetrepo` (no `tasks/`, no guide,
    no licence evidence), `skills/` at this fix, and the d065b full brief pointed at it. The runner command was
    d065b/full's.
    - **Coldness:** no skills listed and no Skill tool.
    - **The round:** it put a `Setup:` block holding mode, integration, the conditional `If you chose pr-per-task:`
      workspace question, the guide file and the licence. The fill item was outside it.
    - **With no answers:** `workspace undeclared — tasks work in place (integration unanswered)`, and nothing was
      written for it.
    - **Not undecided:** neither the overflow nor the dependency is in its undecided list.
    - **Three of its points came from this task's own wording, and were fixed at the close:**
      - point 1: "stated wording" claimed for mode, guide and licence, which have none;
      - point 8: whether the licence question from a `LICENSE` `unknown` is a setup question (it is);
      - point 14: the fill item described as owned-file changes while listing a backfill on a file this run
        creates.
    - **Cross-drill comparison:**
      - point 15 (specs scans only tracked files) matches d102b (11) and d072/a (9): filed as TASK-361;
      - point 1's task-mode wording is added to TASK-356;
      - points 10 and 12 are TASK-357's.
    - **Recorded here, one runner each:**
      - passing no mode makes `/tasks init` run its own mode detection;
      - the seed tokens with no adopter source (`{{PROJECT_NAME}}`, `{{ONE_LINE_PURPOSE}}`, `{{STACK}}`, `{{KIND}}`,
        `{{TASK_MODE}}`);
      - `{{STACK}}` treated two ways;
      - whether a `.csproj` is a manifest for `## Commands`;
      - hint comments above a token rather than below;
      - INFER's three-file floor against "manifests are authoritative";
      - the features index's project name against the guide's title;
      - `specs init`'s harvest offer filed as found after the round.

## Implementation plan

_Populated by `/tasks plan TASK-360` — leave empty until then._

## Outcome

**The fix (the user's decision, 2026-11-13).**
- **Setup questions sit outside the five-question limit.** Adoption's setup questions (task mode, integration,
  workspace, guide file, licence) are one short block that grill-me's limit does not cover. The five stays for
  open questions: proposals, `unknown` rows and the fill item. The round stays one round.
- **The workspace question is conditional.** It is put as "If you chose pr-per-task: …", and its answer is used
  only when integration ends up `pr-per-task`. Otherwise nothing is written, with the reason reported.

**Step-6 split.**
- **Text assertions:** 2 of 2 fail on `HEAD`'s copy and pass on the fix, both fix-dependent. The script is
  `task360-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** on the old text, d072/c listed all six questions as an unresolved conflict, and d353 marked
    workspace with a conditional note of its own.
  - **After:** the d360 runner built the setup block and the conditional, and listed neither.
- **Contract pins, not evidence:** skills-lint, and TASK-102's eight assertions, which still pass.

**Judgement calls.**
- **The decision was asked:** which of two rules gives way is not this run's to choose.
- **The conditional form needed no decision.** It is the criterion's own suggested form, and its no-answer outcomes
  reuse the `workspace undeclared` line LAYER.md already prints.
- **The drill found three overclaims in this task's own sentences**, all fixed before the close (Human test plan).

**Close gate (inline, about 20 lines in one file):**
- **Standards:** the conditional question's no-answer path is stated. The declaration list is pointed at, not
  copied.
- **Intent:** both criteria met.
- **Correctness:** the overclaims are fixed.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-361**, filed: three runners.
- **TASK-356**, extended with the task-mode wording.
- **Eight one-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked; ranked above TASK-356, TASK-357 and TASK-099 (same story, correctness-invariants, key 6 inert) because it is a contradiction inside the round rule TASK-102 just set: on a first adoption the declarations alone exceed the cap, so every such run breaks one rule or the other (keys 1–2). Small: one section of one file (key 4)
- step 3 — verified: held. grill-me caps a round at five; adopt step 2 lists five declarations plus the fill item; `tasks init` skips workspace under single-branch, so workspace depends on integration in the same round
- step <guardrail> — decision put to the user (2026-11-13): over five → the setup declarations do not count toward grill-me's five; one round kept. Recommendation taken. The dependent workspace question is put conditionally (no decision needed: it is the criterion's own suggested form)
- step 3b — not planned separately: one file, one section; the decision is the plan
- step 4 — layer: local
- step 5 — fix in skills/adopt-project/SKILL.md step 2 (setup questions outside the cap; conditional workspace question with its no-answer outcomes)
- step 6 — reverted fix (HEAD copy): 2/2 assertions failed; fix-dependent = H1, H2; contract pins = skills-lint, task102-check 8/8
- step 7 — respecced project-baseline (round requirement), surgical, restamped; intended — the user's decision
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
