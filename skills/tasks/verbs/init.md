# /tasks init — bootstrap the tasks/ folder (config + dashboard)

Create `tasks/.config.yml` and the initial `tasks/README.md` dashboard for a project that
doesn't have them yet. This is the entry point [[new-project]] chains at scaffold time (step 4),
and it's safe to run standalone on an existing repo that's adopting the skill.

Idempotent: a second run on an **up-to-date** tree writes nothing. But *existing* is not
*current* — a `.config.yml` written by an older version of this skill is reconciled against the
current template first (step 3), because a file that merely exists cannot be reported as up to date.

## Args

- `mode=<local|hybrid-github|hybrid-jira>` — skip the mode question (a caller like
  [[new-project]] already asked at intake; **never re-ask what the caller resolved**).
- `repo=<owner/name>` — hybrid-github only; the resolved slug.
- `project=<KEY>` — hybrid-jira only; the Jira project key.
- `integration=<pr-per-task|single-branch>` — skip the integration question the same way `mode=`
  skips the mode one. [[adopt-project]] asks it inside its single frontier round and passes the
  answer here; **never re-ask what the caller resolved**.
- `workspace=<in-place|worktree>` and `worktree-root=<path>` — the answers to the **workspace question**
  below, which the front doors ([[new-project]] at intake, [[adopt-project]] in its frontier round) put
  and pass here. Each writes a live key, in the Absent and the Present branch alike, exactly as
  `integration=` does. `worktree-root=` comes only with `workspace=worktree`.

## Steps

1. **Find the project root** (shape detection: `tasks/.config.yml` marker → `*.slnx`/`*.sln` → `.git`); the task root is `<root>/tasks/`. Create the folder if absent.

