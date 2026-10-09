# UX Baseline

**The project's own interaction-design inventory: one list, read by several skills.** [[verify-conventions]]
applies it to UI files as the second half of its baseline, after the repo's own rules. [[feature]]'s
`prototype` verb uses it to question a mockup before a stakeholder sees it. Don't copy these rows into another
skill. Point at this file instead, because a second copy goes wrong silently the moment a row is added here.

Every row is a **judgement call, not a violation.** Each one names a signal you can see in a diff, so a reader
can check the call instead of trusting it. Each one also gives a suggested move, which is only a suggestion.
**A rule the repo recorded always wins.** If a repo's guide says *"every delete asks for confirmation"*, the
first row does not apply there.

**Why these are heuristics and not rules:** the first rows come from published guidance that carries no
measured outcomes, mainly Nielsen's heuristics on user control and error recovery, Google PAIR on feedback
loops, the Center for Humane Technology on defaults, and Smashing Magazine's *"The Death of the Button"*
(2026-09). They are good questions to ask. They are not settled answers.

| Heuristic | Observable signal | Suggested move |
|---|---|---|
| **Confirm guarding a reversible action** | a confirmation dialog in front of an action the system can take back: a soft delete, an archive, a status change, an edit, a reorder | do it at once, and give the success feedback an **Undo** for a few seconds. The undo must be real: a soft delete or a delayed commit, never a toast offering what the backend cannot do |
| **High-stakes action with no gate** | one click, with no confirm and no undo, that moves money, publishes to people outside the app, changes permissions, privacy or sharing, or destroys data for good | confirm explicitly. This is the case confirmation exists for |
| **Confirmation that names nothing** | *"Are you sure?"* with **OK / Cancel** or **Yes / No**, when the dialog could name the object and what happens to it | say the object and the consequence (*"Send 3 invoices to 3 customers?"*), and put the verb on the button (**Send invoices**) |
| **Field the system could have filled** | a new form field left empty although its value is already known: the current user, the organisation or tenant, today's date, the parent record's value, the last value used, the only valid option | prefill it from that context, and keep it editable |
| **Default that serves the product, not the user** | a pre-ticked opt-in (marketing, sharing, tracking), a paid add-on selected by default, the most expensive tier preselected | default to what the user would pick without being nudged, and leave opt-ins unticked |
| **Interpretation the user cannot see** | results, a filter, an inferred value or an automated action applied with no sign of what was understood: a list that doesn't repeat its active filters, an auto-filled value that looks typed, an assistant acting without saying what it took the request to mean | state the reading (*"Showing 12 unpaid invoices from October"*, *"Searching non-stop flights"*) next to the way to correct it |
| **Automation with no record and no stop** | work done for the user out of sight (auto-apply, scheduled send, sync, an agent step) with no visible trace, no undo and no way to stop it | leave a history entry, offer undo where it is possible, and say plainly what it does without asking and what it never does |
| **A step asking for what is already known** | a wizard or multi-step form whose step asks for a value an earlier step, the context or the record already holds | drop the step or prefill it, and ask only for what cannot be inferred |
