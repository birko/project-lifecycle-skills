---
id: TASK-157
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [DRILL-141-1]
pr: null
github-issue: null
jira-key: null
---

# Six more comment findings in `skills-lint.sh`, one of them introduced by the task that was fixing them

## Context

Found by finally running **TASK-141**'s human test plan, a month after that task closed with all three
of its manual checks unticked. Two cold `claude -p` readers applied this project's comment rule to
`.github/workflows/skills-lint.sh` with no slash commands and no edit permission. The plan's recorded
expectation was *"Expected: none."* Between them they found nine things.

**These six are one task because they are one sweep of one file**, and because two of them were found
by **both** readers independently, which splitting would bury.

| Site | Destination | Found by |
|---|---|---|
| `:4-5` | version history | A |
| `:105-106` | the ticket / git — state at introduction | **both** |
| `:108-109` | the rulebook (`AGENTS.md:279`), and `:146-148` where it is already a proper pointer | B |
| `:212-214` | § Architecture / ADR 0010 | B |
| `:259` | provenance about another comment | A |
| `:290-292` + `:296-297` | the drill measurement, twice, six lines apart | **both** |

### `:4-5` was introduced by TASK-151, in the commit whose subject was comment discipline

```
# Each check announces itself below as `== N. name ==`; those banners are the inventory. A copy
# of them here went stale twice as checks were inserted — most recently listing four of six.
```

TASK-151 deleted a stale check enumeration here and replaced it with a sentence recording **that it
had gone stale twice and how**. That is a changelog. It passed three close-gate axes and a
`/review-comments --all` run, and a cold reader with no context caught it in one pass.

**The two readers disagree about this line, in opposite directions** — B kept it as *"a prospective
rule against re-adding the check list, not a changelog"*. A's reading is the correct one: the
*prospective rule* ("do not restate them here") is worth keeping and survives on its own; the
incident report attached to it is what `git log` holds. Fix by keeping the first clause and cutting
the history, not by deleting the pair.

### `:290` is live-wrong, not merely restated

> `# "Nothing is linked" is ONE condition, not N findings. Naming all 16 skills for a root the …`

The lint prints **19 skills**. A restated count that has already gone stale — the exact defect this
repo lints for, sitting inside the lint. The number lives in `$total`, computed at `:232`.

### `:212-214` is the class already handed to TASK-148, in a file nobody checked for it

> `# \`skills/\` is linked into BOTH roots; \`skills-pi/\` into the pi root ONLY — the real built-ins live`
> `# in the Claude root and the stubs would shadow them.`

`AGENTS.md:76` carries it, citing ADR 0010. TASK-148 was filed for exactly this why-clause in the
installers; nobody looked for it here. **The following sentence stays** — that the asymmetry is carried
by *which trees each call passes*, so `skills-pi/` can never be reported missing from the Claude root,
is a mechanic with no other home.

## Acceptance criteria

- [x] Each of the six sites is acted on or dismissed **with a reason recorded**; "left as is" alone does not close this.
- [x] `:4-5` keeps the prospective rule and loses the incident report. Deleting both is a wrong fix — the rule against re-adding the check list is what stops TASK-151's original defect returning.
- [x] `:290`'s count stops being restated in prose. Do not simply change 16 → 19: the number is computed at `:232` and will go stale again.
- [x] `:212-214` keeps the trees-each-call-passes mechanic and reduces only the ADR-backed why to a pointer.
- [x] Every deletion names the destination that holds the content, verified — not asserted.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- `:159-162` and `:199-205` — **TASK-154** owns those two; both verification readers found them again independently, on a fixture with no record of that verdict.
- **Deferred to TASK-158** — five new sites the verification run surfaced: `:22` (`RUNTIME_REFS` has no comment and should), `:166`, `:10`, `:149`, `:295-296`.
- `:222`'s wrong run-order premise — **TASK-081**, whose criterion is being amended separately; it is an accuracy defect, not a comment-placement one.
- The comment rule's wording — FEATURE-002 D1/D2, settled.

## Human test plan

- [x] Two cold runners on a fixture carrying **the whole `AGENTS.md` minus the measurement table only** — the clean isolation TASK-141's run did not achieve (its rule-only fixture dropped § Testing and § Architecture too, removing destinations rather than just the verdict). Expected: the six sites are gone, and the four TASK-151 named as survivors are still untouched.
- [x] Expected failure to watch for: a reader now passes the file because the measurement table says two blocks are TASK-154's and stops looking. The table is a record of a verdict, not a substitute for the search.

## Implementation plan

_Populated by `/tasks plan TASK-157` — leave empty until then._

## Progress log

- 2026-09-20 — Picked. **Destinations verified before any cut, per criterion 5 — and two of the six were filed at the wrong address in this task's own context table.**

| Site | Destination this task claimed | Where the content actually is |
|---|---|---|
| `:4-5` | version history | ✅ commit `9543bfb`'s body carries *"four of six"* verbatim |
| `:105-106` | *"the ticket / git"*, elsewhere implied as TASK-108 | **TASK-045:92** — *"Result of running it: 30 checked, 0 mismatches. The trap was armed but unsprung"* — the ticket that added check 4, not TASK-108 |
| `:108-109` | `AGENTS.md:279` and `:146-148` | ✅ both |
| `:212-214` | § Architecture / ADR 0010 | ✅ `AGENTS.md:76`, citing ADR 0010 |
| `:259` | provenance about another comment | ✅ the comment it refers to is three lines above, in view |
| `:290-292`, `:296-297` | *"the drill"*, TASK-037 cited in the code | **TASK-016:177** carries the measurement (*"A 30-line wall for an existing-but-empty root"*); TASK-050:143 carries the collapse reasoning. TASK-037 is the *situation* the collapse is reachable in, not the record of the measurement |

  **Had I trusted the filing instead of searching, two deletions would have cited a record that does not
  hold the content** — which is the assertion-not-verification failure criterion 5 exists to prevent, and
  it would have been invisible afterwards.

