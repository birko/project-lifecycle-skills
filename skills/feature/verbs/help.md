# /feature help — print the verb table

Print the text inside the code block below exactly as written, without its fence lines, and exit. Do nothing else: no file is read and no feature is collected. The menu is a short form of [SKILL.md](../SKILL.md#verbs-router)'s verb table; when a verb is added there, add its line here.

```
/feature <verb> [FEATURE-NNN]

  new         capture an idea; grill it into a decision tree; create the feature folder
  prototype   build an interactive prototype for stakeholders (HTML / wireframe / state-model playground / spike)
  decide      stamp each decision: approved / deferred / changed / removed (+ rationale)
  decompose   turn approved decisions into tracked tasks (/tasks new --from-feature)
  status      regenerate the stakeholder-facing status rollup
  review      completeness gate: decisions built + tasks merged + human-test verification + sign-off
  pick        enter a feature at the right stage (decide → decompose → /tasks pick)
  show        read-only view of a feature
  help        this table

Lifecycle:  new ─▶ prototype ─▶ decide ─▶ decompose ─▶ (work in /tasks) ─▶ status ─▶ review
Bare /feature  → list all features with decision counts + task progress.
Working on an existing feature? Use /feature pick — it offers decompose when
approved decisions have no tasks yet, and won't hand off to work until they do.
```
