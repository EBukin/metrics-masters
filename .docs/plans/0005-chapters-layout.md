# Move the book into chapters/ and follow the workflow outline

- **Date:** 2026-10-05
- **Author:** Eduard Bukin
- **Status:** done

## Goal

All book material lives in `chapters/<NN>-<name>/`, one folder per chapter,
in the order fixed in `.docs/notes/0002-book-outline.md`: road map, explore
the panel, cross-sectional dependence, spatial dependence, time dependence,
core panel models. Each folder holds its chapter page, its step files and its
theory notes. Steps link to theory notes, which open in the right pane. The
old `panel-spat.qmd`, `unit-roots.qmd`, `examples/` and `theory/` are gone.
The book renders in full from a clean cache, with no dead links, and every
existing result and book check survives unchanged.

## Context

- The two-page layout from `proto/` is already in the main book (plan 0003,
  commits `5983c3a`, `25a7f71`). Proto still has two features the main book
  lacks: the `assets/terms.lua` filter and a glossary page.
- Today the book has two topic chapters and seven theory notes as appendices.
  Two notes are written (01, 07); five are placeholders.
- `CLAUDE.md` already describes the target layout (commit `26a3698`).
- This plan supersedes `.docs/plans/0002-restructure-panel-spat.md`: the
  panel-spat split now happens as part of the move.
- No R code or numerical result changes. Only files, labels, links and
  chapter intros move.

## Steps

Each step ends in its own commit. Use `git mv` so history follows the files.

- [x] **Templates.** Update `.docs/_templates/chapter.qmd` and `section.qmd`
  to `chapters/` paths and `c<chapter>-<step>-<what>` labels. Add a theory
  note template if none exists.
- [x] **Explore the panel** (`chapters/01-explore/`). `index.qmd` with a
  short intro and the setup chunk; `1-shape.qmd` from
  `examples/panel-spat/0-1-panel-shape.qmd`.
- [x] **Cross-sectional dependence** (`chapters/02-cross-dependence/`).
  - `index.qmd`: a short intro, then the setup chunk.
  - Steps in the new order: `1-tests.qmd` (from `0-4-csd-tests.qmd`),
    `2-exponent.qmd` (from `0-2-csd-exponent.qmd`), `3-cce.qmd` (from
    `0-3-cce.qmd`). Check that the tests step does not use objects that the
    exponent step creates; move shared objects to the setup chunk.
  - Theory: `theory-cross-sectional-dependence.qmd` (from theory 01),
    `theory-common-factors-cce.qmd` (from theory 04, placeholder).
- [x] **Spatial dependence** (`chapters/03-spatial/`). `index.qmd` as a
  placeholder chapter listing the spec sections 5.1–5.9. Theory placeholders:
  `theory-spatial-weights.qmd` (02), `theory-spatial-dependence-tests.qmd`
  (03), `theory-spatial-model-choice.qmd` (05),
  `theory-direct-indirect-effects.qmd` (06).
- [x] **Time dependence** (`chapters/04-time/`). `index.qmd` from
  `unit-roots.qmd`; steps `1-why.qmd` to `7-summary.qmd` from
  `examples/unit-roots/`; `theory-panel-unit-roots.qmd` from theory 07.
  Cointegration, serial correlation and dynamic panels stay as unticked lines
  in the `index.qmd` checklist until written.
- [x] **Core panel models** (`chapters/05-core/`). `index.qmd` as a
  placeholder chapter listing spec sections 3.1–3.3 and 4a.1–4a.4.
- [x] **Road map** (`chapters/00-road-map/index.qmd`). The "Same data, two
  answers" opener and its figure from `panel-spat.qmd`, a plain intro to the
  workflow, one decision diagram (mermaid) from panel set-up to the
  dependence fork, then numbered points linking each chapter.
- [x] **Labels.** Rename every chunk label to `c<chapter>-<step>-<what>`.
  Check that labels stay unique across the book.
- [x] **Links.** Rewrite every link to the old paths (about 94 today) to the
  new chapter pages and anchors. Theory notes in subfolders link back with
  `../` paths. Step anchors (`{#sec-...}`) keep their ids, so only the file
  part of each link changes.
- [x] **Book config.** Rewrite `_quarto.yml`: chapters in reading order
  under short part titles; theory notes in `project: render:` and in a
  "Theory" sidebar group outside the reading order, not as appendices. Set
  `execute-dir: project` if any chunk reads a path relative to its file.
- [x] **Proto features.** Add the `assets/terms.lua` filter to the main
  book. The glossary page waits (see Decisions).
- [x] **Tracker.** Rebuild the checklist in `index.qmd` around the new
  chapters; keep ticks only for written nodes.
- [x] **Clean up.** Delete `panel-spat.qmd`, `unit-roots.qmd`, `examples/`
  and `theory/` once nothing links to them. Mark plan 0002 superseded.
- [x] **Render.** Clear `_freeze/` and `_book/`, then render in full:
  `QUARTO_R="C:/Program Files/R/R-4.6.1/bin" quarto render`. Read the log for
  unresolved cross-references and R errors. Open the book and click through
  each chapter and each theory link in the pane.
- [x] **Outcome.** Fill in the outcome below; set status to done.

## Decisions

Settled with the user on 2026-10-05, before the work started:

- Glossary: wait. Add the `assets/terms.lua` filter now; build the glossary
  page once more chapters are written.
- The "Same data, two answers" opener and its figure go to the road map, not
  to the cross-dependence chapter.
- Placeholder chapters (spatial, core) appear in the sidebar now, each with a
  `Placeholder` callout.
- Theory notes are appendices with the heading renamed to "Theory"
  (`language: section-title-appendices`). A Quarto book drops a custom
  sidebar group, and a page listed only in `project: render:` is not built.

## Outcome

Done on 2026-10-05. The book lives in `chapters/00-road-map` to
`chapters/05-core`; `panel-spat.qmd`, `unit-roots.qmd`, `examples/` and
`theory/` are gone. A full render from a clean `_freeze/` and `_book/` builds
15 pages with no R errors, and a crawl of `_book/` finds no dead links or
anchors. Book checks print the same numbers as before (CD z = 53.26, CCE
elasticity 1.14).

- Moving the CD tests ahead of CCE exposed a hidden dependency:
  `plm::pcdtest()` on a formula needs `library(plm)`, which the CCE step used
  to attach. The tests step now attaches it itself.
- Theory notes are appendices headed "Theory" (see Decisions).
- `devtools` was missing from `renv.lock`; it is now installed and recorded.
- renv resolves this project's library to an external cache folder
  (`AppData/Local/R/cache/R/renv/library/metrics-masters-*`) that holds only
  renv, not to `renv/library/`. The render ran with
  `RENV_PATHS_LIBRARY=<project>/renv/library` set for the command. The cause
  is found in plan 0006: `renv/activate.R` treats a project with a
  `DESCRIPTION` file as a package and moves its library to the user cache.
  `.Rprofile` now sets the library path itself.
- Not done: clicking through the pane links by hand in a browser.
