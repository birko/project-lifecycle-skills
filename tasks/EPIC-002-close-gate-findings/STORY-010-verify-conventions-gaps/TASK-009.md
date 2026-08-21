---
id: TASK-009
parent: STORY-010
feature: null
status: done
priority: P3
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# verify-conventions has no rule about generated and vendored files

## Context

Spawned from the TASK-006 verification, not part of it.

Symbio's live working diff is four files: `index.html` (cache-busting hashes), `sw.js`,
`wwwroot/app.js` and `wwwroot/app.js.map`. Three are **build output**. Linting a bundled
`app.js` against naming or structure conventions produces noise at best, and at worst
findings against code no human wrote and nobody can act on.

`skills/verify-conventions/SKILL.md` says nothing about this. It lints "each changed file",
so generated output is in scope by default — and generated files are exactly the ones most
likely to violate hand-written conventions.

The same applies to vendored dependencies (`node_modules`, `vendor/`, `packages/`), lockfiles,
and minified assets.

## Acceptance criteria

- [x] The skill states that generated, vendored and minified files are out of scope for adherence linting, and how to recognise them (path conventions, `.map` files, minified-line heuristics, `.gitattributes linguist-generated`, a project's own ignore lists)
- [x] A diff consisting **only** of generated files reports "nothing to lint — all changes are generated output" rather than either silence or noise; the distinction matters because silence reads as a pass
- [x] Prefer the project's own declaration where one exists over a built-in list
- [x] Verified against Symbio's current working diff, which is the case that surfaced it

## Out of scope

- The rulebook-location ladder → TASK-006.
- Whether generated files should be committed at all; that is the project's call.

## Human test plan

- [x] Run on Symbio's working diff and confirm the generated files are excluded with the reason stated — `app.js` excluded on the **declaration** (`CLAUDE.md:1676` names it the built bundle) and `app.js.map` as its sourcemap, each with the reason on the header line. `sw.js` **not** excluded and flagged: undeclared and undetectable, so it is linted rather than guessed away
- [x] Run on a mixed diff (hand-written + generated) and confirm only the hand-written files are linted — the same Symbio run is genuinely mixed: 4 of 6 tracked files linted, the two declared artifacts dropped

## Implementation plan

**Measured on Symbio before designing, and it inverts the obvious approach.** Its three generated files
in the live diff:

| File | Lines | Longest line | Detectable by heuristic? |
|---|---|---|---|
| `app.js.map` | 7 | 4,154,785 | yes — `.map` extension, absurd line length |
| `app.js` | 75,037 | 19,028 | yes — bundled/minified |
| `sw.js` | 128 | 104 | **no.** Reads as hand-written by every signal |

`sw.js` is the case that matters. A heuristic-only implementation excludes the two obvious files and
goes on linting the third, so the noise this task exists to remove is only partly removed while the
report now *claims* generated output was handled. And Symbio carries **no** `linguist-generated`
attribute, so there is nothing to read either.

That fixes the shape of the rule:

1. **Declaration first** — `.gitattributes` `linguist-generated` / `linguist-vendored` is the
   purpose-built one; a guide naming its build-output paths counts too. This is the repo's own *read the
   declaration, never infer it* convention, and `sw.js` is why it is not merely tidier.
2. **Heuristics second**, and stated as partial: `.map`, lockfiles, known vendor directories, minified
   shape (very long lines, huge byte-to-line ratio). They catch bundles; they do not catch a small
   generated file.
3. **Unclassifiable → lint it, and say so.** The safe direction is asymmetric: a false *inclusion*
   produces noise a reader can dismiss, a false *exclusion* silently stops checking hand-written code.
   Never guess toward exclusion.
4. **Recommend the durable fix** — a `linguist-generated` line — rather than growing a built-in list,
   since only the project knows that `sw.js` is emitted.
5. **Never repurpose a list that answers a different question.** `docs/specs/.map.yml`'s `ignore:` is
   tempting and present in real repos — Symbio's declares `**/wwwroot/**`, which would have covered two
   of the three. It also declares `tests/**`, `docs/**`, `tasks/**` and `tools/**`, all hand-written. Use
   it as a generated-file oracle and you silently stop linting tests, which is where § Testing
   conventions apply most.
6. **All-generated diff** reports it explicitly; silence reads as a pass.

## Progress log

- step 2 — picked as the other half of STORY-010, with a live repro found during TASK-013's Symbio drill.
- step 3 — verified: held, and **rescoped before any writing**. The task framed this as excluding
  generated files; measuring Symbio showed the interesting half is the file that *cannot* be detected.
- step 4 — layer: local.
- step 5 — fix in `skills/verify-conventions/SKILL.md`: new step 2b, plus the exclusions on the report
  header alongside the rulebook line.
- step 6 — **no guard to fail**; the lint does not read a skill's step list. Evidence is the drills.
- step 7 — no usable spec map (`areas: []`). Nothing to respec.

## Outcome

**What was broken.** The skill linted "each changed file", so build output was in scope by default — and
generated files are the ones most likely to violate hand-written conventions. Findings against a bundle
are noise at best and at worst point at code nobody can act on, because the fix lives in the source.

**The measurement inverted the design.** I expected heuristics to carry this. On Symbio's live diff
`app.js.map` (7 lines, one of 4,154,785 characters) and `app.js` (75,037 lines, longest 19,028) are
trivial to spot — but `sw.js` is **128 lines with a longest line of 104** and is indistinguishable from
hand-written code by every available signal. A heuristic-only rule drops the two obvious files, keeps
linting the third, and now *claims* generated output was handled. So the rule reads the project's
declaration first, and heuristics are stated as partial by construction.

**Declaration-first is not merely tidier, and Symbio proved it concretely.** Its guide already says
`wwwroot/app.js` is the built bundle (`CLAUDE.md:1676`) and even predicts this exact failure —
*"preformatuje cely bundle na 60k-riadkovy sumovy diff"*. The declaration was sitting there; nothing
read it.

**Judgement call: asymmetric on uncertainty.** An unclassifiable file is **linted**, and the report says
it was. A false inclusion is noise a reader dismisses in a second; a false exclusion silently stops
checking code a human wrote. `sw.js` therefore stays in scope, with a recommendation to add
`linguist-generated` — the durable fix, which only the project can make.

**The trap the rule is built around.** `docs/specs/.map.yml`'s `ignore:` is the live temptation: it
exists, and on Symbio it declares `**/wwwroot/**`, covering two of three. It also declares `tests/**`,
`docs/**`, `tasks/**` and `tools/**`, all hand-written — so using it as a generated-file oracle silently
stops linting tests, exactly where a § Testing convention applies. It answers a different question.

**Exclusions ride on the report header**, next to the rulebook line TASK-013 added, and for the same
reason: a pass over four files and a pass over seven are different claims, and an exclusion nobody sees
is how a wrongly-skipped hand-written file stays skipped.
