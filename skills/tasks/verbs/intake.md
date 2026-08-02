# /tasks intake — file a review pass as tracked work

A review pass produced findings. Turn them into a **drainable backlog**: one EPIC for the pass,
STORYs by severity theme, one TASK per coherent fix group — each task self-contained and carrying the
finding ids it remediates.

This is the review-side mirror of `/feature decompose`: that verb batches
`/tasks new --from-feature`, this one batches [`/tasks new --from-review`](new.md). Same engine,
different source of work.

> **Why this verb exists.** [[code-review]], [[security-review]] and [[verify-conventions]] all report
> to stdout or a PR comment and none of them writes files — *"a security fix is tracked work, not a
> side effect of the pass that found it."* Without an intake step, that tracked work is never created
> and the pass evaporates the moment the conversation ends.

## When this fires

- Right after a review pass at **project or module scale** — `/code-review`, `/security-review`,
  `/verify-conventions`, or a fan-out sweep — when the output is more than a couple of findings.
- After a [[specs]] `regen` whose diff review classified behavioral changes as **unexplained**.
- On a pasted or committed review report from elsewhere (an external audit, a pentest, a colleague's
  write-up).
- **Not** for a single adjacent finding surfaced while working a task — that's
  [`/tasks spawn`](spawn.md). The dividing line is a *pass* versus an *incident*.

## Args

- `[scope]` — free text naming what was reviewed (`"auth module"`, `"full codebase"`). Used in the
  epic title/slug. Ask if absent.
- `--source <ref>` — where the findings came from, if there's something durable to point at (a report
  path, a PR url, a commit). Optional; findings usually arrive in-conversation.
- `--epic <EPIC-NNN>` — file into an existing `kind: review-intake` epic instead of creating one
  (a second pass over the same scope, or a review split across sessions).
- `--adopt <EPIC-NNN>` — no new findings; stamp an existing hand-built review epic so it becomes
  drainable (see Edge cases). Runs steps 7–8 only.
- `--dry-run` — print the proposed tree and stop. Nothing written.

## Steps

1. **Find task root** (SKILL.md § Shape detection).

2. **Collect the findings.** From the review just run in this conversation, from `--source`, or from
   text the user pasted. For each, capture: the claim, the **evidence** (`file:line` + the mechanism —
   not just the rule that was violated), the severity the reviewer assigned, and the suggested fix if
   one was offered.

   **Assign a stable id per finding**, prefixed by source so provenance survives:

   | Prefix | Source |
   |---|---|
   | `CR-*` | [[code-review]] — correctness |
   | `SEC-*` | [[security-review]] |
   | `SH-*` | [[specs]] harvest — an unexplained behavioral change in a regen diff |
   | `VC-*` | [[verify-conventions]] — adherence |

   Number within the pass (`CR-1`, `CR-2`, …). If `--epic` targets an existing intake epic, continue
   its numbering rather than restarting — grep the epic's tasks' `findings:` lists for the current max.

3. **Triage before filing — not every finding is work.** Walk each one:
   - **Real defect / real adherence gap** → it becomes work (step 4).
   - **Not a defect** (the reviewer misread the code, the behaviour is intentional) → **drop it, with
     the reason recorded** in the epic's `## Area of concern` under a `### Findings dropped at intake`
     list. A dropped finding must stay visible, or the next pass re-raises it and someone re-litigates
     it from scratch.
   - **Needs a decision, not a fix** (a breaking API change, a convention that isn't settled) → route
     per [spawn.md](spawn.md) step 3: a stakeholder-visible capability goes to `/feature new`; a
     `deferred`/`removed` decision the finding overturns goes back to `/feature decide`. Don't mint a
     task that quietly implements an undecided choice.
   - **Duplicate of an open task** → link it: append the id to that task's `findings:` and add the new
     evidence to its Context. Don't create a second task ([audit.md](audit.md)'s duplicate rule).

4. **Group findings into tasks — findings travel in packs.** Several findings that share a **root
   cause**, or that live in the same function/module and would be fixed in one edit, are **one task**
   carrying all their ids. Findings that merely share a *category* are not. Getting this right at
   filing time is what stops [[fix-next]] from discovering the grouping mid-fix and having to widen.

   Size each group to **≤ ~1 day / one PR**. A group bigger than that is a STORY with tasks under it,
   not one task.

