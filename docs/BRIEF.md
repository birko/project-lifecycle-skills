# Project brief — ground truth

> **Do not rewrite.** This file stores the user's requests **verbatim** — typos and all.
> `README.md`, `AGENTS.md` and every `docs/features/*/idea.md` are *distillations* of what is
> recorded here; when a distillation disagrees with this file, **this file wins** (or the
> divergence is recorded as an explicit decision).
>
> The opening entry is **immutable**. Later requirement-changing requests are **appended
> verbatim** under *Amendments*, dated, naming the feature or story they became.

## Origin

**Adopted 2026-08-18 — no original brief exists.**

This repository was created on 2026-07-15 and reached 36 commits before the lifecycle layer was
applied to itself. There is no verbatim record of the original ask, and reconstructing one from
the README would be a paraphrase presented as ground truth — precisely what this file exists to
prevent. So the ledger is honest about the gap and starts from adoption.

For what the project *is*, read `README.md` (written 2026-07-15, maintained since). For why it
is shaped that way, read `docs/adr/` once it exists (see EPIC-001 / STORY-003).

**Rule for adopted repos** (established here, to be encoded in `adopt-project` — EPIC-001 /
STORY-002): never reconstruct an origin brief. Stamp the adoption date, state that no original
ask survives, and begin the append-only log from the first request made after adoption.

## Amendments

### 2026-08-18 — became EPIC-001 (adopt the yolobox skill ideas)

> look at these skills here what we have in our yolobox https://github.com/krivulcik/yolobox/tree/master/home/yolo/.pi/agent/skills lets discuss what would be good to implement in our life circle skills

### 2026-08-18 — became EPIC-001 / STORY-002 (`adopt-project`)

> is ok but maybe i would add a new skill maybe or werb  for projects taht already have the old sructure to rescan it and generate missing parts with user grilling and  for project that already have some code and dont use these skills if i wanna to init it

### 2026-09-18 — became FEATURE-001 (task worktrees)

> in our skills we have rule to create branch and merge  after its finnished how about  git worktree support?

> i am afrarid that repo/wt could polute the repository accidentaly so  a specified path  if no path is declared ask for one fisrt or suggest one

### 2026-09-18 — became FEATURE-002 (comment discipline)

> also we need to add un our claude agents tempalte something like this **WRITE FEWER COMMENTS IN CODE.** Comment only what is genuinely non-obvious, in 1-3 lines. Never write a paragraph, a changelog, a QA log, or a rationale essay above a declaration. No 10-line block on a single property, const, enum or field. Put findings in the ticket or a docs/ file, not in the source.
>
> and maybe add a command to review comments in code and fix them

> sometimes a coomet can be longer but only if  it has some necessary ingo and not unceccesry things

> woudl liek to be able to scan the whole repo but also just the files it ctoudhed by wopork in the diff
