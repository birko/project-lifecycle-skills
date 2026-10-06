---
id: TASK-077
parent: STORY-007
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-26
depends-on: [TASK-076]
blocks: [TASK-078]
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# The report surface — an Artifact, a fallback, and what each candidate must carry

## Context

STORY-007 asks for the pass to **report as an Artifact** (a shareable published page), *"falling back to a
temp HTML file where the runtime has no Artifact surface — the same runtime-degradation pattern
`tasks/close` already uses for `code-review`."*

**That precedent is the thing to copy, and it is a specific one.** `close` step 5b's rule is: the skill is
runtime-provided, and **if the name does not resolve, do the pass inline — never skip the gate because a
skill did not resolve.** Applied here: an absent Artifact surface degrades the *delivery*, never the
*analysis*. A run that produces no report because it could not publish one is the failure this task exists to
prevent.

**Why the report earns its own task rather than riding along with the skill.** Two independent reasons: the
runtime-degradation path is a distinct behaviour with its own precedent to follow and its own way of going
wrong silently; and the **per-candidate shape** is what makes findings comparable to each other. A report
whose candidates each argue in their own format cannot be ranked, and ranking is what TASK-078 hands to
`intake`.

### What each candidate carries, per STORY-007

Files · problem · solution · **benefits stated in terms of leverage and locality** · a before/after visual ·
a recommendation strength.

The benefits framing is the non-obvious one and should not be softened to "why it's good": **leverage** is how
much else gets easier, **locality** is how much stays put. Those are the two things a reader trades against
the cost of the refactor, and a benefit stated in any other terms cannot be compared with the next
candidate's.

**Recommendation strength is not priority.** Strength is confidence that the candidate is real; priority is
blast radius, and [[fix-next]] computes that from its own keys when the task exists. Conflating them here
would pre-empt a ranking that belongs downstream.

## Acceptance criteria

- [x] The report publishes as an Artifact, and **degrades to a temp HTML file** when no Artifact surface exists — never to "no report"
- [x] The degradation is written as the `close`-step-5b pattern (delivery degrades, the pass does not), and says so, so the next reader recognises it as the house pattern rather than a local invention
- [x] Every candidate carries all six parts, and the shape is stated once for all candidates rather than described per candidate
- [x] **Benefits are in leverage and locality terms**, with both defined inline — a benefit phrased another way is not comparable and the criterion is that comparability, not the wording
- [x] The before/after visual is specified concretely enough to produce without a design decision per candidate
- [x] Recommendation **strength** is defined as confidence-that-it-is-real, and explicitly **not** priority — with the reason that ranking belongs to `intake`/[[fix-next]] downstream
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The scan and the finding classes — **TASK-076**, which this depends on.
- The `intake` handoff — **TASK-078**. This task produces the report; that one turns it into tracked work.
- Prescribing a diagram *tool*. The visual's content is specified here; how it is drawn is the runtime's business.
- Deferred to TASK-263 — the candidate key's stability and re-checking every kind of rejection (Steps 1, 4, 5), found by this task's drill and correctness review.
- Deferred to TASK-264 — `feature prototype`'s publish-detection wording (VC-062).

## Human test plan

- [x] Produce a report with at least two candidates and confirm their benefits are stated so the two can be **compared** — that is the whole point of fixing the shape
- [x] Force the fallback path (no Artifact surface) and confirm a readable report still lands as a temp HTML file, with the analysis intact
- [x] Check that no candidate's *strength* reads as a priority, and that nothing in the report pre-ranks the work

## Implementation plan

Drafted 2026-10-06 by the `Plan` agent; the precedents were checked (`close` step 5b's inline fallback, and `feature/verbs/prototype.md`'s single offline HTML file published privately where the runtime can).

**Where:** `## Output` in `skills/improve-architecture/SKILL.md` is replaced by `## Output — the report`, inline, because TASK-078's handoff reads the shape from the same file. One AGENTS.md § *Code structure & patterns* bullet is added (register-on-introduce), because this is the third instance of the pattern after `close` 5b and `prototype`: **a runtime-provided capability degrades the delivery, never the pass.**

1. **Delivery, the `close` 5b pattern:**
   - **Always write the page first,** as one self-contained HTML file in the runtime's scratch directory, else the OS temp directory. Never inside the repo: it would be committed, and the next run's `git ls-files` would count it.
   - **Publish it privately** when this session's tool list has a tool that publishes a page as a private link (Claude Code's `Artifact`). Decide from the actual tool list, never from the runtime's name.
   - **No tool, or a publish that fails,** ends the same way: the temp file is the report, and its path and the reason are printed.
   - **No ask-step:** the page starts private, and an ask would push every unattended run onto the fallback path.
2. **One six-part candidate shape,** stated once as a table: Files, Problem, Solution, Benefits, Before/after, Strength. An empty part says `none — <why>`.
3. **Benefits** in leverage terms (callers relieved, counted and named) and locality terms (files per change, before and after; callers untouched), defined inline. Never combined into one score. A figure not counted is written `not measured — <why>`.
4. **The visual:** two panels on one layout. Boxes for files, arrows for calls, dashed lines for co-change with counts, a frame round each module. The after panel shows merges, deletions and a deepened interface strip, with what changed highlighted and everything else grey. At most 12 boxes, and a text fallback under each panel. The tool is the runtime's choice.
5. **Strength:** `strong`, `moderate` or `tentative` as confidence that the candidate is real, with what moves it. Never priority: that is blast radius, computed downstream by [[fix-next]]. Candidates are listed by key, never by strength.
6. **The other sections:** header and the records line; Rejected, with each record line verbatim for intake; Previously rejected; Already filed. Every one prints.
7. **Stdout, always:** the header, one line per candidate, the rejection sections in full, and last `report: <link>` or `report: <path> (<reason>)`.
8. **TASK-078 note:** the six parts are the content each filed task carries, and the Rejected section's record lines are what goes into the dropped list.

