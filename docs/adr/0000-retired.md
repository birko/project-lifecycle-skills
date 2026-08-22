# Retired record numbers

Numbers are *allocated in order and never reused* ([[domain]] § Shape), so a withdrawn record leaves a
permanent gap. Without this ledger a reader meeting `0005, 0007` cannot tell whether `0006` was declined,
deleted, or lost — the same *decline out loud* failure the bar exists to prevent, one level up.

One line per retired number. This file is not a decision record and takes no number of its own.

| # | Was | Withdrawn | Why |
|---|---|---|---|
| 0006 | Decision record: independent review axes are reported side by side, never merged | 2026-08-22 | **Failed the bar's hard-to-reverse test.** Nothing durable was produced under it — unlike every surviving record, which stamped a field, migrated a tree, wrote a history, or deleted content. Found by a cold read of the directory, which noted the same test had been applied strictly to one candidate and leniently to this one. The reasoning was folded back into its `AGENTS.md § Conventions` bullet, which now names the failed test inline. |
| 0007 | Decision record: a vocabulary shared by several skills is expanded in place, never re-homed | 2026-08-22 | **Out of scope, not wrong.** A second cold read showed the hard-to-reverse test could not separate a project decision from a rulebook entry in a repo whose product is prose — it handed roughly half its verdicts back to the reader. The bar was rescoped to project decisions only. This is a rulebook entry: its footprint is a file that did not move, so there is no artifact outside the rulebook for a record to explain. Reasoning returned to its `AGENTS.md § Conventions` bullet, whole. |

## Why two retirements in one day

Both came from cold reads — fresh agents applying the rule with the author's verdicts withheld — and they
found the same thing twice: the bar's first test was written for architectural choices and cannot judge
prose. `0006` was withdrawn under a patched reading of that test; `0007` was withdrawn when the patch itself
failed and the test was replaced by a scope question (*project decision, or rulebook entry?*).

**Both retirements are correct under the current rule**, which is the check that matters — a rule change that
had to spare its own casualties would be special pleading. The five surviving records are all project
decisions: a stack choice, a repo layout, a per-repo policy, a schema, a strategy.
