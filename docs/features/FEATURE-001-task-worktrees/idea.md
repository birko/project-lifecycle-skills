---
id: FEATURE-001
created: 2026-09-18
owner: František Bereň
# status — one of: idea, review (built, sign-off pending), done, dropped, superseded
status: idea
---

# Task worktrees — run a task in its own checkout

> Stakeholder-readable. A project manager or end user should understand the problem and the proposed shape without reading any code.

## Problem

Today a task gets a **branch**. `/tasks pick` cuts `task/TASK-NNN`, you work in the one and only
copy of the project on disk, and `/tasks close` merges it. That works, and it has three costs that
show up the moment more than one thing is happening at once:

- **Only one task can be in flight.** Two agents, or an agent and a person, cannot work on two
  tasks at the same time — they are standing in the same folder, and switching tasks means
  stashing or committing half-finished work.
- **The clean copy disappears while you work.** There is no longer a copy of the project sitting on
  the main line that you can build, run, or compare against, because the only copy has your
  changes in it.
- **Anything that needs a disposable copy improvises.** The test-drill rules already tell people to
  use "a clone or worktree", and nothing says where those go or who deletes them afterwards.

Git has a built-in answer — a **worktree**: a second folder on disk holding the same project at a
different point in its history. The project's rules simply do not mention them.

## Proposed shape

Let a project declare that it wants each task done in its own folder. When it has, `/tasks pick`
creates that folder, the work happens there, and `/tasks close` merges it back and removes it. The
main copy of the project stays on the main line the whole time and is always buildable.

Three things guard it, because the failure modes here are quiet ones:

1. **The folder is never created inside the project.** Where these folders live is *declared*
   once, per project. If nothing is declared, the tool **asks**, offering a suggestion — and if
   nobody answers, it writes nothing, quietly falls back to today's behaviour, and says so. A
   suggestion never becomes a decision on its own.
2. **A tool that cannot actually move into the new folder does not get one.** It falls back to
   today's branch and reports that it did. Creating a folder nobody moves into is worse than not
   creating one: the work would silently land on the main line.
3. **It proves it moved rather than believing it moved.** After the move it checks where it
   actually is, on the evidence, and undoes the whole thing if the answer is wrong.

## Open questions distilled from the grill

_Filled from the [[grill-me]] interview at `/feature new`. Each resolved branch becomes a row in
[decisions.md](decisions.md) with state `proposed`, ready for `/feature decide`._

- **What is a worktree actually buying us that a branch does not?** All four motives were claimed:
  parallel tasks/agents, a permanently clean main copy, drills needing a disposable checkout, and
  reviewing someone else's branch side by side. Only the first is impossible with a branch, but the
  set of four is what makes this a first-class *workspace* idea rather than a drill helper → **D1**.
- **Is this a third value of `integration:`, or its own field?** `integration:` answers *how work
  lands* (`pr-per-task` / `single-branch`); this answers *where work happens*. They compose
  independently, and `single-branch` + worktree is incoherent — one field carrying two questions
  would hand `close` a value it cannot act on → **D2**.
- **What happens when the running tool cannot move into a worktree?** Creating it anyway and
  printing "go here" is not a soft fallback but a trap: a branch checked out in a worktree **cannot**
  be checked out in the main copy, so the session would keep editing the main line under a policy
  that forbids exactly that. Fall back to today's branch and report the degradation → **D3**.
- **How does a run know whether it can move?** Not by asking itself. An agent asked "can you do X?"
  tends to answer yes — DRILL-109 measured two cold runners inventing a blessing nobody gave. Prove
  it from evidence instead, and undo on mismatch → **D4**.
- **Where do the folders live?** Inside the project (fixed path, no configuration) was rejected as
  too easy to pollute the repository with by accident. Outside, under a declared path → **D5**.
- **What if no path is declared?** Ask, with a suggestion. No answer → write nothing, fall back,
  report → **D6**.
- **How does the merge happen, when the main line is checked out in the main copy and cannot be
  checked out again in the worktree?** Drive the main copy from where you are, rather than moving
  first. If the main copy is dirty or not on the main line, that is a failed close, which the rules
  already define → **D7**.
- **Ordering at the end.** You cannot delete the folder you are standing in, and the branch cannot
  be deleted while a worktree still holds it. So the tail is fixed and worth writing down → **D8**.
- **Who else has to change?** A new declared field means the project-setup skill and the
  bring-an-existing-project-up-to-date skill both have to handle it, in the same change → **D9**.

## Out of scope (initial)

- **Worktrees inside the project folder** (`<repo>/wt/…`). Considered and rejected by the requester
  on pollution risk — see D5; it becomes a `removed` row so the ledger records the choice.
- **Tooling for the review-someone-else's-branch case.** It motivates the feature (D1) but needs no
  skill support — a person runs `git worktree add` by hand. The declared path serves it for free.
- **Parallel orchestration.** Making several tasks actually run at once is a separate question;
  this feature only stops the single working copy from being the thing that prevents it.
- **Changing `integration:`.** Untouched — see D2.

## Prototype

_Record the prototype decision explicitly — never leave it blank (see SKILL.md)._

**Skipped** (2026-09-24) — there is no visual or UX surface here, and the proof is a drill (install
the changed skills, run `pick` → `close` on a real project and watch the folder appear and
disappear — TASK-179). The one place a person is spoken to, the undeclared-path question (D6), has
its wording pinned verbatim in TASK-174 instead of a mock-up.

**Note for whoever writes that drill:** it cannot run in this repository. This repo declares
`integration: single-branch`, so `/tasks pick` never offers a branch here and the whole worktree
path is unreachable. The drill needs a `pr-per-task` consumer project.
