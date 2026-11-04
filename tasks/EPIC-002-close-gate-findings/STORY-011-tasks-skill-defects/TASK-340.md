---
id: TASK-340
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-331-1, DRILL-331-2]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# The task template has no `{{FINDINGS}}` token for `new` to fill, and the N/A test-plan wording differs

## Context

Found by TASK-331's verification drill (2026-11-04, recorded on TASK-331). Both claims checked by hand:

- **DRILL-331-1:** `skills/tasks/verbs/new.md` steps 0 and 8 say to set `{{FINDINGS}}` to the id list
  (`--from-review`, `--from-field`). But `skills/tasks/templates/TASK.md` hard-codes `findings: []`, so a literal
  render has no token to fill. A renderer that substitutes only the tokens it finds writes `[]`. The task then
  drops out of `/fix-next`'s pool, because the pool is defined by a non-empty `findings:` (or an intake epic,
  which a `--from-field` loose task does not have). The drills so far wrote the ids by editing the line, so
  nothing has measured the failure yet. A literal reading reaches it.
- **DRILL-331-2:** `skills/tasks/SKILL.md` (Lifecycle, about line 404) writes the plan's opt-out as
  `N/A — covered by automated tests`. `new.md` step 9, `close.md` step 5 and the template write
  `N/A — fully covered by automated tests`. A gate matching one wording misses the other.

## Acceptance criteria

- [x] `templates/TASK.md` carries a `{{FINDINGS}}` token in YAML-safe form, or `new` says to edit the `findings:` line rather than fill a token. Check AGENTS.md § *A template ships nothing a render cannot make true* for the YAML token rule first
- [x] One N/A wording across SKILL.md, `new`, `close` and the template
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- TASK-331's three findings

## Human test plan

- [x] A cold runner files a task with `/tasks new task --from-field` from the template, rendering literally. Expected: the file's `findings:` holds the minted `FIELD-NNN`
  - **Passed 2026-11-04:** a cold runner on fixture `%LOCALAPPDATA%/Temp/d340` (a single-branch `repo/` with EPIC-001 → STORY-001 and one done task; skill `tasks` copied after this fix) ran `/tasks new task --from-field --no-plan` for "export writes a header row even when there are no rows to export", under STORY-001. The written task reads `findings: [FIELD-001]`, and the run printed `minted FIELD-001 — this task is now in /fix-next's pool.` Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, with the shared drill preamble and closing asks (no expected outcome stated). Coldness: it listed no skills

## Outcome

**What was fixed.** The task template now carries `findings: {{FINDINGS}}` instead of a hard-coded `findings: []`. `new` already said to fill that token with the finding ids, so a task filed from a review or a field report keeps its ids, and with them its place in `/fix-next`'s pool. Two off-form wordings of the test-plan opt-out now read `N/A — fully covered by automated tests`, like every other site.

**Step-6 split:** 0/0, because this is a template and prose with nothing executable. Evidence is the drill, which passed; the lint is a contract pin and skips `templates/`.

**Judgement calls.** A token, not an instruction to edit the line. The hard-coded `[]` is a value a correct render makes false (AGENTS.md § *A template ships nothing a render cannot make true*). The rule's caution about `{{TOKEN}}` in YAML concerns `.yml` templates; this frontmatter already tokenises every other field, and `EPIC.md`'s `affects: {{AFFECTS}}` is the list-valued precedent. An edit-the-line instruction was rejected, because it leaves the template stating a value and a literal render still fails.

**Review (close step 5b, inline).** Adherence: the template follows the rule above, and no list is restated. Fidelity: all three criteria are met. Correctness: an unrendered token now fails to parse, as do its eight siblings. That is louder than the silent `[]`, which is the direction the rule prefers.

**Flagged, not fixed** (from the drill's "left undecided" list, outside this task):
- `new` step 9 says sections a step-0 flag drafts are not offered, but gives no wording for the shortened question.
- "A title in quotes" can read as covering a quoted defect description.
- No search pattern is given for the `FIELD-NNN` max scan.
Each is small. None is filed yet; offered in this run's report.

## Implementation plan

### Criterion 1: add the token, do not tell `new` to edit the line
- `templates/TASK.md`: `findings: []` becomes `findings: {{FINDINGS}}`. The hard-coded `[]` is a value a correct render makes false (AGENTS.md § *A template ships nothing a render cannot make true*): it records "remediates nothing" for a `--from-field` or `--from-review` task, which drops it from `/fix-next`'s pool.
- The rule's caution about `{{TOKEN}}` in YAML is about `.yml` templates. This frontmatter already carries a bare token on every other field, and `EPIC.md`'s `affects: {{AFFECTS}}` is the exact list-valued precedent. `new` steps 0 and 8 already define the value with its brackets (`[CR-7, CR-9]`, `[FIELD-NNN]`, else `[]`), so every branch renders valid YAML.
- Telling `new` to edit the line instead was rejected: the template would keep stating a value, and a literal render would still fail.

### Steps
1. Edit `templates/TASK.md` as above. `new.md` needs no change, because it already defines `{{FINDINGS}}` and its `[]` fallback.
2. `SKILL.md:404` and `close.md:231`: use `N/A — fully covered by automated tests`. Leave `close.md:171` alone; it is a legitimate `N/A — <reason>`.
3. Check for leftovers with a grep. Run the lint (it skips `templates/`).
4. Spec: no requirement wording changes. `work-tracking` already quotes the canonical N/A form and states the intended `findings:` outcome.

### Risks
- A renderer that skips the token leaves `{{FINDINGS}}`, which fails to parse. That is the same as the eight sibling tokens, and louder than today's silent `[]`. Existing task files are untouched.

## Progress log

- step 2 — picked; ranked above TASK-335 because key 1: a literal render of `findings: []` silently drops a filed defect out of the /fix-next pool (silent loss of the pool record), where TASK-335 is a wrong next action (wrong result); keys 3 and 5 tie (both silent, both verified by hand); key 6 agrees (correctness-invariants vs no theme)
- step 3 — verified: held, one detail rescoped in the log, not the criteria: new.md steps 0 and 8 set a `{{FINDINGS}}` token that templates/TASK.md lacks (it hard-codes `findings: []`). On DRILL-331-2, the gates accept `N/A — <any reason>` (close.md:171 is such an example), so the two off-form phrasings (SKILL.md:404, close.md:231) are a consistency defect, not a missed gate
- step 3b — planned: /tasks plan --no-grill (three files, three criteria); no split signal
- step 4 — layer: local
- step 5 — fix in skills/tasks/templates/TASK.md (`findings: {{FINDINGS}}`), skills/tasks/SKILL.md:404 and skills/tasks/verbs/close.md:231 (canonical `N/A — fully covered by automated tests`); leftover grep clean; lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose and template only, nothing executable; fix-dependent = none; contract pins = skills-lint.sh (it skips templates/); evidence = the Human test plan drill
- step 7 — work-tracking: no requirement contradicted (it already quotes the canonical N/A form and states the intended `findings:` outcome; its one `findings: []` is a hand-filed scenario), so nothing was rewritten and the stamp was left as it is
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
