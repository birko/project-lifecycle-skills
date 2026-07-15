# /specs init — discovery pass, bless the area map

Bootstrap `docs/specs/` for a project: scan the codebase, propose a capability map, let the user bless it, write `.map.yml`.

## Steps

1. **Find project root** — same walk as the [[tasks]] skill (`tasks/.config.yml` marker → `*.slnx`/`*.sln` → `.git`). Polyrepo Shape A: if cwd is inside a subproject, init that subproject's `docs/specs/`; at the meta-root, ask whether the user wants meta-level (cross-cutting) specs or a specific subproject.

2. **Already initialized?** If `docs/specs/.map.yml` exists, this becomes a *re-discovery*: propose additions/renames against the existing map, never drop an existing area without asking. Show the delta, not a fresh map.

3. **Discovery pass** — propose the capability map from the codebase:
   - Read the project's `CLAUDE.md` / `README.md` first — the architecture section usually names the capabilities already; prefer its vocabulary.
   - Survey structure: source folders, namespaces/modules, public surface. For a large codebase, fan out [[Explore]] agents (or the Workflow tool) — one per top-level source folder — each returning proposed areas + source globs.
   - Target granularity: **capability, not class** — ~5–20 areas. Each area = a name a stakeholder would recognize (`auth-session`, `bulk-filter-updates`), with source globs that collectively cover the behavioral code.
   - Propose an `ignore` list: build output, tests, generated code, vendored deps.

4. **Present the proposed map** as a table (area · title · globs · rough file count). Check coverage: any source file matching neither an area nor `ignore` → list as unmapped and either extend an area or add one.

5. **Offer a grill** (optional, [[grill-me]]) — for a project with real architectural ambiguity, offer to grill the area boundaries before blessing ("is `auth-login` vs `auth-session` one capability or two?"). Skip silently for small/obvious projects.

6. **Write** `docs/specs/.map.yml` from [templates/map.yml](../templates/map.yml) with the blessed areas.

7. **Offer the first harvest** — suggest `/specs regen --all` (don't auto-run; the first regen on N areas is a real token spend the user should opt into).

## Edge cases

- **No obvious behavioral code** (docs-only, pure contracts/markers) — say so and write a minimal map (or nothing); don't invent areas for a project with no observable behavior.
- **Existing hand-written specs/docs** in `docs/specs/` — never overwrite; ask whether to adopt them as areas (add frontmatter + map entry) or leave them outside the map.