- 2026-09-20 — Six cuts made, each keeping the half that lives nowhere else:
  - `:4-5` — the **prospective rule** survives (*"do not restate them here, because a copy goes stale the next time a check is inserted"*); the incident report about having gone stale twice is gone. Deleting both would have removed the guard against TASK-151's original defect returning.
  - `:105-106` — the design note (**preventive, not remedial**) survives with a `TASK-045` pointer; the state-at-introduction count is gone.
  - `:108-109` — the duplicated *"existence only, never semantics"* sentence is gone; the **read-WHOLE-not-`## Args`** mechanic and its two-declaration-styles reason survive, as does the proper pointer at `:146-148` that adds the prose-mention case.
  - `:212-214` — reduced to `(ADR 0010)`; the **which-trees-each-call-passes** mechanic survives intact, because it is the thing that makes `skills-pi/` un-reportable as missing from the Claude root.
  - `:259` — *"which is what the comment above has always claimed"* → *"which is what this case needs"*. The claim was about the comment above, which is three lines up and in view.
  - `:290`/`:296` — `all 16 skills` → `every skill` (the value is `$total`, computed at `:232`), and both copies of the drill measurement replaced by one `TASK-016` pointer.
- 2026-09-20 — Verified **comment-only**: filtering every non-comment `+`/`-` line from the diff leaves nothing. The four survivors TASK-151 named are all still present.
- 2026-09-20 — `AGENTS.md`'s measurement table **re-run, not re-quoted**, as its own rule demands: 323/128/31 → **321/126/30**, shebang-excluded 127 → 125, and the two cited survivor ranges repointed (`:124-133` → `:123-132`, `:256-259` → `:254-257`) since the cuts moved them. The verdict row now records that six sites were cut here and that TASK-154's two remain.

### Verification run — 2026-09-20, two cold readers, **clean isolation this time**

**Fixture** `t157-i` / `t157-j`: the whole `AGENTS.md` **minus lines 402-446 only** — the measurement
table and its surrounding prose, nothing else. § Testing, § Architecture, the ADR references and the
comment rule all survive; mentions of `skills-lint.sh` drop 12 → 7, and those 5 are exactly the verdict
being withheld. This is the isolation TASK-141's run did not achieve and recorded itself as lacking.

Same brief, `--disable-slash-commands`, `--permission-mode plan`, captured whole.

| Human test plan expectation | Result |
|---|---|
| the six cut sites are gone | ✅ **neither reader reported any of them.** Reader I explicitly clears `:4-5`: *"borderline; each carries a maintenance invariant or an orienting pointer rather than a copy, so they pass"* |
| the four TASK-151 survivors untouched | ✅ Reader I names them unprompted as deliberately not flagged — the `ARG_RE` block *"protected at any length"*, plus `:254-257` and three more, each *"with its ticket cited as a pointer rather than reproduced"* |
| **named failure mode: a reader passes the file because the table says two blocks are TASK-154's** | ✅ **did not occur, and the reverse is now proven.** With the table removed, **both** readers found TASK-154's two sites from the rule alone — `:198-202` and `:158-161`. Those findings are reachable from the rule, not merely inherited from the record |

**The expectation was stated in the task before the run, so this is not a verdict fitted to its result.**

#### Reader J caught a contradiction this task introduced

The `:4-5` fix writes *"do not restate them here, because a copy goes stale the next time a check is
inserted"* — and **line 7 then hard-coded "Checks 2 and 3"**, two lines below the rule forbidding it,
and is exactly what would go stale if a check were inserted before them. Fixed in the same task, since
it is a defect in this task's own change: the note now names the checks (*"the wikilink and
file-reference checks"*), which is stable under renumbering, and says why.

**Worth recording rather than just fixing.** Writing a rule against restating a list, directly above a
restated list, is not a slip a careful re-read catches — I read that header four times. It took a
reader with no investment in the change.

#### New sites neither this task nor TASK-154 owns

| Site | Finding | Found by |
|---|---|---|
| `:22` `RUNTIME_REFS` | **the opposite failure** — why three names resolve with no skill folder lives *nowhere*, and the rule's `nowhere` row says write it. No comment at all | **both** |
| `:166` | `# $1 = file` restates the signature; `[ -f "$1" ]` on the next line says it | I |
| `:10` | `# Run locally: bash …` — recoverable from the shebang and the path, and in `AGENTS.md` § Commands | I |
| `:149` | first clause restates `:117-121`, which explicitly claims ownership of that mechanic | I |
| `:295-296` | closing sentence restates the branch below it | J |

`RUNTIME_REFS` is the notable one: **both readers independently found the same absent comment**, and
reader I declined to draft it — *"guessing it into the file would be worse than the gap"* — because the
fixture could not show what links to those three names. That is the only-copy discipline applied to a
comment that does not exist yet.
