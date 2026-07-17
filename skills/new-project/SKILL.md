---
name: new-project
description: Scaffold a brand-new project of ANY tech stack with a consistent universal layer — README.md, CLAUDE.md (seeded with the team's feature lifecycle convention), .gitignore, docs/ (incl. docs/features/), and a tracked tasks/ folder. Use when the user says "new project", "novy projekt", "start a project", "scaffold a project", "bootstrap a repo", "create a new app/library/service", or wants a fresh repo set up with docs + task tracking. Tech-agnostic (Python, TS, Go, .NET, anything). **This is the universal front door for new projects** — it builds the universal layer and then, when a stack-specific scaffolding skill is installed for the chosen stack (a team framework's wiring skill), chains it for the code wiring; such stack skills may equally invoke this one as their universal front half. Sets up the [[tasks]] folder and the [[feature]] skill's docs/features/ so the project is ready for the prototype→decide→decompose→test→review lifecycle from day one.
---

# new-project

The front door for a new project. Produces a **consistent universal layer** regardless of language, then optionally chains language-specific wiring. The goal: every new repo starts already wired for tracked, testable, reviewable, stakeholder-visible work.

**Extension hook:** a team may install a **stack-specific scaffolding skill** (a framework's wiring skill — build props, solution/workspace registration, source layout). When one is installed that matches the chosen stack, this skill gathers the basics, scaffolds the universal layer, and then *calls* the stack skill for the code wiring (step 5). The relationship also works inverted: a stack scaffolding skill can be the user's entry point and invoke this one first for its universal layer. Either way the layering holds — the stack skill knows this one; this one only knows the *hook*, never a specific framework.

## What it creates

```
<project-root>/
  README.md                 ← seeded from intake (templates/README.seed.md)
  CLAUDE.md                 ← agent guide w/ feature lifecycle (default), OR a one-line `@AGENTS.md` bridge
  AGENTS.md                 ← only if "AGENTS.md canonical" chosen — holds the content; CLAUDE.md imports it
  CHANGELOG.md              ← Keep-a-Changelog stub (code changelog; decisions live in docs/features/)
  .gitignore                ← stack-appropriate (always ignores .env)
  .gitattributes            ← line-ending normalization (text=auto eol=lf)
  .editorconfig             ← shared editor style
  .env.example              ← service/API/web kinds only (real .env stays ignored)
  LICENSE                   ← full text with year+author, if chosen
  docs/
    BRIEF.md                ← the user's ask, VERBATIM (append-only ground truth — written first)
    features/               ← home for the [[feature]] skill (prototype, decisions, status)
    specs/                  ← home for the [[specs]] skill (.map.yml seed; specs harvested later)
    architecture.md         ← short but real overview; a living doc, not a stub
  tasks/                    ← initialized via the [[tasks]] skill (.config.yml, README.md)
  .github/workflows/ci.yml  ← install→build→test gate, if a stack with known CI was chosen
  Dockerfile (+ .dockerignore) ← service/API/web kinds only
  .git/ (+ origin remote)   ← git init; remote offered for hybrid task mode
  src/ (+ tests/)           ← stack-idiomatic source root + tests, if a stack was chosen
  <manifest + skeleton>     ← package.json / pyproject.toml / go.mod / Cargo.toml …
  <named project folders>   ← instead of src/, when a stack scaffolder owns the layout (e.g. .NET named projects)
```

## Flow

### 1. Intake (plain `AskUserQuestion` — these are facts, not debates)

Gather in one or two question batches:

1. **Project name** + **location** (absolute path). If the dir exists and is non-empty, confirm before writing; merge, don't clobber.
2. **Kind** — library / service-or-API / web app / CLI / worker / other.
3. **Tech stack** — .NET, TypeScript/Node, Python, Go, Rust, other, or "none yet / docs-only". This drives `.gitignore` and which skeleton step 5 creates.
4. **Stack scaffolder check** — if a stack-specific scaffolding skill is installed that matches the chosen stack (check the available-skills list for a framework wiring skill), ask whether to chain it. If yes → it runs in step 5.
5. **Task tracking mode** — local (files only) / hybrid (GitHub) / hybrid (Jira). Passed to the [[tasks]] init.
6. **License** — MIT / Apache-2.0 / proprietary / none.
7. **Agent config file** — **CLAUDE.md only** (default; Claude Code's native auto-loaded file — right for Claude-Code-only repos) / **AGENTS.md canonical + CLAUDE.md bridge** (when other agent tools — Codex, Cursor, etc. — also touch the repo; one source of truth, both tools satisfied). Only surface this if it's plausibly multi-tool; otherwise default silently to CLAUDE.md.

### 2. Offer a scope grill (optional — only for substantial projects)

- If the project is non-trivial (a service, a product, anything with real architecture choices), **offer** — don't force — a scope grill: "Want me to grill you on scope/architecture before scaffolding? A wrong project-level assumption is the most expensive to unwind."
- If yes → invoke [[grill-me]] on the project scope. Fold the resolved decisions into `README.md` (overview) and `CLAUDE.md` (constraints/architecture notes).
- For a throwaway lib or a docs-only repo, skip silently. (Per-*feature* grilling is mandatory later in [[feature]] `new`; per-*project* grilling is opt-in here.)

### 3. Scaffold the universal layer

- **`docs/BRIEF.md` — store the user's request VERBATIM (do this first, before any paraphrasing).** Capture the original ask word-for-word (typos and all), with a capture date and a "do not rewrite" note. README/CLAUDE/idea.md are all *distillations*; this is the ground truth they reconcile against. Without it, a paraphrase silently becomes the only record and nuance/requirements drift or vanish (a soft or secondary requirement is the classic casualty). The requirement→feature traceability table (in the seed EPIC) should cite `docs/BRIEF.md` as its source. Skip only for a truly throwaway/docs-only repo with no stated requirements.
  - **Keep it append-only as the project evolves.** The original block stays immutable, but when the user makes a later requirement-changing request (a new feature, a scope change), append it **verbatim** under an "Amendments" section with a date and the feature it became. The brief is the running ground truth of *everything the user asked for*, not just the opening ask — so a mid-project request (a new feature, mode, or integration) is logged here too, not only as a distilled feature.
- **`README.md`** — render [templates/README.seed.md](templates/README.seed.md): title, one-paragraph purpose (from intake/grill), a "Getting started" stub, the "How we work" lifecycle section, layout tree, and license line. Set `{{AGENT_GUIDE_FILE}}` to `CLAUDE.md` (default) or `AGENTS.md` (canonical-AGENTS choice) so the "full convention" link points at the real guide.
- **Agent config** — render [templates/CLAUDE.seed.md](templates/CLAUDE.seed.md) (the agent-guide content: the **feature lifecycle convention** so any future agent knows features go idea → prototype → decisions(approved/deferred/changed/removed) → tasks → human-test plan → review, plus name/stack/grill output). Where it lands depends on the step-1 choice:
  - **CLAUDE.md only** (default) → write the rendered content to `CLAUDE.md`. Done.
  - **AGENTS.md canonical + bridge** → write the rendered content to `AGENTS.md`, then write `CLAUDE.md` containing exactly the one-line import `@AGENTS.md` (Claude Code pulls AGENTS.md in natively; other tools read AGENTS.md directly). **One source of truth — never duplicate the content into both files** (a divergent CLAUDE.md/AGENTS.md pair is the one genuinely bad outcome; it's also exactly what `/tasks audit`-style dedup logic exists to prevent). Use the `@import` bridge rather than a symlink — symlinks are fragile on Windows.
  - The seed template is filename-agnostic — same content renders to whichever file is canonical.
  - **Seed the `## Conventions` rulebook with real content — not bare placeholders.** The seed's `## Conventions` block is the project's canonical, living rulebook (it lives in the auto-loaded agent guide so every future task sees it). A rulebook that ships as empty `{{…}}` tokens teaches the next task nothing, so actively fill each subsection:
    - **Framework/stack** — from the chosen stack: name the foundation + the approved libraries, and note "no new framework/major dep without a recorded decision."
    - **Code structure & patterns** and **Naming** — **seed the stack's idiomatic defaults** rather than leaving them blank (e.g. TS: feature-folder or layered `src/`, named exports, `camelCase`/`PascalCase`; Python: src-layout, `snake_case`, type hints; .NET: idiomatic conventions, or the ones a chained stack scaffolder documents; Go: package layout, `MixedCaps`). These are safe starting rules the team edits later — a sensible default beats an empty heading.
    - **UI/UX** — for a UI kind, this is the subsection most worth getting right, so **ask one targeted question** (alongside intake, not a full grill): the component library / design system, the token source (color/spacing/type scale), and the accessibility bar. Record the answers. **Delete the whole subsection for headless / library / CLI / worker kinds** (no UI surface to govern).
    - **Testing** — `{{TEST_CONVENTION}}` from the stack.
    - Fold in any scope-grill output. Leave the register-on-introduce + working-rules sub-blocks as-is.
    - **Rule:** every subsection either carries a real rule or is removed — never a dangling `{{…}}`. From here, [[verify-conventions]] lints diffs against this block and the lifecycle keeps it current.
- **`.gitignore`** — stack-appropriate (e.g. `bin/ obj/` for .NET, `node_modules/ dist/` for Node, `__pycache__/ .venv/` for Python). For "none yet", a minimal OS/editor ignore. **Always include `.env` and `.env.*`** (never commit secrets).
- **`.gitattributes`** — `* text=auto eol=lf` line-ending normalization (matters on a Windows shop committing cross-platform). Add stack-specific binary markers if relevant.
- **`.editorconfig`** — basic shared style (UTF-8, final newline, stack-idiomatic indent) so editors agree regardless of contributor.
- **`.env.example`** — for service / API / web kinds, a documented (valueless) template of required env vars; the real `.env` stays gitignored. Skip for pure libraries.
- **`LICENSE`** — if chosen, write the **full license text** (MIT/Apache-2.0) with the current year and the **copyright holder** filled in — not just a name reference. Intake doesn't ask for the holder; derive it from `git config user.name` (and an org if the remote/owner is known), and only ask if that's empty. Skip for proprietary/none (note it in README instead).
- **`CHANGELOG.md`** — a [Keep a Changelog](https://keepachangelog.com) stub with an `## [Unreleased]` section. This is the *code* changelog (maintained by the [[roll-changelog]] skill); it's distinct from the *decision* ledger in `docs/features/` — the lifecycle tracks both.
- **`docs/features/`** — create the directory and a **`docs/features/README.md` features index** (the human entry point: a table of every feature with status, linking each folder), rendered from the [[feature]] skill's `templates/README.md.tmpl` (empty table at birth). Don't rely on a `.gitkeep` alone — the index doubles as the tracked-dir anchor and the at-a-glance list. From then on `/feature status` (all-features mode) owns regenerating it; don't hand-roll its shape here — use the feature skill's template so the two stay in sync.
- **`docs/specs/`** — create the directory + a starter `.map.yml` from the [[specs]] skill's `templates/map.yml` (empty `areas:` list, stack-appropriate `ignore:` globs). Specs are *harvested from code*, so at birth this is just the anchor — once real code exists, `/specs init` proposes the area map and `/specs regen` generates the capability specs. The seed agent-guide template already carries this leg (header bullet + lifecycle step "Spec check at story close") — don't add a duplicate line.
- **`docs/architecture.md`** — write a real (if short) architecture overview, not just a stub, and mark it a **living document**: it must be updated whenever a feature changes the structure, not left at its scaffold state. (A stale `architecture.md` that still describes day-1 assumptions is a common, silent rot — the [[feature]] skill is responsible for refreshing it as features land.)
- **Requirement traceability + resumable roadmap (do NOT skip for multi-feature briefs).** When the brief lists several capabilities (a real product, not a one-off), **persist the plan as tracked artifacts, never only in chat** — otherwise a brief requirement silently evaporates and a cold-start agent has no map:
  - Write a **requirement → feature** matrix in the **seed EPIC** (the task/feature roll-up rules keep it current): one row per explicit requirement from the brief/grill, each mapped to a tracked feature/story. **Every stated requirement must have a tracked home** — if one doesn't map anywhere, that's a planning bug, not an omission to defer silently. **Don't put a hand-typed status column here** — status is read live from `/roadmap` (the [[roadmap]] skill), never persisted by hand or it rots. If you want a standalone file, a `docs/ROADMAP.md` is fine **only** as a status-free brief→feature coverage map (mapping only, touched on scope changes); never as a status mirror.
  - Seed the **whole planned roadmap** up front as `status: idea` feature folders + `planned` STORY stubs (not just the first one). The repo must be resumable: if the session ends right after planning, the next agent sees the full intent, not one lonely story.
  - Soft/qualitative requirements (e.g. "make it fast", "accessible", "polished/good-looking") are the easiest to drop — give them their **own tracked feature**, don't fold them into a vague bullet that another feature can later overwrite.
  - The durable feature list lives as `docs/features/FEATURE-*/` folders (the [[feature]] skill's home and the thing bare `/feature` renders). Seed every planned requirement as at least an `idea.md` stub here at project birth; from then on [[feature]] owns keeping that list **complete and current** (see its "living artifact" rule). Don't leave the roadmap only in README prose or chat.

### 4. Initialize task tracking

- **Hybrid-GitHub needs the repo slug first.** `tasks/.config.yml` for hybrid-GitHub stores `repo: owner/name`, which isn't known until a remote exists — but remote creation is step 6. So when the chosen mode is hybrid-GitHub, **resolve the repo slug before writing the config**: do step 6's remote action now (offer `gh repo create`, or ask for the intended `owner/name`), and pass the resolved slug into the tasks init. If the user defers the remote, fall back to `local` mode and tell them to switch to hybrid later via `/tasks migrate`. (local / hybrid-Jira modes have no such dependency — Jira uses a project key, not a git remote.)
- Chain the [[tasks]] skill to create `tasks/.config.yml` (with the resolved mode + slug) and an initial `tasks/README.md` dashboard. Don't hand-roll these — let `tasks` own its file shapes so they stay in sync with that skill.

### 5. Language-specific wiring + source root (conditional)

Create a **source root** so there's an obvious place for code — but make it **stack-idiomatic**, not a blanket `src/`. Skip it for docs-only and for .NET (where named project folders are the convention and `dotnet new` / a stack scaffolder owns them).

- **If a stack scaffolding skill was confirmed at intake** → invoke it now, passing the same name + location + its stack-specific choices. The scaffolder owns its build wiring (props/solution/workspace registration) **and the project/source folders**. Do **not** also create a generic `src/` — the scaffolder's layout wins.
- **Other stacks** → create the minimal idiomatic skeleton AND its source/tests roots:
  | Stack | Source root | Tests | Manifest |
  |---|---|---|---|
  | TypeScript / Node | `src/` (`src/index.ts`) | `tests/` or `src/**/*.test.ts` | `package.json`, `tsconfig.json` |
  | Python | `src/<package>/__init__.py` (src-layout) | `tests/` | `pyproject.toml` |
  | Rust | `src/` (`src/main.rs` or `lib.rs`) | `tests/` | `Cargo.toml` |
  | Go | flat, or `cmd/<app>/main.go` + `internal/` | `*_test.go` beside source | `go.mod` |
  | other | ask the user for the conventional layout; default `src/` + `tests/` | | |
  - Keep skeleton files minimal (an entry point + empty test) — enough to establish the layout, not a full app.
  - Confirm the layout with the user if the stack's convention is ambiguous (e.g. Python src-layout vs flat).
- **none / docs-only** → no source root; stop at the universal layer.

**Wire a runnable test harness** (any stack with a source root): chain [[populate-tests]] in `adopt`
mode so the project has a real runner from day one — not just the `{{TEST_CONVENTION}}` line in
CLAUDE.md and an empty test file. `adopt` is stack-agnostic (it sets up the runner config + a pinned
dev-dep) and, when `CLAUDE.md` § Testing names a shared/in-house toolkit, follows that toolkit's own
adoption doc. (When a chained stack scaffolder already wired a test harness in step 5, `adopt` is a
no-op.) This makes the CI gate and the lifecycle's **PROVE** leg
(`/populate-tests populate`) have something to run. Skip for docs-only.

**CI stub** (when a stack with a known CI shape is chosen): write a minimal `.github/workflows/ci.yml` (or the host's CI equivalent) that runs **install → build → test** on push/PR — the lifecycle is test-centric and review-gated, so a green-build gate is the natural enforcement point. Match the stack: `dotnet restore/build/test`, `npm ci && npm run build && npm test`, `uv sync && pytest`, `cargo build && cargo test`, `go build ./... && go test ./...`. Keep it to one job; the user expands it later. Skip for docs-only, and ask before assuming a non-GitHub CI host.

**Dockerfile** (service / API / web-UI kinds only — skip libraries/CLIs): a minimal multi-stage `Dockerfile` + `.dockerignore` for the chosen stack. When a chained stack scaffolder documents its own Docker pattern, follow that instead of the generic template. Offer it; don't force it.

### 6. Git + remote + finish

- **Ask whether the project should be git-tracked, and confirm the root before touching git.** Never silently `git init`. Run `git -C <project-dir> rev-parse --show-toplevel` first to learn the current state, then drive an `AskUserQuestion`:
  1. **Already its own repo** — `rev-parse` returns the **project dir itself** → tell the user it's already tracked here; nothing to do.
  2. **Untracked, no ancestor repo** — `rev-parse` fails → ask **"Track this project with git?"** (Yes → `git init` in the project dir / No → skip, note they can init later). Default suggestion: Yes.
  3. **Captured by an ancestor repo** — `rev-parse` returns an **ancestor** path (≠ project dir, e.g. `C:\Source` when the project is `C:\Source\MyApp`) → this is the dangerous case. **Surface the resolved ancestor root and ask which is correct**, do NOT assume:
     - *"git already tracks this via `<ancestor>` — is that the intended repo root?"* with options: **(a)** give the project its own repo (`git init <project-dir>` — becomes nested inside the ancestor); **(b)** the ancestor is an accidental repo over a folder of sibling checkouts → offer to verify it's empty (`rev-list --all --count` = 0, no `remote -v`, no `ls-files`) and remove its stray `.git` so each project tracks itself; **(c)** leave as-is (the ancestor really is meant to be the root).
  Only the user knows whether an ancestor root is intended — present the resolved root and let them confirm. Don't commit unless the user asks.
- **Remote (required for hybrid task mode):** if the user chose hybrid-GitHub, a remote must exist — `tasks` hybrid sync and `/feature review`'s issue-closing both target it. **Note:** if you already created/linked the remote in step 4 (to resolve the repo slug for `.config.yml`), don't do it twice — just confirm it here. Otherwise **offer** (don't auto-run — it's outward-facing) `gh repo create <name> --private --source=. --remote=origin`, or ask for an existing remote URL to link. If they decline, the config should already be `local` (per step 4); remind them they can `/tasks migrate` to hybrid once a remote is wired. For hybrid-Jira, no git remote is needed (handled via the Atlassian MCP).
- Print a next-step checklist:
  - "First feature: `/feature new`" (this is the intended entry point for real work)
  - "Ad-hoc task: `/tasks new`"
  - Stack-specific build/run hint if a skeleton was created.
  - CI/Docker reminders if those were generated (e.g. "set repo secrets the CI workflow expects").

## What it deliberately does NOT do

- It does **not** reimplement stack/framework wiring — an installed stack scaffolding skill owns that; this skill only chains it via the extension hook.
- It does **not** reimplement task file shapes — that's [[tasks]]'s job.
- It does **not** start building features — it leaves the repo *ready* for [[feature]] `new`.
- It does **not** force a grill for trivial repos.

## Conventions

- **No `Co-Authored-By:` trailers** in any commit it might create (user preference).
- **Always seed an agent guide (CLAUDE.md, or AGENTS.md+bridge) + README + .gitignore** for any new project — these are the non-negotiable universal layer (mirrors the user's "always update docs" preference). Default to CLAUDE.md unless the repo is plausibly multi-tool.
- PowerShell-compatible commands.
- Respect existing files on merge into a non-empty dir — never clobber a present README/CLAUDE/.gitignore without showing the diff and confirming.

## Related skills

- Stack-specific scaffolding skills (installed per team — a framework's wiring skill) — chained in step 5 for the code wiring; they may equally invoke this skill as their universal front half. Not part of this generic set.
- [[tasks]] — initializes `tasks/`; the project's tracking backbone.
- [[feature]] — the per-feature lifecycle this scaffold prepares the repo for (`docs/features/` + CLAUDE.md convention).
- [[populate-tests]] — chained in `adopt` mode to wire a runnable test harness for the stack (the lifecycle's PROVE leg); later authors/maintains the tests + the `[auto]/[manual]` ledger.
- [[roadmap]] — the live cross-tree view of `tasks/` + `docs/features/` with a drift audit. **Distinct from any static `docs/ROADMAP.md` requirement matrix you seed here:** that matrix is a one-time written table; `/roadmap` is the computed, always-current view that flags when the two trees diverge. A scaffolded project gets that drift-checking for free the moment both trees exist.
- [[specs]] — the harvested-spec skill whose `docs/specs/.map.yml` anchor this scaffold seeds; `/specs init` fills the map once the project has real code.
- [[grill-me]] — optional project-scope interrogation in step 2.
- [[roll-changelog]] — the generic skill that maintains the `CHANGELOG.md` this skill seeds (a project-local variant may shadow it).
- [[verify-conventions]] — the generic adherence lint that reads the `## Conventions` rulebook seeded here and checks diffs against it; wired into `/tasks close` and `/feature review`.
- [[init]] — Claude Code's built-in CLAUDE.md generator for an *existing* codebase; this skill is for *new* projects and seeds a lifecycle-aware CLAUDE.md instead.
