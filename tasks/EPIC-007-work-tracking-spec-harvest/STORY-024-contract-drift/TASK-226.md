---
id: TASK-226
parent: STORY-024
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
findings: [SH-8, SH-9, SH-10]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Three references point at things that do not exist

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). Each sends a reader to something absent.

- **SH-8 — `move.md` step 5** cites "`verbs/close.md` step 7's note and TASK-036" for the anchored-`parent:`
  hazard. `close` step 7 has no such note — the warning lives in `specs` regen — and TASK-036 is this repo's own
  task id, which does not exist in a consumer's install.
- **SH-9 — `show.md`'s STORY view** prints "owner", but the STORY template has no `owner` field (only the EPIC
  template does).
- **SH-10 — `export.md` step 5** warns that a `# labels:` comment line can be mistaken for the title. The TASK
  template carries no `# labels:` comment — only the status, blocked and findings comments.

## Acceptance criteria

- [x] `move.md` points at where the hazard is actually stated, or states it itself, with no repo-local task id
- [x] `show`'s STORY view lists only fields a story has
- [x] `export`'s warning names the comment lines the template actually emits
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other references to this repo's records — TASK-210's classification sweep

## Human test plan

N/A — references, checked by following each to its target.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Triggers: three files, four criteria.

1. **SH-8** — `verbs/move.md` step 5: drop the citation of `close` step 7's note (it does not exist) and of
   TASK-036 (this repo's id). The sentence already states the hazard; finish it with what a loose match does.
2. **SH-9** — `verbs/show.md` STORY view: replace `owner` with the field the STORY template has, `theme:`, shown when
   present.
3. **SH-10** — `verbs/export.md` step 5: name the TASK template's actual comment lines (`# status`, `# blocked`,
   `# assignee`, `# findings`) in both the list and the title check. Confirm first that no template version ever
   emitted `# labels`, since export also reads older task files.
4. Respec `work-tracking` only if a requirement restates one of these.

## Outcome

**The fix.** Three `tasks` verbs pointed a reader at things that do not exist:
- **`move`:** step 5 cited "`close` step 7's note and TASK-036". There is no such note, and TASK-036 is this repo's
  own id. The sentence now ends by stating what a loose match does, so nothing needs following.
- **`show`:** the STORY view printed an `owner` field stories do not have. It now shows `theme:` when a story carries
  one.
- **`export`:** step 5's title warning named a `# labels:` comment no template emits, and missed the `# assignee`
  comment the template does emit. It now lists exactly the template's four comment lines, in both the list and the
  title check.

**Step 6 split.** 3 of 3 assertion groups failed on HEAD's verb files and pass on the fix. All three are
fix-dependent: `move` cites no repo-local task id, `show`'s STORY view lists no field missing from the STORY template,
and `export` names no comment absent from the TASK template. The completeness half (no template comment omitted) did
not fire on the old file, which mentions `# assignee` elsewhere, so it is a contract pin for this change, not evidence.
skills-lint passes on both.

**Judgement calls.**
- **`# assignee` added, though not in the finding.** SH-10 was "names a comment the template doesn't emit". The same
  sentence also omitted one the template does emit, and the title check would let an `assignee — one of: …` title
  through, the measured failure the warning exists for. Same sentence, same root cause.
- **History checked before dropping `# labels`.** Export reads task files written by older templates. No version of
  `templates/TASK.md` ever carried `# labels` (searched every commit touching it), so dropping it protects nothing real.
- **`show` prints `theme:` only when present**, rather than always. The template says to omit it on an ordinary
  story, so a fixed field would print an empty value on most stories.
- **No spec change.** `work-tracking` describes `show`'s output and export's payload in general terms and restates
  none of the three lines. Regen would leave the area unchanged.
- **`export`'s named repo (FlowerFurStudio) left in place**: that is TASK-210's classification sweep, named in this
  task's Out of scope.
- **Close gate ran inline** on a ~10-line prose diff.
  - Standards: no finding.
  - Intent: all three content criteria met, plus the `# assignee` addition above.
  - Correctness: no other reference to `# labels` or TASK-036 remains in `skills/tasks`.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Nothing.

## Progress log

- step 2 — picked; ranked above TASK-264 because both are wrong results in shipped prose (key 1), but `move`, `show` and `export` are routine `tasks` verbs reached on every tree while `feature prototype`'s state-model playground is one form of one verb (key 2, reachability); TASK-226 was last run's runner-up behind TASK-271, now closed. Key 6 did not separate them: TASK-264 sits loose under EPIC-002 (no theme), which sorts it after TASK-226's `contract-drift` anyway
- step 3 — verified: held, all three. `close.md` carries no anchoring note; STORY template has `theme:`, no `owner`; TASK template comments are `# status`, `# blocked`, `# assignee`, `# findings`, with no `# labels` in any version
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: three files, four criteria)
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/move.md, show.md, export.md (plus `# assignee` in export's list, same sentence)
- step 6 — reverted fix (HEAD's verb files): 3/3 assertion groups failed; fix-dependent = no repo-local id in move step 5, no non-story field in show's STORY view, no non-template comment in export; contract pins = export's no-omission half (did not fire on the old file), skills-lint
- step 7 — work-tracking: no requirement restates these lines; unchanged
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
