---
id: TASK-011
parent: STORY-002
feature: null
status: done
priority: P1
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `adopt-project` is not installed in either runtime — a new skill folder needs an installer re-run

## Context

`skills/adopt-project/` shipped today (`ef22e64`, `7375162`), but neither runtime can resolve it:

```
ls ~/.claude/skills      → new-project, birko-new-project, …  (no adopt-project)
ls ~/.pi/agent/skills    → new-project, …                     (no adopt-project)
```

`install.ps1` enumerates `skills/` with `Get-ChildItem -Directory` and creates **one junction per
folder**. That is what makes an *edit* live immediately — and exactly why a *new folder* is not:
the junction for it has never been created. So `/adopt-project` does not resolve, and the
description's trigger phrases reach nothing.

This also puts a question mark on STORY-002's drill evidence: any drill recorded before the
junction exists was run by reading `skills/adopt-project/*.md` out of this repo, not by invoking
the installed skill. That is a weaker test — it never exercised discovery, and discovery is the
half that is currently broken.

The repo's own `## Commands` section documents `./install.sh` / `install.ps1` but nothing says
*when* a re-run is required, so the same gap will recur for the next new skill.

## Acceptance criteria

- [x] `adopt-project` resolves in Claude Code — junction at `~/.claude/skills/adopt-project` → `skills/adopt-project` in this repo; the session's skill list refreshed and now offers it
- [x] It resolves in the pi runtime too — junction at `~/.pi/agent/skills/adopt-project`, same target. **Filesystem-verified only**: that pi loads it can be confirmed only by invoking it in pi
- [x] The repo records that **adding a skill folder requires re-running the installers** (editing an existing one does not) — recorded at all three sites that carried the half-truth: `AGENTS.md` § Architecture, `AGENTS.md` § Commands, `docs/architecture.md`
- [x] Drill evidence predating the junction is marked, not re-run — 7 checked lines annotated `— run from the repo copy, pre-junction` across TASK-003 (3), TASK-004 (1), TASK-007 (3). Re-running belongs to each task's own close

## Out of scope

- Making the installers self-healing (watching for new folders, or a lint that compares `skills/` against the two install roots) — a design change, not this fix → **TASK-016**, which also carries the rename/delete drift this task's junction scan exposed.
- The four-state survey drift → TASK-012.

## Human test plan

- [x] Re-ran `./install.ps1` and `./pi-install.ps1` — exactly one `+ adopt-project` per root, every other skill `= already linked`, no warnings
- [x] Confirmed 2026-08-18 in a fresh session: typing `adopt this repo` resolved to `Skill(adopt-project)` with **no path and no skill name given** — description match, which is the half the junction check could not prove from inside a primed session. Unasked-for bonus evidence in the same run: its first move was to read [[verify-conventions]]'s rulebook **ladder**, i.e. `LAYER.md`'s rulebook row delegating detection to the skill that owns it instead of guessing separately — TASK-008's delegation criterion behaving in the wild. Recorded honestly: only the invocation is evidence here; what the run then did to its target repo is a separate drill on its own task
- [x] Appended a probe marker to `skills/adopt-project/SKILL.md`; it read back through **both** link paths with no re-install, then reverted clean (proves junction, not copy)

## Implementation plan

⚠ Acceptance criteria question: criterion 3 offers a choice between `AGENTS.md` § Commands and
§ Architecture, but the misleading sentence exists in **three** places — `AGENTS.md` § Architecture
("Both installers link rather than copy, so an edit here is live … immediately"), `AGENTS.md`
§ Commands (the two install lines, with no note on when to re-run), and `docs/architecture.md`
§ What this repository is (the same claim, worded slightly differently). Fixing only one leaves the
other two still teaching the wrong thing. The plan below edits all three; `AGENTS.md`'s own
"if the change alters structure, update § Architecture and `docs/architecture.md` too" rule already
requires the third. Flagging rather than silently widening — say so if you want it narrowed.

### Step 1 — Create the missing junctions

Run both Windows installers from the repo root:

```powershell
./install.ps1
./pi-install.ps1
```

Both are idempotent and print `= <name> (already linked)` for existing junctions, so the only new
output should be the `+ adopt-project -> …` lines. Anything else — a `links elsewhere` or
`a real directory already exists` warning — is a separate finding, not part of this fix.

