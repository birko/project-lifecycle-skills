# /feature prototype — build an interactive prototype for stakeholders

Produce something a project manager or end user can look at and react to, so decisions get made against a concrete artifact instead of a description.

## Steps

1. **Locate the feature** — `docs/features/FEATURE-NNN-slug/`. Read `idea.md` + `decisions.md` so the prototype reflects the proposed/approved decisions.

2. **Decide the form (per-feature — ask each time):** use `AskUserQuestion` with these options unless the user already named one:

   | Form | The question it answers | Produces | Best when |
   |------|------|----------|-----------|
   | **HTML mockup** | *what should this look like?* | self-contained `prototype.html` (clickable, opens in a browser) | UI/UX feature; stakeholder needs to *see and click* a flow |
   | **Markdown wireframe** | *what should this look like?* | `prototype.md` (ASCII/markdown wireframes + user-flow narrative) | layout/flow can be conveyed in text; fastest; diff-friendly |
   | **Code spike** | *can this be built?* | a throwaway/feature-flagged branch in the real app | the risk is technical feasibility, not look-and-feel; stakeholder runs the real app |
   | **State-model playground** | *does this state model feel right?* | one self-contained `prototype-states.html` that drives the proposed states and transitions | the feature adds or changes states (statuses, a workflow, a lifecycle); the risk is a transition nobody thought through, which neither a picture nor prose shows |

3. **Build it:**
   - **HTML mockup** — write `prototype.html` in the feature folder. Self-contained (inline CSS/JS, no build step). If the project ships a component library / design system (check `CLAUDE.md § Conventions → UI/UX`; a team may also install a component-catalogue skill), use its components so the mockup matches the real design language; otherwise plain semantic HTML. Make the key interactions clickable; stub data is fine. Add a banner noting "PROTOTYPE — not wired to real data."
   - **Markdown wireframe** — write `prototype.md`: one wireframe block per screen/state, plus a numbered user-flow walkthrough and the edge cases the stakeholder should weigh in on.
   - **Code spike** — create a branch (`spike/feature-NNN-slug`), keep it behind a flag, do the minimum to demonstrate. Record the branch name in the feature folder (a short `prototype.md` pointing at it) — don't merge it.
   - **State-model playground** — write `prototype-states.html` in the feature folder. It must be a **single file that opens in a browser with nothing installed**: inline CSS/JS, no build step, no server, no framework download. That is a constraint, not a style: the output is the reaction of someone who cannot run the code, so a playground that needs a dev environment never reaches the person whose answer is the whole point. When the runtime can publish a file as a private shareable page, publish it and send the link. It carries **both** of these, because each finds what the other cannot:
     - **Free play:** the current state shown plainly, one control per transition from it (unavailable ones visible but disabled, with the reason), and a reset. It finds the case the author did not think of.
     - **Guided walkthroughs**, one tab each: a named scenario that steps the model through a case that is hard to reason about on paper, ending with a question to the stakeholder (*"Should this be allowed from here?"*). They cover the cases the author knows are hard.

     **Pick walkthrough cases for difficulty, never to demo the happy path.** Candidates:

     | Case | Why it is hard on paper |
     |---|---|
     | A transition from a state people rarely reach (an error, a hold, an edge) | nobody walks it in a spec review |
     | Going back: undo, reopen, cancel mid-way | reverse paths are where models quietly lose data |
     | Two actors acting on one item | each path is fine alone; the interleaving is not |
     | A container whose children change state (a parent's status versus its children's) | rollup rules are invisible until one contradicts |
     | A terminal state, and what may still happen after it | "done" that can be undone is a design choice someone must make |

     Draw them from the decisions being tested: each walkthrough names the decision row it exercises. Label the page "PROTOTYPE — a model of the proposed states, not the product."

4. **Tie prototype choices back to decisions** — if building the prototype surfaced a new branch or made one obviously wrong, add/flag it in `decisions.md` (state stays `proposed`; note it in the History log). The prototype is itself a decision-discovery tool.
   **The output of every form is the stakeholder's reaction, not the file.** Record each reaction where
   decisions go: a History line in `decisions.md` naming the row it bears on, quoting the reaction, and
   saying which form produced it. A reaction left in a chat or on the prototype is lost when the prototype
   is deleted, which it will be.

4b. **Update the `## Prototype` line in `idea.md`** — this verb *is* the prototype decision, so
   record it: rewrite the line to `**Built** — <relative link to prototype.html / prototype.md / the
   spike branch name>`. (For a regenerated v2, point at the latest and keep the prior per step's
   edge case.) Whether you prototype is an explicit, recorded choice — leaving the line at its
   template placeholder after building one makes an absent line read as an omission, not a
   decision. If you (or the user) deliberately *skip* prototyping instead of running this verb,
   that line is set to `Skipped — <reason>` at `/feature new`/`decide` time, not here.

4c. **Update this feature's row in the index** — `docs/features/README.md`: fill the Prototype
   column with the artifact link and let the Phase column read `prototyping`. Same single-row
   pattern as new.md's 6b — full regeneration stays `/feature status`'s job, but the index must
   never show `Prototype: —` for a feature whose prototype exists.

5. **Confirm + next step:**
   - HTML: "Open `docs/features/FEATURE-NNN-slug/prototype.html` in a browser and demo it."
   - "After the stakeholder reacts, stamp verdicts with `/feature decide FEATURE-NNN`."

## Throwaway discipline — all four forms

**A prototype answers its question and is then deleted.** Do not architect it, do not polish it, do not
wire it into the product. A prototype that survives becomes a second implementation nobody maintains,
and it goes on answering a question that has since been decided differently.

- **When:** once `/feature decide` has stamped every row the prototype was built to test. Delete it in
  that change: remove `prototype.html` / `prototype.md` / `prototype-states.html`, and delete the spike
  branch (`git branch -d`, and the remote copy if one was pushed).
- **What remains:** the reactions in `decisions.md` (step 4), any snippet admitted under
  [decide.md](decide.md)'s prototype-derived exception, and the recorded line in `idea.md`,
  rewritten to `**Built, then deleted** — answered D<n>, D<m>; last version at <commit>`. Git history
  still holds the file for anyone who needs it; nothing in the repo links to it.
- **A copy shared with a stakeholder cannot be recalled.** A sent file or a published page is dead from
  the deletion on: no updates, and not a source for anything. Unpublish it if the runtime allows; if not,
  say so in the History line, so a later reaction to that stale copy is recognised as stale.
- **Re-prototyping after deletion** builds a new artifact from the current decisions. It is never a
  restore of the old one, which answered a different set.

## Edge cases

- **Re-prototype after a `changed` decision** — fine to regenerate; keep the previous artifact if the stakeholder wants to compare (`prototype-v2.html`), and note it in the History log.
- **No browser available to the stakeholder** — steer toward markdown wireframe.
- **Don't gold-plate** — a prototype exists to provoke decisions, not to be production code. Stub freely; label clearly.
