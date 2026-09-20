---
name: review-comments
description: Find comments whose content already lives somewhere else, and report each with the destination that caught it — so the verdict is checkable rather than asserted. Runs over the current diff by default, over named paths in full when you give it any, and over the whole repository with `--all`. Use when the user says "/review-comments", "review comments", "check the comments", "are these comments necessary", "clean up the comments", "comment discipline", "find stale comments", "this comment is out of date", "skontroluj komentáre", "prekontroluj komentare", "vyčisti komentáre", "sú tie komentáre potrebné", "zbytočné komentáre", "komentár už neplatí", or before marking a task done. Tech-agnostic — it reads the comment rule **this project** recorded in its own agent guide and never carries a copy, so a project that tightens the rule tightens this check. Never reports a comment for being long; length is a reason to look, never a finding. Never destroys the only record of something. Distinct from [[verify-conventions]], which lints a diff against the whole rulebook and by construction cannot see code nobody is changing, and from [[code-review]], which judges correctness.
---

One axis, one question: **does any comment here carry content that already lives somewhere else?**

Not whether the code is right ([[code-review]]), not whether it follows the rest of the rulebook
([[verify-conventions]]) — only whether a comment is a record kept in the wrong place.

> **The rule is not in this file, and it must not be copied into it.** The destination test lives in the
> project's own guide, under § Conventions › Comments, between the `comment-rule` markers in a scaffolded
> repo. Read it there on every invocation and read the **destination names off its table**, never off a
> list here: the destinations are a list that can grow, and a copy here would go wrong silently. If the
> guide's table carries more rows than you expect, the table wins and the report says so.

**One invariant is restated here, because it is load-bearing and it is not a list: never report a comment
for being long.** A long block where every line carries something the code cannot is correct. Length is a
reason to look, never a finding by itself. A reader who must fetch the rule before learning that will
re-derive a cap, which is the one failure this whole check was built to avoid.

## Invocation

```
/review-comments                 the current diff (default)
/review-comments PATH …          those paths in full, ignoring the diff
/review-comments --all           the whole repository
/review-comments --all --batch N print batch N of the same ordering
```

- `PATH …` — sweep the named files **in full**, whatever the diff says. Step 2 owns the scope.
- `--all` — widen from the diff to every tracked file.
- `--batch` — which page of an `--all` run to print. Defaults to 1.
- **`--batch` without `--all` is refused by name**: neither a diff-scoped nor a path-scoped run is paged,
  so honouring the flag would be pretending. Say *"`--batch` applies to `--all` only; any other scope
  prints in full"* rather than ignoring it — a flag silently dropped by one path is worse than one that
  never existed, because the caller reads the promise and not the scope.

- **`PATH` with `--all` is refused by name**, for the reason `--batch` is: they are two scopes and
  honouring both is impossible, so one would be silently dropped and the caller would not know which.
  Say *"`--all` is the whole repository; drop the paths, or drop `--all`"* and do neither.

## Step 1 — Find the rule, and say which rung found it

Work down this ladder, stop at the first hit, and **name the rung on the report header**.

| Rung | Look for |
|---|---|
| 0 | `<!-- comment-rule:start -->` … `<!-- comment-rule:end -->` in the project's guide (`CLAUDE.md`, or `AGENTS.md` through the `@import` bridge). Machine-exact, language-independent |
| 1 | A heading that names comments, anywhere — `### Comments`, `## Commenting`, `### Komentáre`. Match on meaning in the guide's own language; a project does not owe you English headings |
| 2 | Normative content about comments under any heading — sustained *must / never / always* and their equivalents |
| 3 | Nothing. Use the universal floor below |

**Rung 2 is reachable, not decorative.** A project scaffolded before the rule was spliced verbatim carries
it **reworded and unmarked** — measured, and the reason the marker exists at all. Do not conclude "no rule"
because rung 0 missed.

### Rung 3 — the universal floor

Read the rule at runtime from [`../new-project/templates/CONVENTIONS-universal.md`](../new-project/templates/CONVENTIONS-universal.md),
relative to this skill's own folder. Both installers place every skill folder in one root, so `new-project`
is a sibling there; the same cross-skill pointer [[verify-conventions]] uses for its smell inventory.

Three rules ride with the floor, and dropping any one turns this check into something that argues with its
own project:

- **The project always overrides, and suppresses a conflicting universal finding outright** — not "reports
  both". A shop whose guide requires a changelog header, or a doc comment on every public member, has
  *decided*.
- **Every floor finding is prefixed `universal:` and capped at ⚠, never 🛑.** The project never agreed to
  these words. A reader must be able to tell a heuristic from a rule the project wrote down without
  inferring it from tone.
