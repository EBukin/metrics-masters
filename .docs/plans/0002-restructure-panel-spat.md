# Restructure the spatial panel chapter for intuition

- **Date:** 2026-10-04
- **Author:** Eduard Bukin
- **Status:** active

## Goal

The spatial panel material reads as one progressive story. Each step asks a
plain question, explains the problem in a paragraph, runs one test, shows a
case where the test fires and a case where it does not, says how to read both,
and says where to go next. A reader can lift the code of any section and run it
on their own panel. Every existing result (and its book check) survives; only
its place and its framing change.

## Context

The user's request, verbatim:

> structure of this book is useless. And honestly, I have a very hard time
> reading it. I think that this is because it's really confused in terms of
> the location of the code and explanations. And the explanations themselves,
> they are way too complicated and not intuitive at all. [...] this book is
> meant for economists, but it's also meant to create an intuition, an easy to
> understand intuition of what the concepts are, of how do they interact
> together, and how do they change the result, and most importantly, what
> econometric methods we are supposed to use to understand better the results
> and to reveal the true cause of relationship. [...] I would like theory to be
> short and intuitive, and then it should give clear understanding of what is
> the problem of what econometrics are looking for when they want to resolve
> this problem. And what test they're using. How to use those tests and how to
> interpret the results of those tests. And once the results are that, where to
> go next? For every test and for most of the tests, we would like to reproduce
> positive and negative results and provide an intuitive interpretation based
> on this positive and negative results.

### What is wrong now

1. **One story, three places.** The spec (`.docs/panel-spat-PLAN.md`), the
   theory appendices (`theory/*.qmd`) and the examples split each idea. The
   reader jumps between an example and an appendix to understand one test.
2. **Ordered by the spec, not by the reader's question.** "Stage 0" mixes
   panel shape, the exponent α, an estimator (CCE) and then the CD test. The
   fix (CCE) comes before the diagnosis (CD) that motivates it.
3. **Software audit crowds out the idea.** Interface traps, `p.approx`,
   a `print` bug, `tbar` limits and refusals on unbalanced panels sit in the
   main text, at the same weight as the result.
4. **No fixed shape.** Sections open with "Theory", "Intuition" or a callout,
   and the decision ("so what do I do now?") is often missing or buried in the
   last paragraph.
5. **Positive and negative cases are uneven.** The CD section has reject /
   accept / misleading cases and reads well. Most other sections show one case.
6. **Plumbing repeated in the text.** `as_matrix()` is defined twice; DGP
   helpers live inline although `R/` exists for them.

## Proposed structure

Turn the single chapter into a **Part** of short chapters, one question each.
Order follows the work an applied economist does: see the problem, diagnose,
then estimate.

```
Part: Panels where units are not independent
│
├─ 1  Why it matters                    (hook + map)
│     One regression, two answers: house prices on income, FE says 0.30,
│     CCE says 1.14. Which is right, and how would you know?
│     Decision map of the whole Part (one flowchart).
│
├─ 2  Know your panel                   (N, T, balance)
│     Shape decides which tools are usable. N/T rule of thumb.
│     → next: 3
│
├─ 3  Do units move together?           (CD family)
│     + raw log house prices   → reject
│     − independent simulated panel → do not reject
│     ! two-way FE residuals   → "do not reject" that means nothing
│     → reject: 4.   do not reject (honestly): standard panel tools.
│
├─ 4  How strong is the co-movement?    (exponent α)
│     + raw prices, α ≈ 0.83   → strong: common factors
│     − CCE residuals, α ≈ 0.51 → weak: local / spatial
│     ! variable method on a rebased index
│     → strong: 5 (remove factors).   weak: spatial Part (later).
│
├─ 5  Do the series wander?             (panel unit roots)
│   5.1 Why it matters: spurious regression in one picture.
│   5.2 What "reject" means: one null, three alternatives.
│   5.3 Tests that assume independence (LLC, IPS, Maddala–Wu, Hadri)
│        + growth rates reject   − levels do not
│   5.4 Tests that allow a common factor (CIPS)
│        + differences reject    − levels do not
│   5.5 Which series? (Hanck / Simes)
│        + 10 of 19 exchange rates   − 0 of 49 states
│   5.6 When the tests lie: size under spatial dependence,
│        cross-unit cointegration (simulations, flagged unverified)
│     → I(1): 6 with a cointegration check.   I(0): 6 directly.
│
├─ 6  Removing common factors           (MG, CCEMG, CCEP)
│     + house prices: 0.30 → 1.14
│     − factor-free simulated panel: MG ≈ CCE (no harm done)
│     Did it work? CD and α on residuals; CIPS on residuals
│     (= cointegration check).
│     → residual dependence weak: spatial Part.   gone: done.
│
└─ 7  Summary: the map again, filled in with this data's answers.
```

Later stages of the spec (cointegration, error structure, static and dynamic
panels, spatial models) become later Parts, in the same template.

## Section template

Every test section has the same blocks, in this order. Only the first five are
in the main text.

1. **Question.** One sentence in plain words. "Do the states' house prices move
   together more than chance allows?"
2. **Intuition.** One short paragraph, a picture if it helps, at most one
   equation. What the problem does to an estimate.
3. **The test.** Null and alternative in words; what it is blind to.
4. **Run it.** The minimal call on the running example.
5. **Read it.** Positive case, negative case, and a misleading case where one
   exists, each with one or two sentences of reading. Then **Next**: "reject →
   section X, do not reject → section Y".
6. **Recipe** (callout). The code to copy for your own panel, nothing else.
7. **Pitfalls** (collapsed callout). Interface traps, software bugs, refusals.
8. **Book check** (collapsed callout). Output beside the published numbers,
   with pages.
9. **Going deeper** (link). The appendix note, for the math and the sources.

## Where things live

- **Chapter files** hold the story: blocks 1–6 above. A chapter must be
  readable without opening any appendix.
- **`R/`** holds plumbing only: `as_matrix()`, the DGP simulators, `rook_w()`,
  `as_pseries()`. Roxygen-documented, loaded with `devtools::load_all()`. Every
  test call stays in the open in the chapter.
- **`theory/`** appendices become optional "going deeper" notes: math, rate
  conditions, literature. Their intuition moves into the chapters.
- **`.docs/panel-spat-PLAN.md`** stays the implementation spec, unchanged.

## Steps

- [x] Agree the Part outline and the section template with the user.
- [x] Write the template as `.docs/_templates/section.qmd`.
- [x] Move plumbing helpers into `R/`, one topic per file (unit-root
  simulators and reshapers; Stage 0's `as_matrix()` still inline).
- [x] Pilot on chapter 5 instead of 3, at the user's request: unit roots are
  now `unit-roots.qmd`, rendered 2026-10-04. Review with the user.
- [ ] Rebuild chapters 1, 2, 3, 4, 6, 7 from the Stage 0 material.
- [ ] Add missing negative cases (CCE on a factor-free panel; first-generation
  rejection on a stationary panel).
- [ ] Trim appendices 01 and 07 to "going deeper" content.
- [ ] Update `_quarto.yml`, `index.qmd` checklist, and links.

## Open questions

- One chapter with seven sections, or a Part with seven short chapters?
  Taken as a Part: the user asked to implement the outline chapter by
  chapter.
- `renv/activate.R` hangs at startup on this machine (Rscript, mcp-repl and
  quarto alike). The render worked with `R_PROFILE_USER` pointing to a profile
  that only sets `.libPaths()` to the renv library. Cause not diagnosed.
- Keep the theory appendices, or fold them fully into the chapters?
  Recommendation: keep, trimmed to "going deeper".

## Outcome

