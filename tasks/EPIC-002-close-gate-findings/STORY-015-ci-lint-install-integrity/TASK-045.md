---
id: TASK-045
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# A flag one skill passes is never checked to exist in the receiving verb

## Context

Spawned by TASK-015's `close` step 5d sweep — the first run of the unattended path that task added.

TASK-015 made [[fix-next]] pass `--unattended` to [`/tasks close`](../../../skills/tasks/verbs/close.md),
and `close` step 2 now documents that flag. Nothing verifies the two stay in agreement. Rename the flag
on one side, drop it, or typo it, and the other keeps passing it into a verb that silently ignores an
unrecognised argument — the out-of-scope sweep reverts to *offering* in exactly the unattended run where
nobody is present to see the offer go unanswered. The failure is silent on both sides: no error, and a
close that looks identical to a correct one.

This is a **cross-skill contract with no enforcement**, the same shape as two findings already filed:

- `AGENTS.md § Conventions` states it as a rule — *"A format one skill reads is a contract the writing
  skill must state too"* — and that rule is honoured by convention alone.
- TASK-043 covers the neighbouring case: `[[link]]` references are resolved by CI inside `skills/` and
  nowhere else, so the same contract is enforced in one tree and not another.

`skills-lint.sh` already parses every skill markdown file for links and file references, so the walk
exists; what is missing is the assertion. The check is plausibly cheap: find `<verb> --flag` mentions in
one skill and confirm the flag appears in the target verb's arg list.

**Not assumed to be easy.** `--unattended` is the only instance today, so a check written for it risks
being a one-case check. Whether flags are consistently written in a greppable form across the skill set
is the first thing to establish, and if they are not, saying so and closing is a legitimate outcome.

## Acceptance criteria

- [x] Establish first whether cross-skill flag passing is written consistently enough to detect — survey
      the actual instances before designing anything, and record the count
- [x] If it is: a check asserts every flag one skill passes to another verb exists in that verb's args
- [x] If it is not: say so with the evidence, and close the task — a check that catches one hard-coded
      case is worse than none, because it reads as coverage
- [x] Whichever way it goes, `--unattended` specifically is covered — by the general check, or by a
      pinned case in `skills-lint-test.sh`
- [x] Any check added is advisory or fatal by the existing rule (advisory only when the remedy lives
      outside the repo — this one does not, so fatal is the default), and carries a test that fails
      without it

## Out of scope

- The `[[link]]`-in-`tasks/` coverage gap — TASK-043 owns it. Related, and worth doing in the same
  sitting if both land, but they are separately scoped.
- Validating flag *semantics* (that the receiving verb does the right thing with the flag). Existence
  is what is silently wrong here.

## Human test plan

- [ ] Rename `--unattended` in `close.md` only, run the check, and confirm it fails naming both sides
- [ ] Restore, and confirm the run is clean
- [ ] Confirm a flag mentioned in prose but not passed to a verb is not reported (the false-positive
      direction — the same trap TASK-043 documents for wikilinks)

## Implementation plan

_Populated by `/tasks plan TASK-045` — leave empty until then._

## Outcome

**AC 1 first, because it gated everything: the pattern IS detectable.** Surveyed every cross-skill
invocation carrying a flag in `skills/` — **30 instances, and all 30 share one shape:** `/skill verb --flag`.
No variant spellings, no prose paraphrases. So the "close it as undetectable" branch does not apply.

**The survey's real finding was on the receiving side, not the calling side.** A first pass extracted each
verb's declared flags from `- \`--flag\`` bullets and reported `tasks/verbs/import.md` as declaring **none** —
while `import` is invoked elsewhere with `--github` and `--jira`. `import.md` declares its args in an
**invocation table**, not bullets. Keying the check on bullets would have produced a false alarm on a
correctly-written file. **The check therefore reads the receiving file whole**: if the flag token appears
anywhere in it, it is declared. Over-permissive in the safe direction — it cannot invent a missing flag —
and existence is all this task scopes.

**Result of running it: 30 checked, 0 mismatches.** The trap was **armed but unsprung**, the same posture
TASK-036 found on the status-read side. So the check exists to keep it that way, not to clear a backlog —
and `--unattended` specifically is covered by the general check rather than a pinned case (AC 4), since
`close` declares it and `fix-next` passes it.

**Fatal, not advisory (AC 5).** The existing rule makes advisory the exception for findings whose remedy
lives outside the repo; a mis-named flag is fixed by editing a file in the repo, so fatal is the default and
applies. Inserted as **check 4**; the install-roots advisory renumbered to **5**, including the three
references in the test harness that name it — one of which is the guard requiring the advisory section to
have *run*, so leaving it stale would have quietly weakened a "must not appear" assertion.

**A defect I introduced and caught before committing.** The first version keyed the skill name to a
hard-coded alternation — `/(tasks|feature|specs|…)`. That is the restated-list defect this repo lints for:
a skill added tomorrow is silently unchecked, and the fixture's skills are named `alpha`/`beta` so the check
could not be tested at all. Now it matches any `/word verb --flag` and lets the existence of
`skills/<word>/` decide, so a stray `/usr/bin/x y --z` in prose resolves to no skill and is skipped.

**Step 6 — proved the guard can fail, and accounted for it exactly.** Four cases added (36 → 40). With
check 4's `suberr` branch neutered:

| Case | Neutered | Restored | Role |
|---|---|---|---|
| flag not declared in receiving verb | **FAIL (exit 0, wanted 1)** | ok | **fix-dependent** — the only real evidence |
| flag declared in receiving verb | ok | ok | contract pin |
| receiver declares flags in a table | ok | ok | contract pin — pins the whole-file read against the `import.md` regression |
| flag aimed at a non-skill path | ok | ok | contract pin — pins the no-hard-coded-list behaviour |

`skills-lint-test: 39 passed, 1 failed` neutered; **40 passed, 0 failed** restored. Three of four are pins
rather than proof, and are recorded as such.

**Registered in the rulebook.** § Conventions' *"a format one skill reads is a contract the writing skill
must state too"* now names check 4 as the enforcement for the flag case. And § Testing's case count was
stale the moment I added cases — **36 → 40**, with the drift history (16 → 25 → 36 → 40) written in, because
that repetition is exactly TASK-029's argument.

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped.

## Progress log

- step 2 — picked; ranked above TASK-071 on key 1 (a silently ignored flag in the **unattended** path means the out-of-scope sweep reverts to *offering* with nobody present, so findings evaporate — silent loss of tracked work) and key 4 (survey-first, with a defined "close it as undetectable" outcome; TASK-071 has three live options and may fold into TASK-043). Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **held.** `close` declares `--unattended`, `fix-next` passes it, and nothing connected the two.
- step 4 — layer: **local** — the lint and the rulebook are this repo's own.
- step 5 — survey (30 instances, one shape) → check 4 in `skills-lint.sh`; whole-file read on the receiving side after the bullets-only version false-alarmed on `import.md`; skill list derived from the tree, not hard-coded.
- step 6 — 4 cases added (36 → 40). Neutered check 4 → 1 fail (`flag not declared`), 39 pass; restored → 40/0. One fix-dependent, three pins.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: both bullets are boundaries (TASK-043 owns the `[[link]]`-in-`tasks/` gap; flag *semantics* explicitly out). Nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
