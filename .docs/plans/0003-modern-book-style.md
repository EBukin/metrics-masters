# Modernise the look and navigation of the book

- **Date:** 2026-10-04
- **Author:** Eduard Bukin
- **Status:** active

## Goal

The book looks current and is easy to navigate. The left sidebar lists every
chapter, and the open chapter unfolds into its sections as a collapsible list
that follows the reader's scroll position. The right-hand contents is shorter.
Light and dark modes both work. No chapter text changes.

## Context

The user's request, verbatim:

> The style of the book is really outdated. I would like it to be a little bit
> more modern or way more modern. Use Quarto and research decent templates in
> Quarto. Or to use event based template that exists already to style book more
> useful. So that every kind of chapter has at least a drop down on the left
> with the sections within the chapter. So we could navigate between, and then
> there is also a quality table of content, a little bit shorter than that. And
> so on.

Findings:

- The book uses Bootswatch `sandstone` with default settings.
- Quarto has no option to list a page's headings in the book sidebar. The
  maintainers confirm the sidebar holds top-level items only
  (quarto-dev/quarto-cli discussion #5859; feature request #13392).
  `toc-location: left` puts the page contents below the chapter list, not
  inside it.
- No maintained HTML book template does this either; existing book extensions
  target PDF or Typst (e.g. quarto-orange-book).
- So: a Bootstrap theme with custom SCSS, plus a small script that copies the
  page's own TOC under the active sidebar entry. The script works for any page,
  so it survives the Part restructure in plan 0002.

## Steps

- [x] Research Quarto options and templates.
- [ ] `assets/theme.scss` and `assets/theme-dark.scss`: fonts, colours,
  callouts, code blocks, sidebar.
- [ ] `assets/sidebar-toc.html`: nest page sections under the active chapter,
  collapsible, with scroll-spy.
- [ ] `_quarto.yml`: light/dark themes, code-copy, shorter right TOC
  (`toc-depth: 3`, `toc-expand: 1`), floating sidebar, repo-free tools.
- [ ] Update `CLAUDE.md` where it fixes `toc-depth: 4`.
- [ ] Render the book and check every page in light and dark mode.

## Open questions

- Fonts: Inter for headings and interface, Source Serif 4 for body, JetBrains
  Mono for code. Change if the user prefers an all-sans look.

## Outcome
