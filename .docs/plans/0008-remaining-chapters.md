# Write the remaining chapters: core models, dynamic panels, cointegration

- **Date:** 2026-10-06
- **Author:** Eduard Bukin
- **Status:** active

## Goal

Every element of `.docs/panel-spat-PLAN.md` that is still unwritten has a
home in the book: Stage 2 (cointegration) as two more steps and a theory note
in `chapters/04-time/`; Stage 3 and Stage 4a (poolability, slope
homogeneity, heteroskedasticity, serial correlation, effects tests, fixed
against random effects, robust standard errors) as `chapters/05-core/`;
Stage 4b (dynamic panels) as a new `chapters/06-dynamic/`. Each chapter reads
the way chapters 03 and 04 read, carries every book check the spec names,
states every gap as a limitation, and is backed by the literature in the way
set out below. The outline note records the structure, `_quarto.yml` lists
the new pages, the checklist in `index.qmd` is ticked, and the whole book
renders from a clean `_freeze/`.

## Context

**What exists.** Chapters 00 to 03 are written in full. Chapter 04 covers
Stage 1 (1.1 to 1.6, including the spatial size and cross-cointegration
traps). `chapters/05-core/index.qmd` is a placeholder with six inbound
links. Plan 0007 closed with one task left: a full-book render from a clean
`_freeze/`.

**What remains, by spec section.**

| Spec | Chapter | Canonical data | Verification target |
|---|---|---|---|
| 2.1 precondition (per-unit rank) | 04 | HPUS | `?ca.jo` Johansen examples |
| 2.2 residual-based tests | 04 | HPUS | `?pedroni99m` example (weak) |
| 2.3 long-run estimation | 04 | HPUS | CM §8.4.3 CCE + CIPS |
| 3.1 poolability | 05 | GRUN, HPUS | B p. 81; CM §8.2.3 |
| 3.2 slope homogeneity | 05 | — | none in R: limitation |
| 3.3 heteroskedasticity | 05 | PROD, GRUN | `?vcovHC`, `?pggls`; CM §5.2.2 |
| 3.4 serial correlation | 05 | GRUN, PROD, EMPL | B Table 5.3 p. 129; CM §4.3 |
| 4a.1 effects tests | 05 | GRUN | B Table 4.3 p. 89 |
| 4a.2 FE vs RE | 05 | GRUN, WAGE | B p. 99 χ²₂ = 8.842; `?pht` |
| 4a.4 robust SEs | 05 | PROD | vcov help pages; Millo 2017 |
| 4b.1 the problem | 06 | simulation | Nickell 1981 Table 1 |
| 4b.2 estimators | 06 | EMPL | AB 1991 Table 4(b) via `?pgmm` |
| 4b.3 diagnostics | 06 | EMPL | Windmeijer 2005 Table 2 via `?mtest` |

**Checked on 2026-10-06** in the project renv, R 4.6.1: plm 2.6.7 exports
every function the spec names for these stages; all nine plm datasets are
present; `urca` is installed; `pco`, `pdynmc`, `sphet` and `Westerlund` are
not. `renv::status()` reports the project in a consistent state once
`.Rprofile` has been sourced; an R session started without it resolves to
the user cache and sees no packages at all.

**Structure.** Decided on 2026-10-06 and recorded in
`.docs/notes/0002-book-outline.md`: serial correlation joins the core
chapter, dynamic panels become chapter 06, cointegration extends chapter 04.
Writing order is core, dynamic, cointegration, by verification value.

**Literature in `lit/`.** The four anchor texts are on disk as PDFs:
Baltagi (2021), Croissant & Millo (2019), Pesaran (2015), Millo & Piras
(2012). The `Read` tool opens a PDF by page range, so a page reference can
be checked before it is cited.

## Rules for this plan

Three instructions from 2026-10-06 bind every chapter here; the note quotes
them verbatim.

### Literature, rigorously

Flagged by the user: every chapter "properly backed by literature, so it
uses literature rigorously and references it properly."

