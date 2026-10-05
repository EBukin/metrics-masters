# Restructure the spatial panel chapter for intuition

- **Date:** 2026-10-04
- **Author:** Eduard Bukin
- **Status:** superseded by .docs/plans/0005-chapters-layout.md

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

**Revised 2026-10-04** after the user's review of the unit-root pilot; the
instruction is quoted in `.docs/notes/0001-writing-standard.md`. The model is
*Mastering 'Metrics*: a relatable example first, a plain definition, just
enough math, economist vocabulary, short headers, and no term before it is
explained.

```
Part: Panel data
│
├─ Same data, two answers      FE says 0.30, CCE says 1.14. Why?
├─ Panel shape                 N, T, balance
├─ Common shocks               CD test; strength (α)
├─ Unit roots                  pilot, see below
├─ Removing common shocks      MG, CCEMG, CCEP
└─ Map of the Part             one page, written last
```

The unit-root chapter, revised:

```
Unit roots
  Opening    After the 2006 peak, prices in some states fell by a third.
             Do they come back to their old path, or is the loss
             permanent? That is the unit-root question.
  Definition A series has a unit root when a shock never fades: today's
             value carries all of yesterday's, y_t = ρ y_{t-1} + ε_t with
             ρ = 1. With ρ < 1 a shock dies out, half of it in a known time.
  1 The idea          picture: random walks vs stationary; half-life
  2 Why it matters    spurious regression (57% vs 3.5%); define
                      cointegration here: two wandering series tied by a
                      stable long-run link
  3 One series        Dickey–Fuller on one state: too few years to tell
  4 Many series       pool the states: LLC, IPS, Maddala–Wu, Hadri;
                      levels vs growth rates; what a rejection means
  5 Common shocks     one-line gloss of CD + link; CIPS
  6 Which states      Hanck / Simes
  7 When tests mislead  panel shape, spatial spillovers, shared trends
  8 Bottom line       numbered points, no flowchart
  9 Under the hood    pitfalls, book checks, link to theory note 07
```

Pictures, one or more per section, each a different kind:

| Section | Picture |
|---|---|
| The idea | random walks vs stationary series; one shock's decay at ρ = 1, 0.9, 0.5 |
| Why it matters | two independent random walks with a fitted line; t statistics in levels vs differences against ±1.96 |
| One series | Dickey–Fuller distribution against the normal |
| Many series | 49 states' log prices vs their growth rates; per-state ADF *t* against its null |
| Common shocks | state growth rates with the cross-state average on top |
| Which states | sorted p-values against the Simes / Hommel line |
| When tests mislead | size against N/T and against λ; a shared-trend pair vs a correlated pair over time |

Math per test: the regression, the statistic, and its null distribution
where each helps (e.g. ADF regression, IPS *t̄*, Maddala–Wu
−2Σ ln pᵢ ~ χ²₂N, the CADF regression and CIPS).

## Chapter template

`.docs/_templates/chapter.qmd`:

1. **Title.** A few plain words: the term itself.
2. **Opening.** One or two paragraphs of a relatable economic example.
3. **Definition.** One plain sentence: what it is, why it matters.
4. **In this chapter.** A numbered list of points, not a flowchart.
5. **Sections**, one idea or one test each (template below).
6. **Bottom line.** Numbered points: what the running example showed and
   what to do with your own data.
7. **Under the hood.** Pitfalls, book checks, recipes, the theory-note link.

## Section template

`.docs/_templates/section.qmd`, for each test:

1. **Header.** A few plain words.
2. **The question** in the running example's words, one sentence.
3. **How it works.** One paragraph of intuition, at most one small equation.
   New terms bold where defined; terms from other chapters glossed in one
   line with a link back.
4. **The test.** Name, null in words, what a rejection means in words.
5. **Run it.** The call, in the open.
6. **Read it.** Rejects / does not reject / misleads (only if there is one),
   each with its number and a one-sentence *So:* implication.
7. **Next.** Where each result sends the reader.

Between 4 and 6: **Show it**, a picture of the evidence. Math in 3 and 4 may
run to several equations when each one tells part of the story.

## Where things live

- **Chapter files** hold the story. A chapter must be readable without
  opening any appendix.
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
- [x] Revise the outline and the templates after the user's review
  (`.docs/notes/0001-writing-standard.md`).
- [ ] Rewrite `unit-roots.qmd` to the revised template.
- [ ] Rebuild the other chapters of the Part from the Stage 0 material.
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

