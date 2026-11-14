---
id: TASK-089
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
picked-by: fix-next
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-033-3]
pr: null
github-issue: null
jira-key: null
---

# `coverage: unverified` has never once been produced, across three drills

## Context

**The unclosed half of TASK-033.** That task added a three-value coverage verdict to `/specs init`, and
`unverified` is the value the whole change exists for — the state that stops a run reporting coverage it
never established. **Three cold drills over nine repositories have never produced it.**

| Drill | Repos | Verdicts reached |
|---|---|---|
| Fixtures, 2026-09-01 | A, B, C, D (+ D re-run) | `verified` ×4, `not-applicable` ×1 |
| Real repos, read-only | Latent, Presenter, WorkoutTracker, Symbio, BardStudio | `verified` ×5 (under the post-reconciliation reading TASK-033 later settled) |
| Re-drill, read-only | BardStudio, Presenter | `verified` ×2 |

**Two different reasons it never fired, and neither is reassuring.**

- **The fixture built to force it failed to.** Fixture A was a repo whose sources were `engine/*.rules`
  — an unconventional extension, no `.csproj`, no recognised stack — on the assumption that discovery
  would come back empty. The runner read the README, understood the files were the sources, and returned
  `verified` with a scan set of 3. **The assumption that an unusual extension defeats discovery is simply
  false**, and that is worth knowing on its own.
- **Every real repo is ordinary .NET.** All five have recognisable sources, so `unverified` was never
  reachable there.

**Why this is filed rather than shrugged off.** `unverified` carries the strongest consequence in the
schema — it tells a later reader, and `init`'s own step 2, that a populated map is **not** a blessed
baseline. That branch currently rests on reasoning alone. Every other rule TASK-033 added was executed
mechanically by a drill and two of them changed a real outcome; this one has never run.

### Update 2026-09-17 — `unverified` has now been produced once, by a different route

TASK-127's cold drill (`/tasks init` then `/specs init` against `tinyfmt`, a small JS formatter, runner
confirmed cold) wrote `coverage: unverified` with the reason *"areas proposed but never blessed"*.

**It does not close this task, and the reason matters.** That verdict came from the **blessing** branch —
nobody was present to bless the proposed map — not from the **discovery-failed** branch this task is
hunting, where the scan cannot establish what the sources are. Discovery worked fine there: 3 areas over
5 tracked files.

So the table above gains a row, and the question narrows rather than closes: the reachable case is
*unblessed*, and *undiscoverable* remains unobserved across four drills. That is itself evidence for this
task's own closing option — that `unverified`'s definition may need to narrow to what can actually occur.

**The hard part is constructing an honest case, and that is the task.** A repo where discovery genuinely
fails is not a repo with odd file extensions — the drill proved a competent agent reads the README and
recovers. Candidates worth trying, none obviously right: a repo whose sources sit outside the project
root (the polyrepo aggregator shape `regen` step 6 already measures); a monorepo where the walk resolves
to the wrong root; a repo whose behaviour lives in a database, generated code, or a submodule that is not
checked out. **If it turns out `unverified` is effectively unreachable for a careful agent, that is a
finding about the verdict's value, not a failure of this task** — say so and let the rule shrink.

## Acceptance criteria

- [x] A repo shape is found or built where `/specs init` genuinely reaches `unverified`, and a cold drill reaches it **without being told that is the target**
- [x] The run refuses to claim coverage, and does not write a populated map that reads as blessed
- [x] Step 2's consequence is exercised: a later re-discovery over that map treats its areas as proposals to re-confirm, not as a baseline
- [ ] *(not needed — an honest case was found)* **Or**, if no honest case can be constructed, that is recorded with what was tried, and `unverified`'s definition narrows to what can actually occur
- [x] Whatever is learned lands in `skills/specs/verbs/init.md`, not only in this task

## Out of scope

- The other two verdicts. `verified` and `not-applicable` are drill-exercised — the latter on a docs-only fixture, reported distinctly from an empty result.
- Re-testing the rules TASK-033 already validated in the wild (`:(glob)`, the tracked-files universe, dot-paths, unverified-on-absent-key). The last of those caught a real blind spot in Presenter and needs no further evidence.

## Human test plan

