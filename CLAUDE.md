# metrics-masters

<!-- caveman-begin -->
Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:
- Answer first: Answer, then reason, then next step.
- Kill ceremony: No greeting, hedging, pleasantries, recap, or closer.
- Short word: "fix" not "implement a solution for".
- Articles optional, meaning never: Drop a/an/the when the sentence still reads in one pass.
- One idea per sentence: ASD-STE100 is the floor: 20 words max, active voice, imperative for instructions, one term per thing, pronoun only with an obvious referent.
- Payload verbatim: Code blocks unchanged.
- Tool runs: bounded status: No text between routine calls.
- User's language: Compress the style, not the language.
- Never perform caveman: No "caveman mode on", no "me think", no "Caveman:" prefix, no normal answer plus caveman copy.

Switch: /caveman (default), /ultracave (fragments, each fact once), /megacave (Classical Chinese 文言文)
Stop: "stop caveman" or "normal mode"

Auto-Clarity: plain prose for security warnings, irreversible actions, step order a fragment could scramble, user confused. Resume after.

Boundaries: code, comments, commits, PRs, docs written normal.
Floor: code, commands, paths, numbers and error strings verbatim; never drop not/never/no/only.
<!-- caveman-end -->

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
- Name a label `c<chapter>-<step>-<what>`, after the chapter folder and step
  file, e.g. `c01-1-pdim` in `chapters/01-explore/1-shape.qmd`. Labels still
  named `s<section>-<what>` are renamed when their file moves.
- `_quarto.yml` sets `results: hold`, so the printed output of a chunk appears
  in a single block after the code, not after each line. Do not override this
  per chunk without a reason.
- Keep R code inside 80 characters too; `air.toml` sets Air's line width.
- **Call every function with its package prefix**, `pkg::fun()`, so a reader
  sees exactly where it comes from: `plm::pdim()`, never a bare `pdim()`.
- Base R needs no prefix: `base`, `stats`, `utils`, `methods` (so `coef()`,
  `summary()`, `data()`, `round()` stay plain).
- Do not call `library()` in examples by default: the `::` prefix loads the
  namespace and registers the S3 methods, so attaching adds nothing.
- **Exception**: a function that builds a call and evaluates it in the caller's
  environment needs its package attached. `plm::pmg()` and `plm::pcce()` call
  `plm()`, which fails with "could not find function" unless `library(plm)`
  ran. Keep the `pkg::` prefix anyway, attach the package, and say in a comment
  why it is attached.

### One test, one call

- **Write every test out, one call per test, in the open.** When a section
  applies several tests, the calls go one after another so the reader sees each
  function, its arguments, and its own output. Never hide them in a wrapper
  that takes the test name as an argument and returns one combined table: those
  calls are the whole reason the reader is here.

```r
# No — the reader never sees purtest called, and the arguments are gone.
battery <- function(test) plm::purtest(m, test = test, exo = "intercept")
sapply(c("levinlin", "ips", "madwu"), battery)

# Yes — three calls, three outputs, in the order the text discusses them.
plm::purtest(m, test = "levinlin", exo = "intercept", lags = 1)
plm::purtest(m, test = "ips", exo = "intercept", lags = 1)
plm::purtest(m, test = "madwu", exo = "intercept", lags = 1)
```

- Give each of those calls its own chunk when the text says something about
  each result in turn, and keep them in one chunk only when the point is the
  comparison itself.
- A helper is for plumbing that is *not* the point of the section: reshaping a
  panel, generating a DGP, one Monte Carlo replication. Even inside a
  replication function, spell every test out on its own line; never loop over a
  vector of test names.

## Writing the primer

- Write like *Mastering 'Metrics*: relatable example first, then a plain
  definition, a picture of the evidence, the math that tells the story (more
  than one equation per test when needed), economist vocabulary. The rules
  are in `.docs/notes/0001-writing-standard.md`.
- The book follows the practical workflow of a panel analysis, not the order
  of the sources. The outline is fixed in
  `.docs/notes/0002-book-outline.md`; change it there first.