- **Recommend the durable fix once, at the end**: *"This project has recorded no comment rule — add the
  § Comments block from [[new-project]]'s universal conventions template to `CLAUDE.md` § Conventions, so
  there is something to check against."*

**If the rule cannot be read at all — no guide, and the template unreachable — stop and report.** Do not
compose a substitute from memory. Prose describing the rules is exactly what lets an agent write a
plausible report holding none of them. The live cause is install drift: `new-project` has no junction in
this root, and the remedy is re-running an installer.

## Step 2 — Pick the scope

**Default: the current diff.** Prefer staged (`git diff --cached`); fall back to the working tree
(`git diff`); use a branch or PR range only if the user names one; not git-tracked → ask which files to
check. Same precedence as [[verify-conventions]] and [[verify-intent]], deliberately — a reviewer should
not have to learn a third convention.

A diff gives you changed *lines*; this check needs whole *blocks*. Two rules follow:

- **A comment is in scope when the diff adds or modifies any line of it** — then judge the **whole block**
  and the declaration it sits above. You cannot apply a destination test to half a comment.
- **A comment *immediately attached* to a changed line is in scope even when the comment itself is
  untouched** — contiguously above it, or trailing on it. *The comment the change just made false* is the
  most valuable finding a diff-scoped run can produce, and it is why the default is worth running at all.
  **Bounded on purpose:** immediately attached, not "same function", not "same file". A stale block ten
  lines away is what `--all` exists for.

**`PATH …`** sweeps the named paths **in full, and does not consult the diff at all.** This is the scope
for *"check the comments in the file I am about to work in"* — the question neither other scope answers,
since the diff sees only what changed and `--all` drowns one file in a census. Four rules, and each one
is a question a reader would otherwise have to improvise:

- **Membership is `git ls-files`, exactly as `--all` does it and for the identical reason.** A path
  naming an untracked file is **reported, not swept** — `not tracked, not swept: <path>`. Saying which is
  the whole difference between a scope and a silent no-op.
- **A directory expands to the tracked files under it**, and the expansion is what decides the two rules
  below. `PATH …` takes more than one argument, so the plural and the directory both need an answer
  rather than an assumption.
- **"Named explicitly" means a file path, never a directory that happens to contain it.** The
  generated/vendored exclusion below applies, with one exception: a file the caller **named by its own
  path** is swept even when it looks generated, and the header says so — naming a file is the strongest
  available signal they meant it. A file reached by **expanding a directory** was not named, so the
  exclusion applies to it normally, and the header lists what it dropped. Both halves are stated because
  `/review-comments src/` over a `src/` holding `schema.gen.ts` satisfies "explicit" under one reading
  and not the other, and one sentence admitting both readings is the defect this scope was written to
  remove.
- **An untracked file under an expanded directory is skipped silently; an untracked path named
  directly is reported.** Expansion reads tracked files only, so there is nothing to report — whereas a
  caller who typed the path is owed an answer. The asymmetry is the same one: what the caller named.
- **The only-copy question is asked here.** It is not inferable from either neighbouring rule — see
  § *The only copy*, which owns it.

**`--all`** widens to every tracked file. Enumerate with `git ls-files`, never a filesystem walk: an
untracked scratch file on one machine must not produce a finding nobody else can reproduce.

**Exclude generated, vendored and minified files** using [[verify-conventions]]' ladder
([`../verify-conventions/SKILL.md`](../verify-conventions/SKILL.md) § *What to lint*, step 2b) —
`.gitattributes` declarations first, then the project's own guide, then heuristics. Read it there; do not
copy its table. Carry over its two reporting rules: **name what was excluded on the header**, and say when
an exclusion rested on a heuristic rather than a declaration.

## Step 3 — Identify comments without a language table

**Do not ship one.** A language→syntax table is wrong the day the repo gains a file type, and wrong
silently — the sweep simply misses that file.

**A comment is a span the language's compiler or interpreter discards.** Identify it by reading the file in
its own language; you already know the syntax of any file you can read. Whether a documentation comment is
in scope is answered by the rule you read in step 1, not here.

**The evidence rule, which is what makes a misidentification cheap:** every finding quotes the comment text
and gives `path:line`. A span wrongly called a comment is then obvious to a reader in one second.

**The false-positive floor — three places language-blind matching breaks:**

- A `#`, `//` or `--` sequence inside a **string literal, heredoc, template literal, regex or URL** is not
  a comment.
- A **shebang, encoding line, pragma, linter directive or editor modeline** is machinery, not commentary,
  and is out of scope.
- **Markup and config files** are commentary by nature and are not swept.

**When you cannot tell whether a span is a comment, do not report it.** The directions are not symmetric: a
missed comment costs a messy file, a wrongly-reported one teaches the reader to dismiss the report.

## Step 4 — Apply the test, and report what survived

