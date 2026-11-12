# Presentation template

Beamer theme `uoc` for talks: Metropolis restyled in navy and teal (the style of the SciML course
slides), with the University of Crete and FORTH logos on the title page and at the bottom of every
content slide.

## Layout

- `beamerthemeuoc.sty`: the theme.
- `logos/`: University of Crete (horizontal and seal) and FORTH logos.
- `tikz/`: standalone TikZ figures and their shared `tikz-preamble.tex`.
- `example/`: an example talk (`example.tex`) and its notes version (`example-notes.tex`).
- `justfile`: build recipes.

## Format

The class option sets the format; the theme works with both.

```latex
\documentclass[aspectratio=169, 10pt]{beamer}  % wide, 16:9
\documentclass[aspectratio=43,  10pt]{beamer}  % standard, 4:3
```

The example reads the ratio from `\aspect` (default `169`), so `just build example 43` builds the
4:3 version without editing the file. Include figures with
`\includegraphics[max width=\textwidth]{...}`: natural size when they fit, shrunk otherwise.

## Use

- `just new <talk>`: a new talk folder, copied from the example.
- `just build <talk> [43]`, `just notes <talk> [43]`, `just all <talk> [43]`: slides, notes version
  (slide left, notes right), or both, in `<talk>/build/`. Compile with LuaLaTeX.
- `just figures`: compile the TikZ figures whose PDF is out of date.
- `just present <talk>`: present the notes version with pdfpc.
- `just install`: link this folder into `~/Library/texmf`, so `\usetheme{uoc}` works for a talk
  anywhere on this machine.

Theme option: `\usetheme[nofooterlogos]{uoc}` removes the logos from the content slides.

## Helpers

`\term{}` key term, `\alert{}` the one thing not to miss, `\source{}` gray caption under a figure or
table, `\calc{}` supporting calculation under a bullet, `\hlrow` highlighted table row, `\var{}`
variable name. Presenter notes: `\note{...}` or `\note[itemize]{\item ...}` after the frame, with
`\nextslide` for the transition. `\begin{frame}[standout]` gives a navy closing slide.
