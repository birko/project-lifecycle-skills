---
id: TASK-242
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P1
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-65, SH-67, SH-70]
pr: null
github-issue: null
jira-key: null
---

# `new-project`'s fill steps can ship unrendered tokens, and run a remote command before the repo exists

## Context

Found by the project-baseline spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second
reader against the files at `adc4c27`. All three are in `skills/new-project/SKILL.md` steps 3–6 and its § Conventions.

- **SH-70 — four tokens have no fill rule.** `README.seed.md`'s `{{GETTING_STARTED_COMMANDS}}` and `{{LAYOUT_TREE}}`,
  and `CLAUDE.seed.md`'s `{{ARCHITECTURE_NOTES}}` and `{{BUILD_RUN_COMMANDS}}`.
  - Step 3 says to fill README tokens "from intake", and intake gathers none of them.
  - `{{ARCHITECTURE_NOTES}}` has a source only when the scope grill runs, and the grill is skipped silently for
    throwaway and docs-only repos.
  - Two of them describe a skeleton that is only written in step 5, and no step comes back to fill them.
  - The no-dangling-token rule covers `## Conventions` subsections only.
  - Result: an unrendered token, or an invented value, can reach a consumer repo.
- **SH-65 — remote before repo.** For hybrid-GitHub, step 4 says "do step 6's remote action now (offer
  `gh repo create` …)". Step 6's command is `gh repo create <name> --private --source=. --remote=origin`. That fails
  on a directory that is not a git repo, and `git init` is only asked about in step 6. The "ask for `owner/name`"
  alternative still works.
- **SH-67 — clobber with consent vs never overwrite.** § Conventions says "never clobber a present
  README/CLAUDE/.gitignore without showing the diff and confirming", which allows overwriting with consent.
  `LAYER.md`'s README and agent-guide rows say never rewrite a human's README and never touch an existing guide's
  content. Step 1 defers to LAYER's merge column.

## Acceptance criteria

- [x] Each of the four tokens has a stated source, and a stated outcome when that source is absent (docs-only, grill skipped) — neither outcome being an unrendered token or an invented value
- [x] Tokens that describe the skeleton are filled after step 5 writes it, or the step that fills them says why it can do so earlier
- [x] Hybrid-GitHub never runs `gh repo create --source=.` before the git-root question is answered
- [x] § Conventions states the same merge rule as LAYER's rows, with no "overwrite after confirming" path for the files LAYER protects
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Disagreements between the layer rows and the front doors (TASK-243)
- The seed templates' own wording (TASK-248)

## Human test plan

- [x] Scaffold a docs-only project with the grill skipped, from a cold runner, and grep the result for `{{`. Expected: none, and every section that had no source is either removed or says so honestly
- [x] Scaffold a hybrid-GitHub project into an empty folder and decline git at first. Expected: no `gh` command fails, and the remote is created or deferred cleanly

## Implementation plan

Planned inline at pick (2026-10-04).

1. **SH-70.** Step 3 fills only the intake tokens. A new last bullet in step 5 fills `{{GETTING_STARTED_COMMANDS}}`, `{{LAYOUT_TREE}}`, `{{BUILD_RUN_COMMANDS}}` and `{{ARCHITECTURE_NOTES}}` once the skeleton exists: a table of each token's source and its outcome when there is no source (docs-only, grill skipped), the hint comment under each removed, and a closing grep for `{{` over README and the guide that must come back empty before step 6.
2. **SH-65.** Step 4 asks whether the GitHub repo already exists. If it does → `init` hybrid with that slug. If it is new, or there is no answer → `init` `local`, and step 6 creates the remote **after** the git question, then offers `/tasks migrate` (the existing path). Step 4 never runs `gh repo create`. If git is declined, the remote cannot be created; say so.
3. **SH-67.** § Conventions defers to LAYER.md's *already present?* column: merge, report conflicts, never overwrite a file the repo owns.
4. `project-baseline` spec: re-harvest the changed requirements under the stable-wording rule.
5. Drills per the human test plan, by cold `claude -p` runners with read access to the skill (`--add-dir`, because the templates must be read). Neither may reach GitHub.

