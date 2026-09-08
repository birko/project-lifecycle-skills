---
id: TASK-113
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-08
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-079-4]
pr: null
github-issue: null
jira-key: null
---

# Five capabilities a consumer would expect have no area, and one of them is writing the code

## Context

**From the first verified-cold read of the area list, 2026-09-08** (`docs/DRILL-079-item1-2026-09-08.txt`).
Asked what a product like this should have that the 14 titles do not cover, the reader named five. This is
a **map-coverage** question, not a naming one — TASK-105 owns the naming residue.

### The one it flagged hardest

> *"**Actually making the change.** Nothing in 14 titles says 'implement the task' or 'write the code'.
> Tests get written, changes get reviewed, work gets tracked — but the step between 'story' and 'change
> under review' is absent."*

Read the list as a stranger does and the shape is plain: plan it, decide it, pressure-test it, write tests,
review the change, fix filed bugs, document it, see it all — and no area for the work itself.

### Why this is a real question and not obviously a defect

**The map is honest as it stands.** These areas map the skills this repo ships, and there is no
`implement-the-thing` skill, because that is the agent coding. Inventing an area for a skill that does not
exist would be worse than the gap.

**But `.map.yml`'s own header says otherwise**, and that is the tension to settle:

> *"These are grouped by the capability a consumer installs them FOR."*

A consumer's honest answer to *"what do I install this for?"* is close to *"to get code written properly"* —
and no area claims it. So either the header overstates what the map is (a catalogue of shipped skills), or
the map is a consumer-capability map with a hole in the middle. **The reader itself flagged this as the most
likely deliberate framing choice on its list**, which is why this task decides rather than assumes.

### The other four, lower stakes and the same shape

| Gap | Note |
|---|---|
| Debugging a bug reported from **outside** a review | `defect-draining` starts from *"a filed review backlog"*; nothing covers reproducing or root-causing a field report. [[tasks]] § field feedback has rules for this — no area names them |
| Release and versioning | a changelog exists, but nothing cuts a release — odd beside a title reading *"an idea to shipped"* |
| Behaviour-preserving work | refactors, migrations, dependency upgrades — *"a large share of real backlogs"*. `tdd`'s refactor step and `improve-architecture` (STORY-007) are both in `skills/` |
| Human-facing documentation | specs come from code and terms get defined; no README / API reference / user guide |

## Acceptance criteria

- [ ] The header question is settled in writing: is `.map.yml` a catalogue of **shipped skills** or a map of
      **consumer capabilities**? The answer goes in the file, because the two produce different maps
- [ ] Each of the five gaps is resolved to one of: a new area · folded into an existing area · **recorded as
      deliberately absent, with the reason** — never left unaddressed
- [ ] If the answer is "catalogue of skills", the header line that says *"the capability a consumer installs
      them FOR"* is corrected, since it is what made these look like holes
- [ ] Any area added or renamed keeps `coverage: verified` true — recount, do not assert
- [ ] The four gaps that correspond to skills already in `skills/` (`tdd`'s refactor step,
      `improve-architecture`, field-feedback handling) are checked against the map before being called gaps:
      a capability that *is* mapped under another name is a naming finding, and belongs to TASK-105
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **The names themselves** — TASK-105. This task asks what is *absent*, not what is *badly labelled*.
- **Generating spec bodies** — TASK-080, which STORY-008 holds behind STORY-007.
- Building any skill to fill a gap. If a gap turns out to want a real skill, that is a feature-shaped
  decision and goes through `/feature new`, not a quiet task here.

## Human test plan

- [ ] Give a cold runner the revised area list — acquired by [[populate-tests]] § *Acquiring a cold runner*,
      titles generated from `.map.yml` rather than retyped — and ask only what appears missing. Expected: the
      implementation gap is either covered or its absence is legible from the list without asking anyone.