For each comment in scope, apply the destination test from the rule you found. Every finding carries the
**destination row that caught it**, quoted from the project's own table — that is what makes the verdict
checkable rather than asserted.

| Severity | When |
|---|---|
| 🛑 | an instance the project's own rule text names as **always** a violation |
| ⚠ | the content appears to live at one of the table's destinations; a human should confirm |
| 💡 | the comment passes, but its row suggests leaving a pointer rather than the body |
| `universal:` (⚠ cap) | the project recorded no rule and the floor supplied it |
| **held** | the content exists **nowhere else**. Never deleted first — see § *The only copy* |

**Never a finding:** a comment's length; a **pointer** — one line naming where the rest lives, which is
what makes a destination reachable; a structurally required documentation tag that adds nothing, which the
rule says to **fill** rather than delete.

**Print what survived.** A report that lists only violations cannot be told apart from one that flags
everything, so name the comments the check deliberately left and why. This is the same reasoning behind
[[verify-conventions]] printing its exclusions on a clean pass.

```
Comment rule: CLAUDE.md § Conventions › Comments — ladder rung 0, found by marker. Destinations: 5 rows.
Scope:        working tree (nothing staged) — 6 changed files, 4 carrying comments in range.
              2 excluded as generated (app.js.map — minified shape; sw.js — declared linguist-generated).

🛑 src/pricing/Tariff.cs:12 — changelog
   "// 2025-03-04 added VAT handling; 2025-05-11 renamed to Tariff"
   Destination: version history (row 2). Named by the rule as always a violation.
   Fix: delete — `git log` carries both lines already.

⚠ src/pricing/Tariff.cs:41 — restates the line below
   "// set the rate"   above   `rate = input.Rate;`
   Destination: the code itself (row 1).
   Fix: delete. If it was compensating for a name, fix the name instead.

Left alone, so you can see the check discriminates:
   tests/TariffTests.cs:7 — a pointer to FIELD-003 and the mechanism it pins. A pointer is not a copy.
   src/pricing/Rounding.cs:60 — 31 lines on a banker's-rounding edge case. Length is not a finding.
```

Clean pass keeps the header — the verdict alone hides what produced it:

```
Comment rule: CLAUDE.md § Conventions › Comments — ladder rung 0. Destinations: 5 rows.
Scope:        staged — 3 files, 1 carrying comments in range.
✅ No comment carries content that lives somewhere else.
```

**The `Scope:` line names which of the three scopes ran, and a path run must not render like an empty
diff run.** Those two are the pair a reader cannot otherwise tell apart — both print a small number and a
clean verdict — and the whole-file sweep is exactly the case someone runs *because* the tree is clean.

**A path run's line carries `N of M tracked` always, even when N equals M.** It is not optional and not
dropped when nothing was skipped: the fragment is what tells a reader the membership test ran at all,
and a line without it cannot be told from one where the question never came up. Measured — two runners
on one tree emitted the line with and without it, which is the divergence this whole scope exists to
prevent. Anything actually skipped is then named after it.

```
Scope:        paths (diff not consulted) — src/mill.ts, src/rate.ts swept in full; 2 of 2 tracked.
Scope:        paths (diff not consulted) — src/mill.ts swept in full; 1 of 2 tracked.
              not tracked, not swept: notes.txt.
```

## `--all` — census first, then pages

1. **A census before any finding**: total findings, files affected, and the split between always-violations
   and judgement calls. The total is printed *before* the first finding, never after the last.
2. **A batch is a set of whole files, capped at 20 findings.** A file is never split across batches; a
   single file over the cap is its own batch and the census says so.
3. **Batches are ordered by finding density descending, path ascending as the tie-break, and the report
   names the key that ordered them.** Two runs over one tree must page identically. When every file has one
   finding, density discriminates nothing — say that the ordering fell to path rather than leaving a reader
   to wonder.
4. **It asks nothing.** End with the resume command — `` `/review-comments --all --batch 2` `` — so the run
   survives a cleared session and carries no state.
5. **Twenty is a page size and nothing in the check consults it.** It is how much of a report a person
   reads before skimming. No number in this file is a finding.

Alternatives rejected: grouping by destination puts a reviewer in forty files at once and hides the
actionable signal (*this one file has forty*); grouping by severity spreads one file across three pages so
it gets read three times.

## After the report

**Confirm before editing anything.** Findings are advisory until a human agrees to them.

### The only copy

**Before a finding leads to a deletion, check that its content is actually at the destination the test
named.** The destination is not a guess you have to make — step 4 already named it, so the search is
scoped by it rather than sprayed across the repo:

