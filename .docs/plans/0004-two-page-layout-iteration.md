# Two-page layout, iteration 2: alignment, back, notes, index

- **Date:** 2026-10-04
- **Author:** Eduard Bukin
- **Status:** active

## Goal

The two-page prototype in `proto/` looks finished. Every bar, button and
dropdown sits on one shared top line, with consistent sizes and spacing. The
right-hand pane has Back (and Forward) buttons. Every in-text link opens in the
pane, including links to the same page, footnotes and index terms. Footnotes
and index terms show only the note or the entry, not a whole page. The main
book (`_quarto.yml` at the root, `assets/` if present) is not touched.

## Context

The user's feedback on iteration 1 (commits `1f70ad2`, `6e61c56`), verbatim:

> this is a substantial improvement that looks actually almost as I expected
> however the alignment of elements could be done much better I can clearly see
> that some buttons are misaligned and misplaced and um, doesn't appear properly
> and we need to really figure this all out properly Uh, it's nice to have open
> here button and the close button and indeed showing different components on
> the right hand side. Could there also be is um there's a back button go back
> so if well, another section was opened on the right then there must be a
> button to go back so for example if people click on something on the right
> section and it opens this new things in the right section there should be a
> button to go back um I propose to have the same idea of this on this page drop
> down menu above the first um the left side of the book I think it's very
> convenient if we click on the same page, so on this page, for example, on the
> one page, we click on the link that refers to the same page. I would still
> prefer to open this link on the right, despite the fact that this can be the
> same chapter, just two different components of the chapter. Um, also, I would
> like you to test this right panel with the footnotes or end node. So if people
> click on the end node, it could appear on the right side the same way. And um,
> also, I would like you to test this with that central indexes. So if we index
> certain um, words or terminology, and this terminology appears somewhere in
> the index, clicking on this terminology here should probably open the locate
> on the index with this terminology.

### What exists

- `proto/` is an R-free Quarto book (`engine: markdown`) that renders in
  seconds. Plan 0003 records how it came about.
- `proto/assets/theme.scss`, `theme-dark.scss`: fonts, colours, base styles.
- `proto/assets/sidebar-toc.html`: copies the page TOC under the active
  sidebar entry.
- `proto/assets/two-page.scss` + `two-page.html`: fixed resizable sidebar
  (collapses to a rail on request), book page, draggable divider, iframe pane
  with Open here / Close, `?pane=` in the address, TOC as a floating pill.
- `proto/assets/in-pane.html` (in `<head>`): a page opened with `?tp-pane=1`
  names its window `tp-pane` and hides everything but its content.

### Defects seen in iteration 1 (screenshots at 1440×850)

1. **No shared top line.** Sidebar title block, book breadcrumb (y≈40px),
   pane bar (3rem, centre y≈25px) and the TOC pill (top 0.75rem, ≈30px tall)
   all sit at different heights.
2. **Sidebar toggle `‹`** floats in the sidebar's top-right corner above the
   title, not on the title row. The title wraps to two lines and the reader /
   dark-mode toggles wrap with it.
3. **TOC pill overlaps the pane bar.** The bar reserves `padding-right: 11rem`
   for it, so the pane title is cut short ("cd-test.html#sec-cd-p…").
4. **Pane title is raw:** link text ("Section 2.1.1") or a file name, never
   the page and section title.
5. **Anchor scroll in the pane hides the target heading.** Opening
   `unit-roots.html#sec-ips` shows the code below the heading; the heading
   itself is above the fold.
6. **Pane content starts flush under the bar**; the page title has no top
   padding.
7. **Divider and sidebar edge are invisible** until hovered; nothing tells
   the reader they can be dragged.
8. Chevrons in the sidebar (Part, Appendices, nested sections) do not line up
   on one x position.

### Constraints

- Pages are opened from `file://` as well as over http (`quarto preview`,
  hosting). On `file://` Chrome/Edge treat each file as its own origin, so the
  parent **cannot read the iframe's DOM or location**. All parent ↔ pane talk
  must go through `window.postMessage`.
- Quarto has no HTML index. Footnotes render as `a.footnote-ref[href="#fn1"]`
  with Quarto's own hover popup; the note sits in `section#footnotes` at the
  page end.
- Quarto's `aside` / `.column-margin` rule sets `z-index: 998`; never use
  `<aside>` for layout elements.
- Repo rules from `CLAUDE.md`: 80-column markdown, commit per step, stage
  explicit paths, **no Claude attribution or `Co-Authored-By` in commits**.
  Another session works on the main book; do not edit the root `_quarto.yml`,
  `CLAUDE.md`, chapters or `examples/`.

## Design

### Layout grid

One top bar height for all three columns: `--tp-bar: 3rem`. Everything
interactive in a bar is 1.9rem tall and vertically centred.

```
┌ sidebar ─────────────┬ book page ───────────────────┬ pane ─────────────────┐
│ Title        [‹]     │ Crumbs › Chapter  [On page ▾]│ [←][→] Title [▾][⤢][✕]│  ← 3rem bar
├──────────────────────┼──────────────────────────────┼───────────────────────┤
│ search               │                              │                       │
│ chapters + sections  │  page content                │  pane content         │
```

