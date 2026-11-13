---
id: TASK-210
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [VC-054]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Examples in skill text are invented, never lifted from a repo the skill is drilled on

## Context

Raised by the conventions pass at TASK-208's close (2026-10-03), as a register-on-introduce note: TASK-208's
plan applied a rule that is stated nowhere a future author would find it.

**The rule.** A skill's examples must use invented content, never a line copied from a real repo the skill
will be drilled against. A cold drill works by withholding the expected answer from the runner
(`skills/populate-tests/SKILL.md` § *The cold drill*). An example copied from the fixture puts the answer back:
the runner meets the same line in the fixture and copies the example's output instead of applying the rule,
so the drill passes whether the rule works or not, and nothing shows that it was compromised. TASK-208 wrote
its examples with invented content (a vendor contract, a staging host's TLS certificate, 2031 dates) for exactly
this reason, and its Symbio drill depended on it.

**What exists today.** § *The cold drill* → *Choosing a target* says a change justified by naming a repo
cannot be drilled on that repo. It says nothing about the skill **text** carrying that repo's data, which is the
same contamination arriving through the instructions instead of the fixture. AGENTS.md § Testing points at that
section and does not say it either.

**Existing mentions to triage** (found by the same pass; line numbers as of 2026-10-03, re-find them by name).
Real repo names appear as measured evidence in:

| File | Lines |
|---|---|
| `skills/new-project/LAYER.md` | 318, 328, 413, 422, 745 |
| `skills/specs/SKILL.md` | 76, 83 |
| `skills/specs/verbs/init.md` | 60 |
| `skills/roadmap/SKILL.md` | 106 |
| `skills/adopt-project/INFER.md` | 102, 110 |

Not every mention is a defect. A measured count cited as the reason for a rule ("all 31 areas carried
`shaped-by: []`") gives a runner no answer to copy. A line a runner could match against a fixture and copy the
output of does. Each mention needs that judgement.

## Acceptance criteria

- [x] `skills/populate-tests/SKILL.md` § *The cold drill* states the rule, with its reason in one or two
      sentences: an example in skill text is invented, never copied from a repo the skill is drilled on, because
      it hands the runner the answer the drill withholds
- [x] The section says what *is* allowed: a real repo cited as evidence for a rule (a count, a measured
      outcome) is not an example and stays
- [x] Every mention in the table above is classified as **evidence** (stays) or **example a runner could copy**
      (rewritten with invented content), and the classification is recorded on this task, one line per mention
- [x] AGENTS.md § Testing's pointer to § *The cold drill* is still accurate after the change (pointer, not a
      second copy of the rule)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Classification of every mention (2026-11-13)

Re-found by name across `skills/**/*.md`: whole-word real repo names, plus every substring of `Birko`. The October
table's line numbers had drifted, and it listed 11 lines where today there are 36 mentions. **Evidence** stays, because
it cites a measured count or outcome as a rule's reason and gives a runner nothing to match. **Example** is a line a
runner could match against a fixture and copy the output of; each one was rewritten with invented content.

| File | Mention | Class | Action |
|---|---|---|---|
| `adopt-project/INFER.md` | `WorkoutTracker`'s ~24-rule flat rulebook (2 lines) | evidence | stays |
| `adopt-project/INFER.md` | `Birko.Framework`'s `### Naming`, measured borderline | evidence | stays |
| `adopt-project/SKILL.md` | `Presenter` kept a config with no `integration:` (2 lines) | evidence | stays |
| `new-project/LAYER.md` | `WorkoutTracker` 342 lines; its guide scored (2 lines) | evidence | stays |
| `new-project/LAYER.md` | `Symbio`'s 239 KB guide and its sections (4 lines) | evidence | stays |
| `new-project/LAYER.md` | `BardStudio`'s missing `## Commands` counterpart | evidence | stays |
| `new-project/LAYER.md` | `Presenter` in `present, outdated` | evidence | stays |
| `new-project/LAYER.md` | `Symbio` 318 → 99 hits, "every one the genuine `$(BirkoSrc)`" | evidence | stays |
| `new-project/LAYER.md` | `Latent` importing `$(BirkoSrc)\Birko.Helpers…` (observed instance) | evidence | stays |
| `new-project/LAYER.md` | CI table row "`$(BirkoSrc)` … blocks: yes" | **example** | → `$(SharedSrc)` |
| `new-project/SKILL.md` | "a `$(BirkoSrc)`-style import" | **example** | → `$(SharedSrc)` |
| `new-project/SKILL.md` | the quoted checklist line "the build imports `$(BirkoSrc)`" | **example** | → `$(SharedSrc)` |
| `populate-tests/SKILL.md` | `WebChecker` print-mode session listing skills | evidence | stays |
| `roadmap/SKILL.md` | `Symbio`'s count in DV11 | evidence | stays |
| `specs/SKILL.md` | `Presenter`, `Latent`, `Symbio`, `WorkoutTracker` counts (4 mentions, 2 lines) | evidence | stays |
| `specs/SKILL.md` | `Symbio`/`WorkoutTracker` and `.claude/**` | evidence | stays |
| `specs/verbs/init.md` | `Symbio` 33, `Latent` 42, `WorkoutTracker` 14 unmapped | evidence | stays |
| `specs/verbs/regen.md` | `../Birko.Data.SQL/SQL/Connectors/X.cs` and its root (2 lines) | **example** | → `../Acme.Data.Sql/…` |
| `specs/verbs/verify.md` | glob `../Birko.Data.SQL/**/*.cs` | **example** | → `../Acme.Data.Sql/**/*.cs` |
| `specs/verbs/verify.md` | `source-commits:` output with two `../Birko.Data.*` keys (2 lines) | **example** | → `../Acme.Data.Sql`, `../Acme.Data.Mongo` |
| `specs/verbs/verify.md` | the quoted report "3 changed in `../Birko.Data.SQL`, 1 in …" | **example** | → invented names |
| `tasks/verbs/init.md` | `Presenter` on the upgrade path | evidence | stays |

**Also rewritten:** `project-baseline` spec scenarios quoting `$(BirkoSrc)` and its import path (3 lines), to match.
**Checked:** no drill-fixture path (`EPIC-001-cli`, `STORY-001-export`, `d065`, `d212`) remains in `skills/` since
TASK-367's close.

## Out of scope

- A lint check for real repo names in skill text: a name list is a per-machine fact (the repos this team
  happens to have), and evidence mentions are legitimate. That is the measured-and-rejected shape § Framework /
  stack records for prose-shaped detection
- Rewriting evidence mentions that pass the classification

## Human test plan

N/A — the change is a rule and a classification, checked by reading; no behaviour runs. The rule's own
effectiveness is exercised whenever a later drill relies on it, and TASK-208 is the measured instance.

## Implementation plan

_Populated by `/tasks plan TASK-210` — leave empty until then._

## Outcome

**The fix.** `skills/populate-tests/SKILL.md` § *The cold drill* → *Choosing a target* states the rule, with its
reason and a measured instance:
- **A skill's examples are invented, never copied from a repo the skill is drilled on.** A copied example hands the
  runner the answer the drill withholds, and the drill passes whatever the rule does.
- **A real repo cited as evidence stays:** a count or a measured outcome gives nothing to copy.

Every mention in `skills/` is classified above. 10 example lines were rewritten with invented names
(`$(SharedSrc)`, `../Acme.Data.Sql`, `../Acme.Data.Mongo`), and 26 evidence mentions stay. AGENTS.md § Testing's
pointer now names the rule beside its twin, and is still a pointer.

**Step-6 split.** Not applicable as a revert check: this is a rule plus a classification, and the plan is `N/A` by
its own statement. The measured case is today's, not a revert:
- TASK-367's draft lifted the `d212` fixture's path, and the next cold runner noticed it.
- TASK-072's drill C fixture imported `$(BirkoSrc)`, and its runner quoted the LAYER table row "`$(BirkoSrc)` … yes"
  as its deciding sentence.

With `$(SharedSrc)` in that row, a later drill on a Birko consumer has to apply the obtainability question instead
of looking the answer up.

**Judgement calls.**
- **The table row was an example, not evidence**, though it was introduced from a real measurement. A row in a
  lookup table is exactly what a runner matches, and the measurement (318 → 99, "every one the genuine
  `$(BirkoSrc)`") stays two lines below as evidence.
- **The `Latent` / `Birko.Helpers` narrative stays.** It is an observed instance cited for the rule. A runner on
  Latent could recognise its repo there, but that is the *"cannot be drilled on a named repo"* rule's case, which
  already exists, not this one.
- **No lint, per Out of scope.** A list of names is a per-machine fact.

**Close gate (inline, about 20 lines over seven files):**
- **Standards:** register-on-introduce is satisfied: a new cross-cutting rule, with one owner (§ *The cold drill*)
  and a pointer in AGENTS.md.
- **Intent:** all five criteria met.
- **Correctness:** a sed escaping slip in the spec path was caught and fixed.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

## Progress log

- step 2 — picked; ranked first outside the paused adopt-project run because a fresh instance was measured today: TASK-367's draft lifted the `d212` fixture's real path into `block.md` and a cold runner noticed it ("the example even matched this repo's path"), the silent drill-compromise this rule exists to stop (keys 1 and 3). No theme (parented to EPIC-002), but keys 1–5 separated it first
- step 3 — verified: held, and wider than filed: 36 mentions today against the table's 11, re-found by name
- step 3b — not planned separately: the criteria are the plan (state the rule, classify each mention)
- step 4 — layer: local
- step 5 — rule in skills/populate-tests/SKILL.md § The cold drill → Choosing a target; 10 example lines rewritten in new-project/LAYER.md, new-project/SKILL.md, specs/verbs/regen.md, specs/verbs/verify.md; AGENTS.md § Testing pointer names the rule; classification table on this task
- step 6 — no revert split: a rule and a classification (plan N/A). Measured instances are TASK-367's lifted fixture path and TASK-072 drill C quoting the `$(BirkoSrc)` row
- step 7 — respecced project-baseline (three scenarios to the invented name), restamped; specs-from-code does not quote the replaced paths
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
