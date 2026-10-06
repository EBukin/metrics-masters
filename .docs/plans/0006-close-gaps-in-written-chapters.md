# Close the gaps in the written chapters

- **Date:** 2026-10-05
- **Author:** Eduard Bukin
- **Status:** done

## Goal

Every written step reads the way chapter 04 (time dependence) reads: a
question in the running example's words, one paragraph of intuition, the
test in words, the call in the open, a picture of the evidence, a reading of
each result in one sentence, and a "Next" box; recipe, pitfalls and book
check sit in collapsed boxes at the end. Theory notes are named, not
numbered. No term is used before its one-line gloss. R starts in the project
without environment overrides, `splm` and `spdep` are installed, the CCE
theory note is written, and the book renders from a clean cache with the same
book-check numbers as before.

## Context

Plan 0005 moved the book into `chapters/`. An audit of the written material
against `.docs/notes/0001-writing-standard.md` and the section template
found these gaps.

**Tooling.**

- R hangs at startup in this project. Cause: renv's sandbox waits on a lock
  in `AppData/Local/R/cache/R/renv/sandbox/windows/R-4.6/...`, and a lock
  left by a killed R process is never released. With the sandbox disabled R
  starts in 6 s.
- The project library resolves to the user cache (plan 0005's open
  problem). Cause: `renv/activate.R` treats a project with a `DESCRIPTION`
  file as a package and moves its library to the user directory. Fix:
  `RENV_PATHS_LIBRARY` set in `.Rprofile` before `renv/activate.R` runs.
- `.Rbuildignore` (needed by `devtools::load_all()`) is untracked.
- `splm` and `spdep` are not installed; chapter 03 needs both.

**Format.** Chapters 01 and 02 were written before the writing standard.
Their steps open with **Theory** and an equation, have no question, no
picture, no "read it" bullets and no "Next" box. Chapter 04 has all of
these. The section template says pitfalls and book checks go to an "Under
the hood" section; chapter 04, the latest and fullest chapter, puts them in
collapsed boxes at the end of each step. The boxes win: the template changes
to match.

**Pictures.** Rule 7 of the writing standard: every idea and every test gets
visual evidence. Missing in 01 (shape), 02 (all three steps) and 04 (steps 3,
4, 5, 6). The road map and 04 steps 1 and 2 have one each.

**Terms before their gloss.** Rule 4. `Within estimator`, `GLS`, `variance
components`, `asymptotics` (01); `Dickey–Fuller regression` (04-3), `I(1)`
and `I(0)` (04 map and summary), `defactor`, `within transformation`,
`loadings` (02); `SAR / SEM` and `I(1)` in the road map diagram; the
refinements CDw, PEA and CD\* introduced by their mechanics before CD itself
is read (02-1).

**Names.** Theory note subtitles still say "Theory note 01" to "07", the
numbers of the old `theory/` folder, and link texts say "theory note 01".
The sidebar lists them as unnumbered appendices under "Theory".

**Headings.** "Exponent of cross-sectional dependence α", "Testing for
cross-sectional dependence" and "Panel dimensions, balance, variation" are
longer than the standard's "few plain words". Anchors stay, titles shorten.

**Thin step.** 01-shape never runs `pdim` on the running example, and shows
no variation (`pvar`) though its title promises it.

**Theory note.** `theory-common-factors-cce.qmd` is a placeholder; three
steps and the road map link to it.

## Steps

Each step ends in its own commit.

- [x] **Tooling.** `.Rprofile` sets `RENV_PATHS_LIBRARY` and disables the
  sandbox, with a comment saying why. Commit `.Rbuildignore`. Install
  `splm` and `spdep` with `renv::install()`, then `renv::snapshot()`. Note
  in plan 0005's outcome that the cause is found.
- [x] **Templates.** `section.qmd`: collapsed Recipe, Pitfalls and Book check
  boxes at the end of a step, replacing the "Under the hood" note.
  `chapter.qmd`: includes `summary` instead of `bottom-line` and
  `under-the-hood`. `theory.qmd`: subtitle is one line on what the note
  covers, no number.
- [x] **Theory note names.** Subtitles without numbers in all seven notes.
  Every link text "theory note NN" or "note NN" becomes the note's short
  name. "Code:" lines in the notes link steps by anchor.
