# /specs verify — read-only staleness check

Which specs still describe the code, which have fallen behind. Never writes anything. This is also the staleness primitive [[roadmap]]'s Cross-tree pass calls — keep the definition here canonical.

## Staleness definition (canonical)

A spec is **stale** when its `sources` changed since it was generated:

1. Parse the spec's frontmatter: `generated-at`, `sources`.
2. `git cat-file -e <generated-at>` — unknown sha (rebase, shallow clone) → **stale (unknown baseline)**.
3. `git diff --name-only <generated-at>..HEAD -- <sources...>` — non-empty → **stale**, with the changed-file count.
4. Missing/unparseable frontmatter, or a mapped area with **no spec file at all** → **never generated** (worse than stale).

Non-git projects: compare file mtimes against `generated-on` (best-effort; say so in the output).

## Steps

1. **Find project root + load `.map.yml`.** No map → `No docs/specs/.map.yml — run /specs init to bootstrap.` and exit.
2. **Per area**, apply the staleness definition above. Batch the reads; the git calls are cheap — run them per spec, don't re-read sources.
3. **Unmapped check** (cheap glob): project sources matching no area and no `ignore` entry → count + a few example paths.
4. **Render:**
   ```
   docs/specs/  (<A> areas)
     fresh:            <n>
     stale:            <n>   (<area>: <k> changed sources, ...)
     never generated:  <n>   (<area>, ...)
     unmapped sources: <n>   (<example paths> ...)

   Run /specs regen <area> to refresh, /specs init to fix the map.
   ```
   Suppress zero-count lines. All fresh and nothing unmapped → one line: `docs/specs/ — <A> areas, all fresh ✓`.

**Summary mode** (bare `/specs` routes here): render only the counts block, skip the per-area detail unless something is stale.
