# metrics-masters

Reproductions of seminal econometric methods on canonical datasets, written for
economists to read. The project is a Quarto **book** website.

## Markdown formatting

- Wrap all markdown text at **80 characters**. Break at the last word that fits
  and continue on the next line.
- Divide text into **paragraphs**, separated by a blank line. Do not put each
  sentence on its own line, and do not leave a paragraph as one long line.
- This applies to markdown text only. Never re-wrap code inside chunks, and do
  not break URLs or table rows.
- Display math may be split across lines to stay inside 80 characters.

Example:

```markdown
**Theory.** The shape of the panel decides which methods are usable. *Micro*
panels have large N and short T, so asymptotics are large N, fixed T.

A panel is *unbalanced* when units are observed over different periods.
```

## Code chunks

- Every chunk carries a label, given as a `#| label:` option on the first line
  of the chunk. Labels are unique across the whole book.
- Name a label `s<section>-<what>`, e.g. `s0-1-pdim`, `s0-3-book-check`.
- `_quarto.yml` sets `results: hold`, so the printed output of a chunk appears
  in a single block after the code, not after each line. Do not override this
  per chunk without a reason.
- Keep R code inside 80 characters too; `air.toml` sets Air's line width.

## Writing the primer

- Each section of `.docs/panel-spat-PLAN.md` gets its own self-contained file
  in `examples/<topic>/`, holding theory, data, code and a book check. Section
  headings are `###`, because the chapter file supplies `#` and `##`.
- `panel-spat.qmd` only collects those files with `{{< include >}}`.
- Load packages with `library()` in the file that uses them.
- Keep examples extremely concise and self-explanatory.
- No test-style assertions (`stopifnot`, `all.equal`). Verification is a **Book
  check**: show the output beside the numbers the book prints, with pages.
- Cite every source from `references.bib` as `[@key, p. X]`. Add the entry
  before citing it.

## Book structure

- `_quarto.yml` defines the book: chapters are `index.qmd` (preface), the topic
  chapters, and `references.qmd` (the bibliography). Add new chapters to both
  `project: render:` and `book: chapters:`.
- Files under `examples/` are includes, not chapters, so they are not listed.

## R environment

- Install every package used into the project renv, then `renv::snapshot()`.
- Render the whole book with `quarto render`. If `QUARTO_R` is corrupted in the
  environment, override it for the command:
  `QUARTO_R="C:/Program Files/R/R-4.6.1/bin" quarto render`.
- Output goes to `_book/`, which is git-ignored.

## Editor

`.vscode/settings.json` sets format-on-save and 80-column rulers. Air formats R
(`air.toml`), Prettier formats plain Markdown (`.prettierrc`). No installed
extension formats a whole `.qmd`, so the 80-character prose rule above is
applied by hand.