- All book material lives in `chapters/`. Each subfolder is one chapter,
  numbered in reading order: `chapters/<NN>-<short-name>/`. It holds:
  - `index.qmd`, the chapter: title, intro, setup chunk, `{{< include >}}`
    lines. Start from `.docs/_templates/chapter.qmd`.
  - the steps, one file each, `<n>-<what>.qmd`, built from
    `.docs/_templates/section.qmd`. Steps are includes, not pages. Section
    headings are `##` and a few words long; the chapter supplies `#`.
  - the theory notes, `theory-<what>.qmd`. Each is its own page, so a link
    from a step opens it in the right pane.
- Steps carry the story: what to run, then how to read the result. Theory
  notes explain why, and steps link to them at the point of use.
- Never use a term before it is explained. A term from another chapter gets
  a one-line gloss and a link back. Road maps are numbered points, not
  flowcharts. **Exception**: the road map chapter carries one decision
  diagram of the whole process.
- `panel-spat.qmd`, `unit-roots.qmd`, `examples/` and `theory/` are the old
  layout. They move into `chapters/` and are then deleted.
- **Never put manual numbers in a heading** (no "0.1", no "Stage 0 —" prefix on
  a section). Quarto numbers headings itself, and the plan's section number
  belongs in the text, not the title. Give each section a `{#sec-...}` id so it
  can be linked.
- `_quarto.yml` keeps `number-depth: 2`, so only chapters and their top-level
  sections are numbered, and `toc-depth: 3` with `toc-expand: 1`, so the
  "On this page" dropdown stays short.
- The book uses a two-page layout: a fixed sidebar, the book page, and a pane
  on the right where links in the text open. Theme, layout and scripts live in
  `assets/` (`theme.scss`, `two-page.scss`, `two-page.html`, `in-pane.html`,
  `sidebar-toc.html`). Try layout changes first in `proto/`, an R-free mini
  book that shares `assets/` and renders in seconds (`quarto render proto`).
- Chapter files hold the intro, the setup chunk and `{{< include >}}` lines.
- Load packages with `library()` in the file that uses them.
- Keep examples extremely concise and self-explanatory.
- No test-style assertions (`stopifnot`, `all.equal`). Verification is a **Book
  check**: show the output beside the numbers the book prints, with pages.
- Cite every source from `references.bib` as `[@key, p. X]`. Add the entry
  before citing it.

## Nodes and links

- Every document in this system is a **node**: a chapter, a step, a theory
  note, or the spec in `.docs/`.
- Any mention of another node is a **proper link**, never a bare name or a
  loose section number. Link a step by its chapter and anchor, e.g.
  `[CCE](../02-cross-dependence/index.qmd#sec-cce)`, because steps are
  includes, not pages, and a link to their `.qmd` path renders dead. Give each
  step an explicit `{#sec-...}` id so it can be linked. Link a theory note by
  its path; it opens in the pane.
- If the node being referred to does not exist yet, **create it as a
  placeholder in the same change**: YAML title, a `Placeholder` callout, and a
  short "What this note should cover" list. Then link to it. Never leave a
  dangling mention.
- The spec in `.docs/` is not rendered into the book, so refer to it by path in
  code style (`.docs/panel-spat-PLAN.md`) rather than as a link, which would be
  dead in the built site.
- Track nodes in the checklist in `index.qmd`. That is the single source of
  truth for what is written and what is still to do; no status tables
  elsewhere. Tick a box when the node is written, not when its placeholder is
  created, and add a line there whenever a node is created.

## Book structure

- `_quarto.yml` defines the book: `index.qmd` (preface), each
  `chapters/<NN>-<name>/index.qmd`, and `references.qmd` (the bibliography).
  Add a new chapter to both `project: render:` and `book: chapters:`.
- Theory notes are rendered pages: list each in `project: render:`, and under
  the "Theory" group in the sidebar, outside the reading order.
- Step files are includes, not pages, so they are not listed.

<!-- eb:git -->
## Git

- Commit as the edits are made, not in one batch at the end.
- Keep each commit a single clear unit: settings and tooling, materials
  (spec, bibliography, theory notes), examples, tracker.
- **Never put a `Co-Authored-By: Claude ...` trailer, or any other attribution
  to Claude Code, in a commit message.** This is not permitted in this repo.
  Check the message before every commit.