2. **Resolve the mode:**
   - `mode=` arg present → use it verbatim.
   - Otherwise run the [mode detection flow](new.md#mode-detection-flow) (scan signals, ask the user).

3. **Write or reconcile `tasks/.config.yml`** against [templates/config.yml](../templates/config.yml) — the **only** source of what a config contains. Never carry a second copy of the field list in this file.
   - **Absent** → write it from the template with **every resolved value**: mode, `integration:` when the caller passed one, and `repo:`/`project:` for hybrid. A caller's answer is the only thing that fills `integration:` — the template's commented example is a choice to make, not a value to copy, so writing `pr-per-task` verbatim over a passed `integration=single-branch` is the same defect as re-asking a question the caller already resolved.
     - **With no `integration=` and nobody asked, omit the line — do not fill in the template's commented example, and leave that comment block in place.** The same holds for every field the template ships commented out: no live key without an answer, comment block kept.
        "Omit the line" means write no *live* key, never delete the comment: the template's own text defines the undeclared state as *absent, **this comment left in place***, so a create branch that stripped it would leave the next reader no cue that a decision is outstanding — and the reconcile branch below, which adds a commented field *as its comment block*, would then disagree with it. The rule below is not scoped to an existing repo: a brand-new config's silence is not a decision either, and this is the branch where the defect actually landed. Ask when a user is present; unattended, leave the field out and **report it unresolved**, exactly as the reconcile branch does. That yields one honest state from both branches, which a later [[adopt-project]] run detects and backfills — where a written default is a *declaration nobody made*, and the field's whole point is being read rather than inferred. Measured (DRILL-053-6): a scaffold told to skip `git init` shipped `integration: pr-per-task`, declaring a PR-per-task policy in a repo with no git at all.
   - **Present** → **reconcile, don't overwrite.** Every field the template declares and the file lacks is **added**, carrying the template's own comment. Values already in the file are never touched: reconciliation *adds*, it does not re-decide. Comments and keys the template doesn't know about survive — people hand-edit this file — so append what's missing rather than regenerating from the template. Put each added field **where the template puts it**, so two configs stay comparable by eye. A field the template declares **commented out** (today `integration:` among others) is added **as its comment block** when nothing has answered it — and **a comment block already in the file is not added again**, so a re-run does not append it twice. That settles only whether the *comment* needs writing: the field it documents is still **undeclared**, because a commented line reads as absent (`skills/new-project/LAYER.md` § *A named declaration is not a version*). So `integration:` behind a comment is still asked below, or reported unresolved, exactly as if the block were missing — reconciliation carries the documentation forward, it does not decide the question the comment is there to pose. **A caller's `integration=` still writes a live key here, exactly as in the Absent branch**: this is the branch [[adopt-project]] always lands on, since an adopted repo has a config by definition, so a rule that swallowed the answer would discard the one the frontier round just asked for.
   - A field whose value is a **real choice** (`integration:`) is **asked**, never defaulted — in an existing repo *or* a new one: neither an old config's silence nor a fresh template's default is a decision. Put this question:

     > **How does work reach the default branch in this repo?**
     > · **pr-per-task** — `pick` cuts `task/TASK-NNN` and `close` is the merge gate.
     > · **single-branch** — commits go straight to the default branch; `close` skips its merge step.

     Unattended, with no user to ask and no arg, leave the field absent and **report it unresolved** — consumers have a documented default, and a value written into the file looks *decided*, which is worse than an absent one.
   - **`workspace:` and `worktree-root:` are asked by the front doors, never by init itself.** Init writes
     what `workspace=` / `worktree-root=` carry, and otherwise only carries the comment blocks forward.
     Run on its own, it asks nothing about them. **The workspace question** — the one wording both front
     doors put, kept here beside the fields it fills. Put exactly this:

     > **Where should each task's work happen?**
     > · **in place** — in this one copy of the repository, as today.
     > · **its own worktree** — each task gets its own folder outside the repository, so several tasks can
     >   run at once and this copy stays on the main line.

     **Skip it when the integration model is already `single-branch`.** There is no task branch to put in a
     worktree, so one option would do nothing. Say it was skipped and why.

     If the answer is **its own worktree**, a front door may follow with the **root question**, worded here
     rather than borrowed from `pick`, because nothing is committed at this point. Put exactly this:

     > **Where should task worktrees live?** Each task gets its own folder there, outside this repository.
     > Suggested: `../wt` (next to this repository). Give a path, or leave it blank to decide later —
     > `pick` asks when the first task needs one.

     **Check an answer before passing it**, exactly as `pick` step 6b checks a root: resolve it against the
     repo root, and refuse it if it equals the repo's top level or lies beneath it. Refused or blank → pass
     no `worktree-root=`, and report *worktree-root undeclared — pick will ask*, adding the reason for a
     refusal. A refused root written here would be refused again by every later pick.
     **No answer to the workspace question, or nobody to ask:** pass nothing and write nothing. Absent
     `workspace:` already means `in-place`, a defined state. Report it as *workspace undeclared — tasks work
     in place*, which is true and names the gap, never as a choice somebody made.
   - **Mode conflict** — an existing config whose mode differs from the arg: surface it and let the user decide (`/tasks migrate` is the mode-change path, not init). Put this question:

     > **This project's `tasks/.config.yml` says `mode: <existing>`, but this run was passed `mode=<arg>`. Which is right?**
     > · **Keep `<existing>`** — ignore the argument for this run.
     > · **Change to `<arg>`** — this is a mode change; run `/tasks migrate` rather than having `init` rewrite it.

     **No answer, or nobody to ask:** keep the **existing** value, ignore the arg, and **report the conflict unresolved**, naming both values. Init reconciles and never re-decides, so the file on disk wins by default; and a mode change carries a migration this verb does not perform, which is why an unanswered conflict must not be resolved in the argument's favour.
   - Why this is not "leave it alone": the field list grows, so a config written before a field existed reports complete from the outside. That is the case [[adopt-project]] delegates here to settle, and step 5's three outcomes are what let it report the truth — `already current` and `brought up to date` are both real answers it can pass on, where silence would have forced it to report `unknown`.

4. **Generate the initial dashboard** — run the [triage](triage.md) logic over whatever tree exists (an empty tree renders zero counts; scaffold-seeded epics/stories render their `planned` rows). Write `tasks/README.md`.

5. **Confirm** — print both file paths, and the config outcome as one of three: **created**, **already current** (nothing to add), or **brought up to date** (naming each field added and each answer asked for). A comment block added for a field nobody answered is named as *added commented, undeclared — nothing asked*, and is **not** listed as unresolved: its absence is a defined state. For `workspace:` and `worktree-root:` that one line is the whole report, printed with the front door's wording above (*workspace undeclared — tasks work in place*, *worktree-root undeclared — pick will ask*) when a front door put the question. **Name any field left unresolved**, whichever outcome it was — a caller composing a report cannot invent that line, and `integration:` left out silently is the whole defect this verb was handed. Then the next step: "Create work with `/tasks new` (or `/feature new` for stakeholder-facing features)."
   - The three are distinct on purpose. A caller cannot distinguish "your config is current" from "I declined to look" if both print the same line, and [[adopt-project]] has to.

## Edge cases

- **`tasks/` exists with task files but no `.config.yml`** — a pre-skill or older-version tree: run mode detection, write the config, regenerate the dashboard over the existing files (adopt, don't disturb).
- **`.config.yml` exists but predates fields the template has since gained** — the upgrade path, and the common one now that repos have been on the skill for a while. Step 3 reconciles it in place: fields added, existing values and comments untouched, real choices asked. Observed in `Presenter`, whose config was written by `/tasks import` on 2026-05-28 and carries no `integration:` field at all; an adoption pass delegated here, was told nothing to do, and the missing field was then guessed from `git log`.
- **Hybrid-github without a resolvable repo** — no `repo=` arg and no `origin` remote: fall back to `local` and say so (the caller can `/tasks migrate` once a remote exists). Mirrors [[new-project]] step 4's fallback.
