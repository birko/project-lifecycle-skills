---
id: TASK-278
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-113, SH-114, SH-115]
picked-by: fix-next
pr: null
github-issue: null
jira-key: null
---

# Lint check 1 passes descriptions pi will not load, and AGENTS.md overclaims checks 1 and 4

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-113:** `.github/workflows/skills-lint.sh:75-83`: `description:` and `description: ""` both pass check 1. pi's own `yaml` package parses them to null and "", which pi rejects (`description is required`; the skill is not loaded). AGENTS.md's table says check 1 enforces "present and not empty".
- **SH-114:** `:77-81` only looks for `: ` and ` #`. pi's parser throws on a description ending `Use when:` ("Nested mappings are not allowed") and on one starting with `*` or `[` ("Unexpected scalar"), and all three pass the lint. Same outcome as the `: ` row: the skill is not loaded.
- **SH-115 (partly confirmed, wording only):** check 4 stops at a bare lowercase word, so a later flag in `/beta go --real value --nosuch` is unchecked. That is the documented ARG_RE trade-off and no real invocation hits it, but AGENTS.md:331's "every flag on the invocation" claims more than the check does.

## Acceptance criteria

- [x] Check 1 fails an empty description, a description ending in `:`, and a description starting with a YAML indicator character, each with a test case in `skills-lint-test.sh` that fails without the change
- [x] AGENTS.md's description of check 4 matches what it checks
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Test cases for the lint's other untested branches (TASK-029)

## Human test plan

N/A: covered by the new test cases, which must fail without the change (AGENTS.md § Testing).

## Implementation plan

_Populated by `/tasks plan TASK-278` — leave empty until then._

## Outcome

**What changed.** Lint check 1 (frontmatter) passed `description:` values that pi's YAML parser cannot load, so a skill could
vanish from pi while the repo's only gate stayed green. It now fails every shape pi's own parser was measured to reject or
mangle: an empty value (`description:`, `""`, `~`, `null`) unless it continues on indented lines; a leading `#`; a leading
flow or reserved character (`[ ] { } * % @` backtick `,`) or `- `/`? `; `|`/`>` other than a real block-scalar header;
a leading `&`/`!` (anchor or tag, which silently drops the first word); a trailing `:`; and a bare number or boolean. AGENTS.md's
check-1 table gains three rows for these, and its check-4 sentence now says the check stops at the first bare lowercase word
(SH-115, wording only; the spec already said so).

**Step 6, as numbers.** Revert-and-split: the suite was run against `HEAD`'s `skills-lint.sh` with the new tests in place.
**78 passed, 12 failed of 90.** Fix-dependent (all 12 new must-fail cases): empty, quoted empty, `~`, ending `:`, starting
`*`, `[`, `@`, `- `, `&`, `|x`, `true`, `42`. Contract pins (pass either way): `-v flags`, a `>-` block scalar, a value on
indented lines, and the 75 earlier cases. With the fix: 90/90.

**Judgement calls.**
- *Measured, not guessed.* Every rule was checked by running pi's bundled `yaml` against the value, plus pi's
  `validateDescription` (it rejects a non-string or blank value). Rejected: copying `tasks` § *Writing a `blocked:` value*'s
  "when in doubt, quote" list wholesale. That list deliberately over-quotes, and here it would fail `-v flags` and `?x`,
  which load fine.
- *Rejected: rejecting every leading `|`/`>`.* A block scalar is the legitimate way to write a long description, so only a header
  with trailing text (`|x`) fails.
- *The indented-continuation exemption* keeps a valid multi-line plain value from reading as empty. No skill uses that shape today.
  The exemption costs one `awk` line, while a false failure there would teach authors to distrust the check.
- AGENTS.md § Comments table re-measured (eighteenth time). The verdict cells say plainly that TASK-278's four new comment lines
  have not been walked by a reader pair, rather than claiming a pass for them.

**Flagged, not fixed.** None. A flag after a bare word stays unchecked by design (check 4's ARG_RE trade-off), and it is now
stated accurately.

**Close gate (`/tasks close --unattended`), each pass on its own.**
- `ci: main green — 1 workflows read`.
- **standards** (inline): pass. Check 1's new rules are recorded in AGENTS.md's table in the same change (register-on-introduce);
  test count updated; § Comments table re-measured as its own rule requires after a lint edit; no raw CR or tab bytes, and both
  scripts are stored as LF (check 8).
- **fidelity** (inline): pass. Criterion 1 is built and wider (same `case`, same root cause, logged at step 3); criteria 2 and 3
  are met. Out of scope (TASK-029's untested branches) is untouched.
- **correctness** (inline): pass. The case order was checked: quoted values are matched before the `|`/`>` header test, and both
  before the indicator class, so `"*x"` and `>-` are accepted. The number/boolean regex is anchored (`-x`) and so cannot
  match a sentence like `2 things`.
- **security-review**: not applicable. A CI lint over the repo's own files, with no input from outside the repo.
- **review-comments** (inline): four comment lines added. Each carries mechanism or a pointer to this task's measurement; none
  restates code. Not walked by a cold pair, as recorded in the table.
- 5c skipped: `single-branch`. 5d: one Out of scope bullet, a boundary naming TASK-029. Nothing spawned.

## Progress log

- step 2 — picked; ranked above TASK-221 because the lint is the repo's only gate and here it passes a description pi refuses to load, so the skill goes missing in pi with nothing reporting it (key 3, silence; key 5, already confirmed by a second reader), while TASK-221's two verbs contradict each other where a reader sees both. Keys 1–2 tie (wrong result, reachable by an ordinary edit); key 6 inert, both in STORY-023 with the same declared theme
- step 3 — verified against pi's own parser (`@earendil-works/pi-coding-agent/node_modules/yaml`, `YAML.parse("description: <v>")`, and pi's `validateDescription`, which rejects a non-string or blank value): held, and wider. Not loaded: empty, `~`, `null`, a leading `#`, `""`/`''`, and `true`/`42` (non-strings). Parse error: a trailing `:`, a leading `* [ ] { } % @` backtick `,`, `- ` or `? `, and `|x`/`>x`, which the lint currently waves through as block scalars. Silently cut short: a leading `&` or `!` (anchor or tag; pi gets the rest). Pulled the whole set in, because one `case` in check 1 is the single root cause. SH-115 confirmed as wording only (AGENTS.md overclaims check 4)
- step 4 — layer: local (`.github/workflows/skills-lint.sh` check 1, its test suite, AGENTS.md)
- step 5 — fix in `.github/workflows/skills-lint.sh` check 1 (empty/`~`/`null`, unless continued on indented lines; leading `#`; flow/reserved indicators and `- `/`? `; `|`/`>` only as a real block-scalar header; leading `&`/`!`; trailing `:`; bare number or boolean); 15 cases in `skills-lint-test.sh` (12 must fail, 3 must pass: `-v flags`, a `>-` block scalar, a value on indented lines); AGENTS.md check-1 table (3 rows), check 4 sentence (stops at the first bare lowercase word), test count 75 → 90, § Comments table re-measured; suite 90/90 green
- step 6 — reverted fix: 12/90 failed (78 passed); fix-dependent = the 12 new must-fail description cases; contract pins = `-v flags`, `>-` block scalar, indented continuation, and the 75 earlier cases
- step 7 — respecced skill-authoring-rules; requirements changed: *The description line must be present and must parse as YAML text* (title and body: what fails now), scenario *Empty description passes* replaced by *Empty description fails*, two scenarios added (*A description that YAML misreads fails*, *Legitimate shapes still pass*). Check 4's requirement already stated the bare-word limit, unchanged
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
