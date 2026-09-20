---
id: TASK-157
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
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

- [ ] Each of the six sites is acted on or dismissed **with a reason recorded**; "left as is" alone does not close this.
- [ ] `:4-5` keeps the prospective rule and loses the incident report. Deleting both is a wrong fix — the rule against re-adding the check list is what stops TASK-151's original defect returning.
- [ ] `:290`'s count stops being restated in prose. Do not simply change 16 → 19: the number is computed at `:232` and will go stale again.
- [ ] `:212-214` keeps the trees-each-call-passes mechanic and reduces only the ADR-backed why to a pointer.
- [ ] Every deletion names the destination that holds the content, verified — not asserted.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- `:159-162` and `:199-205` — **TASK-154** owns those two, and runner B found them again independently.
- `:222`'s wrong run-order premise — **TASK-081**, whose criterion is being amended separately; it is an accuracy defect, not a comment-placement one.
- The comment rule's wording — FEATURE-002 D1/D2, settled.

## Human test plan

- [ ] Two cold runners on a fixture carrying **the whole `AGENTS.md` minus the measurement table only** — the clean isolation TASK-141's run did not achieve (its rule-only fixture dropped § Testing and § Architecture too, removing destinations rather than just the verdict). Expected: the six sites are gone, and the four TASK-151 named as survivors are still untouched.
- [ ] Expected failure to watch for: a reader now passes the file because the measurement table says two blocks are TASK-154's and stops looking. The table is a record of a verdict, not a substitute for the search.

## Implementation plan

_Populated by `/tasks plan TASK-157` — leave empty until then._
