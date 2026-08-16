# /specs verify — read-only staleness check

Which specs still describe the code, which have fallen behind. Never writes anything. This is also the staleness primitive [[roadmap]]'s Cross-tree pass calls — keep the definition here canonical.

## Staleness definition (canonical)

A spec is **stale** when its `sources` changed since it was generated:

1. Parse the spec's frontmatter: `generated-at`, `sources`, and `source-commits` (optional — see *External sources* below).
2. **Partition `sources`** into *in-repo* and *external* (a glob that escapes the project root via `../`, or an absolute path outside it). A spec with no external sources skips step 5 entirely.
3. `git cat-file -e <generated-at>` — unknown sha (rebase, shallow clone) → **stale (unknown baseline)**.
4. **In-repo sources:** `git diff --name-only <generated-at>..HEAD -- <in-repo sources...>` — non-empty → **stale**, with the changed-file count.
5. **External sources:** resolve each against its own repo, per *External sources* below — non-empty → **stale**.
6. Missing/unparseable frontmatter, or a mapped area with **no spec file at all** → **never generated** (worse than stale).

Stale if **either** of steps 4/5 reports changes; the counts add.

Non-git projects: compare file mtimes against `generated-on` (best-effort; say so in the output).

### External sources — a stamp only measures its own repo

`generated-at` names **this** repo's HEAD, so `git diff <generated-at>..HEAD` can only ever observe files this repo tracks. Where an area's globs point into a sibling repo — the normal case for a **polyrepo aggregator**, whose whole purpose is contracts spanning several repos — that diff silently matches nothing, and the area reports **fresh forever**. This is worse than a weak check: it is a guard that reports green by construction, and it hides drift that is already there.

So each external repo carries its own baseline, in an optional frontmatter map keyed by the path prefix exactly as it appears in `sources`:

```yaml
source-commits:
  ../Birko.Data.SQL: d8c2f40
  ../Birko.Data.MongoDB: 88f96ee
```

Per external source glob:

1. **Find its repo root** — the nearest ancestor directory containing `.git`. Never guess from the name.
2. Look that prefix up in `source-commits`. **Absent → stale (unknown baseline)** for that repo, named as such. Do *not* fall back to `generated-at`: a sha from another repo either fails to resolve or, far worse, resolves to an unrelated commit.
3. `git -C <repo-root> diff --name-only <sha>..HEAD -- <globs relative to that root>` — non-empty → **stale**.

Report external staleness **per repo**, not merged: *"3 changed in `../Birko.Data.SQL`, 1 in `../Birko.Data.MongoDB`"* tells you where to look; a single total does not.

**Backwards-compatible by construction.** A project whose sources are all in-repo never reaches step 5 and behaves exactly as before, so `source-commits` is absent from most specs and that is correct — flag its absence only for areas that actually have external sources.

## Steps

1. **Find project root + load `.map.yml`.** No map → `No docs/specs/.map.yml — run /specs init to bootstrap.` and exit.
2. **Per area**, apply the staleness definition above. Batch the reads; the git calls are cheap — run them per spec, don't re-read sources.
3. **Unmapped check** (cheap glob): project sources matching no area and no `ignore` entry → count + a few example paths.
4. **Render:**
   ```
   docs/specs/  (<A> areas)
     fresh:            <n>
     stale:            <n>   (<area>: <k> changed sources, ...)
     unknown baseline: <n>   (<area>: no source-commits entry for <repo>, ...)
     never generated:  <n>   (<area>, ...)
     unmapped sources: <n>   (<example paths> ...)

   Run /specs regen <area> to refresh, /specs init to fix the map.
   ```
   Suppress zero-count lines. All fresh and nothing unmapped → one line: `docs/specs/ — <A> areas, all fresh ✓`.

**Summary mode** (bare `/specs` routes here): render only the counts block, skip the per-area detail unless something is stale.
