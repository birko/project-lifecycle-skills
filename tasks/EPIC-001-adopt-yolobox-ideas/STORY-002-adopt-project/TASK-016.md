---
id: TASK-016
parent: STORY-002
feature: null
status: done
priority: P2
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The installers only ever add — nothing detects a missing or stale junction

## Context

Spawned from TASK-011's `## Out of scope` at its close. **This is one task covering two symptoms of
the same root cause**, deliberately grouped: splitting them buries the connection that makes them
cheap to fix together.

Both installers enumerate `skills/` (plus `skills-pi/` for pi) with `Get-ChildItem -Directory` and
create one junction per folder. That loop only ever **adds**. It never compares the install roots
back against the repo, so two drifts are invisible:

| Drift | What happens | Observed? |
|---|---|---|
| **Folder added, installers not re-run** | No junction, skill resolves nowhere, its trigger phrases reach nothing | **Yes** — TASK-011: `adopt-project` shipped in `ef22e64`/`7375162` and sat unlinked in both runtimes |
| **Folder renamed or deleted** | Old junction stays behind, pointing at a path that no longer exists | Not yet — scanned both roots at TASK-011's close, zero stale, zero dangling. **Latent, not active** |

TASK-011 fixed the first instance and recorded the rule in `AGENTS.md` § Architecture / § Commands
and `docs/architecture.md`, so the next occurrence is a five-second diagnosis instead of a puzzling
"why doesn't my skill trigger". But a documented rule is a prompt to a human who remembers to read
it. Nothing *detects* either drift, and the failure is silent in both directions — which is the
same reason `skills-lint.sh` exists rather than trusting people to resolve `[[links]]` by eye.

The natural home is the existing lint: it already walks `skills/` and `skills-pi/`, so the
comparison costs one extra pass. But CI runs on Linux where `$HOME/.claude/skills` does not exist,
so an install-root check cannot be a CI gate — it is only meaningful locally. That tension is the
real design question this task has to answer, and it is why TASK-011 fenced it off rather than
folding it in: it is a design change, not a fix.

## Acceptance criteria

