# /feature help — print the verb table

Print the verb table from [SKILL.md](../SKILL.md#verbs-router) and the one-line lifecycle, then exit. Do nothing else.

```
/feature <verb> [FEATURE-NNN]

  new         capture an idea; grill it into a decision tree; create the feature folder
  prototype   build an interactive prototype for stakeholders (HTML / wireframe / spike)
  decide      stamp each decision: approved / deferred / changed / removed (+ rationale)
  decompose   turn approved decisions into tracked tasks (/tasks new --from-feature)
  status      regenerate the stakeholder-facing status rollup
  review      completeness gate: decisions built + tasks merged + human-test verification + sign-off
  show        read-only view of a feature
  help        this table

Lifecycle:  new ─▶ prototype ─▶ decide ─▶ decompose ─▶ (work in /tasks) ─▶ status ─▶ review
Bare /feature  → list all features with decision counts + task progress.
```