1. Every claim about a test or estimator (its null, its alternative, a rate
   condition, a size or power result, a reported number) carries a citation
   with a page, `[@key, p. X]`, from `references.bib`.
2. A page number is checked against the PDF in `lit/` before it is cited.
   A page that cannot be checked is not cited; the original paper is cited
   without a page instead.
3. The original paper is cited beside the anchor text: the test's own paper
   for its definition, the anchor for the exposition and the page.
4. Every bibliography entry added is complete (authors, year, title,
   journal, volume, number, pages, DOI where one exists) and checked
   against the anchor book's reference list or the publisher's page. No
   entry is written from memory alone.
5. A book check names the table or example and its page. A number that
   does not reproduce is reported as not reproduced, with both values.
6. A review pass per chapter opens every cited page and confirms that it
   supports the sentence that cites it.

### One chapter, one pipeline of fresh agents

Flagged by the user: "every single chapter is written by a different
subagent, with a sufficient context in the right context to focus on", and
no agent "overloaded with the context".

Each chapter is produced by a pipeline of separate agents, each started
fresh with a bounded brief and nothing else:

| Agent | Brief | Produces |
|---|---|---|
| Recon | the spec slice, the datasets, R access | every spec call run on canonical data; targets matched; the chapter plan (`0009`, `0010`, `0011`) drafted on the plan template with the detail of plan 0007 |
| Tooling | the chapter plan's bibliography and helper lists | checked `references.bib` entries, roxygen-documented `R/` helpers, packages installed and `renv.lock` snapshotted |
| Writer | the chapter plan, templates, writing standard, one exemplar step, the spec slice | `index.qmd` and the steps, every chunk run, every number in prose taken from output |
| Theory | the chapter plan, the theory template, one exemplar note, the PDF pages | the theory notes |
| Review | the chapter files, the PDFs, the rules above | a findings list: citations against pages, numbers against output, style and link checks |
| Fix | the findings list | the fixes, nothing else |

The brief names files to read and page ranges to open. No agent receives
the whole spec, another chapter's plan, or this session's history. The main
session orchestrates: it writes the briefs, commits after each agent,
retargets inbound links, edits `_quarto.yml` and the checklist, renders,
and closes each chapter plan with its outcome.

### Stata benchmarks: deferred

Flagged by the user: "not necessary right now, keep it planned for later."
Spec §3 names Stata as the nearest benchmark for Pesaran–Yamagata Δ
(`xthst`), Kao (`xtcointtest kao`), Breitung (`xtunitroot breitung`) and the
dynamic spatial panel (`xsmle`). StataNow 19 is installed at
`C:\Program Files\StataNow19` and a Stata MCP server is configured. In this
plan those four elements are stated limitations, each with a line
"Benchmark: Stata `...`" in its Pitfalls box. A later plan hand-codes the
statistic in `R/`, runs the Stata command from `code/`, and matches to three
significant figures or declares the element unverified.

## Chapters

The chapter plans written by the recon agents fix the running examples, the
step list and the numbers. What follows is the brief they start from.

### `05-core`, core panel models (plan 0009)

Spec 3.1 to 3.4, 4a.1, 4a.2, 4a.4. Grunfeld carries the Baltagi book checks;
`Produc` the vcov help-page checks; `Wages` the Hausman–Taylor check; house
prices run alongside where CM do (§8.2.3 poolability and `pvcm`, §5.1.3.1
robust Hausman). Steps to start from: poolability; slope heterogeneity
(`pvcm` dispersion, with Pesaran–Yamagata as a stated limitation);
effects tests; fixed against random effects (Hausman, its robust `aux`
form, the two-way case, Hausman–Taylor); serial correlation (the full plm
battery, `pwfdtest` as the FE-against-FD choice); heteroskedasticity and
robust standard errors (`vcovHC`, `pggls`, the Driscoll–Kraay, Beck–Katz,
Newey–West and double-clustered menu side by side); summary. Theory notes:
"Fixed and random effects" and "The error of a panel regression". Gaps to
state: SLM and the conditional LM tests (B eqs. 4.26, 4.34, 4.36), Verbon
and Lejeune heteroskedasticity tests, Bester–Conley–Hansen, Kang's five
two-way hypotheses behind plm's single statistic.

