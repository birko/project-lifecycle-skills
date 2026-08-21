# Refactor Candidates

**The project's own smell inventory — one list, read by several skills.** Written for the refactor step
of a TDD cycle, and also the baseline [[verify-conventions]] applies when a repo has recorded no
conventions of its own. Don't copy these rows into another skill; point at this file. A second copy goes
wrong silently the moment a row is added here.

Every row is a **judgement call, not a violation.** Each names an observable signal so a reader can check
the call rather than take it on trust, and a suggested move — the signal is what you saw, the move is
only a suggestion.

| Smell | Observable signal | Suggested move |
|---|---|---|
| **Mysterious name** | a name that needs the body read to understand, or that says *what it is* (`data`, `manager`, `helper`, `info`) rather than what it does | rename to the question it answers |
| **Duplicated code** | the same shape in two places, where changing one means remembering the other | extract a function or class |
| **Long method** | a body you must scroll, or one whose steps sit at several levels of abstraction at once | break into private helpers; keep tests on the public interface |
| **Feature envy** | a function that reaches through another object for most of what it needs | move the logic to where the data lives |
| **Data clumps** | the same three or four parameters travelling together through several signatures | make them one object |
| **Primitive obsession** | a domain concept carried as a string, int or bare map, with validation repeated at every use | introduce a value object |
| **Repeated switches** | the same `switch`/`if` chain over the same type in several places, so adding a case means finding them all | polymorphism, or one lookup table |
| **Shotgun surgery** | one behavioural change forces edits across many files | pull the scattered pieces into one module |
| **Divergent change** | one module changes for several unrelated reasons | split it along those reasons |
| **Speculative generality** | an abstraction, hook or parameter with exactly one caller and no second in sight | inline it until a second case is real |
| **Message chains** | `a.b().c().d()` — the caller must know the shape of things it does not own | ask the first object for what you actually want |
| **Middle man** | a class whose methods all delegate straight through | let callers talk to the real thing |
| **Refused bequest** | a subclass that inherits state or behaviour it does not want and overrides to no-ops | prefer composition, or push the shared part down |
| **Shallow module** | an interface nearly as complex as the implementation it hides | combine or deepen |
| **Existing code the new code reveals as problematic** | the change you just made was awkward *because* of something already there | fix the cause, or file it — see [[tasks]] `spawn` |