5. **Scaffold the tree.**
   - **EPIC** — chain [new.md](new.md) (`epic`), title `<scope> review <YYYY-MM>`, and pass
     `{{KIND}}` = **`review-intake`** plus `{{SOURCE}}` = the provenance (report path(s), a PR, or
     `<pass> <date>` when the findings arrived in-conversation — a list is fine when a second pass is
     adopted into the same epic). The `kind` stamp is the whole contract with [[fix-next]]: it is how
     the drain finds this backlog, so no epic id is ever hard-coded anywhere; `source` is what lets a
     reader six months later find what produced these tasks. Write the pass itself into
     `## Area of concern` — what was reviewed, by what, on which commit, how many findings, and the
     dropped list from step 3.
   - **STORY per theme** — only for themes that actually got findings; don't scaffold empty ones. Use
     this ladder, and keep the order (it doubles as [[fix-next]]'s tie-breaker):

     | # | Theme | Covers |
     |---|---|---|
     | 1 | Security & tenancy | authn/authz, permission coverage, tenant/account isolation, secrets |
     | 2 | Correctness & invariants | data-corrupting bugs, broken architectural rules, query/predicate mistranslation |
     | 3 | Data integrity | money and unit handling, numbering/sequences, cascade & orphan cleanup |
     | 4 | Contract drift | client↔API mismatches, binding, missing endpoints, enum/status drift |
     | 5 | Performance | N+1 loops, unpaged reads, full scans |
     | 6 | Reuse & dead code | duplication, unreachable code, simplification |
     | 7 | Docs, i18n & coverage | audits that *spawn* fix work rather than fixing in place |

   - **TASK per group** — chain [new.md](new.md) (`task`) with
     `--from-review <ids> [--source <ref>] --no-plan`, parented to its theme story. Priority from
     severity: theme 1–2 blockers → P0, other blockers → P1, warnings → P1/P2, suggestions → P2.

6. **Never file a bare checklist.** ***A checklist line is filed, not scheduled.*** Only
   `status: todo` **tasks** are ranked by any picker — a finding parked as a bullet under a STORY is
   invisible to `/tasks pick`, to the `Next up` snapshot, and to [[fix-next]], so it will simply never
   be worked. If a finding is too vague to state acceptance criteria for, it still becomes a task —
   one whose acceptance is *"reproduce and characterize; then either fix or close with evidence"* —
   never a bullet.

7. **Regenerate dashboard** — chain [verbs/triage.md](triage.md).

8. **Report** — the tree, then counts by theme, then the handoff:
   ```
   EPIC-031  auth-module review 2026-08   (kind: review-intake)
     STORY-071  security & tenancy      3 tasks   (CR-7, CR-9, SEC-2, SEC-5)
     STORY-072  correctness             2 tasks   (CR-12, CR-14, SH-4)
     STORY-073  performance             1 task    (CR-20)

   11 findings → 6 tasks · 2 dropped (recorded on the epic) · 1 → /feature decide

   Drain it with /fix-next.
   ```

## Edge cases

- **Adopting a review backlog that predates this verb** — a project may already have an epic full of
  review findings filed by hand. Don't re-file it. `/tasks intake --adopt <EPIC-NNN>` (or just say so):
  add `kind: review-intake` to the epic's frontmatter, and — best-effort — backfill `findings:` on its
  tasks from ids already named in their bodies. One line makes an existing backlog drainable; without
  the stamp [[fix-next]] reads an empty pool and correctly refuses to guess. Say how many tasks got
  ids and how many didn't, rather than inventing ids for the rest.
- **One or two findings only** — don't scaffold an epic for it. Say so and use
  [`/tasks spawn`](spawn.md) (or `/tasks new`) instead; the ceremony costs more than it tracks.
- **Findings span several existing epics' areas** — still file them under the review epic. The pass is
  the unit: "how much of the audit is left?" must stay answerable, and it isn't once findings scatter
  across subject epics. Cross-reference the subject epic in each task's Context.
- **Re-running a pass over the same scope** — `--epic <EPIC-NNN>` into the existing intake epic and
  continue the finding numbering. Findings that duplicate an open task from the last pass link to it
  (step 3); findings that duplicate a **`done`** task are a regression — file fresh, and say so in the
  Context, because that's evidence the earlier fix or its test didn't hold.
- **A finding the reviewer marked blocker but you judge a false positive** — you don't get to drop it
  silently on your own read. Record it in the dropped list *with the evidence*, and say so in the
  report so the user can push back.
- **No `tasks/.config.yml`** — [new.md](new.md)'s mode-detection flow runs on the first create; nothing
  special here.
- **Review output already committed as a file** — pass it as `--source`. Still write the evidence into
  each task's Context; the file is provenance, not the brief.
