# Retired record numbers

Numbers are *allocated in order and never reused* ([[domain]] § Shape), so a withdrawn record leaves a
permanent gap. Without this ledger a reader meeting `0005, 0007` cannot tell whether `0006` was declined,
deleted, or lost — the same *decline out loud* failure the bar exists to prevent, one level up.

One line per retired number. This file is not a decision record and takes no number of its own.

| # | Was | Withdrawn | Why |
|---|---|---|---|
| 0006 | Decision record: independent review axes are reported side by side, never merged | 2026-08-22 | **Failed the bar's hard-to-reverse test.** Nothing durable was produced under it — unlike every surviving record, which stamped a field, migrated a tree, wrote a history, or deleted content. Found by a cold read of the directory, which noted the same test had been applied strictly to one candidate and leniently to this one. The reasoning was folded back into its `AGENTS.md § Conventions` bullet, which now names the failed test inline. |