- [x] **01 Panel shape.** Rewrite `1-shape.qmd` on the template: question,
  intuition, `pdim` on `HousePricesUS` first, then `TobinQ` and `Tileries`;
  `punbalancedness`; `pvar` on the running example; a coverage picture of
  `Tileries` (which tile works are observed which weeks); read it; next;
  boxes. Gloss "within" and "GLS" or drop them. Heading "Panel shape".
- [x] **02-1 The CD test.** Reorder: question, intuition (the average of the
  1 176 pairwise correlations), the test, run CD on prices, a histogram of
  the pairwise correlations for raw prices, the iid panel and the two-way
  FE residuals, read it (rejects / does not reject / misleads), then the
  three refinements as a second part with their own table and calls; next;
  boxes with recipe, pitfalls, book check. Heading "The CD test".
- [x] **02-2 The exponent α.** Question first; intuition before the
  equation; a picture of $\log\operatorname{Var}(\bar z_t)$ against
  $\log N$ for random subsets of states, raw prices against CCEMG
  residuals, whose slope is $2(\alpha-1)$; gloss CCEMG and "defactor" with
  a link forward; move "where the variable method breaks" and the SE
  warning into Pitfalls; next; boxes.
- [x] **02-3 CCE.** Question, intuition in the example's words (add the
  cross-state average as a regressor), the estimator in two equations, run
  it, a picture of the 49 state slopes under MG and under CCEMG with their
  means, read it, next; boxes with recipe and book check.
- [x] **CCE theory note.** Write `theory-common-factors-cce.qmd` on the
  theory template: why averages proxy the factors (the averaged equation),
  heterogeneous loadings against two-way FE, CCEMG and CCEP, the rank
  condition and what CCE does not fix, if/then, next. Tick it in the
  checklist.
- [x] **04 glosses and pictures.** Gloss Dickey–Fuller in 04-3 and I(1)/I(0)
  in the chapter intro. Pictures: 04-3 the 49 per-state ADF *t* statistics
  in levels and growth rates; 04-4 per-state ADF against CADF *t*
  statistics; 04-5 the sorted p-values against Simes' line; 04-6 size
  against λ by test.
- [x] **Road map.** Diagram boxes in plain words ("wanders / does not
  wander", "spatial lag / spatial error"); gloss "loadings".
- [x] **Render and check.** Clear `_freeze/` and `_book/`, render in full,
  read the log, compare every number quoted in prose with the output it
  quotes. Update the checklist titles in `index.qmd`. Fill in the outcome.

## Open questions

- Implicit `renv::snapshot()` records only packages the project's code uses.
  If `splm` and `spdep` are not recorded until chapter 03 calls them, say so
  in the outcome.

## Outcome

Done on 2026-10-05. A full render from a clean `_freeze/` and `_book/`
builds 15 pages with no R errors, no unresolved citations and no dead links
or anchors. The book checks print the same numbers as before: CD z = 53.26,
CCE 1.135 and 1.199, CIPS −2.0342 and −1.8199, Maddala–Wu 14.719, the
`pdim` lines of `TobinQ` and `Tileries`.

- R starts in the project in 6 s with no environment override. The stale
  sandbox lock was removed by hand once; `.Rprofile` keeps the library in
  `renv/library` and skips the sandbox from now on. The MCP R sessions
  started before the fix are stuck on the old hang and need a restart of
  Claude Code.
- `splm` 1.6-5 and `spdep` 1.4-2 are installed in `renv/library`. The
  implicit `renv::snapshot()` does not record them until a chapter calls
  them, so `renv.lock` is unchanged; snapshot again when chapter 03 is
  written.
- Nine pictures were added: `Tileries` coverage (01); the 1 176 pairwise
  correlations, the variance of the cross-state average against N, the 49
  state slopes under MG and CCEMG (02); per-state Dickey–Fuller statistics,
  ADF against CADF, Simes' sorted p-values, size against λ (04).
- The variance-against-N picture gives α = 0.85 on log prices and 0.47 on
  the CCEMG residuals from its slope alone, next to 0.83 and 0.51 from the
  residual method: a second, independent reading of the exponent.
- Rewrapping the cross-sectional dependence theory note showed that it was
  written at 82 characters; it is now at 80.
- Not done: clicking through the pane links by hand in a browser.
