# /feature prototype — build an interactive prototype for stakeholders

Produce something a stocktaker or project manager can look at and react to, so decisions get made against a concrete artifact instead of a description.

## Steps

1. **Locate the feature** — `docs/features/FEATURE-NNN-slug/`. Read `idea.md` + `decisions.md` so the prototype reflects the proposed/approved decisions.

2. **Decide the form (per-feature — ask each time):** use `AskUserQuestion` with these options unless the user already named one:

   | Form | Produces | Best when |
   |------|----------|-----------|
   | **HTML mockup** | self-contained `prototype.html` (clickable, opens in a browser) | UI/UX feature; stakeholder needs to *see and click* a flow |
   | **Markdown wireframe** | `prototype.md` (ASCII/markdown wireframes + user-flow narrative) | layout/flow can be conveyed in text; fastest; diff-friendly |
   | **Code spike** | a throwaway/feature-flagged branch in the real app | the risk is technical feasibility, not look-and-feel; stakeholder runs the real app |

3. **Build it:**
   - **HTML mockup** — write `prototype.html` in the feature folder. Self-contained (inline CSS/JS, no build step). If the project ships a component library / design system (check `CLAUDE.md § Conventions → UI/UX`; a team may also install a component-catalogue skill), use its components so the mockup matches the real design language; otherwise plain semantic HTML. Make the key interactions clickable; stub data is fine. Add a banner noting "PROTOTYPE — not wired to real data."
   - **Markdown wireframe** — write `prototype.md`: one wireframe block per screen/state, plus a numbered user-flow walkthrough and the edge cases the stakeholder should weigh in on.
   - **Code spike** — create a branch (`spike/feature-NNN-slug`), keep it behind a flag, do the minimum to demonstrate. Record the branch name in the feature folder (a short `prototype.md` pointing at it) — don't merge it.

4. **Tie prototype choices back to decisions** — if building the prototype surfaced a new branch or made one obviously wrong, add/flag it in `decisions.md` (state stays `proposed`; note it in the History log). The prototype is itself a decision-discovery tool.

4b. **Update the `## Prototype` line in `idea.md`** — this verb *is* the prototype decision, so
   record it: rewrite the line to `**Built** — <relative link to prototype.html / prototype.md / the
   spike branch name>`. (For a regenerated v2, point at the latest and keep the prior per step's
   edge case.) Whether you prototype is an explicit, recorded choice — leaving the line at its
   template placeholder after building one makes an absent line read as an omission, not a
   decision. If you (or the user) deliberately *skip* prototyping instead of running this verb,
   that line is set to `Skipped — <reason>` at `/feature new`/`decide` time, not here.

5. **Confirm + next step:**
   - HTML: "Open `docs/features/FEATURE-NNN-slug/prototype.html` in a browser and demo it."
   - "After the stakeholder reacts, stamp verdicts with `/feature decide FEATURE-NNN`."

## Edge cases

- **Re-prototype after a `changed` decision** — fine to regenerate; keep the previous artifact if the stakeholder wants to compare (`prototype-v2.html`), and note it in the History log.
- **No browser available to the stakeholder** — steer toward markdown wireframe.
- **Don't gold-plate** — a prototype exists to provoke decisions, not to be production code. Stub freely; label clearly.
