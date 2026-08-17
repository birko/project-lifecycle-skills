# /specs verify — read-only staleness check

Which specs still describe the code, which have fallen behind. Never writes anything. This is also the staleness primitive [[roadmap]]'s Cross-tree pass calls — keep the definition here canonical.

## Staleness definition (canonical)

A spec is **stale** when its `sources` changed since it was generated:

1. Parse the spec's frontmatter: `generated-at`, `sources`, and `source-commits` (optional — see *External sources* below).
2. **Partition `sources`** into *in-repo* and *external* (a glob that escapes the project root via `../`, or an absolute path outside it). A spec with no external sources skips step 5 entirely.
3. **Resolve the in-repo anchor** — *not* `generated-at` on its own; see *The stamp predates its own spec* below:
   - `SPEC_COMMIT` = `git log -1 --format=%H -- docs/specs/<area>.md` (empty when the spec is untracked).
   - Only consider `SPEC_COMMIT` if the stamp is actually behind it in this history: `git merge-base --is-ancestor <generated-at> <SPEC_COMMIT>`. If it is not an ancestor — rewritten history, a cherry-pick, a spec restored from elsewhere — the two shas describe different lines and comparing their dates would be meaningless, so keep `generated-at`.
   - Otherwise take whichever is **later by committer date** (`git log -1 --format=%ct <sha>`). Either being unresolvable just means the other wins.
   - Neither resolves → **stale (unknown baseline)**.
4. **In-repo sources:** `git diff --name-only <anchor>..HEAD -- ':(glob)<glob>' ...` — non-empty → **stale**, with the changed-file count. **The `:(glob)` prefix is not optional** — see *Pathspecs are not globs* below.
5. **External sources:** resolve each against its own repo, per *External sources* below — non-empty → **stale**.
6. Missing/unparseable frontmatter, or a mapped area with **no spec file at all** → **never generated** (worse than stale).

Stale if **either** of steps 4/5 reports changes; the counts add.

### The stamp predates its own spec

`generated-at` is written at harvest time, **before** the spec file it stamps has been committed — and [regen](regen.md) step 7 tells you to commit the spec *with the related work*. So the source changes the spec was just written from land in a commit the stamp cannot include, and the next `verify` reports them as drift the spec has already absorbed.

This is not an edge case. Measured across a 25-area polyrepo aggregator: **25 of 25 stamps were older than the commit that last wrote their own spec**, gaps from minutes to two days. Anchoring on the stamp alone reported **15 stale areas / 40 changed files** where the truth was **6 / 10** — nine areas were false positives, including one whose content was written three minutes *after* the commits it was accused of missing. A staleness check that cries wolf on 60% of its findings teaches people to stop reading spec diffs, which is the one thing this verb exists to make them do.

**Take the later of the two**, rather than simply preferring the spec's own commit — the two failure directions are different and both real:

| Situation | `generated-at` | spec's own commit | anchor | why |
|---|---|---|---|---|
| Normal: regen, then commit spec + sources together | earlier | later | **spec's commit** | the sources in that commit are what the spec was written from |
| Regen run but not yet committed | later | earlier (or none) | **`generated-at`** | the spec on disk is newer than its last commit |
| Spec touched by an unrelated commit (a rename, a lint) | earlier | later | **spec's commit** | slightly optimistic — see below |

**Known bias, stated rather than hidden:** anchoring on the spec's own commit treats everything in that commit as absorbed. If a source was edited *after* the harvest but committed alongside the spec, that change is not in the spec and this will not report it. That is a deliberate trade — it under-reports in a narrow case that the next regen catches, where the old behaviour over-reported structurally on **every single spec**. Prefer a check people still believe.

**The sharp edge of that bias: a commit that touches a spec without regenerating it still moves its anchor.** A frontmatter fix, a bulk re-stamp, a rename, a lint pass — `git log -1 -- <spec>` cannot tell those from a real regen, so every source changed before that touch is silently credited as absorbed. Observed in the field: one maintenance commit touched all 25 specs in an aggregator, of which only 6 had actually been regenerated. So: **if you edit spec files without regenerating them, either regen the ones you touched or accept that their baseline just moved forward.** Distinguishing a body change from a frontmatter change per commit is possible but not worth the machinery for a check whose job is to point you at a diff to read.

Worked example — the case this fix exists for:

```
c0                                        <- HEAD when the harvest runs
    working tree already holds the RedisCache.ClearAsync fix
    /specs regen caching   -> generated-at: c0   (rev-parse HEAD, and the fix is NOT in it)
c1  commit: docs/specs/caching.md + RedisCache.cs      <- regen step 7's advice, one commit

git diff c0..HEAD -- <caching sources>   -> RedisCache.cs changed   => "stale"  (wrong: the
                                                                       spec was written from it)
git diff c1..HEAD -- <caching sources>   -> empty                   => fresh    (right)
```

Note it takes an uncommitted source change at harvest time — which is the *normal* way this is used, since you regen after editing and commit the two together. If the fix had been committed before the harvest, `generated-at` would already name it and the stamp would be fine; that is why the defect is invisible when you reason about it from a clean tree.

Non-git projects keep the mtime comparison below; there is no commit to anchor on.

Non-git projects: compare file mtimes against `generated-on` (best-effort; say so in the output).

### Pathspecs are not globs

`.map.yml` sources are written as globs — `src/**/*.cs`, `../Birko.Data.SQL/**/*.cs` — and a git **pathspec** is not a glob unless you say so. By default git matches it with `*` crossing `/`, so `src/**/*.cs` requires a literal `/` after `src/` and **silently fails to match a file sitting directly in `src/`**:

```
src/Stores/Store.cs    matched by  src/**/*.cs          ✓  (nested — looks like it works)
src/RedisCache.cs      matched by  src/**/*.cs          ✗  (top level — invisible)
src/RedisCache.cs      matched by  :(glob)src/**/*.cs   ✓
```

Partial blindness is worse than total blindness: the check reports changes for nested files, so it looks alive while missing every edit to a file at a source root. Measured in one aggregator: **47 of 74 source globs had files at their root — 124 files the check could never see.** Always pass `:(glob)`.

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
3. `git -C <repo-root> diff --name-only <sha>..HEAD -- ':(glob)<glob relative to that root>' ...` — non-empty → **stale**. Same `:(glob)` requirement as step 4.

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