**Human test plan:** a cold `claude -p` runner on a scratch clone of `ClientApi.CSharp` with the seeded `docs/adr/0001`. It has no `Artifact` tool, so it forces the fallback naturally. If fewer than two candidates come out, re-run with a rung 1 direction at the client classes.

## Progress log

- 2026-10-06 — Picked; plan drafted by the `Plan` agent and its precedents checked. `## Output — the report` written, AGENTS.md bullet added, note left on TASK-078. Lint OK.
- 2026-10-06 — **Human test plan: one cold drill.**
  - **Runner:** `claude -p --disable-slash-commands --permission-mode acceptEdits --add-dir <%TEMP%/d077out> --allowedTools "Bash(git:*)" … "Write" < brief`, run in a fresh scratch clone of `C:/Source/ClientApi.CSharp` (`%TEMP%/d077`) with the TASK-076 drill's seeded `docs/adr/0001`. The granted output directory stood in for the runtime's scratch directory. **Coldness:** it listed no skills. The brief held the procedure and the passages it links to, with no direction and no expected answer.
  - **Step 2, the fallback:** the runner had no publishing tool. It wrote a 23 KB self-contained page, `improve-architecture-d077-0eaa1c3.html`: six SVG panels, a text fallback under each, all six parts on each of 3 candidates, and no network URL. It printed `report: <path> (no publishing surface)`, and printed the full rejection sections to stdout. The repo was untouched.
  - **Step 1, comparable benefits:** each leverage line counts the callers or sites relieved, and each locality line reads "N → M files per change": candidate 1 gives 6 → 1, candidate 2 gives 6 → 3, candidate 3 gives 2 → 1. They read straight across.
  - **Step 3:** no strength line carries priority language, and the candidates are listed by key.
  - **Its guesses exposed two gaps,** both deferred to TASK-263: a key collision when two candidates share a main file and class, and no rejection path for a class 1 or 4 signal that fails on a closer look. They were first fixed here, then taken back out at the close gate, because they belong to the scan (TASK-076's steps), not the report.
  - Held as sensible judgement calls: the root directory `.` counted as a hot spot; "examined first" read as not exclusive.
  - **Outside this task:** the reader also reported a correctness bug in the fixture repo (`ParseErrorResponse`'s `parameter` is never passed, so a 404 reads as "query too short"). It is ClientApi.CSharp's, relayed to the owner, and not filed here.
- 2026-10-06 — **Close gate (step 5b), each axis reported separately:**
  - **Standards** ([[verify-conventions]]): no blockers. Three warnings on the new AGENTS.md bullet, all fixed: the instances are a "today" list that can grow; the headline is "the means or the delivery" (`close` 5b changes who runs the pass); `prototype`'s file is primary, and only its state-model playground publishes. A detail pointer was added. One note → TASK-264 (VC-062, `prototype`'s detection wording).
  - **Fidelity** ([[verify-intent]]): all 7 criteria built. Scope-creep notes acted on: the two drill fixes to Steps 4 and 5 were reverted and deferred to TASK-263, and the TASK-078 note is marked a proposal. Its note that stdout had narrowed is fixed with the correctness items below.
  - **Correctness** (code-review pass): 10 findings.
    - **To TASK-263** (scan and gate, not the report): #1, #2 and #4, on key stability, key-led rejection entries and re-checking every rejection.
    - **#3** is TASK-078's existing criterion: writing the key onto filed tasks.
    - **Fixed here:**
      - #5: each class gets its move in Step 4's table, and every candidate collects its paths;
      - #6: "module" is defined;
      - #7: strength rows are ordered, evidence only;
      - #8: stdout and the page agree again;
      - #9: the publishing rationale is corrected (the page goes to the provider the session already uses, and starts private);
      - #10: the publishing tool's own page rules apply to the published copy.

      #5 and #6 touch Step 4, but criterion 5 (a visual producible without a per-candidate design decision) cannot be met without them.
  - **Re-check of those fixes:** 5–10 fixed. New defects, all fixed:
    - a single file counted as a module in Python, JS and Rust, which would make every co-change pair a leaky seam;
    - the two path sets did not feed both benefits;
    - `strong` counted the raising signal as its own corroboration;
    - stdout dropped the direction note and the evidence lines;
    - the Delivery line misdescribed `close` 5b;
    - one-adapter candidates had no move;
    - the AGENTS bullet overstated `prototype`.
  - **Security:** not applicable, because the diff is prose with no security surface. **Comments:** not applicable, because there are no code comments in range.
  - **Out of scope (5d):** 5 boundaries (TASK-076, TASK-078, the diagram tool, TASK-263, TASK-264), 2 spawned (TASK-263, TASK-264), 0 declined.
