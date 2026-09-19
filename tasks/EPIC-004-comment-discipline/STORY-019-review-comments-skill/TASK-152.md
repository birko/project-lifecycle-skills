---
id: TASK-152
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-19
depends-on: []
blocks: []
findings: [DRILL-143-1]
pr: null
github-issue: null
jira-key: null
---

# `review-comments` promises a `PATH` argument and never defines it

## Context

Found while building TASK-143's drill fixture, not by a review pass.

`skills/review-comments/SKILL.md`'s invocation block offers three forms:

```
/review-comments [PATH …]        the current diff (default)
/review-comments --all           the whole repository
/review-comments --all --batch N print batch N of the same ordering
```

**`PATH` appears exactly once in the whole file — on that line.** Nothing says what passing a path
does. Step 2 defines two scopes only, the diff and `--all`, so a caller who writes
`/review-comments src/mill.ts` gets whatever the reader improvises: the diff *restricted* to that path,
that whole file swept regardless of the diff, or the path ignored.

**This is the same defect class the skill itself refuses for `--batch`.** That flag is refused by name
where it cannot apply, on the stated grounds that *"a flag silently dropped by one path is worse than
one that never existed, because the caller reads the promise and not the scope."* `PATH` is a promise in
the invocation block with no scope behind it at all.

**It bit during the drill and that is how it was found.** TASK-143's fixture needed a run that is scoped
but not diff-bound — `--all` deliberately asks nothing, so the only-copy question cannot be exercised
there. A path argument is the obvious way to get one, and it turned out to be undefined, so the fixture
was rebuilt to make the comments an unstaged diff instead. That worked, but it means **the only-copy
question has only ever been exercised through the diff scope.**

**The third form matters most and is the least defined.** A whole-file sweep of one file is exactly what
someone reaching for this command wants — *"check the comments in the file I am about to work in"* —
and today that is the one thing the invocation block appears to offer and does not.

## Acceptance criteria

- [ ] Step 2 defines what a `PATH` argument does, in the same terms as the other two scopes, or the form is removed from the invocation block.
- [ ] If defined: it says whether the path restricts the diff or sweeps the whole file regardless of the diff. One reading, not a sentence admitting both.
- [ ] If it sweeps whole files, it says whether the only-copy question is asked there — `--all` suppresses it, and a path scope is not `--all`, so the answer cannot be inferred from either existing rule.
- [ ] Generated-file exclusion and `git ls-files` membership apply to a path scope too, or the file says why they do not.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The two defined scopes — TASK-142, working.
- The only-copy rule — TASK-143, working; this task only widens where it can be reached.

## Human test plan

- [ ] Run `/review-comments <one file>` on the TASK-143 fixture (`scratchpad/drill-143`, resettable with `git reset --hard && git clean -fd`) with a **clean** tree, so the diff is empty. Expected: the file is swept and the header names the path scope. Today an empty diff and a path argument cannot be told apart in the output.
- [ ] Run it twice with the same arguments. Expected: the same scope both times. An undefined form invites two readers to improvise differently, which is the defect rather than a side effect of it.