- Commit messages and pull-request text carry no email address and no AI
  attribution: no `Co-Authored-By`, no "Generated with". The hook in
  `.claude/hooks/no-coauthor.sh` blocks a violation; write different text,
  never work around it.
- Stage explicit paths, never `git add -A`.
<!-- /eb:git -->

<!-- eb:r -->
## R environment

- Install every package used into the project renv, then `renv::snapshot()`.
- Render the whole book with `quarto render`. If `QUARTO_R` is corrupted in the
  environment, override it for the command:
  `QUARTO_R="C:/Program Files/R/R-4.6.1/bin" quarto render`.
- Output goes to `_book/`, which is git-ignored.
- Run R through the `run-r` skill (`mcp__r__repl` and its siblings). It covers
  the `Rscript` fallback when those tools are missing; do not improvise one.
- When you write or change R code, use Posit's `r-lib` skills, enabled for this
  project, before your own habits:
  - `r-lib:r-package-development` for package layout, roxygen2 documentation,
    the devtools and usethis workflow;
  - `r-lib:testing-r-packages` for every test: testthat 3, fixtures,
    snapshots, mocking;
  - `r-lib:cli` for every user-facing message, error or progress bar
    (`cli_abort()`, `cli_warn()`, `cli_inform()`, not bare `stop()`,
    `warning()`, `message()`);
  - `r-lib:lifecycle` when deprecating, renaming or superseding a function or
    argument;
  - `r-lib:mirai` for parallel or asynchronous R;
  - `r-lib:r-cli-app` when a script becomes a command-line tool;
  - `r-lib:cran-extrachecks`, `r-lib:r-cran-status` and `r-lib:alt-text` for a
    release, a CRAN check, or figure alt text.
- `R/` holds shared functions only, one topic per file, roxygen-documented.
  Load them with `devtools::load_all()`.
- `chapters/` holds the documents (`.qmd`) that call those functions; results
  saved to disk go to `output/`.
- The R session's working directory is where Claude Code was started, not the
  script's folder: build paths from the project root.
<!-- /eb:r -->

## Editor

`.vscode/settings.json` sets format-on-save and 80-column rulers. Air formats R
(`air.toml`), Prettier formats plain Markdown (`.prettierrc`). No installed
extension formats a whole `.qmd`, so the 80-character prose rule above is
applied by hand.

<!-- eb:conversation -->
## How to answer

- Short replies: bullets, no preamble, no recap. Lead with the result.
- Code, commands, paths and error text go in fenced blocks, not in prose.
- One question at a time, and only when the answer changes what you do next.
  Otherwise state the assumption and proceed.
- Do not narrate what you are about to do or restate what you did. Say what
  changed and what is left.
<!-- /eb:conversation -->

<!-- eb:docs -->
## Documentation lives in `.docs/`

Three numbered series, `NNNN-short-name.md`: four digits, next number = highest
existing + 1, lowercase words joined by hyphens. Start from the template in
`.docs/_templates/`; do not write one from memory.

| Folder | Write one when | It starts with |
|---|---|---|
| `.docs/plans/` | before any multi-step task; update its status as work moves | date, author, status, goal |
| `.docs/handoffs/` | a session ends with work unfinished; written for an agent with no context | date, where things stand, how to verify, next steps |
| `.docs/notes/` | the user says "note this" or "record this", or a decision is worth keeping | date, author, one-line summary, then the instruction quoted verbatim |

Quote the user's instruction verbatim in a note before paraphrasing it. Never
renumber, rename or delete an existing file in these folders.
<!-- /eb:docs -->

<!-- eb:data -->
## Data and outputs

- Raw data lives outside this repository at `{{DATA_PATH}}`. Read it in place;
  never copy it into the repo.
- Only results are saved here: tables in `output/tables/`, figures in
  `output/figures/`. Everything under `output/` is produced by code and never
  edited by hand.
<!-- /eb:data -->

<!-- eb:stata -->
## Stata

- Stata code lives in `code/`. Run `.do` files through the `stata-run` skill
  (`stata_run_file`); it covers the fallback when those tools are missing.
- Stata's batch exit code is `0` even on failure. Read the log for `r(` errors
  before reporting success. Logs (`*.log`, `*.smcl`) are gitignored.
<!-- /eb:stata -->