### `06-dynamic`, dynamic panels (plan 0010)

Spec 4b.1 to 4b.3. `EmplUK`, non-negotiable. Steps to start from: the
problem (Nickell bias shown by simulation, bias by T in the shape of Nickell
1981 Table 1); the estimators (Anderson–Hsiao, difference GMM, system GMM
through `pgmm`, the three-part formula); the diagnostics (Sargan, AR(1) and
AR(2), Windmeijer as `summary(robust = TRUE)`, an instrument-count
sensitivity table with the Bowsher reading); summary. Theory note: "Dynamic
panel GMM". Gaps to state: Ahn–Schmidt, Kiviet bias-corrected FE,
transformed likelihood, Kripfganz–Schwarz; `pdynmc` tried once by the recon
agent and reported.

### `04-time`, cointegration (plan 0011)

Spec 2.1 to 2.3, after the traps step: `7-cointegration.qmd` ("Do they move
together in the long run?": the precondition, per-unit rank with
`urca::ca.jo`; Pedroni through `pco::pedroni99m` if it installs, as a weak
target; Kao, McCoskey–Kao, Larsson and Westerlund as limitations) and
`8-long-run.qmd` ("Estimating the long run": the CCE regression with a CIPS
test on its residuals as the substitute, labelled as such, CM §8.4.3;
FMOLS, DOLS, DSUR and the rest as limitations). `7-summary.qmd` becomes
`9-summary.qmd` and its labels `c04-9-*`. The chapter intro drops "not yet
written", the map gains the cointegration box, the summary's "Next" points
at the long-run step and then at chapter 05. Theory note: "Cointegration in
panels".

## Steps

Each step ends in its own commit.

- [x] **Render check.** Clear `_freeze/` and `_book/`, render the whole
  book, read the log, snapshot renv. Closes plan 0007's open item. Done
  2026-10-06: 16 pages, exit 0, no R error and no warning in the log.
- [ ] **Core: recon.** Chapter plan 0009 drafted, every call run.
- [ ] **Core: tooling.** Bibliography, helpers, snapshot.
- [ ] **Core: steps.** `index.qmd` and seven steps.
- [ ] **Core: theory.** Two notes.
- [ ] **Core: review and fix.** Findings list, fixes.
- [ ] **Core: wire in.** `_quarto.yml`, checklist, inbound links from 00,
  02, 03 and 04 retargeted to step anchors; chapter rendered; plan 0009
  closed.
- [ ] **Dynamic: recon.** Chapter plan 0010.
- [ ] **Dynamic: tooling.**
- [ ] **Dynamic: steps.**
- [ ] **Dynamic: theory.**
- [ ] **Dynamic: review and fix.**
- [ ] **Dynamic: wire in.** New chapter in `project: render:` and
  `book: chapters:`; checklist; road map; plan 0010 closed.
- [ ] **Cointegration: recon.** Chapter plan 0011.
- [ ] **Cointegration: tooling.**
- [ ] **Cointegration: steps.**
- [ ] **Cointegration: theory.**
- [ ] **Cointegration: review and fix.**
- [ ] **Cointegration: wire in.** Chapter 04 intro, map and summary;
  checklist; plan 0011 closed.
- [ ] **Close.** Full render from a clean `_freeze/`, dead-link crawl, the
  road map's "still to come" wording gone, outcome written here.

## Open questions

- Does `pco` install under R 4.6.1, and does `pedroni99m` accept the
  house-price panel as a `[time, individual, variable]` array?
- Grunfeld and house prices through every core step, as chapter 03 ran two
  panels, or Grunfeld for the checks and house prices in the summary only?
  The core recon agent decides and records why.
- `pdynmc`: one call on `EmplUK` by the dynamic recon agent; shown in a
  Pitfalls box if it runs, named as untested if not.

## Outcome

Filled in when the status becomes done or superseded.
