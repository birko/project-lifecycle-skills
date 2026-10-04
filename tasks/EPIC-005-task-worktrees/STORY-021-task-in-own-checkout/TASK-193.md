---
id: TASK-193
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-29
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-186-1]
pr: null
github-issue: null
jira-key: null
---

# "Local mode" names two unrelated settings, and a cold runner read one as the other

## Context

Found by the TASK-186 drill (2026-09-29, remote-mode fixture of Affiliate). The `/fix-next` runner
reported: *"the config says `mode: local`, but the pick commit is only on the task branch … the skill
doesn't say which wins."*

Two different facts share the words:

| Words | Meaning | Where |
|---|---|---|
| `mode: local` / "local mode (files only)" | the **tracker**: files only, no GitHub/Jira sync (vs `hybrid`) | `tasks/.config.yml`, `tasks/SKILL.md` description and § Mode |
| "local mode" / "remote mode" | the **worktree workspace**: whether the default branch tracks a remote (`<default>@{upstream}`) | `pick.md` steps 3, 6b; `close.md` steps 4b, 8; `fix-next/SKILL.md` step 2 |

A repo with `mode: local` and an upstream, which is the common case, is "local mode" by one and
"remote mode" by the other. The runner reached the right answer only because step 0's branch lookup
runs regardless. A skill step that branches on "in local mode" (fix-next step 2, `pick.md` 6b) can be
read against the wrong setting.

## Acceptance criteria

- [x] The worktree sense gets a name that cannot be read as `mode:`. For example "upstream-tracked" / "no upstream", or keep "remote mode" and rename its counterpart. Chosen and recorded in `docs/glossary.md`.
- [x] Every worktree-sense "local mode" in `skills/` (the sites in the table, found by `grep -rn "local mode" skills`) uses the new name.
- [x] FEATURE-001's decision ledger records the rename as a `changed` decision, since it rewords shipped behaviour.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- Renaming `mode: local | hybrid` itself. It is a declared field that consumer repos already carry, and changing it would need an `init` reconcile path.

## Human test plan

- [x] Cold drill: a runner in a repo with `mode: local` and an upstream-tracked default branch, briefed to explain which workspace path `pick` 6b takes and why, without being told about the collision. It must name the upstream check, not `mode:`.

## Implementation plan

**Name chosen by the owner (2026-10-04): "upstream" / "no upstream"** — the word "mode" is dropped from the worktree
sense entirely, so nothing is left for a reader to match against `mode:`. The name is the fact the behaviour turns on:
whether `<default>@{upstream}` resolves.

1. **Rename every worktree-sense site** — `pick.md` (20), `close.md` (17 + 2 hyphenated), `fix-next/SKILL.md` (4),
   `tasks/SKILL.md` (2: the Collection pass and § *Where the work happens*). Prose reads "with an upstream" / "with no
   upstream". Report lines read `workspace: upstream (…)`. `tasks/SKILL.md:3` ("local mode (files only)") is the
   tracker sense and stays.
2. **Records:** `docs/glossary.md` gets an entry for the two senses. AGENTS.md's three mentions (the "Remote mode is
   derived" convention bullet) and `docs/architecture.md`'s one are renamed. FEATURE-001's ledger gets D23 →
   `changed` with a History line. Past History lines are not rewritten.
3. **Specs:** `work-tracking` (10 mentions) and `defect-draining` (2) describe these skills, so a scoped
   `/specs regen` of those two areas, under the stable-wording rule. The diff should be the rename and nothing else,
   which is also the "deliberate change" check TASK-080 wants.
4. Lint; grep for any remaining worktree-sense "local mode" or "remote mode" in `skills/`.
5. **Human test plan:** the cold drill as written — a runner in a repo with `mode: local` and an upstream, asked which
   path `pick` 6b takes. It must name the upstream check, not `mode:`.

## Progress log

- 2026-10-04 — Picked; planned inline. 44 worktree-sense sites plus 4 hyphenated forms found by grep. Name chosen by the owner.
- 2026-10-04 — Renamed: 19 sites in `pick.md` (including the report lines, now `workspace: upstream …`), 19 in `close.md` (including the 4 hyphenated forms), 4 in `fix-next`, 2 in `tasks/SKILL.md`. The tracker sense in `tasks/SKILL.md`'s description ("local mode (files only)") is untouched, as is `migrate`'s "from local mode" in the spec. `grep -rniE '\b(local|remote)[ -]mode\b' skills skills-pi` now finds only that line. Each replacement was applied as an exact match that had to hit exactly once.
- 2026-10-04 — Records: a `docs/glossary.md` § upstream entry (the two facts, declared vs derived, and "never write local/remote mode for the second"). AGENTS.md's three mentions, including the § Conventions bullet now titled "Whether there is an upstream is derived, not declared", and `docs/architecture.md`'s one. FEATURE-001 D23 stays `changed`, with its text updated and a "Renamed 2026-10-04" note, plus a History line.
- 2026-10-04 — **Specs:** scoped regen of `work-tracking` and `defect-draining`. Neither area's sources had changed since harvest apart from this rename, so under the stable-wording rule the diff is exactly the rename: 18 lines changed, 18 removed. Classified as matching D23 (changed). Re-stamped at `eebeb6e`. `shaped-by` is unchanged on re-derivation, and unresolved stays 7, because this task has no commit of its own yet. This is also the first real instance of TASK-080's "deliberate change shows exactly that change" check, noted there.
- 2026-10-04 — **Human test plan — cold drill, passed.** Runner: `claude -p --disable-slash-commands --allowedTools "Bash(git:*)" Read Glob Grep < brief.txt`, cwd `%LOCALAPPDATA%\Temp\d193` (outside every repo), holding `skill/` (copies of the renamed `tasks/SKILL.md` and `verbs/pick.md`) and `repo/`. `repo/` is a git repo with `mode: local`, `workspace: worktree`, `integration: pr-per-task`, `worktree-root: ../wt`, and `main` tracking a local bare `origin`. The brief asked which step-6b branch `/tasks pick TASK-001` takes and where the pick commit lands, without mentioning the collision. **Coldness:** it listed no skills. **Result:** it decided from `main@{upstream}` → `origin/main` and quoted "It names an upstream → **upstream**". It put the pick commit on `task/TASK-001` after the proof, and never treated `mode: local` as relevant: `mode:` does not appear in its "pointed the other way" list. Passed.
- 2026-10-04 — The drill's runner also noted in passing that the in-place fallback with an upstream never says where the status flip is committed. Confirmed against `pick.md`: it stays an uncommitted edit on the task branch until `close`. Harmless, since the pushed branch is the taken signal, but unstated. Filed as **TASK-254** (DRILL-193-1, P3, not linked to FEATURE-001, because it changes no decided behaviour).
- 2026-10-04 — Close review. Intent: all four criteria met, plus the human test plan. Correctness: wording only, and nothing in `skills/`, the lint or its tests parses the old report lines. Comments: none touched. Conventions: the glossary entry and the renamed § Conventions bullet register the name. → **done**.