| Destination the finding named | What to check |
|---|---|
| the code itself | nothing to check. The code is on the next line; a row-1 finding is never an only copy |
| version history | is it in `git log` / `git blame` for that file? **A comment on an uncommitted line has no history yet** — the destination is empty and this is an only copy |
| the ticket | does an open task in the tracker carry it? Search by the behaviour described, not by wording |
| a decision record | does a record under `docs/adr/`, or a feature's decision ledger, carry the reasoning? |

**Found it? Delete the comment, and name in the report where the content already lives** — by task id,
commit, or record path. That citation is what makes the deletion checkable instead of asserted.

**Not found? It is an only copy, and nothing is deleted in the same step as the relocation being
proposed.** The two are separate acts: propose, get an answer, relocate, and only then delete. A run that
collapses them has no point at which a human could have said no.

**Choose the destination by the content's kind**, not by convenience:

- **A finding** — a bug, a defect, work someone should do → a **task**. Chain [[tasks]] `spawn`, which
  places it under the right parent and inherits the feature link.
- **A rationale** — why a choice was made, what was rejected → a **decision record** under `docs/adr/`, or
  the owning feature's decision ledger if one exists.
- **Anything else that is genuinely reference material** → a `docs/` page.
- **Cannot tell?** Do not guess a destination. Report it held, say the kind is unclear, and let the answer
  come from the person who knows.

**Nothing is created without asking.** The question put, verbatim:

> **`<path>:<lines>` — this content exists nowhere else.**
> *"<the comment's first line, quoted>"*
> Its destination is **<the row the test named>**, and nothing there carries it yet.
> **File it as a <task | decision record | docs page> and leave a pointer, or keep the comment as it is?**

**When no answer comes: the comment stays exactly as it is, nothing is created, and the finding is
reported `unresolved` with the question that went unanswered.** Not a silent delete, and — the half that
is easier to get wrong — **not a silent skip either**. A held finding that vanishes from the report is
indistinguishable from one that passed, so an unanswered question gets a line of its own:

```
unresolved (1) — src/pricing.ts:1-10. Only copy; destination "version history" is empty.
                 Asked whether to file it; no answer. Comment untouched, nothing created.
```

**After a relocation, the source carries a one-line pointer** naming where the content went — by id or
path, not by description. *"`// rate history: TASK-214`"* is a pointer; *"`// see the ticket`"* is a
second thing to go looking for. A pointer is what keeps the destination reachable, and it is never itself
a finding.

**On `--all`, only-copy findings are reported and never asked about.** The census run asks nothing at all
(§ `--all`), so relocation belongs to a scoped run where a person is looking at one file. Asking three
hundred times is not a usable flow, and batching the questions would make the answers arrive detached
from the code that prompted them. The `--all` report therefore names each only copy and stops:
`held — only copy, relocation not proposed (run scoped to act on it)`.

**A path-scoped run is that scoped run, and it asks.** Stated here rather than left to be worked out,
because it follows from neither neighbour: `--all` suppresses the question on grounds of volume, the diff
scope asks because a person is present, and a path run shares the *person* with one and the *whole-file
reach* with the other. A reader reaching for the nearest rule can land either way, and the two answers
differ by whether anything gets relocated at all. **`PATH …` is the scope this section was written for**
— "a person looking at one file" is its literal description — so it asks, exactly as the diff scope does.

## Where this runs

- **Standalone, any time** — before a commit (the default diff), or pointed at an area you are about to work in (`PATH …`, which is what that phrase means mechanically).
- **At a review gate, as its own axis** — reported beside standards, fidelity and correctness, with its own
  severity ordering and nothing sorted across them. A comment finding and a correctness blocker are not the
  same quantity, and one ranked list makes them look like it.

## What this skill does NOT do

- **Judge correctness** — [[code-review]].
- **Lint the rest of the rulebook** — [[verify-conventions]], which also cannot see code nobody is changing;
  that gap is this skill's entire reason to exist.
- **Judge comment *style*** — formatting, documentation-comment syntax, language, house voice.
- **Invent a rule the project never agreed to.** Absent a recorded rule it says so, labels every finding,
  and recommends recording one.

## Related skills

- [[verify-conventions]] — the adherence axis; this skill borrows its rulebook ladder and its generated-file
  exclusions rather than re-deriving them.
- [[verify-intent]] — the fidelity axis. Same advisory posture, same severities.
- [[code-review]] — the correctness axis. Runtime-provided in Claude Code.
- [[tasks]] — where a comment describing unowned work belongs; `spawn` is how it gets an id.
- [[new-project]] — ships the universal conventions template this skill falls back to.
- [[adopt-project]] — reconciles which artifacts a repo has, never the prose inside a hand-written guide, so
  it does not backfill the comment rule. This skill is what reaches an already-adopted repo.
- [[fix-next]] — drains filed defects; a comment that became a task is drained there, not here.
