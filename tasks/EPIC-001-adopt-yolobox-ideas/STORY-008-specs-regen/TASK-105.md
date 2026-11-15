---
id: TASK-105
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-106]
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-079-2, DRILL-079-4, CR-6]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `change-review` and `work-tracking` describe the same gate in near-identical words

## Context

**Found 2026-09-08 while running TASK-079's outstanding human-test item** — the third cold read of
`docs/specs/.map.yml`'s area list. The reader was given the 14 names and titles and nothing else.

Two titles claim the same object:

| Area | Title |
|---|---|
| `work-tracking` | The developer-facing backlog — epics, stories and tasks, **with a gate before done** |
| `change-review` | **The gate on a change** — your own rules, the task's criteria, correctness, and security |

> *"Those are the same sentence twice. I cannot tell whether the gate is invoked from work-tracking,
> described in it, or a different gate."*

It also second-guessed routing item 16 (*"does my change do what the ticket asked"*) toward
`work-tracking` before settling on `change-review`.

**This is a conclusive negative, and that is why it survives a contaminated drill.** The reader was
**not** cold — see TASK-106 — so it held the product's own vocabulary and still could not
discriminate. `populate-tests` § *The cold drill* names this asymmetry directly: *"A contaminated
drill can still produce a conclusive negative… if the runner still reports having to decide, the fix
failed, whatever it guessed about the answer."* The pass-direction results from the same run are
weak evidence and are not relied on here.

### Why this is new rather than a re-run of TASK-103

TASK-104 merged three diff-review areas into `change-review` on usage evidence, and that merge is
sound — it dissolved the four-way naming problem TASK-103 recorded. It also created this collision:
the merged area's title now names *"the gate on a change"*, while `work-tracking` already claimed
*"a gate before done"*. They are the same gate — `tasks/verbs/close.md` step 5b **is** it, and that
file is in `work-tracking`'s sources while the axes it fires are in `change-review`'s.

### Two further unrecoverable pairs, filed here because the root cause is shared

Both are titles that name a capability without naming its **scope**:

- **`feature-lifecycle` ↔ `glossary-and-adrs`** — both promise to record why something was decided;
  neither states scope (a per-feature ledger vs a repo-wide record). Routing item 18 landed on
  `feature-lifecycle` only because the question happened to contain the word "feature", which the
  reader flagged itself.
- **`defect-draining` ↔ `work-tracking`** — *"Working a **filed** review backlog down"*: filed by
  what, into where. No area on the list names an intake step, so the backlog's origin is invisible.

### Merged in 2026-09-26: TASK-113 — Five capabilities a consumer would expect have no area, and one of them is writing the code

_Merged because one specs map / regen.md cleanup pass right before TASK-080. The original file stays, cancelled, at `tasks/EPIC-001-adopt-yolobox-ideas/STORY-008-specs-regen/TASK-113.md`._

**From the first verified-cold read of the area list, 2026-09-08** (`docs/DRILL-079-item1-2026-09-08.txt`).
Asked what a product like this should have that the 14 titles do not cover, the reader named five. This is
a **map-coverage** question, not a naming one — TASK-105 owns the naming residue.

#### The one it flagged hardest

> *"**Actually making the change.** Nothing in 14 titles says 'implement the task' or 'write the code'.
> Tests get written, changes get reviewed, work gets tracked — but the step between 'story' and 'change
> under review' is absent."*

Read the list as a stranger does and the shape is plain: plan it, decide it, pressure-test it, write tests,
review the change, fix filed bugs, document it, see it all — and no area for the work itself.

#### Why this is a real question and not obviously a defect

**The map is honest as it stands.** These areas map the skills this repo ships, and there is no
`implement-the-thing` skill, because that is the agent coding. Inventing an area for a skill that does not
exist would be worse than the gap.

**But `.map.yml`'s own header says otherwise**, and that is the tension to settle:

> *"These are grouped by the capability a consumer installs them FOR."*

A consumer's honest answer to *"what do I install this for?"* is close to *"to get code written properly"* —
and no area claims it. So either the header overstates what the map is (a catalogue of shipped skills), or
the map is a consumer-capability map with a hole in the middle. **The reader itself flagged this as the most
likely deliberate framing choice on its list**, which is why this task decides rather than assumes.

#### The other four, lower stakes and the same shape

| Gap | Note |
|---|---|
| Debugging a bug reported from **outside** a review | `defect-draining` starts from *"a filed review backlog"*; nothing covers reproducing or root-causing a field report. [[tasks]] § field feedback has rules for this — no area names them |
| Release and versioning | a changelog exists, but nothing cuts a release — odd beside a title reading *"an idea to shipped"* |
| Behaviour-preserving work | refactors, migrations, dependency upgrades — *"a large share of real backlogs"*. `tdd`'s refactor step and `improve-architecture` (STORY-007) are both in `skills/` |
| Human-facing documentation | specs come from code and terms get defined; no README / API reference / user guide |

### Merged in 2026-09-26: TASK-111 — regen.md quotes a status-comment format the task template no longer emits

