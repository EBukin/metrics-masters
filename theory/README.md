# theory/

Short, intuitive notes on **why** each method exists and what its numbers mean.

## The three-layer contract

This repo says the same thing three times, at three altitudes. Each layer has one
job and should not do the others':

| Layer | File | Job | Contains |
|---|---|---|---|
| **Spec** | `.docs/panel-spat-PLAN.md` | What must be implemented and how it is verified | Equations by number, page refs, code refs, verification targets. No prose, no code. |
| **Theory** | `theory/*.qmd` | Why it exists, what the number means | Intuition, the minimum math, if/then rules. **No R code.** |
| **Example** | `examples/panel-spat/*.qmd` | Show it running on real data | R code, printed output, prose book check. Opens with 1–3 sentences of intuition and a link up to the theory note. |

Rule of thumb: if you are asking *"what does this number mean?"* read `theory/`.
If you are asking *"how do I compute it?"* read `examples/`. If you are asking
*"is the implementation right?"* read `.docs/panel-spat-PLAN.md`.

## Notes

This is a map, not a tracker. Which notes are written and which are still
placeholders is tracked in one place only: the node checklist in
[the preface](../index.qmd).

| # | Note | Covers | Plan § |
|---|---|---|---|
| 01 | [Cross-sectional dependence](01-cross-sectional-dependence.qmd) | Exponent α; CD test; BP LM / scaled LM / bias-corrected scaled LM; ρ̄ vs abs(ρ̄) | 0.2, 4a.3 |
| 02 | [Spatial weights and W](02-spatial-weights.qmd) | Choosing W, row standardisation, sparsity, what W assumes | 5.1 |
| 03 | [Testing for *spatial* dependence](03-spatial-dependence-tests.qmd) | CD_Moran, CD_local, randomised-W test; why local CD gives false positives under factors | 5.7 |
| 04 | [Common factors and CCE](04-common-factors-cce.qmd) | Heterogeneous loadings, why cross-section averages work as proxies, CCEP vs CCEMG | 0.3 |
| 05 | [Spatial model choice](05-spatial-model-choice.qmd) | SAR vs SEM vs SDM, and what each assumes about the spillover mechanism | 5.2, 5.5 |
| 06 | [Direct and indirect effects](06-direct-indirect-effects.qmd) | Why a SAR coefficient is not a marginal effect | 5.8 |

## Conventions

- Notes are **appendices of the book**. Each one is listed twice in `_quarto.yml`:
  under `project: render:` and under `book: appendices:`. Add both lines when you
  add a note, or its links will render as dead `.qmd` hrefs.
- No YAML `format:` or `bibliography:` block in a note — the project config
  supplies both. Citations are collected into `references.qmd` with the rest of
  the book.
- Every source is cited `[@key, p. X]` from `references.bib` at the repo root.
  Add the entry before citing anything new.
- The matching `examples/panel-spat/*.qmd` section opens with 1–3 sentences of
  intuition and links here as `theory/<file>.qmd` — a root-relative path, because
  Quarto resolves links in an included file against the *including* document.
- Where the literature is unsettled or an implementation is missing, say so in an
  **Open** section rather than papering over it.
