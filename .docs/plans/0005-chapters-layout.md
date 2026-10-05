# Move the book into chapters/ and follow the workflow outline

- **Date:** 2026-10-05
- **Author:** Eduard Bukin
- **Status:** draft

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

- [ ] **Templates.** Update `.docs/_templates/chapter.qmd` and `section.qmd`
  to `chapters/` paths and `c<chapter>-<step>-<what>` labels. Add a theory
  note template if none exists.
- [ ] **Explore the panel** (`chapters/01-explore/`). `index.qmd` with a
  short intro and the setup chunk; `1-shape.qmd` from
  `examples/panel-spat/0-1-panel-shape.qmd`.
- [ ] **Cross-sectional dependence** (`chapters/02-cross-dependence/`).
  - `index.qmd`: the "Same data, two answers" opener and its figure from
    `panel-spat.qmd`, then the setup chunk.
  - Steps in the new order: `1-tests.qmd` (from `0-4-csd-tests.qmd`),
    `2-exponent.qmd` (from `0-2-csd-exponent.qmd`), `3-cce.qmd` (from
    `0-3-cce.qmd`). Check that the tests step does not use objects that the
    exponent step creates; move shared objects to the setup chunk.
  - Theory: `theory-cross-sectional-dependence.qmd` (from theory 01),
    `theory-common-factors-cce.qmd` (from theory 04, placeholder).
- [ ] **Spatial dependence** (`chapters/03-spatial/`). `index.qmd` as a
  placeholder chapter listing the spec sections 5.1–5.9. Theory placeholders:
  `theory-spatial-weights.qmd` (02), `theory-spatial-dependence-tests.qmd`
  (03), `theory-spatial-model-choice.qmd` (05),
  `theory-direct-indirect-effects.qmd` (06).
- [ ] **Time dependence** (`chapters/04-time/`). `index.qmd` from
  `unit-roots.qmd`; steps `1-why.qmd` to `7-summary.qmd` from
  `examples/unit-roots/`; `theory-panel-unit-roots.qmd` from theory 07.
  Cointegration, serial correlation and dynamic panels stay as unticked lines
  in the `index.qmd` checklist until written.
- [ ] **Core panel models** (`chapters/05-core/`). `index.qmd` as a
  placeholder chapter listing spec sections 3.1–3.3 and 4a.1–4a.4.
- [ ] **Road map** (`chapters/00-road-map/index.qmd`). Plain intro to the
  workflow, one decision diagram (mermaid) from panel set-up to the
  dependence fork, then numbered points linking each chapter.
- [ ] **Labels.** Rename every chunk label to `c<chapter>-<step>-<what>`.
  Check that labels stay unique across the book.
- [ ] **Links.** Rewrite every link to the old paths (about 94 today) to the
  new chapter pages and anchors. Theory notes in subfolders link back with
  `../` paths. Step anchors (`{#sec-...}`) keep their ids, so only the file
  part of each link changes.
- [ ] **Book config.** Rewrite `_quarto.yml`: chapters in reading order
  under short part titles; theory notes in `project: render:` and in a
  "Theory" sidebar group outside the reading order, not as appendices. Set
  `execute-dir: project` if any chunk reads a path relative to its file.
- [ ] **Proto features.** Add the `assets/terms.lua` filter to the main
  book. Add a glossary page only after the open question below is settled.
- [ ] **Tracker.** Rebuild the checklist in `index.qmd` around the new
  chapters; keep ticks only for written nodes.
- [ ] **Clean up.** Delete `panel-spat.qmd`, `unit-roots.qmd`, `examples/`
  and `theory/` once nothing links to them. Mark plan 0002 superseded.
- [ ] **Render.** Clear `_freeze/` and `_book/`, then render in full:
  `QUARTO_R="C:/Program Files/R/R-4.6.1/bin" quarto render`. Read the log for
  unresolved cross-references and R errors. Open the book and click through
  each chapter and each theory link in the pane.
- [ ] **Outcome.** Fill in the outcome below; set status to done.

## Open questions

- Glossary: build one now from the terms the chapters already define, or
  wait until more chapters are written?
- Does the "Same data, two answers" opener belong to the cross-dependence
  chapter (as planned) or to the road map?
- Should placeholder chapters (spatial, core) appear in the sidebar now, or
  only once they have a first written step?

## Outcome