- [x] Running the check on a repo whose `skills/` gained a folder since the last install reports the missing junction, naming the folder and both roots
- [x] It reports a junction in either install root that points into this repo but has no matching source folder (the rename/delete case)
- [x] It does **not** fail or warn on a machine where an install root is simply absent — a pi-less or Claude-Code-less machine is a normal configuration, not drift
- [x] It does not flag the deliberate asymmetry: `skills-pi/` is linked into `~/.pi/agent/skills` only, and its absence from `~/.claude/skills` is correct, not a gap
- [x] The decision on where it runs (installer self-check / local-only lint step / separate script) is recorded with its reasoning — an ADR if it turns out to be hard to reverse
- [x] `.github/workflows/skills-lint-test.sh` gains a case that fails without the new check, if the check lands in the lint (the repo's rule: a change to `skills-lint.sh` is not done until a case here fails without it)

## Out of scope

- Auto-creating the missing junctions. Detect-and-report first; a check that silently mutates two directories outside the repo is a bigger decision and would need its own agreement.
- The `.sh` installers' behaviour on Linux/macOS beyond what the check needs to read. TASK-011 could not test that path either — work here is on Windows.
- Deferred to TASK-037 — a `skills-pi/` stub junctioned into the Claude root shadows a real built-in and check 4 is structurally blind to it (the source exists, so it is not stale; it is missing from nowhere). Named as a spawn candidate in this task's plan and filed by its own 5d sweep.

**Unverified on Linux, and it will stay that way until `main` is pushed.** The six new test cases take
`mk_link`'s POSIX `ln -s` branch on the CI runner, which cannot be exercised here — this machine falls
back to a PowerShell junction because MSYS `ln -s` copies. CI is the verification, and `main` is
currently 21 commits ahead of `origin/main` by the user's choice, so CI has not run. Treat the Linux
path as untested rather than as passing.

## Human test plan

- [x] Add a throwaway folder under `skills/`, run the check without installing, confirm it reports the missing junction in both roots — then delete it and confirm the check goes quiet
- [x] Rename an installed skill folder, run the check, confirm it reports the now-stale junction by name
- [x] Run it on a machine (or a simulated `$HOME`) with no `~/.pi` at all and confirm it stays silent rather than reporting every skill as missing

## Implementation plan

### The design question, answered

The task frames it as *"installer self-check / local-only lint step / separate script"*. Reading the
four installers settles it, because **the two symptoms have different requirements and only one home
satisfies both**:

| Symptom | What must be true of its detector |
|---|---|
| Folder added, installers not re-run | It has to run **when the installer hasn't**. An installer self-check is structurally incapable — if you forgot to run it, its self-check didn't run either. This is the *observed* drift (TASK-011), so it decides the answer |
| Junction stale after a rename/delete | Anything that walks both roots catches it; the installer could too, but *Out of scope* forbids mutating, so detection is all that is on offer |

So: **a fourth check inside `skills-lint.sh`**, not in the installers, and not a separate script (a
script you must remember to run is the documented rule this task exists to replace, with extra steps).
The installers stay add-only — record that as a deliberate decision, not an omission.

### The part the task's framing misses

Its stated tension is "CI runs on Linux, so the check can't be a CI gate". True, but the sharper
problem is that `skills-lint.sh` **is the repo's only gate and CI gates on its exit code**. A check
that can fail locally and never in CI makes the gate's meaning machine-dependent. Two consequences
fix it:

1. **The new check is advisory — it never touches `fail`/the exit code.** Justified on its own terms,
   not as a workaround: the remedy (`./install.ps1`) is *outside the repo*, so nothing in a diff can
   fix it and no gate should block on it. Wrong altitude for a blocker.
2. **The roots come from overridable variables** — `CLAUDE_SKILLS_ROOT` / `PI_SKILLS_ROOT`, defaulting
   to `$HOME/.claude/skills` and `$HOME/.pi/agent/skills`. Without this, criterion 6's test case is
   impossible to write (CI has no install roots to fabricate) and criterion 3 is untestable. This is
   the detail that makes the whole task testable, so do it first.

### Steps

1. `skills-lint.sh` — add `== 4. install roots (advisory) ==` after check 3, before `exit "$fail"`.
   - Resolve both roots from the overridable vars; **absent root → print one line saying it was skipped
     and why, then move on** (criterion 3: a pi-less machine is a normal configuration). Silence and
     "skipped" are different outputs; say which.
   - **Missing junction:** for each `skills/*` compare against the claude root; for each `skills/*` +
     `skills-pi/*` compare against the pi root. Report folder name and the root it is missing from.
   - **Stale junction:** walk each root, read the link's **raw target string** (`readlink`, not a
     resolved path — a dangling link cannot be resolved), keep only targets that point inside this
     repo, and report any whose source folder no longer exists. Scoping to this repo matters: those
     roots hold the user's own unrelated skills and must never be flagged.
   - Criterion 4 is satisfied by construction — `skills-pi/*` is only ever compared against the pi
     root, so its absence from the claude root is never computed, let alone reported.
2. `skills-lint-test.sh` — cases that fail without step 1, using the overridable roots against the
   throwaway fixture: (a) source folder with no junction → reported; (b) junction whose source is gone
   → reported; (c) both roots absent → silent-but-stated, exit still 0; (d) a junction pointing outside
   the repo → **not** reported; (e) `skills-pi` folder absent from the claude root → **not** reported.
   (d) and (e) are the false-positive guards and are the cases most likely to be skipped — write them.
3. `AGENTS.md` — **register-on-introduce fires here.** "The lint may carry advisory sections that are
   environment-dependent and never affect its exit code" is a new cross-cutting pattern and a new
   contract for the repo's only gate; § Conventions › Testing gets the one-liner, § Commands gets what
   the check reports and how to override the roots.
4. `docs/architecture.md` — the install/junction section currently ends at TASK-011's documented rule;
   add that a detector now exists and what it cannot do (detect, never repair).
5. Run `skills-lint-test.sh` then `skills-lint.sh`. Then the drill in `## Human test plan`.

### Risks and open questions

