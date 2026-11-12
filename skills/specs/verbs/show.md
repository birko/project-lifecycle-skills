# /specs show — print one area's spec

Read-only view of a single capability spec.

## Steps

1. **Find project root + load `.map.yml`.** No map, or a map whose `areas:` list is empty → `No usable spec map — run /specs init to bootstrap.` and exit, as the router does.
2. **Resolve the area** — exact `name` match first, then unambiguous prefix/substring. Ambiguous or unknown → list the map's areas and stop.
3. **Print** `docs/specs/<area>.md` (the body; keep the frontmatter as a one-line header: `area · generated-on · shaped-by`). When `shaped-by-derived:` is `false` or absent, render the provenance as **`shaped-by: (never derived)`** rather than as an empty list — an un-derived field is unknown, not empty, and a reader must not take `[]` at face value. Suggest `/specs regen <area>` to fill it. When it *was* derived but `shaped-by-unresolved:` is non-zero, append **`(N tasks left no evidence)`** — a partial answer shown as a plain list reads as a complete one.
4. **Freshness footer** — run the [verify](verify.md) staleness check for just this spec and append one line: `fresh ✓ (as of <generated-on>)` or `⚠ stale — <k> sources changed since <anchor short sha> → /specs regen <area>`, where the anchor is the one [verify](verify.md) step 3 resolved (the later of `generated-at` and the spec's own last commit), never `generated-at` read on its own. An unresolvable anchor prints `⚠ stale — unknown baseline → /specs regen <area>`.
5. **No spec file yet** (mapped but never generated) → say so and suggest `/specs regen <area>`.
