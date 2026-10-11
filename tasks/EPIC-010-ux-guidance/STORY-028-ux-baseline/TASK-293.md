---
id: TASK-293
parent: STORY-028
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-09
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# A UX baseline that `/verify-conventions` and `/feature prototype` read, the way they read the smell inventory

## Context

Raised from a consumer (Birko.Web / Symbio), where the UX rules sit in four files across two repos and nothing
lints a UI diff for the judgement calls those files never recorded. Measured there: **78 `confirmDelete(` and 38
`confirm(` calls**, a shared delete string reading *"This cannot be undone"*, and no undo mechanism anywhere — the
confirm dialog is the default for every reversible action because nothing ever asked the question.

`/verify-conventions` already has the slot: a **smell baseline** that runs after the repo's rulebook, is labelled
`smell:`, never blocks, and is suppressed by any documented rule that conflicts. Its inventory is code smells only
(`skills/tdd/refactoring.md`). This task adds a second inventory for interaction design, read by the same rules.

Source for the first rows: Smashing Magazine, *"The Death of the Button: Why the Best Interface Is No Interface"*
(2026-09). **The article carries no usage data or measured outcomes** — its claims are examples and conceptual
references (Nielsen's heuristics, Google PAIR, Center for Humane Technology). That is why every row is a judgement
call, and why its forward-looking parts (generative UI, autonomous agents) are not rows: they are a direction, not
a signal anyone can see in a diff.

**Not a defect, and not loose either:** it is new behaviour, so it lives under EPIC-010 / STORY-028 (moved from `tasks/_loose/` 2026-10-09). `tasks/_loose/` is for tree hygiene and meta-work.

## Acceptance criteria

- [x] `skills/verify-conventions/ux-baseline.md` exists: one table, each row a heuristic with an **observable
      signal in a diff** and a suggested move, in the shape of `skills/tdd/refactoring.md`
- [x] `/verify-conventions` § *The smell baseline* reads it for UI files, under the same three rules (repo
      overrides, `smell:` label, skip what tooling enforces) — stated once, not restated per inventory
- [x] `/feature prototype` step 3 points the HTML mockup and markdown wireframe at it, and a prototype choice the
      baseline questions becomes a decision row rather than a silent default
- [x] AGENTS.md § *A vocabulary shared by several skills* names this as the third owned inventory
- [x] CHANGELOG `[Unreleased]` › Added has an entry
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- A `new-project` intake question about confirm-vs-undo policy — an ask-step needs its question text and its
  answer-less path (AGENTS.md § *Output / prose rules*). **Decided not to do (owner, 2026-10-11):** a project
  that cares writes the rule in one line, and the baseline already yields to it (drill step 2), so asking every
  new project costs more than it saves
- Any consumer-side rule or framework change (Birko.Web toast action slot, undo hook) — those belong to the consumer

## Human test plan

- [x] In a repo with UI code and a rulebook that says nothing about confirmation, stage a diff adding a
      `confirm()` before a reversible delete and run `/verify-conventions`. Expect a `⚠ smell:` finding citing the
      UX baseline, after the rulebook findings
  - **Passed 2026-10-11:** `⚠ smell: confirm guarding a reversible action — src/note-list.js:12`, citing the soft
    delete and `restoreNote` as evidence, after the ✅ rulebook verdict; plus `💡 smell: confirmation that names
    nothing` for *"Are you sure?"*
- [x] Add a rule to that repo's CLAUDE.md requiring a confirm on every delete and rerun. Expect the finding to
      disappear (repo overrides)
  - **Passed 2026-10-11:** the reversible-action smell was gone from the findings, and the runner said the rule
    suppresses it; the names-nothing smell stayed, correctly, since the rule says nothing about wording

**Drill record.** Fixture: `%TEMP%\d293`, a fresh `git init` notes app (plain JS) whose `CLAUDE.md` has four
conventions and no word on confirmation; `src/api.js` soft-deletes (`trashNote`/`restoreNote`); the staged diff
adds `if (!confirm("Are you sure?")) return;` before `trashNote`. Runner, from that cwd:
`echo "/verify-conventions" | claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" Read Grep Glob
--add-dir C:/Users/FinStat/.claude/skills C:/Source/project-lifecycle-skills`. Coldness: the brief was the bare
invocation, with no expected finding; the runner holds the installed skill roster, which a **behaviour** drill
needs (it must run the skill), and the fixture's guide names no skill. Step 2 appended
`- Every delete asks the user for confirmation before it runs.` and reran the same command.

## Implementation plan

1. Write `skills/verify-conventions/ux-baseline.md` — header stating ownership and readers, then the table.
2. In `skills/verify-conventions/SKILL.md` § *The smell baseline*, name the second inventory and when it applies
   (UI files); add a sample finding to § *Output format*.
3. In `skills/feature/verbs/prototype.md` step 3 (HTML mockup, markdown wireframe) and step 4, point at it.
4. AGENTS.md bullet + CHANGELOG entry; run the lint.