_Merged because one specs map / regen.md cleanup pass right before TASK-080. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-111.md`._

**From a [[code-review]] pass on 2026-09-08.**

`skills/specs/verbs/regen.md:54` quotes the task template's enum comment verbatim —
`# status: todo | in-progress | review (…) | blocked | done | cancelled` — and says it is *"what the
task template emits on every file"*. TASK-073 changed the template (and STORY/EPIC/idea) to
`# status — one of: todo, in-progress, …`, so **that claim is now false**: the quoted string survives in
only two historical task files.

**The hazard it describes is still real** — a regen reading the commented enum instead of the live
`status:` field is exactly what TASK-036 fixed — but an agent grepping for the quoted line finds
nothing and may conclude the hazard is gone. A stale quote is worse than a paraphrase here: it looks
checkable.

This is the writing-side/reading-side contract AGENTS.md already names: the template changed and the
skill that reads its shape was not updated in the same change.

## Decision (2026-11-15, the user)

Accepted after one round of improvement on the first proposal (the user asked what could be better):
- **What the map is:** a map of what the shipped skills do, grouped by the job a consumer uses them for. A job no
  shipped skill does has no area and is listed, with why, in a new optional `not-covered:` key.
- **The gate lives in one area.** `skills/tasks/verbs/close.md`, whose step 5b *is* the gate, joins
  `change-review`'s sources (and stays in `work-tracking`'s: the file implements both). Only `change-review`'s
  title claims the gate.
- **Writing the code is mislabelled, not missing:** `tdd` is that skill, so `test-authoring`'s title says so.
- **The gaps are shown where readers pick an area:** `/specs show` with no area prints the areas, then the
  `not-covered:` lines.
- **Not done:** a title-overlap check in `/specs init` for merges and renames. Declined as a rule for a case seen once.

## Acceptance criteria

- [x] A reader holding only the titles can tell which area to open to **run** the gate and which — `work-tracking` now ends *from picking one up to closing it*; only `change-review` names the checks before a task closes
      describes the backlog the gate sits in — the two no longer both claim "a gate" unqualified
- [x] `feature-lifecycle` and `glossary-and-adrs` state their scope, so a decision-recording need — *each feature's decisions … in its own ledger* against *a repo-wide hard choice*
      routes to exactly one of them
- [x] Where a filed defect backlog comes from is recoverable from the list — a title says it, or the — `defect-draining`: *filed from any review pass or found in use*
      intake step gets an area
- [x] Verified by a **routing test, not the author's own reading**: items 1, 16 and 18 from the — d105 `route2`; the original items' wording was not kept, so twelve invented needs carried their intent (see the test plan)
      TASK-079 brief, plus a new "where do my defects come from" item, each route to one area with
      no `UNSURE` and no pair reported "not recoverable"
- [x] `coverage: verified` still holds — no `sources:` glob moved, or the 63/63 recount is redone — no glob moved: `close.md` was added to `change-review` and stays under `skills/tasks/**`, so the mapped set is the same 63 files
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-113:*

- [x] The header question is settled in writing: is `.map.yml` a catalogue of **shipped skills** or a map of — a map of what the shipped skills do; the header says it
      **consumer capabilities**? The answer goes in the file, because the two produce different maps
- [x] Each of the five gaps is resolved to one of: a new area · folded into an existing area · **recorded as — writing the code → `test-authoring`; field-found defects → `defect-draining`; releases → `changelog-maintenance`; refactoring → `code-shape-review` and `tdd`; migrations and dependency upgrades, and user-facing docs → `not-covered:` with reasons
      deliberately absent, with the reason** — never left unaddressed
- [x] If the answer is "catalogue of skills", the header line that says *"the capability a consumer installs — corrected, with the misreading it caused named
      them FOR"* is corrected, since it is what made these look like holes
- [x] Any area added or renamed keeps `coverage: verified` true — recount, do not assert — none added or renamed (titles only); the set is unchanged, so nothing to recount
- [x] The four gaps that correspond to skills already in `skills/` (`tdd`'s refactor step, — all three were mapped under other names (above), so they were naming findings and are fixed here
      `improve-architecture`, field-feedback handling) are checked against the map before being called gaps:
      a capability that *is* mapped under another name is a naming finding, and belongs to TASK-105
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-111:*

- [x] `regen.md:54` describes the comment format the templates emit **today**, or stops quoting a — TASK-200 (Progress log 2026-10-01): it describes the comment by shape
      literal string and describes the hazard by shape instead
- [x] The guidance still prevents reading the commented enum rather than the live field — the fix must — TASK-200's wording keeps it: the comment is matched as a comment, never as the live field
      not lose what TASK-036 established
- [x] Any other skill quoting the old literal is found and fixed in the same change, or its absence is — checked 2026-11-15: `grep -rn 'status: todo | in-progress' skills` finds nothing
      stated as checked
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **The `glossary-and-adrs` name itself.** The same reader called it *"a filing label, not a want…
  the `and` is the confession"* — but one skill owns both halves, so the map has no split available.
  That is `domain`'s scope, already recorded in the map's own comment and in TASK-103.