### Step 2 — Verify both roots, and verify they are *links*

```bash
ls ~/.claude/skills/adopt-project ~/.pi/agent/skills/adopt-project
```

Existence alone is not the criterion: a copied directory would satisfy `ls` and then silently rot.
Confirm the junction resolves back into this repo (`Get-Item <link> -Force` shows `LinkType` +
`Target`). The Human test plan's third bullet — edit a line, see it live without re-installing — is
the behavioural version of the same check and is the one that actually proves it.

Expected end state (the two roots currently diverge for good reason — `skills-pi/` is pi-only):

| Root | Should gain |
|---|---|
| `~/.claude/skills` | `adopt-project` |
| `~/.pi/agent/skills` | `adopt-project` |

### Step 3 — Record the rule where it will be read

The root cause is documentary, not mechanical: every doc says the installers *link*, so edits are
live — and none says the corollary that a **new folder** has no link yet. Add the corollary next to
each claim, keeping it to one line per site.

| File | Site | Change |
|---|---|---|
| `AGENTS.md` | § Architecture, after "Both installers **link** rather than copy…" | Add the corollary: linking makes *edits* live, but a **new skill folder needs an installer re-run** before either runtime can resolve it. |
| `AGENTS.md` | § Commands, the `install.sh` / `pi-install.sh` block | Add a comment line stating both must be re-run after adding a skill folder (not after editing one). |
| `docs/architecture.md` | § What this repository is, the "installers *link* rather than copy" sentence | Same corollary, one sentence, in that doc's voice. |

Wording constraint: this repo's prose rules want the *rationale* inline for a non-obvious rule. The
rationale is one clause — one junction per folder, created at install time — so it fits.

### Step 4 — Reconcile STORY-002's drill evidence

Every checked drill box under STORY-002 predates the junction, so all of it was run by reading
`skills/adopt-project/*.md` out of this repo. That is still real evidence of *behaviour*; it is not
evidence of *discovery*. Mark, don't silently keep:

| Task | Checked lines to annotate |
|---|---|
| TASK-003 | 3 (`this` repo, twice-in-a-row on Latent, Latent README untouched) |
| TASK-004 | 1 (BardStudio, 70 files) |
| TASK-007 | 3 (Latent CI row, flappy-dragon, no workflow written) |
| TASK-008 | 0 checked — nothing to annotate |

Append `— run from the repo copy, pre-junction` to each checked line. **Do not un-check them and do
not re-run them here.** Re-running belongs to each task's own close, and pulling four other tasks'
verification into this one is exactly the widening the task-first gate forbids. What this task owes
is honesty about how the evidence was obtained; criterion 4 explicitly allows that route.

### Step 5 — Run this task's own Human test plan

The third bullet (edit a line, confirm it is live with no re-install) is the one that distinguishes
a junction from a copy — run it last so it also proves steps 1–2 did the right thing. The
description-match bullet needs a **fresh session**: this one has its skill list already loaded, so
it cannot honestly test discovery.

### Critical files

- `install.ps1`, `pi-install.ps1` — **run, not edited**. Self-healing installers are out of scope.
- `AGENTS.md` — two sites (§ Architecture, § Commands)
- `docs/architecture.md` — one site
- `tasks/EPIC-001-.../STORY-002-adopt-project/TASK-00{3,4,7}.md` — evidence annotations only

### Risks / tradeoffs

- **The `.sh` installers are untouched and unverified.** Work here is on Windows, so only the
  `.ps1` pair actually runs. The recorded rule must name both pairs, since a consumer on Linux hits
  the identical trap — but this task cannot claim the bash path was tested.
- **This fix does not prevent recurrence, only re-diagnosis.** The next new skill folder will be
  just as unlinked; the doc line is what makes it a five-second fix instead of a puzzling
  "why doesn't my skill trigger". The mechanical guard (a lint comparing `skills/` against both
  install roots) is deliberately out of scope → spawned as TASK-016 at this task's close.
- **Criterion 2 is unverifiable from inside Claude Code.** Whether pi actually resolves the skill
  can only be confirmed by invoking it in pi; `ls` proves the junction exists, not that the runtime
  loads it.
