---
id: TASK-007
parent: STORY-002
feature: null
status: done
priority: P1
assignee: agent
created: 2026-08-18
depends-on: [TASK-003]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Do not offer a CI gate a repo cannot possibly pass

## Context

Found by drilling `adopt-project` on `C:\Source\Birko\Consumers\Latent` — the first run against a
real consumer, and it produced a defect within minutes.

`LAYER.md`'s CI row says: *"Absent → offer a minimal install→build→test workflow for the detected
stack."* Latent is a clean .NET 10 solution with xUnit tests, so that offer fires. It would be
**actively harmful**: `src/Latent.Birko/Latent.Birko.csproj` imports

```
$(BirkoSrc)\Birko.Helpers\Birko.Helpers.projitems
```

— shared **source from outside the repo**, resolved via `BirkoSrc` → `BIRKO_SRC` →
`..\..\Framework`. On a GitHub runner none of those resolve: the framework tree is not a
dependency that can be restored, and it is not even a repo that could be cloned (untracked root,
177 nested repos — see STORY-009). `dotnet build` fails at import resolution.

So adoption would hand the user a workflow that is red on its first run and stays red. Worse than
no CI: a permanently-failing gate trains people to ignore CI, and a repo with a red badge and no
CI look identical in outcome but the first actively erodes the habit.

The general rule the drill exposed: **a repo whose build depends on paths outside itself cannot be
built in isolation, and offering it isolated CI is wrong by construction.** The aggregator pattern
is the team's normal shape, so this is the common case, not an edge case.

## Acceptance criteria

- [x] Before offering CI, detect out-of-repo build dependencies: MSBuild `Import`/`ProjectReference` paths escaping the repo root (`..` beyond it, or an absolute/`$(Var)`-rooted path), and the equivalent for other stacks (a path dependency in `Cargo.toml`, a `file:` dep in `package.json`, an editable local install in Python)
- [x] When found, **skip the CI offer and say why** — naming the dependency and what would have to exist on a runner for a build to succeed. Never write a workflow that cannot pass
- [x] `LAYER.md`'s CI row states this as the rule, not as an aside
- [x] `.gitignore` row also covers agent-tool local state (`.claude/`), found untracked in Latent
- [x] Re-drill on Latent and confirm CI is skipped with the reason stated, and on flappy-dragon (self-contained node) that CI is still offered normally

## Out of scope

- Making aggregator consumers CI-able — that needs a decision about how the framework tree is distributed, which is STORY-009's territory, not a lint rule.
- Latent's own missing CI: correctly left absent by this rule.

## Human test plan

- [x] Ran the survey on Latent and confirmed the CI row reads "skipped — out-of-repo source import" with the projitems path quoted — run from the repo copy, pre-junction
- [x] flappy-dragon (self-contained node): CI still offered — run from the repo copy, pre-junction
- [x] Confirmed no workflow file was written into Latent — run from the repo copy, pre-junction
- [x] **WorkoutTracker (2026-08-18, installed skill)**: CI skipped, with `Directory.Build.props` resolving `$(BirkoSrc)` to a sibling framework tree named as the reason, and no workflow written. A second consumer confirming the rule generalises past Latent — and the first drill of it through the junction rather than the repo copy

## Implementation plan

1. Add the detection rule to `LAYER.md`'s CI row with the reasoning, since that file is the shared
   inventory both front doors read.
2. Extend the `.gitignore` row for agent-tool local state.
3. Re-run the survey on both repos.
4. The re-drill exposed a second, smaller defect: counting `..` segments over-reports, because
   `../../src/X` from `tests/Y/` stays inside the repo. LAYER.md now says to resolve the path and
   flag only targets that land outside the root, plus `$(Variable)`-rooted paths that cannot be
   resolved at all. Recorded explicitly because the wrong implementation is the obvious one.