- **`installation` and `skill-authoring-rules`.** The reader's judgement on these two is discounted:
  they describe the product-as-product, which is precisely what a contaminated runner already knows.
  (It returned `yes` on `installation`, contradicting an earlier reader — unusable either way.)
- **Making a genuinely cold reader available — TASK-106.** This task's own human test cannot run
  until that lands, which is why `depends-on` names it.
- **Generating spec bodies — TASK-080.**

*From TASK-113:*

- **The names themselves** — TASK-105. This task asks what is *absent*, not what is *badly labelled*.
- **Generating spec bodies** — TASK-080, which STORY-008 holds behind STORY-007.
- Building any skill to fill a gap. If a gap turns out to want a real skill, that is a feature-shaped
  decision and goes through `/feature new`, not a quiet task here.

*From TASK-111:*

- Changing the template's comment format again — TASK-073 settled it.
- Whether the enum comment should exist at all — also TASK-073.

## Human test plan

- [x] Re-run the routing test with a runner acquired by TASK-106's documented method, briefed with
  - **Passed 2026-11-15**, `%LOCALAPPDATA%/Temp/d105/route2`: `claude -p --disable-slash-commands --allowedTools Read`,
    the cwd holding only `brief.txt` and `areas.txt` generated from `.map.yml` in `show`'s format; the coldness probe
    listed no skills. Twelve invented needs (run the checks before done; does it do what the ticket asked; a
    project-wide and a per-feature decision; where defects come from; a field crash; open tasks; implement an
    endpoint; dependency upgrades; a release; a term; an API reference): each to one area or `not covered`, no
    `UNSURE`, *not recoverable: none*. The first run (`d105/route`) left *implement* UNSURE between
    `test-authoring` and `work-tracking` and the defects' source review unclear; both titles were tightened.
      the area list alone. Expected: items 1 and 16 both to `change-review`, item 18 to exactly one
      area, the defects-origin item to exactly one area, and no `UNSURE` or "not recoverable" on any
      pair involving the four areas above.

*From TASK-113:*

- [x] Give a cold runner the revised area list — acquired by [[populate-tests]] § *Acquiring a cold runner*,
  - **Passed 2026-11-15**, `%LOCALAPPDATA%/Temp/d105/missing`, same channel: *"Writing the code itself —
    test-authoring covers it"*, and both `not covered` lines read as explaining their absence. Its other
    expectations (deploys, PRs and merging, prioritisation, team coordination, external trackers, incident
    response, specs before code, multi-repo) and confusions are one-runner readings, recorded here, not filed.
      titles generated from `.map.yml` rather than retyped — and ask only what appears missing. Expected: the
      implementation gap is either covered or its absence is legible from the list without asking anyone.

*From TASK-111:*

- [x] N/A — fully covered by a grep: the quoted literal must not appear in `skills/` except where it **Passed 2026-11-15:** the grep finds nothing.
      genuinely matches what a template emits. A human adds nothing to a string comparison.

## Implementation plan

Inline, from the decision above.

## Outcome

- **`docs/specs/.map.yml`:** the header says what the map is; seven titles rewritten; `close.md` added to
  `change-review` with the reason; `not-covered:` lists migrations and dependency upgrades, and user-facing
  documentation, each with why; the stale "14 areas" count corrected to 15.
- **The specs skill:** `SKILL.md` defines `not-covered:` (optional, hand-written, a job without ` — `); `show` with no
  area prints the areas then the `not-covered:` lines, and says the first ` — ` ends a name or job; `init` carries the
  key over untouched; the template ships it commented out; the help menu shows `show [<area>]`.
- **Drills:** `d105/show` printed the list exactly, and raised the separator clash this change created (titles and one
  job held ` — `), fixed in the same change. Routing and missing-capability as in the test plan.

**Close gate (inline; the specs skill, the map, eight specs):**
- **Standards:** the key defined once in `SKILL.md`; `show` and `init` point at it; the template ships nothing a
  render cannot make true.
- **Intent:** all criteria met; the declined init check is recorded in the Decision.
- **Correctness:** d105 (show, route, route2, missing).
- **Layer parity, security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** title headings follow the map in seven specs; `change-review` gains `close.md` and the gate-at-close
  requirement; `specs-from-code` gains the no-area listing and the `not-covered:` requirement.

## Progress log

- 2026-10-01 — Note from TASK-200: `regen.md` no longer quotes the template's status comment verbatim. It now describes it as a comment listing every legal value, matched by being a comment and not by its wording, because template versions differ. The merged-in TASK-111 criterion (a quoted format the template no longer emits) is met by that change; check it off when this task closes.
- step 2 — picked; a decision task, in the user's order (TASK-024, TASK-074, then this)
- step 4 — decided by the user 2026-11-15, the revised proposal
- step 5 — the map, the specs skill (key, show, init, template, help)
- step 6 — behavioural: d105 show (separator clash fixed after it), route (two titles tightened after it), route2, missing
- step 7 — respecced change-review, specs-from-code; six title headings
- step 8 — closed inline; commit in git log