- [x] Hand the constructed repo to a fresh agent with the expected verdict **withheld**, per TASK-068, and confirm it reaches `unverified` from the prose alone
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d089a` (`claude -p --disable-slash-commands`; no skills listed).
    Fixture `ledgerbot`: its only behaviour is an uninitialised submodule (`engine`, tracked as one gitlink), plus a
    README, `.gitmodules`, a compose file and an operations doc. The brief answered the blessing question "Bless it"
    and withheld the verdict. The run ended `coverage: unverified — discovery returned nothing while sources exist:
    behaviour lives in the uninitialised engine submodule`, left the gitlink unmapped, and wrote `areas: []`. A
    second `/specs init` read the stamp and treated the map as proposals to re-confirm (criterion 3).
- [x] Confirm a repo that merely *looks* unusual (odd extensions, no manifest) still reaches `verified` — the failure mode this task must not create is an `init` that cries wolf on any unfamiliar stack
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d089b` (no skills listed). Fixture `tariffs`: a Tcl
    runner and three `rules/*.trf` files, no manifest. Blessed, it reached `coverage: verified` with one area.

## Implementation plan

Inline: re-verify against today's rules, build one fixture for the discovery branch and one control, drill both with the blessing answered, land the findings in `init.md`.

## Outcome

**An honest case exists, and it is narrower than the task assumed.** Since the scan became *every tracked file*,
*discovery returned nothing while sources exist* can only mean the source is outside the tracked tree. An odd
extension never reaches it (d089b, and Fixture A in 2026-09), because a tracked file is scanned whatever it is
called. An uninitialised submodule does (d089a), and so would a sibling repository or uncommitted generated code.

**What landed in `skills/specs/verbs/init.md`** (beside the `unverified` catch-all):
- the discovery branch means source outside the tracked tree, with its shapes named, and an unfamiliar stack is not it;
- **a submodule's gitlink is never covered by an area.** The d089a runner found this gap: a glob matching the gitlink
  leaves nothing unmapped, and a blessed run would then grade `verified` over code nobody read. It avoided the trap
  by its own reasoning; the rule now states it;
- the reason line names each cause when more than one applies (d089a's verdict had two).

**Also re-verified:** `unverified` is now reached routinely, by the blessing branch on every unattended run, so the
verdict's value is not in question. The drills supplied the blessing answer to isolate the discovery branch.

**Step-6 split.** Behavioural: d089a and d089b, at HEAD, before the text change; both passed. The text change makes
explicit the reasoning d089a's runner had to supply (point 3 of its report), so its proof is the text assertion
(the submodule rule absent at HEAD, present at the fix). A re-drill after the change was not run.

**Close gate (inline, one skill file plus one spec):**
- **Standards:** the rule lives in the verb that owns the verdict; the spec scenarios are invented, not the fixtures' names.
- **Intent:** criteria 1, 2, 3 and 5 met; criterion 4 (the fallback) not needed.
- **Correctness:** the new rule only removes a path to a false `verified`.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

**One-runner readings, recorded rather than filed:** d089a — "Shape A" and "meta-root" undefined in `init`; a
`not-applicable`-only exemption from blessing leaves a 0-area `unverified` map asking for a blessing; the
"fewer than the typical range" line at 0 areas; `regen --all` offered over 0 areas. d089b — the plural "1 areas", the
`scan:` line format outside the chained case, and the placement of the live `ignore:` key. **Filed:** the
`<n> areas` line (no singular, and odd at 0) was raised by both runners, so it joins TASK-349 as DRILL-089-1.

## Progress log

- step 2 — picked; next P2 in the pool after TASK-099, ranked above TASK-132 and the architecture tasks because the verdict it tests decides whether a populated map reads as blessed (a silent wrong answer), and it is self-contained
- step 3 — re-verified 2026-11-14: two changes since filing reshape the task. (1) Blessing is now a precondition of `verified`, so every unattended run reaches `unverified` by the blessing branch; a drill of the discovery branch must supply the blessing answer. (2) The scan universe is every tracked file, so 'discovery returned nothing while sources exist' can only arise when source is outside the tracked tree (an uninitialised submodule, a sibling repo, generated code)
- step 5 — fixtures d089a (uninitialised submodule) and d089b (odd extensions), both drilled cold with the blessing answered; findings landed in skills/specs/verbs/init.md
- step 6 — behavioural: d089a unverified (discovery branch, gitlink unmapped), second run re-confirms; d089b verified. Text: submodule rule 0 → 1
- step 7 — respecced specs-from-code: the verdict requirement names the tracked-tree reading and the gitlink rule, with two scenarios; restamped
- step 8 — closed inline; commit in git log