- **ADR or not?** Applying the repo's three-part test: hard to reverse — *no* (deleting a script
  section); surprising without context — *yes*; result of a real trade-off — *yes*. Two of three, so
  **a § Conventions line with inline rationale, not an ADR**. Let `/verify-conventions` arbitrate at
  close rather than pre-deciding.
- **An advisory is easy to scroll past.** That is the real cost of choosing non-fatal, and it is
  accepted rather than solved: the alternative is a gate that fails on a condition no diff can fix.
  If it proves too quiet in practice, that is a follow-up task with evidence, not a guess now.
- **A junction named for a `skills-pi/` skill sitting in the *claude* root is a genuine defect** — the
  `pi-install.ps1` header warns those stubs would shadow the real built-ins — but it is a *third*
  check, not one of these criteria. Spawn candidate; do not widen this task.
- **`.sh` installer paths stay untested** on Windows, as TASK-011 already recorded. The lint check
  reads links with `readlink`, which works under Git Bash, so the check itself is testable here even
  though `install.sh` is not.
- **No split signal.** Steps 1–2 are one change and its test; 3–4 are the register-on-introduce
  obligation that the same change incurs.


### Drill record — 2026-08-19

Ran all three `## Human test plan` items against the real install roots where that was safe, and
against overridable roots where it was not (renaming a production skill folder would break every
`[[link]]` to it, so the lint would fail on check 2 instead of exercising check 4 — the drill used a
throwaway `zz-drill-probe` folder instead, since deleted).

| Item | Result |
|---|---|
| Folder added, not installed | ✅ named in **both real roots**, exit still 0. This is the TASK-011 failure caught automatically for the first time |
| Deleted again | ✅ check goes quiet — both roots back to "in sync" |
| Source renamed → stale junction | ✅ `zz-drill-probe in <root> points at <path>, which no longer exists — stale junction` |
| No `~/.pi` at all | ✅ one "skipped" line, and **not** 16 false "missing" reports |

**Three defects in my own work, all found by testing rather than review, and all fixed before commit:**

1. **`ln -s` silently *copies* under this Git Bash** (MSYS `winsymlinks` unset), so `-L` was false and
   `readlink` empty — fixture links were untestable. The suite now falls back to a PowerShell junction,
   which is what `install.ps1` creates anyway; `ln -s` still takes the POSIX path on CI.
2. **The ownership test was a false-negative trap.** It prefix-matched the link target against
   `$(pwd -P)`. Measured: `readlink` reports a junction into the Windows temp as `/tmp/…` while `pwd -P`
   gives `/c/Users/…/Temp/…` — same directory, no common prefix, so the link is skipped as "not ours"
   and the stale case is silently lost. It passed live only because this repo sits where the two forms
   agree. Now matched on the target's **tail** (`*/<repo-basename>/skills{,-pi}/*`); verified
   non-vacuously — 13 of 13 of this repo's links matched, and 4 links into `Birko.Framework` were
   correctly ignored.
3. **A 30-line wall for an existing-but-empty root.** "Nothing is linked" is one condition, not N
   findings. Collapsed to a single summary line while keeping per-skill naming for the case that
   matters. This then broke a test case that asserted per-skill naming against an empty root — split
   into two cases (`r_empty` for the summary, `r_partial` for the naming), which is better coverage
   than the original.

**Also strengthened, unprompted:** the two `case_silent` guards passed with check 4 deleted entirely —
a "must not appear" assertion is vacuous when the feature is gone, which is the same vacuous-pass shape
TASK-002 already fixed once in the lint itself. They now require the check to have run.

**Test suite: 25 → 31 cases.** All six new ones fail with check 4 removed (verified twice, before and
after the split), so the repo's "not done until a case fails without it" rule is met non-vacuously.

**Criterion-wording note, no skill change needed:** item 3 says the check should "stay silent" on a
machine with no `~/.pi`. It prints `skipped … — not present on this machine`. Criterion 3's actual
requirement is that it "does not fail or warn", which is met — and stated-over-silent is deliberate,
matching this repo's own rule that a silent skip is indistinguishable from a step that was forgotten.