## Progress log

- 2026-10-04 — Picked; planned inline. **SH-70:** step 3 now fills only the intake tokens. A new last bullet of step 5 fills the four skeleton tokens from a table of source and no-source outcome (docs-only: "No code yet — …" / "None yet — no code."; grill skipped: a pointer to `docs/architecture.md`; the layout tree always has a source), deletes each hint comment, and greps README and guide for `{{` before step 6. Step 3's "change only token lines" names the hint-comment exception. **SH-65:** step 4 asks whether the GitHub repository already exists (question quoted, answer-less path = `local` with hybrid reported deferred) and never creates the remote. Step 6 creates a new remote only once the directory is git-tracked, then offers `/tasks migrate`; with git or the creation declined it creates nothing. **SH-67:** § Conventions now defers to LAYER.md's *already present?* column and § Rule; the "overwrite after confirming" path is gone.
- 2026-10-04 — **Spec:** `project-baseline` re-harvested for the changed requirements under the stable-wording rule. The templates requirement gains the skeleton-token rule and a docs-only scenario; task tracking gets the exists/new question with a new scenario; the git requirement says the remote comes only after git. 12 lines added, 6 removed. SH-67 needed no spec change: the spec already said "merge per the inventory's column". Re-stamped at `578f440`; `shaped-by-unresolved` 7 → 5, because TASK-193's and TASK-194's commits now resolve.
- 2026-10-04 — **Human test plan — both drills passed.** Each runner had its own folder outside every repo, `%LOCALAPPDATA%\Temp\d242a` and `d242b`, holding a copy of `skills/` (so the templates and the referenced skills were readable without `--add-dir` into this repo). Command: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(mkdir:*)" "Bash(ls:*)" Read Write Edit Glob Grep < brief.txt`. There was no `gh` in the allowlist. The brief gave the intake answers, with any other question left unanswered. **Coldness:** both listed no skills.
  - **A — docs-only, grill skipped, git yes:** `grep -rn '{{\|<!-- e\.g\.'` over the output is empty. README reads "No code yet — this repository holds documents only." The splice was checked identical, git was initialised and the scaffold committed.
  - **B — Python, hybrid-GitHub, "a new one", git no:** no `gh` command ran; the runner listed `gh repo create … --source=.` under "would run, but skipped: this needs git". `tasks/.config.yml` says `mode: local`, with `/tasks migrate` named as the way back. The output grep is empty. One deviation outside this task: its closing checklist left out the hybrid-deferred line and the two `unknown` conditional-row lines, which it reported in its questions section instead. That was one runner, and the step-6 checklist rules predate this task, so it is recorded here and not filed.
- 2026-10-04 — Runner B also noticed its `CLAUDE.md` inherited CRLF from the template. Traced to **this machine's working copy**: five files under `skills/` were `w/crlf` or `w/mixed` while the index holds LF. The installed skills are junctions to the working copy, so local scaffolds inherited the CRs. The files were normalised to LF; their blob hashes equal the index, so no commit was involved. This is not a repo defect, and by AGENTS.md's rule a repo-level check never turns machine state into a verdict, so nothing was filed.
- 2026-10-04 — **Found in passing, spawned as TASK-256:** `adopt-project` adds the seed's missing `## Architecture` and `## Commands` sections, and nothing says how to fill their tokens. It is the same defect as SH-70, through the other front door.
- 2026-10-04 — Close review. Intent: all four criteria plus both test-plan drills. Correctness: wording and ordering only, proved by the two drills. Comments: none. Conventions: the ask-step carries its question and its answer-less path; no layer row changed, so no parity edit was owed (TASK-256 owns the adopter's side). → **done**.
