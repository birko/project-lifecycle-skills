# /tasks init — bootstrap the tasks/ folder (config + dashboard)

Create `tasks/.config.yml` and the initial `tasks/README.md` dashboard for a project that
doesn't have them yet. This is the entry point [[new-project]] chains at scaffold time (step 4),
and it's safe to run standalone on an existing repo that's adopting the skill.

Idempotent: if both files already exist, report that and change nothing (suggest `/tasks triage`
to refresh the dashboard instead).

## Args

- `mode=<local|hybrid-github|hybrid-jira>` — skip the mode question (a caller like
  [[new-project]] already asked at intake; **never re-ask what the caller resolved**).
- `repo=<owner/name>` — hybrid-github only; the resolved slug.
- `project=<KEY>` — hybrid-jira only; the Jira project key.

## Steps

1. **Find the project root** (shape detection: `tasks/.config.yml` marker → `*.slnx`/`*.sln` → `.git`); the task root is `<root>/tasks/`. Create the folder if absent.

2. **Resolve the mode:**
   - `mode=` arg present → use it verbatim.
   - Otherwise run the [mode detection flow](new.md#mode-detection-flow) (scan signals, ask the user).

3. **Write `tasks/.config.yml`** from [templates/config.yml](../templates/config.yml) with the resolved mode (+ `repo:`/`project:` for hybrid). Don't overwrite an existing config — if one exists with a *different* mode than the arg, surface the conflict and let the user decide (`/tasks migrate` is the mode-change path, not init).

4. **Generate the initial dashboard** — run the [triage](triage.md) logic over whatever tree exists (an empty tree renders zero counts; scaffold-seeded epics/stories render their `planned` rows). Write `tasks/README.md`.

5. **Confirm** — print both file paths and the next step: "Create work with `/tasks new` (or `/feature new` for stakeholder-facing features)."

## Edge cases

- **`tasks/` exists with task files but no `.config.yml`** — a pre-skill or older-version tree: run mode detection, write the config, regenerate the dashboard over the existing files (adopt, don't disturb).
- **Hybrid-github without a resolvable repo** — no `repo=` arg and no `origin` remote: fall back to `local` and say so (the caller can `/tasks migrate` once a remote exists). Mirrors [[new-project]] step 4's fallback.
