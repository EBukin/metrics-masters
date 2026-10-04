# Complete the Stage 1 write-up

- **Date:** 2026-10-04
- **Author:** Eduard Bukin
- **Status:** done

## Goal

Stage 1 (panel unit roots) of `.docs/panel-spat-PLAN.md` is complete as a
node set: the six example sections (1.1–1.6) and theory note 07, which they all
link to. Note 07 explains why each test exists and what a rejection means,
drawing on the literature that **plm**'s `?purtest`, `?cipstest` and
`?phansitest` cite.

## Context

All six Stage 1 example sections exist and are ticked in `index.qmd`. Theory
note 07 was still a placeholder. The help pages of **plm** cite four sources
that `references.bib` lacked: Hall (1994), Kwiatkowski et al. (1992),
MacKinnon (1994) and Pfaff (2008). The R session hung during this work, so
the references came from the **plm** sources on GitHub (`man/*.Rd`,
`inst/REFERENCES.bib`).

## Steps

- [x] Add Hall (1994), KPSS (1992), MacKinnon (1994), Pfaff (2008) to
  `references.bib`.
- [x] Write `theory/07-panel-unit-roots.qmd`, no R code, numbers taken from
  the rendered example sections.
- [x] Update the note 07 row in `theory/README.md` to cover 1.1–1.6.
- [x] Tick note 07 in `index.qmd`.
- [ ] Render the book with `quarto render` to check links and citations.

## Open questions

- `plm`'s bibliography gives Hanck (2013) as pp. 159–180; `references.bib`
  has pp. 183–203. Check against the journal.

## Outcome

Note 07 written. The render was not run in this session because R hung.
