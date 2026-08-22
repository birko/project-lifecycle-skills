# Decision record: this repo commits to `main` — `integration: single-branch`

- **Date:** 2026-08-18 — the field was written with the initial `tasks/.config.yml` (`1886df7`)
- **Decided by:** reconstructed 2026-08-22 from the repo's own evidence (TASK-054). The config carries a written rationale for `mode: local` but not for `integration:`, so the reasoning below is inferred from the repo's shape and from what the choice later cost. A reconstruction.
- **Status:** accepted
- **Filed:** 2026-08-22 (retroactively — see *Decided by*)
- **Rule it produced:** none standing — it is a per-repo declaration, not a convention. The rule it *exercises* is `AGENTS.md § Conventions › Read the declaration, never infer it`, of which this field is the canonical instance.

## Context

The [[tasks]] skill's documented default is **PR-per-task**: `pick` cuts `task/TASK-NNN`, `close` is the
merge gate, and `done` means merged. `integration:` in `tasks/.config.yml` selects that or
`single-branch`, and this repo declares `single-branch`.

Two things made the default a poor fit. The repo is **markdown with no build**, so a PR's central value —
CI proving the change works before it lands — collapses to a lint that runs in seconds and can equally run
before the commit. And it is **single-maintainer**, so a PR would be an author reviewing their own diff
through a web UI, which is ceremony rather than review; the actual review happens at `close`, where
`verify-conventions`, `verify-intent` and `code-review` run on the working tree.

## Decision

**`integration: single-branch`.** Work commits straight to `main`. `pick` offers no branch, `close` skips
its merge step, and `done` still means *on the default branch* — only the mechanism changes.

Critically, it is **declared in the config, not inferred.** That is the whole reason the field exists: a
squash-merge history and a commit-to-main history produce the same `git log`, so no amount of reading
history can recover the policy.

## Rejected alternatives

**PR-per-task, the documented default.** Rejected on cost-for-value above. Worth revisiting the moment a
second regular contributor appears, at which point the field is a one-line change — and this record is
what explains why it was not that from the start.

**Leave `integration:` unset and let each verb work it out.** This is the option that looks harmless and is
the actual defect: `AGENTS.md` names deducing it from `git log` as the failure TASK-021 and TASK-023 exist
to have killed. An absent field is a gap to backfill by asking, never a licence to guess.

## Consequences

**Easier.** No branch ceremony on a repo where a branch buys nothing. The close gate keeps its full
weight, since it runs on the working tree rather than on a PR diff.

**Harder, and this one is measured rather than theoretical.** `close` step 5c — the merge question — is
**never reached** on a `single-branch` repo. So `--unattended`'s contract table shipped covering the
out-of-scope sweep alone while the merge question still fired on `pr-per-task` projects, and the defect was
invisible here. `AGENTS.md` now states the general form: *"The configuration that hides such a gap is
usually the one it was written on."* Anything gated on `pr-per-task` is untested by this repo's own
dogfooding, and [[review]] — the PR-diff pass — never runs here at all.

It also means **history is linear and unreviewed-by-a-second-party.** A bad commit is on `main`
immediately; there is no staging area where someone else could catch it. That is an accepted consequence of
being single-maintainer, and it stops being acceptable the moment that changes.

**Not affected.** Consumers get `pr-per-task` as their default, which is deliberate: this record is a
statement about this repo, and the skill set should not push a single-maintainer shortcut onto teams.
