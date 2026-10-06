# Deep Modules

From "A Philosophy of Software Design":

**Deep module** = small interface + lots of implementation

```
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
│                     │
└─────────────────────┘
```

**Shallow module** = large interface + little implementation (avoid)

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

When designing interfaces, ask:

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?

## The deletion test

Run it on anything you suspect is shallow before calling it a problem. A small module is not a defect by itself.
It applies to a module that **does** something. A type that only mirrors a data shape (a config section, a DTO,
a wire format) hides no behaviour, so the test has nothing to judge and it is never a finding here.

**Signal:** an interface nearly as complex as its body, or methods that all delegate straight through (the
*Shallow module* and *Middle man* rows in [refactoring.md](refactoring.md)).

**Test:** inline the module into each of its callers, on paper, and compare the **total** logic before and after.
Judge the total, not caller by caller, so a module whose logic reappears at only some of its callers is still
judged once.

| Outcome | What you see after inlining | Record |
|---|---|---|
| **Concentrates** | the total shrinks: pass-through calls, workarounds or duplicated handling disappear | a finding: delete or merge it |
| **Merely moves** | the total stays the same, or grows because several callers each carry a copy | not a deletion finding. If the interface is still nearly as complex as the body, deepen it (the *Shallow module* row's other move) |

**One caller:** if the total shrinks, it concentrates, as above. If it merely moves, the table cannot judge it,
because a single caller never carries a second copy. That case is the *Speculative generality* row in
[refactoring.md](refactoring.md), and that row decides.

**Record a "merely moves" result where the next review will read it:** in the review's own record, such as the
list of findings dropped at intake, with the callers you checked. Never record it in a code comment, which would
be a QA log.