- **Sidebar bar:** book title on one line (ellipsis), the `‹` toggle at the
  right of the same row. Reader and dark-mode toggles move below the title
  or into the bar as icon buttons of the same size.
- **Book bar:** breadcrumb on the left, the "On this page" dropdown on the
  right (the user's proposal: the dropdown sits above the book page, not
  floating over the pane). Sticky at the top of the book column.
- **Pane bar:** Back, Forward, page title + section (ellipsis), the pane
  page's own "On this page" dropdown, Open here, Close. Icon buttons with
  tooltips; Bootstrap Icons are already loaded (`bi bi-arrow-left`,
  `bi-arrow-right`, `bi-list-ul`, `bi-box-arrow-up-left`, `bi-x-lg`).
- **Handles:** a visible 1px rule at each column edge plus a small grip on
  hover; cursor `col-resize`.

### Pane protocol (postMessage)

Pane page → parent, on load and on hash change:

```js
{ tp: "loaded", url, title, section, toc: [{ id, text, level }] }
```

Parent → pane:

```js
{ tp: "goto", id }        // scroll to an anchor (pane "On this page")
```

The parent keeps a history stack `[{ url, title }]` and an index. A
`loaded` message with a new url pushes (dropping forward entries); Back and
Forward set `frame.src` to the entry and mark the move so the next `loaded`
does not push. Validate `event.source === frame.contentWindow` and the
`tp` key; ignore anything else.

### Which links open in the pane

Every link inside `main.content` except: page navigation, breadcrumbs,
external sites, `target=_blank`, downloads, modifier-clicks. **Same-page
anchors now open in the pane too** (the same chapter at that section), so the
reader keeps their place on the left. The sidebar and the "On this page"
dropdown keep scrolling the left page.

### Snippet mode for notes and index terms

`?tp-pane=1&tp-only=<id>` makes the pane page show only the element with
that id (and, for a footnote, a small heading "Note n, from <chapter>"),
hiding the rest. Use it for:

- **Footnotes:** a click on `a.footnote-ref` opens the same page with
  `tp-only=fnN`. Quarto's hover popup stays.
- **Index terms:** see below.

### Index (prototype)

- New page `proto/glossary.qmd` ("Index"), unnumbered, listed before
  References. Each entry is a `{#term-<slug>}` div: term, one-line
  definition, and a "Used in" list of links back to the sections.
- In text, a term is marked `[unit root]{.term}` or
  `[unit roots]{.term key="unit-root"}`.
- A Lua filter `proto/assets/terms.lua` turns each `.term` span into a link
  `glossary.qmd#term-<slug>` with class `tp-term`. A click opens the entry in
  the pane in snippet mode.
- The "Used in" lists are written by hand for the prototype. An automatic
  index (a pre-render script that scans `.qmd` files for `.term` spans and
  writes the lists) is out of scope; note it in Open questions.

## Steps

Render and check after every step:

```sh
QUARTO_R="C:/Program Files/R/R-4.6.1/bin" quarto render proto
```

Verify with headless Edge from the repo root (no `cd` into `proto/_book`:
an open handle there blocks the next render):

```sh
E="/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
B="file:///C:/Users/wb532966/eb-local/metrics-masters/proto/_book"
"$E" --headless=new --disable-gpu --window-size=1440,850 \
  --virtual-time-budget=7000 --screenshot="<scratchpad>/x.png" \
  "$B/dependence.html?pane=unit-roots.html%23sec-ips"
```

Simulate clicks by copying a built page to `proto/_book/clk.html` with a
`<script src="clk.js">` that dispatches `MouseEvent("click")` on a link,
then screenshot or `--dump-dom`; delete both files after. Test light, dark
(`--force-dark-mode --blink-settings=preferredColorScheme=0`), 1440 and
1100 px wide, and the page wrapped in an outer iframe (editor preview case).

- [ ] **Test content.** Add to `proto/` pages: two footnotes, three
  `.term` spans, two same-page cross-references, one wide table. Add
  `glossary.qmd` with three entries.
- [ ] **Top bars.** Implement the three 3rem bars and move the "On this
  page" dropdown into the book bar (fixes defects 1, 2, 3, 6, 8).
- [ ] **Handles.** Visible column rules and grips (defect 7).
- [ ] **Pane protocol.** postMessage from `in-pane.html`/`two-page.html`;
  pane title shows page and section (defect 4); scroll with
  `scroll-margin-top` so the target heading is in view (defect 5).
- [ ] **Back / Forward** in the pane bar, with disabled states.
- [ ] **Pane "On this page"** dropdown fed by the `toc` message.
- [ ] **Same-page links** open in the pane.
- [ ] **Footnotes** in snippet mode.
- [ ] **Index:** `terms.lua`, `glossary.qmd`, snippet mode for entries.
- [ ] **Review pass:** screenshots of every case above; list any remaining
  misalignment and fix it. Update this plan's Outcome and plan 0003.

Commit after each step, staging explicit paths under `proto/` and
`.docs/plans/`.

## Open questions

- Automatic "Used in" lists for the index: pre-render script, or keep them
  by hand?
- Should citations open the bibliography entry in the pane (snippet mode on
  `#ref-<key>`)? Cheap once snippet mode exists.
- Pane history: keep it per page load only, or store it in the address?

## Outcome
