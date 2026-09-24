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
  drainable (see Edge cases). Runs steps 7–8 only. **Requires the epic to already own the tasks** — if the
  findings are filed but *loose*, re-home them first with [`move`](move.md); see the loose-backlog edge case.
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
   | `VI-*` | [[verify-intent]] — fidelity: a requirement missing, partly built, or built wrong |
   | `DRILL-*` | a **cold drill** — the prose executed by a reader denied the expected answer ([[populate-tests]] § *The cold drill*) |
   | `FIELD-*` | **no pass at all** — the product failing in ordinary use. Minted by [`new`](new.md)'s `--from-field`, not by this verb |

   **This table is the only list of prefixes.** A prefix names the *pass* that produced the finding, so a
   new source gets a row here and nothing else changes — `templates/TASK.md` and [SKILL.md](../SKILL.md)
   point at this table rather than repeating it. `DRILL-*` was added 2026-09-01 after nine drills had
   already minted such ids: a drill produces findings by **execution**, which none of the review passes
   above describes, so remapping them would have filed them under a pass that never ran.

   **`FIELD-*` is the row that breaks the "names a pass" shape, deliberately.** A defect found by *using*
   the product has no sweep behind it — no reviewer, no harvest, no drill brief — so before this row every
   available prefix required a pass to have run. [[fix-next]] § Step 1 told such a bug to join the pool by
   putting "its finding id" in `findings:`, which named a door with no key cut: there was no id and nothing
   issued one, so a genuine field defect could be worked only when a human named it. Borrowing an existing
   prefix was the tempting alternative and is worse — `CR-*` on a bug nobody code-reviewed makes the
   provenance the prefix exists to carry a lie.

   Number within the pass (`CR-1`, `CR-2`, …). If `--epic` targets an existing intake epic, continue
   its numbering rather than restarting — grep the epic's tasks' `findings:` lists for the current max.

   **`FIELD-*` numbers tree-wide instead, because it has no pass to number within.** Field reports arrive
   one at a time over months, not as a batch, so there is no epic or pass to scope a counter to — take the
   current max `FIELD-NNN` over the `findings:` lists of every copy of the task tree (this one, every local
   branch, every other worktree — [SKILL.md § ID generation](../SKILL.md#id-generation)) and increment,
   zero-padded to three digits. Scoping it to an epic would restart the count in each one and collide the moment two field
   defects landed under different parents.

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
     this ladder, and keep the order (it doubles as [[fix-next]]'s tie-breaker). **Pass the theme's
     slug as `{{THEME}}`** so the story records its ladder position in frontmatter: `fix-next` reads
     that field for the tie-break rather than inferring the theme from a title, which fails the moment
     a backlog is grouped any other way (a subject-grouped adoption, a retitled story):

     | # | `theme:` | Theme | Covers |
     |---|---|---|---|
     | 1 | `security-tenancy` | Security & tenancy | authn/authz, permission coverage, tenant/account isolation, secrets |
     | 2 | `correctness-invariants` | Correctness & invariants | data-corrupting bugs, broken architectural rules, query/predicate mistranslation |
     | 3 | `data-integrity` | Data integrity | money and unit handling, numbering/sequences, cascade & orphan cleanup |
     | 4 | `contract-drift` | Contract drift | client↔API mismatches, binding, missing endpoints, enum/status drift |
     | 5 | `performance` | Performance | N+1 loops, unpaged reads, full scans |
     | 6 | `reuse-dead-code` | Reuse & dead code | duplication, unreachable code, simplification |
     | 7 | `docs-i18n-coverage` | Docs, i18n & coverage | audits that *spawn* fix work rather than fixing in place |

     **This table is the single source of the ladder and its order — no other file restates it.**
     Stories record the **slug**, never the row number: a number would freeze this table's ordering
     into every already-stamped story, so inserting a theme or reordering the rows would silently
     remap them all with nothing to signal it. Adding a row is safe; the slugs stay stable.

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

- **Findings already filed as tasks, but with no epic to stamp** — the case that falls between this verb's
  two entrances, and the most common shape a real backlog arrives in. `--adopt` needs an epic that owns the
  tasks; `intake` proper *creates* tasks from findings. Loose tasks are neither: correctly written, and
  outside [[fix-next]]'s pool entirely (SKILL.md § *A task outside a pool*). **Measured on this repo: 17 open
  loose defect tasks, pool = 2.**
  **Two steps, in this order, and neither is folded into the other:**
  1. `/tasks new epic` for the pass if none exists, then [`/tasks move <ids> --to EPIC-NNN`](move.md) — that
     verb moves the file *and* `parent:` together and rolls up both sides' parents.
  2. `/tasks intake --adopt EPIC-NNN` — stamps `kind: review-intake` and best-effort backfills `findings:`.
  **Why not have `--adopt` do the moving.** Re-homing is a tree operation, not an intake one: most moves have
  nothing to do with review findings, and burying the mechanism in this flag means the next person who needs
  to re-home an ordinary task hand-edits `parent:` instead — which is exactly the hole `move` was added to
  close. Composing two verbs also keeps `--adopt` idempotent, since it never has to ask whether a task it can
  see is one it moved.
- **Adopting a review backlog that predates this verb** — a project may already have an epic full of
  review findings filed by hand. Don't re-file it. `/tasks intake --adopt <EPIC-NNN>` (or just say so):
  add `kind: review-intake` to the epic's frontmatter, and — best-effort — backfill `findings:` on its
  tasks from ids already named in their bodies. One line makes an existing backlog drainable; without
  the stamp [[fix-next]] reads an empty pool and correctly refuses to guess. Say how many tasks got
  ids and how many didn't, rather than inventing ids for the rest.
  **Also offer to stamp `theme:` on the epic's stories**, proposing a slug per story from the ladder
  table and letting the user correct each. An adopted backlog is grouped however its author grouped it,
  so this is the one path where the field is otherwise absent forever — and `fix-next`'s key 6 would
  announce itself inert on exactly the trees this verb exists to rescue. Offer it; never guess silently,
  and a story the user won't classify stays unstamped rather than mis-stamped.
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
